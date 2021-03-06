﻿SELECT
    Q.ACTL_GOODS_ISS_WK
    , Q.ACTL_GOODS_ISS_MTH
    , Q.OWN_CUST_ID
    , Q.OWN_CUST
    , AVERAGE(Q.SHIP_TO_CUST_CNT) AS AVG_NONSIG_PER_BOL
    
    , COUNT(DISTINCT Q.BILL_LADING_ID) AS BILL_OF_LADING_CNT
    , SUM(Q.MATL_ID_CNT) AS MATL_ID_CNT
    , SUM(Q.DELIV_LINE_CNT) AS DELIV_LINE_CNT
    
    , Q.GROSS_WT_PER_BOL
    
    , Q.SALES_ORG
    , Q.TIRE_CUST_TYP_CD
    , Q.CUST_GRP2_CD
    , Q.SHIP_COND_ID
    
    , Q.QTY_UOM
    , SUM(Q.DELIVERY_QTY) AS DELIV_QTY
    , AVERAGE(Q.DELIVERY_QTY) AS AVG_DELIV_QTY_PER_BOL
    , PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Q.DELIVERY_QTY) AS MEDIAN_DELIV_QTY_PER_BOL
    
    , Q.WT_UOM
    , SUM(Q.GROSS_WEIGHT) AS GROSS_WT
    , AVERAGE(Q.GROSS_WEIGHT) AS AVG_GROSS_WT_PER_BOL
    , PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Q.GROSS_WEIGHT) AS MEDIAN_GROSS_WT_PER_BOL
    
    , Q.VOL_UOM
    , SUM(Q.VOL) AS VOL
    , SUM(Q.CMPR_VOL) AS COMPRESSED_VOL
    
FROM (

    SELECT
        DDC.BILL_LADING_ID
        , CAL.BEGIN_DT AS ACTL_GOODS_ISS_WK
        , CAL.MONTH_DT AS ACTL_GOODS_ISS_MTH
        
        , COUNT(DISTINCT DDC.MATL_ID) AS MATL_ID_CNT
        , COUNT(DISTINCT DDC.FISCAL_YR || DDC.DELIV_ID || DDC.DELIV_LINE_NBR) AS DELIV_LINE_CNT
        , COUNT(DISTINCT DDC.SHIP_TO_CUST_ID) AS SHIP_TO_CUST_CNT
        , CASE 
            WHEN GROSS_WEIGHT > 30000 
                THEN '30K+'
            WHEN GROSS_WEIGHT BETWEEN 20000 AND 30000
                THEN '20-30K'
            WHEN GROSS_WEIGHT BETWEEN 15000 AND 20000
                THEN '15-20K'
            WHEN GROSS_WEIGHT BETWEEN 10000 AND 15000
                THEN '10-15K'
            WHEN GROSS_WEIGHT BETWEEN 5000 AND 10000
                THEN '5-10K'
            WHEN GROSS_WEIGHT BETWEEN 2000 AND 5000
                THEN '2-5K'
            WHEN GROSS_WEIGHT < 2000
                THEN '0-2K'
            END AS GROSS_WT_PER_BOL
        , CASE
            WHEN GROSS_WEIGHT > 20000
                THEN 1
            WHEN GROSS_WEIGHT BETWEEN 10000 AND 20000
                THEN 2
            ELSE 3
            END AS TRUCKLOAD_RNK

        , DDC.SHIP_TO_CUST_ID
        
        , CUST.OWN_CUST_ID
        , CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS OWN_CUST
    	
    	, CUST.SALES_ORG_CD
    	, CUST.SALES_ORG_CD || ' - ' || CUST.SALES_ORG_NAME AS SALES_ORG
        
        , CUST.TIRE_CUST_TYP_CD
        
        , DDC.DELIV_LINE_FACILITY_ID AS FACILITY_ID
        , DDC.CUST_GRP2_CD
        , DDC.SHIP_COND_ID
        , DDC.PLN_GOODS_MVT_DT
        
        , CAST('EA' AS CHAR(3)) AS QTY_UOM
        , SUM(CASE 
            WHEN DDC.QTY_UNIT_MEAS_ID = 'LB'
                THEN DDC.DELIV_QTY / 100
            ELSE DDC.DELIV_QTY
            END) AS DELIVERY_QTY
        
        , CAST('LB' AS CHAR(3)) AS WT_UOM
        , SUM(CASE
            WHEN DDC.WT_UNIT_MEAS_ID = 'KG'
                THEN DDC.GROSS_WT * 2.20
            ELSE DDC.GROSS_WT
            END) AS GROSS_WEIGHT
        
        , CAST('FT3' AS CHAR(3)) AS VOL_UOM
        , SUM(DDC.VOL) AS VOL
        , SUM(CAST(CASE MATL.PBU_NBR || MATL.MKT_AREA_NBR
                WHEN '0101' THEN 0.75
                WHEN '0108' THEN 0.80
                WHEN '0305' THEN 1.20
                WHEN '0314' THEN 1.20
                WHEN '0406' THEN 1.20
                WHEN '0507' THEN 0.75
                WHEN '0711' THEN 0.75
                WHEN '0712' THEN 0.75
                WHEN '0803' THEN 1.20
                WHEN '0923' THEN 0.75
            ELSE 1
            END * MATL.UNIT_VOL * CASE 
            WHEN DDC.QTY_UNIT_MEAS_ID = 'LB'
                THEN DDC.DELIV_QTY / 100
            ELSE DDC.DELIV_QTY
            END AS DECIMAL(15,3))) AS CMPR_VOL
        
    FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
            ON MATL.MATL_ID = DDC.MATL_ID
            AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')
            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID
            AND CUST.PRIM_SHIP_FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
            AND CUST.OWN_CUST_ID NOT IN ('00A0003088', '00A0000632', '00A0003149', '00A0005538', '00A0004099')
            AND CUST.CUST_GRP2_CD <> 'TLB'

    WHERE
        DDC.DELIV_CAT_ID = 'J'
        AND DDC.GOODS_ISS_IND = 'Y'
        AND DDC.ACTL_GOODS_ISS_DT BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
        AND DDC.DISTR_CHAN_CD <> '81'
        AND DDC.DELIV_QTY > 0
        AND DDC.CUST_GRP2_CD NOT IN ('TLB', 'YDN')
        AND DDC.SALES_ORG_CD IN ('N301', 'N311')

    GROUP BY
        DDC.BILL_LADING_ID
        , CAL.BEGIN_DT
        , CAL.MONTH_DT
        , DDC.SHIP_TO_CUST_ID
        , CUST.OWN_CUST_ID
        , OWN_CUST
    	, CUST.SALES_ORG_CD
    	, SALES_ORG
        , CUST.TIRE_CUST_TYP_CD
        , DDC.DELIV_LINE_FACILITY_ID
        , DDC.CUST_GRP2_CD
        , DDC.SHIP_COND_ID
        , DDC.PLN_GOODS_MVT_DT
        , QTY_UOM
        , WT_UOM
        , VOL_UOM

    ) Q

GROUP BY
    Q.ACTL_GOODS_ISS_WK
    , Q.ACTL_GOODS_ISS_MTH
    , Q.OWN_CUST_ID
    , Q.OWN_CUST
    , Q.GROSS_WT_PER_BOL
    , Q.SALES_ORG
    , Q.TIRE_CUST_TYP_CD
    , Q.CUST_GRP2_CD
    , Q.SHIP_COND_ID
    , Q.QTY_UOM
    , Q.WT_UOM
    , Q.VOL_UOM

/*
QUALIFY
    COUNT(*) OVER (PARTITION BY CAL.MONTH_DT, Q.OWN_CUST_ID) > 1
*/

ORDER BY
    Q.OWN_CUST_ID
    , Q.ACTL_GOODS_ISS_WK

