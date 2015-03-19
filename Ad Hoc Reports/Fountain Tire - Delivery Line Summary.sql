SELECT
    q.fiscal_yr AS "Delivery Fiscal Year",
    q.deliv_id AS "Delivery ID",
    q.deliv_line_nbr AS "Delivery Line Nbr",
    q.order_fiscal_yr AS "Order Fiscal Year",
    q.order_id AS "Order ID",
    q.order_line_nbr AS "Order Line Nbr",
    q.matl_id AS "Material ID",
    q.matl_descr AS "Material Description",
    q.pbu AS "PBU",
    q.category AS "Category",
    q.ship_to_cust_id AS "Ship To Customer ID",
    q.ship_to_cust_name AS "Ship To Customer Name",
    q.sales_org AS "Sales Organization",
    q.distr_chan AS "Distribution Channel",
    q.cust_grp AS "Customer Group",
    q.cust_grp2_cd AS "Customer Group 2 Code",
    q.facility_id AS "Facility ID",
    q.deliv_line_facility_id AS "Delivery Line Facility ID",
    q.ship_facility_id AS "Ship Facility ID",
    q.ship_pt_id AS "Ship Point ID",
    q.return_ind AS "Return Ind",
    q.deliv_note_crea_dt AS "Delivery Note Create Date",
    q.deliv_line_crea_dt AS "Delivery Line Create Date",
    q.pick_dt AS "Pick Date",
    q.load_dt AS "Load Date",
    q.actl_goods_iss_dt AS "Actual Goods Issue Date",
    q.deliv_dt AS "Delivery Date",
    q.deliv_month AS "Delivery Month",
    q.deliv_type_id AS "Delivery Type ID",
    q.deliv_cat_id AS "Delievry Category ID",
    q.deliv_prty_id AS "Delivery Priority ID",
    q.bill_lading_id AS "Bill of Lading",
    q.ship_cond_id AS "Shipping Condition ID",
    q.in_proc_ind AS "In Process Ind",
    q.qty_uom AS "Quantity UOM",
    q.deliv_qty AS "Delivery Qty",
    q.in_proc_qty AS "In Process Qty",
    q.vol_uom AS "Volume UOM",
    q.vol AS "Volume",
    q.wt_uom AS "Weight UOM",
    q.gross_wt AS "Gross Weight",
    q.net_wt AS "Net Weight"

FROM (

    SELECT
        ddc.fiscal_yr,
        ddc.deliv_id,
        ddc.deliv_line_nbr,
        ddc.order_fiscal_yr,
        ddc.order_id,
        ddc.order_line_nbr,
        
        ddc.matl_id,
        matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
        matl.pbu_nbr || ' - ' || matl.pbu_name AS pbu,
        matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS category,
        
        ddc.ship_to_cust_id,
        cust.cust_name AS ship_to_cust_name,
        cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
        cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
        cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
        ddc.cust_grp2_cd,
        
        ddc.facility_id,
        ddc.deliv_line_facility_id,
        ddc.ship_facility_id,
        ddc.ship_pt_id,
        
        COALESCE(ddc.return_ind, 'N') AS return_ind,
        
        ddc.deliv_note_crea_dt,
        ddc.deliv_line_crea_dt,
        ddc.load_dt,
        ddc.pick_dt,
        ddc.actl_goods_iss_dt,
        ddc.deliv_dt,
        ddc.deliv_dt - (EXTRACT(DAY FROM ddc.deliv_dt) - 1) AS deliv_month,
        
        ddc.deliv_type_id,
        ddc.deliv_cat_id,
        ddc.deliv_prty_id,
        ddc.bill_lading_id,
        ddc.ship_cond_id,
        CASE WHEN dip.qty_to_ship IS NOT NULL THEN 'Y' ELSE 'N' END AS in_proc_ind,
        
        ddc.qty_unit_meas_id AS qty_uom,
        ddc.deliv_qty,
        ZEROIFNULL(dip.qty_to_ship) AS in_proc_qty,
        
        ddc.vol_unit_meas_id AS vol_uom,
        ddc.vol,
        
        ddc.wt_unit_meas_id AS wt_uom,
        ddc.gross_wt,
        ddc.net_wt
        
    FROM na_bi_vws.delivery_detail_curr ddc

        INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
            ON cust.ship_to_cust_id = ddc.ship_to_cust_id
            AND cust.own_cust_id = '00A0009337'

        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = ddc.matl_id
            AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
            AND matl.super_brand_id IN ('01', '02', '03', '05')

        INNER JOIN na_bi_vws.ord_dtl_smry ods
            ON ods.order_fiscal_yr = ddc.order_fiscal_yr
            AND ods.order_id = ddc.order_id
            AND ods.order_line_nbr = ddc.order_line_nbr
            AND ods.order_cat_id = 'C'
            AND ods.order_type_id NOT IN ('ZLS', 'ZLZ')
            AND ods.po_type_id <> 'RO'

        LEFT OUTER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
            ON dip.deliv_id = ddc.deliv_id
            AND dip.deliv_line_nbr = ddc.deliv_line_nbr
            AND dip.order_id = ddc.order_id
            AND dip.order_line_nbr = ddc.order_line_nbr
            AND dip.intra_cmpny_flg = 'N'

    WHERE
        ddc.deliv_qty > 0
        AND ddc.fiscal_yr >= CAST( EXTRACT(YEAR FROM (CURRENT_DATE-1))-3 AS CHAR(4))
        AND (
            (ddc.goods_iss_ind = 'Y' AND ddc.actl_goods_iss_dt >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE))
            OR (ddc.goods_iss_ind = 'N' AND dip.qty_to_ship IS NOT NULL)
            )

    ) q
    
ORDER BY
    q.fiscal_yr,
    q.deliv_id,
    q.deliv_line_nbr,
    q.order_fiscal_yr,
    q.order_id,
    q.order_line_nbr