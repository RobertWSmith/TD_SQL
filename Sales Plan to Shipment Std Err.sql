﻿SELECT
    Q.MATL_ID
    , Q.DESCR
    , Q.PBU_NBR
    , Q.PBU_NAME
    , Q.MKT_AREA_NBR
    , Q.MKT_AREA_NAME
    , Q.MKT_CTGY_MKT_AREA_NBR
    , Q.MKT_CTGY_MKT_AREA_NAME
    , Q.MKT_GRP_NBR
    , Q.MKT_GRP_NAME
    , Q.PROD_LINE_NBR
    , Q.PROD_LINE_NAME
    , Q.MKT_CTGY_PROD_LINE_NBR
    , Q.MKT_CTGY_PROD_LINE_NAME

    , Q.QTY_UNIT_MEAS_ID
    , SUM(Q.DELIV_QTY) AS DELIV_QTY
    , SUM(Q.SOP_SLS_PLN_LAG0) AS SOP_SLS_PLN_LAG0
    , SUM(Q.SOP_SLS_PLN_LAG2) AS SOP_SLS_PLN_LAG2
    , SUM(Q.SOP_SLS_PLN_LAG0_ERR) AS SOP_SLS_PLN_LAG0_ERR
    , SUM(Q.SOP_SLS_PLN_LAG2_ERR) AS SOP_SLS_PLN_LAG2_ERR
    , SUM(Q.SOP_SLS_PLN_LAG0_ERR_SQ) AS SOP_SLS_PLN_LAG0_ERR_SQ
    , SUM(Q.SOP_SLS_PLN_LAG2_ERR_SQ) AS SOP_SLS_PLN_LAG2_ERR_SQ
    , CAST(SQRT(SUM(Q.SOP_SLS_PLN_LAG0_ERR_SQ)) AS DECIMAL(15,3)) AS SOP_SLS_PLN_LAG0_STD_ERR
    , CAST(SQRT(SUM(Q.SOP_SLS_PLN_LAG2_ERR_SQ)) AS DECIMAL(15,3)) AS SOP_SLS_PLN_LAG2_STD_ERR

FROM (

SELECT
    DD.MONTH_DT
    , DD.MATL_ID
    , DD.DESCR
    , DD.PBU_NBR
    , DD.PBU_NAME
    , DD.MKT_AREA_NBR
    , DD.MKT_AREA_NAME
    , DD.MKT_CTGY_MKT_AREA_NBR
    , DD.MKT_CTGY_MKT_AREA_NAME
    , DD.MKT_GRP_NBR
    , DD.MKT_GRP_NAME
    , DD.PROD_LINE_NBR
    , DD.PROD_LINE_NAME
    , DD.MKT_CTGY_PROD_LINE_NBR
    , DD.MKT_CTGY_PROD_LINE_NAME

    , DD.SALES_ORG_CD
    , DD.SALES_ORG_NAME

    , DD.DISTR_CHAN_CD
    , DD.DISTR_CHAN_NAME

    , DD.CUST_GRP_ID
    , DD.CUST_GRP_NAME

    , DD.DP_CUST_GRP_ID
    , DD.DP_CUST_GRP_NM

    , DD.QTY_UNIT_MEAS_ID
    , DD.DELIV_QTY
    , SUM(CASE WHEN SP.LAG_DESC = '0' THEN ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) ELSE 0 END) AS SOP_SLS_PLN_LAG0
    , SUM(CASE WHEN SP.LAG_DESC = '2' THEN ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) ELSE 0 END) AS SOP_SLS_PLN_LAG2
    , DD.DELIV_QTY - SOP_SLS_PLN_LAG0 AS SOP_SLS_PLN_LAG0_ERR
    , DD.DELIV_QTY - SOP_SLS_PLN_LAG2 AS SOP_SLS_PLN_LAG2_ERR
    , SOP_SLS_PLN_LAG0_ERR ** 2 AS SOP_SLS_PLN_LAG0_ERR_SQ
    , SOP_SLS_PLN_LAG2_ERR ** 2 AS SOP_SLS_PLN_LAG2_ERR_SQ

FROM (

SELECT
    CAL.MONTH_DT
    , D.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_aREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.MKT_GRP_NBR
    , M.MKT_GRP_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME
    , M.MKT_CTGY_PROD_LINE_NBR
    , M.MKT_CTGY_PROD_LINE_NAME

    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME

    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME

    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME

    , C.DP_CUST_GRP_ID
    , C.DP_CUST_GRP_NM

    , D.QTY_UNIT_MEAS_ID
    , SUM(D.DELIV_QTY) AS DELIV_QTY

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR D

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = D.ACTL_GOODS_ISS_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = D.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = D.SHIP_TO_CUST_ID
        AND C.SALES_ORG_CD = D.SALES_ORG_CD
        AND C.CO_CD IN ('N101', 'N102', 'N266')

WHERE
    D.DELIV_LINE_FACILITY_ID IN (
        SELECT
            FACILITY_ID
        FROM GDYR_BI_VWS.NAT_FACILITY_EN_CURR
        WHERE
            SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND DISTR_CHAN_CD = '81'
        )
    AND M.PBU_NBR IN ('01', '03')
    AND M.MKT_AREA_NBR <> '04'
    AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')
    AND D.ACTL_GOODS_ISS_DT IS NOT NULL
    AND D.ACTL_GOODS_ISS_DT BETWEEN ADD_MONTHS((CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1), -4) AND (CURRENT_DATE-1) - EXTRACT(DAY FROM CURRENT_DATE-1)

GROUP BY
    CAL.MONTH_DT
    , D.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_aREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.MKT_GRP_NBR
    , M.MKT_GRP_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME
    , M.MKT_CTGY_PROD_LINE_NBR
    , M.MKT_CTGY_PROD_LINE_NAME

    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME

    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME

    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME

    , C.DP_CUST_GRP_ID
    , C.DP_CUST_GRP_NM

    , D.QTY_UNIT_MEAS_ID

    ) DD
    
    LEFT OUTER JOIN NA_BI_VWS.CUST_SLS_PLN_SNAP SP
        ON SP.PERD_BEGIN_MTH_DT = DD.MONTH_DT
        AND SP.MATL_ID = DD.MATL_ID
        AND SP.SALES_ORG_CD = DD.SALES_ORG_CD
        AND SP.DISTR_CHAN_CD = DD.DISTR_CHAN_CD
        AND SP.CUST_GRP_ID = DD.CUST_GRP_ID
        AND SP.DP_CUST_GRP_ID = DD.DP_CUST_GRP_ID
        AND SP.LAG_DESC IN ('0', '2')

GROUP BY
    DD.MONTH_DT
    , DD.MATL_ID
    , DD.DESCR
    , DD.PBU_NBR
    , DD.PBU_NAME
    , DD.MKT_aREA_NBR
    , DD.MKT_AREA_NAME
    , DD.MKT_CTGY_MKT_AREA_NBR
    , DD.MKT_CTGY_MKT_AREA_NAME
    , DD.MKT_GRP_NBR
    , DD.MKT_GRP_NAME
    , DD.PROD_LINE_NBR
    , DD.PROD_LINE_NAME
    , DD.MKT_CTGY_PROD_LINE_NBR
    , DD.MKT_CTGY_PROD_LINE_NAME

    , DD.SALES_ORG_CD
    , DD.SALES_ORG_NAME

    , DD.DISTR_CHAN_CD
    , DD.DISTR_CHAN_NAME

    , DD.CUST_GRP_ID
    , DD.CUST_GRP_NAME

    , DD.DP_CUST_GRP_ID
    , DD.DP_CUST_GRP_NM

    , DD.QTY_UNIT_MEAS_ID
    , DD.DELIV_QTY

    ) Q

GROUP BY
    Q.MATL_ID
    , Q.DESCR
    , Q.PBU_NBR
    , Q.PBU_NAME
    , Q.MKT_AREA_NBR
    , Q.MKT_AREA_NAME
    , Q.MKT_CTGY_MKT_AREA_NBR
    , Q.MKT_CTGY_MKT_AREA_NAME
    , Q.MKT_GRP_NBR
    , Q.MKT_GRP_NAME
    , Q.PROD_LINE_NBR
    , Q.PROD_LINE_NAME
    , Q.MKT_CTGY_PROD_LINE_NBR
    , Q.MKT_CTGY_PROD_LINE_NAME

    , Q.QTY_UNIT_MEAS_ID

ORDER BY 
    Q.MATL_ID
