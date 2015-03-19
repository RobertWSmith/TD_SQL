/*
Orders with Z3 Reason for Rejection w/ full confirmation by FRDD FMAD, but then Z3 Cancel is applied after this date.
*/

SELECT
    odc.order_id,
    odc.order_line_nbr,
    CAST(CASE
        WHEN odc.cancel_dt > odc.frst_matl_avl_dt
            THEN 'Cancelled after FRDD FMAD'
        WHEN odc.cancel_dt = odc.frst_matl_avl_dt
            THEN 'Cancelled on FRDD FMAD'
        WHEN odc.cancel_dt < odc.frst_matl_avl_dt
            THEN 'Cancelled before FRDD FMAD'
    END AS VARCHAR(100)) AS cancel_date_test,
    CAST(CASE
        WHEN fmad_confirmed_qty < fmad_ordered_qty
            THEN 'Underconfirmed'
        WHEN fmad_confirmed_qty = fmad_ordered_qty
            THEN 'Fully Confirmed'
        WHEN fmad_confirmed_qty > fmad_ordered_qty
            THEN 'Overconfirmed -- Investigate'
        ELSE 'Not Underconfirmed'
    END AS VARCHAR(100)) AS fmad_confirmed_test,
    CAST(CASE
        WHEN fmad_open_confirmed_qty > 0
            THEN 'FMAD Open Confirmed Qty Present'
        WHEN fmad_unconfirmed_qty > 0
            THEN 'FMAD Unconfirmed Open Qty Present'
        WHEN fmad_open_other_qty > 0
            THEN 'FMAD Other Open Qty Present'
        ELSE 'No FMAD Open Qty'
    END AS VARCHAR(100)) AS fmad_open_qty_test,
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.sales_org_cd,
    cust.sales_org_name,
    cust.distr_chan_cd,
    cust.distr_chan_name,
    CASE
        WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322') OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Replacement'
    END AS oe_repl_ind,
    cust.cust_grp_id,
    cust.cust_grp_name,
    odc.cust_grp2_cd,
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.super_brand_id || ' - ' || matl.super_brand_name AS super_brand,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS ctgy_mkt_area,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS ctgy_mkt_grp,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS ctgy_prod_grp,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS ctgy_prod_line,
    matl.matl_sta_id,
    matl.tic_cd,
    matl.matl_prty,
    matl.hva_txt,
    matl.hmc_txt,
    odc.facility_id,
    fac.fac_name AS facility_name,
    odc.ship_pt_id,
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    COALESCE(odc.return_ind, 'N') AS return_ind,
    odc.deliv_blk_ind,
    odc.deliv_blk_cd,
    fmad.deliv_blk_cd AS fmad_deliv_blk_cd,
    odc.ship_cond_id,
    odc.cancel_ind,
    odc.cancel_dt,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    fmad.rej_reas_id AS fmad_rej_reas_id,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    odc.order_dt,
    odc.cust_rdd AS ordd,
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    odc.qty_unit_meas_id AS qty_uom,
    MAX(odc.order_qty) AS ordered_qty,
    SUM(odc.cnfrm_qty) AS confirmed_qty,
    ZEROIFNULL(dd.deliv_qty) AS delivered_qty,
    ZEROIFNULL(dd.in_proc_qty) AS in_process_qty,
    ZEROIFNULL(fmad.fmad_order_qty) AS fmad_ordered_qty,
    ZEROIFNULL(fmad.fmad_cnfrm_qty) AS fmad_confirmed_qty,
    ZEROIFNULL(fmad.fmad_open_cnfrm_qty) AS fmad_open_confirmed_qty,
    ZEROIFNULL(fmad.fmad_uncnfrm_qty) AS fmad_unconfirmed_qty,
    ZEROIFNULL(fmad.fmad_other_open_qty) AS fmad_open_other_qty

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = odc.facility_id

    LEFT OUTER JOIN (
                SELECT
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr,
                    ddc.qty_unit_meas_id AS qty_uom,
                    SUM(ddc.deliv_qty) AS deliv_qty,
                    CAST(SUM(ZEROIFNULL(dip.qty_to_ship)) AS DECIMAL(15,3)) AS in_proc_qty
                FROM na_bi_vws.delivery_detail_curr ddc
                    LEFT OUTER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
                        ON dip.deliv_id = ddc.deliv_id
                        AND dip.deliv_line_nbr = ddc.deliv_line_nbr
                        AND dip.order_id = ddc.order_id
                        AND dip.order_line_nbr = ddc.order_line_nbr
                WHERE
                    ddc.distr_chan_cd <> '81'
                    AND ddc.order_fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) AS CHAR(4))
                    AND ddc.actl_goods_iss_dt >= DATE '2014-01-01'
                    AND (ddc.goods_iss_ind = 'Y' OR dip.deliv_id IS NOT NULL)
                GROUP BY
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr,
                    ddc.qty_unit_meas_id
            ) dd
        ON dd.order_id = odc.order_id
        AND dd.order_line_nbr = odc.order_line_nbr

    LEFT OUTER JOIN (
                SELECT
                    od.order_id,
                    od.order_line_nbr,
                    od.deliv_blk_cd,
                    od.rej_reas_id,
                    ods.frst_matl_avl_dt,
                    SUM(od.order_qty) AS fmad_order_qty,
                    SUM(od.cnfrm_qty) AS fmad_cnfrm_qty,
                    SUM(ZEROIFNULL(ool.open_cnfrm_qty)) AS fmad_open_cnfrm_qty,
                    SUM(ZEROIFNULL(ool.uncnfrm_qty)) + SUM(ZEROIFNULL(ool.back_order_qty)) AS fmad_uncnfrm_qty,
                    SUM(ZEROIFNULL(ool.defer_qty)) + SUM(ZEROIFNULL(ool.wait_list_qty)) + SUM(ZEROIFNULL(ool.in_proc_qty)) + SUM(ZEROIFNULL(ool.othr_order_qty)) AS fmad_other_open_qty
                FROM na_bi_vws.order_detail od
                    INNER JOIN na_bi_vws.ord_dtl_smry ods
                        ON ods.order_id = od.order_id
                        AND ods.order_line_nbr = od.order_line_nbr
                        AND ods.order_cat_id = 'C'
                        AND ods.order_type_id <> 'ZLZ'
                        AND ods.po_type_id <> 'RO'
                        AND ods.order_dt >= DATE '2014-01-01'
                        AND ods.rej_reas_id = 'Z3'
                    LEFT OUTER JOIN na_vws.open_order_schdln ool
                        ON ool.order_fiscal_yr = ods.order_fiscal_yr
                        AND ool.order_id = od.order_id
                        AND ool.order_line_nbr = od.order_line_nbr
                        AND ool.sched_line_nbr = od.sched_line_nbr
                WHERE
                    od.order_cat_id = 'C'
                    AND od.order_type_id <> 'ZLZ'
                    AND od.po_type_id <> 'RO'
                    AND od.order_dt >= DATE '2014-01-01'
                    AND ods.frst_matl_avl_dt BETWEEN od.eff_dt AND od.exp_dt
                    AND ods.frst_matl_avl_dt BETWEEN ool.eff_dt AND ool.exp_dt
                GROUP BY
                    od.order_id,
                    od.order_line_nbr,
                    od.deliv_blk_cd,
                    od.rej_reas_id,
                    ods.frst_matl_avl_dt
            ) fmad
        ON fmad.order_id = odc.order_id
        AND fmad.order_line_nbr = odc.order_line_nbr

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id <> 'ZLZ'
    AND odc.po_type_id <> 'RO'
    AND odc.order_dt >= DATE '2014-01-01'
    AND odc.rej_reas_id = 'Z3'
    AND odc.cancel_dt >= CAST(odc.frst_matl_avl_dt - 1 AS DATE)

GROUP BY
    odc.order_id,
    odc.order_line_nbr,
    CAST(CASE
        WHEN odc.cancel_dt > odc.frst_matl_avl_dt
            THEN 'Cancelled after FRDD FMAD'
        WHEN odc.cancel_dt = odc.frst_matl_avl_dt
            THEN 'Cancelled on FRDD FMAD'
        WHEN odc.cancel_dt < odc.frst_matl_avl_dt
            THEN 'Cancelled before FRDD FMAD'
    END AS VARCHAR(100)),
    CAST(CASE
        WHEN fmad_confirmed_qty < fmad_ordered_qty
            THEN 'Underconfirmed'
        WHEN fmad_confirmed_qty = fmad_ordered_qty
            THEN 'Fully Confirmed'
        WHEN fmad_confirmed_qty > fmad_ordered_qty
            THEN 'Overconfirmed -- Investigate'
        ELSE 'Not Underconfirmed'
    END AS VARCHAR(100)),
    CAST(CASE
        WHEN fmad_open_confirmed_qty > 0
            THEN 'FMAD Open Confirmed Qty Present'
        WHEN fmad_unconfirmed_qty > 0
            THEN 'FMAD Unconfirmed Open Qty Present'
        WHEN fmad_open_other_qty > 0
            THEN 'FMAD Other Open Qty Present'
        ELSE 'No FMAD Open Qty'
    END AS VARCHAR(100)),
    odc.ship_to_cust_id,
    cust.cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.sales_org_cd,
    cust.sales_org_name,
    cust.distr_chan_cd,
    cust.distr_chan_name,
    CASE
        WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322') OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Replacement'
    END,
    cust.cust_grp_id,
    cust.cust_grp_name,
    odc.cust_grp2_cd,
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name,
    matl.super_brand_id || ' - ' || matl.super_brand_name,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name,
    matl.matl_sta_id,
    matl.tic_cd,
    matl.matl_prty,
    matl.hva_txt,
    matl.hmc_txt,
    odc.facility_id,
    fac.fac_name,
    odc.ship_pt_id,
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.return_ind,
    odc.deliv_blk_ind,
    odc.deliv_blk_cd,
    fmad.deliv_blk_cd,
    odc.ship_cond_id,
    odc.cancel_ind,
    odc.cancel_dt,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    fmad.rej_reas_id,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    odc.order_dt,
    odc.cust_rdd,
    odc.frst_matl_avl_dt,
    odc.frst_pln_goods_iss_dt,
    odc.frst_rdd,
    odc.qty_unit_meas_id,
    ZEROIFNULL(dd.deliv_qty),
    ZEROIFNULL(dd.in_proc_qty),
    ZEROIFNULL(fmad.fmad_order_qty),
    ZEROIFNULL(fmad.fmad_cnfrm_qty),
    ZEROIFNULL(fmad.fmad_open_cnfrm_qty),
    ZEROIFNULL(fmad.fmad_uncnfrm_qty),
    ZEROIFNULL(fmad.fmad_other_open_qty)

ORDER BY
    odc.order_id,
    odc.order_line_nbr