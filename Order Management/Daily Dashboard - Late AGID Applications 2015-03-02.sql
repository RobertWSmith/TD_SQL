﻿SELECT
    DDC.FISCAL_YR
    , DDC.DELIV_ID
    , DDC.DELIV_LINE_NBR

    , DDC.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , DDC.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME

    , DDC.DELIV_LINE_FACILITY_ID
    , F.FACILITY_NAME

    , DDC.ACTL_GOODS_ISS_DT
    , DDC.QTY_UNIT_MEAS_ID
    , DDC.DELIV_QTY

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = DDC.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN NA_VWS.DELIV_DTL DD
        ON DD.FISCAL_YR = DDC.FISCAL_YR
        AND DD.DELIV_ID = DDC.DELIV_ID
        AND DD.DELIV_LINE_NBR = DDC.DELIV_LINE_NBR
        AND DDC.ACTL_GOODS_ISS_DT BETWEEN DD.EFF_DT AND DD.EXP_DT

WHERE
    DDC.ACTL_GOODS_ISS_DT BETWEEN DATE '2015-02-01' AND DATE '2015-02-28'
    AND DDC.DELIV_QTY <> 0
    AND DD.ACTL_GOODS_ISS_DT IS NULL
    AND (
            C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
            OR (
                C.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                AND C.DISTR_CHAN_CD IN ('30', '31', '32')
                )
            )
        AND M.PBU_NBR = '01' -- IN ('01', '03')
        AND M.MKT_AREA_NBR <> '04'
        AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')