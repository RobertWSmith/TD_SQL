SELECT
    -- q.prim_ship_facility_id,
    q.matl_id,
    q.frdd_fmad,
    -- q.frdd_fpgi,
    -- q.frdd,
    q.qty_uom,
    SUM(q.ordered_qty) AS ordered_qty,
    SUM(q.adj_ordered_qty) AS adj_ordered_qty
    
FROM (

SELECT
    odc.order_id,
    odc.order_line_nbr,
    
    odc.ship_to_cust_id,
    cust.prim_ship_facility_id,
    odc.matl_id,
    odc.facility_id,
    
    odc.deliv_blk_cd,
    odc.po_type_id,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    
    SUM(odc.order_qty) AS ordered_qty,
    SUM(odc.cnfrm_qty) AS confirmed_qty,
    odc.qty_unit_meas_id AS qty_uom,
    ZEROIFNULL(dd.deliv_qty) AS delivered_qty,
    CASE
        WHEN odc.rej_reas_id = '' OR ((odc.rej_reas_id = 'Z2' AND odc.po_type_id IN ('DT', 'WA', 'WC', 'WS')) OR odc.rej_reas_id IN ('Z6', 'ZW', 'ZX', 'ZY'))
            THEN (CASE
                WHEN delivered_qty > ordered_qty
                    THEN delivered_qty
                ELSE ordered_qty
            END)
        ELSE (CASE
            WHEN dd.deliv_qty IS NULL
                THEN 0
            ELSE (CASE
                WHEN delivered_qty > confirmed_qty
                    THEN delivered_qty
                ELSE confirmed_qty
            END)
        END)
    END AS adj_ordered_qty

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.matl_id LIKE '%00019032'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.cust_grp_id <> '3R' -- exclude COWD

    LEFT OUTER JOIN (
            SELECT
                d.order_id,
                d.order_line_nbr,
                SUM(d.deliv_qty) AS deliv_qty
            FROM na_bi_vws.delivery_detail_curr d
            WHERE
                d.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-2) AS CHAR(4))
                AND d.distr_chan_cd <> '81' -- exclude internal sales
                AND d.cust_grp_id <> '3R' -- exclude COWD
                AND d.deliv_qty > 0
            GROUP BY
                d.order_id,
                d.order_line_nbr
            ) dd
        ON dd.order_id = odc.order_id
        AND dd.order_line_nbr = odc.order_line_nbr

WHERE
    odc.order_cat_id = 'c'
    AND odc.cust_grp_id <> '3R' -- exclude COWD
    AND odc.order_type_id NOT IN ('zls', 'zlz')
    AND odc.po_type_id <> 'ro'
    AND odc.frst_matl_avl_dt >= ADD_MONTHS((CURRENT_DATE-1), -18)
    AND odc.rej_reas_id NOT IN ('Z1', 'Z3', 'Z4', 'Z5', 'Z9', 'ZA', 'ZB', 'ZC', 'ZD', 'ZE', 'ZF', 'ZG', 'ZH', 'ZJ', 'ZN')

GROUP BY
    odc.order_id,
    odc.order_line_nbr,
    
    odc.ship_to_cust_id,
    cust.prim_ship_facility_id,
    odc.matl_id,
    odc.facility_id,
    
    odc.deliv_blk_cd,
    odc.po_type_id,
    odc.rej_reas_id,
    odc.rej_reas_desc,
    
    odc.frst_matl_avl_dt,
    odc.frst_pln_goods_iss_dt,
    odc.frst_rdd,

    odc.qty_unit_meas_id,
    dd.deliv_qty
    
    ) q

GROUP BY
    q.prim_ship_facility_id,
    q.matl_id,
    q.frdd_fmad,
    -- q.frdd_fpgi,
    -- q.frdd,
    q.qty_uom

ORDER BY
    q.frdd_fmad,
    q.prim_ship_facility_id