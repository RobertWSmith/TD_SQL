SELECT
    cal.day_date AS bus_dt,
    
    od.order_id,
    od.order_line_nbr,
    od.sched_line_nbr,
    
    od.order_cat_id,
    od.order_type_id,
    od.po_type_id,
    od.deliv_blk_cd,
    od.rej_reas_id,
    od.prtl_dlvy_cd,
    od.ship_cond_id,
    od.deliv_prty_id,
    od.route_id,
    od.deliv_grp_cd,
    od.spcl_proc_id,
    
    od.ship_to_cust_id,
    od.sales_org_cd,
    od.distr_chan_cd,
    od.cust_grp_id,
    od.rpt_frt_plcy_cd AS cust_grp2_cd,
    
    od.matl_id,
    
    od.facility_id,
    od.ship_pt_id,
    
    --CASE WHEN ool.credit_hold_flg = 'Y' THEN 'Y' ELSE 'N' END AS credit_hold_flg,
    
    od.order_dt,
    od.cust_rdd AS ordd,
    od.frst_rdd AS frdd,
    od.frst_matl_avl_dt AS frdd_fmad,
    od.frst_pln_goods_iss_dt AS frdd_fpgi,
    
/*    fcdd - (frdd - frdd_fmad) AS fcdd_fmad,
    fcdd - (frdd - frdd_fpgi) AS fcdd_fpgi,
    od.frst_prom_deliv_dt AS fcdd,*/
    
/*    od.pln_transp_pln_dt,
    od.pln_matl_avl_dt,
    od.pln_load_dt,
    od.pln_goods_iss_dt,
    od.pln_deliv_dt,*/
    
    od.qty_unit_meas_id AS qty_uom,
    SUM(od.order_qty) AS order_qty,
    SUM(od.cnfrm_qty) AS cnfrm_qty,
    SUM(ZEROIFNULL(ool.open_cnfrm_qty)) AS open_cnfrm_qty,
    SUM(ZEROIFNULL(ool.uncnfrm_qty)) AS uncnfrm_qty,
    SUM(ZEROIFNULL(ool.back_order_qty)) AS back_order_qty,
    SUM(ZEROIFNULL(ool.defer_qty)) AS defer_qty,
    SUM(ZEROIFNULL(ool.in_proc_qty)) AS in_proc_qty,
    SUM(ZEROIFNULL(ool.wait_list_qty)) AS wait_list_qty,
    SUM(ZEROIFNULL(ool.othr_order_qty)) AS othr_order_qty,
    SUM(ZEROIFNULL(ool.open_cnfrm_qty) + ZEROIFNULL(ool.uncnfrm_qty) + ZEROIFNULL(ool.back_order_qty) +
        ZEROIFNULL(ool.defer_qty) + ZEROIFNULL(ool.in_proc_qty) + ZEROIFNULL(ool.wait_list_qty) + 
        ZEROIFNULL(ool.othr_order_qty)) AS total_open_qty
    
FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN na_bi_vws.order_detail od
        ON cal.day_date BETWEEN od.eff_dt AND od.exp_dt
        AND od.order_cat_id = 'C'
        AND od.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND od.po_type_id <> 'RO'
        AND od.frst_pln_goods_iss_dt / 100 = (DATE '2014-04-01') / 100

    LEFT OUTER JOIN na_vws.open_order_schdln ool
        ON cal.day_date BETWEEN ool.eff_dt AND ool.exp_dt
        AND ool.order_id = od.order_id
        AND ool.order_line_nbr = od.order_line_nbr
        AND ool.sched_line_nbr = od.sched_line_nbr
        AND ool.open_cnfrm_qty > 0

    LEFT OUTER JOIN (
            SELECT
                ddc.order_id,
                ddc.order_line_nbr,
                ddc.sales_org_cd,
                ddc.distr_chan_cd,
                ddc.cust_grp_id,
                CASE
                    WHEN ddc.sales_org_cd IN ('N302', 'N312', 'N322')
                            OR (ddc.sales_org_cd IN ('N303', 'N313', 'N323') AND ddc.distr_chan_cd = '32')
                        THEN 'OE'
                    ELSE 'Repl'
                END AS oe_repl_ind,
                ddc.matl_id,
                ddc.deliv_line_facility_id AS facility_id,
                ddc.actl_goods_iss_dt - (EXTRACT(DAY FROM ddc.actl_goods_iss_dt) - 1) AS actl_goods_iss_mth,
            /*    CASE
                    WHEN ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100
                        THEN 'Current Month'
                    WHEN ddc.actl_goods_iss_dt / 100 > (CURRENT_DATE-1) / 100
                        THEN 'Future Month'
                    WHEN ddc.actl_goods_iss_dt / 100 < (CURRENT_DATE-1) / 100
                        THEN 'Past Month'
                END AS agi_month,*/
                SUM(ddc.deliv_qty) AS goods_issued_qty
                
            FROM na_bi_vws.delivery_detail_curr ddc
            
                INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                    ON matl.matl_id = ddc.matl_id
                    AND matl.pbu_nbr = '01'
                    
            WHERE
                ddc.fiscal_yr >= (EXTRACT(YEAR FROM (CURRENT_DATE-1))-1)
                AND ddc.distr_chan_cd <> '81' -- exclude internal sales
                AND ddc.actl_goods_iss_dt / 100 = DATE '2014-04-01' / 100
                AND ddc.actl_goods_iss_dt <= (CURRENT_DATE-1)
                AND ddc.actl_goods_iss_dt IS NOT NULL
                AND ddc.goods_iss_ind = 'Y'
                AND ddc.deliv_qty > 0
                
            GROUP BY
                ddc.order_id,
                ddc.order_line_nbr,
                ddc.sales_org_cd,
                ddc.distr_chan_cd,
                ddc.cust_grp_id,
                oe_repl_ind,
                ddc.matl_id,
                ddc.deliv_line_facility_id,
                actl_goods_iss_mth
                -- agi_month
            ) dd
        ON dd.order_id = od.order_id
        AND dd.order_line_nbr = od.order_line_nbr

WHERE
    cal.day_date = (DATE '2014-04-01' - 1)

GROUP BY
    cal.day_date AS bus_dt,
    
    od.order_id,
    od.order_line_nbr,
    od.sched_line_nbr,
    
    od.order_cat_id,
    od.order_type_id,
    od.po_type_id,
    od.deliv_blk_cd,
    od.rej_reas_id,
    od.prtl_dlvy_cd,
    od.ship_cond_id,
    od.deliv_prty_id,
    od.route_id,
    od.deliv_grp_cd,
    od.spcl_proc_id,
    
    od.ship_to_cust_id,
    od.sales_org_cd,
    od.distr_chan_cd,
    od.cust_grp_id,
    od.rpt_frt_plcy_cd,
    
    od.matl_id,
    
    od.facility_id,
    od.ship_pt_id,

    
    od.order_dt,
    od.cust_rdd,
    od.frst_rdd,
    od.frst_matl_avl_dt,
    od.frst_pln_goods_iss_dt,
    od.qty_unit_meas_id
