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
    SUM( ZEROIFNULL( POL.CURR_ORD_QTY ) ) AS FRDD_ORDER_QTY,
    SUM( ZEROIFNULL( POL.PRFCT_ORD_QTY ) ) AS FRDD_ONTIME_QTY,
    SUM( ZEROIFNULL( POL.NE_HIT_RT_QTY ) ) AS FRDD_RETURN_HIT_QTY,
    SUM( ZEROIFNULL( POL.NE_HIT_CL_QTY ) ) AS FRDD_CLAIM_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_FP_QTY ) ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_CARR_PICKUP_QTY ) ) + SUM( ZEROIFNULL( POL.OT_HIT_WI_QTY ) ) AS FRDD_PHYS_LOG_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_MB_QTY ) ) AS FRDD_MAN_BLK_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_CH_QTY ) ) AS FRDD_CREDIT_HOLD_HIT_QTY,
    SUM( ZEROIFNULL( POL.IF_HIT_NS_QTY ) ) AS FRDD_NO_STOCK_HIT_QTY,
    SUM( ZEROIFNULL( POL.IF_HIT_CO_QTY ) ) AS FRDD_CANCEL_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_CG_QTY ) ) AS FRDD_CUST_GEN_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_CG_99_QTY ) ) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_99_QTY ) ) AS FRDD_MAN_REL_HIT_QTY,
    SUM( ZEROIFNULL( POL.OT_HIT_LO_QTY ) ) AS FRDD_OTHER_HIT_QTY

FROM NA_BI_VWS.PRFCT_ORD_LINE POL

WHERE
    POL.CMPL_IND = 1
    AND POL.CMPL_DT < CURRENT_DATE
    AND EXTRACT( YEAR FROM POL.CMPL_DT ) >= 2013

GROUP BY
    CMPL_MTH,
    POL.ORDER_ID,
    POL.ORDER_LINE_NBR,
    POL.MATL_ID,
    POL.SHIP_TO_CUST_ID,
    POL.SHIP_FACILITY_ID,
    POL.PBU_NBR

ORDER BY
    CMPL_MTH,
    POL.PBU_NBR