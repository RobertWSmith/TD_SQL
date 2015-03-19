SELECT
    fmc.matl_id,
    fmc.facility_id,
    MAX(fmc.lvl_grp_id) AS lvl_grp_id,
    COUNT(DISTINCT fmc.lvl_grp_id) (DECIMAL(15,3)) AS lvl_grp_cnt

FROM na_vws.facl_matl_cycasgn fmc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr m
        ON m.matl_id = fmc.matl_id
        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND m.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN (
            SELECT
                f.matl_id,
                f.facility_id,
                MAX(f.lvl_design_eff_dt) AS max_ld_eff_dt
            FROM na_vws.facl_matl_cycasgn f
            WHERE
                f.exp_dt = CAST('5555-12-31' AS DATE)
                AND (CURRENT_DATE-1) >= f.lvl_design_eff_dt
                AND f.lvl_design_sta_cd = 'A'
                AND f.sbu_id = 2
                AND f.orig_sys_id = 2
                AND f.src_sys_id = 2
            GROUP BY
                f.matl_id,
                f.facility_id
            ) lim
        ON lim.matl_id = fmc.matl_id
        AND lim.facility_id = fmc.facility_id
        AND lim.max_ld_eff_dt = fmc.lvl_design_eff_dt

WHERE
    fmc.exp_dt = CAST('5555-12-31' AS DATE)
    AND (CURRENT_DATE-1) >= fmc.lvl_design_eff_dt
    AND fmc.lvl_design_sta_cd = 'A'
    AND fmc.sbu_id = 2
    AND fmc.orig_sys_id = 2
    AND fmc.src_sys_id = 2

GROUP BY
    fmc.matl_id,
    fmc.facility_id