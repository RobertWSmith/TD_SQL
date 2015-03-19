SELECT
    odc.ship_cond_id AS "Order Shipping Cond"
    , cust.ship_cond_id AS "Cust. Mstr. Shipping Cond"
    , odc.ship_pt_id AS "Order Ship Point ID"
    , SUBSTR(cust.postal_cd, 1, 3) AS "Postal Code (3)"
    , odc.route_id AS "Order Route ID"
    
    , MAX(odc.route_id) OVER (PARTITION BY odc.ship_cond_id, odc.ship_pt_id, SUBSTR(cust.postal_cd, 1, 3)) AS "Max Route ID"
    , COUNT(DISTINCT odc.order_fiscal_yr || odc.order_id || odc.order_line_nbr) AS "Count of Unique Order Lines"
    , COUNT(DISTINCT odc.matl_id) AS "Count of Unique Material IDs"
    
    , CASE 
        WHEN odc.facility_id IN ('N5US', 'N5CA')
            THEN 'N5US/CA - Large Order'
        WHEN odc.facility_id = cust.prim_ship_facility_id 
            THEN 'Primary LC' 
        ELSE (CASE
            WHEN odc.facility_id LIKE 'N5%'
                THEN 'Out of Area - Direct from Plant'
            ELSE 'Out of Area'
        END)
    END AS "Primary Ship Facility Test"
    
    , odc.order_fiscal_yr AS "Order Fiscal Year"
    , odc.ship_to_cust_id AS "Ship To Customer ID"
    , cust.cust_name AS "Ship To Customer Name"
    , cust.own_cust_id AS "Common Owner ID"
    , cust.own_cust_name AS "Common Owner Name"
    , matl.pbu_nbr || ' - ' || matl.pbu_name AS "PBU"
    
    , odc.facility_id AS "Order Ship Facility ID"
    , cust.prim_ship_facility_id AS "Customer Primary Ship Facility"
    
    , cust.addr_line_1 AS "Address Line 1"
    , cust.addr_line_2 AS "Address Line 2"
    , cust.addr_line_3 AS "Address Line 3"
    , cust.addr_line_4 AS "Address Line 4"
    , cust.postal_cd AS "Postal Code"
    , cust.district_name AS "District Name"
    , cust.terr_name AS "Territory Name"
    , cust.city_name AS "City Name"
    , cust.cntry_name_cd AS "Country Name Code"
    
    , cust.sales_org_cd || ' - ' || cust.sales_org_name AS "Sales Org"
    , cust.distr_chan_cd || ' - ' || cust.distr_chan_name AS "Distribution Channel"
    
    , cust.tire_cust_typ_cd AS "OE/Replacement"
    , odc.cust_grp2_cd AS "Order Customer Group 2 Code"
    , cust.cust_grp2_cd AS "Cust. Mstr. Customer Group 2 Code"

FROM na_bi_vws.open_order_schdln_curr ool
    
    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_fiscal_yr = ool.order_fiscal_yr
        AND odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'c'
        AND odc.po_type_id <> 'ro'
        AND odc.order_type_id <> 'zlz'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id
        
    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id

GROUP BY
    odc.ship_cond_id
    , cust.ship_cond_id
    , odc.ship_pt_id
    , SUBSTR(cust.postal_cd, 1, 3)
    , odc.route_id

    , CASE 
        WHEN odc.facility_id IN ('N5US', 'N5CA')
            THEN 'N5US/CA - Large Order'
        WHEN odc.facility_id = cust.prim_ship_facility_id 
            THEN 'Primary LC' 
        ELSE (CASE
            WHEN odc.facility_id LIKE 'N5%'
                THEN 'Out of Area - Direct from Plant'
            ELSE 'Out of Area'
        END)
    END
    
    , odc.order_fiscal_yr
    , odc.ship_to_cust_id
    , cust.cust_name
    , cust.own_cust_id
    , cust.own_cust_name
    , matl.pbu_nbr || ' - ' || matl.pbu_name 
    
    , odc.facility_id
    , cust.prim_ship_facility_id
  
    , cust.addr_line_1
    , cust.addr_line_2
    , cust.addr_line_3
    , cust.addr_line_4
    , cust.postal_cd
    , cust.district_name
    , cust.terr_name
    , cust.city_name
    , cust.cntry_name_cd
    
    , cust.sales_org_cd || ' - ' || cust.sales_org_name
    , cust.distr_chan_cd || ' - ' || cust.distr_chan_name
    
    , cust.tire_cust_typ_cd
    , odc.cust_grp2_cd
    , cust.cust_grp2_cd

ORDER BY
    odc.ship_cond_id
    , odc.ship_pt_id
    , cust.postal_cd
