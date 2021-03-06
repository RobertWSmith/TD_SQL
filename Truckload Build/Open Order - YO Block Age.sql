﻿SELECT
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , OD.SCHED_LINE_NBR

    , OD.ORDER_DT
    , CAST(CURRENT_DATE - OD.ORDER_DT AS INTEGER) AS ORDER_DT_AGE_DYS
    , OD.ORDER_LN_CRT_DT
    , CAST(CURRENT_DATE - OD.ORDER_LN_CRT_DT AS INTEGER) AS ORDER_LN_DT_AGE_DYS

    , OD.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MATL_STA_ID

    , OD.FACILITY_ID
    , F.FACILITY_NAME
    , C.PRIM_SHIP_FACILITY_ID

    , OD.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , NULLIF(OD.ORDER_DELIV_BLK_CD, '') AS HDR_DELIV_BLK_CD
    , NULLIF(OD.DELIV_BLK_CD, '') AS SL_DELIV_BLK_CD

    , OD.DELIV_PRTY_ID
    , OD.DELIV_GRP_CD
    
    , OD.PLN_MATL_AVL_DT
    , OD.PLN_GOODS_ISS_DT
    , OD.PLN_DELIV_DT

    , OD.QTY_UNIT_MEAS_ID
    , (OD.ORDER_QTY) AS ORDER_QTY
    , (OD.CNFRM_QTY) AS CNFRM_QTY
    
    , (OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , (OOL.UNCNFRM_QTY) AS UNCNFRM_QTY
    , (OOL.BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , (OOL.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , (OOL.DEFER_QTY) AS DEFER_QTY
    , (OOL.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY

FROM NA_BI_VWS.ORDER_DETAIL OD

    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL
        ON OOL.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
        AND OOL.ORDER_ID = OD.ORDER_ID
        AND OOL.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = OD.SCHED_LINE_NBR
        AND (
                OOL.OPEN_CNFRM_QTY > 0
                OR OOL.UNCNFRM_QTY > 0
                OR OOL.BACK_ORDER_QTY > 0
                OR OOL.DEFER_QTY > 0
                OR OOL.WAIT_LIST_QTY > 0
            )

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OD.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

WHERE
    OD.EXP_DT = CAST('5555-12-31' AS DATE)
    AND OD.ORDER_CAT_ID = 'C'
    AND OD.RO_PO_TYPE_IND = 'N'
    AND OD.CUST_GRP2_CD = 'TLB'
    AND OD.REJ_REAS_ID = ''
    AND OD.ORDER_DELIV_BLK_CD = 'YO'

ORDER BY
    ORDER_DT_AGE_DYS DESC
    , ORDER_LN_DT_AGE_DYS DESC
    , OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , OD.SCHED_LINE_NBR
