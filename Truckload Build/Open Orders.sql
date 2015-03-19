SELECT 
    odc.order_fiscal_yr
	, odc.order_id
	, odc.order_line_nbr
	, odc.sched_line_nbr
	, odc.co_cd
	, odc.div_cd
	, odc.sales_org_cd
	, odc.distr_chan_cd
	, odc.cust_grp_id
	, odc.sold_to_cust_id
	, odc.ship_to_cust_id
	, odc.bill_to_cust_id
	, odc.payor_cust_id
	, odc.order_dt
	, odc.order_cat_id
	, odc.order_type_id
	, odc.schd_ln_ctgy_cd
	, odc.bus_inqr_ind
	, odc.wait_list_cd
	, odc.cancel_ind
	, odc.return_ind
	, odc.po_type_id
	, odc.ro_po_type_ind
	, odc.deliv_blk_ind
	, odc.deliv_blk_cd
	, odc.cust_po_nbr
	, odc.facility_id
	, odc.ship_pt_id
	, odc.item_cat_id
	, odc.matl_id
	, odc.cust_part_nbr
	, odc.price
	, odc.crncy_id
	, odc.prc_dt
	, odc.qty_unit_meas_id
	, odc.src_ord_qty
	, odc.order_qty
	, odc.bus_inqr_qty
	, odc.cnfrm_qty
	, odc.sls_qty_unit_meas_id
	, odc.sls_order_qty
	, odc.rpt_order_qty
	, odc.rpt_cnfrm_qty
	, odc.rpt_qty_unit_meas_id
	, odc.net_wt
	, odc.gross_wt
	, odc.wt_units_meas_id
	, odc.vol
	, odc.vol_unit_meas_id
	, odc.order_creator
	, odc.ship_cond_id
	, odc.prtl_dlvy_cd
	, odc.rej_reas_id
	, odc.rej_reas_desc
	, odc.order_reas_cd
	, odc.batch_nbr
	, odc.deliv_prty_id
	, odc.handshake_typ_cd
	, odc.cust_rdd
	, odc.frst_rdd
	, odc.frst_matl_avl_dt
	, odc.frst_pln_goods_iss_dt
	, odc.frst_prom_deliv_dt
	, odc.pln_transp_pln_dt
	, odc.pln_matl_avl_dt
	, odc.pln_load_dt
	, odc.pln_goods_iss_dt
	, odc.pln_deliv_dt
	, odc.pln_arrive_tm
	, odc.fnl_accept_dt
	, odc.route_id
	, odc.deliv_grp_cd
	, odc.spcl_proc_id
	, odc.prod_allct_determ_proc_id
	, odc.rpt_frt_plcy_cd
	, odc.cust_grp2_cd
	, odc.fc_matl_avl_dt
	, odc.fc_pln_goods_iss_dt
	, odc.cancel_dt
    , ool.credit_hold_flg
    , ool.open_cnfrm_qty
    , ool.uncnfrm_qty
    , ool.back_order_qty
    , ool.defer_qty
    , ool.in_proc_qty
    , ool.wait_list_qty
    , ool.othr_order_qty

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr

WHERE
    odc.order_cat_id = 'C'
    AND odc.po_type_id <> 'RO'
    AND odc.order_type_id <> 'ZLZ'
    AND odc.cust_grp2_cd = 'TLB'
    AND odc.ship_cond_id IN ('SG', 'ST', 'PT')



