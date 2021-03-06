﻿SELECT
    DDC.FISCAL_YR
    , DDC.DELIV_ID
    , DDC.DELIV_LINE_NBR
    , DDC.DELIV_CAT_ID
    , DDC.BILL_LADING_ID

    , DDC.ORDER_FISCAL_YR
    , DDC.ORDER_ID
    , DDC.ORDER_LINE_NBR
    , DDC.SD_DOC_CTGY_CD
    , CASE
        WHEN ODS.ORIG_ORDER_LINE_NBR = 0 OR ODS.ORIG_ORDER_LINE_NBR = ODS.ORDER_LINE_NBR
            THEN 'Original Order Line'
        ELSE 'Split Line'
        END AS SPLIT_LINE_IND

    , DDC.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.SHIP_TO_CUST_ID || ' - ' || C.CUST_NAME AS SHIP_TO_CUST
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.CITY_NAME
    , C.TERR_NAME
    , C.DISTRICT_NAME

    , DDC.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.MKT_CTGY_PROD_LINE_NBR
    , M.MKT_CTGY_PROD_LINE_NAME

    , DDC.DELIV_LINE_FACILITY_ID
    , F.FACILITY_ID || ' - ' || F.FACILITY_NAME AS FACILITY

    , ODS.ORDER_DT
    , ODS.ORDER_LN_CRT_DT

    , DDC.SRC_CRT_USR_ID
    , DDC.DELIV_NOTE_CREA_DT
    , DDC.PLN_GOODS_MVT_DT
    , DDC.ACTL_GOODS_ISS_DT
    , DDC.DELIV_DT
    , CASE
        WHEN CAST(DDC.ACTL_GOODS_ISS_DT - DDC.DELIV_NOTE_CREA_DT AS INTEGER) < 0
            THEN 0
        ELSE CAST(DDC.ACTL_GOODS_ISS_DT - DDC.DELIV_NOTE_CREA_DT AS INTEGER)
        END AS DN_CREATE_TO_AGID_DAYS
    , DDC.DELIV_QTY * DN_CREATE_TO_AGID_DAYS AS WTD_AVG_PRECURSOR

    , DDC.QTY_UNIT_MEAS_ID
    , DDC.DELIV_QTY

    , DDC.TERMS_ID
    , DDC.UNLD_PT_CD
    , DDC.CUST_GRP2_CD
    , DDC.GOODS_ISS_IND
    , ODS.DELIV_GRP_CD
    , CASE
        WHEN ODS.DELIV_GRP_CD > '000'
            THEN 'TLB Managed'
        ELSE 'Non-TLB'
        END AS TLB_IND

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M    
        ON M.MATL_ID = DDC.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID

    INNER JOIN (
            SELECT
                OD.ORDER_FISCAL_YR
                , OD.ORDER_ID
                , OD.ORDER_LINE_NBR
                , OD.ORIG_ORDER_LINE_NBR

                , OD.DELIV_GRP_CD
                , OD.ORDER_CAT_ID
                , OD.RO_PO_TYPE_IND

                , OD.ORDER_DT
                , OD.ORDER_LN_CRT_DT
            FROM NA_BI_VWS.ORDER_DETAIL OD
            WHERE
                OD.EXP_DT = CAST('5555-12-31' AS DATE)
                AND OD.SCHED_LINE_NBR = 1
        ) ODS
        ON ODS.ORDER_FISCAL_YR = DDC.ORDER_FISCAL_YR
        AND ODS.ORDER_ID = DDC.ORDER_ID
        AND ODS.ORDER_LINE_NBR = DDC.ORDER_LINE_NBR
        AND ODS.ORDER_CAT_ID = 'C'
        AND ODS.RO_PO_TYPE_IND = 'N'

WHERE
    DDC.DELIV_NOTE_CREA_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
    AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
    AND DDC.DELIV_QTY > 0
    
    AND C.OWN_CUST_ID = '00A0006582'

ORDER BY
    1,2,3
