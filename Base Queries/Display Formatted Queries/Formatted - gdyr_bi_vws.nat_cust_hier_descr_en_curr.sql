SELECT 
    CUST.SHIP_TO_CUST_ID AS "Ship To Customer ID"
	, CUST.SHIP_TO_CUST_NO AS "Ship To Customer Nbr"
	, CUST.CUST_NAME AS "Ship To Customer Name"
    
	, CUST.OWN_CUST_ID AS "Common Owner ID"
	, CUST.OWN_CUST_NAME AS "Common Owner Name"
    
    , CUST.SHIP_TO_CUST_ID || ' - ' || CUST.CUST_NAME AS "Ship To Customer"
	, CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS "Common Owner"
    
	, CUST.SALES_ORG_CD AS "Sales Org Code"
	, CUST.SALES_ORG_NAME AS "Sales Org Name"
    
	, CUST.DISTR_CHAN_CD AS "Distribution Channel Code"
	, CUST.DISTR_CHAN_NAME AS "Distribution Channel Name"
    
	, CUST.CUST_GRP_ID AS "Customer Group ID"
	, CUST.CUST_GRP_NAME AS "Customer Group Name"
    
    , CUST.SALES_ORG_CD || ' - ' || CUST.SALES_ORG_NAME AS "Sales Org"
	, CUST.DISTR_CHAN_CD || ' - ' || CUST.DISTR_CHAN_NAME AS "Distribution Channel"
	, CUST.CUST_GRP_ID || ' - ' || CUST.CUST_GRP_NAME AS "Customer Group"
    
	, CUST.DIV_CD AS "Division Code"
	, CUST.SALES_GRP_CD AS "Sales Group Code"
	, CUST.SALES_DISTR_CD AS "Sales Distribution Code"
	, CUST.ADDR_LINE_1 AS "Address Line 1"
	, CUST.ADDR_LINE_2 AS "Address Line 2"
	, CUST.ADDR_LINE_3 AS "Address Line 3"
	, CUST.ADDR_LINE_4 AS "Address Line 4"
	, CUST.POSTAL_CD AS "Postal Code"
	, CUST.DISTRICT_NAME AS "District Name"
	, CUST.TERR_NAME AS "Territory Name"
	, CUST.CITY_NAME AS "City Name"
	, CUST.CNTRY_NAME_CD AS "Country Name Code"
	, CUST.PRIM_SHIP_FACILITY_ID AS "Primary Shipping Facility ID"

	, CUST.DELIV_PRTY_CD AS "Delivery Priority Code"
	, CUST.SHIP_COND_ID AS "Shipping Condition ID"
	, CUST.DIST_CHAN_GRP_CD AS "Distribution Channel Group Code"
	, CUST.TIRE_CUST_TYP_CD AS "OE / Replacement Ind."
	, CUST.ACTIV_IND AS "Active Ind"
	, CUST.CUST_GRP1_CD AS "Customer Group 1 Code"
	, CUST.CUST_GRP2_CD AS "Customer Group 2 Code"

FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST

WHERE 
    CUST.SHIP_TO_CUST_ID IN (
		SELECT 
            SHIP_TO_CUST_ID
		FROM NA_BI_VWS.ORDER_DETAIL_CURR
		WHERE 
            ORDER_CAT_ID = 'C'
			AND ORDER_DT >= ADD_MONTHS((CURRENT_DATE-1), -84)
		GROUP BY 
            SHIP_TO_CUST_ID
		)

ORDER BY 
    CUST.OWN_CUST_ID
	, CUST.SHIP_TO_CUST_ID