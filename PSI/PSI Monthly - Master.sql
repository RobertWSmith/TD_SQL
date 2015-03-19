/*
PSI Monthly - Master

Created: 2014-04-24

This query unions past production plans (effective the Friday before the Monday of the production week),
currently effective production plans for future production weeks and the historical production credits.
Finally, the Production Facility Level Design details are left joined to the production plans & credits to
provide supporting information.

This query is unique at the Busines Month, Material ID & Facility ID level.

*/

SELECT
    ppc.pln_typ,

    ppc.bus_mth,
    extract(year from ppc.bus_mth) as prod_year,
    extract(month from ppc.bus_mth) as prod_month,

    ppc.matl_id,
    ppc.facility_id,
    ppc.plan_qty,

    sum(ppc.plan_qty) over (partition by ppc.bus_mth, ppc.matl_id) as tot_plan_qty,
    ppc.plan_qty / nullifzero(tot_plan_qty) as plan_pct,
    ppc.credit_qty,

    sum(ppc.credit_qty) over (partition by ppc.bus_mth, ppc.matl_id) as tot_credit_qty,
    ppc.credit_qty / nullifzero(tot_credit_qty) as credit_pct,
    cast(count(ppc.facility_id) over (partition by ppc.bus_mth, ppc.matl_id) as decimal(15,3)) as ppc_facility_id_cnt,

    ld.lvl_grp_id,
    ld.lvl_grp_id_cnt

FROM (


    SELECT
        pp.plan_type,
        pp.bus_mth,
        pp.matl_id,
        pp.src_facility_id,
        SUM(CASE WHEN pp.credit_cd = 'C' THEN pp.credit_qty ELSE 0 END) AS prod_credit_qty,
        SUM(CASE WHEN pp.credit_cd <> 'C' THEN pp.credit_qty ELSE 0 END) AS prod_plan_qty

    FROM (

        SELECT
            CAST('Production Credit' AS VARCHAR(25)) AS query_type,
            CAST(CASE
                WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
                    THEN 'Current Month'
                WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
                    THEN 'Future Month'
                WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
                    THEN 'Past Month'
            END AS VARCHAR(25)) AS plan_type,
            cal.day_date AS bus_dt,
            CASE
                WHEN cal.day_date = cal.begin_dt
                    THEN CAST(cal.begin_dt + 6 AS DATE)
                ELSE CAST(cal.begin_dt + 1 AS DATE)
            END AS bus_wk,
            cal.month_dt AS bus_mth,
            pc.matl_id AS matl_id,
            pc.facility_id AS src_facility_id,
            CAST('C' AS CHAR(1)) AS credit_cd,
            CAST(SUM(pc.prod_qty) AS DECIMAL(15,3)) AS credit_qty

        FROM gdyr_bi_vws.gdyr_cal cal

            INNER JOIN gdyr_vws.prod_credit_dy pc
                ON pc.prod_dt = cal.day_date
                AND pc.prod_qty > 0

            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = pc.matl_id
                AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                AND matl.super_brand_id IN ('01', '02', '03', '05')

        WHERE
            cal.day_date >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE)

        GROUP BY
            query_type,
            plan_type,
            bus_dt,
            bus_wk,
            bus_mth,
            pc.matl_id,
            pc.facility_id,
            credit_cd

        UNION ALL

        SELECT
            CAST('Production Plan' AS VARCHAR(25)) AS query_type,
            CAST(CASE
                WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
                    THEN 'Current Month'
                WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
                    THEN 'Future Month'
                WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
                    THEN 'Past Month'
            END AS VARCHAR(25)) AS plan_type,
            cal.day_date AS bus_dt,
            pp.prod_wk_dt AS bus_wk,
            cal.month_dt AS bus_mth,
            pp.pln_matl_id AS matl_id,
            pp.facility_id AS src_facility_id,
            pp.prod_pln_cd AS prod_pln_cd,
            CAST(CASE
                WHEN matl.ext_matl_grp_id = 'TIRE'
                    THEN ROUND(pp.pln_qty / 7.000, 0)
                ELSE (pp.pln_qty / 7.000)
            END AS DECIMAL(15,3)) AS plan_qty

        FROM gdyr_bi_vws.gdyr_cal cal

            INNER JOIN gdyr_vws.prod_pln pp
                ON cal.day_date BETWEEN pp.prod_wk_dt AND CAST(pp.prod_wk_dt + 6 AS DATE)
                AND CAST(pp.prod_wk_dt - 3 AS DATE) BETWEEN pp.eff_dt AND pp.exp_dt
                AND pp.prod_pln_cd = '0'
                AND pp.sbu_id = 2
                AND pp.pln_qty > 0

            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = pp.pln_matl_id
                AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                AND matl.super_brand_id IN ('01', '02', '03', '05')

        WHERE
            cal.day_date BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND
                (SELECT MIN(pp.prod_wk_dt) - 1 AS end_dt FROM gdyr_vws.prod_pln pp WHERE pp.sbu_id = 2 AND pp.prod_pln_cd = '0' AND pp.prod_wk_dt > CURRENT_DATE)

        UNION ALL

        SELECT
            CAST('Production Plan' AS VARCHAR(25)) AS query_type,
            CAST(CASE
                WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
                    THEN 'Current Month'
                WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
                    THEN 'Future Month'
                WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
                    THEN 'Past Month'
            END AS VARCHAR(25)) AS plan_type,
            cal.day_date AS bus_dt,
            pp.prod_wk_dt AS bus_wk,
            cal.month_dt AS bus_mth,
            pp.pln_matl_id AS matl_id,
            pp.facility_id AS src_facility_id,
            pp.prod_pln_cd AS prod_pln_cd,
            CAST(CASE
                WHEN matl.ext_matl_grp_id = 'TIRE'
                    THEN ROUND(pp.pln_qty/7.000, 0)
                ELSE (pp.pln_qty / 7.000)
            END AS DECIMAL(15,3)) AS plan_qty

        FROM gdyr_bi_vws.gdyr_cal cal

            INNER JOIN gdyr_vws.prod_pln pp
                ON cal.day_date BETWEEN pp.prod_wk_dt AND CAST(pp.prod_wk_dt + 6 AS DATE)
                AND pp.exp_dt = CAST('5555-12-31' AS DATE)
                AND pp.sbu_id = 2
                AND pp.prod_pln_cd = '0'
                AND pp.pln_qty > 0

            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = pp.pln_matl_id
                AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                AND matl.super_brand_id IN ('01', '02', '03', '05')

        WHERE
            cal.day_date BETWEEN (SELECT MIN(pp.prod_wk_dt) AS begin_dt FROM gdyr_vws.prod_pln pp WHERE pp.prod_pln_cd = '0' AND pp.sbu_id = 2 AND pp.prod_wk_dt > (CURRENT_DATE-1)) AND
                (SELECT MIN(pp.prod_wk_dt) + (7*7) AS end_dt FROM gdyr_vws.prod_pln pp WHERE pp.prod_pln_cd = '0' AND pp.sbu_id = 2 AND pp.prod_wk_dt > (CURRENT_DATE-1))

        UNION ALL

        SELECT
            CAST('Production Plan' AS VARCHAR(25)) AS query_type,
            CAST(CASE
                WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
                    THEN 'Current Month'
                WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
                    THEN 'Future Month'
                WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
                    THEN 'Past Month'
            END AS VARCHAR(25)) AS plan_type,
            cal.day_date AS bus_dt,
            pp.prod_wk_dt AS bus_wk,
            cal.month_dt AS bus_mth,
            pp.pln_matl_id AS matl_id,
            pp.facility_id AS src_facility_id,
            pp.prod_pln_cd AS prod_pln_cd,
            CAST(CASE
                WHEN matl.ext_matl_grp_id = 'TIRE'
                    THEN ROUND(pp.pln_qty / 7.000, 0)
                ELSE (pp.pln_qty / 7.000)
            END AS DECIMAL(15,3)) AS plan_qty

        FROM gdyr_bi_vws.gdyr_cal cal

            INNER JOIN gdyr_vws.prod_pln pp
                ON cal.day_date BETWEEN pp.prod_wk_dt AND CAST(pp.prod_wk_dt + 6 AS DATE)
                AND pp.exp_dt = CAST('5555-12-31' AS DATE)
                AND pp.sbu_id = 2
                AND pp.prod_pln_cd = 'A'
                AND pp.pln_qty > 0

            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = pp.pln_matl_id
                AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                AND matl.super_brand_id IN ('01', '02', '03', '05')

        WHERE
            cal.day_date BETWEEN
                -- where prod plan '0' ends
                (SELECT MIN(pp.prod_wk_dt) + (7*8) AS begin_dt FROM gdyr_vws.prod_pln pp WHERE pp.prod_pln_cd = '0' AND pp.sbu_id = 2 AND pp.prod_wk_dt > (CURRENT_DATE-1)) AND
                -- end of +12 months
                (SELECT ADD_MONTHS(MIN(pp.prod_wk_dt), 13) - EXTRACT(DAY FROM ADD_MONTHS(MIN(pp.prod_wk_dt), 13)) AS end_dt FROM gdyr_vws.prod_pln pp WHERE pp.prod_pln_cd = '0' AND pp.sbu_id = 2 AND pp.prod_wk_dt > (CURRENT_DATE-1))

       ) pp

    GROUP BY
        pp.plan_type,
        pp.bus_mth,
        pp.matl_id,
        pp.src_facility_id

   ) ppc

    left outer join (
            SELECT
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
                cal.month_dt,

                fmc.matl_id,
                fmc.facility_id

            UNION

            SELECT
                cal.month_dt AS bus_mth,

                fmc.matl_id,
                fmc.facility_id,
                MAX(fmc.lvl_grp_id) AS lvl_grp_id,
                COUNT(DISTINCT fmc.lvl_grp_id) (DECIMAL(15,3)) AS lvl_grp_cnt

            from gdyr_bi_vws.gdyr_cal cal

                INNER JOIN na_vws.facl_matl_cycasgn fmc
                    on fmc.exp_dt = CAST('5555-12-31' AS DATE)
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
                cal.month_dt,

                fmc.matl_id,
                fmc.facility_id
            ) ld
        on ld.bus_mth = ppc.bus_mth
        and ld.facility_id = ppc.src_facility_id
        and ld.matl_id = ppc.matl_id