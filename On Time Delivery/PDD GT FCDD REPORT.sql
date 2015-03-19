
-- ORDERS WITH PDD > FCDD @ SCHEDULE LINE LEVEL
SELECT 
    OOF.ORDER_ID AS "Order ID"
    , OOF.ORDER_LINE_NBR AS "Order Line Nbr"
    , OOF.SCHED_LINE_NBR AS "Schedule Line Nbr"
    
    , OOF.CREDIT_HOLD_FLG AS "Credit Hold Flag"
    , OOF.SHIP_TO_CUST_ID AS "Ship To Customer ID"
    , OOF.SHIP_TO_CUST_NAME AS "Ship To Custome Name"
    , OOF.OWN_CUST_ID AS "Common Owner ID"
    , OOF.OWN_CUST_NAME AS "Common Owner Name"
    
    
    
    
    , OOF.SALES_ORG_CD AS "Sales Organization Code"
    , OOF.DISTR_CHAN_CD AS "Distribution Channel Code"
    , OOF.CUST_GRP_ID AS "Customer Group ID"
    , OOF.PO_TYPE_ID AS "PO Type ID"
    , OOF.ORDER_CAT_ID AS "Order Category ID"
    , OOF.ORDER_TYPE_ID AS "Order Type ID"
    
    , OOF.DELIV_PRTY_ID AS "Delivery Priority ID"
    , OOF.CUST_GRP2_CD AS "Customer Group 2 Code"
    , OOF.MATL_ID AS "Material ID"
    , OOF.MATL_STA_ID AS "Material Status ID"
    , OOF.TIC_CD AS "TIC Code"
    , OOF.MATL_PRTY_DESCR AS "Material Priority"
    , OOF.SRC_FACILITY_ID AS "Material Source Facility ID"
    , OOF.MATL_DESCR AS "Material Description"
    
    , OOF.PBU_NBR AS "PBU Nbr"
    , OOF.PBU_NBR || ' - ' || OOF.PBU_NAME AS "PBU"
    , OOF.EXT_MATL_GRP_ID AS "External Material Group ID"
    , OOF.MKT_AREA AS "Market Area"
    , OOF.MKT_GRP AS "Market Group"
    , OOF.PROD_GRP AS "Product Group"
    , OOF.PROD_LINE AS "Product Line"
    , OOF.ITEM_CAT_ID AS "Item Category ID"
    , OOF.ORDER_DT AS "Order Date"
    , OOF.FIRST_DATE AS "First Date"
    , OOF.FRDD
    , OOF.FCDD
    , OOF.PLN_MATL_AVL_DT AS "Planned Material Availability Date"
    , OOF.PLN_GOODS_ISS_DT AS "Planned Goods Issue Date"
    , OOF.PLN_DELIV_DT AS "Planned Delivery Date"
    
    , CAST(OOF.FCDD_LEAD_DAYS || ' Days between ' || OOF.REPORTING_DT || ' and FCDD' AS VARCHAR(40)) AS "Days between Today and FCDD"
    , CAST(OOF.PDD_TO_FCDD_DAYS || ' Days between FCDD and PDD' AS VARCHAR(40)) AS "Days between FCDD and PDD"
    
    , OOF.OPEN_CONFIRMED_QTY AS "Open Confirmed Qty"
    , OOF.OPEN_CONFIRMED_WT AS "Open Confirmed Weight"
    , OOF.QTY_UNIT_MEAS_ID AS "Quantity UOM"
    , OOF.CURR_LC_ATP_QTY AS "Current LC ATP Qty"
    
    , OOF.DELIV_BLK_CD AS "Header Delivery Block"
    , OOF.SCHD_LN_DELIV_BLK_CD AS "Schedule Line Delivery Block"
    
    , OOF.FACILITY_ID AS "Facility ID"
    , OOF.SHIP_PT_ID AS "Ship Point ID"
    , OOF.CURR_LC_ATP_QTY AS "Order LC ATP Qty"
        
    , OOF.LOCKBOURNE_ATP AS "Lockbourne ATP Qty"
    , OOF.LOCKBOURNE_EST_DSI AS "Lockbourne Est. Days of Supply"
    
    , OOF.MCDONOUGH_ATP AS "McDonough ATP Qty"
    , OOF.MCDONOUGH_EST_DSI AS "McDonough Est. Days of Supply"
    
    , OOF.STOCKBRIDGE_ATP AS "Stockbridge ATP Qty"
    , OOF.STOCKBRIDGE_EST_DSI AS "Stockbridge Est. Days of Supply"
    
    , OOF.YORK_ATP AS "York ATP Qty"
    , OOF.YORK_EST_DSI AS "York Est. Days of Supply"

    , OOF.DEKALB_ATP AS "Dekalb ATP Qty"
    , OOF.DEKALB_EST_DSI AS "Dekalb Est. Days of Supply"

    , OOF.VICTORVILLE_ATP AS "Victorville ATP Qty"
    , OOF.VICTORVILLE_EST_DSI AS "Victorville Est. Days of Supply"

    , OOF.SHELBY_ATP AS "Shelby ATP Qty"
    , OOF.SHELBY_EST_DSI AS "Shelby Est. Days of Supply"

    , OOF.MAX_DSI_FACILITY_ID AS "Greatest DSI Facility ID"
    , OOF.MAX_DSI_ATP_QTY AS "Greatest DSI ATP Qty"

FROM (

    SELECT 
        OOSL.ORDER_FISCAL_YR
        , OOSL.ORDER_ID
        , OOSL.ORDER_LINE_NBR
        , OOSL.SCHED_LINE_NBR
        , OOSL.CREDIT_HOLD_FLG
        , ODC.SHIP_TO_CUST_ID
        , CUST.CUST_NAME AS SHIP_TO_CUST_NAME
        , CUST.OWN_CUST_ID
        , CUST.OWN_CUST_NAME
        , ODC.SALES_ORG_CD
        , ODC.DISTR_CHAN_CD
        , ODC.CUST_GRP_ID
        , NULLIF(ODC.PO_TYPE_ID, '') AS PO_TYPE_ID
        , ODC.ORDER_CAT_ID
        , ODC.ORDER_TYPE_ID
        , CASE WHEN ODC.CANCEL_IND = 'Y' THEN 'Y' ELSE 'N' END AS CANCEL_IND
        , CASE WHEN ODC.RETURN_IND = 'Y' THEN 'Y' ELSE 'N' END AS RETURN_IND
        
        , ODC.CUST_GRP2_CD
        , ODC.MATL_ID
        , MATL.MATL_NO_8
        , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
        , MATL.TIC_CD
        , MATL.PBU_NBR
        , MATL.PBU_NAME
        , MATL.EXT_MATL_GRP_ID
        , MATL.MATL_PRTY_DESCR
        , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA
        , MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP
        , MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP
        , MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE
        , ODC.ITEM_CAT_ID
        , SP.SRC_FACILITY_ID
        , MATL.MATL_STA_ID
        , ODC.ORDER_DT
        , SL.SCHD_LN_DELIV_DT AS FIRST_DATE
        , ODC.CUST_RDD AS ORDD
        , ODC.FRST_RDD AS FRDD
        , ODC.FRST_PROM_DELIV_DT AS FCDD
        , ODC.PLN_MATL_AVL_DT
        , ODC.PLN_GOODS_ISS_DT
        , ODC.PLN_DELIV_DT
        , CAST(CAST(ODC.PLN_DELIV_DT - FCDD AS INT) AS FORMAT '-9(3)') AS PDD_TO_FCDD_DAYS
        , CAST(CAST(CURRENT_DATE AS FORMAT 'YYYY-MMM-DD') AS CHAR(11)) AS REPORTING_DT
        , CAST(CAST(FCDD - CURRENT_DATE AS INT) AS FORMAT '-9(3)') AS FCDD_LEAD_DAYS
        , CAST(CAST(FCDD_LEAD_DAYS / 7 AS INT) AS FORMAT '-9(3)') AS FCDD_LEAD_WKS
        , ODC.ORDER_QTY AS ORDER_QTY
        , ODC.CNFRM_QTY AS TOTAL_CNFRM_QTY
        , OOSL.OPEN_CNFRM_QTY AS OPEN_CONFIRMED_QTY
        , CAST(OOSL.OPEN_CNFRM_QTY * MATL.UNIT_WT AS DECIMAL(15, 3)) AS OPEN_CONFIRMED_WT
        , ODC.QTY_UNIT_MEAS_ID
        
        , SD.DELIV_BLK_CD
        , SL.SCHD_LN_DELIV_BLK_CD
        
        , ODC.DELIV_PRTY_ID
        
        , ODC.SHIP_COND_ID
        
        , ODC.SHIP_PT_ID
        , ODC.FACILITY_ID
        , SP.AVAIL_TO_PROM_QTY AS CURR_LC_ATP_QTY
        
        , CASE WHEN INV.LOCKBOURNE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.LOCKBOURNE_ATP END AS LOCKBOURNE_ATP
        , CASE WHEN INV.LOCKBOURNE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.LOCKBOURNE_EST_DSI END AS LOCKBOURNE_EST_DSI
        
        , CASE WHEN INV.MCDONOUGH_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.MCDONOUGH_ATP END AS MCDONOUGH_ATP
        , CASE WHEN INV.MCDONOUGH_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.MCDONOUGH_EST_DSI END AS MCDONOUGH_EST_DSI
        
        , CASE WHEN INV.STOCKBRIDGE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.STOCKBRIDGE_ATP END AS STOCKBRIDGE_ATP
        , CASE WHEN INV.STOCKBRIDGE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.STOCKBRIDGE_EST_DSI END AS STOCKBRIDGE_EST_DSI
        
        , CASE WHEN INV.YORK_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.YORK_ATP END AS YORK_ATP
        , CASE WHEN INV.YORK_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.YORK_EST_DSI END AS YORK_EST_DSI

        , CASE WHEN INV.DEKALB_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.DEKALB_ATP END AS DEKALB_ATP
        , CASE WHEN INV.DEKALB_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.DEKALB_EST_DSI END AS DEKALB_EST_DSI

        , CASE WHEN INV.VICTORVILLE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.VICTORVILLE_ATP END AS VICTORVILLE_ATP
        , CASE WHEN INV.VICTORVILLE_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.VICTORVILLE_EST_DSI END AS VICTORVILLE_EST_DSI

        , CASE WHEN INV.SHELBY_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.SHELBY_ATP END AS SHELBY_ATP
        , CASE WHEN INV.SHELBY_ATP < 1.5 * OOSL.OPEN_CNFRM_QTY THEN INV.SHELBY_EST_DSI END AS SHELBY_EST_DSI

        , INV.MAX_DSI_FACILITY_ID
        , INV.MAX_DSI_ATP_QTY
        , INV.MAX_DSI_EST_DSI

    FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
    
        INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
            ON ODC.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
            AND ODC.ORDER_ID = OOSL.ORDER_ID
            AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
            AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
            AND ODC.ORDER_CAT_ID = 'C'
            AND ODC.PO_TYPE_ID <> 'RO'
            AND ODC.FRST_PROM_DELIV_DT IS NOT NULL
            AND ODC.FRST_PROM_DELIV_DT > CURRENT_DATE
            AND ODC.PLN_DELIV_DT > ODC.FRST_PROM_DELIV_DT
        
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = ODC.MATL_ID
            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
            AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')
    
        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
        
        INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
            ON SD.EXP_DT = DATE '5555-12-31'
            AND SD.FISCAL_YR = OOSL.ORDER_FISCAL_YR
            AND SD.SLS_DOC_ID = OOSL.ORDER_ID
        
        INNER JOIN NA_BI_VWS.NAT_SLS_DOC_SCHD_LN SL
            ON SL.EXP_DT = DATE '5555-12-31'
            AND SL.FISCAL_YR = OOSL.ORDER_FISCAL_YR
            AND SL.SLS_DOC_ID = OOSL.ORDER_ID
            AND SL.SLS_DOC_ITM_ID = OOSL.ORDER_LINE_NBR
            AND SL.SCHD_LN_ID = 1
                   
        LEFT OUTER JOIN (
            SELECT
                FMI.MATL_ID
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N602' THEN FMI.AVAIL_TO_PROM_QTY END) AS LOCKBOURNE_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N602' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS LOCKBOURNE_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N607' THEN FMI.AVAIL_TO_PROM_QTY END) AS MCDONOUGH_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N607' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS MCDONOUGH_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N623' THEN FMI.AVAIL_TO_PROM_QTY END) AS STOCKBRIDGE_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N623' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS STOCKBRIDGE_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N636' THEN FMI.AVAIL_TO_PROM_QTY END) AS YORK_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N636' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS YORK_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N637' THEN FMI.AVAIL_TO_PROM_QTY END) AS DEKALB_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N637' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS DEKALB_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N699' THEN FMI.AVAIL_TO_PROM_QTY END) AS VICTORVILLE_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N699' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS VICTORVILLE_EST_DSI
                
                , MAX(CASE WHEN FMI.FACILITY_ID = 'N6D3' THEN FMI.AVAIL_TO_PROM_QTY END) AS SHELBY_ATP
                , MAX(CASE 
                    WHEN FMI.FACILITY_ID = 'N6D3' 
                        THEN (CASE
                            WHEN FMI.EST_DAYS_SUPPLY < 15
                                THEN 'Less than 15 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                                THEN 'Between 15 and 30 DSI'
                            WHEN FMI.EST_DAYS_SUPPLY > 30
                                THEN 'Greater than 30 DSI'
                        END)
                    END) AS SHELBY_EST_DSI
                , MAX_DSI.FACILITY_ID AS MAX_DSI_FACILITY_ID
                , MAX_DSI.AVAIL_TO_PROM_QTY AS MAX_DSI_ATP_QTY
                , MAX_DSI.EST_DAYS_SUPPLY AS MAX_DSI_EST_DSI

            FROM NA_BI_VWS.FACILITY_MATL_INVENTORY FMI

                INNER JOIN (
                            SELECT
                                F.MATL_ID
                                , F.FACILITY_ID
                                , F.AVAIL_TO_PROM_QTY
                                , F.EST_DAYS_SUPPLY
                                
                            FROM NA_BI_VWS.FACILITY_MATL_INVENTORY F
                            
                                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                                    ON M.MATL_ID = F.MATL_ID
                                    AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                                    AND M.MATL_TYPE_ID IN ('PCTL', 'ACCT')
                            
                            WHERE
                                F.DAY_DT = (CURRENT_DATE-1)
                                AND F.FACILITY_ID IN ('N602', 'N607', 'N623', 'N636', 'N637', 'N699', 'N6D3')
                            
                            QUALIFY
                                ROW_NUMBER() OVER (PARTITION BY F.MATL_ID ORDER BY F.EST_DAYS_SUPPLY DESC, F.AVAIL_TO_PROM_QTY DESC) = 1

                        ) MAX_DSI
                    ON MAX_DSI.MATL_ID = FMI.MATL_ID

            WHERE
                FMI.DAY_DT = (CURRENT_DATE-1)
                AND FMI.AVAIL_TO_PROM_QTY > 0
                AND FMI.FACILITY_ID IN ('N602', 'N607', 'N623', 'N636', 'N637', 'N699', 'N6D3')

            GROUP BY
                FMI.MATL_ID
                , MAX_DSI.FACILITY_ID
                , MAX_DSI.AVAIL_TO_PROM_QTY
                , MAX_DSI.EST_DAYS_SUPPLY

                ) INV
            ON INV.MATL_ID = ODC.MATL_ID
        
        LEFT OUTER JOIN (

            SELECT
                FM.FACILITY_ID AS SHIP_FACILITY_ID
                , FM.MATL_ID AS MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , CAST( CASE FM.SPCL_PRCU_TYP_CD
                    WHEN 'AA' THEN 'N501'
                    WHEN 'AB' THEN 'N502'
                    WHEN 'AC' THEN 'N503'
                    WHEN 'AD' THEN 'N504'
                    WHEN 'AE' THEN 'N505'
                    WHEN 'AH' THEN 'N508'
                    WHEN 'AI' THEN 'N509'
                    WHEN 'AJ' THEN 'N510'
                    WHEN 'AM' THEN 'N513'
                    WHEN 'S1' THEN 'N6BD'
                    WHEN 'S2' THEN 'N6BE'
                    WHEN 'S4' THEN 'N6BS'
                    WHEN 'S6' THEN 'N6J2'
                    WHEN 'S7' THEN 'N6J3'
                    WHEN 'S8' THEN 'N6J4'
                    WHEN 'S9' THEN 'N6J7'
                    WHEN 'SA' THEN 'N526'
                    WHEN 'SC' THEN 'N6A1'
                    WHEN 'SD' THEN 'N6A2'
                    WHEN 'SE' THEN 'N6A3'
                    WHEN 'SF' THEN 'N6A4'
                    WHEN 'SG' THEN 'N6A6'
                    WHEN 'SH' THEN 'N6A8'
                    WHEN 'SI' THEN 'N6A9'
                    WHEN 'SJ' THEN 'N6AA'
                    WHEN 'SL' THEN 'N6AC'
                    WHEN 'SM' THEN 'N6AE'
                    WHEN 'SN' THEN 'N6AG'
                    WHEN 'SO' THEN 'N6AH'
                    WHEN 'SQ' THEN 'N6AK'
                    WHEN 'SR' THEN 'N6AL'
                    WHEN 'SS' THEN 'N6J8'
                    WHEN 'ST' THEN 'N6AO'
                    WHEN 'SU' THEN 'N6AQ'
                    WHEN 'SV' THEN 'N6AR'
                    WHEN 'SW' THEN 'N6AS'
                    WHEN 'SX' THEN 'N6AT'
                    WHEN 'SY' THEN 'N6AX'
                    WHEN 'SZ' THEN 'N6BB'
                    WHEN 'WA' THEN 'N637'
                    WHEN 'WB' THEN 'N636'
                    WHEN 'WF' THEN 'N623'
                    WHEN 'WG' THEN 'N639'
                    WHEN 'WH' THEN 'N699'
                    WHEN 'WK' THEN 'N602'
                    ELSE COALESCE(FMX.FACILITY_ID, '')
                END AS CHAR(4) ) AS SRC_FACILITY_ID
                , FMI.AVAIL_TO_PROM_QTY
                , FMI.BACK_ORDER_QTY
                , FMI.COMMIT_QTY
                , FMI.UN_COMMIT_QTY
                , FMI.TOT_QTY
                , FMI.STO_INBOUND_QTY
                , FMI.IN_TRANS_QTY
                , FMI.STO_OUTBOUND_QTY
                , FMI.IN_PROS_TO_CUST_QTY
                , FMI.RSVR_QTY
                , FMI.BLOCKED_STK_QTY
                , FMI.RSTR_QTY
                , FMI.STK_RET_QTY
                , FMI.SAFE_STK_QTY
                , FMI.COMMIT_ON_HAND_QTY
                , FMI.COMMIT_IN_TRANS_QTY
                , FMI.PAST_DUE_QTY
                , FMI.DELAYED_QTY
                , FMI.INV_QTY_UOM

            FROM GDYR_VWS.FACILITY_MATL FM

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = FM.MATL_ID
                    AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                    AND M.MATL_TYPE_ID IN ('PCTL', 'ACCT')

                LEFT OUTER JOIN GDYR_VWS.FACILITY_MATL FMX
                    ON FMX.MATL_ID = FM.MATL_ID
                    AND FMX.ORIG_SYS_ID = 2
                    AND FMX.EXP_DT = DATE '5555-12-31'
                    AND FMX.MRP_TYPE_ID = 'X0'
                
                INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = FM.FACILITY_ID
                    AND F.SALES_ORG_CD <> 'N340' -- EXCLUDE COWD LOCATIONS
                
                INNER JOIN NA_BI_VWS.FACILITY_MATL_INVENTORY FMI
                    ON FMI.FACILITY_ID = FM.FACILITY_ID
                    AND FMI.MATL_ID = FM.MATL_ID
                    AND FMI.DAY_DT = (CURRENT_DATE-1)
                
            WHERE
                FM.EXP_DT = DATE '5555-12-31'
                AND FM.MRP_TYPE_ID = 'XB'
                AND FM.ORIG_SYS_ID = 2
                AND FMX.EXP_DT = DATE '5555-12-31'
                --AND SRC_FACILITY_ID = ''

            GROUP BY
                FM.FACILITY_ID
                , FM.MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , SRC_FACILITY_ID
                , FMI.AVAIL_TO_PROM_QTY
                , FMI.BACK_ORDER_QTY
                , FMI.COMMIT_QTY
                , FMI.UN_COMMIT_QTY
                , FMI.TOT_QTY
                , FMI.STO_INBOUND_QTY
                , FMI.IN_TRANS_QTY
                , FMI.STO_OUTBOUND_QTY
                , FMI.IN_PROS_TO_CUST_QTY
                , FMI.RSVR_QTY
                , FMI.BLOCKED_STK_QTY
                , FMI.RSTR_QTY
                , FMI.STK_RET_QTY
                , FMI.SAFE_STK_QTY
                , FMI.COMMIT_ON_HAND_QTY
                , FMI.COMMIT_IN_TRANS_QTY
                , FMI.PAST_DUE_QTY
                , FMI.DELAYED_QTY
                , FMI.INV_QTY_UOM

                ) SP
            ON SP.MATL_ID = MATL.MATL_ID
            AND SP.SHIP_FACILITY_ID = ODC.FACILITY_ID
    
    WHERE
        OOSL.OPEN_CNFRM_QTY > 0
    
    ) OOF
    
ORDER BY
    OOF.ORDER_ID,
    OOF.ORDER_LINE_NBR,
    "Days between Today and FCDD",
    "Days between FCDD and PDD"
