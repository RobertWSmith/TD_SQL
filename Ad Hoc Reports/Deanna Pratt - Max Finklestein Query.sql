SELECT
    c.day_date AS "Order Create Date",
    c.month_dt AS "Order Create Month",
    c.day_of_week_name_desc AS "Order Create Day of Week",
    
    q.order_id AS "Order ID",
    q.order_line_nbr AS "Order Line Nbr.",
    
    q.cancel_ind AS "Cancellation Indicator",
    q.cancel_timing AS "Cancel Timing",
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.own_cust_id AS "Common Owner ID",
    q.own_cust_name AS "Common Owner Name",
    q.sales_org_cd AS "Sales Organization Code",
    q.distr_chan_cd AS "Distribution Channel Code",
    q.cust_grp_id AS "Customer Group ID",
    q.cust_grp_name AS "Customer Group Desc.",
    q.cust_grp2_cd AS "Customer Group 2 Code",
    q.cust_grp2_desc AS "Customer Group 2 Desc.",
    
    q.matl_id AS "Material ID",
    q.matl_descr AS "Material Desc.",
    q.pbu_nbr AS "PBU Nbr.",
    q.pbu_name AS "PBU Name",
    q.mkt_area_nbr AS "Market Area Nbr.",
    q.mkt_area_name AS "Market Area Name",
    q.mkt_ctgy_mkt_area_nbr AS "Category Mkt. Area Nbr.",
    q.mkt_ctgy_mkt_area_name as "Category Mkt. Area Name",
    q.mkt_grp_nbr AS "Market Group Nbr.", 
    q.mkt_grp_name AS "Market Group Name",
    q.mkt_ctgy_mkt_grp_nbr AS "Category Mkt. Group Nbr.",
    q.mkt_ctgy_mkt_grp_name AS "Category Mkt. Group Name",
    
    q.facility_id AS "Ship Facility ID",
    q.fac_name AS "Ship Facility Name",
    q.qty_uom AS "Qty. Unit of Measure",
    ZEROIFNULL(q.order_qty) AS "Ordered Qty"
    
FROM gdyr_bi_vws.gdyr_cal c

    LEFT OUTER JOIN (
        
        SELECT
            odc.order_dt,
            
            odc.order_id,
            odc.order_line_nbr,
            
            odc.rej_reas_id,
            odc.rej_reas_desc,
            odc.cancel_ind,
            odc.cancel_dt,
            CASE 
                WHEN odc.cancel_ind = 'N'
                    THEN 'Not Cancelled'
                WHEN odc.cancel_ind = 'Y' AND odc.cancel_Dt <= odc.frst_matl_avl_dt
                    THEN 'Cancelled before feasible shipment'
                WHEN odc.cancel_ind = 'Y' AND odc.cancel_dt > odc.frst_matl_avl_dt
                    THEN 'Cancelled after feasible shipment'
                ELSE 'Indeterminate'
            END AS cancel_timing,
        
            odc.ship_to_cust_id,
            cust.cust_name AS ship_to_cust_name,
            cust.own_cust_id,
            cust.own_cust_name,
            odc.sales_org_cd,
            odc.distr_chan_cd,
            
            odc.cust_grp_id,
            cg.name AS cust_grp_name,
            odc.cust_grp2_cd,
            cg2.cust_grp2_desc,
            
            odc.matl_id,
            matl.descr AS matl_descr,
            matl.matl_prty,
            matl.pbu_nbr,
            matl.pbu_name,
            matl.mkt_area_nbr,
            matl.mkt_area_name,
            matl.mkt_ctgy_mkt_area_nbr,
            matl.mkt_ctgy_mkt_area_name,
            matl.mkt_grp_nbr,
            matl.mkt_grp_name,
            matl.mkt_ctgy_mkt_grp_nbr,
            matl.mkt_ctgy_mkt_grp_name,
            
            odc.facility_id,
            fac.fac_name,
            
            odc.frst_matl_avl_dt AS frdd_fmad,
            odc.frst_pln_goods_iss_dt AS frdd_fpgi,
            odc.frst_rdd AS frdd,
            
            odc.qty_unit_meas_id AS qty_uom,
            SUM(odc.order_qty) AS order_qty
            
        FROM na_bi_vws.order_detail_curr odc
        
            INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
                ON cust.ship_to_cust_id = odc.ship_to_cust_id
                AND cust.own_cust_id = '00A0003047'
        
            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = odc.matl_id
        
            INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
                ON fac.facility_id = odc.facility_id
            
            LEFT OUTER JOIN na_bi_vws.cust_grp2_desc_en_curr cg2
                ON cg2.cust_grp2_cd = odc.cust_grp2_cd
        
            LEFT OUTER JOIN gdyr_vws.cust_grp cg
                ON cg.cust_grp_id = odc.cust_grp_id
                AND cg.lang_id IN ('E', 'EN')
                AND cg.exp_dt = DATE '5555-12-31'
                AND cg.sbu_id = 2
                AND cg.orig_sys_id = 2
                AND cg.src_sys_id = 2
        
        WHERE
            odc.order_cat_id = 'c'
            AND odc.order_type_id NOT IN ('zls', 'zlz')
            AND odc.po_type_id <> 'RO'
            AND odc.order_dt BETWEEN ADD_MONTHS(CURRENT_DATE-1, -12) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -12)) -1) AND (CURRENT_DATE-1)
        
        GROUP BY
            odc.order_dt,
            
            odc.order_id,
            odc.order_line_nbr,
            
            odc.rej_reas_id,
            odc.rej_reas_desc,
            odc.cancel_ind,
            odc.cancel_dt,
            cancel_timing,
        
            odc.ship_to_cust_id,
            cust.cust_name,
            cust.own_cust_id,
            cust.own_cust_name,
            odc.sales_org_cd,
            odc.distr_chan_cd,
            
            odc.cust_grp_id,
            cg.name,
            odc.cust_grp2_cd,
            cg2.cust_grp2_desc,
            
            odc.matl_id,
            matl.descr,
            matl.matl_prty,
            matl.pbu_nbr,
            matl.pbu_name,
            matl.mkt_area_nbr,
            matl.mkt_area_name,
            matl.mkt_ctgy_mkt_area_nbr,
            matl.mkt_ctgy_mkt_area_name,
            matl.mkt_grp_nbr,
            matl.mkt_grp_name,
            matl.mkt_ctgy_mkt_grp_nbr,
            matl.mkt_ctgy_mkt_grp_name,
            
            odc.facility_id,
            fac.fac_name,
            
            odc.frst_matl_avl_dt,
            odc.frst_pln_goods_iss_dt,
            odc.frst_rdd,
            
            odc.qty_unit_meas_id
        ) q
    ON q.order_dt = c.day_date

WHERE
    c.day_date BETWEEN ADD_MONTHS(CURRENT_DATE-1, -12) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -12)) -1) AND (CURRENT_DATE-1)