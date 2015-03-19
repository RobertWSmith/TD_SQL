SELECT
    q.oe_repl_ind,
    q.pbu_nbr,
    q.pbu_name,
    q.super_brand_id,
    q.super_brand_name,
    q.goods_iss_dt,
    q.qty_uom,
    SUM(q.deliv_qty) AS deliv_qty,
    SUM(q.in_proc_qty) AS in_proc_qty,
    SUM(q.open_cnfrm_qty) AS open_cnfrm_qty

FROM (

SELECT
    odc.order_id,
    odc.order_line_nbr,
    
    odc.sales_org_cd,
    odc.distr_chan_cd,
    CASE
        WHEN odc.sales_org_cd IN ('N302', 'N312', 'N322')
                OR (odc.sales_org_cd IN ('N303', 'N313', 'N323') AND odc.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Replacement'
    END AS oe_repl_ind,
    
    odc.ship_to_cust_id,
    
    odc.matl_id,
    matl.pbu_nbr,
    matl.pbu_name,
    matl.super_brand_id,
    matl.super_brand_name,
    
    odc.facility_id,
    
    COALESCE(dd.actl_goods_iss_dt, odc.pln_goods_iss_dt) AS goods_iss_dt,
    odc.qty_unit_meas_id AS qty_uom,
    ZEROIFNULL(dd.deliv_qty) AS deliv_qty,
    ZEROIFNULL(dd.in_proc_qty) AS in_proc_qty,
    SUM(ZEROIFNULL(ool.open_cnfrm_qty)) AS open_cnfrm_qty

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr = '01'

    LEFT OUTER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr
        AND ool.open_cnfrm_qty > 0

    LEFT OUTER JOIN (
            SELECT
                ddc.order_id,
                ddc.order_line_nbr,
                
                ddc.ship_to_cust_id,
                ddc.sales_org_cd,
                ddc.distr_chan_cd,
                
                ddc.matl_id,
                ddc.deliv_line_facility_id,
            
                ddc.actl_goods_iss_dt,
                ddc.goods_iss_ind,
                
                ddc.qty_unit_meas_id AS qty_uom,
                SUM(ddc.deliv_qty) AS deliv_qty,
                SUM(ZEROIFNULL(dip.qty_to_ship)) AS in_proc_qty
            
            FROM na_bi_vws.delivery_detail_curr ddc
            
                LEFT OUTER JOIN gdyr_bi_Vws.deliv_in_proc_curr dip
                    ON dip.deliv_id = ddc.deliv_id
                    AND dip.deliv_line_nbr = ddc.deliv_line_nbr
            
            WHERE
                ddc.fiscal_yr >= (EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 1)
                AND ddc.distr_chan_cd <> '81'
                AND ddc.return_ind = 'N'
                AND ddc.deliv_qty > 0
                AND (
                    ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100
                    OR (dip.deliv_id IS NOT NULL AND dip.qty_to_ship > 0)
                    )
            
            GROUP BY
                ddc.order_id,
                ddc.order_line_nbr,
                
                ddc.ship_to_cust_id,
                ddc.sales_org_cd,
                ddc.distr_chan_cd,
                
                ddc.matl_id,
                ddc.deliv_line_facility_id,
            
                ddc.actl_goods_iss_dt,
                ddc.goods_iss_ind,
                
                ddc.qty_unit_meas_id
            ) dd
        ON dd.order_id = odc.order_id
        AND dd.order_line_nbr = odc.order_line_nbr

WHERE
    odc.order_cat_id = 'C'
    AND odc.order_type_id NOT IN ('zls', 'zlz')
    AND odc.po_type_id <> 'ro'
    AND COALESCE(dd.deliv_qty, dd.in_proc_qty, ool.open_cnfrm_qty, ool.uncnfrm_qty, ool.back_order_qty) > 0
    AND goods_iss_dt / 100 = (CURRENT_DATE-1) / 100

GROUP BY
    odc.order_id,
    odc.order_line_nbr,
    
    odc.sales_org_cd,
    odc.distr_chan_cd,
    oe_repl_ind,
    
    odc.ship_to_cust_id,
    
    odc.matl_id,
    matl.pbu_nbr,
    matl.pbu_name,
    matl.super_brand_id,
    matl.super_brand_name,
    
    odc.facility_id,
    
    goods_iss_dt,
    
    odc.qty_unit_meas_id,
    dd.deliv_qty,
    dd.in_proc_qty
    
    ) q

GROUP BY
    q.oe_repl_ind,
    q.pbu_nbr,
    q.pbu_name,
    q.super_brand_id,
    q.super_brand_name,
    q.goods_iss_dt,
    q.qty_uom