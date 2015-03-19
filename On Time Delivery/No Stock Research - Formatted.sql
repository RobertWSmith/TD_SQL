SELECT
    otd.metric_type AS "Metric Type",
    otd.order_id AS "Order ID",
    otd.order_line_nbr AS "Order Line Nbr",
    otd.complete_ind AS "Metric Complete Ind",
    otd.complete_dt AS "Metric Complete Date",

    otd.matl_id AS "Material ID",
    matl.matl_no_8 || ' - ' || matl.descr AS "Material Description",
    matl.pbu_nbr AS "PBU Nbr",
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
    matl.brand_id || ' - ' || matl.brand_name AS "Brand",
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS "Market Area",
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name AS "Market Group",
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name AS "Product Group",
    matl.prod_line_nbr || ' - ' || matl.prod_line_name AS "Product Line",
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS "Category",
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS "Segment",
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS "Tier",
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS "Sales Product Line",
    matl.ext_matl_grp_id AS "External Material Group ID",
    matl.matl_prty AS "Material Priority",
    matl.matl_sta_id AS "Material Status ID",
    matl.tic_cd AS "TIC Code",
    matl.sal_ind AS "SAL Ind",
    COALESCE(pal.pal_ind, '') AS "PAL Ind",
    matl.hva_txt AS "HVA Text",
    matl.hmc_txt AS "HMC Text",
    matl.target_mkt_segment AS "Target Market Segment",
    src.src_facility_id AS "Source Facility ID",
    fs.fac_name AS "Source Facility Name",
    ld.lvl_grp_id AS "Level Design",
    ld.grn_tire_ctgy_cd AS "Green Tire Category Code",
    ld.mold_adj_inv_qty AS "Adjusted Mold Inventory Qty",
    ld.dy_sply_inv_qty AS "Day Supply Inventory Qty",
    ld.safe_stk_qty AS "Safety Stock Qty",
    ld.min_run_qty AS "Miniumum Run Qty",

    otd.ship_to_cust_id AS "Ship To Customer ID",
    cust.ship_to_cust_id || ' - ' || cust.cust_name AS "Ship To Customer",
    cust.own_cust_id AS "Common Owner ID",
    cust.own_cust_id || ' - ' || cust.own_cust_name  AS "Common Owner",
    cust.sales_org_cd AS "Sales Org Code",
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS "Sales Organization",
    cust.distr_chan_cd AS "Distribution Channel Code",
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS "Distribution Channel",
    cust.tire_cust_typ_cd AS "OE / Replacement Ind",

    cust.cust_grp_id AS "Customer Group ID",
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS "Customer Group",

    cust.cust_grp2_cd AS "Customer Group 2 Code",
    cg2.cust_grp2_cd || ' - ' || cg2.cust_grp2_desc AS "Customer Group 2",

    otd.facility_id AS "Facility ID",
    fac.fac_name AS "Facility Name",

    otd.order_dt AS "Order Date",
    sd.src_crt_tm AS "Order Header Create TS",
    sdi.src_crt_ts AS "Order Line Create TS",
    ods.cust_rdd AS ORDD,
    otd.day_before_fmad AS "Day Before FMAD",
    otd.fmad AS FMAD,
    otd.fpgi AS FPGI,
    otd.metric_dt AS "Metric Date",
    ods.frst_rdd AS "FRDD",
    ods.frst_prom_deliv_dt AS "FCDD",

    ods.cancel_dt AS "Cancel Date",
    ods.rej_reas_id AS "Reason for Rejection ID",
    ods.rej_reas_id || ' - ' || ods.rej_reas_desc AS "Reason for Rejection",

    otd.a_ind AS "Appointment Ind",
    otd.cust_appt_dt AS "Customer Appointment Date",
    otd.max_edi_deliv_dt AS "Max EDI Delivery Date",
    otd.max_sap_deliv_dt AS "Max SAP Delivery Date",
    otd.actl_deliv_dt AS "Calculated Delivery Date",

    otd.hit_desc AS "Metric Hit Description",

    otd.order_qty AS "Order Qty",
    ods.sl_cnfrm_qty AS "Confirmed Qty",
    otd.hit_qty AS "Hit Qty",
    otd.ontime_qty AS "On Time Qty",
    otd.cancel_qty AS "Cancel Qty",
    otd.rel_late_qty AS "Release Late Qty",
    otd.rel_ontime_qty AS "Release On Time Qty",
    otd.commit_ontime_qty AS "Commit On Time Qty",
    otd.deliv_late_qty AS "Delivered Late Qty",
    otd.deliv_ontime_qty AS "Delivered On Time Qty",

    otd.return_hit_qty AS "Return Hit Qty",
    otd.claim_hit_qty AS "Claim Hit Qty",
    otd.freight_policy_hit_qty AS "Freight Policy Hit Qty",
    otd.phys_log_hit_qty AS "Physical Logistics Hit Qty",
    otd.man_blk_hit_qty AS "Manual Block Hit Qty",
    otd.credit_hold_hit_qty AS "Credit Hold Hit Qty",
    otd.no_stock_hit_qty AS "No Stock Hit Qty",
    otd.cancel_hit_qty AS "Cancel Hit Qty",
    otd.cust_gen_hit_qty AS "Customer Generated Hit Qty",
    otd.man_rel_cust_gen_hit_qty AS "Manual Release Cust. Gen. Hit Qty",
    otd.man_rel_hit_qty AS "Manual Release Hit Qty",
    otd.other_hit_qty AS "Other Hit Qty",

    fmad.avail_to_prom_qty AS "FMAD ATP Qty",
    fmad.tot_qty AS "FMAD Total Inventory Qty",
    fmad.sto_inbound_qty AS "FMAD STO Inbound Qty",

    before_fmad.avail_to_prom_qty AS "Day Before FMAD ATP Qty",
    before_fmad.tot_qty AS "Day Before FMAD Total Inv. Qty",
    before_fmad.sto_inbound_qty AS "Day Before FMAD STO Inbound Qty",

    ocd.avail_to_prom_qty AS "Order Create ATP Qty",
    ocd.tot_qty AS "Order Create Total Inventory Qty",
    ocd.sto_inbound_qty AS "Order Create STO Inbound Qty",

    CASE
        WHEN (fmad.avail_to_prom_qty = 0 OR before_fmad.avail_to_prom_qty = 0)
            THEN 'No Stock'
        WHEN fmad.avail_to_prom_qty IS NULL
            THEN 'Unknown Issue'
        ELSE 'Other Issue'
    END AS "Macro No Stock Issue",

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
    END AS "Micro No Stock Issue",
    CASE
        WHEN otd.metric_type = 'FCDD'
            THEN fcdd.src_crt_dt
    END AS "FCDD Last Update Date",
    CASE
        WHEN otd.metric_type = 'FCDD'
            THEN CAST(otd.metric_dt - fcdd.src_crt_dt AS INTEGER)
    END AS "FCDD Update Date to FCDD (days)",
    CASE
        WHEN otd.metric_type = 'FCDD' AND CAST(otd.metric_dt - fcdd.src_crt_dt AS INTEGER) > 56
            THEN 'Confirming at 9+ Weeks'
        ELSE 'Confirming within 8 Weeks'
    END AS "FCDD Update to FCDD Description"

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
        pol.spcl_proc_id,
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
        pol.spcl_proc_id,
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

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = otd.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = otd.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_id = otd.order_id
        AND ods.order_line_nbr = otd.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

    LEFT OUTER JOIN na_bi_vws.cust_grp2_desc_en_curr cg2
        ON cg2.cust_grp2_cd = cust.cust_grp2_cd

    LEFT OUTER JOIN gdyr_bi_vws.nat_sls_doc_curr sd
        ON sd.fiscal_yr = ods.order_fiscal_yr
        AND sd.sls_doc_id = otd.order_id

    LEFT OUTER JOIN gdyr_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.fiscal_yr = ods.order_fiscal_yr
        AND sdi.sls_doc_id = otd.order_id
        AND sdi.sls_doc_itm_id = otd.order_line_nbr

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
                fmc.*

            FROM na_vws.facl_matl_cycasgn fmc

            WHERE
                fmc.lvl_design_sta_cd = 'A'
                AND fmc.exp_dt = CAST('5555-12-31' AS DATE)
                AND fmc.sbu_id = 2
                AND fmc.orig_sys_id = 2
                AND fmc.src_sys_id = 2
                AND (fmc.matl_id, fmc.facility_id, fmc.lvl_grp_id, fmc.lvl_design_eff_dt) IN (

                SELECT
                    fmc.matl_id,
                    fmc.facility_id,
                    MAX(fmc.lvl_grp_id) AS lvl_grp_id,
                    lim.max_ld_eff_dt

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
                    fmc.facility_id,
                    lim.max_ld_eff_dt
                )
            ) ld
        ON ld.facility_id = src.src_facility_id
        AND ld.matl_id = otd.matl_id

    LEFT OUTER JOIN (
                SELECT
                    fp.*

                FROM na_vws.ord_fpdd fp

                    INNER JOIN (
                                SELECT
                                    f.order_fiscal_yr,
                                    f.order_id,
                                    f.order_line_nbr,
                                    f.seq_id,
                                    f.frst_prom_deliv_dt
                                FROM na_vws.ord_fpdd f
                                WHERE
                                    f.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                                    AND f.exp_dt = DATE '5555-12-31'
                                QUALIFY
                                    ROW_NUMBER() OVER (PARTITION BY f.order_fiscal_yr, f.order_id, f.order_line_nbr ORDER BY f.frst_prom_deliv_dt DESC, f.src_crt_dt DESC, f.src_crt_tm DESC) = 1
                            ) lim
                        ON lim.order_fiscal_yr = fp.order_fiscal_yr
                        AND lim.order_id = fp.order_id
                        AND lim.order_line_nbr = fp.order_line_nbr
                        AND lim.seq_id = fp.seq_id
                        AND lim.frst_prom_deliv_dt = fp.frst_prom_deliv_dt

                WHERE
                    fp.exp_dt = DATE '5555-12-31'
                    AND fp.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
            ) fcdd
        ON fcdd.order_id = otd.order_id
        AND fcdd.order_line_nbr = otd.order_line_nbr

/*
-- qualify statement validates one record per unique key
    -- run this after any changes to validate that zero records are returned.
QUALIFY
    COUNT(*) OVER (PARTITION BY otd.order_id, otd.order_line_nbr, otd.metric_type) > 1
*/

ORDER BY
    otd.order_id,
    otd.order_line_nbr,
    otd.metric_type
