SELECT
    q.order_fiscal_yr AS order_fiscal_yr,
    q.order_id AS order_id,
    q.nm AS ship_to_cust,
    q.owner_nm,
    q.cust_grp2_cd AS cust_grp2_cd,
    COUNT(DISTINCT q.order_fiscal_yr || q.order_id || q.order_line_nbr) AS order_line_cnt,
    COUNT(DISTINCT q.order_fiscal_yr || q.order_id || q.matl_id) AS matl_id_cnt,
    order_line_cnt - matl_id_cnt AS tlb_split_lines

FROM (

    SELECT
        odc.order_fiscal_yr,
        odc.order_id,
        odc.order_line_nbr,
        odc.sched_line_nbr,

        odc.ship_to_cust_id,
        CASE WHEN cust.cust_grp_id = '3R' THEN 'COWD' WHEN cust.own_cust_id = '00A0006929' THEN 'Dealer' ELSE 'MFI' END AS owner_nm,
        owner_nm || ' - ' || odc.ship_to_cust_id AS nm,
        cust.cust_name AS ship_to_cust_name,
        cust.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to_cust,
        cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust,
        cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
        cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
        cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,

        odc.matl_id,
        matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
        matl.pbu_nbr,
        matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
        matl.mkt_area_nbr,
        matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
        matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
        matl.vol_meas_id,
        matl.unit_vol,
        CAST(CASE matl.pbu_nbr || matl.mkt_area_nbr
            WHEN '0101' THEN 0.75
            WHEN '0108' THEN 0.80
            WHEN '0305' THEN 1.20
            WHEN '0314' THEN 1.20
            WHEN '0406' THEN 1.20
            WHEN '0507' THEN 0.75
            WHEN '0711' THEN 0.75
            WHEN '0712' THEN 0.75
            WHEN '0803' THEN 1.20
            WHEN '0923' THEN 0.75
            ELSE 1
        END AS DECIMAL(15,3)) AS compression_factor,
        matl.unit_vol * compression_factor AS unit_compressed_vol,
        matl.wt_meas_id,
        matl.unit_wt,

        cust.prim_ship_facility_id,
        odc.facility_id,
        odc.ship_pt_id,

        odc.cancel_ind,
        COALESCE(odc.return_ind, 'N') AS return_ind,
        odc.deliv_blk_ind,
        COALESCE(ool.credit_hold_flg, 'N') AS credit_hold_flg, 

        odc.cancel_dt,
        odc.rej_reas_id,
        odc.rej_reas_id || ' - ' || odc.rej_reas_desc AS rej_reas,
        odc.route_id,
        odc.spcl_proc_id,

        odc.ship_cond_id,
        odc.deliv_blk_cd,
        odc.deliv_prty_id,
        odc.deliv_grp_cd,
        odc.cust_grp2_cd,

        sd.src_crt_dt,
        sd.src_crt_tm,
        CAST(sd.src_crt_dt AS TIMESTAMP(0)) + (sd.src_crt_tm - TIME '00:00:00' HOUR TO SECOND) AS header_crt_ts,
        sdi.src_crt_ts,
        sdi.src_crt_ts - header_crt_ts DAY(4) TO MINUTE AS header_to_line_interval,
        CASE
            WHEN header_to_line_interval <= INTERVAL '5' MINUTE
                THEN 'Original Line'
            ELSE 'Split Line'
        END AS order_line_type,

        odc.order_dt,
        odc.cust_rdd AS ordd,
        odc.frst_matl_avl_dt AS frdd_fmad,
        odc.frst_pln_goods_iss_dt AS frdd_fpgi,
        odc.frst_rdd AS frdd,

        COALESCE(odc.fc_matl_avl_dt, fcdd - (frdd - frdd_fmad)) AS fcdd_fmad,
        COALESCE(odc.fc_pln_goods_iss_dt, fcdd - (frdd - frdd_fpgi)) AS fcdd_fpgi,
        odc.frst_prom_deliv_dt AS fcdd,

        odc.qty_unit_meas_id AS qty_uom,
        odc.order_qty,
        odc.cnfrm_qty,
        ool.open_cnfrm_qty,
        ool.uncnfrm_qty,
        ool.back_order_qty,
        ool.defer_qty,
        ool.in_proc_qty,
        ool.wait_list_qty,
        ool.othr_order_qty

    FROM na_bi_vws.order_detail_curr odc

        LEFT OUTER JOIN na_vws.open_order_schdln ool
            ON ool.order_fiscal_yr = odc.order_fiscal_yr
            AND ool.order_id = odc.order_id
            AND ool.order_line_nbr = odc.order_line_nbr
            AND ool.sched_line_nbr = odc.sched_line_nbr
            AND ool.exp_dt = DATE '5555-12-31'

        INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
            ON cust.ship_to_cust_id = odc.ship_to_cust_id
            AND cust.cust_grp2_cd = 'TLB'

        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = odc.matl_id
            AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
            AND matl.super_brand_id IN ('01', '02', '03', '05')

        INNER JOIN na_bi_vws.nat_sls_doc sd
            ON sd.fiscal_yr = odc.order_fiscal_yr
            AND sd.sls_doc_id = odc.order_id
            AND sd.exp_dt = DATE '5555-12-31'

        INNER JOIN na_bi_vws.nat_sls_doc_itm sdi
            ON sdi.fiscal_yr = odc.order_fiscal_yr
            AND sdi.sls_doc_id = odc.order_id
            AND sdi.sls_doc_itm_id = odc.order_line_nbr
            AND sdi.exp_dt = DATE '5555-12-31'

        LEFT OUTER JOIN (
                SELECT
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr,
                    ddc.ship_to_cust_id,
                    ddc.matl_id,
                    ddc.qty_unit_meas_id,
                    SUM(ddc.deliv_qty) AS deliv_qty,
                    SUM(ZEROIFNULL(dip.qty_to_ship)) AS in_proc_qty

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
                    ddc.fiscal_yr >= '2011'
                    AND ddc.deliv_dt >= DATE '2014-01-01'
                    AND ddc.distr_chan_cd <> '81'
                    AND ddc.deliv_qty > 0

                GROUP BY
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr,
                    ddc.ship_to_cust_id,
                    ddc.matl_id,
                    ddc.qty_unit_meas_id
                ) dd
            ON dd.order_fiscal_yr = odc.order_fiscal_yr
            AND dd.order_id = odc.order_id
            AND dd.order_line_nbr = odc.order_line_nbr

    WHERE
        odc.order_cat_id = 'C'
        AND odc.po_type_id <> 'RO'
        AND odc.order_type_id <> 'ZLZ'
        AND odc.order_dt >= DATE '2014-01-01'

    ) q

GROUP BY
    q.order_fiscal_yr,
    q.order_id,
    q.nm,
    q.owner_nm,
    q.cust_grp2_cd
 
 
 