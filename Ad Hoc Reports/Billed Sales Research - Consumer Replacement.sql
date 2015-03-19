SELECT
    s.matl_no AS matl_id,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.ext_matl_grp_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.brand_id || ' - ' || matl.brand_name AS brand,
    matl.assoc_brand_id || ' - ' || matl.assoc_brand_name AS assoc_brand,
    matl.super_brand_id || ' - ' || matl.super_brand_name AS super_brand,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name AS mkt_group,
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name AS prod_group,
    matl.prod_line_nbr || ' - ' || matl.prod_line_name AS prod_line,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS ctgy,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS segment,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS tier,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS sales_prod_line,
    matl.matl_prty,
    
    cust.own_cust_id,
    cust.own_cust_name,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    CASE
        WHEN cust.own_cust_id IN ('00A0003149', '00A0000632', '00A0006582', '00A0006929', '00A0006932', '00A0007036', '00A0009337', '00A0009994', '00A0003088' )
            THEN 'Managed Account'
        ELSE 'Standard Account'
    END AS acct_type,
    cust.tire_cust_typ_cd AS repl_oe_ind,
    s.bill_ref_mth_dt,
    SUM(s.sls_qty) AS bill_sls_qty

FROM gdyr_bi_vws.nat_sales_agg s

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = s.matl_no
        AND matl.pbu_nbr = '01'
        AND matl.matl_type_id IN ('PCTL', 'ACCT')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = s.legacy_ship_to_cust_no
        AND cust.sales_org_cd IN ('N301', 'N302', 'N303', 'N307', 'N311', 'N312', 'N313', 'N321', 'N322', 'N323', 'N336')
        AND cust.tire_cust_typ_cd = 'REPL'

WHERE
    s.sls_qty <> 0
    AND s.bill_ref_mth_dt = CAST((CURRENT_DATE-1) - (EXTRACT(DAY FROM (CURRENT_DATE-1)) -1) AS DATE) 
    AND s.sls_uom = 'EA'
    
GROUP BY
    s.matl_no,
    matl.pbu_nbr,
    pbu,
    matl.ext_matl_grp_id,
    matl.matl_no_8 || ' - ' || matl.descr,
    matl.brand_id || ' - ' || matl.brand_name,
    matl.assoc_brand_id || ' - ' || matl.assoc_brand_name,
    matl.super_brand_id || ' - ' || matl.super_brand_name,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name,
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name,
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name,
    matl.prod_line_nbr || ' - ' || matl.prod_line_name,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name,
    matl.matl_prty,
    
    cust.own_cust_id,
    cust.own_cust_name,
    cust.sales_org_cd || ' - ' || cust.sales_org_name,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name,
    acct_type,
    cust.tire_cust_typ_cd,
    s.bill_ref_mth_dt