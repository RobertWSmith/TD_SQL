SELECT
    q.order_fiscal_yr AS "Order Fiscal Year",
    q.order_id AS "Order ID",
    q.order_line_nbr AS "Order Line Nbr",
    q.matl_id AS "Material ID",
    q.matl_descr AS "Material Description",
    q.pbu AS "PBU",
    q.category AS "Category",
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.sales_org AS "Sales Organization",
    q.distr_chan "Distribution Channel",
    q.cust_grp AS "Customer Group",
    q.cust_grp2_cd AS "Customer Group 2 Code",
    q.facility_id AS "Ship Facility ID",
    q.ship_pt_id AS "Ship Point ID",
    q.order_cat_id AS "Order Category ID",
    q.order_type_id AS "Order Type ID",
    q.po_type_id AS "PO Type ID",
    q.cancel_ind AS "Cancel Ind",
    q.return_ind AS "Return Ind",
    q.deliv_blk_ind AS "Delivery Block Ind",
    q.deliv_blk_cd AS "Delivery Block Code",
    q.ship_cond_id AS "Shipping Condition ID",
    q.deliv_prty_id AS "Delivery Priority ID",
    q.route_id AS "Route ID",
    q.deliv_grp_cd AS "Delivery Group Code",
    q.spcl_proc_id AS "Special Process Ind",
    q.order_dt AS "Order Create Date",
    q.order_month AS "Order Create Month",
    q.frst_rdd AS "FRDD",
    q.frdd_month AS "FRDD Month",
    q.frst_prom_deliv_dt AS "FCDD",
    q.fcdd_month AS "FCDD Month",
    q.fountain_rdd AS "Fountain Tire RDD",
    q.fountain_rdd_month AS "Fountain RDD Month",
    q.qty_uom AS "Quantity UOM",
    q.order_qty AS "Order Qty",
    q.confirmed_qty AS "Confirmed Qty",
    q.qty_to_ship AS "In Process Qty",
    q.open_cnfrm_qty AS "Open Confirmed Qty",
    q.uncnfrm_qty AS "Unconfirmed Qty",
    q.defer_qty AS "Deferred Qty",
    q.wait_list_qty AS "Wait List Qty",
    q.othr_order_qty AS "Other Open Qty"

FROM (

SELECT
    odc.order_fiscal_yr,
    odc.order_id,
    odc.order_line_nbr,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    odc.cust_grp2_cd,
    
    odc.facility_id,
    odc.ship_pt_id,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.cancel_ind,
    COALESCE(odc.return_ind, 'N') AS return_ind,
    odc.deliv_blk_ind,
    odc.deliv_blk_cd,
    odc.ship_cond_id,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    odc.order_creator,
    
    odc.order_dt,
    odc.frst_rdd,
    odc.frst_prom_deliv_dt,
    CASE
        WHEN CAST(COALESCE(odc.cust_rdd, odc.frst_rdd) - odc.order_dt AS INTEGER) < 14
            THEN CAST(odc.order_dt + 14 AS DATE)
        ELSE COALESCE(odc.cust_rdd, odc.frst_rdd)
    END AS fountain_rdd,
    
    CAST(odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1) AS FORMAT 'YYYY-MMM') AS order_month,
    CAST(odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1) AS FORMAT 'YYYY-MMM') AS frdd_month,
    CAST(odc.frst_prom_deliv_dt - (EXTRACT(DAY FROM odc.frst_prom_deliv_dt) - 1) AS FORMAT 'YYYY-MMM') AS fcdd_month,
    CAST(fountain_rdd - (EXTRACT(DAY FROM fountain_rdd) - 1) AS FORMAT 'YYYY-MMM') AS fountain_rdd_month,
    
    odc.qty_unit_meas_id AS qty_uom,
    MAX(odc.order_qty) AS order_qty,
    SUM(odc.cnfrm_qty) AS confirmed_qty,
    SUM(ZEROIFNULL(ool.open_cnfrm_qty)) AS open_cnfrm_qty,
    SUM(ZEROIFNULL(ool.uncnfrm_qty)) + SUM(ZEROIFNULL(ool.back_order_qty)) AS uncnfrm_qty,
    SUM(ZEROIFNULL(ool.defer_qty)) AS defer_qty,
    SUM(ZEROIFNULL(ool.wait_list_qty)) AS wait_list_qty,
    SUM(ZEROIFNULL(ool.in_proc_qty)) + SUM(ZEROIFNULL(ool.othr_order_qty)) AS othr_order_qty,
    ZEROIFNULL(dip.qty_to_ship) AS qty_to_ship

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.own_cust_id = '00A0009337'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    LEFT OUTER JOIN na_vws.open_order_schdln ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr
        AND ool.exp_dt = DATE '5555-12-31'
        
    LEFT OUTER JOIN (
            SELECT
                order_id,
                order_line_nbr,
                SUM(qty_to_ship) AS qty_to_ship
            FROM gdyr_bi_vws.deliv_in_proc_curr
            GROUP BY
                order_id,
                order_line_nbr
        ) dip
        ON dip.order_id = odc.order_id
        AND dip.order_line_nbr = odc.order_line_nbr
        
WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
    AND odc.po_type_id <> 'RO'
    AND (
        odc.order_dt >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        OR odc.frst_rdd >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        OR odc.frst_prom_deliv_dt >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        OR fountain_rdd >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        OR odc.pln_deliv_dt >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        )

GROUP BY
    odc.order_fiscal_yr,
    odc.order_id,
    odc.order_line_nbr,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
    
    odc.ship_to_cust_id,
    cust.cust_name,
    cust.sales_org_cd || ' - ' || cust.sales_org_name,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name,
    odc.cust_grp2_cd,
    
    odc.facility_id,
    odc.ship_pt_id,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.cancel_ind,
    COALESCE(odc.return_ind, 'N'),
    odc.deliv_blk_ind,
    odc.deliv_blk_cd,
    odc.ship_cond_id,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    odc.order_creator,
    
    odc.order_dt,
    odc.frst_rdd,
    odc.frst_prom_deliv_dt,
    CASE
        WHEN CAST(COALESCE(odc.cust_rdd, odc.frst_rdd) - odc.order_dt AS INTEGER) < 14
            THEN CAST(odc.order_dt + 14 AS DATE)
        ELSE COALESCE(odc.cust_rdd, odc.frst_rdd)
    END,
    
    odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1),
    odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1),
    odc.frst_prom_deliv_dt - (EXTRACT(DAY FROM odc.frst_prom_deliv_dt) - 1),
    fountain_rdd - (EXTRACT(DAY FROM fountain_rdd) - 1),
    
    odc.qty_unit_meas_id,
    ZEROIFNULL(dip.qty_to_ship)
    
    ) q
    
ORDER BY
    q.order_fiscal_yr,
    q.order_id,
    q.order_line_nbr
