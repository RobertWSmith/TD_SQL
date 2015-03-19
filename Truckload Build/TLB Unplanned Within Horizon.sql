﻿SELECT
    TLC.DELIV_DT
    , TLC.CUST_ID
    , CUST.CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , TLC.TL_SEQ_ID
    , TLC.DELIV_GRP_CD
    , TLC.TRLR_TYP_ID
    , TLM.TRLR_TYP_DESC
    , TLC.MIN_WT_QTY
    , TLM.MAX_WT_QTY
    , TLM.VOL_QTY AS MAX_VOL_QTY
    , TLC.TL_PLN_CD

FROM NA_BI_VWS.TL_CAP_DELIV_SCHD_CURR TLC

    INNER JOIN NA_BI_VWS.TL_TRLR_MSTR_CURR TLM
        ON TLM.TRLR_TYP_ID = TLC.TRLR_TYP_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = TLC.CUST_ID

WHERE
    TLC.DELIV_DT BETWEEN CURRENT_DATE+1 AND CURRENT_DATE+14
    AND TLC.TL_PLN_CD IS NULL

ORDER BY
    TLC.DELIV_DT
    , TLC.CUST_ID
    , TLC.TL_SEQ_ID