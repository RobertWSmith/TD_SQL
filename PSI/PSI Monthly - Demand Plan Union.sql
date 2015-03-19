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
    SUM(CASE WHEN sp.lag_desc = 0 THEN sp.offcl_sop_sls_pln_qty END) AS offcl_sop_lag0,
    SUM(CASE WHEN sp.lag_desc = 2 THEN sp.offcl_sop_sls_pln_qty END) AS offcl_sop_lag2

FROM na_bi_vws.cust_sls_pln_snap sp

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sp.matl_id
        AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )

WHERE
    sp.perd_begin_mth_dt BETWEEN CAST(SUBSTR(CAST(ADD_MONTHS((CURRENT_DATE-1), -24) AS CHAR(10)),1,7) || '-01' AS DATE ) 
        AND (CURRENT_DATE-1)
    AND sp.lag_desc IN (0, 2) -- need to figure out what this means as opposed to dp_lag_desc -- 
    AND sp.perd_begin_mth_dt = DATE '2014-06-01'
    AND sp.matl_id LIKE '%00163878'

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
    SUM(CASE WHEN sp.dp_lag_desc = 'lag 0' THEN sp.offcl_sop_sls_pln_qty END) AS offcl_sop_lag0,
    SUM(CASE WHEN sp.dp_lag_desc = 'lag 2' THEN sp.offcl_sop_sls_pln_qty END) AS offcl_sop_lag2

FROM na_bi_vws.cust_sls_pln_snap sp

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sp.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')

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