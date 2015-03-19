﻿SELECT
    SA.BILL_DT AS BUS_DT
    , SA.LEGACY_SHIP_TO_CUST_NO
    , SA.MATL_NO AS MATL_ID
    , SA.SLS_UOM AS QTY_UOM
    , SUM(SA.SLS_QTY) AS BILL_QTY
    
FROM NA_VWS.SLS_AGG SA

WHERE
    SA.BILL_REF_MTH_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                    AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
                    
GROUP BY
    SA.BILL_DT
    , SA.LEGACY_SHIP_TO_CUST_NO
    , SA.MATL_NO
    , SA.SLS_UOM
