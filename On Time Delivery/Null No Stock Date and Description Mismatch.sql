SELECT
    CAST('FRDD' AS CHAR(4)) AS metric_type,
    pol.order_id,
    pol.order_line_nbr,
    
    pol.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.tire_cust_typ_cd,
    
    pol.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    
    pol.ship_facility_id AS ship_facility_id,
    fac.facility_id || ' - ' || fac.fac_name AS ship_facility_name,
    
    pol.prfct_ord_hit_desc AS hit_desc,
    
    pol.cmpl_ind AS complete_ind,
    pol.cmpl_dt AS complete_date,
    pol.no_stk_dt AS no_stock_date,
    
    pol.fmad_dt AS fmad,
    pol.fpgi_dt AS fpgi,
    pol.req_deliv_dt AS metric_dt,
    
    pol.max_deliv_note_crea_dt,
    pol.max_edi_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.actl_deliv_dt,
    pol.cust_appt_dt,
    pol.a_ind,

    ZEROIFNULL(pol.orig_ord_qty) AS orig_order_qty,
    ZEROIFNULL(pol.cancel_qty) AS cancel_qty,

    ZEROIFNULL(pol.curr_ord_qty) AS order_qty,
    ZEROIFNULL(pol.prfct_ord_hit_qty) AS hit_qty,
    ZEROIFNULL(pol.curr_ord_qty) - ZEROIFNULL(pol.prfct_ord_hit_qty) AS ontime_qty,
    ZEROIFNULL(pol.rel_late_qty) AS rel_late_qty,
    ZEROIFNULL(pol.rel_ontime_qty) AS rel_ontime_qty,
    ZEROIFNULL(pol.commit_ontime_qty) AS commit_ontime_qty,
    ZEROIFNULL(pol.deliv_late_qty) AS deliv_late_qty,
    ZEROIFNULL(pol.deliv_ontime_qty) AS deliv_ontime_qty,

    ZEROIFNULL(pol.ne_hit_rt_qty) AS return_hit_qty,
    ZEROIFNULL(pol.ne_hit_cl_qty) AS claim_hit_qty,
    ZEROIFNULL(pol.ot_hit_fp_qty) AS freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_hit_carr_pickup_qty) + ZEROIFNULL(pol.ot_hit_wi_qty) AS phys_log_hit_qty,
    ZEROIFNULL(pol.ot_hit_mb_qty) AS man_blk_hit_qty,
    ZEROIFNULL(pol.ot_hit_ch_qty) AS credit_hold_hit_qty,
    ZEROIFNULL(pol.if_hit_ns_qty) AS no_stock_hit_qty,
    ZEROIFNULL(pol.if_hit_co_qty) AS cancel_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_qty) AS cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_99_qty) AS man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_99_qty) AS man_rel_hit_qty,
    ZEROIFNULL(pol.ot_hit_lo_qty) AS other_hit_qty,
    
    CASE
        WHEN hit_qty > no_stock_hit_qty
            THEN 'Multiple Hit Types'
        WHEN hit_qty = no_stock_hit_qty
            THEN 'No Stock'
        WHEN hit_qty < no_stock_hit_qty
            THEN 'Hit Qty < No Stock Qty'
        ELSE 'Indeterminate'
    END AS adj_hit_descr

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = pol.ship_facility_id
        AND fac.facility_type_id <> ''

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1) - 3) AS CHAR(4))
        AND ods.order_id = pol.order_id
        AND ods.order_line_nbr = pol.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

WHERE
    pol.cmpl_ind = 1
    AND pol.cmpl_dt BETWEEN DATE '2013-01-01' AND (CURRENT_DATE-1)
    AND pol.prfct_ord_hit_sort_key <> 99
    AND no_stock_hit_qty > 0
    AND no_stock_date IS NULL

UNION ALL

SELECT
    CAST('FCDD' AS CHAR(4)) AS metric_type,
    pol.order_id,
    pol.order_line_nbr,
    
    pol.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.tire_cust_typ_cd,
    
    pol.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    
    pol.ship_facility_id AS ship_facility_id,
    fac.facility_id || ' - ' || fac.fac_name AS ship_facility_name,
    
    pol.prfct_ord_fpdd_hit_desc AS hit_desc,
    
    pol.fpdd_cmpl_ind AS complete_ind,
    pol.fpdd_cmpl_dt AS complete_date,
    pol.fpdd_no_stk_dt AS no_stock_date,
    
    metric_dt - (pol.req_deliv_dt - pol.fmad_dt) AS fmad,
    pol.fpgi_dt AS fpgi,
    pol.req_deliv_dt AS metric_dt,
    
    pol.max_deliv_note_crea_dt,
    pol.max_edi_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.actl_deliv_dt,
    pol.cust_appt_dt,
    pol.a_ind,

    ZEROIFNULL(pol.orig_ord_qty) AS orig_order_qty,
    ZEROIFNULL(pol.cancel_qty) AS cancel_qty,

    ZEROIFNULL(pol.fpdd_ord_qty) AS order_qty,
    ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS hit_qty,
    ZEROIFNULL(pol.fpdd_ord_qty) - ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS ontime_qty,
    ZEROIFNULL(pol.deliv_fpdd_late_qty) AS deliv_late_qty,
    ZEROIFNULL(pol.deliv_fpdd_ontime_qty) AS deliv_ontime_qty,
    ZEROIFNULL(pol.fpdd_commit_ontime_qty) AS commit_ontime_qty,
    ZEROIFNULL(pol.rel_fpdd_late_qty) AS rel_late_qty,
    ZEROIFNULL(pol.rel_fpdd_ontime_qty) AS rel_ontime_qty,

    ZEROIFNULL(pol.ne_fpdd_hit_rt_qty) AS return_hit_qty,
    ZEROIFNULL(pol.ne_fpdd_hit_cl_qty) AS claim_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_fp_qty) AS freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_carr_qty) + ZEROIFNULL(pol.ot_fpdd_hit_wi_qty) AS phys_log_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_mb_qty) AS man_blk_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_ch_qty) AS credit_hold_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_ns_qty) AS no_stock_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_co_qty) AS cancel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_qty) AS cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_99_qty) AS man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_99_qty) AS man_rel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_lo_qty) AS other_hit_qty,
    CASE
        WHEN hit_qty > no_stock_hit_qty
            THEN 'Multiple Hit Types'
        WHEN hit_qty = no_stock_hit_qty
            THEN 'No Stock'
        WHEN hit_qty < no_stock_hit_qty
            THEN 'Hit Qty < No Stock Qty'
        ELSE 'Indeterminate'
    END AS adj_hit_descr

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = pol.ship_facility_id
        AND fac.facility_type_id <> ''

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1) - 3) AS CHAR(4))
        AND ods.order_id = pol.order_id
        AND ods.order_line_nbr = pol.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

WHERE
    pol.fpdd_cmpl_ind = 1
    AND pol.fpdd_cmpl_dt BETWEEN DATE '2013-01-01' AND (CURRENT_DATE-1)
    AND pol.frst_prom_deliv_dt IS NOT NULL
    AND pol.prfct_ord_fpdd_hit_sort_key <> 99
    AND no_stock_hit_qty > 0
    AND no_stock_date IS NULL
    
ORDER BY
    1, 2, 3
;

/*------------------------------------------------------------------------------------------------------------*/

SELECT
    CAST('FRDD' AS CHAR(4)) AS metric_type,
    pol.order_id,
    pol.order_line_nbr,
    
    pol.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.tire_cust_typ_cd,
    
    pol.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    
    pol.ship_facility_id AS ship_facility_id,
    fac.facility_id || ' - ' || fac.fac_name AS ship_facility_name,
    
    pol.prfct_ord_hit_desc AS hit_desc,
    
    pol.cmpl_ind AS complete_ind,
    pol.cmpl_dt AS complete_date,
    pol.no_stk_dt AS no_stock_date,
    
    pol.fmad_dt AS fmad,
    pol.fpgi_dt AS fpgi,
    pol.req_deliv_dt AS metric_dt,
    
    pol.max_deliv_note_crea_dt,
    pol.max_edi_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.actl_deliv_dt,
    pol.cust_appt_dt,
    pol.a_ind,

    ZEROIFNULL(pol.orig_ord_qty) AS orig_order_qty,
    ZEROIFNULL(pol.cancel_qty) AS cancel_qty,

    ZEROIFNULL(pol.curr_ord_qty) AS order_qty,
    ZEROIFNULL(pol.prfct_ord_hit_qty) AS hit_qty,
    ZEROIFNULL(pol.curr_ord_qty) - ZEROIFNULL(pol.prfct_ord_hit_qty) AS ontime_qty,
    ZEROIFNULL(pol.rel_late_qty) AS rel_late_qty,
    ZEROIFNULL(pol.rel_ontime_qty) AS rel_ontime_qty,
    ZEROIFNULL(pol.commit_ontime_qty) AS commit_ontime_qty,
    ZEROIFNULL(pol.deliv_late_qty) AS deliv_late_qty,
    ZEROIFNULL(pol.deliv_ontime_qty) AS deliv_ontime_qty,

    ZEROIFNULL(pol.ne_hit_rt_qty) AS return_hit_qty,
    ZEROIFNULL(pol.ne_hit_cl_qty) AS claim_hit_qty,
    ZEROIFNULL(pol.ot_hit_fp_qty) AS freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_hit_carr_pickup_qty) + ZEROIFNULL(pol.ot_hit_wi_qty) AS phys_log_hit_qty,
    ZEROIFNULL(pol.ot_hit_mb_qty) AS man_blk_hit_qty,
    ZEROIFNULL(pol.ot_hit_ch_qty) AS credit_hold_hit_qty,
    ZEROIFNULL(pol.if_hit_ns_qty) AS no_stock_hit_qty,
    ZEROIFNULL(pol.if_hit_co_qty) AS cancel_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_qty) AS cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_cg_99_qty) AS man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_hit_99_qty) AS man_rel_hit_qty,
    ZEROIFNULL(pol.ot_hit_lo_qty) AS other_hit_qty,
    
    CASE
        WHEN hit_qty > no_stock_hit_qty
            THEN 'Multiple Hit Types'
        WHEN hit_qty = no_stock_hit_qty
            THEN 'No Stock'
        WHEN hit_qty < no_stock_hit_qty
            THEN 'Hit Qty < No Stock Qty'
        ELSE 'Indeterminate'
    END AS adj_hit_descr

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = pol.ship_facility_id
        AND fac.facility_type_id <> ''

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1) - 3) AS CHAR(4))
        AND ods.order_id = pol.order_id
        AND ods.order_line_nbr = pol.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

WHERE
    pol.cmpl_ind = 1
    AND pol.cmpl_dt BETWEEN DATE '2013-01-01' AND (CURRENT_DATE-1)
    AND pol.prfct_ord_hit_sort_key <> 99
    AND no_stock_hit_qty > 0
    AND hit_desc <> metric_type || ' Hit - No Stock'
        
UNION ALL

SELECT
    CAST('FCDD' AS CHAR(4)) AS metric_type,
    pol.order_id,
    pol.order_line_nbr,
    
    pol.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.tire_cust_typ_cd,
    
    pol.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    
    pol.ship_facility_id AS ship_facility_id,
    fac.facility_id || ' - ' || fac.fac_name AS ship_facility_name,
    
    pol.prfct_ord_fpdd_hit_desc AS hit_desc,
    
    pol.fpdd_cmpl_ind AS complete_ind,
    pol.fpdd_cmpl_dt AS complete_date,
    pol.fpdd_no_stk_dt AS no_stock_date,
    
    metric_dt - (pol.req_deliv_dt - pol.fmad_dt) AS fmad,
    pol.fpgi_dt AS fpgi,
    pol.req_deliv_dt AS metric_dt,
    
    pol.max_deliv_note_crea_dt,
    pol.max_edi_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.actl_deliv_dt,
    pol.cust_appt_dt,
    pol.a_ind,

    ZEROIFNULL(pol.orig_ord_qty) AS orig_order_qty,
    ZEROIFNULL(pol.cancel_qty) AS cancel_qty,

    ZEROIFNULL(pol.fpdd_ord_qty) AS order_qty,
    ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS hit_qty,
    ZEROIFNULL(pol.fpdd_ord_qty) - ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty) AS ontime_qty,
    ZEROIFNULL(pol.deliv_fpdd_late_qty) AS deliv_late_qty,
    ZEROIFNULL(pol.deliv_fpdd_ontime_qty) AS deliv_ontime_qty,
    ZEROIFNULL(pol.fpdd_commit_ontime_qty) AS commit_ontime_qty,
    ZEROIFNULL(pol.rel_fpdd_late_qty) AS rel_late_qty,
    ZEROIFNULL(pol.rel_fpdd_ontime_qty) AS rel_ontime_qty,

    ZEROIFNULL(pol.ne_fpdd_hit_rt_qty) AS return_hit_qty,
    ZEROIFNULL(pol.ne_fpdd_hit_cl_qty) AS claim_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_fp_qty) AS freight_policy_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_carr_qty) + ZEROIFNULL(pol.ot_fpdd_hit_wi_qty) AS phys_log_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_mb_qty) AS man_blk_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_ch_qty) AS credit_hold_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_ns_qty) AS no_stock_hit_qty,
    ZEROIFNULL(pol.if_fpdd_hit_co_qty) AS cancel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_qty) AS cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_cg_99_qty) AS man_rel_cust_gen_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_99_qty) AS man_rel_hit_qty,
    ZEROIFNULL(pol.ot_fpdd_hit_lo_qty) AS other_hit_qty,
    CASE
        WHEN hit_qty > no_stock_hit_qty
            THEN 'Multiple Hit Types'
        WHEN hit_qty = no_stock_hit_qty
            THEN 'No Stock'
        WHEN hit_qty < no_stock_hit_qty
            THEN 'Hit Qty < No Stock Qty'
        ELSE 'Indeterminate'
    END AS adj_hit_descr

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = pol.ship_facility_id
        AND fac.facility_type_id <> ''

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1) - 3) AS CHAR(4))
        AND ods.order_id = pol.order_id
        AND ods.order_line_nbr = pol.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

WHERE
    pol.fpdd_cmpl_ind = 1
    AND pol.fpdd_cmpl_dt BETWEEN DATE '2013-01-01' AND (CURRENT_DATE-1)
    AND pol.frst_prom_deliv_dt IS NOT NULL
    AND pol.prfct_ord_fpdd_hit_sort_key <> 99
    AND no_stock_hit_qty > 0
    AND hit_desc <> metric_type || ' Hit - No Stock'
    
ORDER BY
    1, 2, 3
;