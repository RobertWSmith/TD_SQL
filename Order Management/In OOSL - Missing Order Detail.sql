﻿SELECT
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , COALESCE(OD.SCHED_LINE_NBR, OOL.SCHED_LINE_NBR) AS SCHED_LINE_NBR

    , CASE
        WHEN OD.SCHED_LINE_NBR IS NOT NULL
            THEN 'In Order Detail'
        END AS TEST_ORDER_DETAIL
    , CASE
        WHEN OOL.SCHED_LINE_NBR IS NOT NULL
            THEN 'In Open Order Sched Line'
        END AS TEST_OPEN_ORDER_SCHDLN

    , OOL.ORDER_CAT_ID
    , OOL.ORDER_TYPE_ID

    , OOL.CUST_ID AS SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , OOL.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME

    , OOL.FACILITY_ID
    , F.FACILITY_NAME

    , OOL.RPT_QTY_UNIT_MEAS_ID AS QTY_UNIT_MEAS_ID
    , (OD.ORDER_QTY) AS ORDER_QTY
    , (OD.CNFRM_QTY) AS CNFRM_QTY
    , (OOL.RPT_OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , (OOL.RPT_UNCNFRM_QTY) AS UNCNFRM_QTY
    , (OOL.RPT_BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , (OOL.RPT_DEFER_QTY) AS DEFER_QTY
    , (OOL.RPT_WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , (OOL.RPT_OTHR_ORDER_QTY) AS OTHR_ORDER_QTY
    , (OOL.RPT_IN_PROC_QTY) AS IN_PROC_QTY

FROM NA_VWS.OPEN_ORDER_SCHDLN OOL

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M    
        ON M.MATL_ID = OOL.MATL_ID
        AND M.EXT_MATL_GRP_ID = 'TIRE'
        AND M.PBU_NBR = '01'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OOL.CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OOL.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    LEFT OUTER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OOL.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
        AND OOL.ORDER_ID = OD.ORDER_ID
        AND OOL.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = OD.SCHED_LINE_NBR
        AND OD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.PO_TYPE_ID <> 'RO'

WHERE
    OOL.EXP_DT = CAST('5555-12-31' AS DATE)
    AND OD.SCHED_LINE_NBR IS NULL

ORDER BY
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , COALESCE(OD.SCHED_LINE_NBR, OOL.SCHED_LINE_NBR)