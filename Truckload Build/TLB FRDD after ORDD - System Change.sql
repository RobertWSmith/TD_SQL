SELECT
    ORD.ORDER_FISCAL_YR
    , ORD.ORDER_ID
    , ORD.ORDER_LINE_NBR

    , ORD.ORDER_CAT_ID
    , ORD.ORDER_TYPE_ID
    , ORD.PO_TYPE_ID
    , ORD.CUST_PO_NBR

    , ORD.DELIV_GRP_CD

    , ORD.SHIP_TO_CUST_ID
    , ORD.CUST_NAME
    , ORD.OWN_CUST_ID
    , ORD.OWN_CUST_NAME

    , ORD.MATL_ID
    , ORD.DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.MKT_AREA_NBR
    , ORD.MKT_AREA_NAME
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NAME

    , ORD.FACILITY_ID
    , ORD.FACILITY_NAME

    , ORD.ORDER_DT
    , ORD.ORDER_CRT_TM
    , ORD.ORDER_LN_CRT_DT
    , ORD.ORDER_LN_CRT_TM

    , ORD.CUST_RDD
    , ORD.FRST_RDD
    , ORD.FIRST_DATE

    , ORD.CAPACITY_SLOT_DT
    , ORD.FRDD_CAPACITY_SLOT_IND
    , ORD.FIRST_DATE_CAPACITY_SLOT_IND

    , CHG.CHG_DOC_ID
    , CHG.SRC_CRT_USR_ID
    , CHG.SRC_CRT_DT
    , CHG.SRC_CRT_TM
    , CHG.SRC_CRT_TS
    , CHG.SAP_TRANS_CD
    , CHG.TXT_CHG_IND
    , CHG.OLD_VAL_TXT
    , CHG.NEW_VAL_TXT

FROM (
    SELECT
        CDI.OBJ_CLS_CD
        , CDI.OBJ_VAL_ID
        , CDI.CHG_DOC_ID
        , CDI.SAP_TBL_NM
        , CDI.SAP_COL_NM
        , CDI.CHG_TBL_REC_ID
        , CDI.CHG_TYP_CD
        , CDI.DOC_ID
        , CDI.DOC_ITM_ID
        , CDI.TXT_CHG_IND
        , CDI.OLD_UNIT_QTY
        , CDI.NEW_UNIT_QTY
        , CDI.OLD_CRNCY_ID
        , CDI.NEW_CRNCY_ID
        , CDI.OLD_VAL_TXT
        , CDI.NEW_VAL_TXT

        --, CAST(CDI.OLD_VAL_TXT AS DATE FORMAT 'YYYYMMDD') AS OLD_ORDD_DT
        --, CAST(CDI.NEW_VAL_TXT AS DATE FORMAT 'YYYYMMDD') AS NEW_ORDD_DT

        , CDI.SRC_CRT_DT
        , CDI.SRC_CRT_TM
        , CDI.SRC_CRT_TS
        , CH.SRC_CRT_USR_ID
        , CH.SAP_TRANS_CD
        
        , CH.PLN_CHG_ID
        , CH.ACTL_CHG_DOC_ID
        , CH.PLN_CHG_IND
        , CH.LANG_ID
        , CH.VER_ID

    FROM GDYR_BI_vWS.CHG_DOC_ITM CDI

        INNER JOIN GDYR_BI_VWS.CHG_DOC CH
            ON CH.ORIG_SYS_ID = CDI.ORIG_SYS_ID
            AND CH.OBJ_CLS_CD = CDI.OBJ_CLS_CD
            AND CH.OBJ_VAL_ID = CDI.OBJ_VAL_ID
            AND CH.CHG_DOC_ID = CDI.CHG_DOC_ID
            AND CH.SRC_CRT_DT = CDI.SRC_CRT_DT

    WHERE
        CDI.ORIG_SYS_ID = 2
        AND CDI.OBJ_CLS_CD = 'VERKBELEG'

        AND CDI.SRC_CRT_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)

        AND CDI.SAP_TBL_NM = 'VBAP'
        AND CDI.SAP_COL_NM = 'YYORDD'

        AND CH.SRC_CRT_USR_ID LIKE 'L%'
        
        AND (CDI.DOC_ID, CDI.DOC_ITM_ID) IN (
            SELECT
                ORDER_ID
                , ORDER_LINE_NBR
            FROM NA_BI_VWS.ORDER_DETAIL
            WHERE
                EXP_DT = CAST('5555-12-31' AS DATE)
                AND ORDER_CAT_ID = 'C'
                AND CUST_GRP2_CD = 'TLB'
                AND FRST_RDD >= CAST('2015-01-01' AS DATE)
                AND CUST_RDD IS NOT NULL
                AND FRST_RDD > CUST_RDD
                AND DELIV_GRP_CD > '000'
            GROUP BY 1, 2
        )
    ) CHG

    INNER JOIN (
    SELECT
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_CAT_ID
        , OD.ORDER_TYPE_ID
        , OD.PO_TYPE_ID
        , OD.CUST_PO_NBR

        , OD.DELIV_GRP_CD

        , OD.SHIP_TO_CUST_ID
        , C.CUST_NAME
        , C.OWN_CUST_ID
        , C.OWN_CUST_NAME

        , OD.MATL_ID
        , M.DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MKT_AREA_NBR
        , M.MKT_AREA_NAME
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME

        , OD.FACILITY_ID
        , F.FACILITY_NAME

        , OD.ORDER_DT
        , OD.ORDER_CRT_TM
        , OD.ORDER_LN_CRT_DT
        , OD.ORDER_LN_CRT_TM

        , OD.CUST_RDD
        , OD.FRST_RDD
        , OD.PLN_DELIV_DT AS FIRST_DATE
        , SLOT.DELIV_DT AS CAPACITY_SLOT_DT
        , CASE
            WHEN FRDD_SLOT.DELIV_DT IS NULL
                THEN 'No FRDD Slot'
            ELSE 'FRDD Slot Exists'
            END AS FRDD_CAPACITY_SLOT_IND
        , CASE
            WHEN FD_SLOT.DELIV_DT IS NULL
                THEN 'No First Date Slot'
            ELSE 'First Date Slot Exists'
            END AS FIRST_DATE_CAPACITY_SLOT_IND

    FROM NA_BI_VWS.ORDER_DETAIL OD

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
            AND C.CUST_GRP2_CD = 'TLB'

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON M.MATL_ID = OD.MATL_ID

        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
            ON F.FACILITY_ID = OD.FACILITY_ID

        INNER JOIN (
            SELECT
                CUST_ID
                , DELIV_DT
            FROM NA_BI_VWS.TL_CAP_DELIV_SCHD
            WHERE
                EXP_DT >= CAST('2015-01-01' AS DATE)
            GROUP BY 1,2
            ) SLOT
            ON SLOT.CUST_ID = OD.SHIP_TO_CUST_ID
            AND SLOT.DELIV_DT = OD.CUST_RDD

        LEFT OUTER JOIN (
            SELECT
                CUST_ID
                , DELIV_DT
            FROM NA_BI_VWS.TL_CAP_DELIV_SCHD
            WHERE
                EXP_DT >= CAST('2015-01-01' AS DATE)
            GROUP BY 1,2
            ) FRDD_SLOT
            ON FRDD_SLOT.CUST_ID = OD.SHIP_TO_CUST_ID
            AND FRDD_SLOT.DELIV_DT = OD.FRST_RDD

        LEFT OUTER JOIN (
            SELECT
                CUST_ID
                , DELIV_DT
            FROM NA_BI_VWS.TL_CAP_DELIV_SCHD
            WHERE
                EXP_DT >= CAST('2015-01-01' AS DATE)
            GROUP BY 1,2
            ) FD_SLOT
            ON FD_SLOT.CUST_ID = OD.SHIP_TO_CUST_ID
            AND FD_SLOT.DELIV_DT = OD.PLN_DELIV_DT

    WHERE
        OD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND OD.SCHED_LINE_NBR = 1
        AND OD.FRST_RDD >= CAST('2015-01-01' AS DATE)
        AND OD.CUST_RDD IS NOT NULL
        AND OD.FRST_RDD > OD.CUST_RDD

        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.CUST_GRP2_CD = 'TLB'
        AND OD.DELIV_GRP_CD > '000'

    ) ORD
    ON ORD.ORDER_ID = CHG.DOC_ID
    AND ORD.ORDER_LINE_NBR = CHG.DOC_ITM_ID

ORDER BY
    ORD.SHIP_TO_CUST_ID
    , ORD.DELIV_GRP_CD
    , ORD.CAPACITY_SLOT_DT
    , CHG.SRC_CRT_TS
