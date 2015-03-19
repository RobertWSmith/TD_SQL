SELECT
    STO.METRIC_TYPE
    , STO.COMPLETE_MTH_DT

    --, STO.MATL_ID
    --, STO.MATL_DESCR
    , STO.PBU_NBR
    , STO.PBU_NAME
    --, STO.CATEGORY_CD
    --, STO.CATEGORY_NM
    --, STO.TIER
    --, STO.EXT_MATL_GRP_ID
    --, STO.MATL_PRTY

    --, STO.FACILITY_ID
    --, STO.FACILITY_DESC

    , STO.QTY_UNIT_MEAS_ID
    , SUM(STO.STO_QTY) AS STO_QTY
    , SUM(STO.STO_ONTIME_QTY) AS STO_ONTIME_QTY
    , SUM(STO.STO_LATE_QTY) AS STO_LATE_QTY

FROM (

    SELECT
        CAST('STO - Outbound Deliver On Time' AS VARCHAR(255)) AS METRIC_TYPE
        , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
        , SUM(DDI.ACTL_DELIV_QTY) AS STO_QTY
        , SUM(CASE 
            WHEN PDH.POST_DT <= (PSL.REQ_DELIV_DT + PDI.GOODS_RCPT_DY_QTY)
                THEN DDI.ACTL_DELIV_QTY
            ELSE 0
            END) AS STO_ONTIME_QTY
        , STO_QTY - STO_ONTIME_QTY AS STO_LATE_QTY

    FROM GDYR_VWS.PRCH_DOC PD

        INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
            ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                AND PDI.EXP_DT = PD.EXP_DT
                --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

        --------------------------------------------------------------------------------------------------------------------------------------------------
        -- Joining to PSL will cause duplicates when there are multiple schedule lines.
        -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
        -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
        --------------------------------------------------------------------------------------------------------------------------------------------------  
        INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
            ON PSL.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PSL.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PSL.ORIG_SYS_ID = PDI.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON PDI.MATL_ID = M.MATL_ID
                AND M.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
            ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
                AND PDH.EXP_DT = PDI.EXP_DT
                AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
                AND PDH.MVMNT_TYP_CD = '101'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = PDH.POST_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_ID = PDH.MATL_DOC_ID
                AND MD.MATL_DOC_YR = PDH.MATL_DOC_YR
                AND MD.ORIG_SYS_ID = PDH.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
            ON DD.BILL_LADING_ID = MD.GOODS_RCPT_BOL_ID
                AND DD.ORIG_SYS_ID = MD.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
            ON DDI.FISCAL_YR = DD.FISCAL_YR
                AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                AND DDI.SLS_DOC_ID = PDH.PRCH_DOC_ID
                AND DDI.SLS_DOC_ITM_ID = PDH.PRCH_DOC_ITM_ID
                AND DDI.ORIG_SYS_ID = PDH.ORIG_SYS_ID

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

        AND DD.DELIV_TYP_CD <> 'EL'
        AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
        --AND M.MATL_ID = '000000000000019032'
        AND PDH.POST_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
            AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

    GROUP BY
        METRIC_TYPE
        , COMPLETE_MTH_DT

        , PDI.MATL_ID
        , MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , CATEGORY_CD
        , CATEGORY_NM
        , TIER
        , M.EXT_MATL_GRP_ID
        , M.MATL_PRTY

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD

    UNION ALL

    SELECT
        CAST('STO - Outbound Goods Issue Deliv On Time' AS VARCHAR(255)) AS METRIC_TYPE
        , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
        , SUM(DDI.ACTL_DELIV_QTY) AS STO_QTY
        , SUM(CASE 
            WHEN PDH.POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY)
                THEN DDI.ACTL_DELIV_QTY 
            ELSE 0 
            END) AS STO_ONTIME_QTY
        , STO_QTY - STO_ONTIME_QTY AS STO_LATE_QTY

    FROM GDYR_VWS.PRCH_DOC PD

        INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
            ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                AND PDI.EXP_DT = PD.EXP_DT
                --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

        --------------------------------------------------------------------------------------------------------------------------------------------------
        -- Joining to PSL will cause duplicates when there are multiple schedule lines.
        -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
        -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
        --------------------------------------------------------------------------------------------------------------------------------------------------  
        INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
            ON PSL.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PSL.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PSL.ORIG_SYS_ID = PDI.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON PDI.MATL_ID = M.MATL_ID
                AND M.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
            ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
                AND PDH.EXP_DT = PDI.EXP_DT
                AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
                AND PDH.MVMNT_TYP_CD = '101'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = PDH.POST_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_ID = PDH.MATL_DOC_ID
                AND MD.MATL_DOC_YR = PDH.MATL_DOC_YR
                AND MD.ORIG_SYS_ID = PDH.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
            ON DD.BILL_LADING_ID = MD.GOODS_RCPT_BOL_ID
                AND DD.ORIG_SYS_ID = MD.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
            ON DDI.FISCAL_YR = DD.FISCAL_YR
                AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                AND DDI.SLS_DOC_ID = PDH.PRCH_DOC_ID
                AND DDI.SLS_DOC_ITM_ID = PDH.PRCH_DOC_ITM_ID
                AND DDI.ORIG_SYS_ID = PDH.ORIG_SYS_ID

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

        AND DD.DELIV_TYP_CD <> 'EL'
        AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
        --AND M.MATL_ID = '000000000000019032'
        AND PDH.POST_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
            AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

    GROUP BY
        METRIC_TYPE
        , COMPLETE_MTH_DT

        , PDI.MATL_ID
        , MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , CATEGORY_CD
        , CATEGORY_NM
        , TIER
        , M.EXT_MATL_GRP_ID
        , M.MATL_PRTY

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD

    UNION ALL

    SELECT
        CAST('STO - Outbound Goods Issue On Time' AS VARCHAR(255)) AS METRIC_TYPE
        , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
        , SUM(DDI.ACTL_DELIV_QTY) AS STO_QTY
        , SUM(CASE 
            WHEN DD.ACTL_GOODS_MVT_DT <= DD.PLN_GOODS_MVT_DT
                THEN DDI.ACTL_DELIV_QTY 
            ELSE 0
            END) AS STO_ONTIME_QTY
        , STO_QTY - STO_ONTIME_QTY AS STO_LATE_QTY

    FROM GDYR_VWS.PRCH_DOC PD

        INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
            ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                AND PDI.EXP_DT = PD.EXP_DT
                --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

        --------------------------------------------------------------------------------------------------------------------------------------------------
        -- Joining to PSL will cause duplicates when there are multiple schedule lines.
        -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
        -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
        --------------------------------------------------------------------------------------------------------------------------------------------------  
        INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
            ON PSL.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PSL.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PSL.ORIG_SYS_ID = PDI.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON PDI.MATL_ID = M.MATL_ID
                AND M.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
            ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
                AND PDH.EXP_DT = PDI.EXP_DT
                AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
                AND PDH.MVMNT_TYP_CD = '101'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = PDH.POST_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_ID = PDH.MATL_DOC_ID
                AND MD.MATL_DOC_YR = PDH.MATL_DOC_YR
                AND MD.ORIG_SYS_ID = PDH.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
            ON DD.BILL_LADING_ID = MD.GOODS_RCPT_BOL_ID
                AND DD.ORIG_SYS_ID = MD.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
            ON DDI.FISCAL_YR = DD.FISCAL_YR
                AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                AND DDI.SLS_DOC_ID = PDH.PRCH_DOC_ID
                AND DDI.SLS_DOC_ITM_ID = PDH.PRCH_DOC_ITM_ID
                AND DDI.ORIG_SYS_ID = PDH.ORIG_SYS_ID

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

        AND DD.DELIV_TYP_CD <> 'EL'
        AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
        --AND M.MATL_ID = '000000000000019032'
        AND PDH.POST_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
            AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

    GROUP BY
        METRIC_TYPE
        , COMPLETE_MTH_DT

        , PDI.MATL_ID
        , MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , CATEGORY_CD
        , CATEGORY_NM
        , TIER
        , M.EXT_MATL_GRP_ID
        , M.MATL_PRTY

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD

    UNION ALL

    SELECT
        CAST('STO - Inbound Goods Receipt On Time' AS VARCHAR(255)) AS METRIC_TYPE
        , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
        , SUM(DDI.ACTL_DELIV_QTY) AS STO_QTY
        , SUM(CASE 
            WHEN PDH.POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY) 
                THEN DDI.ACTL_DELIV_QTY 
            ELSE 0 
            END) AS STO_ONTIME_QTY
        , STO_QTY - STO_ONTIME_QTY AS STO_LATE_QTY

    FROM GDYR_VWS.PRCH_DOC PD

        INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
            ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                AND PDI.EXP_DT = PD.EXP_DT
                --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

        --------------------------------------------------------------------------------------------------------------------------------------------------
        -- Joining to PSL will cause duplicates when there are multiple schedule lines.
        -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
        -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
        --------------------------------------------------------------------------------------------------------------------------------------------------  
        INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
            ON PSL.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PSL.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PSL.ORIG_SYS_ID = PDI.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON PDI.MATL_ID = M.MATL_ID
                AND M.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
            ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
                AND PDH.EXP_DT = PDI.EXP_DT
                AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
                AND PDH.MVMNT_TYP_CD = '101'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = PDH.POST_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_ID = PDH.MATL_DOC_ID
                AND MD.MATL_DOC_YR = PDH.MATL_DOC_YR
                AND MD.ORIG_SYS_ID = PDH.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
            ON DD.BILL_LADING_ID = MD.GOODS_RCPT_BOL_ID
                AND DD.ORIG_SYS_ID = MD.ORIG_SYS_ID

        INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
            ON DDI.FISCAL_YR = DD.FISCAL_YR
                AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                AND DDI.SLS_DOC_ID = PDH.PRCH_DOC_ID
                AND DDI.SLS_DOC_ITM_ID = PDH.PRCH_DOC_ITM_ID
                AND DDI.ORIG_SYS_ID = PDH.ORIG_SYS_ID

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

        AND DD.DELIV_TYP_CD = 'EL'
        AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
        --AND M.MATL_ID = '000000000000019032'
        AND PDH.POST_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
            AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

    GROUP BY
        METRIC_TYPE
        , COMPLETE_MTH_DT

        , PDI.MATL_ID
        , MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , CATEGORY_CD
        , CATEGORY_NM
        , TIER
        , M.EXT_MATL_GRP_ID
        , M.MATL_PRTY

        , PD.FACILITY_ID
        , PD_F.FACILITY_DESC

        , PDI.PO_UOM_CD

    UNION ALL

        SELECT
            CAST('STO - Cancels' AS VARCHAR(255)) AS METRIC_TYPE
            , CN.COMPLETE_MTH_DT
            , CN.MATL_ID
            , CN.MATL_DESCR
            , CN.PBU_NBR
            , CN.PBU_NAME
            , CN.CATEGORY_CD
            , CN.CATEGORY_NM
            , CN.TIER
            , CN.EXT_MATL_GRP_ID
            , CN.MATL_PRTY

            , CN.FACILITY_ID
            , CN.FACILITY_DESC

            , CN.QTY_UNIT_MEAS_ID
            , SUM(CASE WHEN CN.DOC_TYPE = 'OB' THEN CN.ITM_QTY ELSE 0 END) AS STO_QTY
            , STO_QTY - STO_LATE_QTY AS STO_ONTIME_QTY
            , SUM(CASE WHEN CN.DOC_TYPE = 'CN' THEN CN.ITM_QTY ELSE 0 END) AS STO_LATE_QTY

        FROM (

            SELECT
                CAST('OB' AS VARCHAR(255)) AS DOC_TYPE
                , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

                , PD.FACILITY_ID
                , PD_F.FACILITY_DESC

                , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
                , SUM(DDI.ACTL_DELIV_QTY) AS ITM_QTY

            FROM GDYR_VWS.PRCH_DOC PD

                INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
                    ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                        AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                        AND PDI.EXP_DT = PD.EXP_DT
                        --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

                --------------------------------------------------------------------------------------------------------------------------------------------------
                -- Joining to PSL will cause duplicates when there are multiple schedule lines.
                -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
                -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
                --------------------------------------------------------------------------------------------------------------------------------------------------  
                INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
                    ON PSL.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                        AND PSL.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                        AND PSL.ORIG_SYS_ID = PDI.ORIG_SYS_ID

                INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                    ON PDI.MATL_ID = M.MATL_ID
                        AND M.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN GDYR_VWS.PRCH_DOC_HIST PDH
                    ON PDH.PRCH_DOC_ID = PDI.PRCH_DOC_ID
                        AND PDH.PRCH_DOC_ITM_ID = PDI.PRCH_DOC_ITM_ID
                        AND PDH.ORIG_SYS_ID = PDI.ORIG_SYS_ID
                        AND PDH.EXP_DT = PDI.EXP_DT
                        AND PDH.PRCH_HIST_CTGY_CD = 'E' -- Goods Receipt
                        AND PDH.MVMNT_TYP_CD = '101'

                INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                    ON CAL.DAY_DATE = PDH.POST_DT

                INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
                    ON MD.MATL_DOC_ID = PDH.MATL_DOC_ID
                        AND MD.MATL_DOC_YR = PDH.MATL_DOC_YR
                        AND MD.ORIG_SYS_ID = PDH.ORIG_SYS_ID

                INNER JOIN GDYR_BI_VWS.DELIV_DOC_CURR DD
                    ON DD.BILL_LADING_ID = MD.GOODS_RCPT_BOL_ID
                        AND DD.ORIG_SYS_ID = MD.ORIG_SYS_ID

                INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
                    ON DDI.FISCAL_YR = DD.FISCAL_YR
                        AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                        AND DDI.SLS_DOC_ID = PDH.PRCH_DOC_ID
                        AND DDI.SLS_DOC_ITM_ID = PDH.PRCH_DOC_ITM_ID
                        AND DDI.ORIG_SYS_ID = PDH.ORIG_SYS_ID

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

                AND DD.DELIV_TYP_CD <> 'EL'
                AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
                --AND M.MATL_ID = '000000000000019032'
                AND PDH.POST_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
                    AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

            GROUP BY
                DOC_TYPE
                , COMPLETE_MTH_DT

                , PDI.MATL_ID
                , MATL_DESCR
                , M.PBU_NBR
                , M.PBU_NAME
                , CATEGORY_CD
                , CATEGORY_NM
                , TIER
                , M.EXT_MATL_GRP_ID
                , M.MATL_PRTY

                , PD.FACILITY_ID
                , PD_F.FACILITY_DESC

                , PDI.PO_UOM_CD

            UNION ALL

            SELECT
                CAST('CN' AS VARCHAR(255)) AS DOC_TYPE
                , CAL.MONTH_DT AS COMPLETE_MTH_DT

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

                , PD.FACILITY_ID
                , PD_F.FACILITY_DESC

                , PDI.PO_UOM_CD AS QTY_UNIT_MEAS_ID
                , SUM(CASE 
                    WHEN PDI.DEL_IND = 'L' 
                        THEN PDI.ORIG_PO_QTY 
                    ELSE PDI.ORIG_PO_QTY - PDI.PO_QTY 
                    END) AS STO_QTY

            FROM GDYR_VWS.PRCH_DOC PD

                INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
                    ON PDI.PRCH_DOC_ID = PD.PRCH_DOC_ID
                        AND PDI.ORIG_SYS_ID = PD.ORIG_SYS_ID
                        AND PDI.EXP_DT = PD.EXP_DT
                        --AND PDI.CO_CD IN ('N101', 'N102', 'N266')

                INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                    ON PDI.MATL_ID = M.MATL_ID
                        AND M.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                    ON CAL.DAY_DATE = PDI.CHANGE_DT

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

            	AND (
            		PDI.DEL_IND = 'L'  -- PO is fully cancelled
            		OR 
            		(PDI.DELIV_FULL_IND = 'Y' AND PDI.ORIG_PO_QTY > PDI.PO_QTY)  -- PO is closed and PO is partially cancelled
            	)
                AND M.PBU_NBR =  '01' --CAST(#prompt('P_PBU', 'string')# AS CHAR(2))
                --AND M.MATL_ID = '000000000000019032'
                AND PDI.CHANGE_DT BETWEEN DATE '2015-01-01'--CAST(#sq(prompt('P_BeginDate', 'DATE'))# AS DATE)
                    AND DATE '2015-01-31' -- CAST(#sq(prompt('P_EndDate', 'DATE'))# AS DATE)

            GROUP BY
                DOC_TYPE
                , COMPLETE_MTH_DT

                , PDI.MATL_ID
                , MATL_DESCR
                , M.PBU_NBR
                , M.PBU_NAME
                , CATEGORY_CD
                , CATEGORY_NM
                , TIER
                , M.EXT_MATL_GRP_ID
                , M.MATL_PRTY

                , PD.FACILITY_ID
                , PD_F.FACILITY_DESC

                , PDI.PO_UOM_CD

            ) CN

        GROUP BY
            METRIC_TYPE
            , CN.COMPLETE_MTH_DT
            , CN.MATL_ID
            , CN.MATL_DESCR
            , CN.PBU_NBR
            , CN.PBU_NAME
            , CN.CATEGORY_CD
            , CN.CATEGORY_NM
            , CN.TIER
            , CN.EXT_MATL_GRP_ID
            , CN.MATL_PRTY

            , CN.FACILITY_ID
            , CN.FACILITY_DESC

            , CN.QTY_UNIT_MEAS_ID

    ) STO

GROUP BY
    STO.METRIC_TYPE
    , STO.COMPLETE_MTH_DT

    --, STO.MATL_ID
    --, STO.MATL_DESCR
    , STO.PBU_NBR
    , STO.PBU_NAME
    --, STO.CATEGORY_CD
    --, STO.CATEGORY_NM
    --, STO.TIER
    --, STO.EXT_MATL_GRP_ID
    --, STO.MATL_PRTY

    --, STO.FACILITY_ID
    --, STO.FACILITY_DESC

    , STO.QTY_UNIT_MEAS_ID
