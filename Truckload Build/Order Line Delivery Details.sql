SELECT
    ddc.order_fiscal_yr,
    ddc.order_id,
    ddc.order_line_nbr,
    COUNT(DISTINCT ddc.fiscal_yr || ddc.deliv_id || ddc.deliv_line_nbr) AS deliv_line_cnt,
    
    ddc.ship_to_cust_id,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    ddc.cust_grp2_cd,
    
    ddc.matl_id,
    
    ddc.facility_id,
    ddc.deliv_line_facility_id,
    ddc.ship_pt_id,
    ddc.ship_facility_id,
    
    ddc.qty_unit_meas_id,
    SUM(ddc.deliv_qty) AS deliv_qty,
    SUM(ZEROIFNULL(dip.qty_to_ship)) AS in_proc_qty,
    
    ddc.vol_unit_meas_id,
    SUM(ddc.vol) AS vol,
    
    ddc.wt_unit_meas_id,
    SUM(ddc.net_wt) AS net_wt,
    SUM(ddc.gross_wt) AS gross_wt

FROM na_bi_vws.delivery_detail_curr ddc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = ddc.ship_to_cust_id
        AND cust.cust_grp2_cd = 'TLB'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ddc.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr = ddc.order_fiscal_yr
        AND ods.order_id = ddc.order_id
        AND ods.order_line_nbr = ddc.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_cat_id NOT IN ('ZLS', 'ZLZ')

    LEFT OUTER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
        ON dip.deliv_id = ddc.deliv_id
        AND dip.deliv_line_nbr = ddc.deliv_line_nbr
        AND dip.order_id = ddc.order_id
        AND dip.order_line_nbr = ddc.order_line_nbr

WHERE
    ddc.fiscal_yr >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))-3 AS CHAR(4))
    AND ddc.distr_chan_cd <> '81'

GROUP BY
    ddc.order_fiscal_yr,
    ddc.order_id,
    ddc.order_line_nbr,
    ddc.ship_to_cust_id,
    ddc.sales_org_cd,
    ddc.distr_chan_cd,
    ddc.cust_grp_id,
    ddc.cust_grp2_cd,
    ddc.matl_id,
    ddc.facility_id,
    ddc.deliv_line_facility_id,
    ddc.ship_pt_id,
    ddc.ship_facility_id,
    ddc.qty_unit_meas_id,
    ddc.vol_unit_meas_id,
    ddc.wt_unit_meas_id
