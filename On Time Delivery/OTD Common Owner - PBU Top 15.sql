SELECT
    TQ.METRIC_TYPE
    , TQ.COMPLETE_MTH
    , TQ.QUARTER
    , TQ.MONTH_NAME
    , TQ.PBU_NBR
    , TQ.PBU
    , TQ.CATEGORY
    , TQ.CATEGORY_NAME
    , TQ.TIER
    , TQ.CATEGORY_TIER
    , TQ.EXT_MATL_GRP_ID
    , TQ.OWN_CUST
    , TQ.OWN_CUST_NAME
    , TQ.TIRE_CUST_TYP_CD
    , TQ.TARGET_NUMERATOR
    , TQ.TARGET_DENOMINATOR
    , TQ.ORDER_QTY
    , TQ.HIT_QTY
    , TQ.ONTIME_QTY
    , TQ.SUPPLY_HIT_QTY
    , TQ.POLICY_HIT_QTY
    , TQ.TOT_OTHER_HIT_QTY
    , TQ.RETURN_HIT_QTY
    , TQ.CLAIM_HIT_QTY
    , TQ.FREIGHT_POLICY_HIT_QTY
    , TQ.PHYS_LOG_HIT_QTY
    , TQ.MAN_BLK_HIT_QTY
    , TQ.CREDIT_HOLD_HIT_QTY
    , TQ.NO_STOCK_HIT_QTY
    , TQ.CANCEL_HIT_QTY
    , TQ.CUST_GEN_HIT_QTY
    , TQ.MAN_REL_CUST_GEN_HIT_QTY
    , TQ.MAN_REL_HIT_QTY
    , TQ.OTHER_HIT_QTY
    , TQ.OWN_CUST_RNK
    , SUM(TQ.ORDER_QTY) OVER (PARTITION BY TQ.METRIC_TYPE, TQ.COMPLETE_MTH, TQ.PBU_NBR, TQ.EXT_MATL_GRP_ID, TQ.TIRE_CUST_TYP_CD) AS MTH_PBU_ORDER_QTY
    , TQ.CO_DELIV_QTY
    , TQ.MTH_DELIV_QTY

FROM (

    SELECT
        SQ.METRIC_TYPE
        , SQ.COMPLETE_MTH
        , SQ.QUARTER
        , SQ.MONTH_NAME
        , SQ.PBU_NBR
        , SQ.PBU
        , SQ.CATEGORY
        , SQ.CATEGORY_NAME
        , SQ.TIER
        , SQ.CATEGORY_TIER
        , SQ.EXT_MATL_GRP_ID
        , SQ.OWN_CUST
        , SQ.OWN_CUST_NAME
        , SQ.TIRE_CUST_TYP_CD

        , SQ.TARGET_NUMERATOR
        , SQ.TARGET_DENOMINATOR

        , SUM(SQ.ORDER_QTY) AS ORDER_QTY
        , SUM(SQ.HIT_QTY) AS HIT_QTY
        , SUM(SQ.ONTIME_QTY) AS ONTIME_QTY

        , SUM(SQ.SUPPLY_HIT_QTY) AS SUPPLY_HIT_QTY
        , SUM(SQ.POLICY_HIT_QTY) AS POLICY_HIT_QTY
        , SUM(SQ.TOT_OTHER_HIT_QTY) AS TOT_OTHER_HIT_QTY

        , SUM(SQ.RETURN_HIT_QTY) AS RETURN_HIT_QTY
        , SUM(SQ.CLAIM_HIT_QTY) AS CLAIM_HIT_QTY
        , SUM(SQ.FREIGHT_POLICY_HIT_QTY) AS FREIGHT_POLICY_HIT_QTY
        , SUM(SQ.PHYS_LOG_HIT_QTY) AS PHYS_LOG_HIT_QTY
        , SUM(SQ.MAN_BLK_HIT_QTY) AS MAN_BLK_HIT_QTY
        , SUM(SQ.CREDIT_HOLD_HIT_QTY) AS CREDIT_HOLD_HIT_QTY
        , SUM(SQ.NO_STOCK_HIT_QTY) AS NO_STOCK_HIT_QTY
        , SUM(SQ.CANCEL_HIT_QTY) AS CANCEL_HIT_QTY
        , SUM(SQ.CUST_GEN_HIT_QTY) AS CUST_GEN_HIT_QTY
        , SUM(SQ.MAN_REL_CUST_GEN_HIT_QTY) AS MAN_REL_CUST_GEN_HIT_QTY
        , SUM(SQ.MAN_REL_HIT_QTY) AS MAN_REL_HIT_QTY
        , SUM(SQ.OTHER_HIT_QTY) AS OTHER_HIT_QTY

        , SQ.OWN_CUST_RNK
        , SUM(SQ.CO_DELIV_QTY) AS CO_DELIV_QTY
        , SQ.MTH_DELIV_QTY

    FROM (

    SELECT
        Q.METRIC_TYPE
        , Q.COMPLETE_MTH
        , Q.QUARTER
        , CAST(Q.COMPLETE_MTH AS FORMAT 'Mmm') (CHAR(3)) AS MONTH_NAME
        , Q.PBU_NBR
        , Q.PBU
        , Q.CATEGORY
        , Q.CATEGORY_NAME
        , Q.TIER
        , Q.CATEGORY_TIER
        , Q.EXT_MATL_GRP_ID
        , CASE
            WHEN DD.OWN_CUST_RNK <= 15
                THEN Q.OWN_CUST_ID || ' - ' || Q.OWN_CUST_NAME
            ELSE 'Other'
            END AS OWN_CUST
        , CASE
           WHEN DD.OWN_CUST_RNK <= 15
                THEN Q.OWN_CUST_NAME
            ELSE 'Other'
            END AS OWN_CUST_NAME
        , Q.TIRE_CUST_TYP_CD

        , Q.TARGET_NUMERATOR
        , Q.TARGET_DENOMINATOR

        , Q.ORDER_QTY
        , Q.YTD_ORDER_QTY
        , Q.HIT_QTY
        , Q.ONTIME_QTY

        , Q.SUPPLY_HIT_QTY
        , Q.POLICY_HIT_QTY
        , Q.TOT_OTHER_HIT_QTY

        , Q.RETURN_HIT_QTY
        , Q.CLAIM_HIT_QTY
        , Q.FREIGHT_POLICY_HIT_QTY
        , Q.PHYS_LOG_HIT_QTY
        , Q.MAN_BLK_HIT_QTY
        , Q.CREDIT_HOLD_HIT_QTY
        , Q.NO_STOCK_HIT_QTY
        , Q.CANCEL_HIT_QTY
        , Q.CUST_GEN_HIT_QTY
        , Q.MAN_REL_CUST_GEN_HIT_QTY
        , Q.MAN_REL_HIT_QTY
        , Q.OTHER_HIT_QTY

        , CASE
            WHEN DD.OWN_CUST_RNK <= 15
                THEN DD.OWN_CUST_RNK
            ELSE 16
            END AS OWN_CUST_RNK
        , ZEROIFNULL(DD.CO_DELIV_QTY) AS CO_DELIV_QTY
        , ZEROIFNULL(DD.MTH_DELIV_QTY) AS MTH_DELIV_QTY
        
    FROM (

    SELECT
        OTD.METRIC_TYPE
        , OTD.COMPLETE_MTH
        , CAL.QUARTER
        , CAL.YEAR_SLASH_QTR
        , CAL.MNTH_NAME_ABBREV
        , OTD.PBU_NBR
        , OTD.PBU
        , OTD.CATEGORY
        , OTD.CATEGORY_NAME
        , OTD.TIER
        , OTD.CATEGORY_NAME || ' (' || OTD.TIER || ')' AS CATEGORY_TIER
        , OTD.EXT_MATL_GRP_ID
        , OTD.OWN_CUST_ID
        , OTD.OWN_CUST_NAME
        , OTD.TIRE_CUST_TYP_CD

        , CAST(CASE WHEN OTD.METRIC_TYPE = 'FRDD' THEN 7.5 ELSE 9 END AS DECIMAL(15,3)) AS TARGET_NUMERATOR
        , CAST(10 AS DECIMAL(15,3)) AS TARGET_DENOMINATOR

        , OTD.ORDER_QTY
        , SUM(OTD.ORDER_QTY) OVER (PARTITION BY OTD.METRIC_TYPE, OTD.PBU_NBR, OTD.EXT_MATL_GRP_ID) AS YTD_ORDER_QTY
        , OTD.HIT_QTY
        , OTD.ONTIME_QTY

        , OTD.NO_STOCK_HIT_QTY + OTD.CANCEL_HIT_QTY AS SUPPLY_HIT_QTY
        , OTD.CREDIT_HOLD_HIT_QTY + OTD.FREIGHT_POLICY_HIT_QTY + OTD.MAN_BLK_HIT_QTY AS POLICY_HIT_QTY
        , OTD.RETURN_HIT_QTY + OTD.CLAIM_HIT_QTY + OTD.CUST_GEN_HIT_QTY + OTD.MAN_REL_CUST_GEN_HIT_QTY + OTD.MAN_REL_HIT_QTY + OTD.OTHER_HIT_QTY AS TOT_OTHER_HIT_QTY

        , OTD.RETURN_HIT_QTY
        , OTD.CLAIM_HIT_QTY
        , OTD.FREIGHT_POLICY_HIT_QTY
        , OTD.PHYS_LOG_HIT_QTY
        , OTD.MAN_BLK_HIT_QTY
        , OTD.CREDIT_HOLD_HIT_QTY
        , OTD.NO_STOCK_HIT_QTY
        , OTD.CANCEL_HIT_QTY
        , OTD.CUST_GEN_HIT_QTY
        , OTD.MAN_REL_CUST_GEN_HIT_QTY
        , OTD.MAN_REL_HIT_QTY
        , OTD.OTHER_HIT_QTY

    FROM (

        SELECT
            CAST('FRDD' AS CHAR(4)) AS METRIC_TYPE
            , POL.CMPL_DT - (EXTRACT(DAY FROM POL.CMPL_DT) - 1) AS COMPLETE_MTH
            , MATL.PBU_NBR
            , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME
                ELSE MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME
              END  AS CATEGORY
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_MKT_AREA_NAME
                ELSE MATL.MKT_CTGY_MKT_GRP_NAME
                END AS CATEGORY_NAME
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_PROD_GRP_NAME
                ELSE MATL.TIERS
              END AS TIER
            , MATL.EXT_MATL_GRP_ID
            , CUST.OWN_CUST_ID
            , CUST.OWN_CUST_NAME
            , CUST.TIRE_CUST_TYP_CD

            , SUM(ZEROIFNULL(POL.CURR_ORD_QTY)) AS ORDER_QTY
            , SUM(ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS HIT_QTY
            , SUM(ZEROIFNULL(POL.CURR_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS ONTIME_QTY

            , SUM(ZEROIFNULL(POL.NE_HIT_RT_QTY)) AS RETURN_HIT_QTY
            , SUM(ZEROIFNULL(POL.NE_HIT_CL_QTY)) AS CLAIM_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_FP_QTY)) AS FREIGHT_POLICY_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_CARR_PICKUP_QTY) + ZEROIFNULL(POL.OT_HIT_WI_QTY)) AS PHYS_LOG_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_MB_QTY)) AS MAN_BLK_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_CH_QTY)) AS CREDIT_HOLD_HIT_QTY
            , SUM(ZEROIFNULL(POL.IF_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
            , SUM(ZEROIFNULL(POL.IF_HIT_CO_QTY)) AS CANCEL_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_CG_QTY)) AS CUST_GEN_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_CG_99_QTY)) AS MAN_REL_CUST_GEN_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_99_QTY)) AS MAN_REL_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_HIT_LO_QTY)) AS OTHER_HIT_QTY

        FROM NA_BI_VWS.PRFCT_ORD_LINE POL

            INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
                ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID
                AND CUST.CUST_GRP_ID <> '3R'

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = POL.MATL_ID
                AND MATL.PBU_NBR IN ('01', '03')
                AND MATL.EXT_MATL_GRP_ID = 'TIRE'
                --AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')

        WHERE
            POL.CMPL_IND = 1
            AND POL.CMPL_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) AND CURRENT_DATE-1
            AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99

        GROUP BY
            METRIC_TYPE
            , COMPLETE_MTH
            , MATL.PBU_NBR
            , PBU
            , CATEGORY
            , CATEGORY_NAME
            , TIER
            , MATL.EXT_MATL_GRP_ID
            , CUST.OWN_CUST_ID
            , CUST.OWN_CUST_NAME
            , CUST.TIRE_CUST_TYP_CD

        UNION ALL

        SELECT
            CAST('FCDD' AS CHAR(4)) AS METRIC_TYPE
            , POL.FPDD_CMPL_DT - (EXTRACT(DAY FROM POL.FPDD_CMPL_DT) - 1) AS COMPLETE_MTH
            , MATL.PBU_NBR
            , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME
                ELSE MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME
              END  AS CATEGORY
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_MKT_AREA_NAME
                ELSE MATL.MKT_CTGY_MKT_GRP_NAME
                END AS CATEGORY_NAME
            , CASE
                WHEN MATL.PBU_NBR = '01'
                    THEN MATL.MKT_CTGY_PROD_GRP_NAME
                ELSE MATL.TIERS
              END AS TIER
            , MATL.EXT_MATL_GRP_ID
            , CUST.OWN_CUST_ID
            , CUST.OWN_CUST_NAME
            , CUST.TIRE_CUST_TYP_CD

            , SUM(ZEROIFNULL(POL.FPDD_ORD_QTY)) AS ORDER_QTY
            , SUM(ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY)) AS HIT_QTY
            , SUM(ZEROIFNULL(POL.FPDD_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY)) AS ONTIME_QTY

            , SUM(ZEROIFNULL(POL.NE_FPDD_HIT_RT_QTY)) AS RETURN_HIT_QTY
            , SUM(ZEROIFNULL(POL.NE_FPDD_HIT_CL_QTY)) AS CLAIM_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_FP_QTY)) AS FREIGHT_POLICY_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_CARR_QTY) + ZEROIFNULL(POL.OT_FPDD_HIT_WI_QTY)) AS PHYS_LOG_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_MB_QTY)) AS MAN_BLK_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_CH_QTY)) AS CREDIT_HOLD_HIT_QTY
            , SUM(ZEROIFNULL(POL.IF_FPDD_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
            , SUM(ZEROIFNULL(POL.IF_FPDD_HIT_CO_QTY)) AS CANCEL_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_CG_QTY)) AS CUST_GEN_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_CG_99_QTY)) AS MAN_REL_CUST_GEN_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_99_QTY)) AS MAN_REL_HIT_QTY
            , SUM(ZEROIFNULL(POL.OT_FPDD_HIT_LO_QTY)) AS OTHER_HIT_QTY

        FROM NA_BI_VWS.PRFCT_ORD_LINE POL

            INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
                ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID
                AND CUST.CUST_GRP_ID <> '3R'

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = POL.MATL_ID
                AND MATL.PBU_NBR IN ('01', '03')
                AND MATL.EXT_MATL_GRP_ID = 'TIRE'
                --AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')

        WHERE
            POL.FPDD_CMPL_IND = 1
            AND POL.FRST_PROM_DELIV_DT IS NOT NULL
            AND POL.FPDD_CMPL_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) AND CURRENT_DATE-1
            AND POL.PRFCT_ORD_FPDD_HIT_SORT_KEY <> 99

        GROUP BY
            METRIC_TYPE
            , COMPLETE_MTH
            , MATL.PBU_NBR
            , PBU
            , CATEGORY
            , CATEGORY_NAME
            , TIER
            , MATL.EXT_MATL_GRP_ID
            , CUST.OWN_CUST_ID
            , CUST.OWN_CUST_NAME
            , CUST.TIRE_CUST_TYP_CD

        ) OTD

        INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
            ON CAL.DAY_DATE = OTD.COMPLETE_MTH

        ) Q

        LEFT OUTER JOIN (
                SELECT
                    DD.OWN_CUST_ID
                    , DD.TIRE_CUST_TYP_CD
                    , DD.PBU_NBR
                    , DD.MONTH_DT
                    , DD.NEXT_MONTH_DT
                    , DD.CO_DELIV_QTY
                    , DD.MTH_DELIV_QTY
                    , ROW_NUMBER() OVER (PARTITION BY DD.MONTH_DT, DD.PBU_NBR, DD.TIRE_CUST_TYP_CD ORDER BY DD.CO_DELIV_QTY DESC) AS OWN_CUST_RNK

                FROM (

                    SELECT
                        D.OWN_CUST_ID
                        , D.TIRE_CUST_TYP_CD
                        , D.PBU_NBR
                        , D.MONTH_DT
                        , D.NEXT_MONTH_DT
                        , D.CO_DELIV_QTY
                        , SUM(D.CO_DELIV_QTY) OVER (PARTITION BY D.TIRE_CUST_TYP_CD, D.PBU_NBR, D.MONTH_DT) AS MTH_DELIV_QTY

                    FROM (

                        SELECT
                            CUST.OWN_CUST_ID
                            , CUST.TIRE_CUST_TYP_CD
                            , MATL.PBU_NBR
                            , CAL.MONTH_DT
                            , ADD_MONTHS(CAL.MONTH_DT, 1) AS NEXT_MONTH_DT
                            , SUM(DDC.DELIV_QTY) AS CO_DELIV_QTY

                        FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

                            INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                                ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT

                            INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
                                ON MATL.MATL_ID = DDC.MATL_ID
                                AND MATL.PBU_NBR IN ('01', '03')
                                AND MATL.EXT_MATL_GRP_ID = 'TIRE'

                            INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
                                ON FAC.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
                                AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                                AND FAC.DISTR_CHAN_CD = '81'

                            INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
                                ON CUST.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID
                                AND CUST.CUST_GRP_ID <> '3R'

                        WHERE
                            DDC.GOODS_ISS_IND = 'Y'
                            AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
                            AND DDC.ACTL_GOODS_ISS_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-12-01' AS DATE) AND CURRENT_DATE-1
                            AND DDC.DELIV_CAT_ID = 'J'
                            AND DDC.DELIV_QTY > 0
                            AND DDC.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
                            AND DDC.DISTR_CHAN_CD <> '81'

                        GROUP BY
                            CUST.OWN_CUST_ID
                            , CUST.TIRE_CUST_TYP_CD
                            , MATL.PBU_NBR
                            , CAL.MONTH_DT
                            , NEXT_MONTH_DT
                        
                        ) D
                        
                    ) DD
                ) DD
            ON DD.OWN_CUST_ID = Q.OWN_CUST_ID
            AND DD.PBU_NBR = Q.PBU_NBR
            AND DD.TIRE_CUST_TYP_CD = Q.TIRE_CUST_TYP_CD
            AND DD.NEXT_MONTH_DT = Q.COMPLETE_MTH

        )SQ

    GROUP BY
        SQ.METRIC_TYPE
        , SQ.COMPLETE_MTH
        , SQ.QUARTER
        , MONTH_NAME
        , SQ.PBU_NBR
        , SQ.PBU
        , SQ.CATEGORY
        , SQ.CATEGORY_NAME
        , SQ.TIER
        , SQ.CATEGORY_TIER
        , SQ.EXT_MATL_GRP_ID
        , SQ.OWN_CUST
        , SQ.OWN_CUST_NAME
        , SQ.TIRE_CUST_TYP_CD

        , SQ.TARGET_NUMERATOR
        , SQ.TARGET_DENOMINATOR
        , SQ.OWN_CUST_RNK
        , SQ.MTH_DELIV_QTY

    ) TQ

ORDER BY
    TQ.METRIC_TYPE
    , TQ.COMPLETE_MTH
    , TQ.PBU_NBR
    , TQ.CATEGORY
    , TQ.OWN_CUST
