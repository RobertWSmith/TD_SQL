
SELECT 
    COALESCE(ORD.REPL_OE_IND, SHP.REPL_OE_IND, OO.REPL_OE_IND, IP.REPL_OE_IND) REPL_OE_IND
    , COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT, IP.DAY_DT) DAY_DT
    , CASE 
        WHEN COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT, IP.DAY_DT) = ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, - 1)
            THEN 'Pri Month Working'
        WHEN COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT, IP.DAY_DT) = ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 2, - 1)
            THEN 'Pri Month Other'
        ELSE CAST(CAST(COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT, IP.DAY_DT) AS DATE FORMAT 'YYYY-MM-DD') AS VARCHAR(10))
        END DAY_DT_TXT
    , SUM(ORD.TOT_ORD_QTY) TOT_ORD_QTY
    , SUM(ORD.CNCL_QTY) CNCL_QTY
    , SUM(ORD.NET_ORD_QTY) NET_ORD_QTY
    , SUM(ORD.NET_ORD_FRDD_PRI_CUR_MTH_QTY) NET_ORD_FRDD_PRI_CUR_MTH_QTY
    , SUM(ORD.NET_ORD_FRDD_NXT_MTH_QTY) NET_ORD_FRDD_NXT_MTH_QTY
    , SUM(ORD.NET_ORD_FRDD_FUT_MTH_QTY) NET_ORD_FRDD_FUT_MTH_QTY
    , SUM(SHP.SHP_QTY) SHP_QTY
    , SUM(OO.CNFRM_PRI_MTH_QTY) CNFRM_PRI_MTH_QTY
    , SUM(OO.CNFRM_CUR_MTH_QTY) CNFRM_CUR_MTH_QTY
    , SUM(OO.CNFRM_NXT_MTH_QTY) CNFRM_NXT_MTH_QTY
    , SUM(OO.CNFRM_FUT_MTH_QTY) CNFRM_FUT_MTH_QTY
    , SUM(OO.CNFRM_TOT_QTY) CNFRM_TOT_QTY
    , SUM(IP.IN_PROC_PRI_MTH_QTY) IN_PROC_PRI_MTH_QTY
    , SUM(IP.IN_PROC_CUR_MTH_QTY) IN_PROC_CUR_MTH_QTY
    , SUM(IP.IN_PROC_NXT_MTH_QTY) IN_PROC_NXT_MTH_QTY
    , SUM(IP.IN_PROC_FUT_MTH_QTY) IN_PROC_FUT_MTH_QTY
    , SUM(IP.IN_PROC_TOT_QTY) IN_PROC_TOT_QTY
    , SUM(OO.UNCNFRM_TOT_QTY) UNCNFRM_TOT_QTY
    , SUM(OO.BACK_ORDER_TOT_QTY) BACK_ORDER_TOT_QTY
    , SUM(OO.DEFER_TOT_QTY) DEFER_TOT_QTY
    , SUM(OO.WAIT_LIST_TOT_QTY) WAIT_LIST_TOT_QTY

FROM (
    SELECT 
        ORD.REPL_OE_IND
        , CASE 
            WHEN ODMS_PMW.ORDER_ID IS NOT NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, - 1)
            WHEN ORD.ORDER_DT <= (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
                OR ORD.ORDER_DT IS NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 2, - 1)
            ELSE ORD.ORDER_DT
            END DAY_DT
        , SUM(CASE 
                WHEN ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN ORD.SL_RPT_ORDER_QTY
                ELSE 0
                END) TOT_ORD_QTY
        , SUM(CASE 
                WHEN ORD.REJ_REAS_ID <> ''
                    THEN CASE 
                            WHEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                                THEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY)
                            ELSE 0
                            END
                ELSE 0
                END) CNCL_QTY
        , SUM(CASE 
                WHEN ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN ORD.REJ_REAS_ID = ''
                                THEN ORD.SL_RPT_ORDER_QTY
                            WHEN ORD.REJ_REAS_ID <> ''
                                THEN CASE 
                                        WHEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                                            THEN ZEROIFNULL(DLV.RPT_DELIV_QTY)
                                        ELSE ORD.SL_RPT_ORDER_QTY
                                        END
                            ELSE 0
                            END
                ELSE 0
                END) NET_ORD_QTY
        , SUM(CASE 
                WHEN ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN ORD.FRST_RDD <= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                                AND ORD.REJ_REAS_ID = ''
                                THEN ORD.SL_RPT_ORDER_QTY
                            WHEN ORD.FRST_RDD <= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                                AND ORD.REJ_REAS_ID <> ''
                                THEN CASE 
                                        WHEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                                            THEN ZEROIFNULL(DLV.RPT_DELIV_QTY)
                                        ELSE ORD.SL_RPT_ORDER_QTY
                                        END
                            ELSE 0
                            END
                ELSE 0
                END) NET_ORD_FRDD_PRI_CUR_MTH_QTY
        , SUM(CASE 
                WHEN ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN ORD.FRST_RDD BETWEEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                                    AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                                AND ORD.REJ_REAS_ID = ''
                                THEN ORD.SL_RPT_ORDER_QTY
                            WHEN ORD.FRST_RDD BETWEEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                                    AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                                AND ORD.REJ_REAS_ID <> ''
                                THEN CASE 
                                        WHEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                                            THEN ZEROIFNULL(DLV.RPT_DELIV_QTY)
                                        ELSE ORD.SL_RPT_ORDER_QTY
                                        END
                            ELSE 0
                            END
                ELSE 0
                END) NET_ORD_FRDD_NXT_MTH_QTY
        , SUM(CASE 
                WHEN ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN ORD.FRST_RDD >= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2)
                                AND ORD.REJ_REAS_ID = ''
                                THEN ORD.SL_RPT_ORDER_QTY
                            WHEN ORD.FRST_RDD >= ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2)
                                AND ORD.REJ_REAS_ID <> ''
                                THEN CASE 
                                        WHEN ORD.SL_RPT_ORDER_QTY - ZEROIFNULL(DLV.RPT_DELIV_QTY) >= 0
                                            THEN ZEROIFNULL(DLV.RPT_DELIV_QTY)
                                        ELSE ORD.SL_RPT_ORDER_QTY
                                        END
                            ELSE 0
                            END
                ELSE 0
                END) NET_ORD_FRDD_FUT_MTH_QTY

    FROM (
        SELECT 
            ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
            , MAX(CASE 
                    WHEN CUST.SALES_ORG_CD IN ('N302', 'N312', 'N322')
                        OR (
                            CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                            AND CUST.DISTR_CHAN_CD = '32'
                            )
                        THEN 'OE'
                    ELSE 'Repl'
                    END) REPL_OE_IND
            , MAX(ORD.ORDER_DT) ORDER_DT
            , MAX(ORD.REJ_REAS_ID) REJ_REAS_ID
            , MAX(ORD.FRST_RDD) FRST_RDD
            , SUM(ORD.RPT_ORDER_QTY) SL_RPT_ORDER_QTY

        FROM NA_BI_VWS.ORDER_DETAIL_CURR ORD

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON ORD.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON ORD.MATL_ID = MATL.MATL_ID

        WHERE ORD.RO_PO_TYPE_IND = 'N'
            AND (
                CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N302', 'N312', 'N322', 'N307', 'N317', 'N336')
                OR (
                    CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                    AND CUST.DISTR_CHAN_CD IN ('30', '31', '32')
                    )
                )
            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
            AND MATL.PBU_NBR = '01'
            AND (
                ORD.ORDER_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                    AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                OR ORD.CANCEL_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                    AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                )
        GROUP BY 
            ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
        ) ORD

    LEFT JOIN (
        SELECT 
            ORDER_ID
            , ORDER_LINE_NBR
            , SUM(RPT_DELIV_QTY) RPT_DELIV_QTY
        FROM NA_BI_VWS.DELIVERY_DETAIL_CURR

        WHERE ACTL_GOODS_ISS_DT IS NOT NULL

        GROUP BY 
            ORDER_ID
            , ORDER_LINE_NBR
        ) DLV
        ON ORD.ORDER_ID = DLV.ORDER_ID
            AND ORD.ORDER_LINE_NBR = DLV.ORDER_LINE_NBR

    LEFT JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS_PMW
        ON ORD.ORDER_ID = ODMS_PMW.ORDER_ID
            AND ORD.ORDER_LINE_NBR = ODMS_PMW.ORDER_LINE_NBR
            AND ODMS_PMW.REF_DT = (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
            AND ODMS_PMW.OPEN_CNFRM_PGI_PAST_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_PRIOR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_CURR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_NXT_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PAST_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PRIOR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_CURR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_NXT_MTH_QTY <> 0

    GROUP BY 
        REPL_OE_IND
        , DAY_DT
    ) ORD

FULL JOIN (
    SELECT 
        CASE 
            WHEN CUST.SALES_ORG_CD IN ('N302', 'N312', 'N322')
                OR (
                    CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                    AND CUST.DISTR_CHAN_CD = '32'
                    )
                THEN 'OE'
            ELSE 'Repl'
            END REPL_OE_IND
        , CASE 
            WHEN ODMS_PMW.ORDER_ID IS NOT NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, - 1)
            WHEN ORD.ORDER_DT <= (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
                OR ORD.ORDER_DT IS NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 2, - 1)
            ELSE ORD.ORDER_DT
            END DAY_DT
        , SUM(DLV.RPT_DELIV_QTY) SHP_QTY

    FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DLV

    LEFT JOIN (
        SELECT 
            ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
            , MAX(ORD.ORDER_DT) ORDER_DT
        FROM NA_BI_VWS.ORD_DTL_SMRY ORD

        INNER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DLV
            ON ORD.ORDER_ID = DLV.ORDER_ID
                AND ORD.ORDER_LINE_NBR = DLV.ORDER_LINE_NBR

        WHERE 
            DLV.ACTL_GOODS_ISS_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
        GROUP BY 
            ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
        ) ORD
        ON DLV.ORDER_ID = ORD.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR

    LEFT JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS_PMW
        ON DLV.ORDER_ID = ODMS_PMW.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ODMS_PMW.ORDER_LINE_NBR
            AND ODMS_PMW.REF_DT = (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
            AND ODMS_PMW.OPEN_CNFRM_PGI_PAST_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_PRIOR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_CURR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_NXT_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PAST_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PRIOR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_CURR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_NXT_MTH_QTY <> 0

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON DLV.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON DLV.MATL_ID = MATL.MATL_ID

    WHERE 
        (
            CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N302', 'N312', 'N322', 'N307', 'N317', 'N336')
            OR (
                CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                AND CUST.DISTR_CHAN_CD IN ('30', '31', '32')
                )
            )
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
        AND MATL.PBU_NBR = '01'
        AND DLV.ACTL_GOODS_ISS_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1 AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
    GROUP BY 
        REPL_OE_IND
        , DAY_DT
    ) SHP
    ON SHP.REPL_OE_IND = ORD.REPL_OE_IND
        AND SHP.DAY_DT = ORD.DAY_DT

FULL JOIN (
    SELECT 
        CASE 
            WHEN CUST.SALES_ORG_CD IN ('N302', 'N312', 'N322')
                OR (
                    CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                    AND CUST.DISTR_CHAN_CD = '32'
                    )
                THEN 'OE'
            ELSE 'Repl'
            END REPL_OE_IND
        , CASE 
            WHEN ODMS_PMW.ORDER_ID IS NOT NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, - 1)
            WHEN ORD.ORDER_DT <= (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
                OR ORD.ORDER_DT IS NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 2, - 1)
            ELSE ORD.ORDER_DT
            END DAY_DT
        , SUM(CASE 
                WHEN ORD.PLN_GOODS_ISS_DT < (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN OO.OPEN_CNFRM_QTY * MATL.NET_WT
                            ELSE OO.OPEN_CNFRM_QTY
                            END
                ELSE 0
                END) CNFRM_PRI_MTH_QTY
        , SUM(CASE 
                WHEN ORD.PLN_GOODS_ISS_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN OO.OPEN_CNFRM_QTY * MATL.NET_WT
                            ELSE OO.OPEN_CNFRM_QTY
                            END
                ELSE 0
                END) CNFRM_CUR_MTH_QTY
        , SUM(CASE 
                WHEN ORD.PLN_GOODS_ISS_DT BETWEEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN OO.OPEN_CNFRM_QTY * MATL.NET_WT
                            ELSE OO.OPEN_CNFRM_QTY
                            END
                ELSE 0
                END) CNFRM_NXT_MTH_QTY
        , SUM(CASE 
                WHEN ORD.PLN_GOODS_ISS_DT > ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN OO.OPEN_CNFRM_QTY * MATL.NET_WT
                            ELSE OO.OPEN_CNFRM_QTY
                            END
                ELSE 0
                END) CNFRM_FUT_MTH_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN OO.OPEN_CNFRM_QTY * MATL.NET_WT
                ELSE OO.OPEN_CNFRM_QTY
                END) CNFRM_TOT_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN OO.UNCNFRM_QTY * MATL.NET_WT
                ELSE OO.UNCNFRM_QTY
                END) UNCNFRM_TOT_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN OO.BACK_ORDER_QTY * MATL.NET_WT
                ELSE OO.BACK_ORDER_QTY
                END) BACK_ORDER_TOT_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN OO.DEFER_QTY * MATL.NET_WT
                ELSE OO.DEFER_QTY
                END) DEFER_TOT_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN OO.WAIT_LIST_QTY * MATL.NET_WT
                ELSE OO.WAIT_LIST_QTY
                END) WAIT_LIST_TOT_QTY

    FROM NA_BI_VWS.ORDER_DETAIL_CURR ORD

    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_SNP OO
        ON ORD.ORDER_ID = OO.ORDER_ID
            AND ORD.ORDER_LINE_NBR = OO.ORDER_LINE_NBR
            AND ORD.SCHED_LINE_NBR = OO.SCHED_LINE_NBR

    LEFT JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS_PMW
        ON ORD.ORDER_ID = ODMS_PMW.ORDER_ID
            AND ORD.ORDER_LINE_NBR = ODMS_PMW.ORDER_LINE_NBR
            AND ODMS_PMW.REF_DT = (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
            AND ODMS_PMW.OPEN_CNFRM_PGI_PAST_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_PRIOR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_CURR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_NXT_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PAST_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PRIOR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_CURR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_NXT_MTH_QTY <> 0

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON ORD.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON ORD.MATL_ID = MATL.MATL_ID

    WHERE 
        ORD.RO_PO_TYPE_IND = 'N'
        AND (
            CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N302', 'N312', 'N322', 'N307', 'N317', 'N336')
            OR (
                CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                AND CUST.DISTR_CHAN_CD IN ('30', '31', '32')
                )
            )
        AND MATL.PBU_NBR = '01'
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
        AND OO.REF_DT = (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
        AND (
            OO.OPEN_CNFRM_QTY <> 0
            OR OO.UNCNFRM_QTY <> 0
            OR OO.BACK_ORDER_QTY <> 0
            OR OO.DEFER_QTY <> 0
            OR OO.WAIT_LIST_QTY <> 0
            )

    GROUP BY 
        REPL_OE_IND
        , DAY_DT
    ) OO
    ON COALESCE(ORD.REPL_OE_IND, SHP.REPL_OE_IND) = OO.REPL_OE_IND
        AND COALESCE(ORD.DAY_DT, SHP.DAY_DT) = OO.DAY_DT

FULL JOIN (
    SELECT 
        CASE 
            WHEN CUST.SALES_ORG_CD IN ('N302', 'N312', 'N322')
                OR (
                    CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323')
                    AND CUST.DISTR_CHAN_CD = '32'
                    )
                THEN 'OE'
            ELSE 'Repl'
            END REPL_OE_IND
        , CASE 
            WHEN ODMS_PMW.ORDER_ID IS NOT NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, - 1)
            WHEN ORD.ORDER_DT <= (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) OR ORD.ORDER_DT IS NULL
                THEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 2, - 1)
            ELSE ORD.ORDER_DT
            END DAY_DT
        , SUM(CASE 
                WHEN DLV.PLN_GOODS_MVT_DT < (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN DIP.QTY_TO_SHIP * MATL.NET_WT
                            ELSE DIP.QTY_TO_SHIP
                            END
                ELSE 0
                END) IN_PROC_PRI_MTH_QTY
        , SUM(CASE 
                WHEN DLV.PLN_GOODS_MVT_DT BETWEEN (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN DIP.QTY_TO_SHIP * MATL.NET_WT
                            ELSE DIP.QTY_TO_SHIP
                            END
                ELSE 0
                END) IN_PROC_CUR_MTH_QTY
        , SUM(CASE 
                WHEN DLV.PLN_GOODS_MVT_DT BETWEEN ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 1)
                        AND ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN DIP.QTY_TO_SHIP * MATL.NET_WT
                            ELSE DIP.QTY_TO_SHIP
                            END
                ELSE 0
                END) IN_PROC_NXT_MTH_QTY
        , SUM(CASE 
                WHEN DLV.PLN_GOODS_MVT_DT > ADD_MONTHS((CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1) + 1, 2) - 1
                    THEN CASE 
                            WHEN MATL.MKT_GRP_NBR = '0019'
                                THEN DIP.QTY_TO_SHIP * MATL.NET_WT
                            ELSE DIP.QTY_TO_SHIP
                            END
                ELSE 0
                END) IN_PROC_FUT_MTH_QTY
        , SUM(CASE 
                WHEN MATL.MKT_GRP_NBR = '0019'
                    THEN DIP.QTY_TO_SHIP * MATL.NET_WT
                ELSE DIP.QTY_TO_SHIP
                END) IN_PROC_TOT_QTY

    FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DLV

    INNER JOIN GDYR_BI_VWS.EXTERNAL_DELIV_IN_PROC_CURR DIP
        ON DLV.DELIV_ID = DIP.DELIV_ID
            AND DLV.DELIV_LINE_NBR = DIP.DELIV_LINE_NBR

    LEFT JOIN (
        SELECT 
            ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
            , MAX(ORD.ORDER_DT) ORDER_DT
        FROM NA_BI_VWS.ORD_DTL_SMRY ORD
        INNER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DLV
            ON ORD.ORDER_ID = DLV.ORDER_ID
                AND ORD.ORDER_LINE_NBR = DLV.ORDER_LINE_NBR
        WHERE DLV.ACTL_GOODS_ISS_DT IS NULL
        GROUP BY ORD.ORDER_ID
            , ORD.ORDER_LINE_NBR
        ) ORD
        ON DLV.ORDER_ID = ORD.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR

    LEFT JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS_PMW
        ON DLV.ORDER_ID = ODMS_PMW.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ODMS_PMW.ORDER_LINE_NBR
            AND ODMS_PMW.REF_DT = (CURRENT_DATE - 1) - EXTRACT(DAY FROM CURRENT_DATE - 1)
            AND ODMS_PMW.OPEN_CNFRM_PGI_PAST_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_PRIOR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_CURR_MTH_QTY + ODMS_PMW.OPEN_CNFRM_PGI_NXT_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PAST_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_PRIOR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_CURR_MTH_QTY + ODMS_PMW.IN_PROC_PGMV_NXT_MTH_QTY <> 0

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON DLV.SHIP_TO_CUST_ID = CUST.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON DLV.MATL_ID = MATL.MATL_ID

    WHERE 
        (
            CUST.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N302', 'N312', 'N322', 'N307', 'N317', 'N336')
            OR (CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND CUST.DISTR_CHAN_CD IN ('30', '31', '32'))
        )
        AND MATL.PBU_NBR = '01'
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
        AND DLV.ACTL_GOODS_ISS_DT IS NULL

    GROUP BY 
        REPL_OE_IND
        , DAY_DT
    ) IP
    ON COALESCE(ORD.REPL_OE_IND, SHP.REPL_OE_IND, OO.REPL_OE_IND) = IP.REPL_OE_IND
        AND COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT) = IP.DAY_DT

GROUP BY 
    COALESCE(ORD.REPL_OE_IND, SHP.REPL_OE_IND, OO.REPL_OE_IND, IP.REPL_OE_IND)
    , COALESCE(ORD.DAY_DT, SHP.DAY_DT, OO.DAY_DT, IP.DAY_DT)
    , DAY_DT_TXT

