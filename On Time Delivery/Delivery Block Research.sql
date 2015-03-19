SELECT
    OL.CMPL_MTH,
    OL.QTY_UNIT_MEAS_ID,
    OL.PBU_NBR,
    OL.PBU_NAME,
    OL.FRDD_HIT_DESC,
    SUM( OL.SL_ORDERED_QTY ) AS TOT_ORDERED_QTY,
    SUM( OL.SL_CONFIRMED_QTY ) AS TOT_CONFIRMED_QTY,
    SUM( OL.ANY_DELIV_BLK_CNFRM_QTY ) AS ANY_DELIV_BLK_CNFRM_QTY,
    SUM( OL.NO_DELIV_BLK_CNFRM_QTY ) AS NO_DELIV_BLK_CNFRM_QTY,
    SUM( OL.DELIV_BLK_02_CNFRM_QTY ) AS DELIV_BLK_02_CNFRM_QTY,
    SUM( OL.DELIV_BLK_09_CNFRM_QTY ) AS DELIV_BLK_09_CNFRM_QTY,
    SUM( OL.DELIV_BLK_11_CNFRM_QTY ) AS DELIV_BLK_11_CNFRM_QTY,
    SUM( OL.DELIV_BLK_15_CNFRM_QTY ) AS DELIV_BLK_15_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YF_CNFRM_QTY ) AS DELIV_BLK_YF_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YR_CNFRM_QTY ) AS DELIV_BLK_YR_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YT_CNFRM_QTY ) AS DELIV_BLK_YT_CNFRM_QTY,
    SUM( OL.FRDD_ORDER_QTY ) AS FRDD_ORDER_QTY,
    SUM( OL.FRDD_NO_STOCK_HIT_QTY ) AS FRDD_NO_STOCK_HIT_QTY,
    SUM( OL.FRDD_ADJ_NO_STOCK_HIT_QTY ) AS FRDD_ADJ_NO_STOCK_HIT_QTY,
    SUM( OL.FRDD_HIT_QTY ) AS FRDD_HIT_QTY,
    SUM( OL.FRDD_ONTIME_QTY ) AS FRDD_ONTIME_QTY

FROM (
    
    SELECT
        O.ORDER_ID,
        O.ORDER_LINE_NBR,
        O.SHIP_TO_CUST_ID,
        CUST.CUST_NAME AS SHIP_TO_CUST_NAME,
        CUST.OWN_CUST_ID,
        CUST.OWN_CUST_NAME,
        O.MATL_ID,
        MATL.DESCR,
        MATL.PBU_NBR,
        MATL.PBU_NAME,
        O.DELIV_BLK_CD,
        POL.CMPL_DT,
        CAST( SUBSTR( CAST( POL.CMPL_DT AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AS CMPL_MTH,
        O.ORDER_DT,
        O.FRDD_FMAD,
        O.FRDD_FPGI,
        O.FRDD,
        O.QTY_UNIT_MEAS_ID,
        O.SL_ORDERED_QTY,
        O.SL_CONFIRMED_QTY,
        O.SL_UNCONFIRMED_QTY,
        O.ANY_DELIV_BLK_CNFRM_QTY,
        O.NO_DELIV_BLK_CNFRM_QTY,
        O.DELIV_BLK_02_CNFRM_QTY,
        O.DELIV_BLK_09_CNFRM_QTY,
        O.DELIV_BLK_11_CNFRM_QTY,
        O.DELIV_BLK_15_CNFRM_QTY,
        O.DELIV_BLK_YF_CNFRM_QTY,
        O.DELIV_BLK_YR_CNFRM_QTY,
        O.DELIV_BLK_YT_CNFRM_QTY,
        
        ZEROIFNULL( POL.CURR_ORD_QTY ) AS FRDD_ORDER_QTY,
        ZEROIFNULL( POL.IF_HIT_NS_QTY ) AS FRDD_NO_STOCK_HIT_QTY,
        FRDD_NO_STOCK_HIT_QTY - O.ANY_DELIV_BLK_CNFRM_QTY AS FRDD_ADJ_NO_STOCK_HIT_QTY,
        ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_HIT_QTY,
        ZEROIFNULL( POL.CURR_ORD_QTY ) - ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_ONTIME_QTY,
        POL.PRFCT_ORD_HIT_DESC AS FRDD_HIT_DESC
    
    FROM (
        
        SELECT
            OD.ORDER_ID,
            OD.ORDER_LINE_NBR,
            OD.SHIP_TO_CUST_ID,
            OD.MATL_ID,
            NULLIF( OD.DELIV_BLK_CD, '' ) AS DELIV_BLK_CD,
            OD.ORDER_DT,
            OD.FRST_MATL_AVL_DT AS FRDD_FMAD,
            OD.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI,
            OD.FRST_RDD AS FRDD,
            OD.QTY_UNIT_MEAS_ID,
            SUM( OD.ORDER_QTY ) AS SL_ORDERED_QTY,
            SUM( OD.CNFRM_QTY ) AS SL_CONFIRMED_QTY,
            SL_ORDERED_QTY - SL_CONFIRMED_QTY AS SL_UNCONFIRMED_QTY,
            
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) IS NOT NULL
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS ANY_DELIV_BLK_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) IS NULL
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS NO_DELIV_BLK_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) = '02'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_02_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) = '09'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_09_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) = '11'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_11_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) = '15'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_15_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) = 'YF'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_YF_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) ='YR'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_YR_CNFRM_QTY,
            SUM( CASE
                WHEN NULLIF( OD.DELIV_BLK_CD, '' ) ='YT'
                    THEN OD.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_YT_CNFRM_QTY
        
        FROM NA_BI_VWS.ORDER_DETAIL OD
        
        WHERE
            OD.FRST_RDD BETWEEN OD.EFF_DT AND OD.EXP_DT
            AND OD.ORDER_CAT_ID = 'C'
            AND OD.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' ) 
            AND OD.PO_TYPE_ID <> 'RO'
            AND OD.CUST_GRP_ID <> '3R'
            AND ( OD.ORDER_ID, OD.ORDER_LINE_NBR ) IN ( 
                SELECT
                    P.ORDER_ID,
                    P.ORDER_LINE_NBR
                FROM NA_BI_VWS.PRFCT_ORD_LINE P
                WHERE
                    P.CMPL_IND = 1
                    AND P.CMPL_DT BETWEEN CAST( '2013-01-01' AS DATE ) AND ( CURRENT_DATE - 1 )
                    AND P.PRFCT_ORD_HIT_DESC = 'FRDD Hit - No Stock'
            )
        
        GROUP BY
            OD.ORDER_ID,
            OD.ORDER_LINE_NBR,
            OD.SHIP_TO_CUST_ID,
            OD.MATL_ID,
            DELIV_BLK_CD,
            OD.ORDER_DT,
            FRDD_FMAD,
            FRDD_FPGI,
            FRDD,
            OD.QTY_UNIT_MEAS_ID
    
        ) O
        
        LEFT OUTER JOIN NA_BI_VWS.PRFCT_ORD_LINE POL
            ON POL.ORDER_ID = O.ORDER_ID
            AND POL.ORDER_LINE_NBR = O.ORDER_LINE_NBR
            AND POL.CMPL_IND = 1
            AND POL.CMPL_DT BETWEEN CAST( '2013-01-01' AS DATE ) AND ( CURRENT_DATE - 1 )
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = O.MATL_ID

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = O.SHIP_TO_CUST_ID
    
    ) OL

GROUP BY
    OL.CMPL_MTH,
    OL.QTY_UNIT_MEAS_ID,
    OL.PBU_NBR,
    OL.PBU_NAME,
    OL.FRDD_HIT_DESC