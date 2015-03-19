SELECT 
    sl.fiscal_yr
    , sl.sls_doc_id
    , sl.sls_doc_itm_id
    , sl.schd_ln_id
    , sl.schd_ln_ctgy_cd
    , sl.itm_rlvnt_deliv_ind
    , sl.prch_ord_typ_cd
    , sl.prch_doc_ctgy_cd
    , sl.mvt_typ_cd
    , sl.schd_ln_typ_cd
    , sdi.sls_doc_itm_ctgy_cd
    , sdi.itm_typ_cd
    , sdi.itm_rlvnt_deliv_ind
    , sd.sd_doc_ctgy_cd
    , sd.sls_doc_typ_cd
    , sdi.matl_id
    , matl.descr
    , matl.pbu_nbr
    , matl.pbu_name
    , matl.mkt_area_nbr
    , matl.mkt_area_name
    , ool.*

FROM na_bi_vws.nat_sls_doc_schd_ln sl

    INNER JOIN na_bi_vws.nat_sls_doc_itm sdi
        ON sdi.exp_dt = DATE '5555-12-31'
        AND sdi.fiscal_yr = sl.fiscal_yr
        AND sdi.sls_doc_id = sl.sls_doc_id
        AND sdi.sls_doc_itm_id = sl.sls_doc_itm_id
        AND sdi.fiscal_yr >= '2014'

    INNER JOIN gdyr_bi_vws.nat_matl_hier_descr_en_curr matl
        ON matl.matl_id = sdi.matl_id
        AND matl.pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
        AND matl.super_brand_id IN ('01', '02', '03', '05')

    INNER JOIN na_bi_vws.nat_sls_doc sd
        ON sd.exp_dt = DATE '5555-12-31'
        AND sd.fiscal_yr = sl.fiscal_yr
        AND sd.sls_doc_id = sl.sls_doc_id
        AND sd.sd_doc_ctgy_cd = 'C' 
        -- ZLZ = Scheduling Agreement
        -- ZDB = Delivery on behalf of Goodyear
        -- ZKB = Consign Shipment
        -- ZKB = Consign Withdrawl
        AND sd.sls_doc_typ_cd NOT IN ('ZLZ', 'ZDB', 'ZKB', 'ZKE') 
        AND sd.cust_prch_ord_typ_cd <> 'RO' -- Reserve Orders
        AND sd.fiscal_yr >= '2014'

WHERE
    sl.exp_dt = DATE '5555-12-31'
    AND sl.fiscal_yr >= '2014'
    AND (sl.fiscal_yr, sl.sls_doc_id, sl.sls_doc_itm_id, sl.schd_ln_id) NOT IN(
        SELECT
            order_fiscal_yr
            , order_id
            , order_line_nbr
            , sched_line_nbr
        FROM na_bi_vws.order_detail_curr
        WHERE
            order_cat_id = 'C'
            AND order_type_id <> 'ZLZ'
            AND po_type_id <> 'RO'
            AND order_fiscal_yr >= '2014'
            AND matl_id IN (
                SELECT
                    matl_id
                FROM gdyr_bi_vws.nat_matl_hier_descr_en_curr
                WHERE
                    pbu_nbr IN ('01', '03', '04', '05', '07', '08', '09')
                    AND super_brand_id IN ('01', '02', '03', '05')
                )
        )
