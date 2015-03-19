SELECT
    odc.order_fiscal_yr AS "Order Fiscal Year",
    odc.order_id AS "Order ID",
    odc.order_line_nbr AS "Order Line Nbr",
    odc.sched_line_nbr AS "Schedule Line Nbr",
    
    odc.ship_to_cust_id AS "Ship To Customer ID",
    cust.ship_to_cust_id || ' - ' || cust.cust_name AS "Ship To Customer",
    cust.own_cust_id || ' - ' || cust.own_cust_name AS "Common Owner",
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS "Sales Organization",
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS "Distribution Channel",
    
    odc.cust_grp2_cd AS "Customer Group 2 Code",
    
    odc.matl_id AS "Material ID",
    matl.matl_no_8 || ' - ' || matl.descr AS "Material Description",
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS "Market Area",
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS "Category",
    
    odc.facility_id AS "Ship Facility ID",
    cust.prim_ship_facility_id AS "Primary Ship Facility ID",
    
    sd.deliv_blk_cd AS "Header Delivery Block",    
    sdsl.schd_ln_deliv_blk_cd AS "Schedule Line Delivery Block",
    
    odc.pln_matl_avl_dt AS "Planned Material Avail. Date",
    odc.pln_goods_iss_dt AS "Planned Goods Issue Date",
    odc.pln_deliv_dt AS "Planned Delivery Date",
    
    odc.qty_unit_meas_id AS "Quantity UOM",
    ool.open_cnfrm_qty AS "Open Confirmed Qty",
    ool.uncnfrm_qty AS "Unconfirmed Qty",
    ool.back_order_qty AS "Back Order Qty",
    ool.defer_qty AS "Deferred Qty",
    ool.in_proc_qty AS "In Process Qty",
    ool.wait_list_qty AS "Wait List Qty",
    ool.othr_order_qty AS "Other Open Qty"

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id

    INNER JOIN na_vws.open_order_schdln ool
        ON ool.exp_dt = CAST('5555-12-31' AS DATE)
        AND ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr

    INNER JOIN na_bi_vws.nat_sls_doc_schd_ln sdsl
        ON sdsl.fiscal_yr = odc.order_fiscal_yr
        AND sdsl.sls_doc_id = odc.order_id
        AND sdsl.sls_doc_itm_id = odc.order_line_nbr
        AND sdsl.schd_ln_id = odc.sched_line_nbr
        AND sdsl.exp_dt = CAST('5555-12-31' AS DATE)

    INNER JOIN na_bi_vws.nat_sls_doc_itm sdi
        ON sdi.fiscal_yr = odc.order_fiscal_yr
        AND sdi.sls_doc_id = odc.order_id
        AND sdi.sls_doc_itm_id = odc.order_line_nbr
        AND sdi.exp_dt = CAST('5555-12-31' AS DATE)

    INNER JOIN na_bi_vws.nat_sls_doc sd
        ON sd.fiscal_yr = odc.order_fiscal_yr
        AND sd.sls_doc_id = odc.order_id
        AND sd.exp_dt = CAST('5555-12-31' AS DATE)

WHERE
    odc.cust_grp2_cd = 'TLB'
    AND (CASE
        WHEN sd.deliv_blk_cd = 'YT'
            THEN 1
        WHEN sdsl.schd_ln_deliv_blk_cd = 'YT' AND NULLIF(sd.deliv_blk_cd, '') IS NOT NULL
            THEN 1
        WHEN sdsl.schd_ln_deliv_blk_cd = 'YO'
            THEN 1
        ELSE 0
    END) = 1

ORDER BY
    odc.order_fiscal_yr,
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr
