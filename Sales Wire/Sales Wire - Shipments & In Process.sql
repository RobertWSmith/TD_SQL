SELECT
    ddc.fiscal_yr,
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
    SUM(ZEROIFNULL(dip.qty_to_ship)) AS qty_in_proc

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
        OR dip.qty_to_ship > 0
        )

GROUP BY
    ddc.fiscal_yr,
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