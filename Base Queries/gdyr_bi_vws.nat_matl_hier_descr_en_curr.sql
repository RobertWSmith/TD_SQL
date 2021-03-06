﻿SELECT
    MATL.MATL_ID
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR

    , MATL.GLOBAL_PART_NBR
    , GPC.GLOBAL_PROD_GRP_NBR
    , GPC.GLOBAL_CMNT_TXT

    , MATL.MATL_ID_TRIM
    , MATL.MATL_NO_8

    , MATL.TIC_CD
    , MATL.TIC_VERSION_CD

    , MATL.HVA_TXT
    , MATL.HMC_TXT
    , MATL.SAL_IND
    , PAL.PAL_IND

    , MATL.MATL_PRTY
    , MATL.EXT_MATL_GRP_ID
    , MATL.STK_CLASS_ID
    , MATL.STK_CLASS_DT
    , MATL.MATL_STA_ID
    , MATL.MATL_STA_DT
    , MATL.TIRE_SZ_TEXT

    , MATL.BRAND_ID
    , MATL.BRAND_ID || ' - ' || MATL.BRAND_NAME AS BRAND

    , MATL.ASSOC_BRAND_ID
    , MATL.ASSOC_BRAND_ID || ' - ' || MATL.ASSOC_BRAND_NAME AS ASSOC_BRAND

    , MATL.SUPER_BRAND_ID
    , MATL.SUPER_BRAND_ID || ' - ' || MATL.SUPER_BRAND_NAME AS SUPER_BRAND

    , MATL.PBU_NBR
    , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU

    , MATL.MKT_AREA_NBR
    , MATL.MKT_AREA_NBR || ' - ' || MATL.MKT_AREA_NAME AS MARKET_AREA

    , MATL.MKT_GRP_NBR
    , MATL.MKT_GRP_NBR || ' - ' || MATL.MKT_GRP_NAME AS MARKET_GROUP

    , MATL.PROD_GRP_NBR
    , MATL.PROD_GRP_NBR || ' - ' || MATL.PROD_GRP_NAME AS PROD_GROUP

    , MATL.PROD_LINE_NBR
    , MATL.PROD_LINE_NBR || ' - ' || MATL.PROD_LINE_NAME AS PROD_LINE

    , MATL.MKT_CTGY_MKT_AREA_NBR AS CATEGORY_CD
    , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS CATEGORY

    , MATL.MKT_CTGY_MKT_GRP_NBR AS SEGMENT_CD
    , MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS SEGMENT

    , MATL.MKT_CTGY_PROD_GRP_NBR AS SALES_PROD_GRP_CD
    , MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS SALES_PROD_GRP

    , MATL.MKT_CTGY_PROD_LINE_NBR AS SALES_PROD_LINE_CD
    , MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS SALES_PROD_LINE

    , MATL.VOL_MEAS_ID
    , MATL.UNIT_VOL

    , CAST(CASE MATL.PBU_NBR || MATL.MKT_AREA_NBR
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
        END AS DECIMAL(15, 3)) AS COMPRESSION_RATIO
    , MATL.UNIT_VOL * COMPRESSION_RATIO AS UNIT_COMPRESSED_VOL

    , MATL.WT_MEAS_ID
    , MATL.UNIT_WT

    , CASE
        WHEN MATL.PBU_NBR = '01'
            THEN MATL.MKT_CTGY_PROD_GRP_NAME
        ELSE MATL.TIERS
        END AS TIER

    , MATL.PRTY_SRC_FACL_ID
    , MATL.PRTY_SRC_FACL_ID || ' - ' || MATL.PRTY_SRC_FACL_NM AS PRTY_SRC_FACL


FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL

    LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_PAL_CURR PAL
        ON PAL.MATL_ID = MATL.MATL_ID

    LEFT JOIN GDYR_BI_VWS.GLOBAL_PART_CURR GPC
        ON GPC.GLOBAL_PART_NBR = MATL.GLOBAL_PART_NBR

WHERE
    MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
    AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
    AND MATL.MKT_AREA_NBR NOT IN ('  ', '10', '15', '17', '21', '13', '18', '19')
