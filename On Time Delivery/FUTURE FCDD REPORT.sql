-- PROPORTIONS FOR ALL ORDERS
SELECT
    OOF.PBU_NBR || ' - ' || OOF.PBU_NAME AS PBU,
    OOF.EXT_MATL_GRP_ID AS "External Material Group ID",
    OOF.OWN_CUST_ID AS "Common Owner ID",
    OOF.OWN_CUST_NAME AS "Common Owner Name",
    OOF.MKT_AREA AS "Market Area",
    OOF.MKT_GRP AS "Market Group",
    OOF.PROD_GRP AS "Product Group",
    OOF.PROD_LINE AS "Product Line",
    OOF.DELIV_PRTY_ID AS "Delivery Priority ID",
    OOF.CUST_GRP2_CD AS "Customer Group 2 Code",
    OOF.TIC_CD AS "TIC Code",
    OOF.MATL_NO_8 || ' - ' || OOF.DESCR AS "Material Description",
    CAST( OOF.FCDD_LEAD_WKS || ' Weeks from ' || OOF.REPORTING_DT || ' to FCDD' AS VARCHAR(50) ) AS "Lead Time (Weeks)",
    CAST( SUM( OOF.OPEN_CONFIRMED_QTY ) AS INTEGER) AS "Open Confirmed Qty",
    CAST( SUM( OOF.UNCONFIRMED_QTY ) AS INTEGER ) AS "Unconfirmed Qty",
    CAST( SUM( OOF.BACK_ORDERED_QTY ) AS INTEGER ) AS "Back Order Qty",
    CAST( SUM( CASE
        WHEN OOF.PDD > OOF.FCDD
            THEN OOF.OPEN_CONFIRMED_QTY
        ELSE 0
    END ) AS INTEGER ) AS "Open Confirmed Qty PDD > FCDD",

    OOF.QTY_UNIT_MEAS_ID AS "Quantity UOM"

FROM (

    SELECT
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
        NULLIF( ODC.PO_TYPE_ID, ' ' ) AS PO_TYPE_ID,
        ODC.ORDER_CAT_ID,
        ODC.ORDER_TYPE_ID,
        CASE WHEN ODC.CANCEL_IND = 'Y' THEN 'Y' END AS CANCEL_IND,
        CASE WHEN ODC.RETURN_IND = 'Y' THEN 'Y' END AS RETURN_IND,
        NULLIF( ODC.DELIV_BLK_CD, ' ' ) AS DELIV_BLK_CD,
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
        ODC.FRST_RDD AS FRDD,
        ODC.FRST_PROM_DELIV_DT AS FCDD,
        ODC.PLN_DELIV_DT AS PDD,
        
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
            ON ODC.ORDER_ID = OOSL.ORDER_ID
            AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
            AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
            AND ODC.CUST_GRP_ID <> '3R'
            AND ODC.ORDER_TYPE_ID <> 'ZLZ'
            AND ODC.RO_PO_TYPE_IND = 'N' -- AND ODC.PO_TYPE_ID <> 'RO'
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = ODC.MATL_ID
            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
    
        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
            AND CUST.CUST_GRP_ID <> '3R'
    
        LEFT OUTER JOIN (
        
                SELECT
                    FM.MATL_ID,
                    CAST( CASE FM.SPCL_PRCU_TYP_CD
                        WHEN 'AA' THEN 'N501'
                        WHEN 'AB' THEN 'N502'
                        WHEN 'AC' THEN 'N503'
                        WHEN 'AD' THEN 'N504'
                        WHEN 'AE' THEN 'N505'
                        WHEN 'AH' THEN 'N508'
                        WHEN 'AI' THEN 'N509'
                        WHEN 'AJ' THEN 'N510'
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
                    END AS CHAR(4) ) AS SRC_FACILITY_ID
                
                FROM GDYR_VWS.FACILITY_MATL FM
                
                WHERE
                    CURRENT_DATE BETWEEN FM.EFF_DT AND FM.EXP_DT
                    AND FM.MRP_TYPE_ID LIKE 'X%'
                    AND FM.SPCL_PRCU_TYP_CD NOT IN ( 'AM', 'AN', 'S3', 'S5', 'SB', 'SP' )
                    AND FM.SPCL_PRCU_TYP_CD LIKE ANY ( 'A%', 'S%' )
                
                GROUP BY
                    FM.MATL_ID,
                    SRC_FACILITY_ID
                    
                ) SP
            ON SP.MATL_ID = MATL.MATL_ID
    
    WHERE
        FCDD > CURRENT_DATE
        AND ( OPEN_CONFIRMED_QTY > 0
        OR UNCONFIRMED_QTY > 0
        OR BACK_ORDERED_QTY > 0 )

    ) OOF

GROUP BY
    PBU,
    OOF.MKT_AREA,
    OOF.MKT_GRP,
    OOF.PROD_GRP,
    OOF.PROD_LINE,
    OOF.DELIV_PRTY_ID,
    OOF.CUST_GRP2_CD,
    OOF.EXT_MATL_GRP_ID,
    OOF.TIC_CD,
    "Material Description",
    OOF.OWN_CUST_ID,
    OOF.OWN_CUST_NAME,
    "Lead Time (Weeks)",
    OOF.QTY_UNIT_MEAS_ID

ORDER BY
    "Lead Time (Weeks)",
    PBU,
    OOF.MKT_AREA,
    OOF.MKT_GRP,
    OOF.PROD_GRP,
    OOF.PROD_LINE,
    OOF.OWN_CUST_ID,
    OOF.OWN_CUST_NAME,
    OOF.DELIV_PRTY_ID,
    OOF.CUST_GRP2_CD
