SELECT
    ODS.ORDER_FISCAL_YR
    , ODS.ORDER_ID
    , ODS.ORDER_LINE_NBR
    
    , ODS.CO_CD
    , ODS.DIV_CD
    , ODS.SALES_ORG_CD
    , ODS.DISTR_CHAN_CD
    , ODS.CUST_GRP_ID
    , ODS.SHIP_TO_CUST_ID
    , CUST.OWN_CUST_ID
    
    , CUST.PRIM_SHIP_FACILITY_ID
    , ODS.FACILITY_ID
    , ODS.SHIP_PT_ID
    
    , ODS.MATL_ID
    , ODS.BATCH_NBR
    , MATL.PBU_NBR
    , MATL.MKT_AREA_NBR
    
    , ODS.QTY_UOM
    , ODS.ORDER_QTY
    , ODS.CNFRM_QTY
    , ODS.FIRST_SL_CNFRM_QTY
    
    , ODS.SLS_QTY_UOM
    , ODS.SLS_ORDER_QTY
    
    , ODS.RPT_QTY_UOM
    , ODS.RPT_ORDER_QTY
    , ODS.RPT_CNFRM_QTY
    
    , ODS.WT_UOM
    , ODS.GROSS_WT
    , ODS.NET_WT
    
    , ODS.VOL_UOM
    , ODS.VOL
    
    , ODS.ORDER_DT
    , ODS.ORDD
    , ODS.FIRST_DATE_MAD
    , ODS.FIRST_DATE_PGI
    , ODS.FIRST_DATE
    , ODS.FNL_ACCEPT_DT
        
    , ODS.FRDD_FMAD
    , ODS.FRDD_FPGI
    , ODS.FRDD
    
    , ODS.FCDD_FMAD
    , ODS.FCDD_FPGI
    , ODS.FCDD
    
    , ODS.CUST_GRP2_CD
    -- SCHEDULE LINE DELIVERY BLOCK
    , ODS.SCHD_LN_DELIV_BLK_CD
    , ODS.SHIP_COND_ID
    , ODS.DELIV_PRTY_ID
    , ODS.ROUTE_ID
    , ODS.DELIV_GRP_CD
    , ODS.SPCL_PROC_ID

    , ODS.CANCEL_DT
    , ODS.REJ_REAS_ID
    , ODS.REJ_REAS
    
    , ODS.ORDER_CAT_ID
    , ODS.ORDER_TYPE_ID
    , ODS.ITEM_CAT_ID
    , ODS.PO_TYPE_ID
    
    , SLS.SD_HDR_CRT_TS
    , SLS.SD_HDR_UPD_DT
    , SLS.SD_ITM_CRT_TS
    , SLS.SD_ITM_UPD_DT
    , SLS.SD_HDR_CRT_USR_ID
    , SLS.SD_HDR_CRT_SAP_TCODE
    , SLS.SD_ITM_CRT_USR_ID
    , SLS.SD_HDR_CRT_SAP_TCODE
    , SLS.SD_HDR_DELIV_BLK_CD
    , SLS.SD_HDR_BILL_BLK_CD
    , SLS.SD_ITM_BILL_BLK_CD

FROM (

    SELECT
        ODC.ORDER_FISCAL_YR
        , ODC.ORDER_ID
        , ODC.ORDER_LINE_NBR
        
        , ODC.CO_CD
        , ODC.DIV_CD
        , ODC.SALES_ORG_CD
        , ODC.DISTR_CHAN_CD
        , ODC.CUST_GRP_ID
        , ODC.SHIP_TO_CUST_ID
        
        , ODC.FACILITY_ID
        , ODC.SHIP_PT_ID
        
        , ODC.MATL_ID
        , ODC.BATCH_NBR
        
        , ODC.QTY_UNIT_MEAS_ID AS QTY_UOM
        , MAX(ODC.ORDER_QTY) AS ORDER_QTY
        , SUM(ODC.CNFRM_QTY) AS CNFRM_QTY
        , SUM(CASE WHEN ODC.SCHED_LINE_NBR = 1 THEN ODC.CNFRM_QTY ELSE 0 END) AS FIRST_SL_CNFRM_QTY
        
        , ODC.SLS_QTY_UNIT_MEAS_ID AS SLS_QTY_UOM
        , MAX(ODC.SLS_ORDER_QTY) AS SLS_ORDER_QTY
        
        , ODC.RPT_QTY_UNIT_MEAS_ID AS RPT_QTY_UOM
        , MAX(ODC.RPT_ORDER_QTY) AS RPT_ORDER_QTY
        , SUM(ODC.RPT_CNFRM_QTY) AS RPT_CNFRM_QTY
        
        , ODC.WT_UNITS_MEAS_ID AS WT_UOM
        , MAX(ODC.GROSS_WT) AS GROSS_WT
        , MAX(ODC.NET_WT) AS NET_WT
        
        , ODC.VOL_UNIT_MEAS_ID AS VOL_UOM
        , MAX(ODC.VOL) AS VOL
        
        , ODC.ORDER_DT
        , ODC.CUST_RDD AS ORDD
        , MAX(CASE WHEN ODC.SCHED_LINE_NBR = 1 THEN ODC.PLN_MATL_AVL_DT END) AS FIRST_DATE_MAD
        , MAX(CASE WHEN ODC.SCHED_LINE_NBR = 1 THEN ODC.PLN_GOODS_ISS_DT END) AS FIRST_DATE_PGI
        , MAX(CASE WHEN ODC.SCHED_LINE_NBR = 1 THEN ODC.PLN_DELIV_DT END) AS FIRST_DATE
        , ODC.FNL_ACCEPT_DT
            
        , ODC.FRST_MATL_AVL_DT AS FRDD_FMAD
        , ODC.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI
        , ODC.FRST_RDD AS FRDD
        
        , MAX(ODC.FC_MATL_AVL_DT) AS FCDD_FMAD
        , MAX(ODC.FC_PLN_GOODS_ISS_DT) AS FCDD_FPGI
        , MAX(ODC.FRST_PROM_DELIV_DT) AS FCDD
        
        , ODC.CUST_GRP2_CD
        -- SCHEDULE LINE DELIVERY BLOCK
        , MAX(ODC.DELIV_BLK_CD) AS SCHD_LN_DELIV_BLK_CD
        , ODC.SHIP_COND_ID
        , MIN(ODC.DELIV_PRTY_ID) AS DELIV_PRTY_ID
        , ODC.ROUTE_ID
        , ODC.DELIV_GRP_CD
        , MAX(ODC.SPCL_PROC_ID) AS SPCL_PROC_ID

        , ODC.CANCEL_DT
        , ODC.REJ_REAS_ID
        , ODC.REJ_REAS_ID || ' - ' || ODC.REJ_REAS_DESC AS REJ_REAS
        
        , ODC.ORDER_CAT_ID
        , ODC.ORDER_TYPE_ID
        , ODC.ITEM_CAT_ID
        , ODC.PO_TYPE_ID

    FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

    WHERE
        ODC.FRST_RDD >= DATE '2014-01-01'
        AND ODC.ORDER_CAT_ID = 'C'
        AND ODC.PO_TYPE_ID <> 'RO'
        
        -- VALIDATES THAT SHIP POINT AND SHIP FACILITY AGREE
        -- REMOVES ONE DUPLICATED RECORD FOUND 2014-08-21
        AND SUBSTR(ODC.FACILITY_ID, 2, 3) = SUBSTR(ODC.SHIP_PT_ID, 1, 3)
        
        -- TRUCKLOAD BUILD FILTERS
        AND ODC.CUST_GRP2_CD = 'TLB'
        
    GROUP BY
        ODC.ORDER_FISCAL_YR
        , ODC.ORDER_ID
        , ODC.ORDER_LINE_NBR
        
        , ODC.CO_CD
        , ODC.DIV_CD
        , ODC.SALES_ORG_CD
        , ODC.DISTR_CHAN_CD
        , ODC.CUST_GRP_ID
        , ODC.SHIP_TO_CUST_ID
        
        , ODC.FACILITY_ID
        , ODC.SHIP_PT_ID
        
        , ODC.MATL_ID
        , ODC.BATCH_NBR
        
        , ODC.QTY_UNIT_MEAS_ID
        
        , ODC.SLS_QTY_UNIT_MEAS_ID
        , ODC.RPT_QTY_UNIT_MEAS_ID
        , ODC.WT_UNITS_MEAS_ID
        , ODC.VOL_UNIT_MEAS_ID 
        
        , ODC.ORDER_DT
        , ODC.CUST_RDD 
        , ODC.FNL_ACCEPT_DT
            
        , ODC.FRST_MATL_AVL_DT
        , ODC.FRST_PLN_GOODS_ISS_DT
        , ODC.FRST_RDD
        
        /*, MAX(ODC.FC_MATL_AVL_DT) AS FCDD_FMAD
        , MAX(ODC.FC_PLN_GOODS_ISS_DT) AS FCDD_FPGI
        , MAX(ODC.FRST_PROM_DELIV_DT) AS FCDD*/
        
        , ODC.CUST_GRP2_CD
        , ODC.SHIP_COND_ID
        , ODC.ROUTE_ID
        , ODC.DELIV_GRP_CD

        , ODC.CANCEL_DT
        , ODC.REJ_REAS_ID
        , REJ_REAS
        
        , ODC.ORDER_CAT_ID
        , ODC.ORDER_TYPE_ID
        , ODC.ITEM_CAT_ID
        , ODC.PO_TYPE_ID

    ) ODS
    
    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
        ON MATL.MATL_ID = ODS.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08')
        AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')
    
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODS.SHIP_TO_CUST_ID
    
    INNER JOIN (
            SELECT
                SDI.FISCAL_YR
                , SDI.SLS_DOC_ID
                , SDI.SLS_DOC_ITM_ID
                , CAST(SD.SRC_CRT_DT AS TIMESTAMP(0)) + (SD.SRC_CRT_TM - TIME '00:00:00' HOUR TO SECOND) AS SD_HDR_CRT_TS
                , SD.SRC_UPD_DT AS SD_HDR_UPD_DT
                , SDI.SRC_CRT_TS AS SD_ITM_CRT_TS
                , SDI.SRC_UPD_DT AS SD_ITM_UPD_DT
                , SD.SRC_CRT_USR_ID AS SD_HDR_CRT_USR_ID
                , SD.SAP_TRANS_CD AS SD_HDR_CRT_SAP_TCODE
                , SDI.SRC_CRT_USR_ID AS SD_ITM_CRT_USR_ID
                , SDI.SAP_TRANS_CD AS SD_ITM_CRT_SAP_TCODE
                , SD.DELIV_BLK_CD AS SD_HDR_DELIV_BLK_CD
                , SD.BILL_BLK_CD AS SD_HDR_BILL_BLK_CD
                , SDI.BILL_BLK_CD AS SD_ITM_BILL_BLK_CD
                
            FROM NA_BI_VWS.NAT_SLS_DOC_ITM_CURR SDI
            
                INNER JOIN NA_BI_vWS.NAT_SLS_DOC SD
                    ON SD.FISCAL_YR = SDI.FISCAL_YR
                    AND SD.SLS_DOC_ID = SDI.SLS_DOC_ID
                    AND SD.EXP_DT = DATE '5555-12-31'
                    -- SALES DOCS, EXCLUDE RESERVE ORDERS, TRUCKLOAD BUILD FREIGHT POLICY
                    AND SD.SD_DOC_CTGY_CD = 'C'
                    AND SD.CUST_PRCH_ORD_TYP_CD <> 'RO'
                    -- JOIN IMPACT REDUCTION FILTERS
                    AND SD.CO_CD IN ('N101', 'N102', 'N266')
                    AND SD.DIV_CD = '01'
                    AND REGEXP_INSTR(SD.SALES_ORG_CD, 'N3[012][123]', 1, 1, 0, 'I') > 0
                    AND SD.DISTR_CHAN_CD <> '81'
                    AND SD.SRC_CRT_DT >= DATE '2014-01-01'
                    
                    -- TRUCKLOAD BUILD FILTER
                    AND SD.CUST_GRP_ID_2 = 'TLB'
                    
            WHERE
                SDI.SRC_CRT_TS >= TIMESTAMP '2014-05-01 00:00:00'
                -- JOIN IMPACT REDUCTION FILTERS
                AND SDI.DIV_CD = '01'
                AND SDI.REQ_DELIV_DT >= TIMESTAMP '2014-01-01 00:00:00'
                -- item categories present in ORD_DTL
                AND SDI.SLS_DOC_ITM_CTGY_CD IN (
                        'BVN', 'LAN', 'TAB', 'TAL', 'TAMA'
                        , 'TAN', 'TAS', 'TATX', 'ZAVO', 'ZDON'
                        , 'ZKBN', 'ZKBO', 'ZNAS', 'ZOP', 'ZRST'
                        , 'ZRTO', 'ZZAV', 'ZZML', 'ZZMO'
                        )
                -- REGEXP OFFERS EFFICIENT STRING PARSING TO IDENTIFY PBU'S 01, 03, 04, 05, 07 & 08 WITHIN THE TABLE
                AND REGEXP_INSTR(SDI.MATL_HIER_ID, '^(0[134578])', 1, 1, 0, 'i') > 0
                
            ) SLS
        ON SLS.FISCAL_YR = ODS.ORDER_FISCAL_YR
        AND SLS.SLS_DOC_ID = ODS.ORDER_ID
        AND SLS.SLS_DOC_ITM_ID = ODS.ORDER_LINE_NBR

ORDER BY
    ODS.ORDER_FISCAL_YR
    , ODS.ORDER_ID
    , ODS.ORDER_LINE_NBR

