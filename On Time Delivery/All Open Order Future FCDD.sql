-- ORDERS WITH PDD > FCDD @ SCHEDULE LINE LEVEL
SELECT
    OOF.ORDER_FISCAL_YR AS "Order Fiscal Yr",
    OOF.ORDER_ID AS "Order ID",
    OOF.ORDER_LINE_NBR AS "Order Line Nbr",
    OOF.SCHED_LINE_NBR AS "Schedule Line Nbr",

    OOF.CREDIT_HOLD_FLG AS "Credit Hold Flag",

    OOF.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    OOF.SHIP_TO_CUST_NAME AS "Ship To Custome Name",
    OOF.OWN_CUST_ID AS "Common Owner ID",
    OOF.OWN_CUST_NAME AS "Common Owner Name",

    OOF.SALES_ORG_CD AS "Sales Organization Code",
    OOF.DISTR_CHAN_CD AS "Distribution Channel Code",
    OOF.CUST_GRP_ID AS "Customer Group ID", 
    OOF.PO_TYPE_ID AS "PO Type ID",
    OOF.ORDER_CAT_ID AS "Order Category ID",
    OOF.ORDER_TYPE_ID AS "Order Type ID",
    OOF.DELIV_BLK_CD AS "Delivery Block Code",
    OOF.FACILITY_ID AS "Facility ID",
    OOF.SHIP_PT_ID AS "Ship Point ID",
    OOF.DELIV_PRTY_ID AS "Delivery Priority ID",
    OOF.CUST_GRP2_CD AS "Customer Group 2 Code",

    OOF.MATL_ID AS "Material ID",
    OOF.TIC_CD AS "TIC Code",
    OOF.MATL_PRTY_DESCR AS "Material Priority",
    OOF.SRC_FACILITY_ID AS "Material Source Facility ID",
    OOF.DESCR AS "Material Description",
    OOF.PBU_NBR AS "PBU Nbr",
    OOF.PBU_NBR || ' - ' || OOF.PBU_NAME AS "PBU",
    OOF.EXT_MATL_GRP_ID AS "External Material Group ID",
    OOF.MKT_AREA AS "Market Area",
    OOF.MKT_GRP AS "Market Group",
    OOF.PROD_GRP AS "Product Group",
    OOF.PROD_LINE AS "Product Line",
    OOF.ITEM_CAT_ID AS "Item Category ID",

    OOF.ORDER_DT AS "Order Date",
    OOF.FIRST_DT AS "First Date",
    OOF.FRDD,
    OOF.FCDD,
    OOF.PDD AS "Planned Delivery Date",
    CAST( OOF.FCDD_LEAD_DAYS || ' Days between ' || OOF.REPORTING_DT ||  ' and FCDD' AS VARCHAR(40) )AS "Days between Today and FCDD",
    CAST( OOF.PDD_TO_FCDD_DAYS || ' Days between FCDD and PDD' AS VARCHAR(40) ) AS "Days between FCDD and PDD", 

    OOF.OPEN_CONFIRMED_QTY AS "Open Confirmed Qty",
    OOF.UNCONFIRMED_QTY AS "Unconfirmed Qty",
    OOF.BACK_ORDERED_QTY AS "Back Ordered Qty",
    OOF.QTY_UNIT_MEAS_ID AS  "Quantity UOM"
    
FROM (

    SELECT
        OOSL.ORDER_FISCAL_YR,
        OOSL.ORDER_ID,
        OOSL.ORDER_LINE_NBR,
        OOSL.SCHED_LINE_NBR,
    
        OOSL.CREDIT_HOLD_FLG,
        
        ODC.SHIP_TO_CUST_ID ,
        CUST.CUST_NAME AS SHIP_TO_CUST_NAME,
        CUST.OWN_CUST_ID,
        CUST.OWN_CUST_NAME,
    
        ODC.SALES_ORG_CD,
        ODC.DISTR_CHAN_CD,
        ODC.CUST_GRP_ID,
        NULLIF( ODC.PO_TYPE_ID, '' ) AS PO_TYPE_ID,
        ODC.ORDER_CAT_ID,
        ODC.ORDER_TYPE_ID,
        CASE WHEN ODC.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
        CASE WHEN ODC.RETURN_IND = 'Y' THEN 'Y' END AS RETURN_IND,
        NULLIF( ODC.DELIV_BLK_CD, '' ) AS DELIV_BLK_CD,
        ODC.FACILITY_ID,
        ODC.SHIP_PT_ID,
        ODC.DELIV_PRTY_ID,
        ODC.CUST_GRP2_CD,
    
        ODC.MATL_ID,
        MATL.MATL_NO_8,
        MATL.DESCR,
        MATL.TIC_CD,
        MATL.PBU_NBR,
        MATL.PBU_NAME,
        MATL.EXT_MATL_GRP_ID,
        MATL.MATL_PRTY_DESCR,
        MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA,
        MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP,
        MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP,
        MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE,
        ODC.ITEM_CAT_ID,
        SP.SRC_FACILITY_ID,
    
        ODC.ORDER_DT,
        FD.PLN_DELIV_DT AS FIRST_DT,
        ODC.FRST_RDD AS FRDD,
        ODC.FRST_PROM_DELIV_DT AS FCDD,
        CASE WHEN OOSL.OPEN_CNFRM_QTY > 0 THEN ODC.PLN_DELIV_DT END AS PDD,
        
        CAST( CAST( PDD - FCDD AS INTEGER ) AS FORMAT '-9(3)' ) AS PDD_TO_FCDD_DAYS,
        
        CAST( CAST( CURRENT_DATE AS FORMAT 'YYYY-MMM-DD') AS CHAR(11) ) AS REPORTING_DT,
        CAST( CAST( FCDD - CURRENT_DATE AS INTEGER ) AS FORMAT '-9(3)' ) AS FCDD_LEAD_DAYS,
        CAST( CAST( FCDD_LEAD_DAYS / 7 AS INTEGER ) AS FORMAT '-9(3)' ) AS FCDD_LEAD_WKS,
    
        ODC.ORDER_QTY AS ORDER_QTY,
        ODC.CNFRM_QTY AS TOTAL_CNFRM_QTY,
    
        OOSL.OPEN_CNFRM_QTY AS OPEN_CONFIRMED_QTY,
        OOSL.UNCNFRM_QTY AS UNCONFIRMED_QTY,
        OOSL.BACK_ORDER_QTY AS BACK_ORDERED_QTY,
        OOSL.DEFER_QTY AS DEFER_QTY,
        OOSL.IN_PROC_QTY AS IN_PROC_QTY,
        OOSL.WAIT_LIST_QTY AS WAIT_LIST_QTY,
        OOSL.OTHR_ORDER_QTY AS OTHR_ORDER_QTY,
        ODC.QTY_UNIT_MEAS_ID
    
    FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
    
        INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
            ON ODC.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
            AND ODC.ORDER_ID = OOSL.ORDER_ID
            AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
            AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
            AND ODC.CUST_GRP_ID <> '3R'
            AND ODC.ORDER_TYPE_ID <> 'ZLZ'
            AND ODC.RO_PO_TYPE_IND = 'N' -- AND ODC.PO_TYPE_ID <> 'RO'
    
        INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR FD
            ON FD.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
            AND FD.ORDER_ID = OOSL.ORDER_ID
            AND FD.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
            AND FD.SCHED_LINE_NBR = 1
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = ODC.MATL_ID
            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
            AND MATL.MKT_CTGY_MKT_AREA_NBR = '36'
    
        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
            AND CUST.CUST_GRP_ID <> '3R'
    
        LEFT OUTER JOIN (
        
                SELECT
                    FM.FACILITY_ID AS SHIP_FACILITY_ID,
                    FM.MATL_ID AS MATL_ID,
                    CAST( CASE FM.SPCL_PRCU_TYP_CD
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

                FROM GDYR_VWS.FACILITY_MATL FM

                    INNER JOIN GDYR_VWS.MATL M
                        ON M.MATL_ID = FM.MATL_ID
                        AND M.EXP_DT = DATE '5555-12-31'
                        AND M.ORIG_SYS_ID = FM.ORIG_SYS_ID
                        AND M.SBU_ID = FM.SBU_ID
                        AND M.SRC_SYS_ID = FM.SRC_SYS_ID
                        AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')

                    LEFT OUTER JOIN GDYR_VWS.FACILITY_MATL FMX
                        ON FMX.EXP_DT = DATE '5555-12-31'
                        AND FMX.MATL_ID = FM.MATL_ID
                        AND FMX.SBU_ID = FM.SBU_ID 
                        AND FMX.ORIG_SYS_ID = FM.ORIG_SYS_ID
                        AND FMX.SRC_SYS_ID = FM.SRC_SYS_ID
                        AND FMX.MRP_TYPE_ID = 'X0'

                WHERE
                    FM.SBU_ID = 2 
                    AND FM.ORIG_SYS_ID = 2
                    AND FM.EXP_DT = DATE '5555-12-31'
                    AND FM.MRP_TYPE_ID = 'XB'

                GROUP BY
                    FM.FACILITY_ID,
                    FM.MATL_ID,
                    SRC_FACILITY_ID
                    
                ) SP
            ON SP.MATL_ID = ODC.MATL_ID
            AND SP.SHIP_FACILITY_ID = ODC.FACILITY_ID
    
    WHERE
        FCDD > CURRENT_DATE
        AND ( OPEN_CONFIRMED_QTY > 0
        OR UNCONFIRMED_QTY > 0
        OR BACK_ORDERED_QTY > 0 )
    
) OOF

WHERE
    OOF.PDD > OOF.FCDD
    
ORDER BY
    "Days between Today and FCDD",
    "Days between FCDD and PDD"
