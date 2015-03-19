SELECT
    cal.day_date AS "Business Date"
    , odc.ship_to_cust_id AS "Ship To Customer ID"
    , cust.cust_name AS "Ship To Customer Name"
    , cust.own_cust_id AS "Common Owner ID"
    , cust.own_cust_name AS "Common Owner Name"
    , odc.ship_cond_id AS "Shipping Condition"
    , odc.facility_id AS "Ship Facility ID"
    , COUNT(DISTINCT ool.order_fiscal_yr || ool.order_id || ool.order_line_nbr) AS "Open Order Line Count"
    , COUNT(DISTINCT ool.order_fiscal_yr || ool.order_id || ool.order_line_nbr || ool.sched_line_nbr) AS "Open Schedule Line Count"
    , COUNT(DISTINCT ool.order_fiscal_yr || ool.order_id || odc.matl_id) AS "Materials per Order ID"
    , COUNT(DISTINCT odc.matl_id) AS "Open Material Count"

FROM gdyr_bi_vws.gdyr_cal cal

    INNER JOIN na_vws.open_order_schdln ool
        ON cal.day_date BETWEEN ool.eff_dt AND ool.exp_dt

    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_fiscal_yr = ool.order_fiscal_yr
        AND odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'c'
        AND odc.po_type_id <> 'ro'
        AND odc.order_type_id <> 'zlz'
        AND odc.cust_grp2_cd = 'tlb'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.cust_grp2_cd = 'TLB'
    
    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03') 
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN na_bi_vws.nat_sls_doc sd
        ON sd.fiscal_yr = ool.order_fiscal_yr
        AND sd.sls_doc_id = ool.order_id
        AND cal.day_date BETWEEN sd.eff_dt AND sd.exp_dt

    INNER JOIN na_bi_vws.nat_sls_doc_itm sdi
        ON sdi.fiscal_yr = ool.order_fiscal_yr
        AND sdi.sls_doc_id = ool.order_id
        AND sdi.sls_doc_itm_id = ool.order_line_nbr
        AND cal.day_date BETWEEN sdi.eff_dt AND sdi.exp_dt

WHERE
    cal.day_date BETWEEN DATE '2014-06-17' AND (CURRENT_DATE-1)
    AND odc.facility_id = cust.prim_ship_facility_id

GROUP BY
    cal.day_date
    , odc.ship_to_cust_id
    , cust.cust_name
    , cust.own_cust_id
    , cust.own_cust_name
    , odc.ship_cond_id
    , odc.facility_id

ORDER BY
    cal.day_date
    , odc.ship_to_cust_id