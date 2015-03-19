﻿SELECT
    DDC.FISCAL_YR
    , DDC.DELIV_ID

    , DDC.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , DDC.DELIV_NOTE_CREA_DT
    , CASE
        WHEN CAL.DAY_OF_WEEK_NAME_ABBREV = 'FRI'
            THEN 3
        ELSE 1
        END AS AGID_LEAD_TIME
    , DDC.ACTL_GOODS_ISS_DT
    , CAST(DDC.ACTL_GOODS_ISS_DT - DDC.DELIV_NOTE_CREA_DT AS INTEGER) AS AGID_LEAD_DYS
    , CASE
        WHEN AGID_LEAD_DYS - AGID_LEAD_TIME < 0
            THEN 0
        ELSE AGID_LEAD_DYS - AGID_LEAD_TIME
        END AS ADJ_AGID_LEAD_DYS
    , DDC.DELIV_DT

    , M.PBU_NBR
    , M.PBU_NAME

    , DDC.QTY_UNIT_MEAS_ID
    , SUM(DDC.DELIV_QTY) AS DELIV_QTY
    , SUM(DDC.DELIV_QTY) * ADJ_AGID_LEAD_DYS AS ADJ_AGID_WTD_AVG_SUBTOT_COL

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DDC.DELIV_NOTE_CREA_DT

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID
        AND C.OWN_CUST_ID = '00A0006932'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = DDC.MATL_ID
        AND M.PBU_NBR = '01'

WHERE
    DDC.DELIV_NOTE_CREA_DT BETWEEN DATE '2014-01-01' AND CURRENT_DATE
    AND DDC.DELIV_CAT_ID = 'J'
    AND DDC.SD_DOC_CTGY_CD = 'C'
    AND DDC.GOODS_ISS_IND = 'Y'

GROUP BY
    DDC.FISCAL_YR
    , DDC.DELIV_ID

    , DDC.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , DDC.DELIV_NOTE_CREA_DT
    , AGID_LEAD_TIME
    , DDC.ACTL_GOODS_ISS_DT
    , DDC.DELIV_DT
    
    , M.PBU_NBR
    , M.PBU_NAME

    , DDC.QTY_UNIT_MEAS_ID

HAVING
    SUM(DDC.DELIV_QTY) <> 0

ORDER BY
    DDC.FISCAL_YR
    , DDC.DELIV_ID
