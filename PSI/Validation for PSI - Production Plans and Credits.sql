/*
Validation for PSI - Production Plans & Credits

Created: 2014-04-24

Confirmed against 2014-March for N508 - Lawton & PBU 01 - Consumer.

Current Query Aggregate:
Plan: 1,968,342
Credit: 1,892,246

PSMS for Lawton for Month of March 2014
Plan: 1,965.3 * 1,000 = 1,965,300
Credit: 1,888.1	* 1,000 = 1,888,100

Difference:
Plan: 1,968,342 - 1,965,300 = 3,042 Units 
Credit: 1,892,246 - 1,888,100 = -4,146 Units

Percent Difference:
Query Plan: 0.15%
PSMS Plan: 0.15%
Query Credit: 0.22%
PSMS Credit: 0.22%
*/

SELECT
    PPC.PLN_TYP,
    PPC.BUS_DT,
    PPC.BUS_WK,
    PPC.BUS_MTH,
    PPC.MATL_ID,
    PPC.FACILITY_ID,
    SUM( CASE WHEN PPC.QRY_TYP = 'Production Plan' THEN PPC.PLN_QTY ELSE 0 END ) AS PLAN_QTY,
    SUM( CASE WHEN PPC.QRY_TYP = 'Production Credit' THEN PPC.PLN_QTY ELSE 0 END ) AS CREDIT_QTY

FROM (

    SELECT
        CAST( 'Production Plan' AS VARCHAR(25)) AS QRY_TYP,
        CAST( CASE WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'History' END AS VARCHAR(25) ) AS PLN_TYP,
        CAL.DAY_DATE AS BUS_DT,
        PP.PROD_WK_DT AS BUS_WK,
        CAL.MONTH_DT AS BUS_MTH,
        PP.PLN_MATL_ID AS MATL_ID,
        PP.FACILITY_ID,
        CASE
            WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                THEN ( CASE
                    WHEN ( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                        THEN CEIL( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                    ELSE FLOOR( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                END )
            ELSE CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000
        END AS PLN_QTY

    FROM GDYR_VWS.GDYR_CAL CAL

        INNER JOIN GDYR_VWS.PROD_PLN PP
            ON CAL.DAY_DATE BETWEEN PP.PROD_WK_DT AND CAST( PP.PROD_WK_DT + 6 AS DATE )
            AND CAST( PP.PROD_WK_DT - 3 AS DATE ) BETWEEN PP.EFF_DT AND PP.EXP_DT
            AND PP.PROD_PLN_CD = '0'
            AND PP.SBU_ID = 2

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = PP.PLN_MATL_ID
            AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

    WHERE
        CAL.DAY_DATE BETWEEN
            CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )
            AND
            (
                SELECT
                    MAX( PROD_WK_DT ) + 6 AS END_OF_CURRENT_PROD_WK
                FROM GDYR_VWS.PROD_PLN
                WHERE
                    SBU_ID = 2
                    AND PROD_PLN_CD = '0'
                    AND PROD_WK_DT < CURRENT_DATE
            )

    UNION ALL

    SELECT
        CAST( 'Production Plan' AS VARCHAR(25)) AS QRY_TYP,
        CAST( CASE WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'Future' END AS VARCHAR(25) ) AS PLN_TYP,
        CAL.DAY_DATE AS BUS_DT,
        PP.PROD_WK_DT AS BUS_WK,
        CAL.MONTH_DT AS BUS_MTH,
        PP.PLN_MATL_ID AS MATL_ID,
        PP.FACILITY_ID,
        CASE
            WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                THEN ( CASE
                    WHEN ( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                        THEN CEIL( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                    ELSE FLOOR( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                END )
            ELSE CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000
        END AS PLN_QTY

    FROM GDYR_VWS.GDYR_CAL CAL

        INNER JOIN GDYR_VWS.PROD_PLN PP
            ON CAL.DAY_DATE BETWEEN PP.PROD_WK_DT AND CAST( PP.PROD_WK_DT + 6 AS DATE )
            AND PP.EXP_DT = CAST( '5555-12-31' AS DATE )
            AND PP.SBU_ID = 2

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = PP.PLN_MATL_ID
            AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

    WHERE
        CAL.DAY_DATE BETWEEN (
                SELECT
                    MIN( PP.PROD_WK_DT ) AS BEGIN_OF_NEXT_WK
                FROM GDYR_VWS.PROD_PLN PP
                WHERE
                    PP.PROD_PLN_CD = '0'
                    AND PP.SBU_ID = 2
                    AND PP.PROD_WK_DT > CURRENT_DATE
            ) AND
        ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 25 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- END MONTH FOR OF +12 MONTHS
        AND PP.PROD_PLN_CD = (
            CASE
                WHEN  CAL.DAY_DATE > ( SELECT ( BEGIN_DT + 7 ) + ( 7 * 7 ) FROM GDYR_BI_VWS.GDYR_CAL WHERE CAL.DAY_DATE = CURRENT_DATE )
                    THEN 'A'
                ELSE '0'
            END
        )

    UNION ALL

    SELECT
        CAST( 'Production Credit' AS VARCHAR(25) ) AS QRY_TYP,
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
        SUM( ZEROIFNULL( CASE WHEN PCD.PROD_QTY > 0 THEN PCD.PROD_QTY END ) ) AS PROD_QTY

    FROM GDYR_VWS.PROD_CREDIT_DY PCD

        INNER JOIN GDYR_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = PCD.PROD_DT
            AND CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND CURRENT_DATE

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = PCD.MATL_ID
            AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

    WHERE
        PCD.PROD_DT >= CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )
        AND PCD.SBU_ID = 2
        AND PCD.SRC_SYS_ID = 2

    GROUP BY
        QRY_TYP,
        PROD_TYP,
        PCD.PROD_DT,
        BUS_WK,
        CAL.MONTH_DT,
        PCD.MATL_ID,
        PCD.FACILITY_ID

    ) PPC

WHERE
    PPC.MATL_ID IN ( SELECT MATL_ID FROM GDYR_BI_VWS.NAT_MATL_HIER_dESCR_EN_CURR WHERE PBU_NBR = '01' )
    AND PPC.FACILITY_ID = 'N508'
    AND PPC.BUS_MTH = DATE '2014-03-01'

GROUP BY
    PPC.PLN_TYP,
    PPC.BUS_DT,
    PPC.BUS_WK,
    PPC.BUS_MTH,
    PPC.MATL_ID,
    PPC.FACILITY_ID

HAVING
    PLAN_QTY > 0 OR CREDIT_QTY > 0

-- SAMPLE 1000;