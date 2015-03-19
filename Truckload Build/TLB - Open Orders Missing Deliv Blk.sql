SELECT
    odc.order_fiscal_yr
    , odc.order_id
    , odc.order_line_nbr
    , odc.sched_line_nbr
    
    , sd.src_crt_dt
    , sd.src_crt_tm
    , sdi.src_crt_ts
    , sdi.src_crt_usr_id
    , CASE
        WHEN sdi.src_crt_usr_id LIKE ANY ('LD%', 'COWD%')
            THEN 'S'
        ELSE 'U'
    END AS itm_creator_typ

    , odc.ship_to_cust_id
    , cust.cust_name AS ship_to_cust_name
	, cust.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to_cust
    
	, cust.own_cust_id
	, cust.own_cust_name
	, cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust
    
	, cust.sales_org_cd
	, cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org
    
	, cust.distr_chan_cd
	, cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan
    
	, cust.cust_grp_id
	, cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp
    , cust.prim_ship_facility_id
    
    , CASE
        WHEN odc.facility_id IN ('N5US', 'N5CA')
            THEN 'Unplanned Large Order'
        WHEN odc.facility_id <> cust.prim_ship_facility_id
            THEN (CASE
                WHEN odc.facility_id LIKE 'N5%'
                    THEN 'Out of Area - Factory Direct'
                ELSE 'Out of Area'
            end)
        ELSE 'Primary LC'
    END AS prim_ship_facility_test
    
    , odc.facility_id
    , fac.facility_name
    , odc.ship_pt_id
    , sp.facility_name AS ship_pt_name
    , odc.ship_cond_id
    , odc.route_id
    
    , odc.matl_id
	, matl.matl_no_8 || ' - ' || matl.descr AS matl_descr
	, matl.tic_cd
    
	, matl.matl_prty
	, matl.ext_matl_grp_id
	, matl.stk_class_id
	, matl.tire_sz_text
    
	, matl.pbu_nbr
	, matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu
	, matl.brand_id || ' - ' || matl.brand_name AS brand
	, matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category
	, matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS segment
	, matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS tier
	, matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS sales_prod_line
    
	, matl.vol_meas_id
	, matl.unit_vol
	, CAST(CASE matl.pbu_nbr || matl.mkt_area_nbr
        WHEN '0101' THEN 0.75
        WHEN '0108' THEN 0.80
        WHEN '0305' THEN 1.20
        WHEN '0314' THEN 1.20
        WHEN '0406' THEN 1.20
        WHEN '0507' THEN 0.75
        WHEN '0711' THEN 0.75
        WHEN '0712' THEN 0.75
        WHEN '0803' THEN 1.20
        WHEN '0923' THEN 0.75
        ELSE 1
    end AS DECIMAL(15, 3)) AS compression_factor
	, matl.unit_vol * compression_factor AS unit_compressed_vol
    
	, matl.wt_meas_id
	, matl.unit_wt
    
	, matl.hva_txt
	, matl.hmc_txt
    
    , odc.cancel_ind
    , odc.return_ind
    , odc.order_creator
    , odc.rej_reas_id
    , odc.rej_reas_desc
    , odc.cancel_dt
    , odc.deliv_prty_id
    , odc.deliv_grp_cd
    , odc.spcl_proc_id
    
    , sd.deliv_blk_cd
    , sl.schd_ln_deliv_blk_cd
    
    , CASE
        WHEN NULLIF(sd.deliv_blk_cd, '') IS NULL
            THEN (CASE
                WHEN sl.schd_ln_deliv_blk_cd NOT IN ('YR', 'YT') -- '11', New product block?
                    THEN 'SL Deliv Blk Error'
            END)
        WHEN sd.deliv_blk_cd = 'YO'
            THEN (CASE
                WHEN NULLIF(sl.schd_ln_deliv_blk_cd, '') IS NOT NULL
                    THEN 'Header Deliv Blk Error'
            END)
    END AS deliv_blk_test

    , odc.order_dt
    , odc.cust_rdd
    , odc.frst_matl_avl_dt
    , odc.frst_pln_goods_iss_dt
    , odc.frst_rdd
    , odc.fc_matl_avl_dt
    , odc.fc_pln_goods_iss_dt
    , odc.frst_prom_deliv_dt
    
    , odc.pln_transp_pln_dt
    , odc.pln_matl_avl_dt
    , odc.pln_load_dt
    , odc.pln_goods_iss_dt
    , odc.pln_deliv_dt
    , odc.fnl_accept_dt
    
    , odc.qty_unit_meas_id
    , odc.order_qty
    , odc.cnfrm_qty
    , ool.open_cnfrm_qty
    , ool.uncnfrm_qty
    , ool.back_order_qty
    , ool.defer_qty
    , ool.in_proc_qty
    , ool.wait_list_qty
    , ool.othr_order_qty
    , ool.open_cnfrm_qty + ool.uncnfrm_qty + ool.back_order_qty + ool.defer_qty + ool.in_proc_qty + ool.wait_list_qty + ool.othr_order_qty AS total_open_qty
    
    , odc.wt_units_meas_id
    , odc.gross_wt
    , odc.net_wt
    
    , odc.vol_unit_meas_id
    , odc.vol

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id

    INNER JOIN na_bi_Vws.nat_sls_doc sd
        ON sd.exp_dt = DATE '5555-12-31'
        AND sd.fiscal_yr = odc.order_fiscal_yr
        AND sd.sls_doc_id = odc.order_id

    INNER JOIN na_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.fiscal_yr = odc.order_fiscal_yr
        AND sdi.sls_doc_id = odc.order_id
        AND sdi.sls_doc_itm_id = odc.order_line_nbr
    
    INNER JOIN na_bi_vws.nat_sls_doc_schd_ln sl
        ON sl.exp_dt = DATE '5555-12-31'
        AND sl.fiscal_yr = odc.order_fiscal_yr
        AND sl.sls_doc_id = odc.order_id
        AND sl.sls_doc_itm_id = odc.order_line_nbr
        AND sl.schd_ln_id = odc.sched_line_nbr

    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_en_curr fac
        ON fac.facility_id = odc.facility_id
        
    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_en_curr sp
        ON sp.facility_id = odc.ship_pt_id

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id <> 'ZLZ'
    AND odc.po_type_id <> 'RO'
    AND odc.cust_grp2_cd = 'TLB'
    AND total_open_qty > 0
    AND (
        odc.deliv_prty_id = '45'
        AND deliv_blk_test IS NOT NULL
        )

ORDER BY
    odc.order_fiscal_yr
    , odc.order_id
    , odc.order_line_nbr
    , odc.sched_line_nbr
