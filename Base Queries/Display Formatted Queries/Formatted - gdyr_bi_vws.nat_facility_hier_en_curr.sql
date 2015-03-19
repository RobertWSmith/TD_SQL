SELECT 
    fac.facility_id AS "Facility ID"
	, fac.name AS "Facility Name"
	, fac.xtnd_name AS "Extended Name"
	, fac.val_area_id AS "Value Area ID"
	, fac.int_cust_id AS "Internal Customer ID"
	, fac.vendor_cust_id AS "Vendor Customer ID"
	, fac.purch_org_id AS "Purch Org"
	, fac.sales_org_cd AS "Sales Org"
	, so.name AS "Sales Org Name"
	, fac.activ_req_plan_ind AS "Active Req Plan Ind"
	, fac.cntry_id AS "Country"
	, fac.terr_id AS "Territory"
	, fac.district_id AS "District"
	, fac.city_id AS "City"
	, fac.distr_chan_cd AS "Distribution Channel Code"
	, dc.name AS "Distribution Channel Name"
	, fac.div_cd AS "Division"
	, fac.lang_id AS "Language ID"
	, fac.facility_type_id AS "Facility Type ID"
	, typ.facility_type_desc AS "Facility Type Description"
	, fac.facility_cat_id AS "Facility Category ID"
	, fac.facility_activ_ind AS "Facility Active Ind"
	, fac.splc_cd AS "Splc Code"
	, fac.src_loc_cd AS "Source Loc Code"
	, fac.mfg_facl_cd AS "Manufacturing Facility Code"
	, fac.prod_facility_id AS "Production Facility ID"
	, fac.addr_id AS "Address"
    
FROM gdyr_vws.facility fac

    LEFT JOIN gdyr_vws.facility_type typ 
        ON typ.facility_type_id = fac.facility_type_id

    LEFT JOIN gdyr_vws.sales_org so 
        ON so.sales_org_cd = fac.sales_org_cd
    	AND so.exp_dt = DATE '5555-12-31'
    	AND so.lang_id = 'e'
    	AND so.sbu_id = fac.sbu_id
    	AND so.orig_sys_id = fac.orig_sys_id
        
    LEFT JOIN gdyr_vws.distr_chan dc 
        ON dc.distr_chan_cd = fac.distr_chan_cd
    	AND dc.exp_dt = DATE '5555-12-31'
    	AND dc.sbu_id = fac.sbu_id
    	AND dc.orig_sys_id = fac.orig_sys_id
    
WHERE 
    fac.sbu_id = 2
	AND fac.orig_sys_id = 2
	AND fac.exp_dt = DATE '5555-12-31'
	AND fac.lang_id = 'EN'

ORDER BY
    fac.facility_id