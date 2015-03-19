SELECT
    -- identifier
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr,
    -- attributes
    odc.order_cat_id,
    odc.order_type_id,
    NULLIF(odc.po_type_id, '') AS po_type_id,
    NULLIF(odc.deliv_blk_cd, '') AS deliv_blk_cd,
    odc.order_creator,
    odc.ship_cond_id,
    NULLIF(odc.prtl_dlvy_cd, '') AS prtl_dlvy_cd,
    odc.cancel_dt,
    NULLIF(odc.rej_reas_id, '') AS rej_reas_id,
    odc.rej_reas_desc,
    NULLIF(odc.order_reas_cd, '') AS order_reas_cd,
    odc.deliv_prty_id,
    NULLIF(odc.route_id, '') AS route_id,
    odc.deliv_grp_cd,
    NULLIF(odc.spcl_proc_id, '') AS spcl_proc_id,
    -- indicators
    odc.cancel_ind,
    CASE WHEN odc.return_ind = 'Y' THEN 'Y' ELSE 'N' END AS return_ind,
    odc.deliv_blk_ind,
    CASE WHEN oosl.order_id IS NOT NULL THEN 'Y' ELSE 'N' END AS open_ind,
    CASE WHEN oosl.credit_hold_flg = 'Y' THEN 'Y' ELSE 'N' END AS credit_hold_flg,
    -- customer
    odc.ship_to_cust_id,
    odc.sales_org_cd,
    odc.distr_chan_cd,
    odc.cust_grp_id,
    odc.cust_grp2_cd,
    -- material
    odc.matl_id,
    -- facility
    odc.facility_id,
    odc.ship_pt_id,
    -- dates
    odc.order_dt,
    odc.cust_rdd AS ordd,
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    odc.fc_matl_avl_dt AS fcdd_fmad,
    odc.fc_pln_goods_iss_dt AS fcdd_fpgi,
    odc.frst_prom_deliv_dt AS fcdd,
    odc.pln_transp_pln_dt,
    odc.pln_matl_avl_dt,
    odc.pln_load_dt,
    odc.pln_goods_iss_dt,
    odc.pln_deliv_dt,
    -- quantity
    odc.qty_unit_meas_id AS qty_uom, 
    (odc.order_qty) AS order_qty,
    (odc.cnfrm_qty) AS cnfrm_qty,
    (ZEROIFNULL(oosl.open_cnfrm_qty)) AS open_cnfrm_qty,
    (ZEROIFNULL(oosl.uncnfrm_qty)) AS uncnfrm_qty,
    (ZEROIFNULL(oosl.back_order_qty)) AS back_order_qty,
    (ZEROIFNULL(oosl.defer_qty) + ZEROIFNULL(oosl.wait_list_qty) + ZEROIFNULL(oosl.in_proc_qty) + ZEROIFNULL(oosl.othr_order_qty)) AS other_open_qty,
    odc.wt_units_meas_id AS wt_uom,
    (odc.net_wt) AS net_wt,
    (odc.gross_wt) AS gross_wt,
    odc.vol_unit_meas_id AS vol_uom,
    (odc.vol) AS vol

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.cust_grp_id <> '3R'

    LEFT OUTER JOIN na_bi_vws.open_order_schdln_curr oosl
        ON oosl.order_id = odc.order_id
        AND oosl.order_line_nbr = odc.order_line_nbr
        AND oosl.sched_line_nbr = odc.sched_line_nbr

WHERE
    odc.order_cat_id = 'c'
    AND odc.order_type_id NOT IN ('zls', 'zlz')
    AND odc.po_type_id <> 'ro' 
    AND odc.cust_grp_id <> '3R'
    AND (
        (CURRENT_DATE-1) / 100 = odc.pln_goods_iss_dt / 100 -- current month PGI
        OR (CURRENT_DATE-1) / 100 = (odc.frst_rdd / 100) -- current month FRDD
        OR (CURRENT_DATE-1) / 100 = (odc.frst_prom_deliv_dt / 100) -- current month FCDD
        OR (CURRENT_DATE-1) / 100 = (odc.order_dt / 100) -- current month Order Create Date
        OR oosl.order_id IS NOT NULL -- currently open order
        )

SAMPLE 1000
