﻿SELECT
    ODC.ORDER_FISCAL_YR
    , ODC.ORDER_ID
    , ODC.ORDER_LINE_NBR
    , ODC.SCHED_LINE_NBR
    
    , ODC.ORDER_CAT_ID
    , ODC.ORDER_TYPE_ID
    , ODC.ORDER_REAS_CD
    , ODC.PO_TYPE_ID
    , ODC.ITEM_CAT_ID
    , ODC.SCHD_LN_CTGY_CD
    
    , ODC.SHIP_TO_CUST_ID
    , CUST.CUST_NAME AS SHIP_TO_CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , CUST.SALES_ORG_CD
    , CUST.SALES_ORG_NAME
    , CUST.DISTR_CHAN_CD
    , CUST.DISTR_CHAN_NAME
    , CUST.CUST_GRP_ID
    , CUST.CUST_GRP_NAME
    , CUST.PRIM_SHIP_FACILITY_ID
    
    , ODC.MATL_ID
    , MATL.DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , ODC.BATCH_NBR
    
    , ODC.FACILITY_ID
    , ODC.SHIP_PT_ID
    , CASE
        WHEN ODC.FACILITY_ID = CUST.PRIM_SHIP_FACILITY_ID
            THEN 'Y'
        ELSE 'N'
    END AS PRIM_SHIP_FACILITY_IND
    , CASE
        WHEN ODC.FACILITY_ID <> CUST.PRIM_SHIP_FACILITY_ID
            THEN (CASE
                WHEN ODC.FACILITY_ID IN ('N5US', 'N5CA')
                    THEN 'Unplanned Large Order'
                WHEN ODC.FACILITY_ID LIKE 'N5%'
                    THEN 'Direct from Factory'
                ELSE 'Out of Area'
            END)
        ELSE 'Standard LC'
    END AS PRIM_SHIP_FACILITY_DESC
    
    , ODC.RETURN_IND
    , ODC.CANCEL_IND
    , ODC.DELIV_BLK_IND
    
    , ODC.DELIV_BLK_CD
    , ODC.CANCEL_DT
    , ODC.REJ_REAS_ID
    , ODC.REJ_REAS_DESC
    , ODC.ORDER_CREATOR
    , ODC.SHIP_COND_ID
    , CASE
        WHEN ODC.SHIP_COND_ID IN ('ST', 'PT')
            THEN 'Y'
        ELSE 'N'
    END AS FTL_SHIP_COND_IND
    , ODC.DELIV_PRTY_ID
    , ODC.ROUTE_ID
    , ODC.DELIV_GRP_CD
    , ODC.SPCL_PROC_ID
    , ODC.CUST_GRP2_CD
    
    , ODC.ORDER_DT
    , CAST(SD.SRC_CRT_DT AS TIMESTAMP(0)) + (SD.SRC_CRT_TM - TIME '00:00:00' HOUR TO SECOND) AS HEADER_CRT_TS
    , SDI.SRC_CRT_TS AS ITEM_CRT_TS
    , (HEADER_CRT_TS - ITEM_CRT_TS) DAY(4) TO MINUTE AS HDR_TO_ITM_CRT_DIFF
    , CASE
        WHEN (HEADER_CRT_TS - ITEM_CRT_TS) DAY(4) TO MINUTE > INTERVAL '5' MINUTE
            THEN CAST(SDI.SRC_CRT_TS AS DATE)
    END AS SPLIT_LINE_DT
    , SL.SCHD_LN_DELIV_DT AS FIRST_DATE
    , ODC.CUST_RDD AS ORDD
    , ODC.FRST_MATL_AVL_DT AS FRDD_FMAD
    , ODC.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI
    , ODC.FRST_RDD AS FRDD
    , ODC.FC_MATL_AVL_DT AS FCDD_FMAD
    , ODC.FC_PLN_GOODS_ISS_DT AS FCDD_FPGI
    , ODC.FRST_PROM_DELIV_DT AS FCDD
    
    , ODC.QTY_UNIT_MEAS_ID AS QTY_UOM
    , ODC.ORDER_QTY
    , ODC.CNFRM_QTY
    
    , ODC.SLS_QTY_UNIT_MEAS_ID AS SLS_QTY_UOM
    , ODC.SLS_ORDER_QTY
    
    , ODC.RPT_QTY_UNIT_MEAS_ID AS RPT_QTY_UOM
    , ODC.RPT_ORDER_QTY
    , ODC.RPT_CNFRM_QTY
    
    , ODC.WT_UNITS_MEAS_ID AS WT_UOM
    , ODC.GROSS_WT
    , ODC.NET_WT
    
    , ODC.VOL_UNIT_MEAS_ID AS VOL_UOM
    , ODC.VOL

FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON SD.FISCAL_YR = ODC.ORDER_FISCAL_YR
        AND SD.SLS_DOC_ID = ODC.ORDER_ID
        AND SD.EXP_DT = DATE '5555-12-31'

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM SDI
        ON SDI.FISCAL_YR = ODC.ORDER_FISCAL_YR
        AND SDI.SLS_DOC_ID = ODC.ORDER_ID
        AND SDI.SLS_DOC_ITM_ID = ODC.ORDER_LINE_NBR
        AND SDI.EXP_DT = DATE '5555-12-31'

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC_SCHD_LN SL
        ON SL.FISCAL_YR = ODC.ORDER_FISCAL_YR
        AND SL.SLS_DOC_ID = ODC.ORDER_ID
        AND SL.SLS_DOC_ITM_ID = ODC.ORDER_LINE_NBR
        AND SL.SCHD_LN_ID = 1
        AND SL.EXP_DT = DATE '5555-12-31'

WHERE
    ODC.ORDER_FISCAL_YR > '2012'
    AND ODC.ORDER_CAT_ID = 'C'
    AND ODC.ORDER_TYPE_ID <> 'ZLZ'
    AND ODC.PO_TYPE_ID <> 'RO'
    AND ODC.CUST_GRP2_CD = 'TLB'

ORDER BY
    ODC.ORDER_FISCAL_YR
    , ODC.ORDER_ID
    , ODC.ORDER_LINE_NBR
    , ODC.SCHED_LINE_NBR

