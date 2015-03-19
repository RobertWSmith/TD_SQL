SELECT
    orig_sys_id,
    co_cd,
    eff_dt,
    exp_dt,
    src_sys_id,
    edw_job_id,
    sbu_id,
    co_type_cd,
    lang_id,
    sales_co_clust_id,
    activ_ind,
    city_name,
    cntry_name_cd,
    district_name,
    jnt_venture_ind,
    name,
    postal_cd,
    po_box,
    splc_cd,
    terr_name,
    crncy_id,
    trade_partner_id,
    gl_acct_chart_id

FROM gdyr_vws.co

ORDER BY
    co_cd,
    exp_dt