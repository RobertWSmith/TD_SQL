SELECT
    cal.day_date AS actl_goods_iss_dt,
    cal.day_of_week_name_desc,
    q.pbu_nbr,
    q.pbu_name,
    q.qty_uom,
    SUM(ZEROIFNULL(q.deliv_qty)) AS deliv_qty

FROM gdyr_bi_vws.gdyr_cal cal

    LEFT OUTER JOIN (
        SELECT
            CASE
                WHEN ddc.sales_org_cd IN ('N302', 'N312', 'N322')
                        OR (ddc.sales_org_cd IN ('N303', 'N313', 'N323') AND ddc.distr_chan_cd = '32')
                    THEN 'OE'
                ELSE 'Repl'
            END AS oe_repl_ind,
            matl.pbu_nbr AS pbu_nbr,
            matl.pbu_name AS pbu_name,
            ddc.actl_goods_iss_dt AS actl_goods_iss_dt,
            ddc.qty_unit_meas_id AS qty_uom,
            SUM(ddc.deliv_qty) AS deliv_qty
            
        FROM na_bi_vws.delivery_detail_curr ddc
        
            INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
                ON matl.matl_id = ddc.matl_id
                -- AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                AND matl.pbu_nbr = '01'
        
            INNER JOIN (
                    SELECT
                        o.order_id,
                        o.order_line_nbr
                    FROM na_bi_vws.order_detail_curr o
                    WHERE
                        o.order_cat_id = 'C'
                        AND o.order_type_id NOT IN ('ZLS', 'ZLZ')
                        AND o.po_type_id <> 'RO'
                    GROUP BY
                        o.order_id,
                        o.order_line_nbr
                    ) odc
                ON odc.order_id = ddc.order_id
                AND odc.order_line_nbr = ddc.order_line_nbr
        
        WHERE
            ddc.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-3) AS CHAR(4))
            AND ddc.distr_chan_cd <> '81' -- exclude internal sales
            AND ddc.goods_iss_ind = 'Y'
            AND ddc.actl_goods_iss_dt IS NOT NULL
            AND ddc.actl_goods_iss_dt BETWEEN ADD_MONTHS(CURRENT_DATE-1, -20) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -20)) - 1) AND (CURRENT_DATE-1)
            AND ddc.deliv_qty > 0
        
        GROUP BY
            oe_repl_ind,
            matl.pbu_nbr,
            matl.pbu_name,
            ddc.actl_goods_iss_dt,
            ddc.qty_unit_meas_id
        ) q
    ON q.actl_goods_iss_dt = cal.day_date
 
 WHERE
    cal.day_date BETWEEN ADD_MONTHS(CURRENT_DATE-1, -20) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -20)) - 1) AND (CURRENT_DATE-1)

GROUP BY
    cal.day_date,
    cal.day_of_week_name_desc,
    q.pbu_nbr,
    q.pbu_name,
    q.qty_uom

ORDER BY
    cal.day_date,
    q.pbu_nbr
;