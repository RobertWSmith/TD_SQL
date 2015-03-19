/*
PSI Monthly - Production & Demand Plan Union

NOT OPERATIONAL -- DO NOT USE

Aggregates Production and Demand Plans for +/- 24 months.

Created: 2014-04-30
*/

/*
Modified the Prod Plan Query to ignore Facility ID -- only produce the network plan
*/

SELECT
    pd.pln_typ,
    pd.bus_mth,
    pd.matl_id,
    SUM(CASE
        WHEN pd.qry_typ = 'Production Plan'
            THEN ZEROIFNULL(pd.pln_qty)
        ELSE 0
    END) AS prod_plan_lag0,
    SUM(CASE
        WHEN pd.qry_typ = 'Demand Plan'
            THEN ZEROIFNULL(pd.pln_qty)
        ELSE 0
    END) AS sop_lag0_qty,
    SUM(CASE
        WHEN pd.qry_typ = 'Demand Plan'
            THEN ZEROIFNULL(pd.lag2_pln_qty)
        ELSE 0
    END) AS sop_lag2_qty

FROM (

SELECT
    pln.qry_typ,
    pln.pln_typ,
    pln.bus_mth,
    pln.matl_id,
    SUM( pln.pln_qty ) AS pln_qty,
    CAST(NULL AS DECIMAL(15,3)) AS lag2_pln_qty

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
            ELSE 'Missing'
        END AS pln_typ,
        cal.day_date AS bus_dt,
        pp.prod_wk_dt AS bus_wk,
        cal.month_dt AS bus_mth,
        pp.pln_matl_id AS matl_id,
        pp.facility_id,
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
            ON cal.day_date BETWEEN pp.prod_wk_dt AND CAST( pp.prod_wk_dt + 6 AS DATE )
            AND CAST( pp.prod_wk_dt - 3 AS DATE ) BETWEEN pp.eff_dt AND pp.exp_dt
            AND pp.prod_pln_cd = '0'
            AND pp.sbu_id = 2
    
        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = pp.pln_matl_id
            AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )
    
    WHERE
        cal.day_date BETWEEN
            CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )
            AND
            (
                SELECT
                    MAX( prod_wk_dt ) + 6 AS end_of_current_prod_wk
                FROM gdyr_vws.prod_pln
                WHERE
                    sbu_id = 2
                    AND prod_pln_cd = '0'
                    AND prod_wk_dt < CURRENT_DATE
            )
    
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
            ON cal.day_date BETWEEN pp.prod_wk_dt AND CAST( pp.prod_wk_dt + 6 AS DATE )
            AND pp.exp_dt = CAST( '5555-12-31' AS DATE )
            AND pp.sbu_id = 2
    
        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = pp.pln_matl_id
            AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )
    
    WHERE
        cal.day_date BETWEEN (
                SELECT
                    MIN( pp.prod_wk_dt ) AS begin_of_next_wk
                FROM gdyr_vws.prod_pln pp
                WHERE
                    pp.prod_pln_cd = '0'
                    AND pp.sbu_id = 2
                    AND pp.prod_wk_dt > CURRENT_DATE
            ) AND
        ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 25 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- end month for of +12 months
        AND pp.prod_pln_cd = (
            CASE
                WHEN  cal.day_date > ( SELECT ( begin_dt + 7 ) + ( 7 * 7 ) FROM gdyr_bi_vws.gdyr_cal WHERE cal.day_date = CURRENT_DATE )
                    THEN 'a'
                ELSE '0'
            END
        )

    ) pln

GROUP BY
    pln.qry_typ,
    pln.pln_typ,
    pln.bus_mth,
    pln.matl_id

UNION ALL

/*
PSI Monthly - Past, Current & Future Demand Plans Union

Brings together Past, Current & Future Demand Plans as one data set

Created: 2014-04-30
*/

SELECT
    CAST('Demand Plan' AS VARCHAR(25)) AS qry_typ,
    CASE 
        WHEN sp.perd_begin_mth_dt / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN sp.perd_begin_mth_dt / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
        WHEN sp.perd_begin_mth_dt / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        ELSE 'Missing'
    END AS pln_typ,
    sp.perd_begin_mth_dt AS bus_mth,
    sp.matl_id,
    SUM(CASE WHEN sp.lag_desc = 0 THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS offcl_sop_lag0,
    SUM(CASE WHEN sp.lag_desc = 2 THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS offcl_sop_lag2

FROM na_bi_vws.cust_sls_pln_snap sp

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sp.matl_id
        AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )

WHERE
    sp.perd_begin_mth_dt BETWEEN CAST(SUBSTR(CAST(ADD_MONTHS((CURRENT_DATE-1), -24) AS CHAR(10)),1,7) || '-01' AS DATE ) 
        AND (CURRENT_DATE-1)
    AND sp.lag_desc IN (0, 2) -- need to figure out what this means as opposed to dp_lag_desc -- 

GROUP BY
    qry_typ,
    pln_typ,
    sp.perd_begin_mth_dt,
    sp.matl_id

HAVING
    offcl_sop_lag0 > 0
    OR offcl_sop_lag2 > 0

UNION ALL

SELECT
    CAST('Demand Plan' AS VARCHAR(25)) AS qry_typ,
    CASE 
        WHEN sp.perd_begin_mth_dt / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN sp.perd_begin_mth_dt / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
        WHEN sp.perd_begin_mth_dt / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        ELSE 'Missing'
    END AS pln_typ,
    sp.perd_begin_mth_dt AS bus_mth,
    sp.matl_id,
    SUM(CASE WHEN sp.dp_lag_desc = 'lag 0' THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS offcl_sop_lag0,
    SUM(CASE WHEN sp.dp_lag_desc = 'lag 2' THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS offcl_sop_lag2

FROM na_bi_vws.cust_sls_pln_snap sp

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sp.matl_id
        AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )

WHERE
    sp.dp_lag_desc IN ( 'lag 0', 'lag 2' )
    AND sp.perd_begin_mth_dt BETWEEN (CURRENT_DATE-1) 
        AND CAST(SUBSTR(CAST(ADD_MONTHS((CURRENT_DATE-1), 13) AS CHAR(10)),1,7) || '-01' AS DATE)

GROUP BY
    qry_typ,
    pln_typ,
    sp.perd_begin_mth_dt,
    sp.matl_id

HAVING
    offcl_sop_lag0 > 0
    OR offcl_sop_lag2 > 0
    
    ) pd

GROUP BY
    pd.pln_typ,
    pd.bus_mth,
    pd.matl_id