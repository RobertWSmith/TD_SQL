SELECT
    ddc.order_fiscal_yr
    , ddc.order_id
    , ddc.order_line_nbr
    , CASE
        WHEN ddc.actl_goods_iss_dt IS NOT NULL 
            THEN 'Shipped'
    END AS current_state_flag
    
    , sd.cust_prch_ord_id
	, sd.cust_prch_ord_typ_cd -- po type id
	, sd.cust_prch_ord_dt
    
    , ddc.ship_to_cust_id
    , cust.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to
    , cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust
    , cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org
    , cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan
    , cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp
    
	, cust.postal_cd
	, cust.district_name
	, cust.terr_name
	, cust.city_name
	, cust.cntry_name_cd
    
    , cust.prim_ship_facility_id
    , ddc.deliv_line_facility_id AS facility_id
    , fac.name AS facility_name
    , ddc.ship_pt_id
    , ddc.cust_grp2_cd
    , ddc.ship_cond_id
    
    , ddc.matl_id
	, matl.matl_no_8 || ' - ' || matl.descr AS matl_descr
	, matl.tic_cd
    
	, matl.matl_prty
	, matl.ext_matl_grp_id
	, matl.stk_class_id
	
    , matl.hva_txt
	, matl.hmc_txt
    
    , matl.tire_sz_text
    , matl.rim_diam_inches
	, matl.rim_diam_group
	, matl.rim_diam_sub_group
    
	, matl.pbu_nbr
	, matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu
	, matl.brand_id || ' - ' || matl.brand_name AS brand
	, matl.assoc_brand_id || ' - ' || matl.assoc_brand_name AS assoc_brand
	, matl.super_brand_id || ' - ' || matl.super_brand_name AS super_brand
    
	, matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category
	, matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS segment
	, matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS tier
	, matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS sales_prod_line
    
    , ddc.deliv_type_id
    , ddc.deliv_cat_id
    , ddc.deliv_prty_id
    , ddc.rtg_id
    , ddc.terms_id
    , ddc.unld_pt_cd
    --, ddc.spcl_proc_id
    --, ddc.prm_ship_carr_cd
    , ddc.goods_iss_ind
    
    , ods.order_dt
    , ods.frst_matl_avl_dt AS frdd_fmad
    , ods.frst_pln_goods_iss_dt AS frdd_fpgi
    , ods.frst_rdd AS frdd
    , ods.fc_matl_avl_dt AS fcdd_fmad
    , ods.fc_pln_goods_iss_dt AS fcdd_fpgi
    , ods.frst_prom_deliv_dt AS fcdd
    
    , ddc.qty_unit_meas_id
    , SUM(ddc.deliv_qty) AS deliv_qty
    
    , ddc.wt_unit_meas_id
    , SUM(ddc.gross_wt) AS gross_wt
    , SUM(ddc.net_wt) AS net_wt
    
    , ddc.vol_unit_meas_id
    , SUM(ddc.vol) AS vol

FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = ddc.ship_to_cust_id
        AND cust.own_cust_id = '00A0006582'
        AND cust.sub_own_cust_id <> '00A0005207'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ddc.matl_id

    INNER JOIN na_bi_vws.nat_sls_doc sd
        ON sd.exp_dt = DATE '5555-12-31'
        AND sd.fiscal_yr = ddc.order_fiscal_yr
        AND sd.sls_doc_id = ddc.order_id

    INNER JOIN na_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.fiscal_yr = ddc.order_fiscal_yr
        AND sdi.sls_doc_id = ddc.order_id
        AND sdi.sls_doc_itm_id = ddc.order_line_nbr

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr = ddc.order_fiscal_yr
        AND ods.order_id = ddc.order_id
        AND ods.order_line_nbr = ddc.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.order_type_id <> 'ZLZ'
        AND ods.po_type_id <> 'RO'

    LEFT OUTER JOIN gdyr_vws.facility fac
        ON fac.facility_id = ddc.deliv_line_facility_id
        AND fac.sbu_id = 2
	    AND fac.orig_sys_id = 2
	    AND fac.exp_dt = DATE '5555-12-31'
	    AND fac.lang_id = 'EN'

WHERE
    ddc.distr_chan_cd <> '81'
    AND ddc.actl_goods_iss_dt BETWEEN (CURRENT_DATE - 10) AND (CURRENT_DATE-1)
    AND ddc.deliv_cat_id = 'J'
    AND ddc.deliv_qty > 0

GROUP BY
    ddc.order_fiscal_yr
    , ddc.order_id
    , ddc.order_line_nbr
    , CASE
        WHEN ddc.actl_goods_iss_dt IS NOT NULL 
            THEN 'Shipped'
    END
    
    , sd.cust_prch_ord_id
	, sd.cust_prch_ord_typ_cd -- po type id
	, sd.cust_prch_ord_dt
    
    , ddc.ship_to_cust_id
    , cust.ship_to_cust_id || ' - ' || cust.cust_name
    , cust.own_cust_id || ' - ' || cust.own_cust_name
    , cust.sales_org_cd || ' - ' || cust.sales_org_name
    , cust.distr_chan_cd || ' - ' || cust.distr_chan_name
    , cust.cust_grp_id || ' - ' || cust.cust_grp_name
    
	, cust.postal_cd
	, cust.district_name
	, cust.terr_name
	, cust.city_name
	, cust.cntry_name_cd
    
    , cust.prim_ship_facility_id
    , ddc.deliv_line_facility_id
    , fac.name
    , ddc.ship_pt_id
    , ddc.cust_grp2_cd
    , ddc.ship_cond_id
    
    , ddc.matl_id
	, matl.matl_no_8 || ' - ' || matl.descr
	, matl.tic_cd
    
	, matl.matl_prty
	, matl.ext_matl_grp_id
	, matl.stk_class_id
	
    , matl.hva_txt
	, matl.hmc_txt
    
    , matl.tire_sz_text
    , matl.rim_diam_inches
	, matl.rim_diam_group
	, matl.rim_diam_sub_group
    
	, matl.pbu_nbr
	, matl.pbu_nbr || ' - ' || matl.pbu_name
	, matl.brand_id || ' - ' || matl.brand_name
	, matl.assoc_brand_id || ' - ' || matl.assoc_brand_name
	, matl.super_brand_id || ' - ' || matl.super_brand_name
    
	, matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name
	, matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name
	, matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name 
	, matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name 
    
    , ddc.deliv_type_id
    , ddc.deliv_cat_id
    , ddc.deliv_prty_id
    , ddc.rtg_id
    , ddc.terms_id
    , ddc.unld_pt_cd
    --, ddc.spcl_proc_id
    --, ddc.prm_ship_carr_cd
    , ddc.goods_iss_ind
    
    , ods.order_dt
    , ods.frst_matl_avl_dt
    , ods.frst_pln_goods_iss_dt
    , ods.frst_rdd
    , ods.fc_matl_avl_dt
    , ods.fc_pln_goods_iss_dt
    , ods.frst_prom_deliv_dt
    
    , ddc.qty_unit_meas_id
    
    , ddc.wt_unit_meas_id
    
    , ddc.vol_unit_meas_id

ORDER BY
    ddc.order_fiscal_yr
    , ddc.order_id
    , ddc.order_line_nbr
