
SELECT
    OL.ORDER_ID,
    OL.ORDER_LINE_NBR,
    OL.DELIV_BLK_CD,
    MAX( OL.ORDER_QTY ) AS ORDER_QTY,
    SUM( OL.CNFRM_QTY ) AS CNFRM_QTY,
    SUM( OL.CNFRM_FRDD_ONTIME_QTY ) AS CNFRM_FRDD_ONTIME_QTY

FROM (

    SELECT
        OD.ORDER_ID,
        OD.ORDER_LINE_NBR,
        OD.SCHED_LINE_NBR,
        
        OD.ORDER_DT,
        OD.FRST_RDD AS FRDD,
        OD.FRST_MATL_AVL_DT AS FRDD_FMAD,
        OD.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI,
        
        CAST( FCDD - ( FRDD - FRDD_FMAD ) AS DATE ) AS FCDD_FMAD,
        CAST( FCDD - ( FRDD - FRDD_FPGI ) AS DATE ) AS FCDD_FPGI,
        CASE
            WHEN OD.FRST_PROM_DELIV_DT < OD.FRST_RDD
                THEN OD.FRST_RDD
            ELSE OD.FRST_PROM_DELIV_DT 
        END AS FCDD,
        
        OD.SHIP_TO_CUST_ID,
        OD.SALES_ORG_CD,
        OD.DISTR_CHAN_CD,
        OD.CUST_GRP_ID,
        OD.CO_CD,
        OD.DIV_CD,
        NULLIF( OD.RPT_FRT_PLCY_CD, '' ) AS CUST_GRP2_CD,
        
        OD.MATL_ID,
        NULLIF( OD.ITEM_CAT_ID, '' ) AS ITEM_CAT_ID,
        
        NULLIF( OD.FACILITY_ID, '' ) AS FACILITY_ID,
        NULLIF( OD.SHIP_PT_ID, '' ) AS SHIP_PT_ID,
        NULLIF( OD.ROUTE_ID, '' ) AS ROUTE_ID,
        
        NULLIF( OD.ORDER_CAT_ID, '' ) AS ORDER_CAT_ID,
        NULLIF( OD.ORDER_TYPE_ID, '' ) AS ORDER_TYPE_ID,
        NULLIF( OD.PO_TYPE_ID, '' ) AS PO_TYPE_ID,
        NULLIF( OD.REJ_REAS_ID, '' ) AS REJ_REAS_ID,
        NULLIF( OD.SHIP_COND_ID, '' ) AS SHIP_COND_ID,
        NULLIF( OD.DELIV_BLK_CD, '' ) AS DELIV_BLK_CD,
        NULLIF( OD.DELIV_PRTY_ID, '' ) AS DELIV_PRTY_ID,
        NULLIF( OD.DELIV_GRP_CD, '' ) AS DELIV_GRP_CD,
        NULLIF( OD.SPCL_PROC_ID, '' ) AS SPCL_PROC_ID,
        
        CASE WHEN OD.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
        CASE WHEN OD.RETURN_IND = 'Y' THEN 'Y' END AS RETURN_IND,
        CASE WHEN OD.DELIV_BLK_IND = 'Y' THEN 'Y' END AS DELIV_BLK_IND,
        
        ZEROIFNULL( OD.ORDER_QTY ) AS ORDER_QTY,
        ZEROIFNULL( OD.CNFRM_QTY ) AS CNFRM_QTY,
        CASE
            WHEN OD.PLN_DELIV_DT <= FRDD
                THEN OD.CNFRM_QTY
            ELSE 0
        END AS CNFRM_FRDD_ONTIME_QTY
    
    FROM NA_BI_VWS.ORDER_DETAIL OD
    
    WHERE
        ( OD.ORDER_ID, OD.ORDER_LINE_NBR, OD.SCHED_LINE_NBR, OD.FRST_MATL_AVL_DT ) IN (
        
            SELECT
                D.ORDER_ID,
                D.ORDER_LINE_NBR,
                D.SCHED_LINE_NBR,
                D.FRST_MATL_AVL_DT
            FROM NA_BI_VWS.ORDER_DETAIL_CURR D
            WHERE
                D.ORDER_DT >= CAST( EXTRACT( YEAR FROM CURRENT_DATE ) - 1 || '-01-01' AS DATE )
                AND D.MATL_ID IN ( SELECT MATL_ID FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR WHERE PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09') )
                AND D.ORDER_CAT_ID = 'C'
                AND D.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
                AND D.PO_TYPE_ID <> 'RO'
                
            )
        AND OD.FRST_MATL_AVL_DT BETWEEN OD.EFF_DT AND OD.EXP_DT
        /* ---------- Static Above this Point -----------*/
        
    ) OL

GROUP BY
    OL.ORDER_ID,
    OL.ORDER_LINE_NBR,
    OL.DELIV_BLK_CD
