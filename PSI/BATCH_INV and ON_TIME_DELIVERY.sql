SELECT
    inv.bus_dt,
    inv.matl_id,
    inv.facility_id,
    inv.tot_qty,
    ZEROIFNULL( otd.current_order_qty ) AS current_order_qty,
	ZEROIFNULL( otd.frdd_no_stock_hit_qty ) AS frdd_no_stock_hit_qty,
	SUM( ZEROIFNULL( otd.frdd_no_stock_hit_qty ) ) OVER ( PARTITION BY inv.matl_id, inv.facility_id ORDER BY inv.bus_dt ASC ROWS 7 PRECEDING ) AS frdd_07dy_no_stock_hit_qty,
	SUM( ZEROIFNULL( otd.frdd_no_stock_hit_qty ) ) OVER ( PARTITION BY inv.matl_id, inv.facility_id ORDER BY inv.bus_dt ASC ROWS 14 PRECEDING ) AS frdd_14dy_no_stock_hit_qty,
	SUM( ZEROIFNULL( otd.frdd_no_stock_hit_qty ) ) OVER ( PARTITION BY inv.matl_id, inv.facility_id ORDER BY inv.bus_dt ASC ROWS 21 PRECEDING ) AS frdd_21dy_no_stock_hit_qty,
	SUM( ZEROIFNULL( otd.frdd_no_stock_hit_qty ) ) OVER ( PARTITION BY inv.matl_id, inv.facility_id ORDER BY inv.bus_dt ASC ROWS 28 PRECEDING ) AS frdd_28dy_no_stock_hit_qty,
	SUM( ZEROIFNULL( otd.frdd_no_stock_hit_qty ) ) OVER ( PARTITION BY inv.matl_id, inv.facility_id ORDER BY inv.bus_dt ASC ROWS 35 PRECEDING ) AS frdd_35dy_no_stock_hit_qty,

    ZEROIFNULL( otd.frdd_ontime_qty ) AS frdd_ontime_qty,
    ZEROIFNULL( otd.frdd_late_qty ) AS frdd_late_qty
    
FROM (

        SELECT
            bi.facility_id,
            bi.matl_id,
            bi.day_dt AS bus_dt,
            SUM( bi.blocked_stk_qty ) AS blocked_stk_qty,
            SUM( bi.qual_insp_qty ) AS qual_insp_qty,
            SUM( bi.tot_qty ) AS tot_qty
        
        FROM gdyr_bi_vws.batch_inv bi
        
        WHERE
            bi.src_sys_id = 2
            AND bi.day_dt BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )  AND ( CURRENT_DATE - 1 )
            AND bi.matl_id LIKE '%00193043'
            AND bi.facility_id = 'N636'
            
        GROUP BY
            bi.facility_id,
            bi.matl_id,
            bi.day_dt

    ) inv
    
    LEFT OUTER JOIN ( 
            
            SELECT
                pol.matl_id,
                pol.ship_facility_id AS facility_id,
                -- pol.order_dt,
                pol.req_deliv_dt AS frdd,
                -- pol.cmpl_dt as frdd_cmpl_dt,
                
                SUM( ZEROIFNULL( pol.orig_ord_qty ) ) AS original_order_qty,
                SUM( ZEROIFNULL( pol.curr_ord_qty ) ) AS current_order_qty,
                SUM( ZEROIFNULL( pol.rel_late_qty ) ) AS frdd_release_late_qty,
                SUM( ZEROIFNULL( pol.rel_ontime_qty ) ) AS frdd_release_ontime_qty,
                SUM( ZEROIFNULL( pol.cancel_qty ) ) AS cancel_qty,
                SUM( ZEROIFNULL( pol.deliv_late_qty ) ) AS frdd_deliver_late_qty,
                SUM( ZEROIFNULL( pol.deliv_ontime_qty ) ) AS frdd_deliver_ontime_qty,
            	
            	SUM( ZEROIFNULL( pol.ne_hit_rt_qty ) ) AS frdd_return_hit_qty,
            	SUM( ZEROIFNULL( pol.ne_hit_cl_qty ) ) AS frdd_claim_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_fp_qty ) ) AS frdd_freight_plcy_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_carr_pickup_qty ) ) + SUM( ZEROIFNULL( pol.ot_hit_wi_qty ) ) AS frdd_phys_log_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_mb_qty ) ) AS frdd_man_blk_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_ch_qty ) ) AS frdd_credit_hit_qty,
            	SUM( ZEROIFNULL( pol.if_hit_ns_qty ) ) AS frdd_no_stock_hit_qty,
            	SUM( ZEROIFNULL( pol.if_hit_co_qty ) ) AS frdd_cancel_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_cg_qty ) ) AS frdd_cust_gen_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_cg_99_qty ) ) AS frdd_man_rel_cust_gen_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_99_qty ) ) AS frdd_man_rel_hit_qty,
            	SUM( ZEROIFNULL( pol.ot_hit_lo_qty ) ) AS frdd_other_hit_qty,
            
                SUM( ZEROIFNULL( pol.curr_ord_qty ) ) - SUM( ZEROIFNULL( pol.prfct_ord_hit_qty ) ) AS frdd_ontime_qty,
                SUM( ZEROIFNULL( pol.prfct_ord_hit_qty ) ) AS frdd_late_qty
                
            FROM na_bi_vws.prfct_ord_line pol
            
            WHERE
                pol.cmpl_ind = 1
                AND pol.cmpl_dt BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )  AND ( CURRENT_DATE - 1 )
                AND pol.req_deliv_dt < CURRENT_DATE
                AND pol.prfct_ord_hit_desc <> 'FRDD Hit - Error'
                AND pol.ship_facility_id = 'N636'
                AND pol.matl_id LIKE '%00193043'
            
            GROUP BY
                pol.matl_id,
                pol.ship_facility_id,
                -- pol.order_dt,
                -- pol.cmpl_dt,
                pol.req_deliv_dt

            ) otd
        ON otd.facility_id = inv.facility_id
        AND otd.matl_id = inv.matl_id
        AND otd.frdd = inv.bus_dt
            
ORDER BY
    inv.bus_dt,
    inv.facility_id,
    inv.matl_id