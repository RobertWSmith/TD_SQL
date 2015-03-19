SELECT 
    B.MATL_ID,
    B.MOLD_INV_QTY,
    MAX(B.LVL_GRP_ID) AS MAX_LVL_GRP_ID, --mfg agg
    B.GRN_TIRE_CTGY_CD,
    B.FACILITY_ID,
    F.FACILITY_NAME
FROM NA_VWS.FACL_MATL_CYCASGN B

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M 
        ON M.MATL_ID = B.MATL_ID
        
    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F 
        ON F.FACILITY_ID = B.FACILITY_ID
        
WHERE 
    B.ORIG_SYS_ID = 2
    AND B.EXP_DT = CAST('5555-12-31' AS DATE)
    AND M.PBU_NBR = '01'
    AND (
        B.MATL_ID,
        EFF_DT,
        LVL_DESIGN_EFF_DT,
        B.FACILITY_ID
        ) IN (
        SELECT 
            MATL_ID,
            EFF_DT,
            LVL_DESIGN_EFF_DT,
            MAX(FACILITY_ID) AS MAX_FACILITY_ID
        FROM NA_VWS.FACL_MATL_CYCASGN        
        WHERE 
            ORIG_SYS_ID = 2
            AND EXP_DT = '5555-12-31'
            AND (
                MATL_ID,
                EFF_DT,
                LVL_DESIGN_EFF_DT
                ) IN (
                SELECT 
                    MATL_ID,
                    MAX(EFF_DT) AS MAX_EFF_DT,
                    LVL_DESIGN_EFF_DT
                FROM NA_VWS.FACL_MATL_CYCASGN
                WHERE 
                    ORIG_SYS_ID = 2
                    AND EXP_DT = '5555-12-31'
                    AND (
                        MATL_ID,
                        LVL_DESIGN_EFF_DT
                        ) IN (
                        SELECT 
                            MATL_ID,
                            MAX(LVL_DESIGN_EFF_DT) AS MAX_LVL_DESIGN_EFF_DT
                        FROM NA_VWS.FACL_MATL_CYCASGN
                        WHERE 
                            EXP_DT = '5555-12-31'
                            AND ORIG_SYS_ID = 2
                            AND LVL_DESIGN_STA_CD = 'A'
                        GROUP BY 
                            MATL_ID
                        )
                GROUP BY 
                    MATL_ID,
                    LVL_DESIGN_EFF_DT
                )
        GROUP BY 
            MATL_ID,
            EFF_DT,
            LVL_DESIGN_EFF_DT
        )
GROUP BY 
    B.MATL_ID,
    B.MOLD_INV_QTY,
    B.GRN_TIRE_CTGY_CD,
    B.FACILITY_ID,
    F.FACILITY_NAME
ORDER BY
    B.MATL_ID