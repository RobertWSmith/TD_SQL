SELECT
    opn.order_fiscal_yr,
    opn.order_id,
    opn.order_line_nbr,
    CAST(CASE opn.open_order_status_cd
        WHEN 'C' THEN 'Confirmed'
        WHEN 'B' THEN 'Back Ordered'
        WHEN 'U' THEN 'Unconfirmed'
        WHEN 'D' THEN 'Deferred'
        WHEN 'W' THEN 'Wait List'
        ELSE 'Other'
    END AS VARCHAR(25)) AS open_order_status,
    opn.eff_dt,
    opn.exp_dt,
    opn.open_order_qty,
    opn.sls_qty_unit_meas_id,
    opn.intra_cmpny_flg,
    opn.credit_hold_flg,
    opn.rpt_open_order_qty,
    opn.rpt_qty_unit_meas_id
    opn.orig_sys_id,
    opn.src_sys_id,
    opn.sbu_id

FROM gdyr_vws.open_order opn

    INNER JOIN na_bi_vws.ord_dtl_smry ods
        ON ods.order_fiscal_yr = opn.order_fiscal_yr
        AND ods.order_id = opn.order_id
        AND ods.order_line_nbr = opn.order_line_nbr
        AND ods.order_cat_id = 'C'
        AND ods.order_type_id <> 'ZLZ'
        AND ods.po_type_id <> 'RO'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = ods.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

WHERE
    opn.exp_dt >= CAST(ADD_MONTHS((CURRENT_DATE-1), -12) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -12)) -1) AS DATE)

ORDER BY
    opn.order_fiscal_yr,
    opn.order_id,
    opn.order_line_nbr,
    opn.exp_dt