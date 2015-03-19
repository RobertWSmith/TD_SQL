SELECT
    sp.perd_begin_mth_dt AS bus_mth,
    sp.perd_begin_yr AS bus_yr,
    
    sp.matl_id,
    sp.sales_org_cd,
    sp.distr_chan_cd,
    sp.cust_grp_id,
    
    MAX(sp.offcl_aop_qty) AS aop_qty,
    SUM(CASE WHEN sp.lag_desc = 0 THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS sop_lag0_qty,
    SUM(CASE WHEN sp.lag_desc = 2 THEN sp.offcl_sop_sls_pln_qty ELSE 0 END) AS sop_lag2_qty


FROM na_bi_vws.cust_sls_pln_snap sp

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sp.matl_id
        AND matl.pbu_nbr = '01'

WHERE
    sp.lag_desc IN (0,2)
    AND sp.perd_begin_mth_dt / 100 = (CURRENT_DATE-1) / 100
    AND (sp.offcl_aop_qty > 0 OR sp.offcl_sop_sls_pln_qty > 0)

GROUP BY
    sp.perd_begin_mth_dt,
    sp.perd_begin_yr,
    
    sp.matl_id,
    sp.sales_org_cd,
    sp.distr_chan_cd,
    sp.cust_grp_id