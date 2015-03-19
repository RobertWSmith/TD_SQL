SELECT
    bi.facility_id,
    bi.matl_id,
    bi.day_dt AS bus_dt,
    SUM(bi.blocked_stk_qty) AS blocked_stk_qty,
    SUM(bi.qual_insp_qty) AS qual_insp_qty,
    SUM(bi.tot_qty) AS tot_qty

FROM gdyr_bi_vws.batch_inv bi

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = bi.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

WHERE
    bi.src_sys_id = 2
    AND bi.day_dt BETWEEN CAST(ADD_MONTHS((CURRENT_DATE-1), -24) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -24))-1) AS DATE)
        AND (CURRENT_DATE-1)

GROUP BY
    bi.facility_id,
    bi.matl_id,
    bi.day_dt

ORDER BY
    bi.day_dt,
    bi.facility_id,
    bi.matl_id