SELECT
    sq.own_cust_id || ' - ' || sq.own_cust_name AS "Common Owner",
    sq.pbu_nbr || ' - ' || sq.pbu_name AS PBU,
    sq.matl_id AS "Material ID",
    sq.matl_no_8 || ' - ' || sq.descr AS "Material Description",
    sq.tiers AS "Tiers",
    sq.super_brand_id || ' - ' || sq.super_brand_name AS "Super Brand",
    sq.mkt_ctgy_mkt_area_nbr || ' - ' || sq.mkt_ctgy_mkt_area_name AS "Category Mkt. Area",
    sq.mkt_ctgy_mkt_grp_nbr || ' - ' || sq.mkt_ctgy_mkt_area_nbr AS "Category Mkt. Group",
    sq.matl_prty_descr AS "Material Priority",
    sq.deliv_blk_ind AS "Delivery Block Flag",
    sq.facility_id || ' - ' || sq.fac_name AS "Ship Facility",
    sq.src_facility_id AS "Source Facility ID",
    sq.weeks_past_frdd AS "Weeks Past FRDD",
    sq.open_cnfrm_qty AS "Open Confirmed Qty",
    -- SUM(sq.open_cnfrm_qty) OVER (PARTITION BY sq.own_cust_id, sq.matl_id, sq.facility_id, sq.deliv_blk_ind ORDER BY sq.weeks_past_frdd DESC ROWS UNBOUNDED PRECEDING) AS "Cum. Open Confirmed Qty",
    sq.back_order_qty AS "Back Order Qty",
    -- SUM(sq.back_order_qty) OVER (PARTITION BY sq.own_cust_id, sq.matl_id, sq.facility_id, sq.deliv_blk_ind ORDER BY sq.weeks_past_frdd DESC ROWS UNBOUNDED PRECEDING) AS "Cum. Back Order Qty",
    sq.tot_past_due_qty AS "Total Past Due Qty"
    --SUM(sq.tot_past_due_qty) OVER (PARTITION BY sq.own_cust_id, sq.matl_id, sq.facility_id, sq.deliv_blk_ind ORDER BY sq.weeks_past_frdd DESC ROWS UNBOUNDED PRECEDING) AS "Cum. Total Past Due Qty"
    
FROM (

    SELECT
        q.own_cust_id,
        q.own_cust_name,
        q.pbu_nbr,
        q.pbu_name,
        q.matl_id,
        q.matl_no_8,
        q.descr,
        q.tiers,
        q.super_brand_id,
        q.super_brand_name,
        q.deliv_blk_ind,
        q.mkt_ctgy_mkt_area_nbr,
        q.mkt_ctgy_mkt_area_name,
        q.mkt_ctgy_mkt_grp_nbr,
        q.mkt_ctgy_mkt_grp_name,
        q.mkt_area_nbr,
        q.mkt_area_name,
        q.mkt_grp_nbr,
        q.mkt_grp_name,
        q.matl_prty_descr,
        q.facility_id,
        q.fac_name,
        q.src_facility_id,
        q.weeks_past_frdd,
        SUM(q.open_cnfrm_qty) AS open_cnfrm_qty,
        SUM(q.back_order_qty) AS back_order_qty,
        SUM(q.tot_past_due_qty) AS tot_past_due_qty
    
    FROM (
        
        SELECT
            odc.order_id,
            odc.order_line_nbr,
            odc.sched_line_nbr,
            
            odc.ship_to_cust_id,
            cust.cust_name AS ship_to_cust_name,
            cust.own_cust_id,
            cust.own_cust_name,
            cust.sales_org_cd,
            cust.sales_org_name,
            cust.distr_chan_cd,
            cust.distr_chan_name,
            odc.cust_grp2_cd,
            cg2.cust_grp2_desc,
            
            odc.matl_id,
            matl.matl_no_8,
            matl.descr,
            matl.pbu_nbr,
            matl.pbu_name,
            matl.tiers,
            matl.super_brand_id,
            matl.super_brand_name,
            matl.mkt_ctgy_mkt_area_nbr,
            matl.mkt_ctgy_mkt_area_name,
            matl.mkt_ctgy_mkt_grp_nbr,
            matl.mkt_ctgy_mkt_grp_name,
            matl.mkt_area_nbr,
            matl.mkt_area_name,
            matl.mkt_grp_nbr,
            matl.mkt_grp_name,
            matl.matl_prty_descr,
            
            odc.facility_id,
            fac.fac_name,
            CAST( CASE FM.SPCL_PRCU_TYP_CD
                WHEN 'AA' THEN 'N501'
                WHEN 'AB' THEN 'N502'
                WHEN 'AC' THEN 'N503'
                WHEN 'AD' THEN 'N504'
                WHEN 'AE' THEN 'N505'
                WHEN 'AH' THEN 'N508'
                WHEN 'AI' THEN 'N509'
                WHEN 'AJ' THEN 'N510'
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
                ELSE FM.SPCL_PRCU_TYP_CD
            END AS CHAR(4) ) AS src_facility_id,
            
            odc.deliv_blk_cd,
            odc.deliv_blk_ind,
            ool.credit_hold_flg,
            
            odc.frst_rdd AS FRDD,
            odc.frst_prom_deliv_dt AS FCDD,
            CASE WHEN ool.open_cnfrm_qty > 0 
                THEN odc.pln_deliv_dt
            END AS PDD,
            CAST((CURRENT_DATE - odc.frst_rdd) AS INTEGER) AS days_past_frdd,
            CAST(days_past_frdd / 7 AS INTEGER) AS weeks_past_frdd,
            CAST((CURRENT_DATE - odc.frst_prom_deliv_dt) AS INTEGER) AS days_past_fcdd,
            CAST((CURRENT_DATE - pdd) AS INTEGER) AS days_to_pdd,
            CAST((pdd - odc.frst_rdd) AS INTEGER) AS days_bw_pdd_and_frdd,
            
            ool.open_cnfrm_qty,
            ool.uncnfrm_qty + ool.back_order_qty AS back_order_qty,
            ool.open_cnfrm_qty + ool.uncnfrm_qty + ool.back_order_qty AS tot_past_due_qty
        
        FROM na_bi_vws.open_order_schdln_curr ool
        
            INNER JOIN na_bi_vws.order_detail_curr odc
                ON odc.order_id = ool.order_id
                AND odc.order_line_nbr = ool.order_line_nbr
                AND odc.sched_line_nbr = ool.sched_line_nbr
                AND odc.order_cat_id = 'C'
                AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
                AND odc.po_type_id <> 'RO'
                AND odc.frst_rdd < CURRENT_DATE
                
            LEFT OUTER JOIN gdyr_vws.facility_matl fm
                ON fm.exp_dt = CAST('5555-12-31' AS DATE)
                AND fm.facility_id = odc.facility_id
                AND fm.matl_id = odc.matl_id
                AND fm.sbu_id = 2
                AND fm.src_sys_id = 2
                AND fm.orig_sys_id = 2
                AND fm.mrp_type_id IN ( 'X0', 'X1', 'XB' )
        
            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = odc.matl_id
                AND matl.pbu_nbr IN ('01', '03')
        
            INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
                ON cust.ship_to_cust_id = odc.ship_to_cust_id
        
            LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
                ON fac.facility_id = odc.facility_id
        
            LEFT OUTER JOIN na_bi_vws.cust_grp2_desc_en_curr cg2
                ON cg2.cust_grp2_cd = odc.cust_grp2_cd
        
        WHERE
            ool.open_cnfrm_qty > 0
            OR ool.uncnfrm_qty > 0
            OR ool.back_order_qty > 0
            OR (ool.defer_qty + ool.in_proc_qty + ool.wait_list_qty + ool.othr_order_qty) > 0
        
        ) q
    
    GROUP BY
        q.own_cust_id,
        q.own_cust_name,
        q.pbu_nbr,
        q.pbu_name,
        q.matl_id,
        q.matl_no_8,
        q.descr,
        q.tiers,
        q.super_brand_id,
        q.super_brand_name,
        q.deliv_blk_ind,
        q.mkt_ctgy_mkt_area_nbr,
        q.mkt_ctgy_mkt_area_name,
        q.mkt_ctgy_mkt_grp_nbr,
        q.mkt_ctgy_mkt_grp_name,
        q.mkt_area_nbr,
        q.mkt_area_name,
        q.mkt_grp_nbr,
        q.mkt_grp_name,
        q.matl_prty_descr,
        q.facility_id,
        q.fac_name,
        q.src_facility_id,
        q.weeks_past_frdd
        
    ) sq