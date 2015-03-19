SELECT
    q.cmpl_mth,
    q.oe_repl_ind,
    q.own_cust_id,
    q.own_cust_name,
    q.sales_org_cd,
    q.sales_org_name,
    q.distr_chan_cd,
    q.distr_chan_name,
    q.cust_grp_id,
    q.cust_grp_name,
    q.pbu,
    q.cust_grp2_cd,
    q.days_late,
    SUM(q.order_qty) AS order_qty,
    SUM(q.ontime_qty) AS ontime_qty,
    SUM(q.hit_qty) AS hit_qty

FROM (

SELECT
    pol.order_id,
    pol.order_line_nbr,
    
    pol.cmpl_dt - (EXTRACT(DAY FROM pol.cmpl_dt) - 1) AS cmpl_mth,
    
    cust.sales_org_cd,
    cust.sales_org_name,
    
    cust.distr_chan_cd,
    cust.distr_chan_name,
    
    cust.own_cust_id,
    cust.own_cust_name,
    
    cust.cust_grp_id,
    cust.cust_grp_name,
    cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust,
    
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
    pol.cust_grp2_cd,
    CASE
        WHEN CUST.SALES_ORG_CD IN ('N302', 'N312', 'N322')
                OR (CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND CUST.DISTR_CHAN_CD = '32')
            THEN 'OE'
        ELSE 'REPL'
    END AS oe_repl_ind,
    
    pol.req_deliv_dt,
    pol.frst_prom_deliv_dt,
    pol.max_sap_deliv_dt,
    pol.max_edi_deliv_dt,
    pol.actl_deliv_dt,

    CASE
        WHEN pol.frst_prom_deliv_dt < pol.req_deliv_dt
            THEN pol.frst_prom_deliv_dt
        ELSE pol.req_deliv_dt
    END AS frdd,
    CASE
        -- if both dates are invalid (null or greater than today)
        WHEN COALESCE(pol.max_sap_deliv_dt, DATE '5555-12-31') > CURRENT_DATE AND COALESCE(pol.max_edi_deliv_dt, DATE '5555-12-31') > CURRENT_DATE
            THEN NULL
        -- EDI missing and SAP delivery date in the future
        WHEN pol.max_edi_deliv_dt IS NULL AND pol.max_sap_deliv_dt IS NOT NULL AND pol.max_sap_deliv_dt >= CURRENT_DATE
            THEN NULL
        WHEN pol.max_sap_deliv_dt >= CURRENT_DATE AND pol.max_edi_deliv_dt < CURRENT_DATE
            THEN pol.max_edi_deliv_dt
        -- when EDI is null and SAP Delivery Date is less than today's date
        WHEN pol.max_edi_deliv_dt IS NULL AND pol.max_sap_deliv_dt IS NOT NULL AND pol.max_sap_deliv_dt < CURRENT_DATE
            THEN pol.max_sap_deliv_dt
        -- when the number of days between the EDI and SAP delivery dates are more than 30 days
        WHEN ABS(pol.max_edi_deliv_dt - pol.max_sap_deliv_dt) > 30
            THEN pol.max_sap_deliv_dt
        -- if the actual delivery date is +/- one month of the line's complete date
        WHEN pol.actl_deliv_dt BETWEEN ADD_MONTHS(pol.cmpl_dt, -1) AND ADD_MONTHS(pol.cmpl_dt, 1)
            THEN pol.actl_deliv_dt
        -- if all else fails, use the SAP delivery date
        ELSE pol.max_sap_deliv_dt
    END AS actual_deliv_dt,
    CASE
        WHEN order_qty = ontime_qty
            THEN 'On Time'
        WHEN ontime_qty > 0 AND order_qty > ontime_qty
            THEN 'Some On Time'
        ELSE 'Late'
    END AS on_time_ind,
    CASE
        WHEN actual_deliv_dt > frdd AND hit_qty > 0
            THEN actual_deliv_dt - frdd
        ELSE 0
    END AS days_late,
    ZEROIFNULL(pol.curr_ord_qty) AS order_qty,
    ZEROIFNULL(pol.prfct_ord_qty) AS ontime_qty,
    order_qty - ontime_qty AS hit_qty

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr IN ('01')
    
    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id

WHERE
    pol.frst_prom_deliv_dt IS NOT NULL
    AND actual_deliv_dt IS NOT NULL
    AND pol.cmpl_ind = 1
    AND pol.cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)

    ) q

GROUP BY
    q.cmpl_mth,
    q.oe_repl_ind,
    q.own_cust_id,
    q.own_cust_name,
    q.sales_org_cd,
    q.sales_org_name,
    q.distr_chan_cd,
    q.distr_chan_name,
    q.cust_grp_id,
    q.cust_grp_name,
    q.pbu,
    q.cust_grp2_cd,
    q.days_late