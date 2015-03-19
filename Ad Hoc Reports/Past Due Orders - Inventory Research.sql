SELECT
    q.order_fiscal_yr AS "Order Fiscal Year",
    q.order_id AS "Order ID",
    q.order_line_nbr AS "Order Line Nbr",
    q.sched_line_nbr AS "Schedule Line Nbr",
    
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.own_cust_id AS "Common Owner ID",
    q.own_cust_name AS "Common Owner Name",
    q.cust_grp AS "Customer Group",
    q.sales_org AS "Sales Organization",
    q.distr_chan AS "Distribution Channel",
    
    q.matl_id AS "Material ID",
    q.matl_descr AS "Material Description",
    q.tic_cd AS "TIC Code",
    q.pbu_nbr AS "PBU Nbr",
    q.pbu AS PBU,
    q.ext_matl_grp_id AS "External Material Group ID",
    q.matl_prty AS "Material Priority",
    q.matl_sta_id AS "Material Status ID",
    q.hva_txt AS "HVA Text",
    q.hmc_txt AS "HMC Text",
    q.sal_ind AS "SAL Ind",
    q.pal_ind AS "PAL Ind",
    
    q.category AS "Category",
    q.mkt_area AS "Market Area",
    
    q.credit_hold_flg AS "Credit Hold Flag",
    
    q.order_cat_id AS "Order Category ID",
    q.order_type_id AS "Order Type ID",
    q.po_type_id AS "PO Type ID",
    
    q.route_id AS "Route ID",
    q.cust_grp2_cd AS "Customer Group 2 Code",
    q.deliv_blk_cd AS "Delivery Block Code",
    q.deliv_prty_id AS "Delivery Priority ID",
    q.order_creator AS "Order Creator",
    q.ship_cond_id AS "Shipping Condition ID",
    q.deliv_grp_cd AS "Delivery Group Code",
    q.spcl_proc_id AS "Special Processing Ind",
    q.spcl_proc_desc AS "Special Processing Type",
    
    q.order_dt AS "Order Create Date",
    q.ordd AS "ORDD",
    q.first_date AS "First Date",
    
    q.frdd_fmad AS "FRDD FMAD",
    q.frdd_fpgi AS "FRDD FPGI",
    q.frdd AS "FRDD",
    
    q.fcdd_fmad AS "FCDD FMAD",
    q.fcdd_fpgi AS "FCDD FPGI",
    q.fcdd AS "FCDD",
    
    q.pln_transp_pln_dt AS "Planned Trans. Planning Date",
    q.pln_matl_avl_dt AS "Planned Matl. Avail. Date",
    q.pln_load_dt AS "Planned Load Date",
    q.pln_goods_iss_dt AS "Planned Goods Iss. Date",
    q.pln_deliv_dt AS "Planned Delivery Date",
    q.fcdd_evaluation AS "Current FCDD Evaluation",
    
    q.order_dt_to_frdd_days AS "Days from Order Create to FRDD",
    
    q.frdd_fmad_to_today AS "Days from FRDD FMAD to Today",
    q.frdd_to_today AS "Days from FRDD to Today",
    
    q.days_to_pln_mad AS "Days to Planned MAD",
    q.days_to_pdd AS "Days to Planned Delivery",
    
    q.qty_uom AS "Quantity UOM",
    q.past_due_qty AS "Past Due Qty",
    
    q.curr_ship_facility_id AS "Current Ship Facility ID",
    q.curr_ship_facility_name AS "Current Ship Facility Name",
    q.ship_pt_id AS "Current Ship Point ID",
    q.curr_src_facility_id AS "Current Source Facility ID",
    q.curr_src_facility_name AS "Current Source Facility Name",
    q.curr_atp_qty AS "Current ATP Qty",
    q.curr_tot_qty AS "Current Total Qty",
    q.curr_sto_inbound_qty AS "Current STO Inbound Qty",
    q.curr_unrstr_qty AS "Current Unrestricted Qty",
    
    q.fmad_facility_id AS "FRDD FMAD Ship Facility ID",
    q.frdd_fmad_atp_qty AS "FRDD FMAD ATP Qty",
    q.frdd_fmad_tot_qty AS "FRDD FMAD Total Qty",
    q.frdd_fmad_sto_inbound_qty AS "FRDD FMAD STO Inbound Qty",
    q.frdd_fmad_unrstr_qty AS "FRDD FMAD Unrestricted Qty",
    
    q.before_fmad_facility_id AS "Before FMAD Ship Facility ID",
    q.before_frdd_fmad_atp_qty AS "Before FMAD ATP Qty",
    q.before_frdd_fmad_tot_qty AS "Before FMAD Total Qty",
    q.before_frdd_fmad_sto_inbound_qty AS "Before FMAD STO Inbound Qty",
    q.before_frdd_fmad_unrstr_qty AS "Before FMAD Unrestricted Qty"
        
FROM (

SELECT
    ool.order_fiscal_yr,
    ool.order_id,
    ool.order_line_nbr,
    ool.sched_line_nbr,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.tic_cd,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.ext_matl_grp_id,
    matl.matl_prty,
    matl.matl_sta_id,
    matl.hva_txt,
    matl.hmc_txt,
    matl.sal_ind,
    COALESCE(pal.pal_ind, '') AS pal_ind,
    
    matl.mkt_ctgy_mkt_area_nbr || ' - '  || matl.mkt_ctgy_mkt_area_name AS category,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    
    ool.credit_hold_flg,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    
    odc.route_id,
    odc.cust_grp2_cd,
    odc.deliv_blk_cd,
    odc.deliv_prty_id,
    odc.order_creator,
    odc.ship_cond_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    CAST(CASE odc.spcl_proc_id
        WHEN 'EDI' THEN 'Delivery By Date Change for Appts'
        WHEN 'OCGL' THEN 'Customer Generated Later'
        WHEN 'OCGS' THEN 'Customer Generated Sooner'
        WHEN 'OCUA' THEN 'Customer Unwilling to Accept'
        WHEN 'OERR' THEN 'Order Errors'
        WHEN 'OFPS' THEN 'Freight Policy System'
        WHEN 'OMAR' THEN 'Age Restriction - AR'
        WHEN 'OMBR' THEN 'Business Request'
        WHEN 'OMCR' THEN 'Credit Review - CR'
        WHEN 'OMMS' THEN 'Markings/Stampings Issue'
        WHEN 'OMNS' THEN 'VL10E Zero Qty Avail'
        WHEN 'OMPD' THEN 'PD Block'
        WHEN 'OMUO' THEN 'Unplanned Large Order (N5US)'
        WHEN 'ONRD' THEN 'Non Realistic Date'
        WHEN 'RF11' THEN 'Plant Held Shipment'
        WHEN 'RF21' THEN 'Diversion'
        WHEN 'RF31' THEN 'Duplicate Shipment'
        WHEN 'RF41' THEN 'SAP Error'
        WHEN 'RF12' THEN 'LC Weather Related Issue'
        WHEN 'RL22' THEN 'LC IT Disruption'
        WHEN 'RL32' THEN 'Space Constraint'
        WHEN 'RL42' THEN 'Load Discrepancy'
        WHEN 'RL52' THEN 'Equipment Constraint'
        WHEN 'RL62' THEN 'Outbound Volume > Capacity'
        WHEN 'RL72' THEN 'Inbound Volume > Capacity'
        WHEN 'RL82' THEN 'Inventory Adjustment'
        WHEN 'RL92' THEN 'Failure to Report Load'
        WHEN 'RLA2' THEN 'Export Shipment'
        WHEN 'RT13' THEN 'Transportation Planning Error'
        WHEN 'RT23' THEN 'Carrier Not Able to Comply'
        WHEN 'RT33' THEN 'Carrier Equipment'
        WHEN 'RT43' THEN 'Carrier Error (Reschedule, No Show, Late)'
        WHEN 'RT53' THEN 'Transportation IT Disruption'
        WHEN 'RT63' THEN 'Wingfoot Backhaul'
        WHEN 'RT73' THEN 'Carrier Weather Related Incident'
        WHEN 'RT83' THEN 'Trailer Theft'
        WHEN 'RT93' THEN 'Delay in Consolidation'
        WHEN 'RTA3' THEN 'Delay from Transportation Planning'
        WHEN 'RTB3' THEN 'Import Delay'
        WHEN 'RTC3' THEN 'Customer Appointment Change'
        WHEN 'RZZZ' THEN 'Other/Unknown'
        ELSE ''
    END AS VARCHAR(255)) AS spcl_proc_desc,
    
    odc.order_dt,
    odc.cust_rdd AS ordd,
    fd.pln_deliv_dt AS first_date,
    
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    
    COALESCE(odc.fc_matl_avl_dt, fcdd - (frdd - frdd_fmad)) AS fcdd_fmad,
    COALESCE(odc.fc_pln_goods_iss_dt, fcdd - (frdd - frdd_fpgi)) AS fcdd_fpgi,
    odc.frst_prom_deliv_dt AS fcdd,
    
    odc.pln_transp_pln_dt,
    odc.pln_matl_avl_dt,
    odc.pln_load_dt,
    odc.pln_goods_iss_dt,
    odc.pln_deliv_dt,
    CAST(CASE
        WHEN odc.pln_deliv_dt <= odc.frst_prom_deliv_dt
            THEN 'FCDD - Planned On Time'
        WHEN odc.pln_deliv_dt > odc.frst_prom_deliv_dt
            THEN 'FCDD - Late'
    END AS VARCHAR(55)) AS fcdd_evaluation,
    
    CAST(frdd - odc.order_dt AS INTEGER) AS order_dt_to_frdd_days,
    
    CAST(CURRENT_DATE - frdd_fmad AS INTEGER) AS frdd_fmad_to_today,
    CAST(CURRENT_DATE - frdd AS INTEGER) AS frdd_to_today,
    
    CAST(odc.pln_matl_avl_dt - CURRENT_DATE AS INTEGER) AS days_to_pln_mad,
    CAST(odc.pln_deliv_dt - CURRENT_DATE AS INTEGER) AS days_to_pdd,
    
    odc.qty_unit_meas_id AS qty_uom,
    ZEROIFNULL(ool.open_cnfrm_qty) AS past_due_qty,
    
    odc.facility_id AS curr_ship_facility_id,
    fac.fac_name AS curr_ship_facility_name,
    odc.ship_pt_id,
    src.source_facility_id AS curr_src_facility_id,
    src.source_facility_name AS curr_src_facility_name,
    invc.avail_to_prom_qty AS curr_atp_qty,
    invc.tot_qty AS curr_tot_qty,
    invc.sto_inbound_qty AS curr_sto_inbound_qty,
    invc.unrstr_qty AS curr_unrstr_qty,
    
    sdi_fmad.facility_id AS fmad_facility_id,
    sl_fmad.schd_ln_deliv_blk_cd AS fmad_sl_deliv_blk_cd,
    fmad.avail_to_prom_qty AS frdd_fmad_atp_qty,
    fmad.tot_qty AS frdd_fmad_tot_qty,
    fmad.sto_inbound_qty AS frdd_fmad_sto_inbound_qty,
    fmad.unrstr_qty AS frdd_fmad_unrstr_qty,
    
    sdi_b4_fmad.facility_id AS before_fmad_facility_id,
    before_fmad.avail_to_prom_qty AS before_frdd_fmad_atp_qty,
    before_fmad.tot_qty AS before_frdd_fmad_tot_qty,
    before_fmad.sto_inbound_qty AS before_frdd_fmad_sto_inbound_qty,
    before_fmad.unrstr_qty AS before_frdd_fmad_unrstr_qty

FROM na_vws.open_order_schdln ool
    
    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_fiscal_yr = ool.order_fiscal_yr
        AND odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND odc.po_type_id <> 'RO'
        AND odc.frst_rdd < CURRENT_DATE
    
    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr = '01'
        -- AND matl.pbu_nbr IN ('01', '03')
        AND matl.super_brand_id IN ('01', '02', '03', '05')
        AND matl.mkt_area_nbr <> '04'
    
    LEFT OUTER JOIN gdyr_bi_vws.nat_matl_pal_curr pal
        ON pal.matl_id = matl.matl_id
    
    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
    
    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = odc.facility_id
    
    LEFT OUTER JOIN na_bi_vws.nat_sls_doc_itm sdi_fmad
        ON sdi_fmad.fiscal_yr = ool.order_fiscal_yr
        AND sdi_fmad.sls_doc_id = ool.order_id
        AND sdi_fmad.sls_doc_itm_id = ool.order_line_nbr
        AND odc.frst_matl_avl_dt BETWEEN sdi_fmad.eff_dt AND sdi_fmad.exp_dt
    
    LEFT OUTER JOIN na_bi_vws.nat_sls_doc_schd_ln sl_fmad
        ON sl_fmad.fiscal_yr = odc.order_fiscal_yr
        AND sl_fmad.sls_doc_id = odc.order_id
        AND sl_fmad.sls_doc_itm_id = odc.order_line_nbr
        AND sl_fmad.schd_ln_id = odc.sched_line_nbr
        AND odc.frst_matl_avl_dt BETWEEN sl_fmad.eff_dt AND sl_fmad.exp_dt

    LEFT OUTER JOIN na_bi_vws.nat_sls_doc_itm sdi_b4_fmad
        ON sdi_b4_fmad.fiscal_yr = ool.order_fiscal_yr
        AND sdi_b4_fmad.sls_doc_id = ool.order_id
        AND sdi_b4_fmad.sls_doc_itm_id = ool.order_line_nbr
        AND CAST(odc.frst_matl_avl_dt - 1 AS DATE) BETWEEN sdi_b4_fmad.eff_dt AND sdi_b4_fmad.exp_dt
    
    LEFT OUTER JOIN na_bi_vws.order_detail_curr fd
        ON fd.order_fiscal_yr = ool.order_fiscal_yr
        AND fd.order_id = ool.order_id
        AND fd.order_line_nbr = ool.order_line_nbr
        AND fd.sched_line_nbr = 1
    
    LEFT OUTER JOIN gdyr_bi_vws.nat_inv_curr invc
        ON invc.day_dt = (CURRENT_DATE-1)
        AND invc.facility_id = odc.facility_id
        AND invc.matl_id = odc.matl_id
    
    LEFT OUTER JOIN gdyr_bi_vws.nat_inv_daily fmad
        ON fmad.day_dt = odc.frst_matl_avl_dt
        AND fmad.facility_id = sdi_fmad.facility_id
        AND fmad.matl_id = sdi_fmad.matl_id
        AND fmad.day_dt >= (CURRENT_DATE-62)

    LEFT OUTER JOIN gdyr_bi_vws.nat_inv_daily before_fmad
        ON before_fmad.day_dt = CAST(odc.frst_matl_avl_dt - 1 AS DATE)
        AND before_fmad.facility_id = sdi_b4_fmad.facility_id
        AND before_fmad.matl_id = sdi_b4_fmad.matl_id
        AND before_fmad.day_dt >= (CURRENT_DATE-62)
    
    LEFT OUTER JOIN (
                SELECT
                    fm.facility_id AS ship_facility_id,
                    f.name AS ship_facility_name,
                    fm.matl_id,
                    m.pbu_nbr,
                    m.matl_grp_cd,
                    m.matl_sta_id,
                    m.matl_type_id,
                    m.ext_matl_grp_id,
                    m.stk_class_id,
                    CAST( CASE COALESCE(fm.spcl_prcu_typ_cd, fmo.spcl_prcu_typ_cd)
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
                        ELSE fmx.facility_id
                    END AS CHAR(4) ) AS source_facility_id,
                    src.fac_name AS source_facility_name
                
                FROM gdyr_vws.facility_matl fm
                
                    INNER JOIN gdyr_vws.matl m
                        ON m.matl_id = fm.matl_id
                        AND m.exp_dt = DATE '5555-12-31'
                        AND m.orig_sys_id = fm.orig_sys_id
                        AND m.sbu_id = fm.sbu_id
                        AND m.src_sys_id = fm.src_sys_id
                        AND m.matl_type_id IN ('PCTL','FWHM','ACCT','ICTL','NVAL')
                        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                
                    INNER JOIN gdyr_vws.facility f
                        ON f.facility_id = fm.facility_id
                        AND f.exp_dt = DATE '5555-12-31'
                        AND f.lang_id = 'EN'
                        AND f.sbu_id = fm.sbu_id
                        AND f.orig_sys_id = fm.orig_sys_id
                        AND f.src_sys_id = fm.src_sys_id
                        AND f.facility_activ_ind = 'Y'
                        AND f.sales_org_cd NOT IN ('N340') -- no COWD facilities
                        AND f.distr_chan_cd = '81' -- only internal, also to help exclude COWD
                        AND f.facility_type_id NOT IN ('', 'N') -- exclude missing types and non-stocking facilities
                
                    LEFT OUTER JOIN gdyr_vws.facility_matl fmo
                        ON fmo.exp_dt = DATE '5555-12-31'
                        AND fmo.matl_id = fm.matl_id
                        AND fmo.facility_id = fm.facility_id
                        AND fmo.sbu_id = fm.sbu_id
                        AND fmo.orig_sys_id = fm.orig_sys_id
                        AND fmo.src_sys_id = fm.src_sys_id
                        AND fmo.mrp_type_id = 'X1'
                
                    LEFT OUTER JOIN gdyr_vws.facility_matl fmx
                        ON fmx.exp_dt = DATE '5555-12-31'
                        AND fmx.matl_id = fm.matl_id
                        AND fmx.sbu_id = fm.sbu_id 
                        AND fmx.orig_sys_id = fm.orig_sys_id
                        AND fmx.src_sys_id = fm.src_sys_id
                        AND fmx.mrp_type_id = 'X0'
                
                    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr src
                        ON src.facility_id = source_facility_id
                
                WHERE
                    fm.sbu_id = 2 
                    AND fm.orig_sys_id = 2
                    AND fm.exp_dt = DATE '5555-12-31'
                    AND fm.mrp_type_id = 'XB'
                
                GROUP BY
                    fm.facility_id,
                    f.name,
                    fm.matl_id,
                    m.pbu_nbr,
                    m.matl_grp_cd,
                    m.matl_sta_id,
                    m.matl_type_id,
                    m.ext_matl_grp_id,
                    m.stk_class_id,
                    source_facility_id,
                    src.fac_name
            ) src
        ON src.ship_facility_id = odc.facility_id
        AND src.matl_id = odc.matl_id

WHERE
    ool.exp_dt = DATE '5555-12-31'
    AND past_due_qty > 0

    ) q

/*
-- Duplicate Record validation (should return zero records if unique)
QUALIFY
    COUNT(*) OVER (PARTITION BY q.order_fiscal_yr, q.order_id, q.order_line_nbr, q.sched_line_nbr) > 1
*/

ORDER BY
    q.order_fiscal_yr,
    q.order_id,
    q.order_line_nbr,
    q.sched_line_nbr

-- SAMPLE 10000
