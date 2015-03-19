/*
PSI Monthly - Production Plans & Credits

Created: 2014-04-23

Individually aggregates plans & credits to the monthly level, unions the queries together and finally denormalizes to show plans & credits side by side for comparison

Update: 2014-04-24
Date logic updates applied
*/

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
                THEN ROUND( pp.pln_qty / 7.000, 0)
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
                THEN ROUND( pp.pln_qty / 7.000, 0)
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
