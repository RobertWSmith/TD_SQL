SELECT
    O.DAY_DATE
    , O.SHIP_TO_CUST_ID
    , O.FACILITY_ID
    , O.MATL_ID

    , SUM(CASE WHEN O.ORD_CURR_MTH_FLG = 'Y' THEN O.RPT_ORDER_QTY ELSE 0 END) AS ORDER_QTY
    , SUM(CASE WHEN O.ORD_CURR_MTH_FLG = 'Y' AND O.FPGI_CM_FLG = 'N' THEN O.RPT_ORDER_QTY ELSE 0 END) AS ORDER_FTR_QTY
    , SUM(CASE WHEN O.ORD_CURR_MTH_FLG = 'Y' AND O.FPGI_CM_FLG = 'Y' THEN O.RPT_ORDER_QTY ELSE 0 END) AS ORDER_CURR_QTY

    , SUM(CASE
        WHEN O.CANCEL_CURR_MTH_FLG = 'Y' AND O.REJ_REAS_ID > '' AND (O.RPT_ORDER_QTY - (ZEROIFNULL(DIP.RPT_IN_PROC_TOT_QTY) + ZEROIFNULL(DLV.RPT_DELIV_QTY))) > 0
            THEN O.RPT_ORDER_QTY - (ZEROIFNULL(DIP.RPT_IN_PROC_TOT_QTY) + ZEROIFNULL(DLV.RPT_DELIV_QTY))
        ELSE 0
        END) AS TOT_CANCEL_QTY
    , SUM(CASE
        WHEN O.CANCEL_CURR_MTH_FLG = 'Y' AND O.FPGI_CM_FLG = 'Y' AND O.REJ_REAS_ID > '' AND (O.RPT_ORDER_QTY - (ZEROIFNULL(DIP.RPT_IN_PROC_TOT_QTY) + ZEROIFNULL(DLV.RPT_DELIV_QTY))) > 0
            THEN O.RPT_ORDER_QTY - (ZEROIFNULL(DIP.RPT_IN_PROC_TOT_QTY) + ZEROIFNULL(DLV.RPT_DELIV_QTY))
        ELSE 0
        END) AS CANCEL_CURR_QTY
    , SUM(CASE
        WHEN O.ORD_CURR_MTH_FLG = 'Y'
            THEN ZEROIFNULL(DIP.RPT_IN_PROC_CURR_QTY)
        ELSE 0
        END) AS IN_PROC_CURR_QTY
    , SUM(CASE
        WHEN O.ORD_CURR_MTH_FLG = 'Y'
            THEN ZEROIFNULL(OOL.RPT_CNFRM_CURR_QTY)
        ELSE 0 
        END) AS CNFRM_CURR_QTY
    , SUM(CASE
        WHEN O.FPGI_CM_FLG = 'Y' AND O.ORD_CURR_MTH_FLG = 'Y'
            THEN ZEROIFNULL(DIP.RPT_IN_PROC_FTR_QTY)
        ELSE 0
        END) AS IN_PROC_FTR_QTY
    , SUM(CASE
        WHEN O.FPGI_CM_FLG = 'Y' AND O.ORD_CURR_MTH_FLG = 'Y'
            THEN ZEROIFNULL(OOL.RPT_CNFRM_FTR_QTY)
        ELSE 0
        END) AS CNFRM_FTR_QTY
    , SUM(CASE
        WHEN O.ORD_CURR_MTH_FLG = 'Y'
            THEN ZEROIFNULL(DLV.RPT_DELIV_QTY)
        ELSE 0
        END) AS DELIV_QTY
    , IN_PROC_CURR_QTY + CNFRM_CURR_QTY + DELIV_QTY AS MTD_SHIPPED_WORKING

FROM (

    SELECT
        CAL.DAY_DATE
        , CAL.MONTH_DT
        , ADD_MONTHS(CAL.MONTH_DT, 1) - 1 AS END_OF_MONTH_DT

        , OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.SHIP_TO_CUST_ID
        , OD.MATL_ID
        , OD.FACILITY_ID
        , OD.REJ_REAS_ID

        , OD.ORDER_TYPE_ID
        , CASE WHEN OD.FRST_PLN_GOODS_ISS_DT BETWEEN CAL.MONTH_DT AND END_OF_MONTH_DT THEN 'Y' ELSE 'N' END AS FPGI_CM_FLG
        , CASE WHEN OD.ORDER_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE THEN 'Y' ELSE 'N' END AS ORD_CURR_MTH_FLG
        , CASE WHEN OD.CANCEL_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE THEN 'Y' ELSE 'N' END AS CANCEL_CURR_MTH_FLG
        , SUM(OD.RPT_ORDER_QTY) AS RPT_ORDER_QTY

    FROM GDYR_BI_VWS.GDYR_CAL CAL

        INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
            ON CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
            ON M.MATL_ID = OD.MATL_ID

        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
            ON F.FACILITY_ID = OD.FACILITY_ID
            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND F.DISTR_CHAN_CD = '81'

    WHERE
        OD.RO_PO_TYPE_IND = 'N'
        AND OD.RETURN_IND = 'N'
        AND (
            OD.ORDER_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE
            --OR OD.CANCEL_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE
            )
        AND (
            C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
            OR (
                C.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                AND C.DISTR_CHAN_CD IN ('30', '31', '32')
                )
            )
        AND M.PBU_NBR IN ('01', '03')
        AND M.MKT_AREA_NBR <> '04'
        AND CAL.DAY_DATE BETWEEN DATE '2015-07-01' AND CURRENT_DATE-1
        --AND CAL.DAY_DATE = CURRENT_DATE-1

    GROUP BY
        CAL.DAY_DATE
        , CAL.MONTH_DT
        , END_OF_MONTH_DT

        , OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.SHIP_TO_CUST_ID
        , OD.MATL_ID
        , OD.FACILITY_ID
        , OD.REJ_REAS_ID

        , OD.ORDER_TYPE_ID
        , FPGI_CM_FLG
        , ORD_CURR_MTH_FLG
        , CANCEL_CURR_MTH_FLG

    ) O

    LEFT OUTER JOIN (
            SELECT
                CAL.DAY_DATE
                , OO.ORDER_FISCAL_YR 
                , OO.ORDER_ID
                , OO.ORDER_LINE_NBR
                , SUM(ZEROIFNULL(OO.RPT_OPEN_CNFRM_QTY)) AS RPT_CNFRM_TOT_QTY
                , SUM(CASE WHEN ORD.PLN_GOODS_ISS_DT < ADD_MONTHS(CAL.MONTH_DT, 1) THEN ZEROIFNULL(OO.RPT_OPEN_CNFRM_QTY) ELSE 0 END) AS RPT_CNFRM_CURR_QTY
                , RPT_CNFRM_TOT_QTY - RPT_CNFRM_CURR_QTY AS RPT_CNFRM_FTR_QTY
                , SUM(OO.RPT_UNCNFRM_QTY) AS RPT_UNCNFRM_QTY
                , SUM(OO.RPT_BACK_ORDER_QTY) AS RPT_BACK_ORDER_QTY
                , SUM(OO.RPT_DEFER_QTY) AS RPT_DEFER_QTY
                , SUM(OO.RPT_WAIT_LIST_QTY) AS RPT_WAIT_LIST_QTY
                , SUM(OO.RPT_OTHR_ORDER_QTY) AS RPT_OTHR_ORDER_QTY

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN OO
                    ON CAL.DAY_DATE BETWEEN OO.EFF_DT AND OO.EXP_DT

                INNER JOIN NA_BI_VWS.ORDER_DETAIL ORD
                    ON ORD.ORDER_FISCAL_YR = OO.ORDER_FISCAL_YR
                    AND ORD.ORDER_ID = OO.ORDER_ID
                    AND ORD.ORDER_LINE_NBR = OO.ORDER_LINE_NBR
                    AND ORD.SCHED_LINE_NBR = OO.SCHED_LINE_NBR
                    AND CAL.DAY_DATE BETWEEN ORD.EFF_DT AND ORD.EXP_DT

                INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR C
                    ON C.SHIP_TO_CUST_ID = ORD.SHIP_TO_CUST_ID

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = ORD.MATL_ID

                INNER JOIN GDYR_BI_vWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = ORD.FACILITY_ID
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.DISTR_CHAN_CD = '81'

            WHERE
                ORD.RO_PO_TYPE_IND = 'N'
                AND ORD.RETURN_IND = 'N'
                AND ORD.ORDER_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE
                AND (
                    C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
                    OR (
                        C.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                        AND C.DISTR_CHAN_CD IN ('30', '31', '32')
                        )
                    )
                AND M.PBU_NBR IN ('01', '03')
                AND M.MKT_AREA_NBR <> '04'
                AND CAL.DAY_DATE BETWEEN CURRENT_DATE-1 - EXTRACT(DAY FROM CURRENT_DATE-1)+1 AND CURRENT_DATE-1
                --AND CAL.DAY_DATE = CURRENT_DATE-1

            GROUP BY
                CAL.DAY_DATE
                , OO.ORDER_FISCAL_YR 
                , OO.ORDER_ID
                , OO.ORDER_LINE_NBR
            ) OOL
        ON OOL.DAY_DATE = O.DAY_DATE
        AND OOL.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND OOL.ORDER_ID = O.ORDER_ID
        AND OOL.ORDER_LINE_NBR = O.ORDER_LINE_NBR

    LEFT OUTER JOIN (
            SELECT
                CAL.DAY_DATE
                , D.ORDER_FISCAL_YR
                , D.ORDER_ID
                , D.ORDER_LINE_NBR
                , SUM(D.RPT_DELIV_QTY) AS RPT_DELIV_QTY

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN NA_BI_VWS.DELIVERY_DETAIL D
                    ON CAL.DAY_DATE BETWEEN D.EFF_DT AND D.EXP_DT
                    AND D.ACTL_GOODS_ISS_DT IS NOT NULL

                INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR C
                    ON C.SHIP_TO_CUST_ID = D.SHIP_TO_CUST_ID

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = D.MATL_ID

                INNER JOIN GDYR_BI_vWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = D.DELIV_LINE_FACILITY_ID
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.DISTR_CHAN_CD = '81'

            WHERE
                D.ACTL_GOODS_ISS_DT BETWEEN CAL.MONTH_DT AND CAL.DAY_DATE
                AND (
                    C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
                    OR (
                        C.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                        AND C.DISTR_CHAN_CD IN ('30', '31', '32')
                        )
                    )
                AND M.PBU_NBR IN ('01', '03')
                AND M.MKT_AREA_NBR <> '04'
                AND CAL.DAY_DATE BETWEEN CURRENT_DATE-1 - EXTRACT(DAY FROM CURRENT_DATE-1)+1 AND CURRENT_DATE-1
                --AND CAL.DAY_DATE = CURRENT_DATE-1

            GROUP BY
                CAL.DAY_DATE
                , D.ORDER_FISCAL_YR
                , D.ORDER_ID
                , D.ORDER_LINE_NBR
            ) DLV
        ON DLV.DAY_DATE = O.DAY_DATE
        AND DLV.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND DLV.ORDER_ID = O.ORDER_ID
        AND DLV.ORDER_LINE_NBR = O.ORDER_LINE_NBR

    LEFT OUTER JOIN (
            SELECT
                CAL.DAY_DATE
                , DIP.ORDER_FISCAL_YR
                , DIP.ORDER_ID
                , DIP.ORDER_LINE_NBR
                , SUM(DIP.RPT_QTY_TO_SHIP) AS RPT_IN_PROC_TOT_QTY
                , SUM(CASE WHEN D.PLN_GOODS_MVT_DT < ADD_MONTHS(CAL.MONTH_DT, 1) THEN DIP.RPT_QTY_TO_SHIP ELSE 0  END) AS RPT_IN_PROC_CURR_QTY
                , RPT_IN_PROC_TOT_QTY - RPT_IN_PROC_CURR_QTY AS RPT_IN_PROC_FTR_QTY

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN GDYR_VWS.DELIV_IN_PROC DIP
                    ON CAL.DAY_DATE BETWEEN DIP.EFF_DT AND DIP.EXP_DT

                INNER JOIN NA_BI_VWS.DELIVERY_DETAIL D
                    ON D.FISCAL_YR = DIP.DELIV_FISCAL_YR
                    AND D.DELIV_ID = DIP.DELIV_ID
                    AND D.DELIV_LINE_NBR = DIP.DELIV_LINE_NBR
                    AND CAL.DAY_DATE BETWEEN D.EFF_DT AND D.EXP_DT

            WHERE
                D.ACTL_GOODS_ISS_DT IS NULL
                AND DIP.INTRA_CMPNY_FLG = 'N'
                AND (
                    D.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
                    OR (
                        D.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                        AND D.DISTR_CHAN_CD IN ('30', '31', '32')
                        )
                    )
                AND CAL.DAY_DATE BETWEEN CURRENT_DATE-1 - EXTRACT(DAY FROM CURRENT_DATE-1)+1 AND CURRENT_DATE-1
                AND D.MATL_ID IN (
                        SELECT
                            MATL_ID
                        FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR
                        WHERE
                            SUPER_BRAND_ID IN ('01', '02', '03', '05')
                            AND PBU_NBR IN ('01', '03')
                            AND MKT_AREA_NBR NOT IN ('04')
                    )
                AND D.DELIV_LINE_FACILITY_ID IN (
                        SELECT
                            FACILITY_ID
                        FROM GDYR_BI_VWS.NAT_FACILITY_EN_CURR
                        WHERE
                            SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND DISTR_CHAN_CD = '81'
                    )

            GROUP BY
                CAL.DAY_DATE
                , DIP.ORDER_FISCAL_YR
                , DIP.ORDER_ID
                , DIP.ORDER_LINE_NBR
            ) DIP
        ON DIP.DAY_DATE = O.DAY_DATE
        AND DIP.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND DIP.ORDER_ID = O.ORDER_ID
        AND DIP.ORDER_LINE_NBR = O.ORDER_LINE_NBR

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = O.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = O.MATL_ID

    LEFT JOIN NA_BI_VWS.ORD_REJ_REAS_DESC_CURR REJ
        ON REJ.REJ_REAS_ID = O.REJ_REAS_ID

WHERE (
        C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302', 'N312', 'N322')
        OR (
            C.SALES_ORG_CD IN ('N303', 'N313', 'N323')
            AND C.DISTR_CHAN_CD IN ('30', '31', '32')
            )
        )
    AND M.PBU_NBR IN ('01', '03')
    AND M.MKT_AREA_NBR <> '04'
    AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')

GROUP BY
    O.DAY_DATE
    , O.SHIP_TO_CUST_ID
    , O.FACILITY_ID
    , O.MATL_ID
