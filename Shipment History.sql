SELECT
    C.SALES_ORG_CD || ' - ' || C.SALES_ORG_NAME AS "Sales Org"
    , DDC.DELIV_LINE_FACILITY_ID || ' - ' || F.FACILITY_NAME AS "Ship From Facility"

    , C.POSTAL_CD AS "Ship To Postal Code"

    , CAL.WEEK_OF_YEAR_ISO AS "Planned Delivery Date Week of Year"
    , DDC.WT_UNIT_MEAS_ID AS "Weight Unit of Measure"
    , SUM(DDC.GROSS_WT) AS "Gross Wt"
    , DDC.VOL_UNIT_MEAS_ID AS "Volume Unit of Measure"
    , SUM(DDC.VOL) AS "Volume"
    , COUNT(DISTINCT DDC.SHIP_TO_CUST_ID) AS "Count of Ship To Locations"
    , COUNT(DISTINCT DDC.TRANSP_VEH_NO) AS "Count of Containers"
    
FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DDC.DELIV_DT

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

WHERE
    DDC.DELIV_CAT_ID = 'J'
    AND DDC.SD_DOC_CTGY_CD = 'C'
    AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
    AND DDC.ACTL_GOODS_ISS_DT >= ADD_MONTHS(CURRENT_DATE-1, -3)
    AND DDC.DELIV_QTY > 0

GROUP BY
    "Sales Org"
    , "Ship From Facility"

    , "Ship To Postal Code"

    , "Planned Delivery Date Week of Year"
    , DDC.WT_UNIT_MEAS_ID
    , DDC.VOL_UNIT_MEAS_ID

ORDER BY
    1,2,3,4
