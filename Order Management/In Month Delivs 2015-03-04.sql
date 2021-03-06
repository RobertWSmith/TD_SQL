﻿SELECT
    ORD.ORDER_MONTH_DT
    , ORD.FRDD_FPGI_MONTH_DT
    , ORD.FRDD_FPGI_TYP_CD
    , ORD.FCDD_FPGI_MONTH_DT
    , ORD.FCDD_FPGI_TYP_CD

    --, ORD.OWN_CUST_ID
    --, ORD.OWN_CUST_NAME
    --, ORD.SHIP_TO_CUST_ID
    --, ORD.CUST_NAME
    , ORD.OE_REPL_IND

    , ORD.MATL_ID
    , ORD.DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.MKT_AREA_NBR
    , ORD.MKT_AREA_NAME
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NAME
    , ORD.PROD_LINE_NBR
    , ORD.PROD_LINE_NAME
    
    , ORD.FACILITY_ID
    , ORD.FACILITY_NAME

    , ORD.PROD_ALLCT_DETERM_PROC_ID

    , ORD.QTY_UNIT_MEAS_ID
    , SUM(ORD.NET_ORDER_QTY) AS NET_ORDER_QTY
    , SUM(ORD.CANCEL_QTY) AS NET_CANCEL_QTY
    , SUM(ORD.OPEN_QTY) AS NET_OPEN_QTY
    , SUM(ORD.TOT_DELIV_QTY) AS NET_AGID_QTY
    , SUM(ORD.IN_PROC_QTY) AS NET_IN_PROC_QTY

    , SUM(ORD.ORDER_QTY) AS RAW_ORDER_QTY
    , SUM(ORD.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , SUM(ORD.NET_CNFRM_QTY) AS NET_CNFRM_QTY
    , SUM(ORD.CNFRM_QTY) AS RAW_CNFRM_QTY
    , SUM(ORD.UNCNFRM_QTY) AS RAW_UNCNFRM_QTY

    , SUM(ORD.AGID_IN_RDD_PGI_MTH_QTY) AS "AGID in FRDD FPGI Month Qty"
    , SUM(ORD.AGID_AFTER_RDD_PGI_MTH_QTY) AS "AGID after FRDD FPGI Month Qty"
    , SUM(ORD.AGID_IN_CDD_PGI_MTH_QTY) AS "AGID in FCDD FPGI Month Qty"
    , SUM(ORD.AGID_AFTER_CDD_PGI_MTH_QTY) AS "AGID after FCDD FPGI Month Qty"

    , SUM(ORD.PGMV_IN_RDD_PGI_MTH_QTY) AS "PGMV in FRDD FPGI Month Qty"
    , SUM(ORD.PGMV_AFTER_RDD_PGI_MTH_QTY) AS "PGMV after FRDD FPGI Month Qty"
    , SUM(ORD.PGMV_IN_CDD_PGI_MTH_QTY) AS "PGMV in FCDD FPGI Month Qty"
    , SUM(ORD.PGMV_AFTER_CDD_PGI_MTH_QTY) AS "PGMV after FCDD FPGI Month Qty"

FROM (

SELECT
    O.ORDER_FISCAL_YR
    , O.ORDER_ID
    , O.ORDER_LINE_NBR

    , O.ORDER_CAT_ID
    , O.ORDER_TYPE_ID
    , O.PO_TYPE_ID

    , O.ORDER_DT
    , O.ORDER_MONTH_DT
    , O.ORDER_LN_CRT_DT
    , O.FRST_MATL_AVL_DT
    , O.FRST_PLN_GOODS_ISS_DT
    , O.FRST_RDD
    , O.FRDD_FPGI_MONTH_DT

    , O.FRDD_FPGI_TYP_CD

    , O.FC_MATL_AVL_DT
    , O.FC_PLN_GOODS_ISS_DT
    , O.FRST_PROM_DELIV_DT
    , O.FCDD_FPGI_MONTH_DT

    , O.FCDD_FPGI_TYP_CD

    , O.SOLD_TO_CUST_ID
    , O.SHIP_TO_CUST_ID
    , O.CUST_NAME
    , O.OWN_CUST_ID
    , O.OWN_CUST_NAME
    , O.SALES_ORG_CD
    , O.SALES_ORG_NAME
    , O.DISTR_CHAN_CD
    , O.DISTR_CHAN_NAME
    , O.OE_REPL_IND

    , O.MATL_ID
    , O.DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    , O.MKT_AREA_NBR
    , O.MKT_AREA_NAME
    , O.MKT_CTGY_MKT_AREA_NBR
    , O.MKT_CTGY_MKT_AREA_NAME
    , O.PROD_LINE_NBR
    , O.PROD_LINE_NAME

    , O.FACILITY_ID
    , O.FACILITY_NAME

    , O.PROD_ALLCT_DETERM_PROC_ID
    , O.ORDER_DELIV_BLK_CD
    , O.DELIV_BLK_CD
    , O.CUST_GRP2_CD
    , O.AVAIL_CHK_GRP_CD
    , O.DELIV_PRTY_ID
    , O.WAIT_LIST_CD
    , O.REJ_REAS_ID
    , O.CANCEL_DT

    , O.QTY_UNIT_MEAS_ID
    , O.ORDER_QTY
    , O.CNFRM_QTY
    , CASE
        WHEN O.ORDER_QTY - ZEROIFNULL(DLV.TOT_DELIV_QTY) <= 0
            THEN 0
        WHEN O.CNFRM_QTY - ZEROIFNULL(DLV.TOT_DELIV_QTY) > 0
            THEN O.CNFRM_QTY - ZEROIFNULL(DLV.TOT_DELIV_QTY)
        ELSE O.CNFRM_QTY
        END AS NET_CNFRM_QTY

    , ZEROIFNULL(DLV.TOT_DELIV_QTY) AS TOT_DELIV_QTY
    , ZEROIFNULL(DLV.AGID_IN_RDD_PGI_MTH_QTY) AS AGID_IN_RDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.AGID_AFTER_RDD_PGI_MTH_QTY) AS AGID_AFTER_RDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.AGID_IN_CDD_PGI_MTH_QTY) AS AGID_IN_CDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.AGID_AFTER_CDD_PGI_MTH_QTY) AS AGID_AFTER_CDD_PGI_MTH_QTY

    , ZEROIFNULL(DLV.IN_PROC_QTY) AS IN_PROC_QTY
    , ZEROIFNULL(DLV.PGMV_IN_RDD_PGI_MTH_QTY) AS PGMV_IN_RDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.PGMV_AFTER_RDD_PGI_MTH_QTY) AS PGMV_AFTER_RDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.PGMV_IN_CDD_PGI_MTH_QTY) AS PGMV_IN_CDD_PGI_MTH_QTY
    , ZEROIFNULL(DLV.PGMV_AFTER_CDD_PGI_MTH_QTY) AS PGMV_AFTER_CDD_PGI_MTH_QTY

    , CASE
        WHEN ZEROIFNULL(DLV.TOT_DELIV_QTY) > O.ORDER_QTY
            THEN ZEROIFNULL(DLV.TOT_DELIV_QTY)
        ELSE O.ORDER_QTY
        END AS NET_ORDER_QTY
    , CASE
        WHEN O.REJ_REAS_ID > '' AND O.ORDER_QTY - ZEROIFNULL(DLV.TOT_DELIV_QTY) > 0
            THEN O.ORDER_QTY - ZEROIFNULL(DLV.TOT_DELIV_QTY)
        ELSE 0
        END AS CANCEL_QTY
    , O.ORDER_QTY - O.CNFRM_QTY AS UNCNFRM_QTY
    , CASE
        WHEN O.WAIT_LIST_CD = 'Y'
            THEN O.ORDER_QTY
        ELSE 0
        END AS WAIT_LIST_QTY
    , NET_ORDER_QTY - (ZEROIFNULL(DLV.TOT_DELIV_QTY) + ZEROIFNULL(DLV.IN_PROC_QTY) + CANCEL_QTY) AS OPEN_QTY

FROM (

    SELECT
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_CAT_ID
        , OD.ORDER_TYPE_ID
        , OD.PO_TYPE_ID

        , OD.ORDER_DT
        , OD.ORDER_LN_CRT_DT
        
        , CASE
            WHEN OD.CUST_GRP2_CD = 'TLB'
                THEN ORD_CAL.MONTH_DT
            ELSE ITM_CAL.MONTH_DT
            END AS ORDER_MONTH_DT

        , OD.FRST_MATL_AVL_DT
        , OD.FRST_PLN_GOODS_ISS_DT
        , OD.FRST_RDD
        , MIN(CASE
            WHEN OD.CUST_GRP2_CD = 'TLB' AND OD.FRST_RDD = OD.FRST_PROM_DELIV_DT
                THEN OD.PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.PLN_GOODS_ISS_DT)-1)
            ELSE OD.FRST_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.FRST_PLN_GOODS_ISS_DT)-1)
            END) AS FRDD_FPGI_MONTH_DT

        , CASE
            WHEN FRDD_FPGI_MONTH_DT = ORDER_MONTH_DT
                THEN 'Requested to Goods Issue in Order Create Month'
            WHEN FRDD_FPGI_MONTH_DT > ORDER_MONTH_DT
                THEN 'Requested to Goods Issue in Future Month'
            ELSE 'Undefined'
            END AS FRDD_FPGI_TYP_CD

        , OD.FC_MATL_AVL_DT
        , OD.FC_PLN_GOODS_ISS_DT
        , OD.FRST_PROM_DELIV_DT
        , MIN(CASE
            WHEN OD.CUST_GRP2_CD = 'TLB' AND OD.FRST_RDD = OD.FRST_PROM_DELIV_DT
                THEN OD.PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.PLN_GOODS_ISS_DT)-1)
            ELSE OD.FC_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.FC_PLN_GOODS_ISS_DT)-1)
            END) AS FCDD_FPGI_MONTH_DT

        , CASE
            WHEN OD.FRST_PROM_DELIV_DT IS NULL
                THEN 'Unconfirmed'
            WHEN FCDD_FPGI_MONTH_DT = ORDER_MONTH_DT
                THEN 'Confirmed w/ PGI in Order Create Month'
            WHEN FCDD_FPGI_MONTH_DT > ORDER_MONTH_DT
                THEN 'Confirmed W/ PGI in Future Month'
            ELSE 'Undefined'
            END AS FCDD_FPGI_TYP_CD

        , OD.SOLD_TO_CUST_ID
        , OD.SHIP_TO_CUST_ID
        , C.CUST_NAME
        , C.OWN_CUST_ID
        , C.OWN_CUST_NAME
        , C.SALES_ORG_CD
        , C.SALES_ORG_NAME
        , C.DISTR_CHAN_CD
        , C.DISTR_CHAN_NAME
        , CASE 
            WHEN C.SALES_ORG_CD IN('N301', 'N311', 'N321', 'N307', 'N317', 'N336') OR (C.SALES_ORG_CD IN('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD IN('30', '31'))
                THEN 'REPL'
            ELSE 'OE'
            END AS OE_REPL_IND

        , OD.MATL_ID
        , M.DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MKT_AREA_NBR
        , M.MKT_AREA_NAME
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME
        , M.PROD_LINE_NBR
        , M.PROD_LINE_NAME

        , OD.FACILITY_ID
        , F.FACILITY_NAME

        , OD.PROD_ALLCT_DETERM_PROC_ID
        , OD.ORDER_DELIV_BLK_CD
        , OD.DELIV_BLK_CD
        , OD.CUST_GRP2_CD
        , OD.AVAIL_CHK_GRP_CD
        , OD.DELIV_PRTY_ID
        , OD.WAIT_LIST_CD
        , OD.REJ_REAS_ID
        , OD.CANCEL_DT

        , OD.QTY_UNIT_MEAS_ID
        , MAX(OD.ORDER_QTY) AS ORDER_QTY
        , SUM(OD.CNFRM_QTY) AS CNFRM_QTY

    FROM NA_BI_VWS.ORDER_DETAIL OD

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON M.MATL_ID = OD.MATL_ID

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
            ON F.FACILITY_ID = OD.FACILITY_ID
            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND F.DISTR_CHAN_CD = '81'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL ORD_CAL
            ON ORD_CAL.DAY_DATE = OD.ORDER_DT

        INNER JOIN GDYR_BI_VWS.GDYR_CAL ITM_CAL
            ON ITM_CAL.DAY_DATE = OD.ORDER_LN_CRT_DT

    WHERE
        OD.EXP_DT = DATE '5555-12-31'
        --OD.ORDER_DT BETWEEN OD.EFF_DT AND OD.EXP_DT
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.PO_TYPE_ID <> 'RO'

        AND M.PBU_NBR IN ('01')
        AND M.EXT_MATL_GRP_ID = 'TIRE'

        AND OD.ORDER_DT BETWEEN DATE '2015-01-01' AND CURRENT_DATE-1

    GROUP BY
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_CAT_ID
        , OD.ORDER_TYPE_ID
        , OD.PO_TYPE_ID

        , OD.ORDER_DT
        , ORDER_MONTH_DT
        , OD.ORDER_LN_CRT_DT
        , OD.FRST_MATL_AVL_DT
        , OD.FRST_PLN_GOODS_ISS_DT
        , OD.FRST_RDD

        , OD.FC_MATL_AVL_DT
        , OD.FC_PLN_GOODS_ISS_DT
        , OD.FRST_PROM_DELIV_DT

        , OD.SOLD_TO_CUST_ID
        , OD.SHIP_TO_CUST_ID
        , C.CUST_NAME
        , C.OWN_CUST_ID
        , C.OWN_CUST_NAME
        , C.SALES_ORG_CD
        , C.SALES_ORG_NAME
        , C.DISTR_CHAN_CD
        , C.DISTR_CHAN_NAME

        , OD.MATL_ID
        , M.DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MKT_AREA_NBR
        , M.MKT_AREA_NAME
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME
        , M.PROD_LINE_NBR
        , M.PROD_LINE_NAME

        , OD.FACILITY_ID
        , F.FACILITY_NAME

        , OD.PROD_ALLCT_DETERM_PROC_ID
        , OD.ORDER_DELIV_BLK_CD
        , OD.DELIV_BLK_CD
        , OD.CUST_GRP2_CD
        , OD.AVAIL_CHK_GRP_CD
        , OD.DELIV_PRTY_ID
        , OD.WAIT_LIST_CD
        , OD.REJ_REAS_ID
        , OD.CANCEL_DT

        , OD.QTY_UNIT_MEAS_ID

    ) O

    LEFT OUTER JOIN (
            SELECT
                DDC.ORDER_FISCAL_YR
                , DDC.ORDER_ID
                , DDC.ORDER_LINE_NBR

                , DDC.QTY_UNIT_MEAS_ID
                , SUM(CASE WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL THEN DDC.DELIV_QTY ELSE 0 END) AS TOT_DELIV_QTY
                , SUM(CASE
                    WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL AND AGID_CAL.MONTH_DT <= OD.FRDD_FPGI_MONTH_DT
                        THEN DDC.DELIV_QTY
                    ELSE 0
                    END) AS AGID_IN_RDD_PGI_MTH_QTY
                , TOT_DELIV_QTY - AGID_IN_RDD_PGI_MTH_QTY AS AGID_AFTER_RDD_PGI_MTH_QTY
                , SUM(CASE
                    WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL AND AGID_CAL.MONTH_DT <= OD.FCDD_FPGI_MONTH_DT
                        THEN DDC.DELIV_QTY
                    ELSE 0
                    END) AS AGID_IN_CDD_PGI_MTH_QTY
                , TOT_DELIV_QTY - AGID_IN_CDD_PGI_MTH_QTY AS AGID_AFTER_CDD_PGI_MTH_QTY

                , SUM(CASE WHEN DDC.ACTL_GOODS_ISS_DT IS NULL THEN DDC.DELIV_QTY ELSE 0 END) AS IN_PROC_QTY
                , SUM(CASE
                    WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND PGMV_CAL.MONTH_DT <= OD.FRDD_FPGI_MONTH_DT
                        THEN DDC.DELIV_QTY
                    ELSE 0
                    END) AS PGMV_IN_RDD_PGI_MTH_QTY
                , IN_PROC_QTY - PGMV_IN_RDD_PGI_MTH_QTY AS PGMV_AFTER_RDD_PGI_MTH_QTY
                , SUM(CASE
                    WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND PGMV_CAL.MONTH_DT <= OD.FCDD_FPGI_MONTH_DT
                        THEN DDC.DELIV_QTY
                    ELSE 0
                    END) AS PGMV_IN_CDD_PGI_MTH_QTY
                , IN_PROC_QTY - PGMV_IN_CDD_PGI_MTH_QTY AS PGMV_AFTER_CDD_PGI_MTH_QTY

            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

                LEFT OUTER JOIN GDYR_BI_VWS.GDYR_CAL AGID_CAL
                    ON AGID_CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT

                INNER JOIN GDYR_BI_VWS.GDYR_CAL PGMV_CAL
                    ON PGMV_CAL.DAY_DATE = DDC.PLN_GOODS_MVT_DT

                INNER JOIN (
                        SELECT
                            O.ORDER_FISCAL_YR
                            , O.ORDER_ID
                            , O.ORDER_LINE_NBR
                            , MIN(CASE
                                WHEN O.CUST_GRP2_CD = 'TLB' AND O.FRST_RDD = O.FRST_PROM_DELIV_DT
                                    THEN O.PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM O.PLN_GOODS_ISS_DT)-1)
                                ELSE O.FRST_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM O.FRST_PLN_GOODS_ISS_DT)-1)
                                END) AS FRDD_FPGI_MONTH_DT
                            , MIN(CASE
                                WHEN O.CUST_GRP2_CD = 'TLB' AND O.FRST_RDD = O.FRST_PROM_DELIV_DT
                                    THEN O.PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM O.PLN_GOODS_ISS_DT)-1)
                                ELSE O.FC_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM O.FC_PLN_GOODS_ISS_DT)-1)
                                END) AS FCDD_FPGI_MONTH_DT
                        FROM NA_BI_VWS.ORDER_DETAIL O
                        WHERE
                            O.EXP_DT = DATE '5555-12-31'
                            AND O.ORDER_CAT_ID = 'C'
                            AND O.PO_TYPE_ID <> 'RO'
                            AND O.ORDER_DT BETWEEN DATE '2015-01-01' AND CURRENT_DATE-1
                        GROUP BY
                            O.ORDER_FISCAL_YR
                            , O.ORDER_ID
                            , O.ORDER_LINE_NBR
                    ) OD
                    ON OD.ORDER_FISCAL_YR = DDC.ORDER_FISCAL_YR
                    AND OD.ORDER_ID = DDC.ORDER_ID
                    AND OD.ORDER_LINE_NBR = DDC.ORDER_LINE_NBR

            WHERE
                DDC.DELIV_CAT_ID = 'J'
                AND DDC.SD_DOC_CTGY_CD = 'C'
                AND DDC.DELIV_NOTE_CREA_DT BETWEEN DATE '2015-01-01' AND CURRENT_DATE-1

            GROUP BY
                DDC.ORDER_FISCAL_YR
                , DDC.ORDER_ID
                , DDC.ORDER_LINE_NBR
                , DDC.QTY_UNIT_MEAS_ID            
            ) DLV
        ON DLV.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND DLV.ORDER_ID = O.ORDER_ID
        AND DLV.ORDER_LINE_NBR = O.ORDER_LINE_NBR

    ) ORD

GROUP BY
    ORD.ORDER_MONTH_DT
    , ORD.FRDD_FPGI_MONTH_DT
    , ORD.FRDD_FPGI_TYP_CD
    , ORD.FCDD_FPGI_MONTH_DT
    , ORD.FCDD_FPGI_TYP_CD

    --, ORD.OWN_CUST_ID
    --, ORD.OWN_CUST_NAME
    --, ORD.SHIP_TO_CUST_ID
    --, ORD.CUST_NAME
    , ORD.OE_REPL_IND

    , ORD.MATL_ID
    , ORD.DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.MKT_AREA_NBR
    , ORD.MKT_AREA_NAME
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NAME
    , ORD.PROD_LINE_NBR
    , ORD.PROD_LINE_NAME
    
    , ORD.FACILITY_ID
    , ORD.FACILITY_NAME

    , ORD.PROD_ALLCT_DETERM_PROC_ID

    , ORD.QTY_UNIT_MEAS_ID

ORDER BY
    ORD.PBU_NBR
    , ORD.MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.PROD_LINE_NBR
    , ORD.MATL_ID
    , ORD.FACILITY_ID
    , ORD.OE_REPL_IND
    , ORD.PROD_ALLCT_DETERM_PROC_ID

    , ORD.ORDER_MONTH_DT
    , ORD.FRDD_FPGI_MONTH_DT
    , ORD.FCDD_FPGI_MONTH_DT
