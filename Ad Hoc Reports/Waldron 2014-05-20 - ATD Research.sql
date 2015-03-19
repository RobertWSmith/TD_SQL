SELECT
    q.pbu_nbr || ' - ' || q.pbu_name AS pbu,
    q.days_late_fcdd,
    SUM(q.fcdd_hit_qty) AS fcdd_hit_qty

FROM (

SELECT
    pol.order_id,
    pol.order_line_nbr,
    
    pol.cmpl_dt AS frdd_cmpl_dt,
    pol.cmpl_dt - (EXTRACT(DAY FROM pol.cmpl_dt) - 1) AS frdd_cmpl_mth,
    pol.fpdd_cmpl_dt AS fcdd_cmpl_dt,
    pol.fpdd_cmpl_dt - (EXTRACT(DAY FROM pol.fpdd_cmpl_dt) - 1) AS fcdd_cmpl_mth,
    pol.cmpl_ind AS frdd_cmpl_ind,
    pol.fpdd_cmpl_ind AS fcdd_cmpl_ind,

    pol.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    
    pol.matl_id,
    matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_name,
    
    pol.ship_facility_id,
    dp.unld_pt_txt,
    CASE
        WHEN dp.unld_pt_txt IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Tuedsay', 'Wed', 'Thr', 'Mon', '.', '\', '.Friday', '.uesday', '\hursday')
            THEN 1
        WHEN dp.unld_pt_txt IN ('Monday thru Friday', 'mon to fri', 'Monday to Friday')
            THEN 5
        WHEN dp.unld_pt_txt IN ('Monday thru Saturday')
            THEN 6
        WHEN dp.unld_pt_txt IN ('Monday thru Sunday', 'Monday thru Suunday')
            THEN 7
        WHEN dp.unld_pt_txt IN ('Monday/Thursday', 'Monday/Tuesday', 'Monday/Wednesday', 'Tuesday/Friday', 'Tuesday/Thursday', 'Tuesday/Wednesday', 'Wednesday/Friday')
            THEN 2
        WHEN dp.unld_pt_txt IN ('Monday/Wednesday/Friday', 'Tuesday/Thursday/Friday')
            THEN 3
        WHEN dp.unld_pt_txt IN ('Monday thru Thursday')
            THEN 4
        ELSE 0
    END AS unloads_per_week,

    NULLIF(pol.max_carr_scac_id, '') AS max_carr_scac_id,

    NULLIF(pol.can_rej_reas_id, '') AS can_rej_reas_id,
    NULLIF(pol.po_type_id, '') AS po_type_id,
    CASE WHEN pol.credit_hold_flg = 'Y' THEN 'Y' ELSE 'N' END AS credit_hold_flg,
    CASE WHEN pol.deliv_blk_ind = 'Y' THEN 'Y' ELSE 'N' END AS deliv_blk_ind,
    CASE WHEN pol.cancel_ind = 'Y' THEN 'Y' ELSE 'N' END AS cancel_ind,
    pol.a_ind,
    pol.r_ind,
    NULLIF(pol.spcl_proc_id, '') AS spcl_proc_id,

    pol.order_dt,
    pol.fmad_dt AS frdd_fmad,
    pol.fpgi_dt AS frdd_fpgi,
    pol.req_deliv_dt AS frdd,

    fcdd - (frdd - frdd_fmad) AS fcdd_fmad,
    fcdd - (frdd - frdd_fpgi) AS fcdd_fpgi,
    pol.frst_prom_deliv_dt AS fcdd,
    
    pol.actl_deliv_dt - frdd AS days_late_frdd,
    pol.actl_deliv_dt - fcdd AS days_late_fcdd,

    pol.cust_appt_dt,
    pol.max_deliv_note_crea_dt,
    pol.max_edi_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.actl_deliv_dt,
    pol.no_stk_dt AS frdd_no_stock_dt,
    pol.fpdd_no_stk_dt AS fcdd_no_stock_dt,

    pol.prfct_ord_hit_desc AS frdd_hit_desc,
    pol.prfct_ord_hit_sort_key AS frdd_hit_sort_key,

    ZEROIFNULL(pol.orig_ord_qty) AS orig_order_qty,
    ZEROIFNULL(pol.cancel_qty) AS cancel_qty,

    ZEROIFNULL(pol.curr_ord_qty) AS frdd_order_qty,
    ZEROIFNULL(pol.prfct_ord_hit_qty) AS frdd_hit_qty,
    ZEROIFNULL(pol.curr_ord_qty) - ZEROIFNULL(pol.prfct_ord_hit_qty) AS frdd_ontime_qty,
    ZEROIFNULL(pol.rel_late_qty) AS frdd_rel_late_qty,
    ZEROIFNULL(pol.rel_ontime_qty) AS frdd_rel_ontime_qty,
    ZEROIFNULL(pol.commit_ontime_qty) AS frdd_commit_ontime_qty,
    ZEROIFNULL(pol.deliv_late_qty) AS frdd_deliv_late_qty,
    ZEROIFNULL(pol.deliv_ontime_qty) AS frdd_deliv_ontime_qty,

    ZEROIFNULL(pol.ne_hit_rt_qty) AS frdd_return_hit_qty,
    ZEROIFNULL(pol.ne_hit_cl_qty) AS frdd_claim_hit_qty,
    ZEROIFNULL(pol.ot_hit_fp_qty) AS frdd_freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_hit_carr_pickup_qty) + ZEROIFNULL(pol.ot_hit_wi_qty) AS frdd_phys_log_hit_qty,
    ZEROIFNULL(pol.ot_hit_mb_qty) AS frdd_man_blk_hit_qty,
    ZEROIFNULL(pol.ot_hit_ch_qty) AS frdd_credit_hold_hit_qty,
    ZEROIFNULL(pol.if_hit_ns_qty) AS frdd_no_stock_hit_qty,
    ZEROIFNULL(pol.if_hit_co_qty) AS frdd_cancel_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_qty) AS frdd_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_99_qty) AS frdd_man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_99_qty) AS frdd_man_rel_hit_qty,
    ZEROIFNULL(pol.ot_hit_lo_qty) AS frdd_other_hit_qty,
    
    pol.prfct_ord_fpdd_hit_desc AS fcdd_hit_desc,
    pol.prfct_ord_fpdd_hit_sort_key AS fcdd_hit_sort_key,

    ZEROIFNULL(pol.fpdd_ord_qty) AS fcdd_order_qty,
    ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS fcdd_hit_qty,
    ZEROIFNULL(pol.fpdd_ord_qty) - ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS fcdd_ontime_qty,
    ZEROIFNULL(pol.deliv_fpdd_late_qty) AS fcdd_deliv_late_qty,
    ZEROIFNULL(pol.deliv_fpdd_ontime_qty) AS fcdd_deliv_ontime_qty,
    ZEROIFNULL(pol.fpdd_commit_ontime_qty) AS fcdd_commit_ontime_qty,
    ZEROIFNULL(pol.rel_fpdd_late_qty) AS fcdd_rel_late_qty,
    ZEROIFNULL(pol.rel_fpdd_ontime_qty) AS fcdd_rel_ontime_qty,

    ZEROIFNULL(pol.ne_fpdd_hit_rt_qty) AS fcdd_return_hit_qty,
    ZEROIFNULL(pol.ne_fpdd_hit_cl_qty) AS fcdd_claim_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_fp_qty) AS fcdd_freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_carr_qty) + ZEROIFNULL(pol.ot_fpdd_hit_wi_qty) AS fcdd_phys_log_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_mb_qty) AS fcdd_man_blk_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_ch_qty) AS fcdd_credit_hold_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_ns_qty) AS fcdd_no_stock_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_co_qty) AS fcdd_cancel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_qty) AS fcdd_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_99_qty) AS fcdd_man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_99_qty) AS fcdd_man_rel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_lo_qty) AS fcdd_other_hit_qty
    
FROM na_bi_vws.prfct_ord_line pol

    LEFT OUTER JOIN na_bi_Vws.sd_doc_partner_curr dp
        ON dp.sd_doc_id = pol.order_id
        AND dp.partner_type_id = 'WE'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id
        AND cust.own_cust_id = '00A0006582'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')

WHERE
    pol.fpdd_cmpl_ind = 1
    AND pol.fpdd_cmpl_dt BETWEEN DATE '2013-01-01' AND (CURRENT_DATE-1)
    AND pol.frst_prom_deliv_dt IS NOT NULL
    AND fcdd_hit_qty > 0
    AND days_late_fcdd > 0

    ) q

GROUP BY
    q.days_late_fcdd,
    pbu