/*
future & historical production plan union

created: 2014-04-23

breaks production plans into daily units -- round function applied to tire to avoid fractional tires
union combines historical & future daily data into one set of values

update: 2014-04-24
base plans queries updated date & plan code selection logic
*/

SELECT
    pln.qry_typ,
    pln.pln_typ,
    pln.bus_mth,
    pln.matl_id,
    pln.facility_id,
    SUM( pln.pln_qty ) AS pln_qty

FROM (
    
SELECT
    CAST('Production Plan' AS VARCHAR(25)) AS qry_typ,
    CASE
        WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
        WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
    END AS pln_typ,
    cal.day_date AS bus_dt,
    pp.prod_wk_dt AS bus_wk,
    cal.month_dt AS bus_mth,
    pp.pln_matl_id AS matl_id,
    pp.facility_id,
    pp.prod_pln_cd,
    CASE
        WHEN matl.ext_matl_grp_id = 'tire'
            THEN ( CASE
                WHEN ( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                    THEN CEIL( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
                ELSE FLOOR( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
            END )
        ELSE CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000
    END AS pln_qty

FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN gdyr_vws.prod_pln pp
        ON CAST((pp.prod_wk_dt - 3) AS DATE) BETWEEN pp.eff_dt AND pp.exp_dt -- snapshot on friday before production
        AND cal.day_date BETWEEN pp.prod_wk_dt AND CAST((pp.prod_wk_dt + 6) AS DATE)
        AND pp.prod_pln_cd = '0' -- historical prod plan zero
        AND pp.sbu_id = 2
        AND pp.src_sys_id = 2

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pp.pln_matl_id
        -- AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.matl_id LIKE '%00177430'

WHERE
    cal.day_date BETWEEN 
        ADD_MONTHS((CURRENT_DATE-1), -24) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -24)) - 1)
        AND (SELECT MAX(prod_wk_dt) FROM gdyr_vws.prod_pln WHERE prod_wk_dt <= (CURRENT_DATE-1))

UNION ALL

SELECT
    CAST('Production Plan' AS VARCHAR(25)) AS qry_typ,
    CASE
        WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
        WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
    END AS pln_typ,
    cal.day_date AS bus_dt,
    pp.prod_wk_dt AS bus_wk,
    cal.month_dt AS bus_mth,
    pp.pln_matl_id AS matl_id,
    pp.facility_id,
    pp.prod_pln_cd,
    CASE
        WHEN matl.ext_matl_grp_id = 'tire'
            THEN ( CASE
                WHEN ( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                    THEN CEIL( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
                ELSE FLOOR( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
            END )
        ELSE CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000
    END AS pln_qty

FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN gdyr_vws.prod_pln pp
        ON pp.exp_dt = CAST('5555-12-31' AS DATE) -- snapshot on friday before production
        AND cal.day_date BETWEEN pp.prod_wk_dt AND CAST((pp.prod_wk_dt + 6) AS DATE)
        AND pp.prod_pln_cd = '0' -- historical prod plan zero
        AND pp.sbu_id = 2
        AND pp.src_sys_id = 2

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pp.pln_matl_id
        -- AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.matl_id LIKE '%00177430'

WHERE
    cal.day_date BETWEEN 
        (SELECT CAST(MAX(prod_wk_dt)+1 AS DATE) FROM gdyr_vws.prod_pln WHERE prod_wk_dt <= (CURRENT_DATE-1))
        AND (SELECT CAST(MAX(prod_wk_dt)+((7*8)-1) AS DATE) FROM gdyr_vws.prod_pln WHERE prod_wk_dt <= (CURRENT_DATE-1))

UNION ALL

SELECT
    CAST('Production Plan' AS VARCHAR(25)) AS qry_typ,
    CASE 
        WHEN cal.day_date / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN cal.day_date / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
        WHEN cal.day_date / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        ELSE 'Missing'
    END AS pln_typ,
    cal.day_date AS bus_dt,
    pp.prod_wk_dt AS bus_wk,
    cal.month_dt AS bus_mth,
    pp.pln_matl_id AS matl_id,
    pp.facility_id,
    pp.prod_pln_cd,
    CASE
        WHEN matl.ext_matl_grp_id = 'tire'
            THEN ( CASE
                WHEN ( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                    THEN CEIL( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
                ELSE FLOOR( CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000 )
            END )
        ELSE CAST( pp.pln_qty AS DECIMAL(15,3) ) / 7.000
    END AS pln_qty

FROM gdyr_vws.gdyr_cal cal

    INNER JOIN gdyr_vws.prod_pln pp
        ON pp.exp_dt = CAST('5555-12-31' AS DATE) -- snapshot on friday before production
        AND cal.day_date BETWEEN pp.prod_wk_dt AND CAST((pp.prod_wk_dt + 6) AS DATE)
        AND pp.prod_pln_cd = 'A' -- Future prod plan A from SNP
        AND pp.sbu_id = 2
        AND pp.src_sys_id = 2

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pp.pln_matl_id
        -- AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )
        AND matl.matl_id LIKE '%00204489'

WHERE
    cal.day_date BETWEEN 
        (SELECT CAST(MAX(prod_wk_dt)+(7*8) AS DATE) FROM gdyr_vws.prod_pln WHERE prod_wk_dt <= (CURRENT_DATE-1))
        AND (ADD_MONTHS((CURRENT_DATE-1), 25) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), 25))-1))

    ) pln

GROUP BY
    pln.query_typ,
    pln.pln_typ,
    pln.bus_mth,
    pln.matl_id,
    pln.facility_id