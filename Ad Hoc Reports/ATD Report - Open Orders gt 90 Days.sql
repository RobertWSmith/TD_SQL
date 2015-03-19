SELECT
    odc.order_fiscal_yr
    , odc.order_id
    , odc.order_line_nbr
    , odc.sched_line_nbr
    , CASE
        WHEN ool.open_cnfrm_qty > 0
            THEN 'Open Confirmed'
        WHEN ool.uncnfrm_qty > 0 OR ool.back_order_qty > 0
            THEN 'Back Ordered'
        WHEN ool.in_proc_qty > 0
            THEN 'In Process'
    END AS current_state_flag
    
    , sd.cust_prch_ord_id
	, sd.cust_prch_ord_typ_cd -- po type id
	, sd.cust_prch_ord_dt
    
    , odc.ship_to_cust_id
    , odc.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to
    , cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust
    , cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org
    , cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan
    , cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp
    
	, cust.postal_cd
	, cust.district_name
	, cust.terr_name
	, cust.city_name
	, cust.cntry_name_cd
    
    , odc.cust_grp2_cd
    
    , cust.prim_ship_facility_id
    , odc.facility_id
    , fac.name AS facility_name
    , odc.ship_pt_id
    
    , odc.matl_id
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
    
    , odc.order_cat_id
    , odc.order_type_id
        
    , odc.order_dt
    , CAST(sdi.src_crt_ts AS DATE) AS order_line_crt_dt
    , odc.cust_rdd AS ordd
    , odc.prc_dt AS pricing_date
    , CAST(CURRENT_DATE - odc.prc_dt AS INTEGER) AS days_past_price_dt
    
    , odc.frst_matl_avl_dt AS frdd_fmad
    , odc.frst_pln_goods_iss_dt AS frdd_fpgi
    , odc.frst_rdd AS frdd
    , odc.fc_matl_avl_dt AS fcdd_fmad
    , odc.fc_pln_goods_iss_dt AS fcdd_fpgi
    , odc.frst_prom_deliv_dt AS fcdd
    
    , CASE
        WHEN ool.open_cnfrm_qty > 0
            THEN odc.pln_matl_avl_dt
    END AS pln_matl_avl_dt
    , CASE
        WHEN ool.open_cnfrm_qty > 0
            THEN odc.pln_goods_iss_dt
    END AS pln_goods_iss_dt
    , CASE
        WHEN ool.open_cnfrm_qty > 0
            THEN odc.pln_deliv_dt
    END AS pln_deliv_dt
    
    , odc.qty_unit_meas_id
    , odc.order_qty
    , odc.cnfrm_qty
    , ool.open_cnfrm_qty
    , ool.uncnfrm_qty + ool.back_order_qty
    , ool.in_proc_qty
    , ool.wait_list_qty
    , ool.defer_qty
    , ool.othr_order_qty
    , ool.open_cnfrm_qty + ool.uncnfrm_qty + ool.back_order_qty + ool.wait_list_qty + ool.in_proc_qty + ool.defer_qty + ool.othr_order_qty AS total_open_qty
    
    , odc.wt_units_meas_id
    , odc.gross_wt
    , odc.net_wt
    
    , odc.vol_unit_meas_id
    , odc.vol

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.own_cust_id = '00A0006582'
        AND cust.sub_own_cust_id <> '00A0005207'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id

    INNER JOIN na_bi_vws.nat_sls_doc sd
        ON sd.exp_dt = DATE '5555-12-31'
        AND sd.fiscal_yr = odc.order_fiscal_yr
        AND sd.sls_doc_id = odc.order_id

    INNER JOIN na_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.fiscal_yr = odc.order_fiscal_yr
        AND sdi.sls_doc_id = odc.order_id
        AND sdi.sls_doc_itm_id = odc.order_line_nbr

    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr

    LEFT OUTER JOIN gdyr_vws.facility fac
        ON fac.facility_id = odc.facility_id
        AND fac.sbu_id = 2
	    AND fac.orig_sys_id = 2
	    AND fac.exp_dt = DATE '5555-12-31'
	    AND fac.lang_id = 'EN'

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id <> 'ZLZ'
    AND odc.po_type_id <> 'RO'
    AND CAST(CURRENT_DATE - odc.prc_dt AS INTEGER) > 90
    AND total_open_qty > 0

/*
QUALIFY
    COUNT(*) OVER (PARTITION BY odc.order_fiscal_yr, odc.order_id, odc.order_line_nbr) > 1
*/

ORDER BY
    odc.order_fiscal_yr
    , odc.order_id
    , odc.order_line_nbr
    , odc.sched_line_nbr    