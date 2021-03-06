﻿SELECT
    STO.METRIC_TYPE
    , STO.STO_CREATE_MONTH_DT AS STO_MONTH_DT
    , STO.MATL_ID
    , STO.MATL_DESCR
    , STO.PBU_NBR
    , STO.PBU_NAME
    , STO.CATEGORY_CD
    , STO.CATEGORY_NM
    , STO.TIER
    , STO.EXT_MATL_GRP_ID
    , STO.MATL_PRTY
    , STO.SHIP_FACILITY_ID
    , STO.SHIP_FACILITY_NAME
    , STO.RECV_FACILITY_ID
    , STO.RECV_FACILITY_NAME
    , STO.PO_UOM_CD
    , STO.OUTBOUND_QTY AS STO_QTY
    , STO.STO_ONTIME_QTY
    , STO.STO_LATE_QTY

FROM (

SELECT
    CAST('STO - PO Create' AS VARCHAR(255)) AS METRIC_TYPE
    , CRT_CAL.MONTH_DT AS STO_CREATE_MONTH_DT
    --, POST_CAL.MONTH_DT AS POST_MTH_DT

    , PDI.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NBR
        ELSE M.MKT_CTGY_MKT_GRP_NBR
        END AS CATEGORY_CD
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NAME
        ELSE M.MKT_CTGY_MKT_GRP_NAME
        END AS CATEGORY_NM
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_PROD_GRP_NAME
        ELSE M.TIERS
        END AS TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , PD.FACILITY_ID AS SHIP_FACILITY_ID
    , PD_F.FACILITY_DESC AS SHIP_FACILITY_NAME
    , PDI.FACILITY_ID AS RECV_FACILITY_ID
    , PDI_F.FACILITY_DESC AS RECV_FACILITY_NAME

    , PDI.PO_UOM_CD
    --  Outbound Metrics
    , SUM(DDI.ACTL_DELIV_QTY) AS OUTBOUND_QTY
    , SUM(CASE 
        WHEN PDH.POST_DT <= (PSL.REQ_DELIV_DT + PDI.GOODS_RCPT_DY_QTY)
            THEN DDI.ACTL_DELIV_QTY
        ELSE 0
        END) AS STO_ONTIME_QTY
    , OUTBOUND_QTY - STO_ONTIME_QTY AS STO_LATE_QTY

FROM GDYR_VWS.PRCH_DOC PD

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CRT_CAL
        ON CRT_CAL.DAY_DATE = PD.CREATE_DT

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
            AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PDI.EXP_DT = PD.EXP_DT
            AND PDI.CO_CD IN ('N101', 'N102', 'N266')

    --------------------------------------------------------------------------------------------------------------------------------------------------
    -- Joining to PSL will cause duplicates when there are multiple schedule lines.
    -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
    -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
    --------------------------------------------------------------------------------------------------------------------------------------------------  
    INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
        ON PDI.PRCH_DOC_ID = PSL.PRCH_DOC_ID
            AND PDI.PRCH_DOC_ITM_ID = PSL.PRCH_DOC_ITM_ID
            AND PDI.ORIG_SYS_ID = PSL.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
        ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDH.EXP_DT = PDI.EXP_DT
            AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
            AND PDH.MVMNT_TYP_CD = '101'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL POST_CAL
        ON POST_CAL.DAY_DATE = PDH.POST_DT
            
    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON PDH.MATL_DOC_ID = MD.MATL_DOC_ID
            AND PDH.MATL_DOC_YR = MD.MATL_DOC_YR
            AND PDH.ORIG_SYS_ID = MD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
        ON MD.GOODS_RCPT_BOL_ID = DD.BILL_LADING_ID
            AND MD.ORIG_SYS_ID = DD.ORIG_SYS_ID
            AND DD.DELIV_TYP_CD <> 'EL'

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
        ON DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
            AND DD.FISCAL_YR = DDI.FISCAL_YR
            AND PDH.PRCH_DOC_ID = DDI.SLS_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = DDI.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PD_F
        ON PD_F.FACILITY_ID = PD.FACILITY_ID
            AND PD_F.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PD_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PD_F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PDI_F
        ON PDI_F.FACILITY_ID = PDI.FACILITY_ID
            AND PDI_F.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDI_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PDI_F.DISTR_CHAN_CD = '81'

WHERE 
    PD.ORIG_SYS_ID = 2
    AND PD.EXP_DT = CAST('5555-12-31' AS DATE)
    AND PD.CO_CD IN ('N101', 'N102', 'N266')

    AND PD.PRCH_TYPE_CD IN ('ZB', 'ZS', 'IB', 'CS', 'CB', 'UB')

    AND M.PBU_NBR = '01'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    AND CRT_CAL.DAY_DATE BETWEEN DATE '2014-01-01' AND DATE '2014-12-31'

GROUP BY
    STO_CREATE_MONTH_DT
    --, POST_MTH_DT

    , PDI.MATL_ID
    , MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CATEGORY_CD
    , CATEGORY_NM
    , TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , SHIP_FACILITY_ID
    , SHIP_FACILITY_NAME
    , RECV_FACILITY_ID
    , RECV_FACILITY_NAME

    , PDI.PO_UOM_CD

UNION ALL

SELECT
    CAST('STO - PO Goods Issue Delivery' AS VARCHAR(255)) AS METRIC_TYPE
    , AGID_CAL.MONTH_DT AS AGID_MONTH_DT
    --, POST_CAL.MONTH_DT AS POST_MTH_DT

    , PDI.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NBR
        ELSE M.MKT_CTGY_MKT_GRP_NBR
        END AS CATEGORY_CD
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NAME
        ELSE M.MKT_CTGY_MKT_GRP_NAME
        END AS CATEGORY_NM
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_PROD_GRP_NAME
        ELSE M.TIERS
        END AS TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , PD.FACILITY_ID AS SHIP_FACILITY_ID
    , PD_F.FACILITY_DESC AS SHIP_FACILITY_NAME
    , PDI.FACILITY_ID AS RECV_FACILITY_ID
    , PDI_F.FACILITY_DESC AS RECV_FACILITY_NAME

    , PDI.PO_UOM_CD
    --  Outbound Metrics
    , SUM(DDI.ACTL_DELIV_QTY) AS OUTBOUND_QTY
    , SUM(CASE 
        WHEN PDH.POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY)
            THEN DDI.ACTL_DELIV_QTY
        ELSE 0
        END) AS GOODS_ISSUE_ONTIME_DELIV_QTY
    , OUTBOUND_QTY - GOODS_ISSUE_ONTIME_DELIV_QTY AS GOODS_ISSUE_LATE_DELIV_QTY

FROM GDYR_VWS.PRCH_DOC PD

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
            AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PDI.EXP_DT = PD.EXP_DT
            AND PDI.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
        ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDH.EXP_DT = PDI.EXP_DT
            AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
            AND PDH.MVMNT_TYP_CD = '101'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL POST_CAL
        ON POST_CAL.DAY_DATE = PDH.POST_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON PDH.MATL_DOC_ID = MD.MATL_DOC_ID
            AND PDH.MATL_DOC_YR = MD.MATL_DOC_YR
            AND PDH.ORIG_SYS_ID = MD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
        ON MD.GOODS_RCPT_BOL_ID = DD.BILL_LADING_ID
            AND MD.ORIG_SYS_ID = DD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AGID_CAL
        ON AGID_CAL.DAY_DATE = DD.ACTL_GOODS_MVT_DT

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
        ON DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
            AND DD.FISCAL_YR = DDI.FISCAL_YR
            AND PDH.PRCH_DOC_ID = DDI.SLS_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = DDI.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PD_F
        ON PD_F.FACILITY_ID = PD.FACILITY_ID
            AND PD_F.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PD_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PD_F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PDI_F
        ON PDI_F.FACILITY_ID = PDI.FACILITY_ID
            AND PDI_F.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDI_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PDI_F.DISTR_CHAN_CD = '81'

WHERE 
    PD.ORIG_SYS_ID = 2
    AND PD.EXP_DT = CAST('5555-12-31' AS DATE)
    AND PD.CO_CD IN ('N101', 'N102', 'N266')

    AND PD.PRCH_TYPE_CD IN ('ZB', 'ZS', 'IB', 'CS', 'CB', 'UB')

    AND M.PBU_NBR = '01'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    AND AGID_CAL.DAY_DATE BETWEEN DATE '2014-01-01' AND DATE '2014-12-31'

GROUP BY
    AGID_MONTH_DT
    --, POST_MTH_DT

    , PDI.MATL_ID
    , MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CATEGORY_CD
    , CATEGORY_NM
    , TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , SHIP_FACILITY_ID
    , SHIP_FACILITY_NAME
    , RECV_FACILITY_ID
    , RECV_FACILITY_NAME

    , PDI.PO_UOM_CD

UNION ALL

SELECT
    CAST('STO - PO Goods Issue' AS VARCHAR(255)) AS METRIC_TYPE
    , AGID_CAL.MONTH_DT AS AGID_MONTH_DT
    --, POST_CAL.MONTH_DT AS POST_MTH_DT

    , PDI.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NBR
        ELSE M.MKT_CTGY_MKT_GRP_NBR
        END AS CATEGORY_CD
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NAME
        ELSE M.MKT_CTGY_MKT_GRP_NAME
        END AS CATEGORY_NM
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_PROD_GRP_NAME
        ELSE M.TIERS
        END AS TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , PD.FACILITY_ID AS SHIP_FACILITY_ID
    , PD_F.FACILITY_DESC AS SHIP_FACILITY_NAME
    , PDI.FACILITY_ID AS RECV_FACILITY_ID
    , PDI_F.FACILITY_DESC AS RECV_FACILITY_NAME

    , PDI.PO_UOM_CD
    --  Outbound Metrics
    , SUM(DDI.ACTL_DELIV_QTY) AS OUTBOUND_QTY

    , SUM(CASE 
        WHEN DD.ACTL_GOODS_MVT_DT <= DD.PLN_GOODS_MVT_DT
            THEN DDI.ACTL_DELIV_QTY
        ELSE 0
        END) AS GOODS_ISSUE_ONTIME_QTY
    , OUTBOUND_QTY - GOODS_ISSUE_ONTIME_QTY AS GOODS_ISSUE_LATE_QTY

FROM GDYR_VWS.PRCH_DOC PD

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
            AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PDI.EXP_DT = PD.EXP_DT
            AND PDI.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
        ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDH.EXP_DT = PDI.EXP_DT
            AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
            AND PDH.MVMNT_TYP_CD = '101'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL POST_CAL
        ON POST_CAL.DAY_DATE = PDH.POST_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON PDH.MATL_DOC_ID = MD.MATL_DOC_ID
            AND PDH.MATL_DOC_YR = MD.MATL_DOC_YR
            AND PDH.ORIG_SYS_ID = MD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
        ON MD.GOODS_RCPT_BOL_ID = DD.BILL_LADING_ID
            AND MD.ORIG_SYS_ID = DD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AGID_CAL
        ON AGID_CAL.DAY_DATE = DD.ACTL_GOODS_MVT_DT

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
        ON DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
            AND DD.FISCAL_YR = DDI.FISCAL_YR
            AND PDH.PRCH_DOC_ID = DDI.SLS_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = DDI.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PD_F
        ON PD_F.FACILITY_ID = PD.FACILITY_ID
            AND PD_F.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PD_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PD_F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PDI_F
        ON PDI_F.FACILITY_ID = PDI.FACILITY_ID
            AND PDI_F.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDI_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PDI_F.DISTR_CHAN_CD = '81'

WHERE 
    PD.ORIG_SYS_ID = 2
    AND PD.EXP_DT = CAST('5555-12-31' AS DATE)
    AND PD.CO_CD IN ('N101', 'N102', 'N266')

    AND PD.PRCH_TYPE_CD IN ('ZB', 'ZS', 'IB', 'CS', 'CB', 'UB')

    AND M.PBU_NBR = '01'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    AND AGID_CAL.DAY_DATE BETWEEN DATE '2014-01-01' AND DATE '2014-12-31'

GROUP BY
    AGID_MONTH_DT
    --, POST_MTH_DT

    , PDI.MATL_ID
    , MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CATEGORY_CD
    , CATEGORY_NM
    , TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , SHIP_FACILITY_ID
    , SHIP_FACILITY_NAME
    , RECV_FACILITY_ID
    , RECV_FACILITY_NAME

    , PDI.PO_UOM_CD

UNION ALL

SELECT
    CAST('STO - PO Goods Receipt' AS VARCHAR(255)) AS METRIC_TYPE
    , POST_CAL.MONTH_DT AS RCVE_MTH_DT
    --, POST_CAL.MONTH_DT AS POST_MTH_DT

    , PDI.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NBR
        ELSE M.MKT_CTGY_MKT_GRP_NBR
        END AS CATEGORY_CD
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_MKT_AREA_NAME
        ELSE M.MKT_CTGY_MKT_GRP_NAME
        END AS CATEGORY_NM
    , CASE
        WHEN M.PBU_NBR = '01'
            THEN M.MKT_CTGY_PROD_GRP_NAME
        ELSE M.TIERS
        END AS TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , PD.FACILITY_ID AS SHIP_FACILITY_ID
    , PD_F.FACILITY_DESC AS SHIP_FACILITY_NAME
    , PDI.FACILITY_ID AS RECV_FACILITY_ID
    , PDI_F.FACILITY_DESC AS RECV_FACILITY_NAME

    , PDI.PO_UOM_CD

    , SUM(DDI.ACTL_DELIV_QTY) AS INBOUND_QTY
    , SUM(CASE 
        WHEN PDH.POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY)
            THEN (DDI.ACTL_DELIV_QTY)
        ELSE (0)
        END) AS GOODS_RECEIPT_ONTIME_QTY
    , INBOUND_QTY - GOODS_RECEIPT_ONTIME_QTY AS GOODS_RECEIPT_LATE_QTY

FROM GDYR_VWS.PRCH_DOC PD

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
            AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PDI.EXP_DT = PD.EXP_DT
            AND PDI.CO_CD IN ('N101', 'N102', 'N266')

    --------------------------------------------------------------------------------------------------------------------------------------------------
    -- Joining to PSL will cause duplicates when there are multiple schedule lines.
    -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
    -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
    --------------------------------------------------------------------------------------------------------------------------------------------------  
    INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
        ON PDI.PRCH_DOC_ID = PSL.PRCH_DOC_ID
            AND PDI.PRCH_DOC_ITM_ID = PSL.PRCH_DOC_ITM_ID
            AND PDI.ORIG_SYS_ID = PSL.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
        ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDH.EXP_DT = PDI.EXP_DT
            AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
            AND PDH.MVMNT_TYP_CD = '101'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL POST_CAL
        ON POST_CAL.DAY_DATE = PDH.POST_DT
            
    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON PDH.MATL_DOC_ID = MD.MATL_DOC_ID
            AND PDH.MATL_DOC_YR = MD.MATL_DOC_YR
            AND PDH.ORIG_SYS_ID = MD.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
        ON MD.GOODS_RCPT_BOL_ID = DD.BILL_LADING_ID
            AND MD.ORIG_SYS_ID = DD.ORIG_SYS_ID
            AND DD.DELIV_TYP_CD = 'EL'

    INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
        ON DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
            AND DD.FISCAL_YR = DDI.FISCAL_YR
            AND PDH.PRCH_DOC_ID = DDI.SLS_DOC_ID
            AND PDH.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
            AND PDH.ORIG_SYS_ID = DDI.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PD_F
        ON PD_F.FACILITY_ID = PD.FACILITY_ID
            AND PD_F.ORIG_SYS_ID = PD.ORIG_SYS_ID
            AND PD_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PD_F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PDI_F
        ON PDI_F.FACILITY_ID = PDI.FACILITY_ID
            AND PDI_F.ORIG_SYS_ID = PDI.ORIG_SYS_ID
            AND PDI_F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND PDI_F.DISTR_CHAN_CD = '81'

WHERE 
    PD.ORIG_SYS_ID = 2
    AND PD.EXP_DT = CAST('5555-12-31' AS DATE)
    AND PD.CO_CD IN ('N101', 'N102', 'N266')

    AND PD.PRCH_TYPE_CD IN ('ZB', 'ZS', 'IB', 'CS', 'CB', 'UB')

    AND M.PBU_NBR = '01'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    AND POST_CAL.DAY_DATE BETWEEN DATE '2014-01-01' AND DATE '2014-12-31'

GROUP BY
    RCVE_MTH_DT
    --, POST_MTH_DT

    , PDI.MATL_ID
    , MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , CATEGORY_CD
    , CATEGORY_NM
    , TIER
    , M.EXT_MATL_GRP_ID
    , M.MATL_PRTY

    , SHIP_FACILITY_ID
    , SHIP_FACILITY_NAME
    , RECV_FACILITY_ID
    , RECV_FACILITY_NAME

    , PDI.PO_UOM_CD

    ) STO
    
    INNER JOIN () FCDD
        ON FCDD.FMAD_MTH_DT = STO.STO_MONTH_DT
        AND FCDD.MATL_ID = STO.MATL_ID
        AND FCDD.SHIP_FACILITY_ID = STO.RECV_FACILITY_ID

