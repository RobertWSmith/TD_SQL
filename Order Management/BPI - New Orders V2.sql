
SELECT
    ORD.DAY_DATE
    , CUST.SALES_ORG_CD
    , CUST.DISTR_CHAN_CD
    , CUST.CUST_GRP_ID
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , MATL.MATL_NO_8 MATL_NO
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR MATERIAL
    , MATL.PBU_NBR
    , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME PBU
    , ORD.REJ_REAS_ID
    , CASE
        WHEN (
                CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336')
                OR (
                    CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                    AND CUST.DISTR_CHAN_CD IN ('30', '31')
                    )
                )
            THEN 'Replacement'
        ELSE 'OE'
        END REPL_OE
    , SUM(ORD.RPT_ORDER_QTY) ORD_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'N'
                THEN ORD.RPT_ORDER_QTY
            ELSE 0
            END) FUT_FRDD_ORD_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN ORD.RPT_ORDER_QTY
            ELSE 0
            END) CURR_FRDD_ORD_QTY
    , ZEROIFNULL(SUM(DLV.RPT_DELIV_QTY)) SHIP_CURR_QTY
    , ZEROIFNULL(SUM(DIP.IN_PROC_PRI_CUR_MTH_QTY)) IN_PROC_CURR_QTY
    , ZEROIFNULL(SUM(OOD.CNFRM_PRI_CUR_MTH_QTY)) CNFRM_CURR_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                AND ORD.REJ_REAS_ID <> ' '
                AND ORD.RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                THEN (ORD.RPT_ORDER_QTY - (ZEROIFNULL(DLV.RPT_DELIV_QTY) + ZEROIFNULL(DIP.IN_PROC_TOT_QTY))) * (- 1)
            ELSE 0
            END) CANCEL_CURR_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(DIP.IN_PROC_NXT_FUT_MTH_QTY)) * (- 1)
            ELSE 0
            END) IN_PROC_FUT_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(OOD.CNFRM_NXT_FUT_MTH_QTY)) * (- 1)
            ELSE 0
            END) CNFRM_FUT_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(OOD.UNCNFRM_TOT_QTY)) * (- 1)
            ELSE 0
            END) UNCNFRM_TOT_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(OOD.BACK_ORDER_TOT_QTY)) * (- 1)
            ELSE 0
            END) BACKORDER_TOT_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(OOD.WAIT_LIST_TOT_QTY)) * (- 1)
            ELSE 0
            END) WAITLIST_TOT_QTY
    , SUM(CASE
            WHEN ORD.CALC_FRDD_CPM_FLG = 'Y'
                THEN (ZEROIFNULL(OOD.DEFER_TOT_QTY)) * (- 1)
            ELSE 0
            END) DEFER_TOT_QTY

FROM (
    SELECT
        ODGC.DAY_DATE
        , ODC.ORDER_FISCAL_YR
        , ODC.ORDER_ID
        , ODC.ORDER_LINE_NBR
        , MAX(ODC.SHIP_TO_CUST_ID) SHIP_TO_CUST_ID
        , MAX(ODC.MATL_ID) MATL_ID
        , MAX(ODC.FACILITY_ID) FACILITY_ID
        , MAX(ODC.FRST_PLN_GOODS_ISS_DT) FRST_RDD_DT
        , CASE
            WHEN FRST_RDD_DT < ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                THEN 'Y'
            ELSE 'N'
            END CALC_FRDD_CPM_FLG
        , MAX(ODC.REJ_REAS_ID || ' - ' || REJ.REJ_REAS_DESC) REJ_REAS_ID
        , MAX(ODC.ORDER_TYPE_ID) ORDER_TYPE_ID
        , SUM(ODC.RPT_ORDER_QTY) RPT_ORDER_QTY

    FROM NA_BI_VWS.ORDER_DETAIL ODC

    INNER JOIN GDYR_BI_VWS.GDYR_CAL ODGC
        ON ODGC.DAY_DATE BETWEEN ODC.EFF_DT AND ODC.EXP_DT

    LEFT JOIN NA_BI_VWS.ORD_REJ_REAS_DESC_CURR REJ
        ON ODC.REJ_REAS_ID = REJ.REJ_REAS_ID

    WHERE
        ODC.RO_PO_TYPE_IND = 'N'
        AND ODC.ORDER_DT = ODGC.DAY_DATE
        AND ODGC.DAY_DATE BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND CURRENT_DATE - 1
        AND ODC.RETURN_IND = 'N'

    GROUP BY
        1, 2, 3, 4
    ) ORD

LEFT JOIN (
    SELECT
        DDGC.DAY_DATE
        , DLS.ORDER_FISCAL_YR
        , DLS.ORDER_ID
        , DLS.ORDER_LINE_NBR
        , SUM(DLS.RPT_DELIV_QTY) RPT_DELIV_QTY

    FROM NA_BI_VWS.DELIVERY_DETAIL DLS

    INNER JOIN GDYR_BI_VWS.GDYR_CAL DDGC
        ON DDGC.DAY_DATE BETWEEN DLS.EFF_DT AND DLS.EXP_DT

    WHERE DLS.ACTL_GOODS_ISS_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) - 4 AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
        AND DDGC.DAY_DATE BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND CURRENT_DATE - 1

    GROUP BY
        1, 2, 3, 4
    ) DLV
    ON ORD.DAY_DATE = DLV.DAY_DATE
        AND ORD.ORDER_FISCAL_YR = DLV.ORDER_FISCAL_YR
        AND ORD.ORDER_ID = DLV.ORDER_ID
        AND ORD.ORDER_LINE_NBR = DLV.ORDER_LINE_NBR

LEFT JOIN (
    SELECT
        OOGC.DAY_DATE
        , ODC.ORDER_FISCAL_YR
        , ODC.ORDER_ID
        , ODC.ORDER_LINE_NBR
        , SUM(CASE
                WHEN ODC.PLN_GOODS_ISS_DT < ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                    THEN OOS.OPEN_CNFRM_QTY
                ELSE 0
                END) CNFRM_PRI_CUR_MTH_QTY
        , SUM(CASE
                WHEN ODC.PLN_GOODS_ISS_DT >= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                    THEN OOS.OPEN_CNFRM_QTY
                ELSE 0
                END) CNFRM_NXT_FUT_MTH_QTY
        , SUM(OOS.OPEN_CNFRM_QTY) CNFRM_TOT_QTY
        , SUM(OOS.UNCNFRM_QTY) UNCNFRM_TOT_QTY
        , SUM(OOS.BACK_ORDER_QTY) BACK_ORDER_TOT_QTY
        , SUM(OOS.DEFER_QTY) DEFER_TOT_QTY
        , SUM(OOS.WAIT_LIST_QTY) WAIT_LIST_TOT_QTY
        , SUM(OOS.OTHR_ORDER_QTY) OTHR_OPEN_TOT_QTY

    FROM NA_VWS.OPEN_ORDER_SCHDLN OOS

    INNER JOIN GDYR_BI_VWS.GDYR_CAL OOGC
        ON OOGC.DAY_DATE BETWEEN OOS.EFF_DT AND OOS.EXP_DT

    INNER JOIN NA_BI_VWS.ORDER_DETAIL ODC
        ON OOS.ORDER_FISCAL_YR = ODC.ORDER_FISCAL_YR
            AND OOS.ORDER_ID = ODC.ORDER_ID
            AND OOS.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
            AND OOS.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
            AND OOGC.DAY_DATE BETWEEN ODC.EFF_DT AND ODC.EXP_DT

    WHERE ODC.RO_PO_TYPE_IND = 'N'
        AND OOGC.DAY_DATE BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND CURRENT_DATE - 1

    GROUP BY
        1, 2, 3, 4
    HAVING CNFRM_TOT_QTY + UNCNFRM_TOT_QTY + BACK_ORDER_TOT_QTY + DEFER_TOT_QTY + WAIT_LIST_TOT_QTY + OTHR_OPEN_TOT_QTY <> 0
    ) OOD
    ON ORD.DAY_DATE = OOD.DAY_DATE
        AND ORD.ORDER_FISCAL_YR = OOD.ORDER_FISCAL_YR
        AND ORD.ORDER_ID = OOD.ORDER_ID
        AND ORD.ORDER_LINE_NBR = OOD.ORDER_LINE_NBR

LEFT JOIN (
    SELECT
        IPGC.DAY_DATE
        , DLS.ORDER_FISCAL_YR
        , DLS.ORDER_ID
        , DLS.ORDER_LINE_NBR
        , SUM(CASE
                WHEN DLS.PLN_GOODS_MVT_DT < ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                    THEN DIP.RPT_QTY_TO_SHIP
                ELSE 0
                END) IN_PROC_PRI_CUR_MTH_QTY
        , SUM(CASE
                WHEN DLS.PLN_GOODS_MVT_DT >= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                    THEN DIP.RPT_QTY_TO_SHIP
                ELSE 0
                END) IN_PROC_NXT_FUT_MTH_QTY
        , SUM(DIP.RPT_QTY_TO_SHIP) IN_PROC_TOT_QTY

    FROM GDYR_VWS.DELIV_IN_PROC DIP

    INNER JOIN GDYR_BI_VWS.GDYR_CAL IPGC
        ON IPGC.DAY_DATE BETWEEN DIP.EFF_DT AND DIP.EXP_DT

    INNER JOIN NA_BI_VWS.DELIVERY_DETAIL DLS
        ON DIP.ORDER_FISCAL_YR = DLS.ORDER_FISCAL_YR
            AND DIP.DELIV_ID = DLS.DELIV_ID
            AND DIP.DELIV_LINE_NBR = DLS.DELIV_LINE_NBR
            AND IPGC.DAY_DATE BETWEEN DIP.EFF_DT AND DIP.EXP_DT

    WHERE DIP.INTRA_CMPNY_FLG = 'N'
        AND DLS.ACTL_GOODS_ISS_DT IS NULL
        AND IPGC.DAY_DATE BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND CURRENT_DATE - 1

    GROUP BY
        1, 2, 3, 4
    ) DIP
    ON ORD.DAY_DATE = DIP.DAY_DATE
        AND ORD.ORDER_FISCAL_YR = DIP.ORDER_FISCAL_YR
        AND ORD.ORDER_ID = DIP.ORDER_ID
        AND ORD.ORDER_LINE_NBR = DIP.ORDER_LINE_NBR

INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
    ON ORD.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
    ON ORD.MATL_ID = MATL.MATL_ID

WHERE (
        CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
        OR (
            CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
            AND CUST.DISTR_CHAN_CD IN ('30', '31', '32')
            )
        )
    AND MATL.PBU_NBR IN ('01', '03')
    AND MATL.MKT_AREA_NBR <> '04'
    AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')

GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
