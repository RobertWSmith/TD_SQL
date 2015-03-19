SELECT
    O.MEAS_DT
    --, O.MATL_ID
    --, O.MATL_DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    --, O.CATEGORY_CD
    --, O.CATEGORY_NM
    --, O.OWN_CUST_ID
    --, O.OWN_CUST_NAME
    , O.OE_REPL_IND

    , O.QTY_UNIT_MEAS_ID
    , SUM(O.ORD_QTY) AS ORDER_QTY

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

    , SUM(O.SL_OPEN_CNFRM_QTY) AS SL_OPEN_CNFMR_QTY
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

    , ORD.MEAS_DT

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

    , CASE
        WHEN SL_TOT_OPEN_QTY > ORDER_QTY AND ORDER_QTY - SL_OPEN_CNFRM_QTY > 0
            THEN ORDER_QTY - SL_OPEN_CNFRM_QTY
        WHEN SL_TOT_OPEN_QTY > ORDER_QTY AND ORDER_QTY - SL_OPEN_CNFRM_QTY <= 0
            THEN 0
        ELSE ZEROIFNULL(OOL.UNCNFRM_QTY)
        END AS UNCONFIRMED_QTY
    , CASE
        WHEN SL_TOT_OPEN_QTY > ORDER_QTY
            THEN 0
        ELSE ZEROIFNULL(OOL.BACK_ORDER_QTY)
        END AS BACK_ORDERED_QTY

    , ZEROIFNULL(OOL.OPEN_CNFRM_QTY_CURR) AS OPEN_CONFIRMED_QTY_CURR
    , ZEROIFNULL(OOL.OPEN_CNFRM_QTY_FTR) AS OPEN_CONFIRMED_QTY_FTR

    , ZEROIFNULL(DIP.IN_PROC_QTY_CURR) AS IN_PROCESS_QTY_CURR
    , ZEROIFNULL(DIP.IN_PROC_QTY_FTR) AS IN_PROCESS_QTY_FTR
    , ZEROIFNULL(DLV.DELIV_QTY) AS ACTL_GOODS_ISS_QTY
    
    , ORDER_QTY - (CANCEL_QTY + WAIT_LISTED_QTY + UNCONFIRMED_QTY + BACK_ORDERED_QTY + OPEN_CONFIRMED_QTY_CURR + OPEN_CONFIRMED_QTY_FTR + IN_PROCESS_QTY_CURR + IN_PROCESS_QTY_FTR + ACTL_GOODS_ISS_QTY) AS NET_IMBALANCE_QTY

    , ZEROIFNULL(IN_PROCESS_QTY_CURR + IN_PROCESS_QTY_FTR + ACTL_GOODS_ISS_QTY) AS TOT_DN_QTY
    , ZEROIFNULL(TOT_OPEN_QTY) AS SL_TOT_OPEN_QTY

    , ZEROIFNULL(OOL.OPEN_CNFRM_QTY) AS SL_OPEN_CNFRM_QTY
    , ZEROIFNULL(OOL.UNCNFRM_QTY) AS SL_UNCNFRM_QTY
    , ZEROIFNULL(OOL.BACK_ORDER_QTY) AS SL_BACK_ORDER_QTY
    , ZEROIFNULL(OOL.DEFER_QTY) AS SL_DEFER_QTY
    , ZEROIFNULL(OOL.WAIT_LIST_QTY) AS SL_WAIT_LIST_QTY
    , ZEROIFNULL(OOL.OTHR_ORDER_QTY) AS SL_OTHR_ORDER_QTY
    , ZEROIFNULL(DIP.IN_PROC_QTY) AS SL_IN_PROC_QTY

FROM (

    SELECT
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , OD.ORDER_DT AS MEAS_DT
        --, CASE
            --WHEN OD.CUST_GRP2_CD = 'TLB'
                --THEN OD.ORDER_DT
            --ELSE OD.ORDER_LN_CRT_DT
            --END AS MEAS_DT

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
            WHEN C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336') OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD IN ('30', '31'))
                THEN 'REPL'
            ELSE 'OE'
            END AS OE_REPL_IND

        , OD.QTY_UNIT_MEAS_ID
        , MAX(OD.ORDER_QTY) AS ORD_QTY

    FROM GDYR_BI_VWS.GDYR_CAL ITM_CAL

        INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
            ON ITM_CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
            AND OD.PO_TYPE_ID <> 'RO'

        INNER JOIN GDYR_BI_VWS.GDYR_CAL PGI_CAL
            ON PGI_CAL.DAY_DATE = OD.PLN_GOODS_ISS_DT

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON M.MATL_ID = OD.MATL_ID
            AND M.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

    WHERE
        ITM_CAL.DAY_DATE BETWEEN CAST('2015-02-01' AS DATE) AND CURRENT_DATE-1
        AND ITM_CAL.DAY_DATE = MEAS_DT
        --AND OD.ORDER_CAT_ID = 'C'
        
        AND M.PBU_NBR IN ('01', '03')
        AND (
                C.SALES_ORG_CD IN('N301', 'N311', 'N321', 'N307', 'N317', 'N336', 'N302','N312','N322')
                OR (C.SALES_ORG_CD IN('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD IN('30', '31','32'))
            )

        -- AND OD.ORDER_FISCAL_YR = '2015'
        -- AND OD.ORDER_ID = '0088563150'
        -- AND OD.ORDER_LINE_NBR = 210

    GROUP BY
        OD.ORDER_FISCAL_YR
        , OD.ORDER_ID
        , OD.ORDER_LINE_NBR

        , MEAS_DT

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
                    DD.ORDER_FISCAL_YR
                    , DD.ORDER_ID
                    , DD.ORDER_LINE_NBR
                    , DD.DELIV_NOTE_CREA_DT

                    , DD.QTY_UNIT_MEAS_ID
                    , SUM(DD.DELIV_QTY) AS DELIV_QTY

                FROM NA_VWS.DELIV_DTL DD

                    INNER JOIN GDYR_BI_VWS.GDYR_CAL DN_CAL
                        ON DN_CAL.DAY_DATE BETWEEN DD.EFF_DT AND DD.EXP_DT

                WHERE
                    DN_CAL.DAY_DATE BETWEEN DATE '2015-02-01' AND CURRENT_DATE-1
                    AND DN_CAL.DAY_DATE = DD.DELIV_NOTE_CREA_DT
                    AND DN_CAL.DAY_DATE = DD.ACTL_GOODS_ISS_DT
                    --AND DD.DELIV_CAT_ID = 'J'
                    --AND DD.SD_DOC_CTGY_CD = 'C'

                GROUP BY
                    DD.ORDER_FISCAL_YR
                    , DD.ORDER_ID
                    , DD.ORDER_LINE_NBR
                    , DD.DELIV_NOTE_CREA_DT

                    , DD.QTY_UNIT_MEAS_ID
                ) DLV
            ON DLV.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
            AND DLV.ORDER_ID = ORD.ORDER_ID
            AND DLV.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
            AND DLV.DELIV_NOTE_CREA_DT = ORD.MEAS_DT

        LEFT OUTER JOIN (
            SELECT
                CAL.DAY_DATE
                , O.ORDER_FISCAL_YR
                , O.ORDER_ID
                , O.ORDER_LINE_NBR
                , SUM(O.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
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
                , SUM(O.OPEN_CNFRM_QTY) + SUM(O.UNCNFRM_QTY) + SUM(O.BACK_ORDER_QTY) + SUM(O.DEFER_QTY) + SUM(O.WAIT_LIST_QTY) + SUM(O.OTHR_ORDER_QTY) AS TOT_OPEN_QTY

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
                    ON CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_dT
                    AND OD.PO_TYPE_ID <> 'RO'

                INNER JOIN NA_VWS.OPEN_ORDER_SCHDLN O
                    ON CAL.DAY_DATE BETWEEN O.EFF_DT AND O.EXP_DT
                    AND O.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
                    AND O.ORDER_ID = OD.ORDER_ID
                    AND O.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
                    AND O.SCHED_LINE_NBR = OD.SCHED_LINE_NBR

                INNER JOIN GDYR_BI_VWS.GDYR_CAL PGI_CAL
                    ON PGI_CAL.DAY_DATE = OD.PLN_GOODS_ISS_DT

            WHERE
                CAL.DAY_DATE BETWEEN CAST('2015-02-01' AS DATE) AND CURRENT_DATE-1
                --AND OD.ORDER_CAT_ID = 'C'
                AND OD.ORDER_DT = CAL.DAY_DATE
                --AND (
                    --(OD.CUST_GRP2_CD = 'TLB' AND OD.ORDER_DT = CAL.DAY_DATE)
                    --OR (OD.CUST_GRP2_CD <> 'TLB' AND OD.ORDER_LN_CRT_DT = CAL.DAY_DATE)
                    --)

            GROUP BY
                CAL.DAY_DATE
                , O.ORDER_FISCAL_YR
                , O.ORDER_ID
                , O.ORDER_LINE_NBR
                
                ) OOL
            ON OOL.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
            AND OOL.ORDER_ID = ORD.ORDER_ID
            AND OOL.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
            AND OOL.DAY_DATE = ORD.MEAS_DT

        LEFT OUTER JOIN (
                SELECT
                    IP.ORDER_FISCAL_YR
                    , IP.ORDER_ID
                    , IP.ORDER_LINE_NBR
                    , CAL.DAY_DATE
                    , IP.SLS_QTY_UNIT_MEAS_ID
                    , SUM(IP.QTY_TO_SHIP) AS IN_PROC_QTY
                    , SUM(CASE
                        WHEN PGMV_CAL.MONTH_DT <= CAL.MONTH_DT
                            THEN IP.QTY_TO_SHIP
                        ELSE 0
                        END) AS IN_PROC_QTY_CURR
                    , SUM(CASE
                        WHEN PGMV_CAL.MONTH_DT > CAL.MONTH_DT
                            THEN IP.QTY_TO_SHIP
                        ELSE 0
                        END) AS IN_PROC_QTY_FTR

                FROM GDYR_VWS.DELIV_IN_PROC IP

                    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                        ON CAL.DAY_DATE BETWEEN IP.EFF_DT AND IP.EXP_DT

                    INNER JOIN NA_VWS.DELIV_DTL DD
                        ON DD.FISCAL_YR = IP.DELIV_FISCAL_YR
                        AND DD.DELIV_ID = IP.DELIV_ID
                        AND DD.DELIV_LINE_NBR = IP.DELIV_LINE_NBR
                        AND CAL.DAY_DATE BETWEEN DD.EFF_DT AND DD.EXP_DT
                        AND CAL.DAY_DATE = DD.DELIV_NOTE_CREA_DT
                        AND DD.ACTL_GOODS_ISS_DT IS NULL

                    INNER JOIN GDYR_BI_VWS.GDYR_CAL PGMV_CAL
                        ON PGMV_CAL.DAY_DATE = DD.PLN_GOODS_MVT_DT

                WHERE
                    IP.ORIG_SYS_ID = 2
                    AND IP.EXP_DT = CAST('5555-12-31' AS DATE)
                    AND IP.INTRA_CMPNY_FLG = 'N'
                    AND CAL.DAY_DATE BETWEEN CAST('2015-02-01' AS DATE) AND CURRENT_DATE-1
                    --AND DD.DELIV_CAT_ID = 'J'
                    --AND DD.SD_DOC_CTGY_CD = 'C'

                GROUP BY
                    IP.ORDER_FISCAL_YR
                    , IP.ORDER_ID
                    , IP.ORDER_LINE_NBR
                    , CAL.DAY_DATE
                    , IP.SLS_QTY_UNIT_MEAS_ID
                ) DIP
            ON DIP.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
            AND DIP.ORDER_ID = ORD.ORDER_ID
            AND DIP.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
            AND DIP.DAY_DATE = ORD.MEAS_DT

--WHERE
    --NET_IMBALANCE_QTY <> 0

--ORDER BY
    --ABS(NET_IMBALANCE_QTY) DESC
    ) O

WHERE
    O.PBU_NBR = '01'

GROUP BY
    O.MEAS_DT
    --, O.MATL_ID
    --, O.MATL_DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    --, O.CATEGORY_CD
    --, O.CATEGORY_NM
    --, O.OWN_CUST_ID
    --, O.OWN_CUST_NAME
    , O.OE_REPL_IND

    , O.QTY_UNIT_MEAS_ID

ORDER BY
    O.MEAS_DT
    , O.PBU_NBR
    --, O.CATEGORY_CD
    --, O.MATL_ID
    , O.OE_REPL_IND
    --, O.OWN_CUST_ID

