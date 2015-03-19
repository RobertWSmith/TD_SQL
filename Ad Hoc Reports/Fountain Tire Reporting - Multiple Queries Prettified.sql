SELECT
    odc.order_fiscal_yr AS "Order Fiscal Year",
    odc.order_id AS "Order ID",
    odc.order_line_nbr AS "Order Line Nbr",
    
    odc.matl_id AS "Material ID",
    matl.matl_no_8 || ' - ' || matl.descr AS "Material Description",
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS "Market Area",
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS "Category Area",
    
    odc.ship_to_cust_id AS "Ship To Customer ID",
    cust.cust_name AS "Ship To Customer Name",
    cust.own_cust_id AS "Common Owner ID",
    cust.own_cust_name AS "Common Owner Name",
    cg.cust_grp_id || ' - ' || cg.name AS "Customer Group",
    
    odc.order_dt AS "Order Create Date",
    odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1) AS "Order Create Month",
    odc.cust_rdd AS ORDD,
    odc.frst_matl_avl_dt AS "FRDD FMAD",
    odc.frst_pln_goods_iss_dt AS "FRDD FPGI",
    odc.frst_rdd AS FRDD,
    odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1) AS "FRDD Month",
    CASE
        WHEN CAST( COALESCE( odc.cust_rdd, odc.frst_rdd ) - odc.order_dt AS INTEGER ) < 14
            THEN CAST( odc.order_dt + 14 AS DATE )
        ELSE COALESCE( odc.cust_rdd, odc.frst_rdd )
    END AS "Fountain Tire RDD",
    "Fountain Tire RDD" - (EXTRACT(DAY FROM "Fountain Tire RDD") - 1) AS "Fountain Tire RDD Month",
    
    odc.facility_id AS "Facility ID",
    cust.prim_ship_facility_id AS "Primary Ship Facility ID",
    CASE 
        WHEN odc.facility_id = 'N5US' 
            THEN 'Large Order' 
        WHEN odc.facility_id <> cust.prim_ship_facility_id 
            THEN 'Out of Area' 
        ELSE 'Primary Facility' 
    END AS "Facility Test",
    
    odc.order_cat_id AS "Order Category ID",
    odc.order_type_id AS "Order Type ID",
    odc.po_type_id AS "PO Type ID",
    odc.route_id AS "Route ID",
    odc.ship_cond_id AS "Shipping Condition ID",
    odc.spcl_proc_id AS "Special Process Indicator",
    odc.cust_grp2_cd AS "Customer Group 2 Code",
    
    MAX(CASE WHEN oosl.order_id IS NOT NULL THEN 'Y' END) AS "Open Order Ind",
    MAX(CASE WHEN oosl.credit_hold_flg = 'Y' THEN 'Y' END) AS "Credit Hold Ind",
    (CASE WHEN odc.return_ind = 'Y' THEN 'Y' END) AS "Return Ind",
    (CASE WHEN odc.cancel_ind = 'Y' THEN 'Y' END) AS "Cancel Ind",
    (CASE WHEN odc.deliv_blk_ind = 'Y' THEN 'Y' END) AS "Delivery Block Ind",
    
    odc.deliv_blk_cd AS "Delivery Block Code",
    odc.deliv_prty_id AS "Delivery Priority ID",
    odc.cancel_dt AS "Cancel Date",
    NULLIF(odc.rej_reas_id, '') || ' - ' || odc.rej_reas_desc AS "Reason for Rejection",
    
    odc.qty_unit_meas_id AS "Quantity Unit of Measure",
    
    MAX(odc.order_qty) AS "Current Order Qty",
    SUM(odc.cnfrm_qty) AS "Current Confirmed Qty",
    MAX(ZEROIFNULL(orig.order_qty)) AS "Original Order Qty",
    CAST("Original Order Qty" - "Current Order Qty" AS INTEGER) AS "Original - Current Order Qty",
    
    SUM(ZEROIFNULL(oosl.open_cnfrm_qty)) AS "Open Confirmed Qty",
    SUM(ZEROIFNULL(oosl.uncnfrm_qty)) AS "Unconfirmed Qty",
    SUM(ZEROIFNULL(oosl.back_order_qty)) AS "Back Order Qty",
    SUM(ZEROIFNULL(oosl.defer_qty) + ZEROIFNULL(oosl.wait_list_qty) + ZEROIFNULL(oosl.in_proc_qty) + ZEROIFNULL(oosl.othr_order_qty)) AS "Other Open Qty",
    ("Open Confirmed Qty" + "Unconfirmed Qty" + "Back Order Qty" + "Other Open Qty") AS "Total Open Qty",
    
    ZEROIFNULL(dd.deliv_qty) AS "Delivered Qty",
    ZEROIFNULL(dd.in_proc_qty) AS "In Process Qty",
    ZEROIFNULL(dd.curr_mth_gi_qty) AS "Current Month AGI Qty",
    ZEROIFNULL(dd.prev_mth_gi_qty) AS "Previous Month AGI Qty",

    CASE
        WHEN "Open Order Ind" = 'Y'
            THEN MAX(odc.order_qty)
        WHEN "Open Order Ind" IS NULL AND ("Reason for Rejection" IS NULL OR (odc.rej_reas_id = 'Z2' AND odc.po_type_id IN ('DT', 'WA', 'WC', 'WS')) OR odc.rej_reas_id IN ('Z6', 'ZW', 'ZX', 'ZY'))
            THEN (CASE
                WHEN ZEROIFNULL(dd.deliv_qty) > MAX(odc.order_qty)
                    THEN ZEROIFNULL(dd.deliv_qty)
                ELSE MAX(odc.order_qty)
            END)
        ELSE (CASE
            WHEN dd.order_id IS NULL -- missing delivery and reason for rejection present
                THEN 0
            ELSE (CASE
                WHEN ZEROIFNULL(dd.deliv_qty) > SUM(odc.cnfrm_qty)
                    THEN ZEROIFNULL(dd.deliv_qty)
                ELSE SUM(odc.cnfrm_qty)
            END)
        END)
    END AS "Adjusted Order Qty",
    
    CASE
        WHEN "Reason for Rejection" IS NOT NULL OR (ZEROIFNULL(dd.deliv_qty) = 0 AND "Open Order Ind" IS NULL)
            THEN "Adjusted Order Qty" - ZEROIFNULL(dd.deliv_qty)
        ELSE 0
    END AS "Cancelled Qty"

FROM na_bi_vws.order_detail_curr odc

    LEFT OUTER JOIN (
                SELECT
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr,
                    SUM(ddc.deliv_qty) AS deliv_qty,
                    SUM(ZEROIFNULL(CAST(dip.qty_to_ship AS DECIMAL(15,3)))) AS in_proc_qty
                    SUM(CASE WHEN ddc.actl_goods_iss_dt / 100 = (CURRENT_DATE-1) / 100 THEN ddc.deliv_qty ELSE 0 END) AS curr_mth_gi_qty,
                    SUM(CASE WHEN ddc.actl_goods_iss_dt / 100 < (CURRENT_DATE-1) / 100 THEN ddc.deliv_qty ELSE 0 END) AS prev_mth_gi_qty
                
                FROM na_bi_vws.delivery_detail_curr ddc
                
                    LEFT OUTER JOIN gdyr_bi_vws.deliv_in_proc_curr dip
                        ON dip.deliv_id = ddc.deliv_id
                        AND dip.deliv_line_nbr = ddc.deliv_line_nbr
                        AND dip.order_id = ddc.order_id
                        AND dip.order_line_nbr = ddc.order_line_nbr
                
                WHERE
                    (ddc.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 3) AS CHAR(4)) OR dip.deliv_id IS NOT NULL)
                    AND ddc.deliv_qty > 0
                    AND ddc.distr_chan_cd <> '81'
                
                GROUP BY
                    ddc.order_fiscal_yr,
                    ddc.order_id,
                    ddc.order_line_nbr
            ) dd
        ON dd.order_fiscal_yr = odc.order_fiscal_yr
        AND dd.order_id = odc.order_id
        AND dd.order_line_nbr = odc.order_line_nbr

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.ext_matl_grp_id = 'TIRE'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        AND cust.own_cust_id = '00A0009337'
    
    INNER JOIN na_bi_vws.nat_sls_doc_itm_curr sdi
        ON sdi.sls_doc_id = odc.order_id
        AND sdi.sls_doc_itm_id = odc.order_line_nbr
        AND sdi.fiscal_yr >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 3) AS CHAR(4))
        AND sdi.orig_sys_id = 2
        AND sdi.sbu_id = 2
    
    LEFT OUTER JOIN na_bi_vws.order_detail orig
        ON orig.order_id = odc.order_id
        AND orig.order_line_nbr = odc.order_line_nbr
        AND orig.sched_line_nbr = odc.sched_line_nbr
        AND CAST(sdi.src_crt_ts AS DATE) BETWEEN orig.eff_dt AND orig.exp_dt
        AND orig.order_cat_id = 'c'
        AND orig.order_type_id NOT IN ('zls', 'zlz')
        AND orig.po_type_id <> 'ro'
    
    LEFT OUTER JOIN na_bi_vws.open_order_schdln_curr oosl
        ON oosl.order_id = odc.order_id
        AND oosl.order_line_nbr = odc.order_line_nbr
        AND oosl.sched_line_nbr = odc.sched_line_nbr
    
    LEFT OUTER JOIN gdyr_vws.sales_org so
        ON so.sales_org_cd = odc.sales_org_cd
        AND so.exp_dt = CAST('5555-12-31' AS DATE)
        AND so.lang_id = 'E'
        AND so.orig_sys_id = sdi.orig_sys_id
        AND so.src_sys_id = 2
        AND so.sbu_id = sdi.sbu_id

    LEFT OUTER JOIN gdyr_vws.distr_chan dc
        ON dc.distr_chan_cd = odc.distr_chan_cd
        AND dc.exp_dt = CAST('5555-12-31' AS DATE)
        AND dc.orig_sys_id = sdi.orig_sys_id
        AND dc.src_sys_id = so.src_sys_id
        AND dc.sbu_id = sdi.sbu_id

    LEFT OUTER JOIN gdyr_vws.cust_grp cg
        ON cg.cust_grp_id = odc.cust_grp_id
        AND cg.exp_dt = CAST('5555-12-31' AS DATE)
        AND cg.lang_id = 'E'
        AND cg.orig_sys_id = sdi.orig_sys_id
        AND cg.src_sys_id = so.src_sys_id
        AND cg.sbu_id = sdi.sbu_id

WHERE
    (
        odc.order_dt BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR odc.frst_rdd BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR "Fountain Tire RDD" BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
    )
    AND odc.order_cat_id = 'C'
    AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
    AND odc.po_type_id <> 'RO'

GROUP BY
    odc.order_fiscal_yr,
    odc.order_id,
    dd.order_id,
    odc.order_line_nbr,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr,
    matl.pbu_nbr || ' - ' || matl.pbu_name,
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name,
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
    
    odc.ship_to_cust_id,
    cust.cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cg.cust_grp_id || ' - ' || cg.name,
    
    odc.order_dt,
    odc.order_dt - (EXTRACT(DAY FROM odc.order_dt) - 1),
    odc.cust_rdd,
    odc.frst_matl_avl_dt,
    odc.frst_pln_goods_iss_dt,
    odc.frst_rdd,
    odc.frst_rdd - (EXTRACT(DAY FROM odc.frst_rdd) - 1),
    "Fountain Tire RDD",
    "Fountain Tire RDD Month",
    
    odc.facility_id,
    cust.prim_ship_facility_id,
    "Facility Test",
    
    odc.order_cat_id,
    odc.order_type_id,
    odc.po_type_id,
    odc.rej_reas_id,
    odc.route_id,
    odc.ship_cond_id,
    odc.spcl_proc_id,
    odc.cust_grp2_cd,

    (CASE WHEN odc.return_ind = 'Y' THEN 'Y' END),
    (CASE WHEN odc.cancel_ind = 'Y' THEN 'Y' END),
    (CASE WHEN odc.deliv_blk_ind = 'Y' THEN 'Y' END),
    
    odc.deliv_blk_cd,
    odc.deliv_prty_id,
    odc.cancel_dt,
    NULLIF(odc.rej_reas_id, '') || ' - ' || odc.rej_reas_desc,
    
    odc.qty_unit_meas_id,

    ZEROIFNULL(dd.deliv_qty),
    ZEROIFNULL(dd.in_proc_qty),
    ZEROIFNULL(dd.curr_mth_gi_qty),
    ZEROIFNULL(dd.prev_mth_gi_qty)

ORDER BY
    odc.order_id,
    odc.order_line_nbr
;

SELECT 
    ODC.ORDER_FISCAL_YR AS "Order Fiscal Year",
    ODC.ORDER_ID AS "Order ID",
    ODC.ORDER_LINE_NBR AS "Order Line Nbr",
    
    ODC.MATL_ID AS "Material ID",
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
    MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS "Market Category Code",
    
    ODC.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.CUST_NAME AS "Ship To Customer Name",
    ODC.SALES_ORG_CD AS "Sales Org Code",
    ODC.DISTR_CHAN_CD AS "Distr Chan Code",
    ODC.CO_CD AS "Company Code",
    ODC.DIV_CD AS "Division Code",
    ODC.CUST_GRP_ID AS "Customer Group ID",
    ODC.CUST_GRP2_CD AS "Customer Group 2 Code",
    
    ODC.FACILITY_ID AS "Facility ID",
    ODC.SHIP_PT_ID AS "Shipping Point ID",
    
    ODC.ORDER_CAT_ID AS "Order Category ID",
    ODC.ORDER_TYPE_ID AS "Order Type ID",
    MAX( ODC.CANCEL_IND ) AS "Cancel Ind.",
    MAX( ODC.CANCEL_DT ) AS "Cancel Date",
    MAX( ODC.RETURN_IND ) AS "Return Ind.",
    ODC.PO_TYPE_ID AS "PO Type ID",
    ODC.DELIV_BLK_CD AS "Delivery Block Code",
    ODC.ORDER_CREATOR AS "Order Creator",
    ODC.SHIP_COND_ID AS "Shipping Condition ID",
    ODC.DELIV_PRTY_ID AS "Delivery Priority ID",
    ODC.ROUTE_ID AS "Route ID",
    ODC.DELIV_GRP_CD AS "Delivery Group Code",
    ODC.SPCL_PROC_ID AS "Special Process Ind.",
    
    ODC.ORDER_DT AS "Order Create Date",
    ODC.FRST_RDD AS FRDD,
    CASE
        WHEN CAST( COALESCE( ODC.CUST_RDD, ODC.FRST_RDD ) - ODC.ORDER_DT AS INTEGER ) < 14
            THEN CAST( ODC.ORDER_DT + 14 AS DATE )
        ELSE COALESCE( ODC.CUST_RDD, ODC.FRST_RDD )
    END AS "Fountain Tire RDD",
    
    ODC.ORDER_DT - ( EXTRACT( DAY FROM ODC.ORDER_DT ) - 1 ) AS "Order Create Month",
    ODC.FRST_RDD - ( EXTRACT( DAY FROM ODC.FRST_RDD ) - 1 ) AS "FRDD Month",
    "Fountain Tire RDD" - ( EXTRACT( DAY FROM "Fountain Tire RDD" ) - 1 ) AS "Fountain Tire RDD Month",

    MAX( ODC.ORDER_QTY ) AS "Order Qty.",
    SUM( ODC.CNFRM_QTY ) AS "Confirmed Qty.",
    ODC.QTY_UNIT_MEAS_ID AS "Quantity UOM"
    
FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
        
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
        AND CUST.OWN_CUST_ID = '00A0009337'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

    

WHERE
    (
        ODC.ORDER_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR ODC.FRST_RDD BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR "Fountain Tire RDD" BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
    )
    AND ODC.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
    AND ODC.ORDER_CAT_ID = 'C'
    AND ODC.PO_TYPE_ID NOT IN ( 'RO' )
    
GROUP BY
    ODC.ORDER_FISCAL_YR,
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    
    ODC.MATL_ID,
    PBU,
    "Market Category Code",
    
    ODC.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    ODC.SALES_ORG_CD,
    ODC.DISTR_CHAN_CD,
    ODC.CO_CD,
    ODC.DIV_CD,
    ODC.CUST_GRP_ID,
    ODC.CUST_GRP2_CD,
    
    ODC.FACILITY_ID,
    ODC.SHIP_PT_ID,
    
    ODC.ORDER_CAT_ID,
    ODC.ORDER_TYPE_ID,
    ODC.PO_TYPE_ID,
    ODC.DELIV_BLK_CD,
    ODC.ORDER_CREATOR,
    ODC.SHIP_COND_ID,
    ODC.DELIV_PRTY_ID,
    ODC.ROUTE_ID,
    ODC.DELIV_GRP_CD,
    ODC.SPCL_PROC_ID,
    
    ODC.ORDER_DT,
    ODC.FRST_RDD,
    "Fountain Tire RDD",
    
    "Order Create Month",
    "FRDD Month",
    "Fountain Tire RDD Month",

    ODC.QTY_UNIT_MEAS_ID

ORDER BY
    ODC.ORDER_FISCAL_YR,
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR
;

SELECT
    DDC.FISCAL_YR AS "Delivery Fiscal Year",
    DDC.DELIV_ID AS "Delivery ID",
    DDC.DELIV_LINE_NBR AS "Delivery Line Nbr",
    
    DDC.ORDER_FISCAL_YR AS "Order Fiscal Year",
    DDC.ORDER_ID AS "Order ID",
    DDC.ORDER_LINE_NBR AS "Order Line Nbr",
    
    DDC.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.CUST_NAME AS "Ship To Customer Name",
    
    DDC.MATL_ID AS "Material ID",
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
    MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS "Market Category Code",
    
    DDC.FACILITY_ID AS "Facility ID",
    DDC.DELIV_LINE_FACILITY_ID AS "Delivery Line Facility ID",
    DDC.SHIP_PT_ID AS "Shipping Point ID",
    
    DDC.DELIV_NOTE_CREA_DT AS "Delivery Note Create Date",
    DDC.DELIV_LINE_CREA_DT AS "Delivery Line Create Date",
    DDC.LOAD_DT AS "Load Date",
    DDC.PICK_DT AS "Pick Date",
    DDC.ACTL_GOODS_ISS_DT AS "Actual Goods Issue Date",
    DDC.DELIV_DT AS "Delivery Date",
    DDC.DELIV_DT - ( EXTRACT( DAY FROM DDC.DELIV_DT ) - 1 ) AS "Delivery Month",
    
    DDC.DELIV_TYPE_ID AS "Delivery Type ID",
    DDC.DELIV_CAT_ID AS "Delivery Category ID",
    DDC.DELIV_PRTY_ID AS "Delivery Priority ID",
    DDC.BILL_LADING_ID AS "Bill of Lading ID",
    DDC.SHIP_COND_ID AS "Shipping Condition ID",
    DDC.UNLD_PT_CD AS "Unloading Point Text",
    DDC.SPCL_PROC_ID AS "Special Process Ind.",
    DDC.RPT_FRT_PLCY_CD AS "Customer Group 2 Code",
    DDC.SRC_CRT_USR_ID AS "Source Create User ID",
    
    DDC.DELIV_QTY AS "Delivered Qty.",
    DDC.QTY_UNIT_MEAS_ID AS "Quantity UOM",
    DDC.VOL AS "Volume",
    DDC.VOL_UNIT_MEAS_ID AS "Volume UOM",
    DDC.GROSS_WT AS "Gross Wt.",
    DDC.NET_WT AS "Net Wt.",
    DDC.WT_UNIT_MEAS_ID AS "Weight UOM"
    
FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID
        AND CUST.OWN_CUST_ID = '00A0009337'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = DDC.MATL_ID
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

WHERE
    (DDC.ACTL_GOODS_ISS_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
        OR DDC.ACTL_GOODS_ISS_DT IS NULL)
    AND DDC.DELIV_QTY > 0 -- avoid returns
    AND DDC.FISCAL_YR >= CAST( EXTRACT(YEAR FROM (CURRENT_DATE-1))-3 AS CHAR(4))
    
ORDER BY
    DDC.FISCAL_YR,
    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR
;

SELECT
    SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST_NAME AS "Ship To Customer Name",
    OWN_CUST_ID AS "Common Owner ID",
    OWN_CUST_NAME AS "Common Owner Name",
    SALES_ORG_CD AS "Sales Org Code",
    SALES_ORG_NAME AS "Sales Org Name",
    DISTR_CHAN_CD AS "Distribution Channel Code",
    DISTR_CHAN_NAME AS "Distribution Channel Name",
    CUST_GRP_ID AS "Customer Group ID",
    CUST_GRP_NAME AS "Customer Group Name",
    ADDR_LINE_1 AS "Address Line 1",
    ADDR_LINE_2 AS "Address Line 2",
    ADDR_LINE_3 AS "Address Line 3",
    ADDR_LINE_4 AS "Address Line 4",
    POSTAL_CD AS "Postal Code",
    DISTRICT_NAME AS "District Name",
    TERR_NAME AS "Territory Name",
    CITY_NAME AS "City Name",
    CNTRY_NAME_CD AS "Country Name Code",
    PHN_NO AS "Phone Nbr.",
    FAX_NO AS "Fax Nbr.",
    PRIM_SHIP_FACILITY_ID AS "Primary Ship Facility ID",
    DELIV_PRTY_CD AS "Delivery Priority Code",
    SHIP_COND_ID AS "Shipping Condition ID",
    TIRE_CUST_TYP_CD AS "Tire Customer Type Code",
    ACTIV_IND AS "Active Cust. Ind.",
    CUST_GRP1_CD AS "Customer Group 1 Code",
    CUST_GRP2_CD AS "Customer Group 2 Code"

FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR

WHERE
    OWN_CUST_ID = '00A0009337'
    
ORDER BY
    SHIP_TO_CUST_ID
;

SELECT
    MATL_ID AS "Material ID",
    MATL_ID_TRIM AS "Trimmed Material ID",
    MATL_NO_8 AS "Material ID (8)",
    
    DESCR AS "Material Description",
    TIC_CD AS "TIC Code",
    
    BRAND_ID AS "Brand ID",
    BRAND_NAME AS "Brand Name",
    EXT_MATL_GRP_ID AS "External Material Group ID",
    STK_CLASS_ID AS "Stock of Class ID",
    MATL_PRTY AS "Material Priority",
    MATL_PRTY_CTGY AS "Material Priority Category",
    MATL_PRTY_DESCR AS "Material Priority Description",
    TIRE_SZ_TEXT AS "Tire Size Text",
    UNIT_WT AS "Unit Wt.",
    NET_WT AS "Net Wt.",
    WT_MEAS_ID AS "Weight UOM",
    UNIT_VOL AS "Unit Volume",
    VOL_MEAS_ID AS "Volume UOM",
    PBU_NBR AS "PBU Nbr.",
    PBU_NAME AS "PBU Name", 
    MKT_AREA_NBR AS "Market Area Nbr.",
    MKT_AREA_NAME AS "Market Area Name",
    MKT_GRP_NBR AS "Market Group Nbr.",
    MKT_GRP_NAME AS "Market Group Name",
    PROD_GRP_NBR AS "Product Group Nbr.",
    PROD_GRP_NAME AS "Product Group Name",
    PROD_LINE_NBR AS "Product Line Nbr.",
    PROD_LINE_NAME AS "Product Line Name",
    MKT_CTGY_MKT_AREA_NBR AS "Mkt. Ctgy. Market Area Nbr.",
    MKT_CTGY_MKT_AREA_NAME AS "Mkt. Ctgy. Market Area Name",
    MKT_CTGY_MKT_GRP_NBR AS "Mkt. Ctgy. Market Group Nbr.",
    MKT_CTGY_MKT_GRP_NAME AS "Mkt. Ctgy. Market Group Name",
    MKT_CTGY_PROD_GRP_NBR AS "Mkt. Ctgy. Product Group Nbr.",
    MKT_CTGY_PROD_GRP_NAME AS "Mkt. Ctgy. Product Group Name",
    MKT_CTGY_PROD_LINE_NBR AS "Mkt. Ctgy. Product Line Nbr.",
    MKT_CTGY_PROD_LINE_NAME AS "Mkt. Ctgy. Product Line Name",
    HVA_TXT AS "HVA Text",
    HMC_TXT AS "HMC Text",
    TIRE_FAMILY_NM AS "Tire Family Name",
    MUD_SNOW_FLG AS "Mud/Snow Flag",
    RUN_FLAT_TYP_CD AS "Run Flat Type Code",
    SEASON_TYP_CD AS "Season Type Code",
    TIRE_CUST_TYP_CD AS "Tire Customer Type Code",
    RIM_DIAM_INCHES AS "Rim Diameter (in.)",
    RIM_DIAM_GROUP AS "Rim Diameter Group",
    RIM_DIAM_SUB_GROUP AS "Rim Diameter Subgroup",
    SOP_FAMILY_ID AS "S&OP Family ID",
    SOP_FAMILY_NM AS "S&OP Family Name",
    TIERS AS "Tiers",
    PRTY_SRC_FACL_ID AS "Priority Source Facility ID",
    PRTY_SRC_FACL_NM AS "Priority Source Facility Name"
    
FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR
WHERE
    MATL_ID IN ( 
        SELECT
            ODC.MATL_ID
        FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC                
        WHERE
            ODC.ORDER_CAT_ID = 'C'
            AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
            AND ODC.PO_TYPE_ID <> 'RO'
            AND ODC.ORDER_DT >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-2) || '-01-01' AS DATE)
            AND ODC.SHIP_TO_CUST_ID IN (SELECT SHIP_TO_CUST_ID FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR WHERE OWN_CUST_ID = '00A0009337')
        GROUP BY
            ODC.MATL_ID
            )
ORDER BY
    MATL_ID
;
