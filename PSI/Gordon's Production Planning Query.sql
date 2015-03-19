SELECT M.PBU_NBR,
    FD.FINISH_TIRE_FD_NBR,
    M.TIC_CD,
    M.MATL_ID,
    M.DESCR,
    M.STK_CLASS_ID,
    M.UNIT_WT,
    M.EXT_MATL_GRP_ID,
    MC.MKT_AREA_NBR,
    MC.MKT_AREA_NAME,
    MC.MKT_GRP_NBR,
    MC.MKT_GRP_NAME,
    M.BRAND_ID,
    B.MKT_BRAND_NAME,
    PLAN_UNION.FACILITY_ID,
    PLAN_UNION.MONTH_DT,
    SUM(MONTH_PLN_QTY) AS PLN_QTY,
    sum(MONTH_PLN_QTY * m.UNIT_WT) AS PLANWGT
FROM
    -- Weekly planning data assigned to desired month based on date of first day of the week and the last
    (
    SELECT PLN_MATL_ID,
        FACILITY_ID,
        PROD_PLN_CD,
        BEG_MONTH_DT AS MONTH_DT,
        EXP_DT,
        BEG_MONTH_PLN_QTY AS MONTH_PLN_QTY
    FROM (
        SELECT
            -- Compute amount of plan to allocate the month of the week begin date and the month of the week end date
            PLN_MATL_ID,
            FACILITY_ID,
            PROD_PLN_CD,
            PROD_WK_DT,
            PLN_QTY,
            EXP_DT,
            -- Attributes to apportion to overlapping months
            EXTRACT(MONTH FROM PROD_WK_DT) AS BEG_MONTH,
            EXTRACT(DAY FROM PROD_WK_DT) AS BEG_DAY,
            EXTRACT(MONTH FROM PROD_WK_DT + 6) AS END_MONTH,
            EXTRACT(DAY FROM PROD_WK_DT + 6) AS END_DAY,
            PROD_WK_DT - BEG_DAY + 1 AS BEG_MONTH_DT,
            PROD_WK_DT + 6 - END_DAY + 1 AS END_MONTH_DT,
            -- Compute beginning week month and ending week month contributions based on days in each month for the week
            CAST((PLN_QTY * CAST((END_MONTH + BEG_MONTH) MOD 2 AS INT) * (END_DAY / 7.0000) ) AS INT) AS END_MONTH_PLN_QTY,
            PLN_QTY - END_MONTH_PLN_QTY AS BEG_MONTH_PLN_QTY
        FROM GDYR_VWS.PROD_PLN
        WHERE SBU_ID = 2 AND EXP_DT = '5555-12-31'
            --  and
            --  FACILITY_ID = 'N504'
            AND ((PROD_PLN_CD = '0' AND PROD_WK_DT <= DATE + 28) OR (PROD_PLN_CD = 'A' AND PROD_WK_DT > DATE + 28)
                )
        ) PLAN_DATA
    
    UNION ALL
    
    SELECT PLN_MATL_ID,
        FACILITY_ID,
        PROD_PLN_CD,
        END_MONTH_DT AS MONTH_DT,
        EXP_DT,
        END_MONTH_PLN_QTY AS MONTH_PLN_QTY
    FROM (
        SELECT
            -- Compute amount of plan to allocate the the month of the week begin date and the month of the week end date
            PLN_MATL_ID,
            FACILITY_ID,
            PROD_PLN_CD,
            PROD_WK_DT,
            PLN_QTY,
            EXP_DT,
            -- Attributes to apportion to overlapping months
            EXTRACT(MONTH FROM PROD_WK_DT) AS BEG_MONTH,
            EXTRACT(DAY FROM PROD_WK_DT) AS BEG_DAY,
            EXTRACT(MONTH FROM PROD_WK_DT + 6) AS END_MONTH,
            EXTRACT(DAY FROM PROD_WK_DT + 6) AS END_DAY,
            PROD_WK_DT - BEG_DAY + 1 AS BEG_MONTH_DT,
            PROD_WK_DT + 6 - END_DAY + 1 AS END_MONTH_DT,
            -- Compute beginning week month and ending week month contributions based on days in each month for the week
            CAST((PLN_QTY * CAST((END_MONTH + BEG_MONTH) MOD 2 AS INT) * (END_DAY / 7.0000)
                    ) AS INT) AS END_MONTH_PLN_QTY,
            PLN_QTY - END_MONTH_PLN_QTY AS BEG_MONTH_PLN_QTY
        FROM GDYR_VWS.PROD_PLN
        WHERE SBU_ID = 2 AND EXP_DT = '5555-12-31' AND
            --  FACILITY_ID = 'N504'
            --  and
            ((PROD_PLN_CD = '0' AND PROD_WK_DT <= DATE + 28) OR (PROD_PLN_CD = 'A' AND PROD_WK_DT > DATE + 28))
        ) PLAN_DATA
    ) PLAN_UNION

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = PLN_MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_MKT_BRAND_EN_CURR B
        ON M.BRAND_ID = B.BRAND_ID

    LEFT JOIN GDYR_VWS.FINISH_TIRE_XREF FD
        ON FD.MATL_ID = PLN_MATL_ID AND FD.FACILITY_ID = PLAN_UNION.FACILITY_ID AND FD.EXP_DT = PLAN_UNION.EXP_DT

    LEFT JOIN GDYR_BI_VWS.NAT_MKT_CTGY_MATL_HIER MC
        ON MC.MATL_ID = M.MATL_ID

WHERE 
    MONTH_DT >= DATE - 31 
    AND PLAN_UNION.FACILITY_ID IN ('N501', 'N502', 'N503', 'N504', 'N505', 'N508', 'N509', 'N510', 'N526', 'N513', 'N518')

GROUP BY 
    M.PBU_NBR,
    FD.FINISH_TIRE_FD_NBR,
    M.TIC_CD,
    M.MATL_ID,
    M.DESCR,
    M.STK_CLASS_ID,
    M.UNIT_WT,
    M.EXT_MATL_GRP_ID,
    MC.MKT_AREA_NBR,
    MC.MKT_AREA_NAME,
    MC.MKT_GRP_NBR,
    MC.MKT_GRP_NAME,
    M.BRAND_ID,
    B.MKT_BRAND_NAME,
    PLAN_UNION.FACILITY_ID,
    PLAN_UNION.MONTH_DT

ORDER BY 
    1,
    2,
    3,
    4,
    13
