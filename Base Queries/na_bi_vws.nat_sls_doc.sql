SELECT
    sd.fiscal_yr
    , sd.sls_doc_id
    , sd.eff_dt
    , sd.exp_dt

    , sd.src_crt_dt
    , sd.src_crt_tm
    , sd.src_crt_usr_id
    , sd.src_upd_dt

    , sd.doc_dt
    , sd.sd_doc_ctgy_cd -- order category
    , sd.trans_grp_cd
    , sd.sls_doc_typ_cd -- order type
    , sd.ord_reas_cd

    , sd.deliv_blk_cd
    , sd.bill_blk_cd

    , sd.doc_cond_id -- document condions? B = Delivery Order, E = Delivery Order Correction
    , sd.req_deliv_dt -- Requested Delivery Date (VBAK - VDATU)
    , sd.prop_dt_typ_cd
    , sd.compl_deliv_ind -- indicates complete if all items are complete
    , sd.sd_doc_icd
    , sd.prc_cond_typ_cd
    , sd.ship_cond_cd
    , sd.bill_typ_cd
    , sd.sls_prbl_pct

    , sd.cust_prch_ord_id
    , sd.cust_prch_ord_typ_cd -- po type id
    , sd.cust_prch_ord_dt

    , sd.ship_to_cust_id
    , sd.sales_org_cd
    , sd.distr_chan_cd
    , sd.div_cd

    , sd.cust_grp_id_1
    , sd.cust_grp_id_2
    , sd.cust_grp_id_3
    , sd.cust_grp_id_4
    , sd.cust_grp_id_5

    -- , sd.rebate_agrmnt_id

    , sd.nxt_pln_deliv_dt
    , sd.ref_doc_sls_doc_id
    , sd.co_cd
    , sd.ref_doc_id
    , sd.ord_id
    , sd.ntfctn_id

    , sd.pick_up_frm_ts
    , sd.pick_up_to_ts
    , sd.matl_avail_dt
    , sd.ship_req_arrv_ts

    , sd.intrntl_sls_doc_id
    , sd.tot_qty
    , sd.sap_trans_cd

    , sd.cust_cntry_cd
    , sd.free_chrg_intrco_cost_cntr_cd
    , sd.term_pay_id
    , sd.proj_id

FROM na_bi_vws.nat_sls_doc sd

WHERE
    sd.exp_dt = DATE '5555-12-31'
    -- C = Sales Order
    AND sd.sd_doc_ctgy_cd = 'C'
    -- ZLZ = Scheduling Agreement
    -- ZDB = Delivery on behalf of Goodyear
    -- ZKB = Consign Shipment
    -- ZKB = Consign Withdrawl
    AND sd.sls_doc_typ_cd NOT IN ('ZLZ', 'ZDB', 'ZKB', 'ZKE')
    AND sd.cust_prch_ord_typ_cd <> 'RO' -- Reserve Orders
    AND sd.fiscal_yr >= '2012'
    AND (sd.fiscal_yr, sd.sls_doc_id) NOT IN (
        SELECT
            order_fiscal_yr
            , order_id
        FROM na_bi_vws.order_detail_curr
        WHERE
            order_cat_id = 'C'
            AND order_type_id <> 'ZLZ'
            AND po_type_id <> 'RO'
            AND order_fiscal_yr >= '2012'
        GROUP BY
            order_fiscal_yr
            , order_id
    )

ORDER BY
    1,2,3,4
