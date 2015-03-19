SELECT
    SUM(q.cnfrm_qty) AS confirmed_qty,
    SUM(q.open_cnfrm_qty) AS open_confirmed_qty,
    SUM(q.uncnfrm_qty) AS unconfirmed_qty,
    SUM(q.back_order_qty) AS backorder_qty

FROM (

SELECT
    od.order_id,
    od.order_line_nbr,
    od.sched_line_nbr,
    
    od.eff_dt,
    od.exp_dt,
    COALESCE(MIN(od.eff_dt) OVER (PARTITION BY od.order_id, od.order_line_nbr, od.sched_line_nbr ORDER BY od.eff_dt ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING), NULL) AS next_eff_dt,
    
    od.ship_to_cust_id,
    
    od.matl_id,
    od.facility_id,
    
    od.order_qty,
    od.cnfrm_qty,
    ool.open_cnfrm_qty,
    ool.uncnfrm_qty,
    ool.back_order_qty
    
FROM na_bi_vws.order_detail od

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = od.matl_id
        AND matl.pbu_nbr = '01'

    INNER JOIN na_vws.open_order_schdln ool
        ON DATE '2014-04-30' BETWEEN ool.eff_dt AND ool.exp_dt
        AND ool.order_id = od.order_id
        AND ool.order_line_nbr = od.order_line_nbr
        AND ool.sched_line_nbr = od.sched_line_nbr

WHERE
    DATE '2014-04-30' BETWEEN od.eff_dt AND od.exp_dt
    AND od.order_cat_id = 'C'
    AND od.order_type_id NOT IN ('ZLS', 'ZLZ')
    AND od.po_type_id <> 'RO'

QUALIFY
    next_eff_dt IS NOT NULL OR od.exp_dt = DATE '5555-12-31'

    ) q
