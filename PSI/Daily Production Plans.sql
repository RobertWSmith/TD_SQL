﻿-- HISTORICAL PLANS

SELECT
    CAST('P' AS CHAR(1)) AS QUERY_TYPE
    , C.POSTED_DT AS DAY_DATE
    , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
    , PP.PLN_MATL_ID AS MATL_ID
    , PP.FACILITY_ID
    , CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3)) AS QUANTITY

FROM GDYR_VWS.PROD_PLN PP

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = PP.PLN_MATL_ID
        AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08','09')
    
    INNER JOIN GDYR_VWS.FACILITY F
        ON F.FACILITY_ID = PP.FACILITY_ID
        AND F.EXP_DT = DATE '5555-12-31'
        AND F.ORIG_SYS_ID = 2
        AND F.LANG_ID = 'EN'
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
        ON C.MEAS_DT = PP.PROD_WK_DT
        AND C.FNL_PERDY_ID = 'D'
        AND C.PERDY_ID = 'W'
        AND C.EXP_DT = DATE '5555-12-31'
        --AND C.SBU_ID = 2
        -- ROLLING 6 MONTHS
        AND C.POSTED_DT >= ADD_MONTHS(CURRENT_DATE-1, -6) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -6)) - 1)

WHERE
    PP.PROD_PLN_CD IN ('0', '7')
    AND CAST(PP.PROD_WK_DT-3 AS DATE) BETWEEN PP.EFF_DT AND PP.EXP_DT
    AND PP.PROD_WK_DT <= CURRENT_DATE

UNION ALL

-- FUTURE WEEKS WITHIN PLANNER HORIZON
    
SELECT
    CAST('P' AS CHAR(1)) AS QUERY_TYPE
    , C.POSTED_DT AS DAY_DATE
    , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
    , PP.PLN_MATL_ID AS MATL_ID
    , PP.FACILITY_ID
    , CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3)) AS QUANTITY

FROM GDYR_VWS.PROD_PLN PP

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = PP.PLN_MATL_ID
        AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08','09')
    
    INNER JOIN GDYR_VWS.FACILITY F
        ON F.FACILITY_ID = PP.FACILITY_ID
        AND F.EXP_DT = DATE '5555-12-31'
        AND F.ORIG_SYS_ID = 2
        AND F.LANG_ID = 'EN'
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
        ON C.MEAS_DT = PP.PROD_WK_DT
        AND C.FNL_PERDY_ID = 'D'
        AND C.PERDY_ID = 'W'
        AND C.EXP_DT = DATE '5555-12-31'
        --AND C.SBU_ID = 2

WHERE
    PP.PROD_PLN_CD IN ('0', '7')
    AND PP.EXP_DT = DATE '5555-12-31'
    AND PP.PROD_WK_DT BETWEEN CURRENT_DATE+1 AND CURRENT_DATE+56

UNION ALL

-- PLAN CODE A, SNP PRODUCTION PLANS

SELECT
    CAST('P' AS CHAR(1)) AS QUERY_TYPE
    , C.POSTED_DT AS DAY_DATE
    , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
    , PP.PLN_MATL_ID AS MATL_ID
    , PP.FACILITY_ID
    , CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3)) AS QUANTITY

FROM GDYR_VWS.PROD_PLN PP

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = PP.PLN_MATL_ID
        AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08','09')
    
    INNER JOIN GDYR_VWS.FACILITY F
        ON F.FACILITY_ID = PP.FACILITY_ID
        AND F.EXP_DT = DATE '5555-12-31'
        AND F.ORIG_SYS_ID = 2
        AND F.LANG_ID = 'EN'
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
        ON C.MEAS_DT = PP.PROD_WK_DT
        AND C.FNL_PERDY_ID = 'D'
        AND C.PERDY_ID = 'W'
        AND C.EXP_DT = DATE '5555-12-31'
        --AND C.SBU_ID = 2

WHERE
    PP.PROD_PLN_CD = 'A'
    AND PP.EXP_DT = DATE '5555-12-31'
    AND PP.PROD_WK_DT > CURRENT_DATE+56
    -- ROLLING +6 MONTHS
    AND C.POSTED_DT <= ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))