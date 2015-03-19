/*
PSI Monthly - Source Facility

Created: 2014-04-23

Acquires the official Source Facility ID for a given Material ID on a given Business / Production Month
*/

SELECT
    CAL.MONTH_DT
    , FM.FACILITY_ID
    , FM.MATL_ID
    , CAST(CASE FM.SPCL_PRCU_TYP_CD
        WHEN 'AA' then 'N501' 
        WHEN 'AB' then 'N502' 
        WHEN 'AC' then 'N503' 
        WHEN 'AD' then 'N504' 
        WHEN 'AE' then 'N505' 
        WHEN 'AF' then 'N506' 
        WHEN 'AH' then 'N508' 
        WHEN 'AI' then 'N509' 
        WHEN 'AJ' then 'N510' 
        WHEN 'AM' then 'N513' 
        WHEN 'AS' then 'N603' 
        WHEN 'CA' then 'N5CA' 
        WHEN 'CC' then 'N518' 
        WHEN 'NR' then 'N638' 
        WHEN 'S1' then 'N6BD' 
        WHEN 'S2' then 'N6BE' 
        WHEN 'S3' then 'N6BF' 
        WHEN 'S4' then 'N6BS' 
        WHEN 'S6' then 'N6J2' 
        WHEN 'S7' then 'N6J3' 
        WHEN 'S8' then 'N6J4' 
        WHEN 'S9' then 'N6J7' 
        WHEN 'SA' then 'N526' 
        WHEN 'SC' then 'N6A1' 
        WHEN 'SD' then 'N6A2' 
        WHEN 'SE' then 'N6A3' 
        WHEN 'SF' then 'N6A4' 
        WHEN 'SG' then 'N6A6' 
        WHEN 'SH' then 'N6A8' 
        WHEN 'SJ' then 'N6AA' 
        WHEN 'SM' then 'N6AE' 
        WHEN 'SN' then 'N6AG' 
        WHEN 'SO' then 'N6AH' 
        WHEN 'SP' then 'N6AJ' 
        WHEN 'SQ' then 'N6AK' 
        WHEN 'SR' then 'N6AL' 
        WHEN 'SS' then 'N6J8' 
        WHEN 'ST' then 'N6AO' 
        WHEN 'SU' then 'N6AQ' 
        WHEN 'SV' then 'N6AR' 
        WHEN 'SW' then 'N6AS' 
        WHEN 'SX' then 'N6AT' 
        WHEN 'SY' then 'N6AX' 
        WHEN 'SZ' then 'N6BB' 
        WHEN 'US' then 'N5US' 
        WHEN 'WA' then 'N637' 
        WHEN 'WD' then 'N6D3' 
        WHEN 'WH' then 'N699' 
        WHEN 'WL' then 'N607' 
        ELSE COALESCE(FMX.FACILITY_ID, FM.SPCL_PRCU_TYP_CD)
        END AS CHAR(4)) AS SRC_FACILITY_ID

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN GDYR_VWS.FACILITY_MATL FM
        ON CAL.DAY_DATE BETWEEN FM.EFF_DT AND FM.EXP_DT
        AND FM.ORIG_SYS_ID = 2
        AND FM.MRP_TYPE_ID = 'XB'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = FM.MATL_ID
        AND M.PBU_NBR = '01'
        --AND M.PBU_NBR IN ('01', '03')
        AND M.EXT_MATL_GRP_ID = 'TIRE'

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR F
        ON F.FACILITY_ID = FM.FACILITY_ID
        AND F.ORIG_SYS_ID = FM.ORIG_SYS_ID
        AND F.LANG_ID = 'EN'
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    LEFT OUTER JOIN GDYR_VWS.FACILITY_MATL FMX
        ON CAL.DAY_DATE BETWEEN FMX.EFF_DT AND FMX.EXP_DT
        AND FMX.MATL_ID = FM.MATL_ID
        AND FMX.ORIG_SYS_ID = FM.ORIG_SYS_ID
        AND FMX.MRP_TYPE_ID = 'X0'

WHERE
    CAL.DAY_DATE = CAL.MONTH_DT
    AND CAL.DAY_DATE BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE) AND CURRENT_DATE-1

GROUP BY
    CAL.MONTH_DT
    , FM.FACILITY_ID
    , FM.MATL_ID
    , SRC_FACILITY_ID
