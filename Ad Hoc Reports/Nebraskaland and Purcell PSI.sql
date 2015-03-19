SELECT
    OTD.PBU
    , OTD.MATL_ID
    , OTD.MATL_DESCR
    , OTD.SAL_IND
    , OTD.PAL_IND
    , OTD.TIER
    
    , OTD.CATEGORY
    , OTD.SEGMENT
    , OTD.PROD_LINE
    
    , OTD.METRIC_ORDER_QTY
    , OTD.METRIC_HIT_QTY
    , OTD.METRIC_ONTIME_QTY
    , CAST(OTD.METRIC_ONTIME_QTY AS DECIMAL(18,6)) / NULLIFZERO(CAST(OTD.METRIC_ORDER_QTY AS DECIMAL(18,6))) AS METRIC_ONTIME_PCT
    , OTD.NO_STOCK_HIT_QTY
    , OTD.CANCEL_HIT_QTY
    , OTD.NO_STOCK_AND_CANCEL_HIT_QTY
    
    , ZEROIFNULL(INV.CURRENT_ATP_QTY) AS CURRENT_ATP_QTY
    , ZEROIFNULL(INV.MIN_ATP_QTY) AS MIN_ATP_QTY
    , ZEROIFNULL(INV.AVG_ATP_QTY) AS AVG_ATP_QTY
    , ZEROIFNULL(INV.MEDIAN_ATP_QTY) AS MEDIAN_ATP_QTY
    , ZEROIFNULL(INV.MAX_ATP_QTY) AS MAX_ATP_QTY
                    
    , ZEROIFNULL(OPN.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , ZEROIFNULL(OPN.UNCNFRM_QTY) AS UNCNFRM_QTY
    
    --, ZEROIFNULL(DP.DP_LAG0) AS DP_LAG0
    , ZEROIFNULL(SOP.OFFCL_SOP_LAG0) AS OFFCL_SOP_LAG0
    , ZEROIFNULL(PCD.MTD_PROD_QTY) AS MTD_PROD_QTY
    , ZEROIFNULL(PPD.CURR_MTH_PLAN_QTY / CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(15,3))) AS MTD_PROD_PLN_QTY
    , ZEROIFNULL(PPD.CURR_MTH_PLAN_QTY) AS CURR_MTH_TOT_PLAN_QTY
    , ZEROIFNULL(DLV.CURR_MTH_DELIV_QTY) AS CURR_MTH_DELIV_QTY
    
    --, ZEROIFNULL(DP.DP_LAG1) AS DP_LAG1
    , ZEROIFNULL(SOP.OFFCL_SOP_LAG1) AS OFFCL_SOP_LAG1
    , ZEROIFNULL(PCD.PRIOR_MTH_PROD_QTY) AS PRIOR_MTH_PROD_QTY
    , ZEROIFNULL(PPD.PRIOR_MTH_PLAN_QTY) AS PRIOR_MTH_PLAN_QTY
    , ZEROIFNULL(DLV.PRIOR_MTH_DELIV_QTY) AS PRIOR_MTH_DELIV_QTY    

FROM (
    SELECT
        POL.MATL_ID
        , MATL.PBU_NBR
        , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
        , MATL.SAL_IND
        , MATL.MATL_PRTY
        , MATL.MKT_CTGY_PROD_GRP_NAME AS TIER
        , PAL.PAL_IND
        , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU
        , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS CATEGORY
        , MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS SEGMENT
        , MATL.PROD_LINE_NBR || ' - ' || MATL.PROD_LINE_NAME AS PROD_LINE
        , CAST(CASE WHEN MATL.SOP_FAMILY_ID > 99 THEN 99 ELSE MATL.SOP_FAMILY_ID END AS FORMAT '-9(2)') || ' - ' || MATL.SOP_FAMILY_NM AS SOP_FAMILY
        , SUM(ZEROIFNULL(POL.CURR_ORD_QTY)) AS METRIC_ORDER_QTY
        , SUM(ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS METRIC_HIT_QTY
        , SUM(ZEROIFNULL(POL.CURR_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS METRIC_ONTIME_QTY
        , SUM(ZEROIFNULL(POL.IF_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
        , SUM(ZEROIFNULL(POL.IF_HIT_CO_QTY)) AS CANCEL_HIT_QTY
        , NO_STOCK_HIT_QTY + CANCEL_HIT_QTY AS NO_STOCK_AND_CANCEL_HIT_QTY
        
    FROM NA_BI_VWS.PRFCT_ORD_LINE POL
    
        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = POL.MATL_ID
            AND MATL.EXT_MATL_GRP_ID = 'TIRE'
            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
            
        LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_PAL_CURR PAL
            ON PAL.MATL_ID = MATL.MATL_ID
            
    WHERE
        POL.CMPL_DT BETWEEN (CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1) AND CURRENT_DATE-1
        AND POL.CMPL_IND = 1
        AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99
        AND POL.PO_TYPE_ID <> 'RO'
        AND POL.CUST_GRP_ID <> '3R'
        
    GROUP BY
        POL.MATL_ID
        , MATL.PBU_NBR
        , MATL_DESCR
        , MATL.SAL_IND
        , MATL.MATL_PRTY
        , MATL.MKT_CTGY_PROD_GRP_NAME
        , PAL.PAL_IND
        , PBU
        , CATEGORY
        , SEGMENT
        , PROD_LINE
        , SOP_FAMILY
    ) OTD    

/*    LEFT OUTER JOIN (
            SELECT
                A.MATL_ID
                , SUM(CASE WHEN A.LAG_DESC = 0 THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS DP_LAG0
                , SUM(CASE WHEN A.LAG_DESC = 1 THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS DP_LAG1
            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A
            WHERE
                A.LAG_DESC IN ('0', '1')
                AND A.PERD_BEGIN_MTH_DT = (CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1)
                AND A.OFFCL_SOP_SLS_PLN_QTY > 0
            GROUP BY
                A.MATL_ID
                ) DP
            ON DP.MATL_ID = OTD.MATL_ID*/

    LEFT OUTER JOIN (
        SELECT
            A.MATL_ID
            , ZEROIFNULL(SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 0') THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS OFFCL_SOP_LAG0
            , ZEROIFNULL(SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 1') THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS OFFCL_SOP_LAG1
        FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A
        WHERE
            A.DP_LAG_DESC IN ('LAG 0', 'LAG 1')
            AND A.PERD_BEGIN_MTH_DT = (CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1)
            AND A.OFFCL_SOP_SLS_PLN_QTY > 0
        GROUP BY
            A.MATL_ID
            ) SOP
        ON SOP.MATL_ID = OTD.MATL_ID

        LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID
                , SUM(ZEROIFNULL(OOL.OPEN_CNFRM_QTY)) AS OPEN_CNFRM_QTY
                , SUM(ZEROIFNULL(OOL.UNCNFRM_QTY) + ZEROIFNULL(OOL.BACK_ORDER_QTY)) UNCNFRM_QTY
            FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL
                INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
                    ON ODC.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
                    AND ODC.ORDER_ID = OOL.ORDER_ID
                    AND ODC.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
                    AND ODC.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
                    AND ODC.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                    AND ODC.ORDER_CAT_ID = 'C'
                    AND ODC.PO_TYPE_ID <> 'RO'
            WHERE
                OOL.OPEN_CNFRM_QTY > 0
                OR OOL.UNCNFRM_QTY > 0
                OR OOL.BACK_ORDER_QTY > 0
            GROUP BY
                ODC.MATL_ID
                ) OPN
            ON OPN.MATL_ID = OTD.MATL_ID

        LEFT OUTER JOIN (
                SELECT
                    MATL_ID
                    , SUM(CASE
                        WHEN PROD_DT / 100 = (CURRENT_DATE-1) / 100
                            THEN ZEROIFNULL(PROD_QTY)
                        ELSE 0
                        END) AS MTD_PROD_QTY
                    , SUM(CASE
                        WHEN PROD_DT / 100 = ADD_MONTHS((CURRENT_DATE-1), -1) / 100
                            THEN ZEROIFNULL(PROD_QTY)
                        ELSE 0
                        END) AS PRIOR_MTH_PROD_QTY
                FROM NA_BI_VWS.PROD_CREDIT_DY
                WHERE
                    PROD_DT >= ADD_MONTHS((CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1), -1)
                GROUP BY
                    MATL_ID
                ) PCD
            ON PCD.MATL_ID = OTD.MATL_ID

        LEFT OUTER JOIN (
                SELECT
                    PLN_MATL_ID AS MATL_ID
                    , CAST(SUM(CASE
                        WHEN REF_DT / 100 = (CURRENT_DATE-1) / 100
                            THEN ZEROIFNULL(PLAN_QTY)
                        ELSE 0
                        END) AS DECIMAL(15,3)) AS CURR_MTH_PLAN_QTY
                    , CAST(SUM(CASE
                        WHEN REF_DT / 100 = ADD_MONTHS((CURRENT_DATE-1), -1) / 100
                            THEN ZEROIFNULL(PLAN_QTY)
                        ELSE 0
                        END) AS DECIMAL(15,3)) AS PRIOR_MTH_PLAN_QTY
                FROM NA_BI_VWS.PROD_PLN_DY_LVL
                WHERE
                    REF_DT BETWEEN ADD_MONTHS((CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1), -1)
                        AND ADD_MONTHS((CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1), 1) - 1
                GROUP BY
                    PLN_MATL_ID
                ) PPD
            ON PPD.MATL_ID = OTD.MATL_ID

        LEFT OUTER JOIN (
                SELECT
                    MATL_ID
                    , MAX(CASE
                        WHEN DAY_DT = CURRENT_DATE-1
                            THEN ATP_QTY
                        ELSE 0
                        END) AS CURRENT_ATP_QTY
                    , MIN(ATP_QTY) AS MIN_ATP_QTY
                    , AVERAGE(ATP_QTY) AS AVG_ATP_QTY
                    , MEDIAN(ATP_QTY) AS MEDIAN_ATP_QTY
                    , MAX(ATP_QTY) AS MAX_ATP_QTY
                FROM (
                SELECT
                    MATL_ID
                    , DAY_DT
                    , SUM(AVAIL_TO_PROM_QTY) AS ATP_QTY
                FROM NA_BI_VWS.FACILITY_MATL_INVENTORY
                WHERE
                    DAY_DT >= CURRENT_DATE-60
                GROUP BY
                    MATL_ID
                    , DAY_DT
                    ) Q
                GROUP BY
                    MATL_ID
                ) INV
            ON INV.MATL_ID = OTD.MATL_ID

        LEFT OUTER JOIN ( 
                SELECT
                    D.MATL_ID
                    , SUM(CASE
                        WHEN D.ACTL_GOODS_ISS_DT / 100 = (CURRENT_DATE-1) / 100
                            THEN D.DELIV_QTY
                        ELSE 0
                        END) AS CURR_MTH_DELIV_QTY
                    , SUM(CASE
                        WHEN D.ACTL_GOODS_ISS_DT / 100 = ADD_MONTHS(CURRENT_DATE-1, -1) / 100
                            THEN D.DELIV_QTY
                        ELSE 0
                        END) AS PRIOR_MTH_DELIV_QTY
                FROM NA_BI_VWS.DELIVERY_DETAIL_CURR D
                    INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR O
                        ON O.ORDER_FISCAL_YR = D.ORDER_FISCAL_YR
                        AND O.ORDER_ID = D.ORDER_ID
                        AND O.ORDER_LINE_NBR = D.ORDER_LINE_NBR
                        AND O.SCHED_LINE_NBR = 1
                        AND O.ORDER_CAT_ID = 'C'
                        AND O.RO_PO_TYPE_IND = 'N'
                        AND O.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                WHERE
                    D.GOODS_ISS_IND = 'Y'
                    AND D.ACTL_GOODS_ISS_DT IS NOT NULL
                    AND D.ACTL_GOODS_ISS_DT >= ADD_MONTHS((CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1), -1)
                    AND D.DELIV_CAT_ID = 'J'
                    AND D.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 AS CHAR(4))
                GROUP BY
                    D.MATL_ID
                ) DLV
            ON DLV.MATL_ID = OTD.MATL_ID

    INNER JOIN (
            SELECT
                DAY_DATE
                , TTL_DAYS_IN_MNTH
            FROM GDYR_BI_VWS.GDYR_CAL
            WHERE
                DAY_DATE = CURRENT_DATE-1
            ) CAL
        ON 1=1

QUALIFY
    PBU_RANK <= 50

