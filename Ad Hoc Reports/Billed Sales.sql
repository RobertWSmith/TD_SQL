SELECT
    cust.own_cust_id,
    cust.own_cust_name,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    cust.cust_grp2_cd,
    cust.tire_cust_type_ind AS oe_repl_ind,
    sa.matl_no AS matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    sa.bill_dt,
    sa.bill_ref_mth_dt,
    sa.wk_of_yr_id,
    sa.mth_of_yr_id,
    sa.cal_yr_id,
    sa.sls_uom,
    sa.sls_qty

FROM na_vws.sls_agg sa

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sa.matl_no
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')
        AND matl.matl_type_id IN ('PCTL','ACCT')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = sa.legacy_ship_to_cust_no
        AND cust.sales_org_cd IN ('N301', 'N302', 'N303', 'N307', 'N311', 'N312', 'N313', 'N321', 'N322', 'N323', 'N336')

WHERE
    sa.bill_ref_mth_dt = CAST((CURRENT_DATE-1) - (EXTRACT(DAY FROM (CURRENT_DATE-1) - 1) AS DATE)
    
