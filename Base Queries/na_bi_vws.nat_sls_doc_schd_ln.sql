SELECT
    sdsl.orig_sys_id
    , sdsl.fiscal_yr
    , sdsl.sls_doc_id
    , sdsl.sls_doc_itm_id
    , sdsl.schd_ln_id
    , sdsl.eff_dt
    , sdsl.exp_dt
    , sdsl.src_sys_id
    , sdsl.edw_job_id
    , sdsl.sbu_id
    , sdsl.schd_ln_ctgy_cd
    , sdsl.itm_rlvnt_deliv_ind
    , sdsl.schd_ln_deliv_dt
    , sdsl.sls_unit_ord_qty
    , sdsl.sls_unit_cnfrm_qty
    , sdsl.sls_uom_cd
    , sdsl.base_unit_rqt_qty
    , sdsl.base_uom_cd
    , sdsl.rqt_typ_cd
    , sdsl.pln_typ_cd
    , sdsl.early_pssbl_rsrv_dt
    , sdsl.prch_req_id
    , sdsl.prch_ord_typ_cd
    , sdsl.prch_doc_ctgy_cd
    , sdsl.schd_ln_cnfrm_sta_cd
    , sdsl.transp_pln_dt
    , sdsl.matl_avail_dt
    , sdsl.ld_dt
    , sdsl.ld_tm
    , sdsl.goods_iss_dt
    , sdsl.goods_iss_tm
    , sdsl.sls_unit_rnd_qty
    , sdsl.schd_ln_deliv_blk_cd
    , sdsl.sku_numer_cnvrsn_fctr_qty
    , sdsl.sku_denom_cnvrsn_fctr_qty
    , sdsl.avail_cnfrm_auto_ind
    , sdsl.mvt_typ_cd
    , sdsl.prch_req_itm_id
    , sdsl.schd_ln_typ_cd
    , sdsl.cust_eng_chg_sta_id
    , sdsl.matl_stg_tm
    , sdsl.transp_pln_tm
    , sdsl.cust_deliv_dt
    , sdsl.cust_goods_iss_dt
    , sdsl.cust_deliv_req_dt
    , sdsl.gy_cnfrm_cust_deliv_dt_ind
    , sdsl.non_match_deliv_dt_icd
    , sdsl.orig_req_deliv_dt
    , sdsl.deliv_dt_cnfrm_ind

FROM na_bi_vws.nat_sls_doc_schd_ln sdsl

WHERE
    sdsl.exp_dt = DATE '5555-12-31'