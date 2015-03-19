SELECT
    ool.order_fiscal_yr
    , ool.order_id
    , ool.order_line_nbr
    , ool.sched_line_nbr
    
    , odc.ship_to_cust_id
    , odc.matl_id
    , odc.facility_id
    , odc.ship_pt_id
    
    , ool.credit_hold_flg
    , odc.deliv_blk_ind
    , odc.deliv_blk_cd
    
    , ool.open_cnfrm_qty
    , ool.uncnfrm_qty
    , ool.back_order_qty
    , ool.defer_qty
    , ool.in_proc_qty
    , ool.wait_list_qty
    , ool.othr_order_qty

FROM na_bi_vws.open_order_schdln_curr ool

    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_fiscal_yr = ool.order_fiscal_yr
        AND odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = 1
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id <> 'ZLZ'
        AND odc.po_type_id <> 'RO'
        AND odc.cust_grp2_cd = 'TLB'
        AND odc.ship_cond_id IN ('ST', 'PT')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.prim_ship_facility_id = odc.facility_id

ORDER BY
    ool.order_fiscal_yr
    , ool.order_id
    , ool.order_line_nbr
    , ool.sched_line_nbr