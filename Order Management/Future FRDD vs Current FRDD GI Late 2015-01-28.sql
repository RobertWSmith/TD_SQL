SELECT
    O.ITM_CRT_MONTH_DT
    , O.REQ_DELIV_DT_TYP_DESC
    , O.MATL_ID
    , O.DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    , O.MATL_STA_ID
    , O.MATL_STA_DT
    , O.MKT_CTGY_MKT_AREA_NBR
    , O.MKT_CTGY_MKT_AREA_NAME
    , O.FACILITY_ID
    , O.FACILITY_NAME
    --, O.OWN_CUST_ID
    --, O.OWN_CUST_NAME
    , O.QTY_UNIT_MEAS_ID
    , CRT.FTR_RDD_ORDER_QTY
    , O.AGID_AFTER_RDD_MTH_QTY
    , CASE
        WHEN CRT.FTR_RDD_ORDER_QTY < O.AGID_AFTER_RDD_MTH_QTY
            THEN CRT.FTR_RDD_ORDER_QTY
        ELSE O.AGID_AFTER_RDD_MTH_QTY
        END MIN_RPT_QTY

FROM (

    SELECT
        OL_CAL.MONTH_DT AS ITM_CRT_MONTH_DT
        --, RDD_CAL.MONTH_DT AS FRDD_MONTH_DT
        , CASE
            WHEN OL_CAL.MONTH_DT < RDD_CAL.MONTH_DT
                THEN 'Requested Future Month'
            ELSE 'Requested Same Month'
            END AS REQ_DELIV_DT_TYP_DESC

        , OD.MATL_ID
        , M.DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MATL_STA_ID
        , M.MATL_STA_DT
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME
        
        --, C.OWN_CUST_ID
        --, C.OWN_CUST_NAME

        , OD.FACILITY_ID
        , F.FACILITY_NAME

        , OD.QTY_UNIT_MEAS_ID
        , SUM(ZEROIFNULL(DLV.AGID_AFTER_ITM_QTY)) AS AGID_AFTER_RDD_MTH_QTY

    FROM NA_BI_VWS.ORDER_DETAIL OD

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
            ON M.MATL_ID = OD.MATL_ID
            AND M.MATL_TYPE_ID = 'PCTL'
            AND M.EXT_MATL_GRP_ID = 'TIRE'
            AND M.PBU_NBR = '01'

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
            ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

        INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
            ON F.FACILITY_ID = OD.FACILITY_ID
            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND F.DISTR_CHAN_CD = '81'
            AND F.FACILITY_ID NOT IN ('N5US', 'N5CA')

        INNER JOIN GDYR_BI_VWS.GDYR_CAL OL_CAL
            ON OL_CAL.DAY_DATE = OD.ORDER_LN_CRT_DT

        INNER JOIN GDYR_BI_VWS.GDYR_CAL RDD_CAL
            ON RDD_CAL.DAY_DATE = OD.FRST_PLN_GOODS_ISS_DT

        INNER JOIN (
                SELECT
                    DD.ORDER_FISCAL_YR
                    , DD.ORDER_ID
                    , DD.ORDER_LINE_NBR
                    , SUM(DD.DELIV_QTY) AS AGID_AFTER_ITM_QTY

                FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DD

                    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
                        ON OD.ORDER_FISCAL_YR = DD.ORDER_FISCAL_YR
                        AND OD.ORDER_ID = DD.ORDER_ID
                        AND OD.ORDER_LINE_NBR = DD.ORDER_LINE_NBR
                        AND OD.SCHED_LINE_NBR = 1
                        AND OD.EXP_DT = CAST('5555-12-31' AS DATE)
                        AND OD.ORDER_CAT_ID = 'C'
                        AND OD.RO_PO_TYPE_IND = 'N'
                        AND OD.ORDER_LN_CRT_DT >= CAST('2014-01-01' AS DATE)

                    INNER JOIN GDYR_BI_VWS.GDYR_CAL AGID_CAL
                        ON AGID_CAL.DAY_DATE = DD.ACTL_GOODS_ISS_DT

                    INNER JOIN GDYR_BI_VWS.GDYR_CAL RDD_CAL
                        ON RDD_CAL.DAY_DATE = OD.FRST_PLN_GOODS_ISS_DT

                WHERE
                    DD.DELIV_LINE_CREA_DT >= CAST('2014-01-01' AS DATE)
                    AND DD.DELIV_CAT_ID = 'J'
                    AND DD.SD_DOC_CTGY_CD = 'C'
                    AND DD.GOODS_ISS_IND = 'Y'
                    -- AGID MONTH IS AFTER THE FRDD FPGI MONTH
                    AND AGID_CAL.MONTH_DT > RDD_CAL.MONTH_DT

                GROUP BY
                    DD.ORDER_FISCAL_YR
                    , DD.ORDER_ID
                    , DD.ORDER_LINE_NBR

                ) DLV
            ON DLV.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
            AND DLV.ORDER_ID = OD.ORDER_ID
            AND DLV.ORDER_LINE_NBR = OD.ORDER_LINE_NBR

    WHERE
        OD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.SCHED_LINE_NBR = 1
        AND OD.ORDER_LN_CRT_DT BETWEEN CAST('2014-01-01' AS DATE) AND CURRENT_DATE-1

        -- ITEM CREATE MONTH IS THE SAME AS THE FRDD MONTH
        AND OL_CAL.MONTH_DT = RDD_CAL.MONTH_DT

        AND (C.SALES_ORG_CD, C.DISTR_CHAN_CD, C.CUST_GRP_ID, M.PBU_NBR) IN (
            SELECT
                SALES_ORG_CD
                , DISTR_CHAN_CD
                , CUST_GRP_ID
                , PBU_NBR
            FROM NA_BI_VWS.SCM_CUST_GRP_CURR
            WHERE
                TIRE_CUST_TYP_CD IS NULL
                OR TIRE_CUST_TYP_CD IN ('REPL', 'NA')
        )

    GROUP BY
        ITM_CRT_MONTH_DT
        --, FRDD_MONTH_DT
        , REQ_DELIV_DT_TYP_DESC
        , OD.MATL_ID
        , M.DESCR
        , M.PBU_NBR
        , M.PBU_NAME
        , M.MATL_STA_ID
        , M.MATL_STA_DT
        , M.MKT_CTGY_MKT_AREA_NBR
        , M.MKT_CTGY_MKT_AREA_NAME
        , OD.FACILITY_ID
        , F.FACILITY_NAME
        --, C.OWN_CUST_ID
        --, C.OWN_CUST_NAME
        , OD.QTY_UNIT_MEAS_ID

/*    HAVING
        AGID_AFTER_RDD_MTH_QTY <> 0*/

    ) O

    INNER JOIN (
            SELECT
                OL_CAL.MONTH_DT AS ITM_CRT_MONTH_DT
                , OD.MATL_ID
                , OD.FACILITY_ID
                --, C.OWN_CUST_ID

                , OD.QTY_UNIT_MEAS_ID
                , SUM(CASE
                    WHEN ZEROIFNULL(DLV.ITM_QTY) > OD.ORDER_QTY
                        THEN ZEROIFNULL(DLV.ITM_QTY)
                    WHEN OD.REJ_REAS_ID <> '' 
                        THEN OD.ORDER_QTY - ZEROIFNULL(DLV.ITM_QTY)
                    ELSE OD.ORDER_QTY
                    END) AS FTR_RDD_ORDER_QTY

            FROM NA_BI_VWS.ORDER_DETAIL OD

                INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                    ON M.MATL_ID = OD.MATL_ID
                    AND M.MATL_TYPE_ID = 'PCTL'
                    AND M.EXT_MATL_GRP_ID = 'TIRE'
                    AND M.PBU_NBR = '01'

                INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
                    ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

                INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = OD.FACILITY_ID
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.DISTR_CHAN_CD = '81'
                    AND F.FACILITY_ID NOT IN ('N5US', 'N5CA')

                INNER JOIN GDYR_BI_VWS.GDYR_CAL OL_CAL
                    ON OL_CAL.DAY_DATE = OD.ORDER_LN_CRT_DT

                INNER JOIN GDYR_BI_VWS.GDYR_CAL RDD_CAL
                    ON RDD_CAL.DAY_DATE = OD.FRST_PLN_GOODS_ISS_DT

                LEFT OUTER JOIN (
                        SELECT
                            DD.ORDER_FISCAL_YR
                            , DD.ORDER_ID
                            , DD.ORDER_LINE_NBR
                            , SUM(DD.DELIV_QTY) AS ITM_QTY

                        FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DD

                        WHERE
                            DD.DELIV_LINE_CREA_DT >= CAST('2014-01-01' AS DATE)
                            AND DD.DELIV_CAT_ID = 'J'
                            AND DD.SD_DOC_CTGY_CD = 'C'

                        GROUP BY
                            DD.ORDER_FISCAL_YR
                            , DD.ORDER_ID
                            , DD.ORDER_LINE_NBR
                        ) DLV
                    ON DLV.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
                    AND DLV.ORDER_ID = OD.ORDER_ID
                    AND DLV.ORDER_LINE_NBR = OD.ORDER_LINE_NBR

            WHERE
                OD.EXP_DT = CAST('5555-12-31' AS DATE)
                AND OD.ORDER_CAT_ID = 'C'
                AND OD.RO_PO_TYPE_IND = 'N'
                AND OD.SCHED_LINE_NBR = 1
                AND OD.ORDER_LN_CRT_DT >= CAST('2014-01-01' AS DATE)

                AND OD.FRST_PROM_DELIV_DT IS NOT NULL
                AND OD.FRST_PROM_DELIV_DT <= OD.FRST_RDD

                AND OL_CAL.MONTH_DT < RDD_CAL.MONTH_DT
                AND OL_CAL.DAY_OF_MONTH <= (OL_CAL.TTL_DAYS_IN_MNTH-8)

                AND (C.SALES_ORG_CD, C.DISTR_CHAN_CD, C.CUST_GRP_ID, M.PBU_NBR) IN (
                    SELECT
                        SALES_ORG_CD
                        , DISTR_CHAN_CD
                        , CUST_GRP_ID
                        , PBU_NBR
                    FROM NA_BI_VWS.SCM_CUST_GRP_CURR
                    WHERE
                        TIRE_CUST_TYP_CD IS NULL
                        OR TIRE_CUST_TYP_CD IN ('REPL', 'NA')
                )

            GROUP BY
                ITM_CRT_MONTH_DT
                , OD.MATL_ID
                , OD.FACILITY_ID
                --, C.OWN_CUST_ID

                , OD.QTY_UNIT_MEAS_ID
    
/*            HAVING
                FTR_RDD_ORDER_QTY >= 0*/
    
            ) CRT
        ON CRT.ITM_CRT_MONTH_DT = O.ITM_CRT_MONTH_DT
        AND CRT.MATL_ID = O.MATL_ID
        AND CRT.FACILITY_ID = O.FACILITY_ID
        --AND CRT.OWN_CUST_ID = O.OWN_CUST_ID
