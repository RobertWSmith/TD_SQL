/*
Future Production Plans - Current Record

Created: 2014-04-23

Breaks production plans into daily units -- round function applied to TIRE to avoid fractional tires

Update: 2014-04-24
-> Teradata 13 doesn't support the 'round' function -- used case statement and ceil / floor functions to recreate
-> Beginning date logic simplified & corrected
-> Updated Production Plan Code logic to grab the 'A' code when the Production Week Date is beyond the 8 week horizon
*/

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
