/*
Future & Historical Production Plan Union

Created: 2014-04-23

Breaks production plans into daily units -- round function applied to TIRE to avoid fractional tires
Union combines historical & future daily data into one set of values

Update: 2014-04-24
-> Apply updates from Production Plans - Future & History Lag 0
-> Remove commented code from Production Plans SQL -- Useful later -- see

Update: 2014-05-06
-> Apply update after identifying that the prod plan zero to A switch was not occurring properly
*/


SELECT
    F.POSTED_DT
    , PP.PROD_WK_DT
    , PP.FACILITY_ID
    , PP.PLN_MATL_ID AS MATL_ID
    , ZEROIFNULL(PP.PLN_QTY) / CAST(7 AS DECIMAL(15,3)) AS PLAN_QTY

FROM GDYR_VWS.PROD_PLN PP

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = PP.PLN_MATL_ID
        AND M.PBU_NBR IN ('01', '03')
        AND M.EXT_MATL_GRP_ID = 'TIRE'

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR F
        ON F.MEAS_DT = PP.PROD_WK_DT
        AND F.FNL_PERDY_ID = 'D'
        AND F.PERDY_ID = 'W'
        AND F.EXP_DT = DATE '5555-12-31'

WHERE
    PP.SBU_ID = 2
    AND PP.PROD_PLN_CD = '0'
    AND CAST(PP.PROD_WK_DT-3 AS DATE) BETWEEN PP.EFF_DT AND PP.EXP_DT
    AND F.POSTED_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE) AND CURRENT_DATE + 56

UNION ALL

SELECT
    F.POSTED_DT
    , PP.PROD_WK_DT
    , PP.FACILITY_ID
    , PP.PLN_MATL_ID AS MATL_ID
    , ZEROIFNULL(PP.PLN_QTY) / CAST(7 AS DECIMAL(15,3)) AS PLAN_QTY

FROM GDYR_VWS.PROD_PLN PP

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = PP.PLN_MATL_ID
        AND M.PBU_NBR IN ('01', '03')
        AND M.EXT_MATL_GRP_ID = 'TIRE'

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR F
        ON F.MEAS_DT = PP.PROD_WK_DT
        AND F.FNL_PERDY_ID = 'D'
        AND F.PERDY_ID = 'W'
        AND F.EXP_DT = DATE '5555-12-31'

WHERE
    PP.SBU_ID = 2
    AND PP.PROD_PLN_CD = 'A'
    AND CAST(PP.PROD_WK_DT-3 AS DATE) BETWEEN PP.EFF_DT AND PP.EXP_DT
    AND F.POSTED_DT BETWEEN CURRENT_DATE + 57 AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))


