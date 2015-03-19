SELECT
    od.order_id,
    od.order_line_nbr,
    od.ship_to_cust_id,
    od.matl_id,
    od.facility_id,
    od.ship_pt_id,
    od.rpt_frt_plcy_cd AS cust_grp2_cd,
    pol.fmad_dt,
    od.qty_unit_meas_id,
    MAX(od.order_qty) AS ordered_qty,
    SUM(od.cnfrm_qty) AS confirmed_qty,
    CASE
        WHEN confirmed_qty > ordered_qty
            THEN ordered_qty
        ELSE confirmed_qty
    END AS adj_confirmed_qty
        
FROM na_bi_vws.order_detail od

    INNER JOIN gdyr_bi_Vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = od.ship_to_cust_id
        AND cust.cust_grp2_cd = 'TLB'

    INNER JOIN na_bi_vws.prfct_ord_line pol
        ON pol.order_id = od.order_id
        AND pol.order_line_nbr = od.order_line_nbr
        AND pol.cmpl_ind = 1
        AND pol.cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
        AND pol.fmad_dt BETWEEN od.eff_dt AND od.exp_dt

WHERE
    od.order_cat_id = 'c'
    AND od.order_type_id <> 'zlz'
    AND od.po_type_id <> 'ro'

GROUP BY
    od.order_id,
    od.order_line_nbr,
    od.ship_to_cust_id,
    od.matl_id,
    od.facility_id,
    od.ship_pt_id,
    od.rpt_frt_plcy_cd,
    pol.fmad_dt,
    od.qty_unit_meas_id