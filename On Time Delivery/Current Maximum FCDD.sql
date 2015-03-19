SELECT
    fp.*
    
FROM na_vws.ord_fpdd fp

    INNER JOIN (
                SELECT
                    f.order_fiscal_yr,
                    f.order_id,
                    f.order_line_nbr,
                    f.seq_id,
                    f.frst_prom_deliv_dt
                FROM na_vws.ord_fpdd f
                WHERE
                    f.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                    AND f.exp_dt = DATE '5555-12-31'
                QUALIFY
                    ROW_NUMBER() OVER (PARTITION BY f.order_fiscal_yr, f.order_id, f.order_line_nbr ORDER BY f.frst_prom_deliv_dt DESC, f.src_crt_dt DESC, f.src_crt_tm DESC) = 1
            ) lim
        ON lim.order_fiscal_yr = fp.order_fiscal_yr
        AND lim.order_id = fp.order_id
        AND lim.order_line_nbr = fp.order_line_nbr
        AND lim.seq_id = fp.seq_id
        AND lim.frst_prom_deliv_dt = fp.frst_prom_deliv_dt

WHERE
    fp.exp_dt = DATE '5555-12-31'
    AND fp.order_fiscal_yr >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))

/*
QUALIFY
    COUNT(*) OVER (PARTITION BY fp.order_fiscal_yr, fp.order_id, fp.order_line_nbr) > 1
*/
