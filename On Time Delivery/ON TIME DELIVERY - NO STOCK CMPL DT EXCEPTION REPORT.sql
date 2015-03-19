SELECT
    CAST( SUBSTR( CAST( OTD.FRDD_CMPL_DT AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AS FRDD_CMPL_MTH,
    CAST( SUBSTR( CAST( ( OTD.FRDD + 1 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AS EXP_FRDD_CMPL_MTH,
    CAST( CASE
        WHEN FRDD_CMPL_MTH > EXP_FRDD_CMPL_MTH
            THEN 'Metric > Expected'
        WHEN FRDD_CMPL_MTH = EXP_FRDD_CMPL_MTH
            THEN 'Same'
        WHEN FRDD_CMPL_MTH < EXP_FRDD_CMPL_MTH
            THEN 'Metric < Expected'
    END AS VARCHAR(30) ) FRDD_CMPL_MTH_TEST,
    OTD.OWN_CUST_ID,
    OTD.OWN_CUST_NAME,
    OTD.MATL_ID,
    OTD.PBU,
    OTD.SHIP_FACILITY_ID,
    OTD.SHIP_FACILITY_NAME,

    SUM( ZEROIFNULL( OTD.FRDD_ORDER_QTY ) ) AS FRDD_ORDER_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_HIT_QTY ) ) AS FRDD_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_ONTIME_QTY ) ) AS FRDD_ONTIME_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_REL_LATE_QTY ) ) AS FRDD_REL_LATE_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_REL_ONTIME_QTY ) ) AS FRDD_REL_ONTIME_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_COMMIT_ONTIME_QTY ) ) AS FRDD_COMMIT_ONTIME_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_DELIV_LATE_QTY ) ) AS FRDD_DELIV_LATE_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_DELIV_ONTIME_QTY ) ) AS FRDD_DELIV_ONTIME_QTY,
    
    SUM( ZEROIFNULL( OTD.FRDD_RETURN_HIT_QTY ) ) AS FRDD_RETURN_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_CLAIM_HIT_QTY ) ) AS FRDD_CLAIM_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_FREIGHT_POLICY_HIT_QTY ) ) AS FRDD_FREIGHT_POLICY_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_PHYS_LOG_HIT_QTY ) ) AS FRDD_PHYS_LOG_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_MAN_BLK_HIT_QTY ) ) AS FRDD_MAN_BLK_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_CREDIT_HOLD_HIT_QTY ) ) AS FRDD_CREDIT_HOLD_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_NO_STOCK_HIT_QTY ) ) AS FRDD_NO_STOCK_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_CANCEL_HIT_QTY ) ) AS FRDD_CANCEL_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_CUST_GEN_HIT_QTY ) ) AS FRDD_CUST_GEN_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_MAN_REL_CUST_GEN_HIT_QTY ) ) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_MAN_REL_HIT_QTY ) ) AS FRDD_MAN_REL_HIT_QTY,
    SUM( ZEROIFNULL( OTD.FRDD_OTHER_HIT_QTY ) ) AS FRDD_OTHER_HIT_QTY

FROM (
    
    SELECT
        POL.ORDER_ID,
        POL.ORDER_LINE_NBR,
        
        CAST( CASE
            WHEN POL.CMPL_DT < CURRENT_DATE AND POL.CMPL_IND = 1
                THEN 'Y'
            ELSE 'N'
        END AS CHAR(1) ) AS FRDD_METRIC_INCLUDE_IND,
        CAST( CASE
            WHEN POL.CMPL_DT < CURRENT_DATE AND POL.CMPL_IND = 1
                THEN 'FRDD Included'
            ELSE 'FRDD Excluded'
        END AS VARCHAR(15) ) AS FRDD_METRIC_INCLUDE_DESC,
        CAST( CASE
            WHEN POL.FPDD_CMPL_DT < CURRENT_DATE AND POL.FPDD_CMPL_IND = 1 AND POL.FRST_PROM_DELIV_DT IS NOT NULL
                THEN 'Y'
            ELSE 'N'
        END AS CHAR(1) ) AS FCDD_METRIC_INCLUDE_IND,
        CAST( CASE
            WHEN POL.FPDD_CMPL_DT < CURRENT_DATE AND POL.FPDD_CMPL_IND = 1 AND POL.FRST_PROM_DELIV_DT IS NOT NULL
                THEN 'FCDD Included'
            ELSE 'FCDD Excluded'
        END AS VARCHAR(15) ) AS FCDD_METRIC_INCLUDE_DESC,
        
        POL.CMPL_DT AS FRDD_CMPL_DT,
        POL.FPDD_CMPL_DT AS FCDD_CMPL_DT,
        POL.CMPL_IND AS FRDD_CMPL_IND,
        POL.FPDD_CMPL_IND AS FCDD_CMPL_IND,
        
        CAST( POL.NO_STK_DT AS DATE ) AS FRDD_NO_STOCK_DT,
        CAST( POL.FPDD_NO_STK_DT AS DATE ) AS FCDD_NO_STOCK_DT,
        
        CAST( FRDD_CMPL_DT - CAST( ( FRDD + 1 ) AS DATE ) AS INTEGER ) AS FRDD_NO_STK_CMPL_DT_DIFF,
        CAST( FCDD_CMPL_DT - CAST( ( FCDD + 1 ) AS DATE ) AS INTEGER ) AS FCDD_NO_STK_CMPL_DT_DIFF,
        
        POL.SHIP_TO_CUST_ID,
        CUST.CUST_NAME AS SHIP_TO_CUST_NAME,
        CUST.OWN_CUST_ID,
        CUST.OWN_CUST_NAME,
        
        POL.MATL_ID,
        MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
        MATL.MATL_NO_8 || '- ' || MATL.DESCR AS MATERIAL_DESCR,
        MATL.TIC_CD,
        MATL.EXT_MATL_GRP_ID,
        MATL.MATL_PRTY_DESCR,
        MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA,
        MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP,
        MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP,
        MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE,
        
        POL.SHIP_FACILITY_ID,
        FAC.XTND_NAME AS SHIP_FACILITY_NAME,
        FAC.FACILITY_TYPE_ID,
        FAC.FACILITY_TYPE_DESC,
        
        NULLIF( POL.MAX_CARR_SCAC_ID, '' ) AS MAX_CARR_SCAC_ID,
        
        NULLIF( POL.CAN_REJ_REAS_ID, '' ) AS CAN_REJ_REAS_ID,
        NULLIF( POL.PO_TYPE_ID, '' ) AS PO_TYPE_ID,
        CASE WHEN POL.CREDIT_HOLD_FLG = 'Y' THEN 'Y' END AS CREDIT_HOLD_FLG,
        CASE WHEN POL.DELIV_BLK_IND = 'Y' THEN 'Y' END AS DELIV_BLK_IND,
        CASE WHEN POL.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
        CASE WHEN POL.A_IND = 'A' THEN 'A' END AS A_IND,
        CASE WHEN POL.R_IND = 'R' THEN 'R' END AS R_IND,
        NULLIF( POL.SPCL_PROC_ID, '' ) AS SPCL_PROC_ID,
        
        CAST( POL.ORDER_DT AS DATE ) AS ORDER_DT,
        CAST( POL.FMAD_DT AS DATE ) AS FRDD_FMAD,
        CAST( POL.FPGI_DT AS DATE ) AS FRDD_FPGI,
        CAST( POL.REQ_DELIV_DT AS DATE ) AS FRDD,
        
        CAST( FCDD - CAST( ( FRDD - FRDD_FMAD ) AS INTEGER ) AS DATE ) AS FCDD_FMAD,
        CAST( FCDD - CAST( ( FRDD - FRDD_FPGI ) AS INTEGER ) AS DATE ) AS FCDD_FPGI,
        CAST( POL.FRST_PROM_DELIV_DT AS DATE ) AS FCDD,
        
        CAST( CASE
            WHEN FRDD > FCDD
                THEN 'FRDD > FCDD'
            WHEN FRDD = FCDD
                THEN 'FRDD = FCDD'
            WHEN FRDD < FRDD
                THEN 'FRDD < FCDD'
        END AS VARCHAR(15) ) AS FRDD_FCDD_TEST,
        
        CAST( POL.CUST_APPT_DT AS DATE ) AS CUST_APPT_DT,
        CAST( POL.MAX_DELIV_NOTE_CREA_DT AS DATE ) AS MAX_DELIV_NOTE_CREA_DT,
        CAST( POL.MAX_EDI_DELIV_DT AS DATE ) AS MAX_EDI_DELIV_DT,
        CAST( POL.MAX_SAP_DELIV_DT AS DATE ) AS MAX_SAP_DELIV_DT,
        CAST( POL.ACTL_DELIV_DT AS DATE ) AS ACTL_DELIV_DT,
        
        CAST( CASE
            WHEN POL.MAX_EDI_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT <= FRDD
                        THEN 'EDI Delivery Date <= FRDD'
                    WHEN POL.ACTL_DELIV_DT > FRDD
                        THEN 'EDI Delivery Date > FRDD'
                END )
            WHEN POL.MAX_SAP_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT <= FRDD
                        THEN 'SAP Delivery Date <= FRDD'
                    WHEN POL.ACTL_DELIV_DT > FRDD
                        THEN 'SAP Delivery Date > FRDD'
                END )
        END AS VARCHAR(30) ) AS FRDD_VS_DELIV_DT_TEST,
        CAST( CASE
            WHEN POL.MAX_EDI_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT <= FCDD
                        THEN 'EDI Delivery Date <= FCDD'
                    WHEN POL.ACTL_DELIV_DT > FCDD
                        THEN 'EDI Delivery Date > FCDD'
                END )
            WHEN POL.MAX_SAP_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT <= FCDD
                        THEN 'SAP Delivery Date <= FCDD'
                    WHEN POL.ACTL_DELIV_DT > FCDD
                        THEN 'SAP Delivery Date > FCDD'
                END )
        END AS VARCHAR(30) ) AS FCDD_VS_DELIV_DT_TEST,
        
        CAST( CASE
            WHEN POL.MAX_EDI_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT < FRDD
                        THEN 'EDI Delivery Date < FRDD'
                    WHEN POL.ACTL_DELIV_DT = FRDD
                        THEN 'EDI Delivery Date = FRDD'
                    WHEN POL.ACTL_DELIV_DT > FRDD
                        THEN 'EDI Delivery Date > FRDD'
                END )
            WHEN POL.MAX_SAP_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT < FRDD
                        THEN 'SAP Delivery Date < FRDD'
                    WHEN POL.ACTL_DELIV_DT = FRDD
                        THEN 'SAP Delivery Date = FRDD'
                    WHEN POL.ACTL_DELIV_DT > FRDD
                        THEN 'SAP Delivery Date > FRDD'
                END )
        END AS VARCHAR(30) ) AS FRDD_VS_DELIV_DT_DTL_TEST,
        CAST( CASE
            WHEN POL.MAX_EDI_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT < FCDD
                        THEN 'EDI Delivery Date < FCDD'
                    WHEN POL.ACTL_DELIV_DT = FCDD
                        THEN 'EDI Delivery Date = FCDD'
                    WHEN POL.ACTL_DELIV_DT > FCDD
                        THEN 'EDI Delivery Date > FCDD'
                END )
            WHEN POL.MAX_SAP_DELIV_DT = POL.ACTL_DELIV_DT
                THEN ( CASE
                    WHEN POL.ACTL_DELIV_DT < FCDD
                        THEN 'SAP Delivery Date < FCDD'
                    WHEN POL.ACTL_DELIV_DT = FCDD
                        THEN 'SAP Delivery Date = FCDD'
                    WHEN POL.ACTL_DELIV_DT > FCDD
                        THEN 'SAP Delivery Date > FCDD'
                END )
        END AS VARCHAR(30) ) AS FCDD_VS_DELIV_DT_DTL_TEST,
        
        POL.PRFCT_ORD_HIT_DESC AS FRDD_HIT_DESC,
        POL.PRFCT_ORD_HIT_SORT_KEY AS FRDD_HIT_SORT_KEY,
        POL.PRFCT_ORD_FPDD_HIT_DESC AS FCDD_HIT_DESC,
        POL.PRFCT_ORD_FPDD_HIT_SORT_KEY AS FCDD_HIT_SORT_KEY,
        
        ZEROIFNULL( POL.ORIG_ORD_QTY ) AS ORIG_ORDER_QTY,
        ZEROIFNULL( POL.CANCEL_QTY ) AS CANCEL_QTY,
    
        ZEROIFNULL( POL.CURR_ORD_QTY ) AS FRDD_ORDER_QTY,
        ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_HIT_QTY,
        ZEROIFNULL( POL.CURR_ORD_QTY ) - ZEROIFNULL( POL.PRFCT_ORD_HIT_QTY ) AS FRDD_ONTIME_QTY,
        ZEROIFNULL( POL.REL_LATE_QTY ) AS FRDD_REL_LATE_QTY,
        ZEROIFNULL( POL.REL_ONTIME_QTY ) AS FRDD_REL_ONTIME_QTY,
        ZEROIFNULL( POL.COMMIT_ONTIME_QTY ) AS FRDD_COMMIT_ONTIME_QTY,
        ZEROIFNULL( POL.DELIV_LATE_QTY ) AS FRDD_DELIV_LATE_QTY,
        ZEROIFNULL( POL.DELIV_ONTIME_QTY ) AS FRDD_DELIV_ONTIME_QTY,
        
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
    
        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID
            AND CUST.CUST_GRP_ID <> '3R'
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = POL.MATL_ID
        
        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_HIER_EN_CURR FAC
            ON FAC.FACILITY_ID = POL.SHIP_FACILITY_ID
    
    WHERE
        POL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
        /* METRIC LOGIC */
        AND ( EXTRACT( YEAR FROM POL.CMPL_DT ) > 2012 ) -- OR EXTRACT( YEAR FROM POL.FPDD_CMPL_DT ) > 2012 )
        AND ( POL.CMPL_IND = 1 OR POL.FPDD_CMPL_IND = 1 )
        AND ( 
            POL.CMPL_DT BETWEEN ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -18 ) AS CHAR(10) ), 1, 7) || '-01' AS DATE ) ) AND ( CURRENT_DATE - 1 )
            OR POL.FPDD_CMPL_DT BETWEEN ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -18 ) AS CHAR(10) ), 1, 7) || '-01' AS DATE ) ) AND ( CURRENT_DATE - 1 ) 
            )
        AND ( POL.PRFCT_ORD_HIT_DESC NOT IN ( 'FRDD Hit - Error' ) OR POL.PRFCT_ORD_FPDD_HIT_DESC NOT IN ( 'FCDD Hit - Error' ) )
    
        AND POL.PRFCT_ORD_HIT_DESC IN ( 'FRDD Hit - No Stock' ) 
        AND FRDD_NO_STK_CMPL_DT_DIFF <> 0
        AND FRDD_METRIC_INCLUDE_IND = 'Y'
    
    ) OTD

GROUP BY
    FRDD_CMPL_MTH,
    EXP_FRDD_CMPL_MTH,
    FRDD_CMPL_MTH_TEST,
    OTD.OWN_CUST_ID,
    OTD.OWN_CUST_NAME,
    OTD.MATL_ID,
    OTD.PBU,
    OTD.SHIP_FACILITY_ID,
    OTD.SHIP_FACILITY_NAME