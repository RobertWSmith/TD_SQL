select
    cast('FRDD' as char(4)) as metric_typ,
    pol.cmpl_dt - (extract(day from pol.cmpl_dt) - 1) as complete_mth,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name as mkt_area,
    sum(zeroifnull(pol.curr_ord_qty)) as order_qty,
    sum(zeroifnull(pol.curr_ord_qty) - zeroifnull(pol.prfct_ord_hit_qty)) as ontime_qty,
    sum(case
        when pol.actl_deliv_dt <= ord.max_frdd
            THEN ZEROIFNULL(pol.curr_ord_qty)
        else (zeroifnull(pol.curr_ord_qty) - zeroifnull(pol.prfct_ord_hit_qty))
    end) as adj_ontime_qty

from na_bi_vws.prfct_ord_line pol
    
    inner join gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        on matl.matl_id = pol.matl_id
        and matl.pbu_nbr in ('01', '03', '04', '05', '07', '08', '09')
    
    inner join gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        on cust.ship_to_cust_id = pol.ship_to_cust_id
        and cust.cust_grp_id <> '3R'

    INNER JOIN ( 
        SELECT
            od.order_id,
            od.order_line_nbr,
            MAX(od.frst_rdd) AS max_frdd,
            MAX(od.frst_prom_deliv_dt) AS max_fcdd
        FROM na_bi_vws.order_detail od
        WHERE
            (od.order_id, od.order_line_nbr) IN (
                SELECT
                    order_id,
                    order_line_nbr
                FROM na_bi_vws.prfct_ord_line
                WHERE
                    cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
                    AND cmpl_ind = 1
                    AND prfct_ord_hit_desc <> 'FRDD Hit - Error'
            )
            AND od.order_cat_id = 'c'
            AND od.order_type_id NOT IN ('zls', 'zlz')
            AND od.po_type_id <> 'ro'
            AND od.cust_grp_id <> '3R'
        GROUP BY
            od.order_id,
            od.order_line_nbr
            ) ord
        ON ord.order_id = pol.order_id
        AND ord.order_line_nbr = pol.order_line_nbr

where
    pol.cmpl_dt between date '2014-01-01' and (current_date-1)
    and pol.cmpl_ind = 1
    and pol.prfct_ord_hit_desc <> 'FRDD Hit - Error'

group by
    metric_typ,
    complete_mth,
    pbu,
    mkt_area

HAVING
    order_qty > 0
    OR ontime_qty > 0
    OR adj_ontime_qty > 0
    
UNION ALL

select
    CAST('FCDD' AS CHAR(4)) AS metric_typ,
    pol.fpdd_cmpl_dt - (EXTRACT(DAY FROM pol.fpdd_cmpl_dt) - 1) AS complete_mth,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name as mkt_area,
    SUM(ZEROIFNULL(pol.fpdd_ord_qty)) AS order_qty,
    SUM(ZEROIFNULL(pol.fpdd_ord_qty) - ZEROIFNULL(pol.prfct_ord_hit_qty)) AS ontime_qty,
    sum(case
        WHEN pol.actl_deliv_dt <= ord.max_fcdd
            THEN ZEROIFNULL(pol.fpdd_ord_qty)
        ELSE (ZEROIFNULL(pol.fpdd_ord_qty) - ZEROIFNULL(pol.prfct_ord_fpdd_hit_qty))
    end) as adj_ontime_qty

from na_bi_vws.prfct_ord_line pol
    
    inner join gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        on matl.matl_id = pol.matl_id
        and matl.pbu_nbr in ('01', '03', '04', '05', '07', '08', '09')
    
    inner join gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        on cust.ship_to_cust_id = pol.ship_to_cust_id
        and cust.cust_grp_id <> '3R'

    INNER JOIN ( 
        SELECT
            od.order_id,
            od.order_line_nbr,
            MAX(od.frst_rdd) AS max_frdd,
            MAX(od.frst_prom_deliv_dt) AS max_fcdd
        FROM na_bi_vws.order_detail od
        WHERE
            (od.order_id, od.order_line_nbr) IN (
                SELECT
                    order_id,
                    order_line_nbr
                FROM na_bi_vws.prfct_ord_line
                WHERE
                    fpdd_cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
                    AND fpdd_cmpl_ind = 1
                    AND prfct_ord_fpdd_hit_desc <> 'FCDD Hit - Error'
                    AND frst_prom_deliv_dt IS NOT NULL
            )
            AND od.order_cat_id = 'c'
            AND od.order_type_id NOT IN ('zls', 'zlz')
            AND od.po_type_id <> 'ro'
            AND od.cust_grp_id <> '3R'
        GROUP BY
            od.order_id,
            od.order_line_nbr
            ) ord
        ON ord.order_id = pol.order_id
        AND ord.order_line_nbr = pol.order_line_nbr

where
    pol.fpdd_cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
    AND pol.fpdd_cmpl_ind = 1
    AND pol.prfct_ord_fpdd_hit_desc <> 'FCDD Hit - Error'
    AND pol.frst_prom_deliv_dt IS NOT NULL

group by
    metric_typ,
    complete_mth,
    pbu,
    mkt_area

HAVING
    order_qty > 0
    OR ontime_qty > 0
    OR adj_ontime_qty > 0