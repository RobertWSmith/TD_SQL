-- Query to aggregate and return all Fountain Tire Order Lines with Order Create Date between ranges determined by the user

SELECT
    Q.ORDER_ID AS "Order ID", 
    Q.ORDER_LINE_NBR AS "Order Line Nbr",  
    
    Q.OPEN_ORDER_CURR_IND AS "Open Order Indicator", 
    Q.RESCHD_DY_CNT AS "Count of Days Rescheduled", 
    
    -- Customer Hierarchy
    Q.SHIP_TO_CUST_ID AS "Ship To Customer ID", 
    CUST.CUST_NAME AS "Ship To Customer Name",
--    CUST.OWN_CUST_ID,     CUST.OWN_CUST_NAME,
    CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS "Common Owner",
--    CUST.CUST_GRP_ID,    CUST.CUST_GRP_NAME,
    CUST.CUST_GRP_ID || ' - ' || CUST.CUST_GRP_NAME AS "Customer Group",
    CUST.CUST_GRP1_CD AS "Customer Group 1 Code",
    CUST.CUST_GRP2_CD AS "Customer Group 2 Code",
--    CUST.SALES_ORG_CD,    CUST.SALES_ORG_NAME,
    CUST.SALES_ORG_CD || ' - ' || CUST.SALES_ORG_NAME AS "Sales Organization",
--    CUST.DISTR_CHAN_CD,    CUST.DISTR_CHAN_NAME,
    CUST.DISTR_CHAN_CD || ' - ' || CUST.DISTR_CHAN_NAME AS "Distribution Channel",
    CUST.POSTAL_CD AS "Postal Code",
    CUST.DISTRICT_NAME AS "District Name",
    CUST.TERR_NAME AS "Territory Name",
    CUST.CITY_NAME AS "City Name",
    CUST.CNTRY_NAME_CD AS "Country Name Code",
    CUST.DELIV_PRTY_CD AS "Delivery Priorty Code",
    
    -- Material Hierarchy
    Q.MATL_ID AS "Material ID", 
    MATL.DESCR AS "Material Description",
    MATL.PBU_NBR AS "PBU Number",
    --MATL.PBU_NAME,
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
--    MATL.BRAND_ID,    MATL.BRAND_NAME,
    MATL.BRAND_ID || ' - ' || MATL.BRAND_NAME AS "Brand",
--    MATL.MKT_CTGY_MKT_AREA_NBR,    MATL.MKT_CTGY_MKT_AREA_NAME,
    MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS "Market Area",
--    MATL.MKT_CTGY_MKT_GRP_NBR,    MATL.MKT_CTGY_MKT_GRP_NAME,
    MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS "Market Group",
--    MATL.MKT_CTGY_PROD_GRP_NBR,     MATL.MKT_CTGY_PROD_GRP_NAME, 
    MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS "Product Group",
--    MATL.MKT_CTGY_PROD_LINE_NBR,    MATL.MKT_CTGY_PROD_LINE_NAME,
    MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS "Product Line",
    
    Q.ORDER_DT AS "Order Date", 
    Q.CUST_RDD AS ORDD, 
    CAST( Q.CUST_RDD - Q.ORDER_DT AS INTEGER ) AS "ORDD to Order Date Interval",
    Q.FRST_RDD AS FRDD, 
    Q.FRST_MATL_AVL_DT AS FMAD, 
    Q.FRST_PLN_GOODS_ISS_DT AS FPGI, 
    Q.FRST_PROM_DELIV_DT AS FCDD,
    MIN( DDC.DELIV_DT ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ) AS "First Delivery Date",
    MAX( DDC.DELIV_DT ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ) AS "Last Delivery Date",
    SUM( CASE WHEN DDC.DELIV_QTY > 0 THEN 1 ELSE 0 END ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ) AS "Count of Delivery Lines",
    
    Q.ORDER_QTY AS "Ordered Qty", 
    Q.CNFRM_QTY AS "Confirmed Qty", 
    
    SUM( ZEROIFNULL( CASE
        WHEN "ORDD to Order Date Interval" < 14
            THEN ( CASE
                WHEN DDC.DELIV_DT <= ( Q.ORDER_DT + 14 )
                    THEN DDC.DELIV_QTY
                WHEN DDC.DELIV_DT > ( Q.ORDER_DT + 14 )
                    THEN 0
                END )
        WHEN "ORDD to Order Date Interval" >= 14
            THEN ( CASE
                WHEN DDC.DELIV_DT <= Q.CUST_RDD
                    THEN DDC.DELIV_QTY
                WHEN DDC.DELIV_DT > Q.CUST_RDD
                    THEN 0
                END )
    END ) ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ) AS "Delivered On Time Qty",
    SUM( ZEROIFNULL( CASE
        WHEN "ORDD to Order Date Interval" < 14
            THEN ( CASE
                WHEN DDC.DELIV_DT <= ( Q.ORDER_DT + 14 )
                    THEN 0
                WHEN DDC.DELIV_DT > ( Q.ORDER_DT + 14 )
                    THEN DDC.DELIV_QTY
                END )
        WHEN "ORDD to Order Date Interval" >= 14
            THEN ( CASE
                WHEN DDC.DELIV_DT <= Q.CUST_RDD
                    THEN 0
                WHEN DDC.DELIV_DT > Q.CUST_RDD
                    THEN DDC.DELIV_QTY
                END )
    END ) ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ) AS "Delivered Late Qty",
    
    Q.CNFRM_ON_TIME_QTY AS "Confirmed On Time Qty",
    Q.CNFRM_LATE_QTY AS "Confirmed Late Qty",
    
    "Delivered On Time Qty" + "Confirmed On Time Qty" AS "Current Total On Time Qty",
    "Delivered Late Qty" + "Confirmed Late Qty" AS "Current Total Late Qty",

    Q.OPEN_CNFRM_QTY AS "Open Confirmed Qty", 
    Q.UNCNFRM_QTY AS "Unconfirmed Qty", 
    Q.BACK_ORDER_QTY AS "Back Ordered Qty", 
    Q.DEFER_QTY AS "Deferred Qty", 
    Q.IN_PROC_QTY AS "In Process Qty", 
    Q.QTY_UNIT_MEAS_ID AS "Quantity UOM",
    
    Q.ORDER_TYPE_ID AS "Order Type ID", 
    Q.ORDER_CAT_ID AS "Order Category ID", 
    Q.CANCEL_IND AS "Cancellation Indicator", 
    Q.RETURN_IND AS "Return Indicator", 
    Q.PO_TYPE_ID AS "PO Type ID", 
    Q.DELIV_BLK_IND AS "Delivery Block Indicator", 
    Q.DELIV_BLK_CD AS "Delivery Block Code", 
    
    Q.FACILITY_ID AS "Facility ID", 
    Q.SHIP_PT_ID AS "Shipment Point ID",
    CUST.PRIM_SHIP_FACILITY_ID AS "Primary Facility ID",
    CASE WHEN Q.FACILITY_ID <> CUST.PRIM_SHIP_FACILITY_ID THEN 0 ELSE 1 END AS "Primary Facility Indicator",
    Q.REJ_REAS_ID AS "Rejection Reason ID", 
    Q.ORDER_REAS_CD AS "Order Reason Code", 
    Q.SPCL_PROC_ID AS "Special Processing ID"

FROM (

    SELECT
        ODC.ORDER_ID,
        ODC.ORDER_LINE_NBR,
        CASE
            WHEN OOSL.ORDER_ID IS NULL
                THEN 0
            ELSE 1
        END AS OPEN_ORDER_CURR_IND,
        MAX( ZEROIFNULL( RES.RESCHD_CNT ) ) AS RESCHD_DY_CNT,
        
        ODC.SHIP_TO_CUST_ID,
        ODC.SALES_ORG_CD,
        ODC.DISTR_CHAN_CD,
        ODC.CUST_GRP_ID,
        
        ODC.MATL_ID,
        
        ODC.ORDER_DT,
        COALESCE( ODC.CUST_RDD, ODC.FRST_RDD ) AS CUST_RDD,
        ODC.FRST_RDD,
        ODC.FRST_MATL_AVL_DT,
        ODC.FRST_PLN_GOODS_ISS_DT,
        ODC.FRST_PROM_DELIV_DT,
        
        MAX( ZEROIFNULL( ODC.ORDER_QTY ) ) AS ORDER_QTY,
        SUM( ZEROIFNULL( ODC.CNFRM_QTY ) ) AS CNFRM_QTY,
        SUM( ZEROIFNULL( CASE
            WHEN CAST( COALESCE( ODC.CUST_RDD, ODC.FRST_RDD ) - ODC.ORDER_DT AS INTEGER ) < 14
                THEN ( CASE
                    WHEN ODC.PLN_DELIV_DT <= CAST( ODC.ORDER_DT + 14 AS DATE )
                        THEN ODC.CNFRM_QTY
                    END )
            WHEN CAST( COALESCE( ODC.CUST_RDD, ODC.FRST_RDD ) - ODC.ORDER_DT AS INTEGER ) >= 14
                THEN ( CASE
                    WHEN ODC.PLN_DELIV_DT <= COALESCE( ODC.CUST_RDD, ODC.FRST_RDD )
                        THEN ODC.CNFRM_QTY
                END )
        END ) ) AS CNFRM_ON_TIME_QTY,
        CNFRM_QTY - CNFRM_ON_TIME_QTY AS CNFRM_LATE_QTY,
        
        SUM( ZEROIFNULL( OOSL.OPEN_CNFRM_QTY ) ) AS OPEN_CNFRM_QTY,
        SUM( ZEROIFNULL( OOSL.UNCNFRM_QTY ) ) AS UNCNFRM_QTY,
        SUM( ZEROIFNULL( OOSL.BACK_ORDER_QTY ) ) AS BACK_ORDER_QTY,
        SUM( ZEROIFNULL( OOSL.DEFER_QTY ) ) AS DEFER_QTY,
        SUM( ZEROIFNULL( OOSL.IN_PROC_QTY ) ) AS IN_PROC_QTY,
        ODC.QTY_UNIT_MEAS_ID,
        
        ODC.ORDER_TYPE_ID,
        ODC.ORDER_CAT_ID,
        MAX( CASE WHEN ODC.CANCEL_IND = 'Y' THEN 1 ELSE 0 END ) AS CANCEL_IND,
        MAX( CASE WHEN ODC.RETURN_IND = 'Y' THEN 1 ELSE 0 END ) AS RETURN_IND,
        ODC.PO_TYPE_ID,
        MAX( CASE WHEN ODC.DELIV_BLK_IND = 'Y' THEN 1 ELSE 0 END ) AS DELIV_BLK_IND,
        ODC.DELIV_BLK_CD,
        ODC.FACILITY_ID,
        ODC.SHIP_PT_ID,
        ODC.REJ_REAS_ID,
        ODC.ORDER_REAS_CD,
        ODC.SPCL_PROC_ID
    
    FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
    
        LEFT OUTER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
            ON OOSL.ORDER_ID = ODC.ORDER_ID
            AND OOSL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
            AND OOSL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
        
        LEFT OUTER JOIN (
                SELECT
                    R.ORDER_ID,
                    R.ORDER_LINE_NBR,
                    COUNT( DISTINCT CASE WHEN R.RESCHD_IND = 'Y' THEN R.ORDER_ID || R.ORDER_LINE_NBR || R.RESCHD_DT END ) AS RESCHD_CNT
                FROM NA_BI_VWS.ORD_RESCHD R
                WHERE
                    R.RESCHD_DT >= CAST( EXTRACT( YEAR FROM CURRENT_DATE ) - 1 || '-01-01' AS DATE ) 
                    AND R.ORIG_SYS_ID = 2
                    AND R.SBU_ID = 2
                GROUP BY
                    R.ORDER_ID,
                    R.ORDER_LINE_NBR
                ) RES
            ON RES.ORDER_ID = ODC.ORDER_ID
            AND RES.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
    
--    WHERE
--        ODC.ORDER_DT >= DATE '2014-01-01'
--        AND ODC.ORDER_DT <= DATE '2014-01-31'
    
    GROUP BY
        ODC.ORDER_ID,
        ODC.ORDER_LINE_NBR,
        OPEN_ORDER_CURR_IND,
        
        ODC.SHIP_TO_CUST_ID,
        ODC.SALES_ORG_CD,
        ODC.DISTR_CHAN_CD,
        ODC.CUST_GRP_ID,
        
        ODC.MATL_ID,
        
        ODC.ORDER_DT,
        ODC.CUST_RDD,
        ODC.FRST_RDD,
        ODC.FRST_MATL_AVL_DT,
        ODC.FRST_PLN_GOODS_ISS_DT,
        ODC.FRST_PROM_DELIV_DT,
    
        ODC.QTY_UNIT_MEAS_ID,
        
        ODC.ORDER_TYPE_ID,
        ODC.ORDER_CAT_ID,
        ODC.PO_TYPE_ID,
        ODC.DELIV_BLK_CD,
        ODC.FACILITY_ID,
        ODC.SHIP_PT_ID,
        ODC.REJ_REAS_ID,
        ODC.ORDER_REAS_CD,
        ODC.SPCL_PROC_ID 

    ) Q

    LEFT OUTER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
        ON DDC.ORDER_ID = Q.ORDER_ID
        AND DDC.ORDER_LINE_NBR = Q.ORDER_LINE_NBR
        AND DDC.DELIV_QTY > 0

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = Q.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = Q.SHIP_TO_CUST_ID
        AND CUST.OWN_CUST_ID = '00A0009337'        

QUALIFY
    ROW_NUMBER( ) OVER ( PARTITION BY Q.ORDER_ID, Q.ORDER_LINE_NBR ORDER BY NULL ) = 1    