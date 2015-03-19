SELECT
    odc.order_fiscal_yr,
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr,
    
    odc.ship_to_cust_id,
    odc.sales_org_cd,
    odc.distr_chan_cd,
    odc.cust_grp_id,
    odc.cust_grp2_cd,
    
    odc.matl_id,
    
    odc.facility_id,
    odc.ship_pt_id,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.cancel_ind,
    COALESCE(NULLIF(odc.return_ind, ''), 'N') AS return_ind,
    odc.deliv_blk_ind,
    COALESCE(NULLIF(ool.credit_hold_flg, ''), 'N') AS credit_hold_flg,
    odc.deliv_blk_cd,
    odc.order_creator,
    odc.ship_cond_id,
    odc.prtl_dlvy_cd,
    odc.deliv_prty_id,
    odc.handshake_typ_cd,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    
    odc.cancel_dt,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    
    odc.order_dt,
    fd.pln_deliv_dt AS first_date,
    odc.cust_rdd,
    odc.frst_matl_avl_dt,
    odc.frst_pln_goods_iss_dt,
    odc.frst_rdd,
    odc.fc_matl_avl_dt,
    COALESCE(odc.fc_matl_avl_dt, odc.frst_prom_deliv_dt - (odc.frst_rdd - odc.frst_matl_avl_dt)) AS fc_matl_avl_dt,
    COALESCE(odc.fc_pln_goods_iss_dt, odc.frst_prom_deliv_dt - (odc.frst_rdd - odc.frst_pln_goods_iss_dt)) AS fc_pln_goods_iss_dt,
    odc.frst_prom_deliv_dt,
    
    odc.qty_unit_meas_id,
    odc.order_qty,
    odc.src_ord_qty,
    odc.cnfrm_qty,
    ZEROIFNULL(ool.open_cnfrm_qty) AS open_cnfrm_qty,
    ZEROIFNULL(ool.uncnfrm_qty) + ZEROIFNULL(ool.back_order_qty) AS uncnfrm_qty,
    ZEROIFNULL(ool.defer_qty) AS defer_qty,
    ZEROIFNULL(ool.wait_list_qty) AS wait_list_qty,
    ZEROIFNULL(ool.in_proc_qty) + ZEROIFNULL(ool.othr_order_qty) AS other_open_qty,
    
    odc.wt_units_meas_id,
    odc.net_wt,
    odc.gross_wt,
    
    odc.vol_unit_meas_id,
    odc.vol
    
FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.cust_grp2_cd = 'TLB'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_Descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN na_bi_vws.order_detail_curr fd
        ON fd.order_fiscal_yr = odc.order_fiscal_yr
        AND fd.order_id = odc.order_id
        AND fd.order_line_nbr = odc.order_line_nbr
        AND fd.sched_line_nbr = 1
        AND fd.order_cat_id = 'C'
        AND fd.order_type_id NOT IN ('ZLZ', 'ZLS')
        AND fd.po_type_id <> 'RO'

    LEFT OUTER JOIN na_vws.open_order_schdln ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr
        AND ool.exp_dt = DATE '5555-12-31'

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id NOT IN ('ZLZ', 'ZLS')
    AND odc.po_type_id <> 'RO'



    