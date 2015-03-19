SELECT
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    
    odc.cust_grp_id,
    odc.cust_grp2_cd,
    odc.deliv_grp_cd,
    odc.deliv_prty_id,
    CASE
        WHEN odc.cust_grp2_cd = 'TLB'
            THEN (CASE
                WHEN odc.deliv_prty_id = '12'
                    THEN 'Truckload Built'
                ELSE 'Pending'
            END)
        ELSE 'Not TLB'
    END AS truckload_prty_ind,
    odc.spcl_proc_id,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS ctgy_mkt_area,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    
    odc.facility_id,
    
    odc.deliv_blk_ind,
    oosl.credit_hold_flg,
    
    CAST(CASE matl.pbu_nbr || matl.mkt_area_nbr
        WHEN '0101'
            THEN 0.75
        WHEN '0108'
            THEN 0.80
        WHEN '0305'
            THEN 1.20
        WHEN '0314'
            THEN 1.20
        ELSE 1
    END AS DECIMAL(15,3)) AS compression_factor,
    matl.unit_wt,
    odc.wt_units_meas_id AS wt_uom,
    matl.unit_vol,
    matl.unit_vol * compression_factor AS unit_compressed_vol,
    odc.vol_unit_meas_id AS vol_uom,
    
    odc.order_dt,
    odc.cust_rdd,
    odc.frst_rdd,
    odc.frst_prom_deliv_dt,
    odc.pln_matl_avl_dt,
    odc.pln_goods_iss_dt,
    odc.pln_deliv_dt,
    
    odc.qty_unit_meas_id AS qty_uom,
    oosl.open_cnfrm_qty AS open_confirmed_qty,
    odc.wt_units_meas_id AS wt_uom,
    oosl.open_cnfrm_qty * matl.unit_wt AS open_confirmed_wt,
    odc.vol_unit_meas_id AS vol_uom,
    oosl.open_cnfrm_qty * unit_compressed_vol AS open_cnfrm_comp_vol

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.open_order_schdln_curr oosl
        ON oosl.order_id = odc.order_id
        AND oosl.order_line_nbr = odc.order_line_nbr
        AND oosl.sched_line_nbr = odc.sched_line_nbr
        AND oosl.open_cnfrm_qty > 0

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        -- AND cust.own_cust_id = '00A0006929'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03')

WHERE
    odc.order_cat_id = 'c'
    AND odc.order_type_id NOT IN ('zls', 'zlz')
    AND odc.po_type_id <> 'ro'
    AND odc.cust_grp2_cd = 'tlb'

ORDER BY
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr
