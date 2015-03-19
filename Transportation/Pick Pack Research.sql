SELECT 
    ddc.fiscal_yr
	, ddc.deliv_id
	, ddc.deliv_line_nbr
    , dm.tm_deliv_fiscal_yr
    , dm.tm_deliv_id
    , xref.tm_pln_schd_id
    , xref.tm_deliv_split_id
    , xref.frt_mvmnt_id
    , xref.frt_mvmnt_schd_id
    , xref.frt_mvmnt_stop_id
    , dm.mstr_bol
    , dm.ship_bol
    
	, ddc.order_fiscal_yr
	, ddc.order_id
	, ddc.order_line_nbr
    
	, ddc.ship_to_cust_id
	, cust.cust_name AS ship_to_cust_name
	, cust.own_cust_id
	, cust.own_cust_name
	, cust.sales_org_cd
	, cust.sales_org_name
	, cust.distr_chan_cd
	, cust.distr_chan_name
	, cust.cust_grp_id
	, cust.cust_grp_name
    , cust.tire_cust_typ_cd
    , cust.prim_ship_facility_id
	, ddc.cust_grp2_cd
    , dm.tm_ship_from_loc_id
    , dm.tm_ship_to_loc_id
    
	, ddc.matl_id
	, matl.descr
	, matl.pbu_nbr
	, matl.pbu_name
	, matl.mkt_area_nbr
	, matl.mkt_area_name
	, matl.mkt_grp_nbr
	, matl.mkt_grp_name
    
	, CASE 
		WHEN ddc.deliv_line_facility_id = cust.prim_ship_facility_id
			THEN 'Primary LC'
		ELSE 'Out of Area'
	END AS primary_facility_test
	, ddc.deliv_line_facility_id
	, ddc.ship_facility_id
	, ddc.ship_pt_id
	, ddc.ship_cond_id
    
    , dm.tm_carr_id
    , dm.carr_scac_id
    , dm.carr_stop_qty
    , dm.tm_pln_schd_id
    , dm.frt_mvmnt_id
    
	, ddc.goods_iss_ind
	, ddc.return_ind
	, ddc.deliv_type_id
	, ddc.deliv_cat_id
	, ddc.deliv_prty_id
	, ddc.prtl_dlvy_cd
	, ddc.bill_lading_id
	, ddc.rtg_id
	, ddc.terms_id
	, ddc.spcl_proc_id
    
	, ods.order_dt
	, ods.frst_matl_avl_dt AS frdd_fmad
	, ods.frst_rdd AS frdd
	, ods.frst_prom_deliv_dt AS fcdd
	, ddc.deliv_note_crea_dt
	, ddc.deliv_line_crea_dt
	, ddc.transp_pln_dt
	, ddc.pick_dt
	, ddc.load_dt
	, ddc.pln_goods_mvt_dt
	, ddc.actl_goods_iss_dt
	, ddc.post_goods_iss_tm
	, ddc.deliv_dt
    
	, dws.appt_dt
	, dws.rte_pln_dt
	, dws.ld_pick_dt
	, dws.ld_ready_dt
    , dws.ld_rel_dt
    
    , dm.tender_ts
    , dm.carr_accept_ts
	, dm.arrv_at_pkup_ts
    , dm.req_deliv_dt
    , dm.pln_arrv_ts
    , dm.lpc_appt_ts
    , dm.src_crt_ts
    , dm.src_upd_ts
    
    , ddc.qty_unit_meas_id AS qty_uom
	, ddc.deliv_qty
    
	, ddc.vol_unit_meas_id AS vol_uom
	, ddc.vol
    
	, ddc.wt_unit_meas_id AS wt_uom
	, ddc.net_wt
	, ddc.gross_wt

FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN na_bi_vws.ord_dtl_smry ods
    	ON ods.order_fiscal_yr = ddc.order_fiscal_yr
    	AND ods.order_id = ddc.order_id
    	AND ods.order_line_nbr = ddc.order_line_nbr
    	AND ods.order_cat_id = 'C'
    	AND ods.order_type_id <> 'ZLZ'
    	AND ods.po_type_id <> 'RO'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
    	ON cust.ship_to_cust_id = ddc.ship_to_cust_id
		-- exclude Reinault-Thomas Corp. (Discount Tire)
		AND cust.own_cust_id <> '00A0003088'
		-- 12 = Mileage
		-- 14 = Walmart / Sam's Club
		-- 56 = NASCAR
		-- 81 = Internal Sales (separate report)
		-- 95 = Other Racing
		AND cust.distr_chan_cd NOT IN ('12', '14', '56', '81', '95')
        AND cust.cust_grp2_cd IN ('20M', 'MAN', 'NWC', 'TLB', 'YDN')

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
    	ON matl.matl_id = ddc.matl_id
    	AND matl.pbu_nbr IN ('01', '03', '04', '05', '08', '09') -- exclude Race PBU
    	AND matl.super_brand_id IN ('01', '02', '03', '05')

    LEFT OUTER JOIN na_bi_vws.tm_frtmv_dlv_xref_curr xref
        ON xref.sap_deliv_id_fiscal_yr = ddc.fiscal_yr
        AND xref.sap_deliv_id = ddc.deliv_id
        AND xref.

    LEFT OUTER JOIN na_bi_Vws.tm_frt_mvmnt_curr fm
        ON fm.frt_mvmnt_id = xref.frt_mvmnt_id
        AND fm.frt_mvmnt_schd_id = xref.frt_mvmnt_schd_id

    LEFT OUTER JOIN na_bi_vws.deliv_whse_schd dws
    	ON dws.deliv_fiscal_yr = ddc.fiscal_yr
    	AND dws.deliv_id = ddc.deliv_id

    LEFT OUTER JOIN na_vws.tm_carr_deliv_msg dm
        ON dm.exp_dt = DATE '5555-12-31'
        AND dm.deliv_fiscal_yr = ddc.fiscal_yr
        AND dm.deliv_id = ddc.deliv_id

WHERE 
    ddc.deliv_cat_id = 'J' -- normal delivery, 'T' indicates 'Returns delivery for order'
	AND ddc.goods_iss_ind = 'Y' -- Goods must have been issued for this analysis
	AND ddc.actl_goods_iss_dt < CURRENT_DATE
	AND ddc.deliv_qty > 0
	AND ddc.ship_cond_id IN ('ST', 'PT')
	AND ddc.distr_chan_cd NOT IN ('12', '14', '56', '81', '95')
	AND ddc.cust_grp2_cd IN ('20M', 'MAN', 'NWC', 'TLB', 'YDN')
	AND ddc.deliv_note_crea_dt = DATE '2014-06-02'
    -- >= DATE '2014-01-01'

QUALIFY COUNT(*) OVER (PARTITION BY ddc.fiscal_yr, ddc.deliv_id, ddc.deliv_line_nbr) > 1

ORDER BY 
    ddc.fiscal_yr
	, ddc.deliv_id
	, ddc.deliv_line_nbr



