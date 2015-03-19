SELECT
    CAST('Actual Goods Issue' AS VARCHAR(50)) AS typ,
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
    
    ddc.actl_goods_iss_dt,
    CASE
        WHEN ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100
            THEN 'Current Month'
        WHEN ddc.actl_goods_iss_dt / 100 > (CURRENT_DATE-1) / 100
            THEN 'Future Month'
        WHEN ddc.actl_goods_iss_dt / 100 < (CURRENT_DATE-1) / 100
            THEN 'Past Month'
    END AS agi_month,
    SUM(ddc.deliv_qty) AS goods_issued_qty
    
FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ddc.matl_id
        AND matl.pbu_nbr = '01'

WHERE
    ddc.fiscal_yr >= (EXTRACT(YEAR FROM (CURRENT_DATE-1))-1)
    AND ddc.distr_chan_cd <> '81' -- exclude internal sales
    AND ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100
    AND ddc.actl_goods_iss_dt <= (CURRENT_DATE-1)
    AND ddc.actl_goods_iss_dt IS NOT NULL
    AND ddc.goods_iss_ind = 'Y'
    AND ddc.deliv_qty > 0

GROUP BY
    typ,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    oe_repl_ind,
    ddc.matl_id,
    ddc.deliv_line_facility_id,
    ddc.actl_goods_iss_dt,
    agi_month