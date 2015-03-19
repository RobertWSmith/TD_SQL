SELECT
    opn.order_fiscal_yr,
    opn.order_id,
    opn.order_line_nbr,
    cal.day_date AS bus_dt,
    opn.intra_cmpny_flg,
    opn.credit_hold_flg,
    opn.sls_qty_unit_meas_id AS qty_uom,
    SUM(CASE WHEN opn.open_order_status_cd = 'C' THEN opn.open_order_qty ELSE 0 END) AS open_cnfrm_qty,
    SUM(CASE WHEN opn.open_order_status_cd = 'U' THEN opn.open_order_qty ELSE 0 END) AS uncnfrm_qty,
    SUM(CASE WHEN opn.open_order_status_cd = 'B' THEN opn.open_order_qty ELSE 0 END) AS back_order_qty,
    SUM(CASE WHEN opn.open_order_status_cd = 'W' THEN opn.open_order_qty ELSE 0 END) AS wait_list_qty,
    SUM(CASE WHEN opn.open_order_status_cd = 'D' THEN opn.open_order_qty ELSE 0 END) AS defer_qty,
    SUM(CASE WHEN opn.open_order_status_cd IN ('U','B') THEN opn.open_order_qty ELSE 0 END) AS total_back_order_qty,
    SUM(opn.open_order_qty) AS total_open_qty,
    opn.orig_sys_id,
    opn.src_sys_id,
    opn.sbu_id

FROM gdyr_vws.gdyr_cal cal

    INNER JOIN gdyr_vws.open_order opn
        ON cal.day_date BETWEEN opn.eff_dt AND opn.exp_dt
        AND opn.sbu_id = 2

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr = opn.order_fiscal_yr
        AND ods.order_id = opn.order_id
        AND ods.order_line_nbr = opn.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.po_type_id <> 'RO'
        AND ods.order_type_id <> 'ZLZ'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ods.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

WHERE
    cal.day_date BETWEEN CAST(ADD_MONTHS((CURRENT_DATE-1), -6) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -6)) -1) AS DATE) AND (CURRENT_DATE-1)

GROUP BY
    opn.order_fiscal_yr,
    opn.order_id,
    opn.order_line_nbr,
    cal.day_date,
    opn.intra_cmpny_flg,
    opn.credit_hold_flg,
    opn.sls_qty_unit_meas_id,
    opn.orig_sys_id,
    opn.src_sys_id,
    opn.sbu_id

ORDER BY
    cal.day_date,
    opn.order_fiscal_yr,
    opn.order_id,
    opn.order_line_nbr