﻿SELECT
    DIP.DELIV_FISCAL_YR
    , DIP.DELIV_ID

    , CASE
        WHEN DD.PLN_GOODS_MVT_DT > CURRENT_DATE+9
            THEN 'PGMV > ' CAST(CURRENT_DATE+9 AS FORMAT 'YYYY-MMM-DD')
        WHEN DD.DELIV_DT > CURRENT_DATE+9
            THEN 'SAP PDD > ' CAST(CURRENT_DATE+9 AS FORMAT 'YYYY-MMM-DD')
        WHEN DD.DELIV_NOTE_CREA_DT < CURRENT_DATE-9
            THEN 'DN Create Date < ' CAST(CURRENT_DATE-9 AS FORMAT 'YYYY-MMM-DD')
        END AS TEST_DATES
    , DD.DELIV_NOTE_CREA_DT
    , DD.PLN_GOODS_MVT_DT AS SAP_PLN_GOODS_MVT_DT
    , DD.DELIV_DT AS SAP_DELIV_DT

    , DD.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.DISTRICT_NAME
    , C.TERR_NAME
    , C.CNTRY_NAME_CD
    , C.POSTAL_CD
    , C.ADDR_LINE_1

    , REGEXP_SUBSTR(C.CUST_NAME, '[0-9]+', 1, 1, 'I') AS CUST_LOC_NBR
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.PRIM_SHIP_FACILITY_ID
    , CASE
        WHEN C.PRIM_SHIP_FACILITY_ID = DD.DELIV_LINE_FACILITY_ID
            THEN 'Primary LC'
        WHEN DD.DELIV_LINE_FACILITY_ID LIKE 'N5%'
            THEN 'Out of Area - Factory Direct'
        ELSE 'Out of Area'
        END AS TEST_PRIM_SHIP_FACILITY

    , F.FACILITY_ID
    , F.FACILITY_NAME

    , DIP.RPT_QTY_UNIT_MEAS_ID AS QTY_UOM
    , SUM(DIP.RPT_QTY_TO_SHIP) AS IN_PROC_QTY
    , CAST(SUM(DIP.RPT_QTY_TO_SHIP * M.UNIT_WT) AS DECIMAL(15,3)) AS IN_PROC_GROSS_WT
    , CAST(SUM(DIP.RPT_QTY_TO_SHIP * M.UNIT_VOL) AS DECIMAL(15,3)) AS IN_PROC_VOL

FROM GDYR_VWS.DELIV_IN_PROC DIP

    INNER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DD
        ON DD.FISCAL_YR = DIP.DELIV_FISCAL_YR
        AND DD.DELIV_ID = DIP.DELIV_ID
        AND DIP.DELIV_LINE_NBR = DIP.DELIV_LINE_NBR

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = DD.SHIP_TO_CUST_ID
        AND C.OWN_CUST_ID = '00A0006582'

    INNER JOIN GDYR_BI_vWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DD.DELIV_LINE_FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = DD.MATL_ID

WHERE
    DIP.ORIG_SYS_ID = 2
    AND DIP.EXP_DT = CAST('5555-12-31' AS DATE)
    AND DIP.INTRA_CMPNY_FLG = 'N'
    AND DD.DELIV_NOTE_CREA_DT < CURRENT_DATE-10

GROUP BY
    DIP.DELIV_FISCAL_YR
    , DIP.DELIV_ID

    , TEST_DATES
    , DD.DELIV_NOTE_CREA_DT
    , DD.PLN_GOODS_MVT_DT
    , DD.DELIV_DT

    , DD.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.DISTRICT_NAME
    , C.TERR_NAME
    , C.CNTRY_NAME_CD
    , C.POSTAL_CD
    , C.ADDR_LINE_1

    , CUST_LOC_NBR
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.PRIM_SHIP_FACILITY_ID
    , TEST_PRIM_SHIP_FACILITY

    , F.FACILITY_ID
    , F.FACILITY_NAME

    , DIP.RPT_QTY_UNIT_MEAS_ID