/*
PSI - Level Design

Created: 2014-04-23

Daily Level Design per Facility ID

Update: 2014-04-24
-> Updated method of handling multiple active level designs on a given production date. Currently selects the first level design when sorted in ascending order. Additionally, when multiple level designs are present on a given production date, level designs are excluded if they have 0 (zero) present for Mold Inventory Qty.
*/

SELECT
    cal.day_date AS bus_dt,
    CASE WHEN cal.day_date <> cal.begin_dt THEN CAST(cal.begin_dt + 1 AS DATE) ELSE CAST(cal.begin_dt + 6 AS DATE) END AS bus_wk,
    cal.month_dt AS bus_mth,

    fmc.matl_id,
    fmc.facility_id,
    MAX(fmc.lvl_grp_id) AS lvl_grp_id,
    COUNT(DISTINCT fmc.lvl_grp_id) (DECIMAL(15,3)) AS lvl_grp_cnt

FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN na_vws.facl_matl_cycasgn fmc
        ON cal.day_date BETWEEN fmc.eff_dt AND fmc.exp_dt
        AND cal.day_date >= fmc.lvl_design_eff_dt
        AND fmc.lvl_design_sta_cd = 'A'
        AND fmc.sbu_id = 2
        AND fmc.orig_sys_id = 2
        AND fmc.src_sys_id = 2

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr m
        ON m.matl_id = fmc.matl_id
        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND m.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN (
            SELECT
                c.day_date AS bus_dt,
                f.matl_id,
                f.facility_id,
                MAX(f.lvl_design_eff_dt) AS max_ld_eff_dt
            FROM gdyr_bi_vws.gdyr_cal c
                INNER JOIN na_vws.facl_matl_cycasgn f
                    ON c.day_date BETWEEN f.eff_dt AND f.exp_dt
                    AND c.day_date >= f.lvl_design_eff_dt
                    AND f.lvl_design_sta_cd = 'A'
                    AND f.sbu_id = 2
                    AND f.orig_sys_id = 2
                    AND f.src_sys_id = 2
            WHERE
                c.day_date BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
            GROUP BY
                c.day_date,
                f.matl_id,
                f.facility_id
            ) lim
        ON lim.bus_dt = cal.day_date
        AND lim.matl_id = fmc.matl_id
        AND lim.facility_id = fmc.facility_id
        AND lim.max_ld_eff_dt = fmc.lvl_design_eff_dt

WHERE
    cal.day_date BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)

GROUP BY
    cal.day_date,
    bus_wk,
    cal.month_dt,

    fmc.matl_id,
    fmc.facility_id

UNION ALL

SELECT
    cal.day_date AS bus_dt,
    CASE WHEN cal.day_date <> cal.begin_dt THEN CAST(cal.begin_dt + 1 AS DATE) ELSE CAST(cal.begin_dt + 6 AS DATE) END AS bus_wk,
    cal.month_dt AS bus_mth,

    fmc.matl_id,
    fmc.facility_id,
    MAX(fmc.lvl_grp_id) AS lvl_grp_id,
    COUNT(DISTINCT fmc.lvl_grp_id) (DECIMAL(15,3)) AS lvl_grp_cnt

FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN na_vws.facl_matl_cycasgn fmc
        ON fmc.exp_dt = CAST('5555-12-31' AS DATE)
        AND cal.day_date >= fmc.lvl_design_eff_dt
        AND fmc.lvl_design_sta_cd = 'A'
        AND fmc.sbu_id = 2
        AND fmc.orig_sys_id = 2
        AND fmc.src_sys_id = 2

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr m
        ON m.matl_id = fmc.matl_id
        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND m.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN (
            SELECT
                c.day_date AS bus_dt,
                f.matl_id,
                f.facility_id,
                MAX(f.lvl_design_eff_dt) AS max_ld_eff_dt
            FROM gdyr_bi_vws.gdyr_cal c
                INNER JOIN na_vws.facl_matl_cycasgn f
                    ON f.exp_dt = CAST('5555-12-31' AS DATE)
                    AND c.day_date >= f.lvl_design_eff_dt
                    AND f.lvl_design_sta_cd = 'A'
                    AND f.sbu_id = 2
                    AND f.orig_sys_id = 2
                    AND f.src_sys_id = 2
            WHERE
                c.day_date BETWEEN CURRENT_DATE AND CAST(ADD_MONTHS(CURRENT_DATE, 13) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 13)) AS DATE)
            GROUP BY
                c.day_date,
                f.matl_id,
                f.facility_id
            ) lim
        ON lim.bus_dt = cal.day_date
        AND lim.matl_id = fmc.matl_id
        AND lim.facility_id = fmc.facility_id
        AND lim.max_ld_eff_dt = fmc.lvl_design_eff_dt

WHERE
    cal.day_date BETWEEN CURRENT_DATE AND CAST(ADD_MONTHS(CURRENT_DATE, 13) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 13)) AS DATE)

GROUP BY
    cal.day_date,
    bus_wk,
    cal.month_dt,

    fmc.matl_id,
    fmc.facility_id