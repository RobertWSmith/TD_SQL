SELECT
    matl.matl_id AS "Material ID",
    matl.matl_no_8 AS "Material ID (8)",
    matl.matl_id_trim AS "Material ID Trimmed",
    matl.global_part_nbr AS "Global Part Number",

    matl.matl_no_8 || ' - ' || matl.descr AS "Material Description",
    matl.tic_cd AS "TIC Code",

    matl.matl_prty AS "Material Priority",

    matl.ext_matl_grp_id AS "External Material Group ID",
    matl.stk_class_id AS "Stock of Class ID",
    matl.tire_sz_text AS "Tire Size Text",
    matl.matl_sta_id AS "Material Status ID",

    matl.pbu_nbr AS "PBU Number",
    matl.pbu_name AS "PBU Name",
    matl.pbu_nbr || ' - ' || matl.pbu_name AS PBU,

    matl.brand_id AS "Brand ID",
    matl.brand_name AS "Brand Name",
    matl.brand_id || ' - ' || matl.brand_name AS "Brand",
    matl.assoc_brand_id AS "Associate Brand ID",
    matl.assoc_brand_name AS "Associate Brand Name",
    matl.assoc_brand_id || ' - ' || matl.assoc_brand_name AS "Associate Brand",
    matl.super_brand_id AS "Super Brand ID",
    matl.super_brand_name AS "Super Brand Name",
    matl.super_brand_id || ' - ' || matl.super_brand_name AS "Super Brand",

    matl.mkt_area_nbr AS "Market Area Number",
    matl.mkt_area_name AS "Market Area Name",
    matl.mkt_area_nbr || ' - ' || matl.mkt_area_name AS "Market Area",
    matl.mkt_grp_nbr AS "Market Group Number",
    matl.mkt_grp_name AS "Market Group Name",
    matl.mkt_grp_nbr || ' - ' || matl.mkt_grp_name AS "Market Group",
    matl.prod_grp_nbr AS "Product Group Number",
    matl.prod_grp_name AS "Product Group Name",
    matl.prod_grp_nbr || ' - ' || matl.prod_grp_name AS "Product Group",
    matl.prod_line_nbr AS "Product Line Number",
    matl.prod_line_name AS "Product Line Name",
    matl.prod_line_nbr || ' - ' || matl.prod_line_name AS "Product Line",

    matl.mkt_ctgy_mkt_area_nbr AS "Category Code",
    matl.mkt_ctgy_mkt_area_name AS "Category Name",
    matl.mkt_ctgy_mkt_area_nbr || ' - ' || matl.mkt_ctgy_mkt_area_name AS "Category",
    matl.mkt_ctgy_mkt_grp_nbr AS "Segment Code",
    matl.mkt_ctgy_mkt_grp_name AS "Segment Name",
    matl.mkt_ctgy_mkt_grp_nbr || ' - ' || matl.mkt_ctgy_mkt_grp_name AS "Segment",
    matl.mkt_ctgy_prod_grp_nbr AS "Tier Code",
    matl.mkt_ctgy_prod_grp_name AS "Tier Name",
    matl.mkt_ctgy_prod_grp_nbr || ' - ' || matl.mkt_ctgy_prod_grp_name AS "Tier",
    matl.mkt_ctgy_prod_line_nbr AS "Sales Product Line Code",
    matl.mkt_ctgy_prod_line_name AS "Sales Product Line Name",
    matl.mkt_ctgy_prod_line_nbr || ' - ' || matl.mkt_ctgy_prod_line_name AS "Sales Product Line",

    matl.vol_meas_id AS "Volume Unit of Measure",
    matl.unit_vol AS "Unit Volume",
    CAST(CASE matl.pbu_nbr || matl.mkt_area_nbr
        WHEN '0101' THEN 0.75
        WHEN '0108' THEN 0.80
        WHEN '0305' THEN 1.20
        WHEN '0314' THEN 1.20
        WHEN '0406' THEN 1.20
        WHEN '0507' THEN 0.75
        WHEN '0711' THEN 0.75
        WHEN '0712' THEN 0.75
        WHEN '0803' THEN 1.20
        WHEN '0923' THEN 0.75
        ELSE 1
    END AS DECIMAL(15,3)) AS "Compression Factor",
    matl.unit_vol * "Compression Factor" AS "Unit Compressed Volume",
    matl.wt_meas_id AS "Weight Unit of Measure",
    matl.unit_wt AS "Unit Weight",
    matl.hva_txt AS "HVA Text",
    matl.hmc_txt AS "HMC Text",
    matl.sal_ind AS "SAL Indicator",
    COALESCE(pal.pal_ind, '') AS "PAL Indicator",

    matl.tire_typ_ind AS "Tire Type Indicator",
    matl.tire_family_nm AS "Tire Family Name",
    matl.sop_family_id AS "S&OP Family ID",
    matl.sop_family_nm AS "S&OP Family Name",
    matl.sop_family_id || ' - ' || matl.sop_family_nm AS "S&OP Family",
    matl.tiers AS "Tiers",
    matl.mud_snow_flg AS "Mud/Snow Flag",
    matl.run_flat_typ_cd AS "Run Flat Type Code",
    matl.season_typ_cd AS "Season Type Code",
    matl.tire_cust_typ_cd AS "Tire Customer Type Code",
    matl.rim_diam_inches AS "Rim Diameter (inches)",
    matl.rim_diam_group AS "Rim Diameter Group",
    matl.rim_diam_sub_group AS "Rim Diameter Sub-Group"

FROM gdyr_bi_vws.nat_matl_hier_descr_en_curr matl

    LEFT OUTER JOIN gdyr_bi_vws.nat_matl_pal_curr pal
        ON pal.matl_id = matl.matl_id

WHERE
    matl.pbu_nbr IN ( '01', '03', '04', '05', '07', '08', '09' )
    AND matl.super_brand_id IN ('01', '02', '03', '05')
    AND matl.matl_id IN (
            SELECT
                odc.matl_id
            FROM na_bi_vws.order_detail_curr odc
            WHERE
                odc.order_cat_id = 'C'
                AND odc.order_type_id <> 'ZLZ'
                AND odc.po_type_id <> 'RO'
                AND odc.order_dt >= ADD_MONTHS(CURRENT_DATE-1, -72)
            GROUP BY
                odc.matl_id
        )

ORDER BY
    matl.matl_id

/*

CREATE TABLE IF NOT EXISTS material(
    matl_id CHAR(18) NOT NULL,
    matl_no_8 VARCHAR(8) NOT NULL,
    matl_id_trim VARCHAR(18) NOT NULL,
    global_part_nbr CHAR(35),
    descr VARCHAR(40),
    tic_cd CHAR(10),
    tic_version_cd CHAR(20),
    matl_prty_ctgy VARCHAR(10),
    matl_prty CHAR(2),
    matl_prty_descr VARCHAR(23),
    ext_matl_grp_id CHAR(18) NOT NULL,
    stk_class_id CHAR(2),
    tire_sz_text VARCHAR(32),
    pbu_nbr VARCHAR(10) NOT NULL,
    pbu_name VARCHAR(50),
    brand_id CHAR(3),
    brand_name VARCHAR(20),
    mkt_area_nbr CHAR(2),
    mkt_area_name VARCHAR(20),
    mkt_grp_nbr CHAR(4),
    mkt_grp_name VARCHAR(20),
    prod_grp_nbr CHAR(4),
    prod_grp_name VARCHAR(20),
    prod_line_nbr CHAR(6),
    prod_line_name VARCHAR(20),
    mkt_ctgy_mkt_area_nbr VARCHAR(10),
    mkt_ctgy_mkt_area_name VARCHAR(50),
    mkt_ctgy_mkt_grp_nbr VARCHAR(10),
    mkt_ctgy_mkt_grp_name VARCHAR(50),
    mkt_ctgy_prod_grp_nbr VARCHAR(10),
    mkt_ctgy_prod_grp_name VARCHAR(50),
    mkt_ctgy_prod_line_nbr VARCHAR(10),
    mkt_ctgy_prod_line_name VARCHAR(50),
    vol_meas_id CHAR(3),
    unit_vol DECIMAL(15,3),
    wt_meas_id CHAR(3),
    unit_wt DECIMAL(15,3),
    hva_txt VARCHAR(3),
    hmc_txt VARCHAR(3),
    tire_typ_ind VARCHAR(5),
    tire_family_nm VARCHAR(20),
    sop_family_id INTEGER,
    sop_family_nm VARCHAR(50),
    tiers VARCHAR(7),
    mud_snow_flg VARCHAR(1),
    run_flat_typ_cd CHAR(5),
    season_typ_cd VARCHAR(5),
    tire_cust_typ_cd VARCHAR(5),
    rim_diam_inches DECIMAL(9,3),
    rim_diam_group VARCHAR(12),
    rim_diam_sub_group VARCHAR(12),
    mold_inv_qty INTEGER,
    ring_inv_qty INTEGER,
    prty_src_facl_id CHAR(4),
    prty_src_facl_nm VARCHAR(60),
    UNIQUE(matl_id) ON CONFLICT REPLACE
);

*/

;
