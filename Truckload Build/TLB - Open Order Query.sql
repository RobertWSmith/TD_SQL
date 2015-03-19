SELECT
    q.order_fiscal_yr AS "Order Fiscal Year",
    q.order_id AS "Order ID",
    q.order_line_nbr AS "Order Line Nbr",
    q.sched_line_nbr AS "Schedule Line Nbr",
    
    q.ordd_test AS "ORDD Test",
    q.frdd_test AS "FRDD Test",
    q.fcdd_test AS "FCDD Test",
    q.frdd_fcdd_test AS "FRDD / FCDD Test",
    q.days_to_first_date AS "Days to First Date",
    q.days_to_ordd AS "Days to ORDD",
    q.days_to_frdd AS "Days to FRDD",
    q.days_to_fcdd AS "Days to FCDD",
    
    q.order_cat_id AS "Order Category ID",
    q.order_type_id AS "Order Type ID",
    q.po_type_id AS "PO Type ID",
    q.return_ind AS "Return Ind",
    q.cancel_ind AS "Cancel Ind",
    q.deliv_blk_ind AS "Delivery Block Ind",
    q.deliv_blk_cd AS "Delivery Block Code",
    q.ship_cond_id AS "Shipping Condition ID",
    q.deliv_prty_id AS "Delivery Priority ID",
    q.route_id AS "Route ID",
    q.deliv_grp_cd AS "Delivery Group Code",
    q.spcl_proc_id AS "Special Process Ind",
    q.cust_grp2_cd AS "Customer Group 2 Code",
    
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust AS "Ship To Customer",
    q.own_cust AS "Common Owner",
    q.sales_org AS "Sales Organization",
    q.distr_chan AS "Distribution Channel",
    q.cust_grp AS "Customer Group",
    q.prim_ship_facility_id AS "Primary Ship Facility ID",
    q.tire_cust_typ_cd AS "OE / Replacement Ind",

    q.matl_id AS "Material ID",
    q.prod_hier AS "Product Hierarchy",
    q.pbu_nbr AS "PBU Nbr",
    q.PBU AS "PBU",
    
    q.brand AS "Brand",
    q.assoc_brand AS "Associate Brand",
    q.super_brand AS "Super Brand",

    q.mkt_area AS "Market Area",
    q.mkt_group AS "Market Group", 
    q.prod_group AS "Product Group",
    q.prod_line AS "Product Line",

    q.ctgy AS "Category",
    q.segment AS "Segment",
    q.tier AS "Tier",
    q.sales_prod_line AS "Sales Product Line",
    q.compression_factor AS "Compression Factor",
    
    q.ship_facility_id AS "Ship Facility ID",
    q.ship_facility AS "Ship Facility", 
    q.ship_pt_id AS "Ship Point ID",
    
    q.order_dt AS "Order Create Date",
    q.ordd AS "ORDD",
    
    q.frdd_fmad AS "FRDD FMAD",
    q.frdd_fpgi AS "FRDD FPGI",
    q.frdd AS "FRDD",
    
    q.fcdd_fmad AS "FCDD FMAD",
    q.fcdd_fpgi AS "FCDD FPGI",
    q.fcdd AS "FCDD",
    
    q.pln_matl_avl_dt AS "Planned MAD",
    q.pln_goods_iss_dt AS "Planned Goods Issue Dt",
    q.pln_deliv_dt AS "Planned Delivery Dt",
    q.first_date AS "First Date",
    
    q.qty_uom AS "Quantity UOM",
    q.order_qty AS "Order Qty",
    q.cnfrm_qty AS "Confirmed Qty",
    q.open_cnfrm_qty AS "Open Confirmed Qty",
    q.wt_uom AS "Weight UOM",
    q.gross_wt AS "Gross Weight",
    q.net_wt AS "Net Weight",
    q.open_cnfrm_wt AS "Open Confirmed Weight",
    q.vol_uom AS "Volume UOM",
    q.vol AS "Volume",
    q.open_cnfrm_vol AS "Open Confirmed Volume",
    q.open_cnfrm_compress_vol AS "Open Confirmed Compressed Volume"

FROM (

SELECT
    odc.order_fiscal_yr,
    odc.order_id,
    odc.order_line_nbr,
    odc.sched_line_nbr,
    
    CASE
        WHEN odc.cust_rdd < odc.frst_rdd
            THEN 'ORDD < FRDD'
        WHEN odc.cust_rdd = odc.frst_rdd
            THEN 'ORDD = FRDD'
        WHEN odc.cust_rdd > odc.frst_rdd
            THEN 'ORDD > FRDD'
    END AS ordd_test,
    CASE
        WHEN odc.frst_rdd < CURRENT_DATE
            THEN 'FRDD < Today'
        WHEN odc.frst_rdd = CURRENT_DATE
            THEN 'FRDD = Today'
        WHEN odc.frst_rdd > CURRENT_DATE
            THEN 'FRDD > Today'
    END AS frdd_test,
    CASE
        WHEN odc.frst_prom_deliv_dt < CURRENT_DATE
            THEN 'FCDD < Today'
        WHEN odc.frst_prom_deliv_dt = CURRENT_DATE
            THEN 'FCDD = Today'
        WHEN odc.frst_prom_deliv_dt > CURRENT_DATE
            THEN 'FCDD > Today'
    END AS fcdd_test,
    CASE
        WHEN frdd < fcdd
            THEN 'FRDD < FCDD'
        WHEN frdd = fcdd
            THEN 'FRDD = FCDD'
        WHEN frdd > fcdd
            THEN 'FRDD > FCDD'
    END AS frdd_fcdd_test,
    CAST((CAST(first_date - CURRENT_DATE AS INTEGER) (FORMAT '-9(3)')) || ' Days to First Date' AS VARCHAR(100)) AS days_to_first_date,
    CAST((CAST(ordd - CURRENT_DATE AS INTEGER) (FORMAT '-9(3)')) || ' Days to ORDD' AS VARCHAR(100)) AS days_to_ordd,
    CAST((CAST(frdd_fmad - CURRENT_DATE AS INTEGER) (FORMAT '-9(3)')) || ' Days to FRDD FMAD' AS VARCHAR(100)) AS days_to_frdd_fmad,
    CAST((CAST(frdd - CURRENT_DATE AS INTEGER) (FORMAT '-9(3)')) || ' Days to FRDD' AS VARCHAR(100)) AS days_to_frdd,
    CAST((CAST(fcdd - CURRENT_DATE AS INTEGER) (FORMAT '-9(3)')) || ' Days to FRDD' AS VARCHAR(100)) AS days_to_fcdd,
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    COALESCE(NULLIF(odc.return_ind, ''), 'N') AS return_ind,
    odc.cancel_ind,
    odc.deliv_blk_ind,
    odc.deliv_blk_cd,
    odc.ship_cond_id,
    odc.deliv_prty_id,
    odc.route_id,
    odc.deliv_grp_cd,
    odc.spcl_proc_id,
    odc.cust_grp2_cd,
    
    odc.ship_to_cust_id,
    cust.ship_to_cust_id || ' - ' || cust.cust_name AS ship_to_cust,
    cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust,
    cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
    cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
    cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
    cust.prim_ship_facility_id,
    cust.tire_cust_typ_cd,

    odc.matl_id,
    matl.pbu_nbr || matl.mkt_area_nbr AS prod_hier,
    matl.pbu_nbr,
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
    
    matl.brand_id || ' - ' || matl.brand_name AS brand,
    matl.assoc_brand_id || ' - ' || matl.assoc_brand_name AS assoc_brand,
    matl.super_brand_id || ' - ' || matl.super_brand_name AS super_brand,

    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS mkt_area,
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name AS mkt_group,
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name AS prod_group,
    matl.prod_line_nbr || ' - ' || matl.prod_line_name AS prod_line,

    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS ctgy,
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS segment,
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS tier,
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS sales_prod_line,
    CAST(CASE matl.pbu_nbr || matl.mkt_area_nbr
        WHEN '0101' THEN 0.75
        WHEN '0108' THEN 0.80
        WHEN '0305' THEN 1.20
        WHEN '0314' THEN 1.20
        WHEN '0406' THEN 1.20
        WHEN '0507' THEN 0.75
        WHEN '0711' THEN 0.75
        WHEN '0712' THEN 0.75
        WHEN '0803' THEN 1.20
        WHEN '0923' THEN 0.75
        ELSE 1
    END AS DECIMAL(15,3)) AS compression_factor,
    
    odc.facility_id AS ship_facility_id,
    fac.facility_id || ' - ' || fac.fac_name AS ship_facility,
    odc.ship_pt_id,
    
    odc.order_dt,
    odc.cust_rdd AS ordd,
    
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    
    odc.fc_matl_avl_dt AS fcdd_fmad,
    odc.fc_pln_goods_iss_dt AS fcdd_fpgi,
    odc.frst_prom_deliv_dt AS fcdd,
    
    odc.pln_matl_avl_dt,
    odc.pln_goods_iss_dt,
    odc.pln_deliv_dt,
    fd.pln_deliv_dt AS first_date,
    
    odc.qty_unit_meas_id AS qty_uom,
    odc.order_qty,
    odc.cnfrm_qty,
    ool.open_cnfrm_qty,
    odc.wt_units_meas_id AS wt_uom,
    odc.gross_wt,
    odc.net_wt,
    matl.unit_wt * ool.open_cnfrm_qty AS open_cnfrm_wt,
    odc.vol_unit_meas_id AS vol_uom,
    odc.vol,
    matl.unit_vol * ool.open_cnfrm_qty AS open_cnfrm_vol,
    compression_factor * open_cnfrm_vol AS open_cnfrm_compress_vol

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr
        AND ool.open_cnfrm_qty > 0

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id    

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = odc.facility_id
        AND fac.facility_type_id <> ''

    INNER JOIN na_bi_vws.order_detail_curr fd
        ON fd.order_fiscal_yr = odc.order_fiscal_yr
        AND fd.order_id = odc.order_id
        AND fd.order_line_nbr = odc.order_line_nbr
        AND fd.sched_line_nbr = 1

WHERE
    odc.order_fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1)) -2) AS CHAR(4))
    AND odc.order_cat_id = 'C'
    AND odc.order_type_id <> 'ZLZ'
    AND odc.po_type_id <> 'RO'
    AND odc.cust_grp2_cd = 'TLB'
    
    ) q
    
ORDER BY
    q.order_fiscal_yr,
    q.order_id,
    q.order_line_nbr,
    q.sched_line_nbr