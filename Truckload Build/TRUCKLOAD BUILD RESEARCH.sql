SELECT
    SL.CUST_GRP2_CD,
    SL.FRDD,
    SUM( SL.ORDER_QTY ) AS ORDER_QTY,
    SUM( SL.CNFRM_QTY ) AS CNFRM_QTY

FROM (

SELECT
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    ODC.SCHED_LINE_NBR,
    CASE
        WHEN OOSL.ORDER_LINE_NBR IS NULL
            THEN 'OPEN ORDER LINE'
        ELSE 'CLOSED ORDER LINE'
    END AS OPEN_ORDER_IND,
    
    ODC.SHIP_TO_CUST_ID,
    ODC.SALES_ORG_CD,
    ODC.DISTR_CHAN_CD,
    ODC.CO_CD,
    ODC.DIV_CD,
    
    ODC.MATL_ID,
    ODC.ITEM_CAT_ID,
    
    ODC.FACILITY_ID,
    ODC.SHIP_PT_ID,
    
    NULLIF( ODC.ORDER_TYPE_ID, ' ' ) AS ORDER_TYPE_ID,
    NULLIF( ODC.ORDER_CAT_ID, ' ' ) AS ORDER_CAT_ID,
    NULLIF( ODC.PO_TYPE_ID, ' ' ) AS PO_TYPE_ID,
    NULLIF( ODC.DELIV_BLK_CD, ' ' ) AS DELIV_BLK_CD,
    NULLIF( ODC.REJ_REAS_ID, ' ' ) AS REJ_REAS_ID,
    NULLIF( ODC.DELIV_PRTY_ID, ' ' ) AS DELIV_PRTY_ID,
    NULLIF( ODC.ROUTE_ID, ' ' ) AS ROUTE_ID,
    NULLIF( ODC.DELIV_GRP_CD, ' ' ) AS DELIV_GRP_CD,
    NULLIF( ODC.SPCL_PROC_ID, ' ' ) AS SPCL_PROC_ID,
    NULLIF( ODC.CUST_GRP2_CD, ' ' ) AS CUST_GRP2_CD,
    
    CASE WHEN ODC.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
    CASE WHEN ODC.RETURN_IND = 'Y' THEN 'Y' END AS RETURN_IND,
    CASE WHEN ODC.RO_PO_TYPE_IND = 'Y' THEN 'Y' END AS RO_PO_TYPE_IND,
    CASE WHEN ODC.DELIV_BLK_IND = 'Y' THEN 'Y' END AS DELIV_BLK_IND,
    
    ODC.QTY_UNIT_MEAS_ID,
    ODC.ORDER_QTY,
    ODC.CNFRM_QTY,
    OOSL.OPEN_CNFRM_QTY,
    OOSL.UNCNFRM_QTY,
    OOSL.BACK_ORDER_QTY,
    
    ODC.ORDER_DT,
    case
        WHEN COALESCE( ODC.CUST_RDD, ODC.FRST_RDD ) < ODC.ORDER_DT
            THEN ODC.ORDER_DT
        ELSE COALESCE( ODC.CUST_RDD, ODC.FRST_RDD )
    END AS ORDD,
    ODC.FRST_RDD AS FRDD,
    ODC.FRST_MATL_AVL_DT AS FRDD_FMAD,
    ODC.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI,
    CASE
        WHEN ODC.FRST_RDD < ODC.FRST_PROM_DELIV_DT
            THEN ODC.FRST_RDD
        ELSE ODC.FRST_PROM_DELIV_DT
    END AS FCDD,
    FCDD - ( FRDD - FRDD_FMAD ) AS FCDD_FMAD,
    FCDD - ( FRDD - FRDD_FPGI ) AS FCDD_FPGI,
    
    ODC.PLN_TRANSP_PLN_DT,
    ODC.PLN_MATL_AVL_DT,
    ODC.PLN_LOAD_DT,
    ODC.PLN_GOODS_ISS_DT,
    ODC.PLN_DELIV_DT
    
FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
    
    LEFT OUTER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
        ON OOSL.ORDER_ID = ODC.ORDER_ID
        AND OOSL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
        AND OOSL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
        AND ( OOSL.OPEN_CNFRM_QTY > 0 OR OOSL.UNCNFRM_QTY > 0 OR OOSL.BACK_ORDER_QTY > 0 )
    
WHERE
    ODC.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
    AND ODC.ORDER_CAT_ID = 'C'
    AND ODC.RO_PO_TYPE_IND = 'N'
    AND ODC.CUST_GRP2_CD = 'TLB'
    AND ODC.ORDER_DT >= CAST( '2013-09-01' AS DATE )
    
    ) SL
    
GROUP BY
    SL.CUST_GRP2_CD,
    SL.FRDD