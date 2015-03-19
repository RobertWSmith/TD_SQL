SELECT
    Q.PBU_NBR,
    MATL.PBU_NAME,
    MATL.EXT_MATL_GRP_ID,
    MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA,
    --MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP,
    --MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP,
    --MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    Q.DELIV_BLK_CD,
    Q.FRDD_CMPL_MTH,
    Q.FRDD_HIT_DESC,
    --MAX( Q.UNQ_DELIV_BLK_CNT ) AS MAX_DLV_BLK_CNT,
    SUM( Q.CURR_ORD_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS ORDERED_QTY,
    SUM( Q.FRDD_ONTIME_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_ONTIME_QTY,
    SUM( Q.FRDD_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_HIT_QTY,
    SUM( Q.FRDD_RETURN_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_RETURN_HIT_QTY,
    SUM( Q.FRDD_CLAIM_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_CLAIM_HIT_QTY,
    SUM( Q.FRDD_FREIGHT_POLICY_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
    SUM( Q.FRDD_PHYS_LOG_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_PHYS_LOG_HIT_QTY,
    SUM( Q.FRDD_MAN_BLK_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_MAN_BLK_HIT_QTY,
    SUM( Q.FRDD_CREDIT_HOLD_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_CREDIT_HOLD_HIT_QTY,
    SUM( Q.FRDD_NO_STOCK_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_NO_STOCK_HIT_QTY,
    SUM( Q.FRDD_CANCEL_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_CANCEL_HIT_QTY,
    SUM( Q.FRDD_CUST_GEN_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_CUST_GEN_HIT_QTY,
    SUM( Q.FRDD_MAN_REL_CUST_GEN_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_MRCG_HIT_QTY,
    SUM( Q.FRDD_MAN_REL_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_MAN_REL_HIT_QTY,
    SUM( Q.FRDD_OTHER_HIT_QTY / NULLIFZERO( Q.UNQ_DELIV_BLK_CNT ) ) AS FRDD_OTHER_HIT_QTY,
    
    SUM( Q.FMAD_CNFRM_QTY ) AS FMAD_CNFRM_QTY,
    SUM( Q.FMAD_CNFRM_ONTIME_QTY ) AS FMAD_CNFRM_ONTIME_QTY

FROM (

    SELECT
        POL.ORDER_ID,
        POL.ORDER_LINE_NBR,
        POL.SHIP_TO_CUST_ID,
        
        POL.MATL_ID,
        POL.PBU_NBR,
        
        POL.SHIP_FACILITY_ID,
        
        L.DELIV_BLK_CD,
        POL.DELIV_PRTY_ID,
        POL.PRFCT_ORD_HIT_DESC AS FRDD_HIT_DESC,
        POL.PO_TYPE_ID,
        POL.CMPL_DT AS FRDD_CMPL_DT,
        CAL.MONTH_DT AS FRDD_CMPL_MTH,

        CAST( COUNT(*) OVER ( PARTITION BY POL.ORDER_ID, POL.ORDER_LINE_NBR ) AS FLOAT ) AS UNQ_DELIV_BLK_CNT,
        ZEROIFNULL( POL.CURR_ORD_QTY ) AS CURR_ORD_QTY,
        ZEROIFNULL( POL.CURR_ORD_QTY ) - ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_ONTIME_QTY,
        ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_HIT_QTY,
        ZEROIFNULL( POL.NE_HIT_RT_QTY ) AS FRDD_RETURN_HIT_QTY,
        ZEROIFNULL( POL.NE_HIT_CL_QTY ) AS FRDD_CLAIM_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_FP_QTY ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_CARR_PICKUP_QTY ) + ZEROIFNULL( POL.OT_HIT_WI_QTY ) AS FRDD_PHYS_LOG_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_MB_QTY ) AS FRDD_MAN_BLK_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_CH_QTY ) AS FRDD_CREDIT_HOLD_HIT_QTY,
        ZEROIFNULL( POL.IF_HIT_NS_QTY ) AS FRDD_NO_STOCK_HIT_QTY,
        ZEROIFNULL( POL.IF_HIT_CO_QTY ) AS FRDD_CANCEL_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_CG_QTY ) AS FRDD_CUST_GEN_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_CG_99_QTY ) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_99_QTY ) AS FRDD_MAN_REL_HIT_QTY,
        ZEROIFNULL( POL.OT_HIT_LO_QTY ) AS FRDD_OTHER_HIT_QTY,
        
        ZEROIFNULL( L.CNFRM_QTY ) AS FMAD_CNFRM_QTY,
        ZEROIFNULL( L.CNFRM_FRDD_ONTIME_QTY ) AS FMAD_CNFRM_ONTIME_QTY
    
    FROM NA_BI_VWS.PRFCT_ORD_LINE POL
    
        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = POL.CMPL_DT
    
        LEFT OUTER JOIN (

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


                    ) L
                ON L.ORDER_ID = POL.ORDER_ID
                AND L.ORDER_LINE_NBR = POL.ORDER_LINE_NBR
    
    WHERE
        POL.CMPL_DT BETWEEN CAST( '2013-01-01' AS DATE ) AND ( CURRENT_DATE - 1 )
        AND POL.CMPL_IND = 1
        AND POL.PRFCT_ORD_HIT_DESC NOT IN ( 'FRDD Hit - Error' )
    
    ) Q

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = Q.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON Q.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

GROUP BY
    Q.PBU_NBR,
    MATL.PBU_NAME,
    MATL.EXT_MATL_GRP_ID,
    MKT_AREA,
    --MKT_GRP,
    --PROD_GRP,
    --PROD_LINE,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    Q.DELIV_BLK_CD,
    Q.FRDD_CMPL_MTH,
    Q.FRDD_HIT_DESC