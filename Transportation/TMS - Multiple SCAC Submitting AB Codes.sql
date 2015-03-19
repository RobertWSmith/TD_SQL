﻿SELECT
    BILL_LADING_ID
    , FRT_MVMNT_STOP_ID
    , COUNT(DISTINCT CARR_SCAC_ID) AS SCAC_CNT

FROM NA_BI_VWS.TM_SHIP_STA_CURR

WHERE
    SRC_CRT_TS BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01 00:00:00' AS TIMESTAMP(0)) AND CURRENT_TIMESTAMP
    AND SHIP_STA_CD = 'AB'

GROUP BY
    BILL_LADING_ID
    , FRT_MVMNT_STOP_ID

HAVING
    SCAC_CNT > 1

ORDER BY
    BILL_LADING_ID
    , FRT_MVMNT_STOP_ID
