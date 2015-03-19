SELECT
    ddc.fiscal_yr,
    ddc.deliv_id,
    ddc.deliv_line_nbr,
    ddc.order_fiscal_yr,
    ddc.order_id,
    ddc.order_line_nbr,
    
    ddc.ship_to_cust_id,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    ddc.cust_grp2_cd,
    
    ddc.matl_id,
    
    ddc.facility_id,
    ddc.deliv_line_facility_id,
    ddc.ship_pt_id,
    ddc.ship_facility_id,
    
    ddc.deliv_type_id,
    ddc.deliv_cat_id,
    ddc.batch_nbr,
    ddc.deliv_prty_id,
    ddc.bill_lading_id,
    ddc.ship_cond_id,
    ddc.orig_deliv_line_nbr,
    ddc.rtg_id,
    ddc.terms_id,
    ddc.unld_pt_cd,
    ddc.spcl_proc_id,
    ddc.prm_ship_carr_cd,
    ddc.src_crt_usr_id,
    ddc.goods_iss_ind,
    
    ddc.deliv_note_crea_dt,
    ddc.deliv_line_crea_dt,
    ddc.transp_pln_dt,
    ddc.pick_dt,
    ddc.load_dt,
    ddc.pln_goods_mvt_dt,
    ddc.actl_goods_iss_dt,
    ddc.deliv_dt,
    ddc.deliv_tm,
    
    ddc.qty_unit_meas_id,
    ddc.deliv_qty,
    ZEROIFNULL(dip.qty_to_ship) AS in_proc_qty,
    
    ddc.vol_unit_meas_id,
    ddc.vol,
    
    ddc.wt_unit_meas_id,
    ddc.net_wt,
    ddc.gross_wt

FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = ddc.ship_to_cust_id
        AND cust.cust_grp2_cd = 'TLB'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ddc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    LEFT OUTER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
        ON dip.deliv_id = ddc.deliv_id
        AND dip.deliv_line_nbr = ddc.deliv_line_nbr
        AND dip.order_id = ddc.order_id
        AND dip.order_line_nbr = ddc.order_line_nbr

WHERE
    ddc.fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))-3 AS CHAR(4))
    AND ddc.distr_chan_cd <> '81'
