/*
PSI Monthly - Level Design

Created: 2014-04-23

Monthly Level Design per Facility ID

NOTE: max( Level Design ) is applied to deduplicate records. Count of Distinct Active Level Designs also provided for reference
*/

SELECT
    SLD.PLN_TYP,
    CAST( 'Source' AS VARCHAR(25) ) AS QRY_TYP,
    SLD.BUS_MTH,
    SLD.MATL_ID,
    SLD.FACILITY_ID,
    MAX( SLD.LVL_GRP_ID ) AS LVL_GRP_ID,
    MAX( SLD.LVL_GRP_ID_CNT ) AS LVL_GRP_ID_CNT

FROM (

    SELECT
        LD.PLN_TYP,
        LD.BUS_MTH,

        LD.MATL_ID,
        LD.FACILITY_ID,
        MAX( LD.LVL_GRP_ID ) AS LVL_GRP_ID,
        CAST( COUNT( DISTINCT LD.LVL_GRP_ID ) AS DECIMAL(15,3) ) AS LVL_GRP_ID_CNT

    FROM (

        SELECT
            CAST( CASE
                WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100
                    THEN 'Current Month'
                WHEN CAL.DAY_DATE / 100 > CURRENT_DATE / 100
                    THEN 'Future'
                WHEN CAL.DAY_DATE / 100 < CURRENT_DATE / 100
                    THEN 'History'
            END AS VARCHAR(25) ) AS PLN_TYP,
            CAL.DAY_DATE AS BUS_DT,
            CAST( CASE
                WHEN CAL.DAY_DATE > CAL.BEGIN_DT
                    THEN CAL.BEGIN_DT + 1
                ELSE CAL.BEGIN_DT - 6
            END AS DATE ) AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,

            FMC.LVL_DESIGN_EFF_DT,
            FMC.MATL_ID,
            FMC.FACILITY_ID,
            FMC.LVL_GRP_ID

        FROM GDYR_BI_VWS.GDYR_CAL CAL

            INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                AND CAL.DAY_DATE >= FMC.LVL_DESIGN_EFF_DT
                AND FMC.LVL_DESIGN_STA_CD = 'A'
                AND FMC.SBU_ID = 2

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = FMC.MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -12 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND
                ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 13 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- END OF 12TH MONTH

        GROUP BY
            PLN_TYP,
            CAL.DAY_DATE,
            BUS_WK,
            CAL.MONTH_DT,

            FMC.LVL_DESIGN_EFF_DT,
            FMC.MATL_ID,
            FMC.FACILITY_ID,
            FMC.LVL_GRP_ID

        QUALIFY
            FMC.LVL_DESIGN_EFF_DT = MAX( FMC.LVL_DESIGN_EFF_DT ) OVER ( PARTITION BY CAL.DAY_DATE, FMC.MATL_ID, FMC.FACILITY_ID )

        ) LD

    GROUP BY
        LD.PLN_TYP,
        LD.BUS_MTH,
        LD.MATL_ID,
        LD.FACILITY_ID

    UNION ALL

    /*
    PSI Monthly - Source Facility

    Created: 2014-04-23

    Acquires the official Source Facility ID for a given Material ID on a given Business / Production Month
    */

    SELECT
        SF.PLN_TYP,
        SF.BUS_MTH,
        SF.MATL_ID,
        SF.SRC_FACILITY_ID,
        CAST( NULL AS VARCHAR(18) ) AS LVL_GRP_ID,
        CAST( NULL AS DECIMAL(15,3) ) AS LVL_GRP_ID_CNT

    FROM (

        SELECT
            CAST( CASE
                WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100
                    THEN 'Current Month'
                WHEN CAL.DAY_DATE / 100 > CURRENT_DATE / 100
                    THEN 'Future'
                WHEN CAL.DAY_DATE / 100 < CURRENT_DATE / 100
                    THEN 'History'
            END AS VARCHAR(25) ) AS PLN_TYP,
            CAL.DAY_DATE AS BUS_DT,
            CAST( CASE
                WHEN CAL.DAY_DATE > CAL.BEGIN_DT
                    THEN CAL.BEGIN_DT + 1
                ELSE CAL.BEGIN_DT - 6
            END AS DATE ) AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,

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

        FROM GDYR_BI_VWS.GDYR_CAL CAL

            INNER JOIN GDYR_VWS.FACILITY_MATL FM
                ON CAL.DAY_DATE BETWEEN FM.EFF_DT AND FM.EXP_DT
                AND FM.MRP_TYPE_ID IN ( 'X0', 'XB', 'XF', 'X1' )
                AND FM.SPCL_PRCU_TYP_CD IN ( 'AA', 'AB', 'AC', 'AD', 'AE', 'AH', 'AI', 'AJ', 'S1', 'S2', 'S4', 'S6', 'S7', 'S8',
                                                                            'S9', 'SA', 'SC', 'SD', 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ', 'SL', 'SM', 'SN', 'SO',
                                                                            'SQ', 'SR', 'SS', 'ST', 'SU', 'SV', 'SW', 'SX', 'SY', 'SZ' )

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = FM.MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -12 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND
                ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 13 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- END OF 12TH MONTH

        GROUP BY
            PLN_TYP,
            CAL.DAY_DATE,
            BUS_WK,
            CAL.MONTH_DT,
            FM.MATL_ID,
            SRC_FACILITY_ID

        ) SF

    GROUP BY
        SF.PLN_TYP,
        SF.BUS_MTH,
        SF.MATL_ID,
        SF.SRC_FACILITY_ID,
        LVL_GRP_ID,
        LVL_GRP_ID_CNT

    ) SLD

GROUP BY
    SLD.PLN_TYP,
    QRY_TYP,
    SLD.BUS_MTH,
    SLD.MATL_ID,
    SLD.FACILITY_ID