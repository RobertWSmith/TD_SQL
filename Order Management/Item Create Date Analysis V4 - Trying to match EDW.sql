﻿SELECT
    O.ORDER_LN_CRT_DT
    --, O.MATL_ID
    --, O.MATL_DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    --, O.CATEGORY_CD
    --, O.CATEGORY_NM
    --, O.OWN_CUST_ID
    --, O.OWN_CUST_NAME
    --, O.OE_REPL_IND

    , O.QTY_UNIT_MEAS_ID
    , SUM(O.ORDER_QTY) AS ORDER_QTY

    , SUM(O.CANCEL_QTY) AS CANCELLED_QTY
    , SUM(O.WAIT_LISTED_QTY) AS WAIT_LIST_QTY
    , SUM(O.UNCONFIRMED_QTY) AS UNCONFIRMED_QTY
    , SUM(O.BACK_ORDERED_QTY) AS BACK_ORDERED_QTY

    , SUM(O.OPEN_CONFIRMED_QTY_CURR) AS OPEN_CONFIRMED_QTY_CURR
    , SUM(O.OPEN_CONFIRMED_QTY_FTR) AS OPEN_CONFIRMED_QTY_FTR

    , SUM(O.IN_PROCESS_QTY_CURR) AS IN_PROCESS_QTY_CURR
    , SUM(O.IN_PROCESS_QTY_FTR) AS IN_PROCESS_QTY_FTR

    , SUM(O.ACTL_GOODS_ISS_QTY) AS ACTL_GOODS_ISS_QTY

    , SUM(O.NET_IMBALANCE_QTY) AS NET_IMBALANCE_QTY

    , SUM(O.SL_OPEN_CNFMR_QTY) AS SL_OPEN_CNFMR_QTY
    , SUM(O.SL_UNCNFRM_QTY) AS SL_UNCNFRM_QTY
    , SUM(O.SL_BACK_ORDER_QTY) AS SL_BACK_ORDER_QTY
    , SUM(O.SL_DEFER_QTY) AS SL_DEFER_QTY
    , SUM(O.SL_WAIT_LIST_QTY) AS SL_WAIT_LIST_QTY
    , SUM(O.SL_OTHR_ORDER_QTY) AS SL_OTHR_ORDER_QTY
    , SUM(O.SL_IN_PROC_QTY) AS SL_IN_PROC_QTY

FROM (

SELECT
    ORD.ORDER_FISCAL_YR
    , ORD.ORDER_ID
    , ORD.ORDER_LINE_NBR

    , ORD.ORDER_DT
    , ORD.ORDER_LN_CRT_DT

    , ORD.REJ_REAS_ID

    , ORD.MATL_ID
    , ORD.MATL_DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.CATEGORY_CD
    , ORD.CATEGORY_NM

    , ORD.OWN_CUST_ID
    , ORD.OWN_CUST_NAME
    , ORD.OE_REPL_IND

    , ORD.QTY_UNIT_MEAS_ID
    , ORD.ORD_QTY
    , CASE
        WHEN TOT_DN_QTY > ORD.ORD_QTY
            THEN TOT_DN_QTY
        ELSE ORD.ORD_QTY
        END AS ORDER_QTY
    , ZEROIFNULL(OOL.WAIT_LIST_QTY) AS WAIT_LISTED_QTY
    , ZEROIFNULL(CASE
        WHEN ORD.REJ_REAS_ID <> ''
            THEN (CASE
                WHEN ORD.ORD_QTY - TOT_DN_QTY < 0
                    THEN 0
                ELSE ORD.ORD_QTY - TOT_DN_QTY
                END)
        ELSE 0
        END) AS CANCEL_QTY

    , ZEROIFNULL(OOL.UNCNFRM_QTY) AS UNCONFIRMED_QTY
    , ZEROIFNULL(OOL.BACK_ORDER_QTY) AS BACK_ORDERED_QTY

    , ZEROIFNULL(OOL.OPEN_CNFRM_QTY_CURR) AS OPEN_CONFIRMED_QTY_CURR
    , ZEROIFNULL(OOL.OPEN_CNFRM_QTY_FTR) AS OPEN_CONFIRMED_QTY_FTR

    , ZEROIFNULL(OOL.IN_PROC_QTY_CURR) AS IN_PROCESS_QTY_CURR
    , ZEROIFNULL(OOL.IN_PROC_QTY_FTR) AS IN_PROCESS_QTY_FTR
    , ZEROIFNULL(DLV.DELIV_QTY) AS ACTL_GOODS_ISS_QTY
    
    , ORDER_QTY - (CANCEL_QTY + WAIT_LISTED_QTY + UNCONFIRMED_QTY + BACK_ORDERED_QTY + OPEN_CONFIRMED_QTY_CURR + OPEN_CONFIRMED_QTY_FTR + IN_PROCESS_QTY_CURR + IN_PROCESS_QTY_FTR + ACTL_GOODS_ISS_QTY) AS NET_IMBALANCE_QTY

    , ZEROIFNULL(IN_PROCESS_QTY_CURR + IN_PROCESS_QTY_FTR + ACTL_GOODS_ISS_QTY) AS TOT_DN_QTY

    , ZEROIFNULL(OOL.OPEN_CNFMR_QTY) AS SL_OPEN_CNFMR_QTY
    , ZEROIFNULL(OOL.UNCNFRM_QTY) AS SL_UNCNFRM_QTY
    , ZEROIFNULL(OOL.BACK_ORDER_QTY) AS SL_BACK_ORDER_QTY
    , ZEROIFNULL(OOL.DEFER_QTY) AS SL_DEFER_QTY
    , ZEROIFNULL(OOL.WAIT_LIST_QTY) AS SL_WAIT_LIST_QTY
    , ZEROIFNULL(OOL.OTHR_ORDER_QTY) AS SL_OTHR_ORDER_QTY
    , ZEROIFNULL(OOL.IN_PROC_QTY) AS SL_IN_PROC_QTY

FROM (

    SELECT
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_DT
        , OD.ORDER_LN_CRT_DT

        , OD.REJ_REAS_ID

        , OD.MATL_ID
        , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MKT_CTGY_MKT_AREA_NBR AS CATEGORY_CD
        , M.MKT_CTGY_MKT_AREA_NAME AS CATEGORY_NM

        , C.OWN_CUST_ID
        , C.OWN_CUST_NAME
        , CASE
            WHEN C.SALES_ORG_GRP_DESC IN ('', 'NA') OR C.SALES_ORG_GRP_DESC IS NULL
                THEN 'REPL'
            ELSE C.SALES_ORG_GRP_DESC
            END AS OE_REPL_IND

        , OD.QTY_UNIT_MEAS_ID
        , MAX(OD.ORDER_QTY) AS ORD_QTY

    FROM GDYR_BI_VWS.GDYR_CAL ITM_CAL

        INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
            ON OD.ORDER_LN_CRT_DT = ITM_CAL.DAY_DATE
            AND OD.ORDER_LN_CRT_DT BETWEEN OD.EFF_DT AND OD.EXP_DT
            --AND OD.ORDER_CAT_ID = 'C'
            AND OD.PO_TYPE_ID <> 'RO'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL PGI_CAL
            ON PGI_CAL.DAY_DATE = OD.PLN_GOODS_ISS_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON M.MATL_ID = OD.MATL_ID
            --AND M.EXT_MATL_GRP_ID = 'TIRE'
            AND M.PBU_NBR = '01' -- IN ('01', '03')
            AND M.MKT_AREA_NBR <> '04'
            AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
            AND (
                C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
                OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD IN ('30', '31', '32'))
                )

    WHERE
        ITM_CAL.DAY_DATE BETWEEN CAST('2015-02-01' AS DATE) AND CURRENT_DATE-1

        -- AND OD.ORDER_FISCAL_YR = '2015'
        -- AND OD.ORDER_ID = '0088563150'
        -- AND OD.ORDER_LINE_NBR = 210

    GROUP BY
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_DT
        , OD.ORDER_LN_CRT_DT

        , OD.REJ_REAS_ID

        , OD.MATL_ID
        , MATL_DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME

        , C.OWN_CUST_ID
        , C.OWN_CUST_NAME
        , OE_REPL_IND

        , OD.QTY_UNIT_MEAS_ID

    ) ORD

        LEFT OUTER JOIN (
            SELECT
                DDI.SLS_DOC_FISCAL_YR AS ORDER_FISCAL_YR
                , DDI.SLS_DOC_ID AS ORDER_ID
                , DDI.SLS_DOC_ITM_ID AS ORDER_LINE_NBR
                , DD.ORIG_DOC_DT AS DELIV_NOTE_CREA_DT

                , DDI.BASE_UOM_CD AS QTY_UNIT_MEAS_ID
                , SUM(DDI.ACTL_DELIV_QTY) AS DELIV_QTY

            FROM GDYR_VWS.DELIV_DOC DD

                INNER JOIN GDYR_BI_VWS.GDYR_CAL DN_CAL
                    ON DN_CAL.DAY_DATE = DD.ORIG_DOC_DT

                INNER JOIN GDYR_BI_VWS.GDYR_CAL PGMV_CAL
                    ON PGMV_CAL.DAY_DATE = DD.PLN_GOODS_MVT_DT

                INNER JOIN GDYR_VWS.DELIV_DOC_ITM DDI
                    ON DDI.FISCAL_YR = DD.FISCAL_YR
                    AND DDI.DELIV_DOC_ID = DD.DELIV_DOC_ID
                    AND DD.ORIG_DOC_DT BETWEEN DDI.EFF_DT AND DDI.EXP_DT
                    AND DDI.SD_DOC_CTGY_CD = 'C'

            WHERE
                DD.ORIG_SYS_ID = 2
                AND DD.ORIG_DOC_DT BETWEEN DD.EFF_DT AND DD.EXP_DT
                AND DD.SD_DOC_CTGY_CD = 'J'
                AND DD.ORIG_DOC_DT BETWEEN DATE '2015-02-01' AND CURRENT_DATE-1
                AND DD.ACTL_GOODS_MVT_DT = DD.ORIG_DOC_DT

            GROUP BY
                DDI.SLS_DOC_FISCAL_YR 
                , DDI.SLS_DOC_ID
                , DDI.SLS_DOC_ITM_ID
                , DD.ORIG_DOC_DT

                , DDI.BASE_UOM_CD 
                ) DLV
            ON DLV.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
            AND DLV.ORDER_ID = ORD.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
            AND DLV.DELIV_NOTE_CREA_DT = ORD.ORDER_LN_CRT_DT

        LEFT OUTER JOIN (
            SELECT
                CAL.DAY_DATE
                , O.ORDER_FISCAL_YR
                , O.ORDER_ID
                , O.ORDER_LINE_NBR
                , SUM(O.OPEN_CNFRM_QTY) AS OPEN_CNFMR_QTY
                , SUM(CASE
                    WHEN CAL.MONTH_DT = PGI_CAL.MONTH_DT
                        THEN O.OPEN_CNFRM_QTY
                    ELSE 0
                    END) AS OPEN_CNFRM_QTY_CURR
                , SUM(CASE
                    WHEN CAL.MONTH_DT < PGI_CAL.MONTH_DT
                        THEN O.OPEN_CNFRM_QTY
                    ELSE 0
                    END) AS OPEN_CNFRM_QTY_FTR
                , SUM(O.UNCNFRM_QTY) AS UNCNFRM_QTY
                , SUM(O.BACK_ORDER_QTY) AS BACK_ORDER_QTY
                , SUM(O.DEFER_QTY) AS DEFER_QTY
                , SUM(O.WAIT_LIST_QTY) AS WAIT_LIST_QTY
                , SUM(O.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY
                , SUM(O.IN_PROC_QTY) AS IN_PROC_QTY
                , SUM(CASE
                    WHEN CAL.MONTH_DT = PGI_CAL.MONTH_DT
                        THEN O.IN_PROC_QTY
                    ELSE 0
                    END) AS IN_PROC_QTY_CURR
                , SUM(CASE
                    WHEN CAL.MONTH_DT < PGI_CAL.MONTH_DT
                        THEN O.IN_PROC_QTY
                    ELSE 0
                    END) AS IN_PROC_QTY_FTR

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN NA_VWS.OPEN_ORDER_SCHDLN O
                    ON CAL.DAY_DATE BETWEEN O.EFF_DT AND O.EXP_DT

                INNER JOIN GDYR_BI_VWS.GDYR_CAL PGI_CAL
                    ON PGI_CAL.DAY_DATE = O.PLN_GOODS_ISS_DT

            WHERE
                CAL.DAY_DATE BETWEEN CAST('2015-02-01' AS DATE) AND CURRENT_DATE-1

            GROUP BY
                CAL.DAY_DATE
                , O.ORDER_FISCAL_YR
                , O.ORDER_ID
                , O.ORDER_LINE_NBR
                
                ) OOL
            ON OOL.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
            AND OOL.ORDER_ID = ORD.ORDER_ID
            AND OOL.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
            AND OOL.DAY_DATE = ORD.ORDER_LN_CRT_DT
--WHERE
    --NET_IMBALANCE_QTY <> 0

--ORDER BY
    --ABS(NET_IMBALANCE_QTY) DESC
    ) O

GROUP BY
    O.ORDER_LN_CRT_DT
    --, O.MATL_ID
    --, O.MATL_DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    --, O.CATEGORY_CD
    --, O.CATEGORY_NM
    --, O.OWN_CUST_ID
    --, O.OWN_CUST_NAME
    --, O.OE_REPL_IND

    , O.QTY_UNIT_MEAS_ID

ORDER BY
    O.ORDER_LN_CRT_DT
    , O.PBU_NBR
    --, O.CATEGORY_CD
    --, O.MATL_ID
    --, O.OE_REPL_IND
    --, O.OWN_CUST_ID
