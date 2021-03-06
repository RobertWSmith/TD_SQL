﻿SELECT
    CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , MATL.MATL_ID
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS CATEGORY
    
    , EXTRACT(YEAR FROM ODC.CANCEL_DT) AS CANCEL_YR
    , EXTRACT(MONTH FROM ODC.CANCEL_DT) AS CANCEL_MTH
    , ODC.REJ_REAS_ID 
    , ODC.REJ_REAS_DESC
    , COUNT(DISTINCT ODC.ORDER_FISCAL_YR || ODC.ORDER_ID || ODC.ORDER_LINE_NBR) AS ORDER_LINE_CNT

FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')

WHERE
    --ODC.REJ_REAS_ID <> ''
    ODC.REJ_REAS_ID = 'Z1'
    AND ODC.ORDER_FISCAL_YR >= '2013'
    AND ODC.ORDER_CAT_ID = 'C'

GROUP BY
    CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , MATL.MATL_ID
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME
    
    , EXTRACT(YEAR FROM ODC.CANCEL_DT)
    , EXTRACT(MONTH FROM ODC.CANCEL_DT)
    , ODC.REJ_REAS_ID 
    , ODC.REJ_REAS_DESC

ORDER BY
    CANCEL_YR
    , CANCEL_MTH
    , CUST.OWN_CUST_ID
    , ODC.REJ_REAS_ID
    , MATL.PBU_NBR
