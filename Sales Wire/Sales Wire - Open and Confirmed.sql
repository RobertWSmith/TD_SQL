SELECT
    CAST('Open Confirmed' AS VARCHAR(50)) AS typ,
    odc.sales_org_cd,
    odc.distr_chan_cd,
    odc.cust_grp_id,
    CASE
        WHEN odc.sales_org_cd IN ('N302', 'N312', 'N322') OR (odc.sales_org_cd IN ('N303', 'N313', 'N323') AND odc.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Repl'
    END AS oe_repl_ind,
    
    odc.matl_id,
    odc.facility_id,
    
    odc.pln_goods_iss_dt,
    CASE
        WHEN odc.pln_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN odc.pln_goods_iss_dt / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        WHEN odc.pln_goods_iss_dt / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
    END AS pgi_month,
    SUM(ool.open_cnfrm_qty) AS open_cnfrm_qty
    
FROM na_bi_vws.open_order_schdln_curr ool

    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'c'
        AND odc.order_type_id NOT IN ('zls', 'zlz')
        AND odc.po_type_id <> 'ro'
        AND odc.deliv_blk_cd <> ''
        AND odc.pln_goods_iss_dt > (CURRENT_DATE-1)

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr = '01'

WHERE
    ool.credit_hold_flg = 'N'
    AND ool.open_cnfrm_qty > 0

GROUP BY
    typ,
    odc.sales_org_cd,
    odc.distr_chan_cd,
    odc.cust_grp_id,
    oe_repl_ind,
    odc.matl_id,
    odc.facility_id,
    odc.pln_goods_iss_dt,
    pgi_month