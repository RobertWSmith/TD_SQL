SELECT
    --OL.ORDER_ID,
    --OL.ORDER_LINE_NBR,
    --OL.SHIP_TO_CUST_ID,
    --OL.MATL_ID,
    PO.PBU_NBR,
    --OL.DELIV_BLK_CD,
    PO.CMPL_MTH,
    --OL.ORDER_DT,
    --OL.FRDD_FMAD,
    --OL.FRDD_FPGI,
    --OL.FRDD,
    OL.QTY_UNIT_MEAS_ID,
    
    SUM( OL.SL_ORDERED_QTY ) AS SL_ORDERED_QTY,
    SUM( OL.SL_CONFIRMED_QTY ) AS SL_CONFIRMED_QTY,
    
    SUM( OL.ANY_DELIV_BLK_CNFRM_QTY ) AS ANY_DELIV_BLK_CNFRM_QTY,
    SUM( OL.NO_DELIV_BLK_CNFRM_QTY ) AS NO_DELIV_BLK_CNFRM_QTY,
    SUM( OL.DELIV_BLK_02_CNFRM_QTY ) AS DELIV_BLK_02_CNFRM_QTY,
    SUM( OL.DELIV_BLK_09_CNFRM_QTY ) AS DELIV_BLK_09_CNFRM_QTY,
    SUM( OL.DELIV_BLK_11_CNFRM_QTY ) AS DELIV_BLK_11_CNFRM_QTY,
    SUM( OL.DELIV_BLK_15_CNFRM_QTY ) AS DELIV_BLK_15_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YF_CNFRM_QTY ) AS DELIV_BLK_YF_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YR_CNFRM_QTY ) AS DELIV_BLK_YR_CNFRM_QTY,
    SUM( OL.DELIV_BLK_YT_CNFRM_QTY ) AS DELIV_BLK_YT_CNFRM_QTY,
    
    SUM( PO.FRDD_ORDER_QTY ) AS FRDD_ORDER_QTY,
    SUM( PO.FRDD_ONTIME_QTY ) AS FRDD_ONTIME_QTY,
    SUM( PO.FRDD_RETURN_HIT_QTY ) AS FRDD_RETURN_HIT_QTY,
    SUM( PO.FRDD_CLAIM_HIT_QTY ) AS FRDD_CLAIM_HIT_QTY,
    SUM( PO.FRDD_FREIGHT_POLICY_HIT_QTY ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
    SUM( PO.FRDD_PHYS_LOG_HIT_QTY ) AS FRDD_PHYS_LOG_HIT_QTY,
    SUM( PO.FRDD_MAN_BLK_HIT_QTY ) AS FRDD_MAN_BLK_HIT_QTY,
    SUM( PO.FRDD_CREDIT_HOLD_HIT_QTY ) AS FRDD_CREDIT_HOLD_HIT_QTY,
    SUM( PO.FRDD_NO_STOCK_HIT_QTY ) AS FRDD_NO_STOCK_HIT_QTY,
    SUM( PO.FRDD_CANCEL_HIT_QTY ) AS FRDD_CANCEL_HIT_QTY,
    SUM( PO.FRDD_CUST_GEN_HIT_QTY ) AS FRDD_CUST_GEN_HIT_QTY,
    SUM( PO.FRDD_MAN_REL_CUST_GEN_HIT_QTY ) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY, 
    SUM( PO.FRDD_MAN_REL_HIT_QTY ) AS FRDD_MAN_REL_HIT_QTY,
    SUM( PO.FRDD_OTHER_HIT_QTY ) AS FRDD_OTHER_HIT_QTY,
    
    SUM( PO.FRDD_NO_STOCK_HIT_QTY ) - SUM( OL.ANY_DELIV_BLK_CNFRM_QTY ) AS ADJ_FRDD_NO_STOCK_HIT_QTY,
    SUM( PO.FRDD_FREIGHT_POLICY_HIT_QTY ) + SUM( OL.ANY_DELIV_BLK_CNFRM_QTY ) AS ADJ_FRDD_FRT_PLCY_HIT_QTY

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

    ) OL

    LEFT OUTER JOIN (

        SELECT
            CAST( SUBSTR( CAST( CASE
                WHEN POL.CMPL_DT / 100 = ( CURRENT_DATE - 1 ) / 100
                    THEN ( CURRENT_DATE - 1)
                ELSE ADD_MONTHS( POL.CMPL_DT, 1 ) - EXTRACT( DAY FROM ADD_MONTHS( POL.CMPL_DT, 1 ) ) 
            END AS CHAR(10) ), 1, 7) || '-01' AS DATE ) AS CMPL_MTH,
            POL.ORDER_ID,
            POL.ORDER_LINE_NBR,
            POL.MATL_ID,
            POL.SHIP_TO_CUST_ID,
            POL.SHIP_FACILITY_ID,
            POL.PBU_NBR,
            ( ZEROIFNULL( POL.CURR_ORD_QTY ) ) AS FRDD_ORDER_QTY,
            ( ZEROIFNULL( POL.PRFCT_ORD_QTY ) ) AS FRDD_ONTIME_QTY,
            ( ZEROIFNULL( POL.NE_HIT_RT_QTY ) ) AS FRDD_RETURN_HIT_QTY,
            ( ZEROIFNULL( POL.NE_HIT_CL_QTY ) ) AS FRDD_CLAIM_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_FP_QTY ) ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_CARR_PICKUP_QTY ) ) + ( ZEROIFNULL( POL.OT_HIT_WI_QTY ) ) AS FRDD_PHYS_LOG_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_MB_QTY ) ) AS FRDD_MAN_BLK_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_CH_QTY ) ) AS FRDD_CREDIT_HOLD_HIT_QTY,
            ( ZEROIFNULL( POL.IF_HIT_NS_QTY ) ) AS FRDD_NO_STOCK_HIT_QTY,
            ( ZEROIFNULL( POL.IF_HIT_CO_QTY ) ) AS FRDD_CANCEL_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_CG_QTY ) ) AS FRDD_CUST_GEN_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_CG_99_QTY ) ) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_99_QTY ) ) AS FRDD_MAN_REL_HIT_QTY,
            ( ZEROIFNULL( POL.OT_HIT_LO_QTY ) ) AS FRDD_OTHER_HIT_QTY
        
        FROM NA_BI_VWS.PRFCT_ORD_LINE POL
        
        WHERE
            POL.CMPL_IND = 1
            AND POL.CMPL_DT < CURRENT_DATE
            AND EXTRACT( YEAR FROM POL.CMPL_DT ) >= 2013
    
        ) PO
    ON PO.ORDER_ID = OL.ORDER_ID
    AND PO.ORDER_LINE_NBR = OL.ORDER_LINE_NBR
    
GROUP BY
    PO.PBU_NBR,
    PO.CMPL_MTH,
    OL.QTY_UNIT_MEAS_ID