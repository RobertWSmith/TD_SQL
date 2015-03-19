SELECT
    ol.order_fiscal_yr
    , ol.order_id
    
    , ol.matl_id
    
    , COUNT(DISTINCT ol.order_fiscal_yr || ol.order_id || ol.order_line_nbr) AS curr_ord_ln_cnt
    , COUNT(DISTINCT ol.order_fiscal_yr || ol.order_id || ol.orig_order_line_nbr) AS orig_ord_ln_cur
    
    , ol.qty_uom
    , SUM(ol.curr_order_qty) AS current_ord_qty
    , SUM(ol.orig_order_qty) AS original_ord_qty

FROM (

    SELECT
        odc.order_fiscal_yr AS order_fiscal_yr
        , odc.order_id AS order_id
        , odc.order_line_nbr AS order_line_nbr
        , od.order_line_nbr AS orig_order_line_nbr
        , odc.matl_id AS matl_id
        
        , odc.qty_unit_meas_id AS qty_uom
        , MAX(ZEROIFNULL(odc.order_qty)) AS curr_order_qty
        , MAX(ZEROIFNULL(od.order_qty)) AS orig_order_qty
        
        
    FROM na_bi_vws.order_detail_curr odc

        INNER JOIN na_bi_vws.nat_sls_doc sd
            ON sd.exp_dt = DATE '5555-12-31'
            AND sd.fiscal_yr = odc.order_fiscal_yr
            AND sd.sls_doc_id = odc.order_id

        FULL OUTER JOIN na_bi_vws.order_detail od
            ON od.order_id = odc.order_id
            AND od.order_line_nbr = odc.order_line_nbr
            AND od.sched_line_nbr = odc.sched_line_nbr
            AND sd.src_crt_dt BETWEEN od.eff_dt AND od.exp_dt
            AND od.order_dt >= DATE '2014-01-01'

    WHERE
        odc.order_cat_id = 'C'
        AND odc.order_type_id <> 'ZLZ'
        AND odc.po_type_id <> 'RO'
        AND odc.cust_grp2_cd = 'TLB'
        AND odc.order_dt >= DATE '2014-01-01'

    GROUP BY
        odc.order_fiscal_yr
        , odc.order_id
        , odc.order_line_nbr
        , od.order_line_nbr
        , odc.matl_id
        
        , odc.qty_unit_meas_id
    
    ) ol

WHERE
    (ol.order_fiscal_yr, ol.order_id, ol.matl_id) IN (
        SELECT
            odc.order_fiscal_yr
            , odc.order_id
            , odc.matl_id
        FROM na_bi_vws.order_detail_curr odc
            INNER JOIN na_bi_vws.open_order_schdln_curr ool
                ON ool.order_fiscal_yr = odc.order_fiscal_yr
                AND ool.order_id = odc.order_id
                AND ool.order_line_nbr = odc.order_line_nbr
                AND ool.sched_line_nbr = odc.sched_line_nbr
        WHERE
            odc.order_cat_id = 'C'
            AND odc.order_type_id <> 'ZLZ'
            AND odc.po_type_id <> 'RO'
            AND odc.cust_grp2_cd = 'TLB'
            AND odc.order_dt >= DATE '2014-01-01'
        GROUP BY
            odc.order_fiscal_yr
            , odc.order_id
            , odc.matl_id
    )

GROUP BY
    ol.order_fiscal_yr
    , ol.order_id
    , ol.matl_id
    , ol.qty_uom

HAVING
    current_ord_qty > original_ord_qty