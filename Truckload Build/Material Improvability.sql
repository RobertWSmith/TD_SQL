SELECT
    ool.order_id AS "Order ID",
    ool.order_line_nbr AS "Order Line Nbr",
    ool.sched_line_nbr AS "Schedule Line Nbr",
    
    odc.ship_to_cust_id AS "Ship To Customer ID",
    cust.cust_name AS "Ship To Customer Name",
    cust.own_cust_id AS "Common Owner ID",
    cust.own_cust_name AS "Common Owner Name",
    cust.sales_org_cd AS "Sales Org Code",
    cust.sales_org_name AS "Sales Org Name",
    cust.distr_chan_cd AS "Distribution Channel Code",
    cust.distr_chan_name AS "Distribution Channel Name",
    cust.cust_grp_id AS "Customer Group ID",
    cust.cust_grp_name AS "Customer Group Name",
    odc.cust_grp2_cd AS "Customer Group 2 Code",
    odc.deliv_prty_id AS "Delivery Priority ID",
    
    odc.matl_id AS "Material ID",
    matl.matl_no_8 || ' - ' || matl.descr AS "Material Description",
    matl.pbu_nbr AS "PBU Number",
    matl.pbu_name AS "PBU Name",
    matl.mkt_ctgy_mkt_area_nbr AS "Category Code",
    matl.mkt_ctgy_mkt_area_name AS "Category Name",
    matl.mkt_ctgy_mkt_grp_nbr AS "Category Group Code",
    matl.mkt_ctgy_mkt_grp_name AS "Category Group Name",
    
    odc.facility_id AS "Facility ID",
    fac.fac_name AS "Facility Name",
    odc.ship_pt_id AS "Ship Point ID",
    
    odc.order_cat_id AS "Order Category ID",
    odc.order_type_id AS "Order Type ID",
    odc.po_type_id AS "PO Type ID",
    
    odc.order_dt AS "Order Create Date",
    odc.frst_rdd AS FRDD,
    odc.frst_prom_deliv_dt AS FCDD,
    fd.pln_deliv_dt AS "First Date",
    
    odc.qty_unit_meas_id AS "Quantity UOM",
    ool.open_cnfrm_qty AS "Open Confirmed Qty",
    ool.open_cnfrm_qty * matl.unit_wt AS "Open Confirmed Weight",
    matl.unit_vol * ool.open_cnfrm_qty AS "Open Confirmed Volume",
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
    END AS DECIMAL(15,3)) AS "Material Compression Factor",
    "Material Compression Factor" * "Open Confirmed Volume" AS "Open Confirmed Compressed Volume",
    
    SUM(ool.open_cnfrm_qty) OVER (PARTITION BY odc.matl_id, odc.facility_id) AS "Total Open Confirmed Qty",
    inv.est_days_supply AS "Esimated Days of Supply",
    inv.avail_to_prom_qty AS "ATP Qty",
    CASE
        WHEN inv.avail_to_prom_qty = 0 OR inv.avail_to_prom_qty < ool.open_cnfrm_qty
            THEN 'Not Improvable'
        WHEN "Total Open Confirmed Qty" * 2 < inv.avail_to_prom_qty
            THEN 'All Improvable'
        WHEN "Total Open Confirmed Qty" <= inv.avail_to_prom_qty OR ool.open_cnfrm_qty <= inv.avail_to_prom_qty
            THEN 'Line Improvable'
        WHEN "Total Open Confirmed Qty" > inv.avail_to_prom_qty
            THEN 'Some Improvable'
    END AS "ATP Improvability Type",
    CASE
        WHEN inv.est_days_supply > 30
            THEN 'Improvable - 30+ DSI'
        WHEN inv.est_days_supply > 15
            THEN 'Improvable - 15+ DSI'
        ELSE '15 DSI or Less'
    END AS "DSI Improvability Type"

FROM na_bi_vws.open_order_schdln_curr ool

    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND odc.po_type_id <> 'RO'
        AND odc.frst_matl_avl_dt < (CURRENT_DATE-1)

    INNER JOIN na_bi_vws.order_detail_curr fd
        ON fd.order_id = ool.order_id
        AND fd.order_line_nbr = ool.order_line_nbr
        AND fd.sched_line_nbr = 1
        AND fd.order_cat_id = 'C'
        AND fd.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND fd.po_type_id <> 'RO'
        AND fd.pln_deliv_dt > (CURRENT_DATE + 14)

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr = '01'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
    
    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = odc.facility_id
        AND fac.facility_type_id NOT IN ('N', '')

    LEFT OUTER JOIN na_bi_vws.inventory inv
        ON inv.day_dt = (CURRENT_DATE-1)
        AND inv.facility_id = odc.facility_id
        AND inv.matl_id = odc.matl_id

WHERE
    ool.open_cnfrm_qty > 0
    AND inv.avail_to_prom_qty > 0
    AND (    
        CASE
            WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322') OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
                THEN 1 -- OE
            ELSE 0 -- Replacement
        END 
        ) = 0

ORDER BY
    ool.order_id,
    ool.order_line_nbr,
    ool.sched_line_nbr