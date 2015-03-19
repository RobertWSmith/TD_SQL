SELECT
    otd.metric_type,
    otd.order_id,
    otd.order_line_nbr,
    otd.complete_ind,
    otd.complete_dt,
    
    otd.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
    matl.brand_id || ' - ' || matl.brand_name AS brand,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name AS mkt_grp,
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name AS prod_grp,
    matl.prod_line_nbr || ' - ' || matl.prod_line_name AS prod_line,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS segment,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS tier,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS sales_prod_line,
    matl.ext_matl_grp_id,
    matl.matl_prty,
    matl.matl_sta_id,
    matl.tic_cd,
    matl.sal_ind,
    COALESCE(pal.pal_ind, '') AS pal_ind,
    matl.hva_txt,
    matl.hmc_txt,
    matl.target_mkt_segment,
    src.src_facility_id,
    fs.fac_name AS src_facility_name,
    ld.lvl_grp_id,
    
    otd.ship_to_cust_id,
    cust.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to_cust,
    cust.own_cust_id,
    cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust,
    cust.sales_org_cd,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    CASE
        WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322') OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Replacement'
    END AS oe_repl_ind,
    
    cust.cust_grp_id,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    
    cust.cust_grp2_cd,
    
    otd.facility_id,
    fac.fac_name AS facility_name,
    
    otd.order_dt,
    sd.src_crt_tm AS order_tm,
    sdi.src_crt_ts AS order_line_ts,
    ods.cust_rdd AS ordd,
    otd.day_before_fmad,
    otd.fmad,
    otd.fpgi,
    otd.metric_dt,
    
    ods.cancel_dt,
    ods.rej_reas_id,
    ods.rej_reas_desc,
    
    otd.a_ind,
    otd.cust_appt_dt,
    otd.max_edi_deliv_dt,
    otd.max_sap_deliv_dt,
    otd.actl_deliv_dt,
    
    otd.hit_desc,
    
    otd.order_qty,
    otd.hit_qty,
    otd.ontime_qty,
    otd.cancel_qty,
    otd.rel_late_qty,
    otd.rel_ontime_qty,
    otd.commit_ontime_qty,
    otd.deliv_late_qty,
    otd.deliv_ontime_qty,
    
    otd.return_hit_qty,
    otd.claim_hit_qty,
    otd.freight_policy_hit_qty,
    otd.phys_log_hit_qty,
    otd.man_blk_hit_qty,
    otd.credit_hold_hit_qty,
    otd.no_stock_hit_qty,
    otd.cancel_hit_qty,
    otd.cust_gen_hit_qty,
    otd.man_rel_cust_gen_hit_qty,
    otd.man_rel_hit_qty,
    otd.other_hit_qty,
    
    fmad.avail_to_prom_qty AS fmad_atp_qty,
    fmad.tot_qty AS fmad_tot_qty,
    fmad.sto_inbound_qty AS fmad_sto_inbound_qty,
    
    before_fmad.avail_to_prom_qty AS before_fmad_atp_qty,
    before_fmad.tot_qty AS before_fmad_tot_qty,
    before_fmad.sto_inbound_qty AS before_fmad_sto_inbound_qty,
    
    ocd.avail_to_prom_qty AS ocd_atp_qty,
    ocd.tot_qty AS ocd_tot_qty,
    ocd.sto_inbound_qty AS ocd_sto_inbound_qty,
    
    CASE
        WHEN (fmad.avail_to_prom_qty = 0 OR before_fmad.avail_to_prom_qty = 0)
            THEN 'No Stock'
        WHEN fmad.avail_to_prom_qty IS NULL
            THEN 'Unknown Issue'
        ELSE 'Other Issue'
    END AS macro_issue,
    
    CASE
        WHEN ods.frst_prom_deliv_dt IS NULL
            THEN 'Missing FCDD - No Confirmation Detected'
        WHEN fmad.avail_to_prom_qty = 0 AND before_fmad.avail_to_prom_qty = 0
            THEN (CASE
                WHEN ocd.avail_to_prom_qty = 0
                    THEN 'All Inventory Checks'
                WHEN ocd.avail_to_prom_qty > 0
                    THEN 'ATP Only on Order Create Date'
                ELSE 'Order Create ATP Not Available'
            END)
        WHEN otd.fmad = otd.order_dt AND fmad.avail_to_prom_qty > 0 AND cust.cust_grp2_cd <> 'TLB'
            THEN 'Order Timing'
        WHEN (ods.cust_rdd < ods.frst_rdd) AND fmad.avail_to_prom_qty > 0 AND cust.cust_grp2_cd = 'TLB'
            THEN 'TLB Non-Feasible ORDD'
        WHEN fmad.avail_to_prom_qty > 0 AND before_fmad.avail_to_prom_qty = 0
            THEN 'Zero ATP - Day Before FMAD'
        WHEN fmad.avail_to_prom_qty = 0 AND before_fmad.avail_to_prom_qty > 0
            THEN 'Zero ATP - FMAD'
        WHEN fmad.avail_to_prom_qty > 0 AND before_fmad.avail_to_prom_qty > 0
            THEN (CASE
                WHEN cust.cust_grp2_cd = 'YDN'
                    THEN 'Order Price Verification'
                WHEN cust.cust_grp2_cd = 'MAN'
                    THEN 'Manual Release Issue'
                WHEN ods.deliv_blk_ind = 'Y'
                    THEN 'Delivery Block Currently Applied'
                ELSE 'Unknown Issue - ATP Available on FMAD'
            END)
        ELSE 'Unknown Issue'
    END AS micro_issue

FROM ( 

    SELECT
        CAST('FRDD' AS CHAR(4)) AS metric_type,
        pol.order_id,
        pol.order_line_nbr,
        pol.cmpl_ind AS complete_ind,
        pol.cmpl_dt AS complete_dt,
        pol.matl_id,
        pol.ship_to_cust_id,
        pol.ship_facility_id AS facility_id,
        pol.order_dt,
        CAST(fmad - 1 AS DATE) AS day_before_fmad,
        pol.fmad_dt AS fmad,
        pol.fpgi_dt AS fpgi,
        pol.req_deliv_dt AS metric_dt,
        pol.a_ind,
        pol.cust_appt_dt,
        pol.max_edi_deliv_dt,
        pol.max_sap_deliv_dt,
        pol.actl_deliv_dt,
        pol.prfct_ord_hit_desc AS hit_desc,
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
        ZEROIFNULL(pol.ot_hit_lo_qty) AS other_hit_qty
    
    FROM na_bi_vws.prfct_ord_line pol
    
    WHERE
        pol.cmpl_ind = 1
        AND pol.cmpl_dt BETWEEN ADD_MONTHS((CURRENT_DATE-1), -2) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -1)) - 1) AND (CURRENT_DATE-1)
        AND pol.prfct_ord_hit_sort_key <> 99
        AND (no_stock_hit_qty > 0)
        AND pol.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
    
    UNION ALL
    
    SELECT
        CAST('FCDD' AS CHAR(4)) AS metric_type,
        pol.order_id,
        pol.order_line_nbr,
        pol.fpdd_cmpl_ind AS complete_ind,
        pol.fpdd_cmpl_dt AS complete_dt,
        pol.matl_id,
        pol.ship_to_cust_id,
        pol.ship_facility_id AS facility_id,
        pol.order_dt,
        CAST(fmad - 1 AS DATE) AS day_before_fmad,
        CAST(pol.frst_prom_deliv_dt - CAST(pol.req_deliv_dt - pol.fmad_dt AS INTEGER) AS DATE) AS fmad,
        pol.fcpgi_dt AS fpgi,
        pol.frst_prom_deliv_dt AS metric_dt,
        pol.a_ind,
        pol.cust_appt_dt,
        pol.max_edi_deliv_dt,
        pol.max_sap_deliv_dt,
        pol.actl_deliv_dt,
        pol.prfct_ord_fpdd_hit_desc AS hit_desc,
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
        ZEROIFNULL(pol.ot_fpdd_hit_lo_qty) AS other_hit_qty
    
    FROM na_bi_vws.prfct_ord_line pol

    WHERE
        pol.fpdd_cmpl_ind = 1
        AND pol.fpdd_cmpl_dt BETWEEN ADD_MONTHS((CURRENT_DATE-1), -2) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -1)) - 1) AND (CURRENT_DATE-1)
        AND pol.frst_prom_deliv_dt IS NOT NULL
        AND pol.prfct_ord_fpdd_hit_sort_key <> 99
        AND (no_stock_hit_qty > 0)
        AND pol.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
    
    ) otd
    
    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_id = otd.order_id
        AND ods.order_line_nbr = otd.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'
    
    LEFT OUTER JOIN gdyr_bi_vws.nat_sls_doc_curr sd
        ON sd.fiscal_yr = ods.order_fiscal_yr
        AND sd.sls_doc_id = otd.order_id

    LEFT OUTER JOIN gdyr_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.fiscal_yr = ods.order_fiscal_yr
        AND sdi.sls_doc_id = otd.order_id
        AND sdi.sls_doc_itm_id = otd.order_line_nbr
    
    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = otd.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = otd.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    LEFT OUTER JOIN gdyr_bi_vws.nat_matl_pal_curr pal
        ON pal.matl_id = matl.matl_id

    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = otd.facility_id
        AND fac.facility_type_id NOT IN ('N', '')

    LEFT OUTER JOIN na_bi_vws.inventory fmad
        ON fmad.day_dt = otd.fmad
        AND fmad.facility_id = otd.facility_id
        AND fmad.matl_id = otd.matl_id
        AND fmad.day_dt >= (CURRENT_DATE-62)

    LEFT OUTER JOIN na_bi_vws.inventory before_fmad
        ON before_fmad.day_dt = otd.day_before_fmad
        AND before_fmad.facility_id = otd.facility_id
        AND before_fmad.matl_id = otd.matl_id
        AND before_fmad.day_dt >= (CURRENT_DATE-62)

    LEFT OUTER JOIN na_bi_vws.inventory ocd
        ON ocd.day_dt = otd.order_dt
        AND ocd.facility_id = otd.facility_id
        AND ocd.matl_id = otd.matl_id
        AND ocd.day_dt >= (CURRENT_DATE-62)

    LEFT OUTER JOIN (
                SELECT
                    fm.facility_id AS ship_facility_id,
                    fm.matl_id AS matl_id,
                    CAST( CASE fm.spcl_prcu_typ_cd
                        WHEN 'AA' THEN 'N501'
                        WHEN 'AB' THEN 'N502'
                        WHEN 'AC' THEN 'N503'
                        WHEN 'AD' THEN 'N504'
                        WHEN 'AE' THEN 'N505'
                        WHEN 'AH' THEN 'N508'
                        WHEN 'AI' THEN 'N509'
                        WHEN 'AJ' THEN 'N510'
                        WHEN 'AM' THEN 'N513'
                        WHEN 'S1' THEN 'N6BD'
                        WHEN 'S2' THEN 'N6BE'
                        WHEN 'S4' THEN 'N6BS'
                        WHEN 'S6' THEN 'N6J2'
                        WHEN 'S7' THEN 'N6J3'
                        WHEN 'S8' THEN 'N6J4'
                        WHEN 'S9' THEN 'N6J7'
                        WHEN 'SA' THEN 'N526'
                        WHEN 'SC' THEN 'N6A1'
                        WHEN 'SD' THEN 'N6A2'
                        WHEN 'SE' THEN 'N6A3'
                        WHEN 'SF' THEN 'N6A4'
                        WHEN 'SG' THEN 'N6A6'
                        WHEN 'SH' THEN 'N6A8'
                        WHEN 'SI' THEN 'N6A9'
                        WHEN 'SJ' THEN 'N6AA'
                        WHEN 'SL' THEN 'N6AC'
                        WHEN 'SM' THEN 'N6AE'
                        WHEN 'SN' THEN 'N6AG'
                        WHEN 'SO' THEN 'N6AH'
                        WHEN 'SQ' THEN 'N6AK'
                        WHEN 'SR' THEN 'N6AL'
                        WHEN 'SS' THEN 'N6J8'
                        WHEN 'ST' THEN 'N6AO'
                        WHEN 'SU' THEN 'N6AQ'
                        WHEN 'SV' THEN 'N6AR'
                        WHEN 'SW' THEN 'N6AS'
                        WHEN 'SX' THEN 'N6AT'
                        WHEN 'SY' THEN 'N6AX'
                        WHEN 'SZ' THEN 'N6BB'
                        WHEN 'WA' THEN 'N637'
                        WHEN 'WB' THEN 'N636'
                        WHEN 'WF' THEN 'N623'
                        WHEN 'WG' THEN 'N639'
                        WHEN 'WH' THEN 'N699'
                        WHEN 'WK' THEN 'N602'
                        ELSE COALESCE(fmx.facility_id, '')
                    END AS CHAR(4) ) AS src_facility_id
                FROM gdyr_vws.facility_matl fm
                    INNER JOIN gdyr_vws.matl m
                        ON m.matl_id = fm.matl_id
                        AND m.exp_dt = DATE '5555-12-31'
                        AND m.orig_sys_id = fm.orig_sys_id
                        AND m.sbu_id = fm.sbu_id
                        AND m.src_sys_id = fm.src_sys_id
                        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                    LEFT OUTER JOIN gdyr_vws.facility_matl fmx
                        ON fmx.exp_dt = DATE '5555-12-31'
                        AND fmx.matl_id = fm.matl_id
                        AND fmx.sbu_id = fm.sbu_id 
                        AND fmx.orig_sys_id = fm.orig_sys_id
                        AND fmx.src_sys_id = fm.src_sys_id
                        AND fmx.mrp_type_id = 'X0'
                WHERE
                    fm.sbu_id = 2 
                    AND fm.orig_sys_id = 2
                    AND fm.exp_dt = DATE '5555-12-31'
                    AND fm.mrp_type_id = 'XB'
                GROUP BY
                    fm.facility_id,
                    fm.matl_id,
                    src_facility_id
                ) src
        ON src.matl_id = otd.matl_id
        AND src.ship_facility_id = otd.facility_id

    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fs
        ON fs.facility_id = src.src_facility_id
        AND fs.facility_type_id NOT IN ('N', '')

    LEFT OUTER JOIN (
                SELECT
                    fmc.matl_id,
                    fmc.facility_id,
                    MAX(fmc.lvl_grp_id) AS lvl_grp_id,
                    COUNT(DISTINCT fmc.lvl_grp_id) (DECIMAL(15,3)) AS lvl_grp_cnt
                FROM na_vws.facl_matl_cycasgn fmc
                    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr m
                        ON m.matl_id = fmc.matl_id
                        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                        AND m.super_brand_id IN ('01', '02', '03', '05')
                    INNER JOIN (
                            SELECT
                                f.matl_id,
                                f.facility_id,
                                MAX(f.lvl_design_eff_dt) AS max_ld_eff_dt
                            FROM na_vws.facl_matl_cycasgn f
                            WHERE
                                f.exp_dt = CAST('5555-12-31' AS DATE)
                                AND (CURRENT_DATE-1) >= f.lvl_design_eff_dt
                                AND f.lvl_design_sta_cd = 'A'
                                AND f.sbu_id = 2
                                AND f.orig_sys_id = 2
                                AND f.src_sys_id = 2
                            GROUP BY
                                f.matl_id,
                                f.facility_id
                            ) lim
                        ON lim.matl_id = fmc.matl_id
                        AND lim.facility_id = fmc.facility_id
                        AND lim.max_ld_eff_dt = fmc.lvl_design_eff_dt
                WHERE
                    fmc.exp_dt = CAST('5555-12-31' AS DATE)
                    AND (CURRENT_DATE-1) >= fmc.lvl_design_eff_dt
                    AND fmc.lvl_design_sta_cd = 'A'
                    AND fmc.sbu_id = 2
                    AND fmc.orig_sys_id = 2
                    AND fmc.src_sys_id = 2
                GROUP BY
                    fmc.matl_id,
                    fmc.facility_id
            ) ld
        ON ld.facility_id = src.src_facility_id
        AND ld.matl_id = otd.matl_id

ORDER BY
    otd.order_id,
    otd.order_line_nbr,
    otd.metric_type
