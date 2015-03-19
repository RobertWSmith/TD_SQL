/*

Query Intention -- prove that no duplicates are produced in UNION ALL query

Query Results: PASS 2014-04-24

1	EDWTDPRD	2014-04-24  11:23:15		0		C:\Users\a421356\OneDrive for Business\Teradata Input\Validation for PSI - Production Plans Union.sql	Query saved to: 	101	0						286

*/

SELECT
    Q.BUS_DT,
    Q.MATL_ID,
    Q.FACILITY_ID,
    COUNT(*) OVER ( PARTITION BY Q.BUS_DT, Q.MATL_ID, Q.FACILITY_ID ) AS RECORD_CNT

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

    ) Q

QUALIFY
    RECORD_CNT > 1
    