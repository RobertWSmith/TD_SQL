﻿SELECT
    V.VEND_ID
    , V.VEND_NM

    , V.VENDOR_GRP_CD

    , V.CUST_ID

    , V.TRADE_PARTNER_ID
    , TP.TRADE_PARTNER_NM

    , COALESCE(TP.CNTRY_NAME_CD, V.CNTRY_NAME_CD) AS CNTRY_CD
    , CN.CNTRY_NAME
    , CN.GDYR_RGN_NM

FROM GDYR_BI_VWS.VENDOR_CURR V

    LEFT OUTER JOIN GDYR_BI_VWS.TRADE_PARTNER_CURR TP
        ON TP.TRADE_PARTNER_ID = V.TRADE_PARTNER_ID
        AND TP.ORIG_SYS_ID = 2

    INNER JOIN GDYR_VWS.CNTRY CN
        ON CN.CNTRY_NAME_CD = CNTRY_CD
        AND CN.ORIG_SYS_ID = 2
        AND CN.LANG_ID = 'E'
        AND CN.EXP_DT = DATE '5555-12-31'

WHERE
    V.ORIG_SYS_ID = 2
    AND V.LANG_ID = 'E'
