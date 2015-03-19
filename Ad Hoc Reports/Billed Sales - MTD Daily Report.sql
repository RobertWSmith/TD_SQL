SELECT
    q.bill_dt AS "Invoice Date",
    CAST(q.bill_ref_mth_dt AS FORMAT 'YYYY-MMM') (CHAR(8)) AS "Invoice Month",
    q.own_cust_id AS "Common Owner ID",
    q.own_cust_name AS "Common Owner Name",
    q.acct_type AS "Standard/Managed Acct.",
    q.own_cust AS "Common Owner",
    q.sales_org AS "Sales Organization",
    q.distr_chan AS "Distribution Channel",
    q.cust_grp AS "Customer Group",
    q.tire_cust_typ_cd AS "OE/Replacement Ind.",
    q.matl_id AS "Material ID",
    q.matl_descr AS "Material Description",
    q.pbu AS PBU,
    q.tic_cd AS "TIC Code",
    q.matl_prty AS "Material Priority",
    q.ext_matl_grp_id AS "External Material Group ID",
    q.stk_class_id AS "Stock of Class ID",
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
    q.qty_uom AS "Quantity UOM",
    q.bill_qty AS "Invoiced Units Qty"

FROM (
    
    SELECT
        sa.bill_dt,
        sa.bill_ref_mth_dt,
        
        cust.own_cust_id,
        cust.own_cust_name,
        CASE
            WHEN cust.own_cust_id IN ('00A0003149', '00A0000632', '00A0006582', '00A0006929', '00A0006932',
                    '00A0007036', '00A0009337', '00A0009994', '00A0003088')
                THEN 'Managed Account'
            ELSE 'Standard Account'
        END AS acct_type,
        cust.own_cust_id || ' - ' || cust.own_cust_name AS own_cust,
        cust.sales_org_cd || ' - ' || cust.sales_org_name AS sales_org,
        cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS distr_chan,
        cust.cust_grp_id || ' - ' || cust.cust_grp_name AS cust_grp,
        cust.tire_cust_typ_cd,
        
        matl.matl_id,
        matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
        matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,
        matl.tic_cd,
        matl.matl_prty,
    
        matl.ext_matl_grp_id,
        matl.stk_class_id,
        
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
        
        sa.sls_uom AS qty_uom,
        SUM(sa.sls_qty) AS bill_qty
        
    FROM na_vws.sls_agg sa
    
        INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
            ON matl.matl_id = sa.matl_no
            -- AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
            AND matl.pbu_nbr = '01'
            AND matl.super_brand_id IN ('01', '02', '03', '05')
            AND matl.matl_type_id IN ('PCTL','ACCT')
    
        INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
            ON cust.ship_to_cust_id = sa.legacy_ship_to_cust_no
            AND cust.sales_org_cd IN ('N301', 'N302', 'N303', 'N307', 'N311', 'N312', 'N313', 'N321', 'N322', 'N323', 'N336')
    
    WHERE
        sa.bill_ref_mth_dt = DATE '2014-05-01' -- CAST((CURRENT_DATE-1) - (EXTRACT(DAY FROM (CURRENT_DATE-1)) - 1) AS DATE)
        
    GROUP BY
        sa.bill_dt,
        sa.bill_ref_mth_dt,
        
        cust.own_cust_id,
        cust.own_cust_name,
        acct_type,
        cust.own_cust_id || ' - ' || cust.own_cust_name,
        cust.sales_org_cd || ' - ' || cust.sales_org_name,
        cust.distr_chan_cd || ' - ' || cust.distr_chan_name,
        cust.cust_grp_id || ' - ' || cust.cust_grp_name,
        cust.tire_cust_typ_cd,
        
        matl.matl_id,
        matl.matl_no_8 || ' - ' || matl.descr,
        matl.pbu_nbr || ' - ' || matl.pbu_name,
        matl.tic_cd,
        matl.matl_prty,
    
        matl.ext_matl_grp_id,
        matl.stk_class_id,
        
        matl.brand_id || ' - ' || matl.brand_name,
        matl.assoc_brand_id || ' - ' || matl.assoc_brand_name,
        matl.super_brand_id || ' - ' || matl.super_brand_name,
        
        matl.mkt_area_nbr || ' - ' || matl.mkt_area_name,
        matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name,
        matl.prod_grp_nbr || ' - ' || matl.prod_grp_name,
        matl.prod_line_nbr || ' - ' || matl.prod_line_name,
        
        matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name,
        matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name,
        matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name,
        matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name,
        
        sa.sls_uom
    
    ) q

