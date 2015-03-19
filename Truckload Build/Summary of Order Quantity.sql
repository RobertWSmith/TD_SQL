SELECT
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.own_cust_id AS "Common Owner ID",
    q.own_cust_name AS "Common Owner Name",
    q.order_mth AS "Order Create Month",
    COUNT(DISTINCT q.order_id) AS "Order ID Count",
    ROUND(AVERAGE(q.order_line_cnt), 1) AS "Average Count of Order Lines",
    MIN(q.order_qty) AS "Minimum Order Qty",
    ROUND(AVERAGE(q.order_qty), 1) AS "Average Order Qty",
    MAX(q.order_qty) AS "Maximum Order Qty"

FROM (

    SELECT
        odc.order_id,
        COUNT(DISTINCT odc.order_id || odc.order_line_nbr) AS order_line_cnt,
        odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1) AS order_mth,
    
        odc.ship_to_cust_id,
        cust.cust_name AS ship_to_cust_name,
        cust.own_cust_id,
        cust.own_cust_name,
    
        MAX(odc.order_qty) AS order_qty,
        SUM(odc.cnfrm_qty) AS cnfrm_qty
        
    FROM na_bi_vws.order_detail_curr odc
    
        INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
            ON cust.ship_to_cust_id = odc.ship_to_cust_id
            AND cust.cust_grp_id <> '3R'
        
        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = odc.matl_id
    
    WHERE
        odc.cust_grp2_cd = 'TLB'
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND odc.po_type_id <> 'RO'
        AND odc.order_dt >= DATE '2014-04-01'
    
    GROUP BY
        odc.order_id,
        order_mth,
    
        odc.ship_to_cust_id,
        cust.cust_name,
        cust.own_cust_id,
        cust.own_cust_name,
        
        odc.qty_unit_meas_id
    
    ) q

GROUP BY
    q.ship_to_cust_id,
    q.ship_to_cust_name,
    q.own_cust_id,
    q.own_cust_name,
    q.order_mth

ORDER BY
    "Average Order Qty" DESC
;

SELECT
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.own_cust_id AS "Common Owner ID",
    q.own_cust_name AS "Common Owner Name",
    q.order_mth AS "Order Create Month",
    COUNT(DISTINCT q.order_id || q.order_line_nbr) AS "Order Line Count",
    MIN(q.order_qty) AS "Minimum Order Line Qty",
    ROUND(AVERAGE(q.order_qty), 1) AS "Average Order Line Qty",
    MAX(q.order_qty) AS "Maximum Order Line Qty"

FROM (

    SELECT
        odc.order_id,
        odc.order_line_nbr,
    
        odc.ship_to_cust_id,
        cust.cust_name AS ship_to_cust_name,
        cust.own_cust_id,
        cust.own_cust_name,
        odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1) AS order_mth,
    
        MAX(odc.order_qty) AS order_qty,
        SUM(odc.cnfrm_qty) AS cnfrm_qty
        
    FROM na_bi_vws.order_detail_curr odc
    
        INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
            ON cust.ship_to_cust_id = odc.ship_to_cust_id
            AND cust.cust_grp_id <> '3R'
        
        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = odc.matl_id
    
    WHERE
        odc.cust_grp2_cd = 'TLB'
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND odc.po_type_id <> 'RO'
        AND odc.order_dt >= DATE '2014-04-01'
    
    GROUP BY
        odc.order_id,
        odc.order_line_nbr,
        order_mth,
    
        odc.ship_to_cust_id,
        cust.cust_name,
        cust.own_cust_id,
        cust.own_cust_name,
        
        odc.qty_unit_meas_id
    
    ) q

GROUP BY
    q.ship_to_cust_id,
    q.ship_to_cust_name,
    q.own_cust_id,
    q.own_cust_name,
    q.order_mth

ORDER BY
    "Average Order Line Qty" DESC
