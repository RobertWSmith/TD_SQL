-- Query returns Open Orders for COWD and their Route ID's
-- Last Update 2014-03-14
--  added Shipping Condition ID

SELECT
    OOSL.ORDER_ID AS "Order ID",
    OOSL.ORDER_LINE_NBR AS "Order Line Nbr",
    
    ODC.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.CUST_NAME AS "Ship To Customer Name",
    
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
    
    ODC.CUST_GRP_ID AS "Customer Group ID",
    ODC.ROUTE_ID AS "Route ID",
    CASE
        WHEN POSITION( 'D' IN ODC.ROUTE_ID ) <> 0
            THEN '"D" Present'
        WHEN NULLIF( ODC.ROUTE_ID, '' ) IS NULL
            THEN 'Missing'
        ELSE 'Numeric'
    END AS "Route ID Test",
    ODC.SHIP_PT_ID AS "Ship Point ID",
    ODC.FACILITY_ID AS "Facility ID",
    CUST.PRIM_SHIP_FACILITY_ID AS "Customer Primary Facility ID",
    CASE
        WHEN CUST.PRIM_SHIP_FACILITY_ID = ODC.FACILITY_ID
            THEN 'Same'
        ELSE 'Different'
    END AS "Customer Primary Facility Test",

    ODC.ORDER_DT AS "Order Create Date",
    /*SD.TERM_PAY_ID,*/
    ODC.SHIP_COND_ID AS "Shipping Condition ID"

FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
        ON ODC.ORDER_ID = OOSL.ORDER_ID
        AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
        AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
        --AND ODC.CUST_GRP_ID = '3R'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.PBU_NBR = '07'
    
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID

/*    LEFT OUTER JOIN GDYR_BI_VWS.NAT_SLS_DOC_CURR SD
        ON SD.SLS_DOC_ID = OOSL.ORDER_ID
        AND SD.EXP_DT = CAST( '5555-12-31' AS DATE )
        AND SD.ORIG_SYS_ID = 2
        AND SD.SBU_ID = 2
*/
GROUP BY
    OOSL.ORDER_ID,
    OOSL.ORDER_LINE_NBR,
    
    ODC.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    PBU,
    
    ODC.CUST_GRP_ID,
    ODC.ROUTE_ID,
    "Route ID Test",   
    ODC.SHIP_PT_ID,
    ODC.FACILITY_ID,
    CUST.PRIM_SHIP_FACILITY_ID,
    "Customer Primary Facility Test",
    
    ODC.ORDER_DT,

    ODC.SHIP_COND_ID

ORDER BY
    ( CASE WHEN "Route ID Test" = 'Numeric' THEN 100 WHEN "Route ID Test" = 'Missing' THEN 50 ELSE 0 END ),
    ( CASE WHEN "Customer Primary Facility Test" = 'Same' THEN 0 ELSE 100 END ),
    OOSL.ORDER_ID,
    OOSL.ORDER_LINE_NBR