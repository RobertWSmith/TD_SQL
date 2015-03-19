SELECT
    CAL.MONTH_DT AS "FCDD Complete Month",
    POL.PBU_NBR AS "PBU Number",
    
/*    CASE
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 <= 0
            THEN '0 Weeks' 
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 BETWEEN 1 AND 2
            THEN '1-2 Weeks'
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 BETWEEN 3 AND 4
            THEN '3-4 Weeks'
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 BETWEEN 5 AND 6
            THEN '5-6 Weeks'
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 BETWEEN 7 AND 8
            THEN '7-8 Weeks'
        ELSE '9+ Weeks'
    END AS "Order Date to FCDD",*/
    
    CASE
        WHEN CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) < 0
            THEN '0-2 Weeks'
        WHEN CAST( CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 AS INTEGER ) > 8
            THEN '9+ Weeks'
        ELSE CAST( CAST( CAST( POL.FRST_PROM_DELIV_DT - POL.ORDER_DT AS INTEGER ) / 7 AS INTEGER ) AS CHAR(1) ) || '  Weeks'
    END AS "Order Date to FCDD",

    SUM( POL.PRFCT_ORD_FPDD_HIT_QTY ) AS "FCDD - Late Qty",
    SUM( POL.PRFCT_ORD_FPDD_QTY ) AS "FCDD - On Time Qty",
    "FCDD - Late Qty" + "FCDD - On Time Qty" AS "Total Ordered Qty"

FROM NA_BI_VWS.PRFCT_ORD_LINE POL

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = POL.FPDD_CMPL_DT
        AND CAL.DAY_DATE BETWEEN CAST( ( EXTRACT( YEAR FROM CURRENT_DATE ) - 1 ) || '-01-01' AS DATE ) AND ( CURRENT_DATE - 1 ) 

WHERE
    POL.FPDD_CMPL_DT BETWEEN CAST( ( EXTRACT( YEAR FROM CURRENT_DATE ) - 1 ) || '-01-01' AS DATE ) AND ( CURRENT_DATE - 1 ) 
    AND POL.FRST_PROM_DELIV_DT IS NOT NULL
    AND POL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )
    AND POL.FPDD_CMPL_IND = 1
    AND POL.ORIG_SYS_ID =2
    AND POL.SBU_ID = 2
    AND POL.SHIP_TO_CUST_ID IN ( 
        SELECT
            C.SHIP_TO_CUST_ID
        FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        WHERE
            C.CUST_GRP_ID <> '3R'
            AND C.SHIP_OR_CNCL_CD IS NULL
            AND C.SALES_ORG_CD NOT IN ( 'N302', 'N312', 'N322' )
        )
    AND POL.MATL_ID IN (
        SELECT
            M.MATL_ID
        FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        WHERE
            M.EXT_MATL_GRP_ID = 'TIRE'
            AND M.PBU_NBR = '01'
        )        

GROUP BY
    CAL.MONTH_DT,
    "PBU Number",
    "Order Date to FCDD"

HAVING
     "Total Ordered Qty" > 0

ORDER BY
    CAL.MONTH_DT,
    "PBU Number",
    "Order Date to FCDD"