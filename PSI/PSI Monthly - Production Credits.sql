/*
Daily Production Credits Query

Created: 2014-04-23

Validated against PSMS 2014-04-23 for PBU 01 and Facility N508 - Lawton -- aggregates within 1% of PSMS for the month of 2014-April

Aggregates daily credits into monthly buckets
*/

SELECT
    CAST( 'Credits' AS VARCHAR(25) ) AS QRY_TYP,
    CR.PROD_TYP,
    CR.BUS_MTH,
    CR.MATL_ID,
    CR.FACILITY_ID,
    CAST( NULL AS VARCHAR(18) ) AS LVL_GRP_ID,
    CR.PROD_QTY

FROM (

    SELECT
        PC.PROD_TYP,
        PC.BUS_MTH,
        PC.MATL_ID,
        PC.FACILITY_ID,
        SUM( PC.PROD_QTY ) AS PROD_QTY,
        PC.QTY_UOM

    FROM (

        SELECT
            CAST( CASE WHEN PCD.PROD_DT / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'History' END AS VARCHAR(25) ) AS PROD_TYP,
            PCD.PROD_DT AS BUS_DT,
            CAST( CASE
                WHEN CAL.DAY_DATE > CAL.BEGIN_DT
                    THEN CAL.BEGIN_DT + 1
                ELSE CAL.BEGIN_DT - 6
            END AS DATE ) AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,
            PCD.MATL_ID,
            PCD.FACILITY_ID,
            SUM( ZEROIFNULL( PCD.PROD_QTY ) ) AS PROD_QTY,
            PCD.QTY_UOM

        FROM GDYR_VWS.PROD_CREDIT_DY PCD

            INNER JOIN GDYR_VWS.GDYR_CAL CAL
                ON CAL.DAY_DATE = PCD.PROD_DT
                AND CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -12 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND ( CURRENT_DATE )

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = PCD.MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            PCD.PROD_DT BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -12 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND ( CURRENT_DATE )
            AND PCD.SBU_ID = 2
            AND PCD.SRC_SYS_ID = 2
            AND PCD.PROD_QTY > 0

        GROUP BY
            PROD_TYP,
            PCD.PROD_DT,
            BUS_WK, -- MONDAY INDEXED
            CAL.MONTH_DT,
            PCD.MATL_ID,
            PCD.FACILITY_ID,
            PCD.QTY_UOM

        ) PC

    GROUP BY
        PC.PROD_TYP,
        PC.BUS_MTH,
        PC.MATL_ID,
        PC.FACILITY_ID,
        PC.QTY_UOM

    ) CR
