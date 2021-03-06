SELECT
    CURRENT_DATE  AS SNAPSHOT_DATE,
    POL.ORDER_ID,
    POL.ORDER_LINE_NBR,
    
    POL.CMPL_DT AS FRDD_CMPL_DT,
    POL.FPDD_CMPL_DT AS FCDD_CMPL_DT,
    POL.CMPL_IND AS FRDD_CMPL_IND,
    POL.FPDD_CMPL_IND AS FCDD_CMPL_IND,
    
    POL.SHIP_TO_CUST_ID,
    POL.MATL_ID,
    POL.PBU_NBR,
    POL.SHIP_FACILITY_ID,
    NULLIF( POL.MAX_CARR_SCAC_ID, '' ) AS MAX_CARR_SCAC_ID,
    
    NULLIF( POL.CAN_REJ_REAS_ID, '' ) AS CAN_REJ_REAS_ID,
    NULLIF( POL.PO_TYPE_ID, '' ) AS PO_TYPE_ID,
    CASE WHEN POL.CREDIT_HOLD_FLG = 'Y' THEN 'Y' END AS CREDIT_HOLD_FLG,
    CASE WHEN POL.DELIV_BLK_IND = 'Y' THEN 'Y' END AS DELIV_BLK_IND,
    CASE WHEN POL.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
    POL.A_IND,
    POL.R_IND,
    NULLIF( POL.SPCL_PROC_ID, '' ) AS SPCL_PROC_ID,
    
    POL.ORDER_DT,
    POL.FMAD_DT AS FRDD_FMAD,
    POL.FPGI_DT AS FRDD_FPGI,
    POL.REQ_DELIV_DT AS FRDD,
    
    FCDD - ( FRDD - FRDD_FMAD ) AS FCDD_FMAD,
    FCDD - ( FRDD - FRDD_FPGI ) AS FCDD_FPGI,
    POL.FRST_PROM_DELIV_DT AS FCDD,
    
    POL.CUST_APPT_DT,
    POL.MAX_DELIV_NOTE_CREA_DT,
    POL.MAX_EDI_DELIV_DT,
    POL.MAX_SAP_DELIV_DT,
    POL.ACTL_DELIV_DT,
    POL.NO_STK_DT AS FRDD_NO_STOCK_DT,
    POL.FPDD_NO_STK_DT AS FCDD_NO_STOCK_DT,
    
    POL.PRFCT_ORD_HIT_DESC AS FRDD_HIT_DESC,
    POL.PRFCT_ORD_HIT_SORT_KEY AS FRDD_HIT_SORT_KEY,
    POL.PRFCT_ORD_FPDD_HIT_DESC AS FCDD_HIT_DESC,
    POL.PRFCT_ORD_FPDD_HIT_SORT_KEY AS FCDD_HIT_SORT_KEY,
    
    ZEROIFNULL( POL.ORIG_ORD_QTY ) AS ORIG_ORDER_QTY,
    ZEROIFNULL( POL.CANCEL_QTY ) AS CANCEL_QTY,
    
    ZEROIFNULL( POL.FPDD_ORD_QTY ) AS FCDD_ORDER_QTY,
    ZEROIFNULL( POL.PRFCT_ORD_FPDD_HIT_QTY ) AS FCDD_HIT_QTY,
    ZEROIFNULL( POL.FPDD_ORD_QTY ) - ZEROIFNULL( POL.PRFCT_ORD_FPDD_HIT_QTY ) AS FCDD_ONTIME_QTY,
    ZEROIFNULL( POL.DELIV_FPDD_LATE_QTY ) AS FCDD_DELIV_LATE_QTY,
    ZEROIFNULL( POL.DELIV_FPDD_ONTIME_QTY ) AS FCDD_DELIV_ONTIME_QTY,
    ZEROIFNULL( POL.FPDD_COMMIT_ONTIME_QTY ) AS FCDD_COMMIT_ONTIME_QTY,
    ZEROIFNULL( POL.REL_FPDD_LATE_QTY ) AS FCDD_REL_LATE_QTY,
    ZEROIFNULL( POL.REL_FPDD_ONTIME_QTY ) AS FCDD_REL_ONTIME_QTY,
    
    ZEROIFNULL( POL.NE_FPDD_HIT_RT_QTY ) AS FCDD_RETURN_HIT_QTY,
    ZEROIFNULL( POL.NE_FPDD_HIT_CL_QTY ) AS FCDD_CLAIM_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_FP_QTY ) AS FCDD_FREIGHT_POLICY_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_CARR_QTY ) + ZEROIFNULL( POL.OT_FPDD_HIT_WI_QTY ) AS FCDD_PHYS_LOG_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_MB_QTY ) AS FCDD_MAN_BLK_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_CH_QTY ) AS FCDD_CREDIT_HOLD_HIT_QTY,
    ZEROIFNULL( POL.IF_FPDD_HIT_NS_QTY ) AS FCDD_NO_STOCK_HIT_QTY,
    ZEROIFNULL( POL.IF_FPDD_HIT_CO_QTY ) AS FCDD_CANCEL_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_CG_QTY ) AS FCDD_CUST_GEN_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_CG_99_QTY ) AS FCDD_MAN_REL_CUST_GEN_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_99_QTY ) AS FCDD_MAN_REL_HIT_QTY,
    ZEROIFNULL( POL.OT_FPDD_HIT_LO_QTY ) AS FCDD_OTHER_HIT_QTY

FROM NA_BI_VWS.PRFCT_ORD_LINE POL

WHERE
    POL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
    /* FRDD LOGIC */
    AND POL.FPDD_CMPL_IND = 1
    AND POL.FPDD_CMPL_DT BETWEEN ( CURRENT_DATE - 8 ) AND ( CURRENT_DATE - 1 )
    AND POL.FRST_PROM_DELIV_DT IS NOT NULL
    AND POL.PRFCT_ORD_FPDD_HIT_DESC NOT IN ( 'FCDD Hit - Error' )
    
ORDER BY
    POL.ORDER_ID,
    POL.ORDER_LINE_NBR
