﻿SELECT
    OTD.METRIC_TYPE
    , OTD.METRIC_FMAD_MTH_DT AS FCDD_FMAD_MTH_DT
    , OTD.MATL_ID
    , OTD.MATL_DESCR

    , OTD.PBU_NBR
    , OTD.PBU_NAME
    , OTD.CATEGORY_CD
    , OTD.CATEGORY_NM

    , OTD.TIER
    , OTD.EXT_MATL_GRP_ID
    , OTD.MATL_PRTY
    , OTD.STK_CLASS_ID

    , OTD.SRC_FACILITY_ID
    , OTD.SRC_FACILITY_NAME
    , OTD.SHIP_FACILITY_ID
    , OTD.SHIP_FACILITY_NAME

    , OTD.QTY_UNIT_MEAS_ID

    , SUM(OTD.ORDER_QTY) AS ORDER_QTY
    , SUM(OTD.HIT_QTY) AS HIT_QTY
    , SUM(OTD.ONTIME_QTY) AS ONTIME_QTY

    , SUM(OTD.RETURN_HIT_QTY) AS RETURN_HIT_QTY
    , SUM(OTD.CLAIM_HIT_QTY) AS CLAIM_HIT_QTY
    , SUM(OTD.FREIGHT_POLICY_HIT_QTY) AS FREIGHT_POLICY_HIT_QTY
    , SUM(OTD.PHYS_LOG_HIT_QTY) AS PHYS_LOG_HIT_QTY
    , SUM(OTD.MAN_BLK_HIT_QTY) AS MAN_BLK_HIT_QTY
    , SUM(OTD.CREDIT_HOLD_HIT_QTY) AS CREDIT_HOLD_HIT_QTY
    , SUM(OTD.NO_STOCK_HIT_QTY) AS NO_STOCK_HIT_QTY
    , SUM(OTD.CANCEL_HIT_QTY) AS CANCEL_HIT_QTY
    , SUM(OTD.CUST_GEN_HIT_QTY) AS CUST_GEN_HIT_QTY
    , SUM(OTD.MAN_REL_CUST_GEN_HIT_QTY) AS MAN_REL_CUST_GEN_HIT_QTY
    , SUM(OTD.MAN_REL_HIT_QTY) AS MAN_REL_HIT_QTY
    , SUM(OTD.OTHER_HIT_QTY) AS OTHER_HIT_QTY

FROM (

SELECT
    CAST('On Time Delivery - FCDD' AS VARCHAR(255)) AS METRIC_TYPE
    , ODS.ORDER_FISCAL_YR
    , POL.ORDER_ID
    , POL.ORDER_LINE_NBR

    , POL.FPDD_CMPL_IND AS COMPLETE_IND
    , POL.FPDD_CMPL_DT AS COMPLETE_DT
    --, COMPLETE_DT - (EXTRACT(DAY FROM COMPLETE_DT) - 1) AS COMPLETE_MTH_DT
    , POL.FPDD_NO_STK_DT AS NO_STOCK_DATE
    --, NO_STOCK_DATE - (EXTRACT(DAY FROM NO_STOCK_DATE) - 1) AS NO_STOCK_MONTH_DT

    , POL.MATL_ID
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , CASE
        WHEN MATL.PBU_NBR = '01'
            THEN MATL.MKT_CTGY_MKT_AREA_NBR
        ELSE MATL.MKT_CTGY_MKT_GRP_NBR
        END AS CATEGORY_CD
    , CASE
        WHEN MATL.PBU_NBR = '01'
            THEN MATL.MKT_CTGY_MKT_AREA_NAME
        ELSE MATL.MKT_CTGY_MKT_GRP_NAME
        END AS CATEGORY_NM
    , CASE
        WHEN MATL.PBU_NBR = '01'
            THEN MATL.MKT_CTGY_PROD_GRP_NAME
        ELSE MATL.TIERS
        END AS TIER
    , MATL.EXT_MATL_GRP_ID
    , MATL.MATL_PRTY
    , MATL.STK_CLASS_ID

    , CUST.SALES_ORG_CD
    , CUST.SALES_ORG_NAME
    , CUST.DISTR_CHAN_CD
    , CUST.DISTR_CHAN_NAME
    , CUST.CUST_GRP_ID
    , CUST.CUST_GRP_NAME
    , POL.SHIP_TO_CUST_ID
    , CUST.CUST_NAME AS SHIP_TO_CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , CUST.SALES_ORG_GRP_DESC

    , MATL.PRTY_SRC_FACL_ID AS SRC_FACILITY_ID
    , MATL.PRTY_SRC_FACL_NM AS SRC_FACILITY_NAME
    , POL.SHIP_FACILITY_ID
    , FAC.FACILITY_NAME AS SHIP_FACILITY_NAME

    , POL.DELIV_PRTY_ID
    , POL.DELIV_BLK_IND
    , POL.CREDIT_HOLD_FLG
    , POL.NUM_DELIV_LINES
    , POL.CAN_REJ_REAS_ID
    , POL.PO_TYPE_ID
    , POL.CANCEL_IND
    , POL.CUST_GRP2_CD
    , POL.SHIP_COND_ID
    , POL.TMS_CD
    , POL.SPCL_PROC_ID
    , POL.MAX_CARR_SCAC_ID

    , POL.ORDER_DT
    , POL.OL_DT
    , ODS.FC_MATL_AVL_DT AS METRIC_FMAD
    , CAL.MONTH_DT AS METRIC_FMAD_MTH_DT
    , POL.FCPGI_DT AS METRIC_FPGI
    , POL.FRST_PROM_DELIV_DT AS METRIC_DT

    , POL.REQ_DELIV_DT AS FRDD
    , POL.FRST_PROM_DELIV_DT AS FCDD
    , POL.MAX_DELIV_NOTE_CREA_DT
    , POL.MAX_EDI_DELIV_DT
    , POL.MAX_SAP_DELIV_DT
    , POL.ACTL_DELIV_DT
    , POL.CUST_APPT_DT

    , ODS.QTY_UNIT_MEAS_ID
    , ZEROIFNULL(POL.ORIG_ORD_QTY) AS ORIG_ORDER_QTY
    , ZEROIFNULL(POL.CANCEL_QTY) AS CANCEL_QTY
    , ZEROIFNULL(POL.FPDD_ORD_QTY) AS ORDER_QTY
    , ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY) AS HIT_QTY
    , ZEROIFNULL(POL.FPDD_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY) AS ONTIME_QTY
    , ZEROIFNULL(POL.DELIV_FPDD_LATE_QTY) AS DELIV_LATE_QTY
    , ZEROIFNULL(POL.DELIV_FPDD_ONTIME_QTY) AS DELIV_ONTIME_QTY
    , ZEROIFNULL(POL.FPDD_COMMIT_ONTIME_QTY) AS COMMIT_ONTIME_QTY
    , ZEROIFNULL(POL.REL_FPDD_LATE_QTY) AS REL_LATE_QTY
    , ZEROIFNULL(POL.REL_FPDD_ONTIME_QTY) AS REL_ONTIME_QTY
    , ZEROIFNULL(POL.NE_FPDD_HIT_RT_QTY) AS RETURN_HIT_QTY
    , ZEROIFNULL(POL.NE_FPDD_HIT_CL_QTY) AS CLAIM_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_FP_QTY) AS FREIGHT_POLICY_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_CARR_QTY) + ZEROIFNULL(POL.OT_FPDD_HIT_WI_QTY) AS PHYS_LOG_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_MB_QTY) AS MAN_BLK_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_CH_QTY) AS CREDIT_HOLD_HIT_QTY
    , ZEROIFNULL(POL.IF_FPDD_HIT_NS_QTY) AS NO_STOCK_HIT_QTY
    , ZEROIFNULL(POL.IF_FPDD_HIT_CO_QTY) AS CANCEL_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_CG_QTY) AS CUST_GEN_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_CG_99_QTY) AS MAN_REL_CUST_GEN_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_99_QTY) AS MAN_REL_HIT_QTY
    , ZEROIFNULL(POL.OT_FPDD_HIT_LO_QTY) AS OTHER_HIT_QTY

FROM NA_BI_VWS.PRFCT_ORD_LINE POL

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = POL.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = POL.SHIP_FACILITY_ID
        AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND FAC.DISTR_CHAN_CD = '81'

    INNER JOIN NA_BI_VWS.ORDER_DETAIL ODS
        ON ODS.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE - 1)) - 2 AS CHAR(4))
        AND ODS.ORDER_ID = POL.ORDER_ID
        AND ODS.ORDER_LINE_NBR = POL.ORDER_LINE_NBR
        AND ODS.SCHED_LINE_NBR = 1
        AND ODS.EXP_DT = DATE '5555-12-31'
        AND ODS.ORDER_CAT_ID = 'C'
        AND ODS.PO_TYPE_ID <> 'RO'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = ODS.FC_MATL_AVL_DT

WHERE
    POL.FPDD_CMPL_IND = 1
    AND POL.FRST_PROM_DELIV_DT IS NOT NULL
    AND POL.FRST_PROM_DELIV_DT <= POL.REQ_DELIV_DT + CAST(14 AS INTERVAL DAY)
    --AND POL.FPDD_CMPL_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE) AND CURRENT_DATE-1
    AND POL.PRFCT_ORD_FPDD_HIT_SORT_KEY <> 99

    AND MATL.STK_CLASS_ID = '0'
    AND MATL.PBU_NBR = '01' -- IN (#promptmany('P_PBU', 'text')#)
    AND MATL.EXT_MATL_GRP_ID = 'TIRE' -- CAST(#prompt('P_ExtMatlGrpID', 'text', '''TIRE''')# AS CHAR(4))
    AND POL.FPDD_CMPL_DT BETWEEN DATE '2014-01-01' AND CURRENT_DATE-1
    --BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
        --AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

    ) OTD

GROUP BY
    OTD.METRIC_TYPE
    , FCDD_FMAD_MTH_DT
    , OTD.MATL_ID
    , OTD.MATL_DESCR
    , OTD.PBU_NBR
    , OTD.PBU_NAME
    , OTD.CATEGORY_CD
    , OTD.CATEGORY_NM
    , OTD.TIER
    , OTD.EXT_MATL_GRP_ID
    , OTD.MATL_PRTY
    , OTD.STK_CLASS_ID
    , OTD.SRC_FACILITY_ID
    , OTD.SRC_FACILITY_NAME
    , OTD.SHIP_FACILITY_ID
    , OTD.SHIP_FACILITY_NAME

    , OTD.QTY_UNIT_MEAS_ID