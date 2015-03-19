SELECT
    CAST('On Time' AS VARCHAR(25)) AS "Delivery Type",
    CAST('On Time' AS VARCHAR(255)) AS "Time Desc.",
	CASE
		WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322')
			OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
			THEN 'OE'
		ELSE 'Repl'
	END AS "OE/Replacement",
    SUM(ZEROIFNULL(pol.deliv_ontime_qty)) AS "Delivery Qty"

FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr = '01'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_Descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id
        AND cust.cust_grp_id <> '3R'

WHERE
    pol.po_type_id <> 'RO'
    AND pol.cmpl_ind = 1
    AND pol.cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
    AND pol.actl_deliv_dt IS NOT NULL
    AND "OE/Replacement" = 'Repl'

GROUP BY
    "Delivery Type",
    "Time Desc.",
    "OE/Replacement"

UNION ALL

SELECT
    CAST('Late' AS VARCHAR(25)) AS "Delivery Type",
	CASE 
	    WHEN CAST((pol.actl_deliv_dt - pol.req_deliv_dt) / 7 AS INTEGER) <= 0
	        THEN '1 Week Late'
        WHEN CAST((pol.actl_deliv_dt - pol.req_deliv_dt) / 7 AS INTEGER) BETWEEN 1 AND 5
            THEN TRIM(1 + CAST((pol.actl_deliv_dt - pol.req_deliv_dt) / 7 AS INTEGER) || ' Weeks Late')
        WHEN CAST((pol.actl_deliv_dt - pol.req_deliv_dt) / 7 AS INTEGER) > 5
            THEN '6+ Weeks Late'
	END AS "Time Desc.",
	CASE
		WHEN cust.sales_org_cd IN ('N302', 'N312', 'N322')
			OR (cust.sales_org_cd IN ('N303', 'N313', 'N323') AND cust.distr_chan_cd = '32')
			THEN 'OE'
		ELSE 'Repl'
	END AS "OE/Replacement",
	SUM(ZEROIFNULL(pol.deliv_late_qty)) AS "Delivery Qty"
	
FROM na_bi_vws.prfct_ord_line pol

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = pol.matl_id
        AND matl.pbu_nbr = '01'

    INNER JOIN gdyr_bi_vws.nat_cust_hier_Descr_en_curr cust
        ON cust.ship_to_cust_id = pol.ship_to_cust_id
        AND cust.cust_grp_id <> '3R'

WHERE
    pol.po_type_id <> 'RO'
    AND pol.cmpl_ind = 1
    AND pol.cmpl_dt BETWEEN DATE '2014-01-01' AND (CURRENT_DATE-1)
    AND pol.actl_deliv_dt IS NOT NULL
    AND "OE/Replacement" = 'Repl'

GROUP BY
    "Delivery Type",
    "Time Desc.",
    "OE/Replacement"