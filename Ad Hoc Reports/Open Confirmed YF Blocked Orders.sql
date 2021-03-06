﻿SELECT
    OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR
    , OOL.SCHED_LINE_NBR
    
    , ODC.CUST_GRP2_CD
    , ODC.SHIP_TO_CUST_ID
    , CUST.SHIP_TO_CUST_ID || ' - ' || CUST.CUST_NAME AS SHIP_TO_CUST
    , CUST.OWN_CUST_ID 
    , CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS OWN_CUST
    
    , ODC.FACILITY_ID
    , FAC.FACILITY_ID || ' - ' || FAC.FACILITY_NAME AS FACILITY
    
    , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU
    
    , ODC.PLN_MATL_AVL_DT
    , ODC.PLN_GOODS_ISS_DT
    , CAL.MONTH_DT AS PLN_GOODS_ISS_MTH
    
    , OOL.CREDIT_HOLD_FLG
    , ODC.DELIV_BLK_CD
    , OOL.OPEN_CNFRM_QTY 
    , CAST(OOL.OPEN_CNFRM_QTY * MATL.UNIT_WT AS DECIMAL(15,3)) AS OPEN_CNFRM_GROSS_WT
    
FROM (
    SELECT
        ORDER_FISCAL_YR
        , ORDER_ID
        , ORDER_LINE_NBR
        , SCHED_LINE_NBR
        , OPEN_CNFRM_QTY
        , CREDIT_HOLD_FLG

    FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR

    WHERE
        OPEN_CNFRM_QTY > 0
    ) OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL ODC
        ON ODC.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND ODC.ORDER_ID = OOL.ORDER_ID
        AND ODC.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND ODC.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND ODC.EXP_DT = DATE '5555-12-31'
        AND ODC.ORDER_CAT_ID = 'C'
        AND ODC.PO_TYPE_ID <> 'RO'
        AND ODC.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
        AND ODC.REJ_REAS_ID = ''
        AND ODC.DELIV_BLK_CD IN ('YF', 'YR', 'YT')
        AND ODC.PLN_GOODS_ISS_DT <= (CURRENT_DATE+28)
    
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
    
    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = ODC.FACILITY_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = ODC.PLN_GOODS_ISS_DT

ORDER BY
    OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR
    , OOL.SCHED_LINE_NBR
