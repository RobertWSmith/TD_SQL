SELECT
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    
    cust.sales_org_cd,
    cust.sales_org_name,
    cust.distr_chan_Cd,
    cust.distr_chan_name,
    cust.cust_grp_id,
    cust.cust_grp_name,
    
    odc.cust_grp2_cd,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS ctgy_mkt_area,
    CAST(CASE matl.pbu_nbr
        WHEN '01'
            THEN (CASE matl.mkt_area_nbr
                WHEN '01'
                    THEN 0.75
                WHEN '04'
                    THEN 0.80
                ELSE 1
            END)
        WHEN '03'
            THEN 1.20
        ELSE 1
    END AS DECIMAL(15,3)) AS compression_ratio,
    matl.unit_wt,
    matl.unit_vol,
    matl.unit_vol * compression_ratio AS unit_compress_vol,
    
    odc.facility_id,
    odc.ship_pt_id,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.deliv_blk_cd,
    odc.ship_cond_id,
    odc.cancel_dt,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    
    odc.order_dt,
    odc.cust_rdd,
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    
    odc.fc_matl_avl_dt AS fcdd_fmad,
    odc.fc_pln_goods_iss_dt AS fcdd_fpgi,
    odc.frst_prom_deliv_dt AS fcdd,
    
    odc.pln_matl_avl_dt AS pmad,
    odc.pln_goods_iss_dt AS pgid,
    odc.pln_deliv_dt AS pdd,
    
    odc.qty_unit_meas_id AS qty_uom,
    odc.wt_units_meas_id AS wt_uom,
    odc.vol_unit_meas_id AS vol_uom,
    odc.order_qty,
    odc.cnfrm_qty,
    ool.open_cnfrm_qty,
    matl.unit_wt * ool.open_cnfrm_qty AS open_cnfrm_wt,
    unit_compress_vol * ool.open_cnfrm_qty AS open_cnfrm_compress_vol,
    ool.uncnfrm_qty,
    ool.back_order_qty,
    ool.defer_qty,
    ool.wait_list_qty,
    ool.othr_order_qty

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr
        AND ool.open_cnfrm_qty > 0

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.own_cust_id = '00A0006929'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03')
        --AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
    AND odc.po_type_id <> 'RO'
