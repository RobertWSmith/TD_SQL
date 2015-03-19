/*
Fountain Tire - Summary Report

Created: 2014-05-08

Summarizes Orders created by Fountain Tire, sources the original order qty, current order qty, 
adjusts current order qty with respect to cancelled orders and deliveries and summarizes open orders by
confirmed, unconfirmed, back ordered and other open qty.
*/

SELECT
    odc.order_id,
    odc.order_line_nbr,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS mkt_ctgy_area,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cg.cust_grp_id || ' - ' || cg.name AS cust_grp,
    
    odc.order_dt,
    odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1) AS order_mth,
    odc.cust_rdd AS ordd,
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1) AS frdd_mth,
    CASE
        WHEN CAST( COALESCE( odc.cust_rdd, odc.frst_rdd ) - odc.order_dt AS INTEGER ) < 14
            THEN CAST( odc.order_dt + 14 AS DATE )
        ELSE COALESCE( odc.cust_rdd, odc.frst_rdd )
    END AS fountain_rdd,
    fountain_rdd - (EXTRACT(DAY FROM fountain_rdd) - 1) AS fountain_rdd_mth,
    
    odc.facility_id,
    cust.prim_ship_facility_id,
    CASE WHEN odc.facility_id = 'N5US' THEN 'large order' WHEN odc.facility_id <> cust.prim_ship_facility_id THEN 'out of area' ELSE 'standard' END AS ship_facility_ind,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.route_id,
    odc.ship_cond_id,
    odc.spcl_proc_id,
    odc.cust_grp2_cd,
    
    MAX(CASE WHEN oosl.order_id IS NOT NULL THEN 'Y' END) AS open_order_ind,
    MAX(CASE WHEN oosl.credit_hold_flg = 'Y' THEN 'Y' END) AS credit_hold_flg,
    (CASE WHEN odc.return_ind = 'Y' THEN 'Y' END) AS return_ind,
    (CASE WHEN odc.cancel_ind = 'Y' THEN 'Y' END) AS cancel_ind,
    (CASE WHEN odc.deliv_blk_ind = 'Y' THEN 'Y' END) AS deliv_blk_ind,
    
    odc.deliv_blk_cd,
    odc.deliv_prty_id,
    odc.cancel_dt,
    NULLIF(odc.rej_reas_id, '') || ' - ' || odc.rej_reas_desc AS rej_reas,
    
    odc.qty_unit_meas_id AS qty_uom,
    
    MAX(odc.order_qty) AS ordered_qty,
    SUM(odc.cnfrm_qty) AS confirmed_qty,
    MAX(ZEROIFNULL(orig.order_qty)) AS orig_order_qty,
    CAST(orig_order_qty - ordered_qty AS INTEGER) AS orig_order_qty_delta,
    
    SUM(ZEROIFNULL(oosl.open_cnfrm_qty)) AS open_confirmed_qty,
    SUM(ZEROIFNULL(oosl.uncnfrm_qty)) AS unconfirmed_qty,
    SUM(ZEROIFNULL(oosl.back_order_qty)) AS backorder_qty,
    SUM(ZEROIFNULL(oosl.defer_qty) + ZEROIFNULL(oosl.wait_list_qty) + ZEROIFNULL(oosl.in_proc_qty) + ZEROIFNULL(oosl.othr_order_qty)) AS other_open_qty,
    (open_confirmed_qty + unconfirmed_qty + backorder_qty + other_open_qty) AS tot_open_qty,
    
    ZEROIFNULL(dd.deliv_qty) AS delivered_qty,
    ZEROIFNULL(dd.in_proc_qty) AS in_process_qty,
    ZEROIFNULL(dd.curr_mth_gi_qty) AS curr_mth_agi_qty,
    ZEROIFNULL(dd.prev_mth_gi_qty) AS prev_mth_agi_qty,

    CASE
        WHEN open_order_ind = 'Y'
            THEN ordered_qty
        WHEN open_order_ind IS NULL AND (rej_reas IS NULL OR (odc.rej_reas_id = 'Z2' AND odc.po_type_id IN ('DT', 'WA', 'WC', 'WS')) OR odc.rej_reas_id IN ('Z6', 'ZW', 'ZX', 'ZY'))
            THEN (CASE
                WHEN delivered_qty > ordered_qty
                    THEN delivered_qty
                ELSE ordered_qty
            END)
        ELSE (CASE
            WHEN dd.order_id IS NULL -- missing delivery and reason for rejection present
                THEN 0
            ELSE (CASE
                WHEN delivered_qty > confirmed_qty
                    THEN delivered_qty
                ELSE confirmed_qty
            END)
        END)
    END AS adj_ordered_qty,
    
    CASE
        WHEN rej_reas IS NOT NULL OR (delivered_qty = 0 AND open_order_ind IS NULL)
            THEN ordered_qty - delivered_qty
        ELSE 0
    END AS cancelled_qty

FROM na_bi_vws.order_detail_curr odc

    LEFT OUTER JOIN (
                SELECT
                    ddc.order_id,
                    ddc.order_line_nbr,
                    SUM(ddc.deliv_qty) AS deliv_qty,
                    SUM(CASE WHEN ddc.actl_goods_iss_dt IS NULL THEN ddc.deliv_qty ELSE 0 END) AS in_proc_qty,
                    SUM(CASE WHEN ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100 THEN ddc.deliv_qty ELSE 0 END) AS curr_mth_gi_qty,
                    SUM(CASE WHEN ddc.actl_goods_iss_dt / 100 < (CURRENT_DATE-1) / 100 THEN ddc.deliv_qty ELSE 0 END) AS prev_mth_gi_qty
                
                FROM na_bi_vws.delivery_detail_curr ddc
                
                WHERE
                    ddc.ship_to_cust_id IN (SELECT ship_to_cust_id FROM gdyr_bi_vws.nat_cust_hier_descr_en_curr WHERE own_cust_id = '00A0009337')
                    AND ddc.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 3) AS CHAR(4))
                    AND ddc.deliv_qty > 0
                
                GROUP BY
                    ddc.order_id,
                    ddc.order_line_nbr
            ) dd
        ON dd.order_id = odc.order_id
        AND dd.order_line_nbr = odc.order_line_nbr

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.ext_matl_grp_id = 'TIRE'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.own_cust_id = '00A0009337'
    
    INNER JOIN na_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.sls_doc_id = odc.order_id
        AND sdi.sls_doc_itm_id = odc.order_line_nbr
        AND sdi.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 3) AS CHAR(4))
        AND sdi.orig_sys_id = 2
        AND sdi.sbu_id = 2
    
    LEFT OUTER JOIN na_bi_vws.order_detail orig
        ON orig.order_id = odc.order_id
        AND orig.order_line_nbr = odc.order_line_nbr
        AND orig.sched_line_nbr = odc.sched_line_nbr
        AND CAST(sdi.src_crt_ts AS DATE) BETWEEN orig.eff_dt AND orig.exp_dt
        AND orig.order_cat_id = 'c'
        AND orig.order_type_id NOT IN ('zls', 'zlz')
        AND orig.po_type_id <> 'ro'
    
    LEFT OUTER JOIN na_bi_vws.open_order_schdln_curr oosl
        ON oosl.order_id = odc.order_id
        AND oosl.order_line_nbr = odc.order_line_nbr
        AND oosl.sched_line_nbr = odc.sched_line_nbr
    
    LEFT OUTER JOIN gdyr_vws.sales_org so
        ON so.sales_org_cd = odc.sales_org_cd
        AND so.exp_dt = CAST('5555-12-31' AS DATE)
        AND so.lang_id = 'E'
        AND so.orig_sys_id = sdi.orig_sys_id
        AND so.src_sys_id = 2
        AND so.sbu_id = sdi.sbu_id

    LEFT OUTER JOIN gdyr_vws.distr_chan dc
        ON dc.distr_chan_cd = odc.distr_chan_cd
        AND dc.exp_dt = CAST('5555-12-31' AS DATE)
        AND dc.orig_sys_id = sdi.orig_sys_id
        AND dc.src_sys_id = so.src_sys_id
        AND dc.sbu_id = sdi.sbu_id

    LEFT OUTER JOIN gdyr_vws.cust_grp cg
        ON cg.cust_grp_id = odc.cust_grp_id
        AND cg.exp_dt = CAST('5555-12-31' AS DATE)
        AND cg.lang_id = 'E'
        AND cg.orig_sys_id = sdi.orig_sys_id
        AND cg.src_sys_id = so.src_sys_id
        AND cg.sbu_id = sdi.sbu_id

WHERE
    (
        odc.order_dt >= ADD_MONTHS((CURRENT_DATE-1),-1) -- BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR odc.frst_rdd >= ADD_MONTHS((CURRENT_DATE-1),-1) -- BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR fountain_rdd >= ADD_MONTHS((CURRENT_DATE-1),-1) -- BETWEEN BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
    )
    AND odc.order_cat_id = 'c'
    AND odc.order_type_id NOT IN ('zls', 'zlz')
    AND odc.po_type_id <> 'ro'

GROUP BY
    odc.order_id,
    dd.order_id,
    odc.order_line_nbr,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
    
    odc.ship_to_cust_id,
    cust.cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cg.cust_grp_id || ' - ' || cg.name,
    
    odc.order_dt,
    odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1),
    odc.cust_rdd,
    odc.frst_matl_avl_dt,
    odc.frst_pln_goods_iss_dt,
    odc.frst_rdd,
    odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1),
    fountain_rdd,
    fountain_rdd - (EXTRACT(DAY FROM fountain_rdd) - 1),
    
    odc.facility_id,
    cust.prim_ship_facility_id,
    ship_facility_ind,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.rej_reas_id,
    odc.route_id,
    odc.ship_cond_id,
    odc.spcl_proc_id,
    odc.cust_grp2_cd,

    (CASE WHEN odc.return_ind = 'Y' THEN 'Y' END),
    (CASE WHEN odc.cancel_ind = 'Y' THEN 'Y' END),
    (CASE WHEN odc.deliv_blk_ind = 'Y' THEN 'Y' END),
    
    odc.deliv_blk_cd,
    odc.deliv_prty_id,
    odc.cancel_dt,
    NULLIF(odc.rej_reas_id, '') || ' - ' || odc.rej_reas_desc,
    
    odc.qty_unit_meas_id,

    ZEROIFNULL(dd.deliv_qty),
    ZEROIFNULL(dd.in_proc_qty),
    ZEROIFNULL(dd.curr_mth_gi_qty),
    ZEROIFNULL(dd.prev_mth_gi_qty)
;