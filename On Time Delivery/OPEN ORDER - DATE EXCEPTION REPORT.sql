SELECT
    Q.ORDER_ID AS "Order ID",
    Q.ORDER_LINE_NBR AS "Order Line Nbr",
    Q.SCHED_LINE_NBR AS "Schedule Line Nbr",
    Q.MAIN_EXCEPTION AS "Primary Date Mgmt Exception",
    
    Q.ORDER_CAT_ID AS "Order Category ID",
    Q.ORDER_TYPE_ID AS "Order Type ID",
    Q.PO_TYPE_ID AS "PO Type ID",
    Q.CUST_GRP_ID AS "Customer Group ID",
    Q.CUST_GRP2_CD AS "Customer Group 2 Code",
    Q.DELIV_BLK_CD AS "Delivery Block Code",
    Q.PBU,
    
    Q.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    Q.SHIP_TO_CUST_NAME AS "Ship To Customer Name",
    Q.OWN_CUST_ID AS "Common Owner ID",
    Q.OWN_CUST_NAME AS "Common Owner Name",

    Q.MATL_ID AS "Material ID",
    
    Q.MATERIAL_DESCR AS "Material Description",

    Q.FACILITY_ID AS "Facility ID",
    Q.FACILITY_NAME AS "Facility Name",
    
    Q.FRDD_TO_FCDD_INTERVAL AS "FRDD to FCDD Interval",
    Q.FRDD_TO_ORDD_INTERVAL AS "FRDD to ORDD Interval",
    Q.FRDD_TO_FMAD_INTERVAL AS "FRDD to FMAD Interval",
    
    Q.ORDER_DT AS "Order Create Date",
    Q.ORDD,
    
    Q.FRDD_FMAD AS "FMAD for FRDD",
    Q.FRDD,
    Q.FCDD,
    
    Q.FRDD_VS_FCDD_TEST AS "FRDD vs FCDD Test",
    
    Q.FRDD_VS_ORDD_TEST AS "FRDD vs ORDD Test",
    
    Q.FMAD_VS_FRDD_TEST AS "FMAD vs FRDD Test",
    
    Q.OPEN_CNFRM_QTY AS "Open Confirmed Qty",
    Q.UNCNFRM_QTY AS "Unconfirmed Qty",
    Q.BACK_ORDER_QTY AS "Back Ordered Qty"

FROM (
    
    SELECT
        OOSL.ORDER_ID,
        OOSL.ORDER_LINE_NBR,
        OOSL.SCHED_LINE_NBR,
        
        CASE
            WHEN ODC.FRST_RDD < ODC.CUST_RDD
                THEN 'FRDD < ORDD'
            WHEN ODC.FRST_RDD > ODC.FRST_PROM_DELIV_DT
                THEN 'FRDD > FCDD'
            WHEN ODC.FRST_MATL_AVL_DT > ODC.FRST_RDD
                THEN 'FMAD > FRDD'
        END AS MAIN_EXCEPTION,
        
        ODC.SHIP_TO_CUST_ID,
        CUST.CUST_NAME AS SHIP_TO_CUST_NAME,
        CUST.OWN_CUST_ID,
        CUST.OWN_CUST_NAME,
        
        ODC.ORDER_CAT_ID,
        ODC.ORDER_TYPE_ID,
        ODC.PO_TYPE_ID,
        
        ODC.CUST_GRP_ID,
        ODC.CUST_GRP2_CD,
        NULLIF( ODC.DELIV_BLK_CD, '' ) AS DELIV_BLK_CD,
        
        ODC.MATL_ID,
        MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
        MATL.MATL_NO_8 || '- ' || MATL.DESCR AS MATERIAL_DESCR,
        MATL.TIC_CD,
        MATL.EXT_MATL_GRP_ID,
        MATL.MATL_PRTY_DESCR,
        MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA,
        MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP,
        MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP,
        MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE,
        
        ODC.FACILITY_ID,
        FAC.XTND_NAME AS FACILITY_NAME,
        
        CAST( CAST( ODC.FRST_PROM_DELIV_DT - ODC.FRST_RDD AS INTEGER FORMAT '-9(3)' ) || ' Days from FRDD to FCDD' AS VARCHAR(50) ) AS FRDD_TO_FCDD_INTERVAL,
        CAST( CAST( ODC.FRST_RDD - ODC.CUST_RDD AS INTEGER FORMAT '-9(3)' ) || ' Days from FRDD to ORDD' AS VARCHAR(50) ) AS FRDD_TO_ORDD_INTERVAL,
        CAST( CAST( ODC.FRST_MATL_AVL_DT - ODC.FRST_RDD AS INTEGER FORMAT '-9(3)' ) || ' Days from FRDD to FMAD' AS VARCHAR(50) ) AS FRDD_TO_FMAD_INTERVAL,
        
        ODC.ORDER_DT,
        ODC.CUST_RDD AS ORDD,
        
        ODC.FRST_MATL_AVL_DT AS FRDD_FMAD,
        ODC.FRST_RDD AS FRDD,
        ODC.FRST_PROM_DELIV_DT AS FCDD,
        
        CASE
            WHEN ODC.FRST_RDD < ODC.FRST_PROM_DELIV_DT
                THEN 'FRDD < FCDD'
            WHEN ODC.FRST_RDD = ODC.FRST_PROM_DELIV_DT
                THEN 'FRDD = FCDD'
            WHEN ODC.FRST_RDD > ODC.FRST_PROM_DELIV_DT
                THEN 'FRDD > FCDD'
        END AS FRDD_VS_FCDD_TEST,
        
        CASE
            WHEN ODC.FRST_RDD < ODC.CUST_RDD
                THEN 'FRDD < ORDD'
            WHEN ODC.FRST_RDD = ODC.CUST_RDD
                THEN 'FRDD = ORDD'
            WHEN ODC.FRST_RDD > ODC.CUST_RDD
                THEN 'FRDD > ORDD'
        END AS FRDD_VS_ORDD_TEST,
        
        CASE
            WHEN ODC.FRST_MATL_AVL_DT < ODC.FRST_RDD
                THEN 'FMAD < FRDD'
            WHEN ODC.FRST_MATL_AVL_DT = ODC.FRST_RDD
                THEN 'FMAD = FRDD'
            WHEN ODC.FRST_MATL_AVL_DT > ODC.FRST_RDD
                THEN 'FMAD > FRDD'
        END AS FMAD_VS_FRDD_TEST,
        
        OOSL.OPEN_CNFRM_QTY,
        OOSL.UNCNFRM_QTY,
        OOSL.BACK_ORDER_QTY
        
    FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
    
        INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
            ON ODC.ORDER_ID = OOSL.ORDER_ID
            AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
            AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
    
        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = ODC.MATL_ID
        
        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_HIER_EN_CURR FAC
            ON FAC.FACILITY_ID = ODC.FACILITY_ID
    
    WHERE
        ( 
            OOSL.OPEN_CNFRM_QTY > 0 
            OR OOSL.UNCNFRM_QTY > 0 
            OR OOSL.BACK_ORDER_QTY > 0 
        )    
        AND MAIN_EXCEPTION IS NOT NULL

    ) Q

ORDER BY
    Q.ORDER_ID,
    Q.ORDER_LINE_NBR,
    Q.SCHED_LINE_NBR
    

    
         -- FRDD_VS_ORDD_TEST IN ( 'FMAD = FRDD', 'FMAD > FRDD' )
         -- OR FRDD_VS_FCDD_TEST IN ( 'FRDD > FCDD' )
         -- OR FRDD_VS_ORDD_TEST IN (  'FRDD < ORDD' )
