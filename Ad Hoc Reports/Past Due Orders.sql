SELECT
    ool.order_id,
    ool.order_line_nbr,
    ool.sched_line_nbr,
    
    odc.ship_to_cust_id,
    cust.cust_name AS ship_to_cust_name,
    cust.own_cust_id,
    cust.own_cust_name,
    cust.cust_grp_id,
    cust.cust_grp_name,
    cust.sales_org_cd,
    cust.sales_org_name,
    cust.distr_chan_cd,
    cust.distr_chan_name,
    
    odc.facility_id,
    fac.fac_name,
    src.source_facility_id,
    src.source_facility_name,
    
    odc.matl_id,
    matl.matl_no_8 || ' - ' || matl.descr AS matl_descr,
    matl.tic_cd,
    matl.pbu_nbr,
    matl.pbu_name,
    matl.ext_matl_grp_id,
    matl.matl_prty,
    
    matl.mkt_ctgy_mkt_area_nbr,
    matl.mkt_ctgy_mkt_area_name,
    matl.mkt_area_nbr,
    matl.mkt_area_name,
    
    ool.credit_hold_flg,
    
    odc.route_id,
    odc.spcl_proc_id,
    
    odc.order_dt,
    odc.cust_rdd AS ordd,
    odc.frst_matl_avl_dt AS frdd_fmad,
    odc.frst_pln_goods_iss_dt AS frdd_fpgi,
    odc.frst_rdd AS frdd,
    COALESCE(odc.fc_matl_avl_dt, fcdd - (frdd - frdd_fmad)) AS fcdd_fmad,
    COALESCE(odc.fc_pln_goods_iss_dt, fcdd - (frdd - frdd_fpgi)) AS fcdd_fpgi,
    odc.frst_prom_deliv_dt AS fcdd,
    CASE
        WHEN past_due_qty > 0
            THEN odc.pln_transp_pln_dt
    END AS plan_transp_pln_dt,
    CASE
        WHEN past_due_qty > 0
            THEN odc.pln_matl_avl_dt
    END AS plan_matl_avl_dt,
    CASE
        WHEN past_due_qty > 0
            THEN odc.pln_load_dt
    END AS plan_load_dt,
    CASE
        WHEN past_due_qty > 0
            THEN odc.pln_goods_iss_dt
    END AS plan_goods_iss_dt,
    CASE
        WHEN past_due_qty > 0
            THEN odc.pln_deliv_dt
    END AS plan_deliv_dt,
    
    CAST(frdd - odc.order_dt AS INTEGER) AS order_dt_to_frdd_days,
    
    CAST(CURRENT_DATE - frdd_fmad AS INTEGER) AS frdd_fmad_to_today,
    CAST(CURRENT_DATE - frdd AS INTEGER) AS frdd_to_today,
    
    CAST(CURRENT_DATE - plan_matl_avl_dt AS INTEGER) AS days_to_pln_mad,
    CAST(CURRENT_DATE - plan_deliv_dt AS INTEGER) AS days_to_pdd,
    
    ZEROIFNULL(ool.open_cnfrm_qty) AS past_due_qty
    --ZEROIFNULL(ool.uncnfrm_qty) + ZEROIFNULL(ool.back_order_qty) AS back_ordered_qty,
    --ZEROIFNULL(ool.in_proc_qty) + ZEROIFNULL(ool.defer_qty) + ZEROIFNULL(ool.wait_list_qty) AS other_open_qty,
    --open_confirmed_qty + back_ordered_qty + other_open_qty AS total_open_qty

FROM na_bi_vws.open_order_schdln_curr ool
    
    INNER JOIN na_bi_vws.order_detail_curr odc
        ON odc.order_id = ool.order_id
        AND odc.order_line_nbr = ool.order_line_nbr
        AND odc.sched_line_nbr = ool.sched_line_nbr
        AND odc.order_cat_id = 'C'
        AND odc.order_type_id NOT IN ('ZLS', 'ZLZ')
        AND odc.po_type_id <> 'RO'
        AND odc.frst_rdd < CURRENT_DATE
    
    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = odc.matl_id
        AND matl.pbu_nbr IN ('01', '03')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN gdyr_bi_vws.nat_cust_hier_descr_en_curr cust
        ON cust.ship_to_cust_id = odc.ship_to_cust_id

    INNER JOIN gdyr_bi_vws.nat_facility_hier_en_curr fac
        ON fac.facility_id = odc.facility_id

    LEFT OUTER JOIN (
                SELECT
                    fm.facility_id AS ship_facility_id,
                    f.name AS ship_facility_name,
                    fm.matl_id,
                    m.pbu_nbr,
                    m.matl_grp_cd,
                    m.matl_sta_id,
                    m.matl_type_id,
                    m.ext_matl_grp_id,
                    m.stk_class_id,
                    CAST( CASE COALESCE(fm.spcl_prcu_typ_cd, fmo.spcl_prcu_typ_cd)
                        WHEN 'AA' THEN 'N501'
                        WHEN 'AB' THEN 'N502'
                        WHEN 'AC' THEN 'N503'
                        WHEN 'AD' THEN 'N504'
                        WHEN 'AE' THEN 'N505'
                        WHEN 'AH' THEN 'N508'
                        WHEN 'AI' THEN 'N509'
                        WHEN 'AJ' THEN 'N510'
                        WHEN 'AM' THEN 'N513'
                        WHEN 'S1' THEN 'N6BD'
                        WHEN 'S2' THEN 'N6BE'
                        WHEN 'S4' THEN 'N6BS'
                        WHEN 'S6' THEN 'N6J2'
                        WHEN 'S7' THEN 'N6J3'
                        WHEN 'S8' THEN 'N6J4'
                        WHEN 'S9' THEN 'N6J7'
                        WHEN 'SA' THEN 'N526'
                        WHEN 'SC' THEN 'N6A1'
                        WHEN 'SD' THEN 'N6A2'
                        WHEN 'SE' THEN 'N6A3'
                        WHEN 'SF' THEN 'N6A4'
                        WHEN 'SG' THEN 'N6A6'
                        WHEN 'SH' THEN 'N6A8'
                        WHEN 'SI' THEN 'N6A9'
                        WHEN 'SJ' THEN 'N6AA'
                        WHEN 'SL' THEN 'N6AC'
                        WHEN 'SM' THEN 'N6AE'
                        WHEN 'SN' THEN 'N6AG'
                        WHEN 'SO' THEN 'N6AH'
                        WHEN 'SQ' THEN 'N6AK'
                        WHEN 'SR' THEN 'N6AL'
                        WHEN 'SS' THEN 'N6J8'
                        WHEN 'ST' THEN 'N6AO'
                        WHEN 'SU' THEN 'N6AQ'
                        WHEN 'SV' THEN 'N6AR'
                        WHEN 'SW' THEN 'N6AS'
                        WHEN 'SX' THEN 'N6AT'
                        WHEN 'SY' THEN 'N6AX'
                        WHEN 'SZ' THEN 'N6BB'
                        WHEN 'WA' THEN 'N637'
                        WHEN 'WB' THEN 'N636'
                        WHEN 'WF' THEN 'N623'
                        WHEN 'WG' THEN 'N639'
                        WHEN 'WH' THEN 'N699'
                        WHEN 'WK' THEN 'N602'
                        ELSE fmx.facility_id
                    END AS CHAR(4) ) AS source_facility_id,
                    src.fac_name AS source_facility_name
                
                FROM gdyr_vws.facility_matl fm
                
                    INNER JOIN gdyr_vws.matl m
                        ON m.matl_id = fm.matl_id
                        AND m.exp_dt = DATE '5555-12-31'
                        AND m.orig_sys_id = fm.orig_sys_id
                        AND m.sbu_id = fm.sbu_id
                        AND m.src_sys_id = fm.src_sys_id
                        AND m.matl_type_id IN ('PCTL','FWHM','ACCT','ICTL','NVAL')
                        AND m.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                
                    INNER JOIN gdyr_vws.facility f
                        ON f.facility_id = fm.facility_id
                        AND f.exp_dt = DATE '5555-12-31'
                        AND f.lang_id = 'EN'
                        AND f.sbu_id = fm.sbu_id
                        AND f.orig_sys_id = fm.orig_sys_id
                        AND f.src_sys_id = fm.src_sys_id
                        AND f.facility_activ_ind = 'Y'
                        AND f.sales_org_cd NOT IN ('N340') -- no COWD facilities
                        AND f.distr_chan_cd = '81' -- only internal, also to help exclude COWD
                        AND f.facility_type_id NOT IN ('', 'N') -- exclude missing types and non-stocking facilities
                
                    LEFT OUTER JOIN gdyr_vws.facility_matl fmo
                        ON fmo.exp_dt = DATE '5555-12-31'
                        AND fmo.matl_id = fm.matl_id
                        AND fmo.facility_id = fm.facility_id
                        AND fmo.sbu_id = fm.sbu_id
                        AND fmo.orig_sys_id = fm.orig_sys_id
                        AND fmo.src_sys_id = fm.src_sys_id
                        AND fmo.mrp_type_id = 'X1'
                
                    LEFT OUTER JOIN gdyr_vws.facility_matl fmx
                        ON fmx.exp_dt = DATE '5555-12-31'
                        AND fmx.matl_id = fm.matl_id
                        AND fmx.sbu_id = fm.sbu_id 
                        AND fmx.orig_sys_id = fm.orig_sys_id
                        AND fmx.src_sys_id = fm.src_sys_id
                        AND fmx.mrp_type_id = 'X0'
                
                    LEFT OUTER JOIN gdyr_bi_vws.nat_facility_hier_en_curr src
                        ON src.facility_id = source_facility_id
                
                WHERE
                    fm.sbu_id = 2 
                    AND fm.orig_sys_id = 2
                    AND fm.exp_dt = DATE '5555-12-31'
                    AND fm.mrp_type_id = 'XB'
                
                GROUP BY
                    fm.facility_id,
                    f.name,
                    fm.matl_id,
                    m.pbu_nbr,
                    m.matl_grp_cd,
                    m.matl_sta_id,
                    m.matl_type_id,
                    m.ext_matl_grp_id,
                    m.stk_class_id,
                    source_facility_id,
                    src.fac_name
            ) src
        ON src.ship_facility_id = odc.facility_id
        AND src.matl_id = odc.matl_id

WHERE
    past_due_qty > 0

ORDER BY
    ool.order_id,
    ool.order_line_nbr,
    ool.sched_line_nbr
