SELECT
    CAST('In Process' AS VARCHAR(50)) AS typ,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    CASE
        WHEN ddc.sales_org_cd IN ('N302', 'N312', 'N322')
                OR (ddc.sales_org_cd IN ('N303', 'N313', 'N323') AND ddc.distr_chan_cd = '32')
            THEN 'OE'
        ELSE 'Repl'
    END AS oe_repl_ind,
    ddc.matl_id,
    ddc.deliv_line_facility_id AS facility_id,
    
    dd.pln_goods_mvt_dt,
    CASE
        WHEN dd.pln_goods_mvt_dt / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN dd.pln_goods_mvt_dt / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        WHEN dd.pln_goods_mvt_dt / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
    END AS pgi_month,
    SUM(dip.qty_to_ship) AS in_proc_qty

FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ddc.matl_id
        AND matl.pbu_nbr = '01'

    INNER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
        ON dip.deliv_id = ddc.deliv_id
        AND dip.deliv_line_nbr = ddc.deliv_line_nbr
        AND dip.order_id = ddc.order_id
        AND dip.order_line_nbr = ddc.order_line_nbr
        AND dip.intra_cmpny_flg = 'N'
        AND dip.qty_to_ship > 0 

    INNER JOIN gdyr_bi_vws.deliv_doc_curr dd
        ON dd.deliv_doc_id = ddc.deliv_id
        AND dd.fiscal_yr = ddc.fiscal_yr
        AND dd.orig_sys_id = 2
        AND dd.sbu_id = 2
        AND dd.pln_goods_mvt_dt > (CURRENT_DATE-1) -- Future PGI Qty

WHERE
    ddc.fiscal_yr >= (EXTRACT(YEAR FROM (CURRENT_DATE-1))-1)
    AND ddc.distr_chan_cd <> '81' -- exclude internal sales
    AND (ddc.order_id, ddc.order_line_nbr) IN (
        SELECT
            order_id,
            order_line_nbr
        FROM na_bi_vws.order_detail_curr
        WHERE
            order_cat_id = 'c'
            AND order_type_id NOT IN ('zls', 'zlz')
            AND po_type_id <> 'ro'
            AND order_dt >= CAST( (EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 2) || '-01-01' AS DATE)
        GROUP BY
            order_id,
            order_line_nbr
    )

GROUP BY
    typ,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    oe_repl_ind,
    ddc.matl_id,
    ddc.deliv_line_facility_id,
    dd.pln_goods_mvt_dt,
    pgi_month
