/*
Daily Production Credits Query

Created: 2014-04-23

Breaks production plans into daily units

Update: 2014-04-24
-> Updated BUS_WK logic
-> Updated minimum Production Date in WHERE clause to support a rolling 24 months (to the beginning of the month 24 months ago)
*/

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
    CASE WHEN cal.day_date <> cal.begin_dt THEN CAST(cal.begin_dt + 1 AS DATE) ELSE CAST(cal.begin_dt + 6 AS DATE) END AS bus_wk,
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