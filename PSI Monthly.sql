﻿
SELECT
    MM.PBU_NBR AS "PBU"
    , MM.TIC_CD AS "TIC"
    , CAST(MM.MATL_ID_TRIM AS INTEGER) AS "Material"
    , MH.DESCR AS "Material Desc"
    , MM.MATL_STA_ID AS "Status"
    , MM.STK_CLASS_ID AS "C/S"
    , MH.HMC_TXT AS "HMC/LMC"
    , GC.CAL_YR AS "Year"
    , GC.CAL_MTH AS "Month"
    , CASE WHEN MM.PBU_NBR= '01' THEN MH.MKT_CTGY_MKT_AREA_NAME ELSE MH.MKT_CTGY_MKT_GRP_NAME END AS "Category"
    , CASE WHEN MM.PBU_NBR = '01' THEN MH.MKT_CTGY_PROD_GRP_NAME ELSE MH.TIERS END AS "Tier"
    , COALESCE(MTI.SRC_FACILITY_ID, MAXSF.SRC_FACILITY_ID) AS "Source"
    , MTI.LVL_GRP_ID AS "Work Center"
    , CAST(MM.MATL_PRTY AS INTEGER) AS "Priority"
    , CAST(CASE
        WHEN MTI.SRC_FACILITY_CNT IS NULL OR MTI.SRC_FACILITY_CNT < 2
            THEN 1
        ELSE (CASE
            WHEN MTI.PROD_CREDIT_PCT IS NULL AND ZEROIFNULL(MTI.TOT_PROD_CREDIT_QTY) = 0
                THEN 1/ NULLIFZERO(MTI.SRC_FACILITY_CNT)
            ELSE ZEROIFNULL(MTI.PROD_CREDIT_PCT)
            END)
        END AS DECIMAL(15,3)) AS PROD_MULTIPLIER
    , ZEROIFNULL(POLG.NO_STOCK_QTY) * PROD_MULTIPLIER  AS "No Stock Qty"
    , ZEROIFNULL(POLG.N602_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N602 NS Qty"
    , ZEROIFNULL(POLG.N623_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N623 NS Qty"
    , ZEROIFNULL(POLG.N636_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N636 NS Qty"
    , ZEROIFNULL(POLG.N637_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N637 NS Qty"
    , ZEROIFNULL(POLG.N639_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N639 NS Qty"
    , ZEROIFNULL(POLG.N699_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N699 NS Qty"
    , ZEROIFNULL(POLG.N6D3_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N6D3 NS Qty"
    , ZEROIFNULL(POLG.OTHER_NO_STOCK_QTY)*PROD_MULTIPLIER AS "Other NS Qty"
    , ZEROIFNULL(POLG.CANCEL_QTY)*PROD_MULTIPLIER AS "Can Qty"
    , ZEROIFNULL(ODCG.ORDER_QTY) * PROD_MULTIPLIER AS "Order Qty"
    , ZEROIFNULL(SA.ORDER_QTY) * PROD_MULTIPLIER AS "SA Order Qty"
    , ZEROIFNULL(ODCG.RO_ORDER_QTY) * PROD_MULTIPLIER AS "RO Order Qty"
    , ZEROIFNULL(DDCG.DELIVERY_QTY) * PROD_MULTIPLIER AS "Ship Qty"
    , ZEROIFNULL(COALESCE(SP.OFFCL_SOP_LAG0, SPB.LAG0_QTY)) * PROD_MULTIPLIER AS "Sales Plan Lag0"
    , ZEROIFNULL(COALESCE(SP.OFFCL_SOP_LAG2, SPB.LAG2_QTY)) * PROD_MULTIPLIER AS "Sales Plan Lag2"
    , ZEROIFNULL(INVE.FACT_END_INV) * PROD_MULTIPLIER AS "Fact End Inv"
    , ZEROIFNULL(INVE.LC_END_INV) * PROD_MULTIPLIER  AS "LC End Inv"
    , ZEROIFNULL(INVE.OTHER_END_INV) * PROD_MULTIPLIER AS "Other End Inv"
    , ZEROIFNULL(INVE.N602_END_INV) * PROD_MULTIPLIER AS "N602 End Inv"
    , ZEROIFNULL(INVE.N623_END_INV) * PROD_MULTIPLIER AS "N623 End Inv"
    , ZEROIFNULL(INVE.N636_END_INV) * PROD_MULTIPLIER AS "N636 End Inv"
    , ZEROIFNULL(INVE.N637_END_INV) * PROD_MULTIPLIER AS "N637 End Inv"
    , ZEROIFNULL(INVE.N639_END_INV) * PROD_MULTIPLIER AS "N639 End Inv"
    , ZEROIFNULL(INVE.N699_END_INV) * PROD_MULTIPLIER AS "N699 End Inv"
    , ZEROIFNULL(INVE.N6D3_END_INV) * PROD_MULTIPLIER AS "N6D3 End Inv"
    , ZEROIFNULL(INV.MIN_INV) * PROD_MULTIPLIER AS "Min Inv"
    , ZEROIFNULL(INV.MAX_INV) * PROD_MULTIPLIER AS "Max Inv"
    , ZEROIFNULL(INV.MIN_INV + ((INV.MAX_INV - INV.MIN_INV)/2)) * PROD_MULTIPLIER AS "Target Inv"
    , ZEROIFNULL(BU.UNITS) * PROD_MULTIPLIER AS "Billed Units"
    , ZEROIFNULL(BU.COLLECTIBLES) * PROD_MULTIPLIER AS "Collect Sales"
    , ZEROIFNULL(BU.COLL_STD_MARGIN) * PROD_MULTIPLIER AS "Collect Margin"
    , ZEROIFNULL(MTI.PROD_CREDIT_QTY) AS "Prod Credit"
    , ZEROIFNULL(MTI.PROD_PLAN_QTY) AS "Prod Plan Lag0"
    , CAST(CASE
        WHEN GC.YESTERDAY_DT BETWEEN GC.MONTH_DT AND ADD_MONTHS(GC.MONTH_DT, 1) - 1
            THEN 1.000 - (CAST(EXTRACT(DAY FROM (CURRENT_DATE-1)) AS DECIMAL(15,3)) / CAST(GC.TTL_DAYS_IN_MNTH AS DECIMAL(15,3)))
        ELSE 1.000
        END AS DECIMAL(15,3)) AS CURR_MTH_BALANCE
    , ZEROIFNULL("Sales Plan Lag0") AS SP_VS_ORD_QTY
    , ZEROIFNULL(CAST(CASE -- in current month, add current gross_inv plus balance of production plans, minus balance of sales plan
        WHEN GC.YESTERDAY_DT BETWEEN GC.MONTH_DT AND ADD_MONTHS(GC.MONTH_DT, 1) - 1
            THEN ZEROIFNULL(INVE.GROSS_INV) + (CURR_MTH_BALANCE * ZEROIFNULL(MTI.PROD_PLAN_QTY)) - (CURR_MTH_BALANCE * ZEROIFNULL(SP_VS_ORD_QTY))
        -- future months use this for the cumulative sum operation
        WHEN GC.MONTH_DT > GC.YESTERDAY_DT
            THEN ZEROIFNULL(MTI.PROD_PLAN_QTY) - SP_VS_ORD_QTY
        ELSE 0.000
        END AS DECIMAL(15,3))) AS INV_QTY_DELTA
    -- cumulative sum OLAP function -- rows unbounded preceding tells the database to only look at dates before the gc.day_date
    , SUM(INV_QTY_DELTA) OVER (PARTITION BY MM.MATL_ID ORDER BY GC.DAY_DATE, "Source" ROWS UNBOUNDED PRECEDING) AS FCST_INV_PROJ

    , "Order Qty" + "SA Order Qty" + "RO Order Qty" AS "Ord+SA+RO"
    , ZEROIFNULL(OO.OPEN_CONFIRM_QTY) * PROD_MULTIPLIER AS "Open Cnfm Qty"
    , GC.BEGIN_DT AS "Rec Date"

    , ZEROIFNULL(INVE.N602_EST_DSI) AS "N602 Est. DSI"
    , ZEROIFNULL(INVE.N623_EST_DSI) AS "N623 Est. DSI"
    , ZEROIFNULL(INVE.N636_EST_DSI) AS "N636 Est. DSI"
    , ZEROIFNULL(INVE.N637_EST_DSI) AS "N637 Est. DSI"
    , ZEROIFNULL(INVE.N639_EST_DSI) AS "N639 Est. DSI"
    , ZEROIFNULL(INVE.N699_EST_DSI) AS "N699 Est. DSI"
    , ZEROIFNULL(INVE.N6D3_EST_DSI) AS "N6D3 Est. DSI"

    , ZEROIFNULL(INVE.ATP_INV_QTY) AS "Network ATP Qty"
    , ZEROIFNULL(INVE.NETWORK_EST_DSI) AS "Network Est DSI"
    , ZEROIFNULL(INVE.LC_ATP_INV_QTY) AS "LC Network ATP Qty"
    , ZEROIFNULL(INVE.LC_NETWORK_EST_DSI) AS "LC Network Est DSI"
    , ZEROIFNULL(INVE.FACT_ATP_INV_QTY) AS "Factory Network ATP Qty"
    , ZEROIFNULL(INVE.FACT_NETWORK_EST_DSI) AS "Factory Network Est DSI"
    , ZEROIFNULL(INVE.OTHER_ATP_INV_QTY) AS "Other Network ATP Qty"
    , ZEROIFNULL(INVE.OTHER_NETWORK_EST_DSI) AS "Other Network Est DSI"

    , CAST(CASE WHEN "LC End Inv" < "Min Inv" THEN 'Y' ELSE 'N' END AS CHAR(1)) AS "Under Min Inventory Ind"

    -- POLS IS A PBU-LEVEL ROLLUP OF ON TIME DELIVERY QTY
    , ZEROIFNULL(POLS.FRDD_ORDER_QTY) AS "PBU FRDD Order Qty"
    , ZEROIFNULL(POLS.FCDD_ORDER_QTY) AS "PBU FCDD Order Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_ORDER_QTY) AS "PBU COWD FRDD Order Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_ORDER_QTY) AS "PBU COWD FCDD Order Qty"

    , ZEROIFNULL(POLS.FRDD_HIT_QTY) AS "PBU FRDD Hit Qty"
    , ZEROIFNULL(POLS.FCDD_HIT_QTY) AS "PBU FCDD Hit Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_HIT_QTY) AS "PBU COWD FRDD Hit Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_HIT_QTY) AS "PBU COWD FCDD Hit Qty"

    , ZEROIFNULL(POLS.FRDD_ONTIME_QTY) AS "PBU FRDD On Time Qty"
    , ZEROIFNULL(POLS.FCDD_ONTIME_QTY) AS "PBU FCDD On Time Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_ONTIME_QTY) AS "PBU COWD FRDD On Time Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_ONTIME_QTY) AS "PBU COWD FCDD On Time Qty"

    , ZEROIFNULL(POLS.FRDD_NO_STOCK_HIT_QTY) AS "PBU FRDD No Stock Hit Qty"
    , ZEROIFNULL(POLS.FCDD_NO_STOCK_HIT_QTY) AS "PBU FCDD No Stock Hit Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_NO_STOCK_HIT_QTY) AS "PBU COWD FRDD No Stock Hit Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_NO_STOCK_HIT_QTY) AS "PBU COWD FCDD No Stock Hit Qty"

    , ZEROIFNULL(POLS.FRDD_CANCEL_HIT_QTY) AS "PBU FRDD Cancel Hit Qty"
    , ZEROIFNULL(POLS.FCDD_CANCEL_HIT_QTY) AS "PBU FCDD Cancel Hit Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_CANCEL_HIT_QTY) AS "PBU COWD FRDD Cancel Hit Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_CANCEL_HIT_QTY) AS "PBU FCDD COWD Cancel Hit Qty"

    -- NO STOCK + CANCEL HITS
    , ZEROIFNULL(POLS.FRDD_NS_CNCL_HIT_QTY) AS "PBU FRDD NS + Cncl Hit Qty"
    , ZEROIFNULL(POLS.FCDD_NS_CNCL_HIT_QTY) AS "PBU FCDD NS + Cncl Hit Qty"
    , ZEROIFNULL(POLS.FRDD_COWD_NS_CNCL_HIT_QTY) AS "PBU COWD FRDD NS + Cncl Hit Qty"
    , ZEROIFNULL(POLS.FCDD_COWD_NS_CNCL_HIT_QTY) AS "PBU COWD FCDD NS + Cncl Hit Qty"

    -- OVERALL NS AND CANCEL HIT QTY
    , "PBU FRDD Order Qty" + "PBU COWD FRDD Order Qty" AS "Total PBU FRDD Order Qty"
    , "PBU FRDD Hit Qty" + "PBU COWD FRDD Hit Qty" AS "Total PBU FRDD Hit Qty"
    , "PBU FRDD On Time Qty" + "PBU COWD FRDD On Time Qty" AS "Total PBU FRDD On Time Qty"
    , "PBU FRDD No Stock Hit Qty" + "PBU COWD FRDD No Stock Hit Qty" AS "Total PBU FRDD No Stock Hit Qty"
    , "PBU FRDD Cancel Hit Qty" + "PBU COWD FRDD Cancel Hit Qty" AS "Total PBU FRDD Cancel Hit Qty"
    , "PBU FRDD NS + Cncl Hit Qty" + "PBU COWD FRDD NS + Cncl Hit Qty" AS "Total PBU FRDD NS + Cncl Hit Qty"
    , GC.MONTH_DT
    , "Category" || ' (' || "Tier" || ')' AS "Category - Tier"
    , "Material" || ' - ' || "Material Desc" AS "Material - Desc"
    , MH.PROD_LINE_NAME

    , MTI.GRN_TIRE_CTGY_CD AS "Green Tire Ctgy Cd"
    , MTI.SAFE_STK_QTY AS "Safety Stock Rqt Qty"
    , CASE WHEN MTI.MATL_MIN_INV_RQT_QTY IS NOT NULL THEN MTI.MATL_MIN_INV_RQT_QTY ELSE INVMM.MATL_MIN_INV_RQT_QTY END AS "Min Inventory Rqt Qty"
    , MTI.MATL_CYCL_STK_QTY AS "Cycle Stock Rqt Qty"
    , CASE WHEN MTI.MATL_MAX_INV_QTY IS NOT NULL THEN MTI.MATL_MAX_INV_QTY ELSE INVMM.MATL_MAX_INV_QTY END AS "Max Inventory Rqt Qty"
    , MTI.MATL_AVG_INV_QTY AS "Avg Inventory Rqt Qty"
    , MTI.MIN_RUN_QTY AS "Material Min Run Qty"
    , CASE
        WHEN GC.MONTH_DT / 100 = (CURRENT_DATE-1) / 100
            THEN ("Sales Plan Lag0" / GC.TTL_DAYS_IN_MNTH) * EXTRACT(DAY FROM CURRENT_DATE-1)
        WHEN GC.MONTH_DT > CURRENT_DATE-1
            THEN 0
        ELSE "Sales Plan Lag0"
        END AS "Sales Plan Par"
    , CASE
        WHEN GC.MONTH_DT / 100 = (CURRENT_DATE-1) / 100
            THEN ("Prod Plan Lag0" / GC.TTL_DAYS_IN_MNTH) * EXTRACT(DAY FROM CURRENT_DATE-1)
        WHEN GC.MONTH_DT > CURRENT_DATE-1
            THEN 0
        ELSE "Prod Plan Lag0"
        END AS "Prod Plan Par"
    , CAST(CASE WHEN "LC End Inv" < "Min Inventory Rqt Qty" THEN 'Y' ELSE 'N' END AS CHAR(1)) AS "Under Min Rqt Inventory Ind"

    , ZEROIFNULL(INVE.NTWK_UNRSTR_INV) AS "Network Unrestricted Inv"
    , ZEROIFNULL(INVE.FACT_UNRSTR_INV) AS "Factory Unrestricted Inv"
    , ZEROIFNULL(INVE.LC_UNRstr_INV) AS "LC Unrestricted Inv"
    , ZEROIFNULL(INVE.OTHER_UNRSTR_INV) AS "Other Unrestricted Inv"

    , ZEROIFNULL(INVE.NTWK_ATP_INV) AS "Network ATP Inv"
    , ZEROIFNULL(INVE.FACT_ATP_INV) AS "Factory ATP Inv"
    , ZEROIFNULL(INVE.LC_ATP_INV) AS "LC ATP Inv"
    , ZEROIFNULL(INVE.OTHER_ATP_INV) AS "Other ATP Inv"

    , ZEROIFNULL(INVE.NTWK_IN_TRANS_INV) AS "Network In Transit Inv"
    , ZEROIFNULL(INVE.FACT_IN_TRANS_INV) AS "Factory In Transit Inv"
    , ZEROIFNULL(INVE.LC_IN_TRANS_INV) AS "LC In Transit Inv"
    , ZEROIFNULL(INVE.OTHER_IN_TRANS_INV) AS "Other In Transit Inv"

    , ZEROIFNULL(INVE.NTWK_TOT_INV) AS "Network Total Inv"
    , ZEROIFNULL(INVE.FACT_TOT_INV) AS "Factory Total Inv"
    , ZEROIFNULL(INVE.LC_TOT_INV) AS "LC Total Inv"
    , ZEROIFNULL(INVE.OTHER_TOT_INV) AS "Other Total Inv"

FROM (
SELECT
    DAY_DATE
    , MONTH_DT
    , BEGIN_DT
    , TTL_DAYS_IN_MNTH
    , CAL_MTH
    , CAL_YR
    , MNTH
    , MNTH_NAME_ABBREV
    , MNTH_NAME
    , MNTH_DESCR
    , CURRENT_DATE AS TODAY_DT
    , CURRENT_DATE-1 AS YESTERDAY_DT

FROM GDYR_BI_VWS.GDYR_CAL

WHERE
    DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
        AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
) GC

    INNER JOIN GDYR_VWS.MATL MM
        ON GC.DAY_DATE BETWEEN MM.EFF_DT AND MM.EXP_DT
        AND MM.PBU_NBR IN ('01','03')
        AND MM.EXT_MATL_GRP_ID = 'TIRE'
        AND MM.ORIG_SYS_ID = 2
        AND MM.MATL_STA_ID <> 'DN'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
        ON MH.MATL_ID = MM.MATL_ID
        AND MH.PBU_NBR IN ('01','03')
        AND MH.EXT_MATL_GRP_ID = 'TIRE'

    LEFT OUTER JOIN (
            SELECT
                A.MATL_ID
                , A.PERD_BEGIN_MTH_DT AS MONTH_DT
                , SUM(CASE WHEN A.DP_LAG_DESC = 'LAG 0' THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS OFFCL_SOP_LAG0
                , SUM(CASE WHEN A.DP_LAG_DESC = 'LAG 2' THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS OFFCL_SOP_LAG2

            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                    ON MH.MATL_ID = A.MATL_ID
                    AND MH.PBU_NBR IN ('01','03')
                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN (
                SELECT
                    DAY_DATE
                    , MONTH_DT
                    , BEGIN_DT
                    , TTL_DAYS_IN_MNTH
                    , CAL_MTH
                    , CAL_YR
                    , MNTH
                    , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                    , MNTH_NAME
                    , MNTH_DESCR
                    , CURRENT_DATE AS TODAY_DT
                    , CURRENT_DATE-1 AS YESTERDAY_DT

                FROM GDYR_BI_VWS.GDYR_CAL

                WHERE
                    DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                        AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.DAY_DATE = A.PERD_BEGIN_MTH_DT
                    AND CAL.DAY_DATE = CAL.MONTH_DT
                    AND CAL.DAY_DATE >= CAL.YESTERDAY_DT

            WHERE
                A.DP_LAG_DESC IN ('LAG 0','LAG 2')

            GROUP BY
                A.MATL_ID
                , A.PERD_BEGIN_MTH_DT
            ) SP
        ON SP.MATL_ID = MM.MATL_ID
        AND SP.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                B.MATL_ID
                , B.PERD_BEGIN_MTH_DT AS MONTH_DT
                , SUM(CASE WHEN B.LAG_DESC = '0' THEN B.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS LAG0_QTY
                , SUM(CASE WHEN B.LAG_DESC = '2' THEN B.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS LAG2_QTY

            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP B

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                    ON MH.MATL_ID = B.MATL_ID
                    AND MH.PBU_NBR IN ('01','03')
                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.MONTH_DT = B.PERD_BEGIN_MTH_DT
                    AND CAL.DAY_DATE = CAL.MONTH_DT
                    AND CAL.DAY_DATE < CAL.YESTERDAY_DT

            WHERE
                B.LAG_DESC IN ('0', '2')

            GROUP BY
                B.MATL_ID
                , B.PERD_BEGIN_MTH_DT
            )SPB
        ON SPB.MATL_ID = MM.MATL_ID
        AND SPB.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
                SELECT
                    SA.MATL_NO AS MATL_ID
                    , SA.BILL_REF_MTH_DT AS MONTH_DT
                    , SUM(SA.COLLCT_SLS_GRP_AMT) AS COLLECTIBLES
                    , SUM(SA.COLLCT_STD_MRGN_GRP_AMT) AS COLL_STD_MARGIN
                    , SUM(SA.SLS_QTY) AS UNITS

                FROM NA_VWS.SLS_AGG SA

                    INNER JOIN (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL
                        ON CAL.MONTH_DT = SA.BILL_DT
                        AND CAL.DAY_DATE < CAL.TODAY_DT

                    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                        ON MH.MATL_ID = SA.MATL_NO
                        AND MH.PBU_NBR IN ('01','03')
                        AND MH.EXT_MATL_GRP_ID = 'TIRE'

                    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR C
                        ON C.SHIP_TO_CUST_ID = SA.LEGACY_SHIP_TO_CUST_NO

                    INNER JOIN GDYR_BI_VWS.NAT_SALES_ORG_EN_CURR SO
                        ON SO.SALES_ORG_CD = C.SALES_ORG_CD
                        AND SO.CO_CD IN ('N101', 'N102', 'N266')

                GROUP BY
                    SA.MATL_NO,
                    SA.BILL_REF_MTH_DT
            )BU
        ON BU.MATL_ID = MM.MATL_ID
        AND BU.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID
                , CAL.MONTH_DT
                , SUM(CASE WHEN ODC.PO_TYPE_ID <> 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS ORDER_QTY
                , SUM(CASE WHEN ODC.PO_TYPE_ID = 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS RO_ORDER_QTY
                , SUM(ZEROIFNULL(ODC.CNFRM_QTY)) AS CONFIRM_QTY

            FROM NA_BI_VWS.ORDER_DETAIL ODC

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                )CAL
                    ON CAL.DAY_DATE = ODC.FRST_RDD

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                    ON MH.MATL_ID = ODC.MATL_ID
                    AND MH.PBU_NBR IN ('01','03')
                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

            WHERE
                ODC.EXP_DT = DATE '5555-12-31'
                AND ODC.ORDER_CAT_ID = 'C'
                AND ODC.REJ_REAS_ID IN ('', 'Z2')
                AND ODC.ORDER_QTY > 0

            GROUP BY
                ODC.MATL_ID
                , CAL.MONTH_DT
            )ODCG
        ON ODCG.MATL_ID = MM.MATL_ID
        AND ODCG.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID
                , CAL.MONTH_DT
                , SUM(OOSL.OPEN_CNFRM_QTY) AS OPEN_CONFIRM_QTY

            FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL

                INNER JOIN NA_BI_VWS.ORDER_DETAIL ODC
                    ON ODC.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
                    AND ODC.ORDER_ID = OOSL.ORDER_ID
                    AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
                    AND ODC.SCHED_LINE_NBR = 1
                    AND ODC.EXP_DT = DATE '5555-12-31'
                    AND ODC.ORDER_CAT_ID = 'C'
                    AND ODC.RO_PO_TYPE_IND = 'N'
                    --AND ODC.PLN_DELIV_DT BETWEEN CURRENT_DATE AND ADD_MONTHS(CURRENT_DATE, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 7))
                    AND ODC.REJ_REAS_ID = ''

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.DAY_DATE = ODC.PLN_DELIV_DT
                    AND CAL.DAY_DATE > CAL.YESTERDAY_DT

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                    ON MH.MATL_ID = ODC.MATL_ID
                    AND MH.PBU_NBR IN ('01','03')
                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

            WHERE
                OOSL.OPEN_CNFRM_QTY > 0

            GROUP BY
                ODC.MATL_ID
                , CAL.MONTH_DT
            )OO
        ON OO.MATL_ID = MM.MATL_ID
        AND OO.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                SDI.MATL_ID
                , CAL.MONTH_DT
                , SUM(SDI.SLS_UNIT_CUM_ORD_QTY) AS ORDER_QTY

            FROM GDYR_BI_VWS.NAT_SLS_DOC_CURR SD

                INNER JOIN GDYR_BI_VWS.NAT_SALES_ORG_EN_CURR SO
                    ON SO.SALES_ORG_CD = SD.SALES_ORG_CD
                    AND SO.CO_CD IN ('N101', 'N102', 'N266')
                    AND SO.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')

                INNER JOIN GDYR_BI_VWS.NAT_SLS_DOC_ITM_CURR SDI
                    ON SDI.FISCAL_YR = SD.FISCAL_YR
                    AND SDI.SLS_DOC_ID = SD.SLS_DOC_ID
                    --AND SDI.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                    AND SDI.REJ_REAS_ID IS NULL
                    AND SDI.MATL_HIER_ID LIKE ANY ('01%', '03%')

                INNER JOIN GDYR_VWS.FACILITY F
                    ON F.FACILITY_ID = SDI.FACILITY_ID
                    AND F.EXP_DT = DATE '5555-12-31'
                    AND F.ORIG_SYS_ID = 2
                    AND F.LANG_ID = 'EN'
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                    AND F.DISTR_CHAN_CD = '81'

                INNER JOIN GDYR_BI_VWS.NAT_SLS_DOC_SCHD_LN_CURR SDSL
                    ON SDSL.FISCAL_YR = SDI.FISCAL_YR
                    AND SDSL.SLS_DOC_ID = SDI.SLS_DOC_ID
                    AND SDSL.SLS_DOC_ITM_ID = SDI.SLS_DOC_ITM_ID
                    AND SDSL.SCHD_LN_ID = 1
/*                    AND SDSL.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
                    AND SDSL.SCHD_LN_DELIV_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE)
                        AND ADD_MONTHS(CURRENT_DATE, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 7))*/

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.DAY_DATE = SDSL.SCHD_LN_DELIV_DT

            WHERE
                SD.SD_DOC_CTGY_CD IN  ('E')
                AND SD.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))

            GROUP BY
                SDI.MATL_ID
                , CAL.MONTH_DT
            )SA
        ON SA.MATL_ID = MM.MATL_ID
        AND SA.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                DDC.MATL_ID
                , CAL.MONTH_DT
                , SUM(DDC.DELIV_QTY) AS DELIVERY_QTY

            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

                INNER JOIN GDYR_BI_VWS.NAT_SALES_ORG_EN_CURR SO
                    ON SO.SALES_ORG_CD = DDC.SALES_ORG_CD
                    AND SO.CO_CD IN ('N101', 'N102', 'N266')
                    AND SO.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT
                    AND CAL.DAY_DATE < CAL.TODAY_DT

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                    ON MH.MATL_ID = DDC.MATL_ID
                    AND MH.PBU_NBR IN ('01','03')
                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN GDYR_VWS.FACILITY F
                    ON F.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
                    AND F.EXP_DT = DATE '5555-12-31'
                    AND F.ORIG_SYS_ID = 2
                    AND F.LANG_ID = 'EN'
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                    AND F.DISTR_CHAN_CD = '81'

            WHERE
                DDC.DELIV_QTY > 0
                AND DDC.DELIV_CAT_ID = 'J'
                --INTERNAL SHIPMENTS
                AND DDC.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
                AND DDC.DISTR_CHAN_CD <> '81'
                AND DDC.GOODS_ISS_IND = 'Y'
                AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL

            GROUP BY
                DDC.MATL_ID
                , CAL.MONTH_DT
            )DDCG
        ON DDCG.MATL_ID = MM.MATL_ID
        AND DDCG.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                POL.MATL_ID
                , CAL.MONTH_DT
                , SUM(POL.IF_HIT_NS_QTY) AS NO_STOCK_QTY
                , SUM(POL.IF_HIT_CO_QTY) AS CANCEL_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS OTHER_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N602' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N602_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N623' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N623_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N636' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N636_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N637' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N637_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N639' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N639_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N699' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N699_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N6D3' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N6D3_NO_STOCK_QTY

            FROM NA_BI_VWS.PRFCT_ORD_LINE POL

                INNER JOIN (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL
                    ON CAL.DAY_DATE = POL.CMPL_DT
                    AND CAL.DAY_DATE < CAL.TODAY_DT

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
                    ON MATL.MATL_ID = POL.MATL_ID
                    AND MATL.PBU_NBR IN ('01', '03')
                    AND MATL.EXT_MATL_GRP_ID = 'TIRE'

            WHERE
                POL.CMPL_IND = 1
                AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99

            GROUP BY
                POL.MATL_ID
                , CAL.MONTH_DT
            )POLG
        ON POLG.MATL_ID = MM.MATL_ID
        AND POLG.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (

            SELECT
                OTD.COMPLETE_MTH AS MONTH_DT
                , OTD.PBU_NBR
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'N' THEN OTD.ORDER_QTY END)) AS FRDD_ORDER_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'N' THEN OTD.ORDER_QTY END)) AS FCDD_ORDER_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'Y' THEN OTD.ORDER_QTY END)) AS FRDD_COWD_ORDER_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'Y' THEN OTD.ORDER_QTY END)) AS FCDD_COWD_ORDER_QTY

                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'N' THEN OTD.ONTIME_QTY END)) AS FRDD_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'N' THEN OTD.HIT_QTY END)) AS FCDD_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'Y' THEN OTD.HIT_QTY END)) AS FRDD_COWD_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'Y' THEN OTD.HIT_QTY END)) AS FCDD_COWD_HIT_QTY

                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'N' THEN OTD.ONTIME_QTY END)) AS FRDD_ONTIME_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'N' THEN OTD.ONTIME_QTY END)) AS FCDD_ONTIME_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'Y' THEN OTD.ONTIME_QTY END)) AS FRDD_COWD_ONTIME_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'Y' THEN OTD.ONTIME_QTY END)) AS FCDD_COWD_ONTIME_QTY

                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'N' THEN OTD.NO_STOCK_HIT_QTY END)) AS FRDD_NO_STOCK_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'N' THEN OTD.NO_STOCK_HIT_QTY END)) AS FCDD_NO_STOCK_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'Y' THEN OTD.NO_STOCK_HIT_QTY END)) AS FRDD_COWD_NO_STOCK_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'Y' THEN OTD.NO_STOCK_HIT_QTY END)) AS FCDD_COWD_NO_STOCK_HIT_QTY

                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'N' THEN OTD.CANCEL_HIT_QTY END)) AS FRDD_CANCEL_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'N' THEN OTD.CANCEL_HIT_QTY END)) AS FCDD_CANCEL_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FRDD' AND OTD.COWD_IND = 'Y' THEN OTD.CANCEL_HIT_QTY END)) AS FRDD_COWD_CANCEL_HIT_QTY
                , SUM(ZEROIFNULL(CASE WHEN OTD.METRIC_TYPE = 'FCDD' AND OTD.COWD_IND = 'Y' THEN OTD.CANCEL_HIT_QTY END)) AS FCDD_COWD_CANCEL_HIT_QTY

            -- NO STOCK + CANCEL HITS
                , FRDD_NO_STOCK_HIT_QTY + FRDD_CANCEL_HIT_QTY AS FRDD_NS_CNCL_HIT_QTY
                , FCDD_NO_STOCK_HIT_QTY + FCDD_CANCEL_HIT_QTY AS FCDD_NS_CNCL_HIT_QTY
                , FRDD_COWD_NO_STOCK_HIT_QTY + FRDD_COWD_CANCEL_HIT_QTY AS FRDD_COWD_NS_CNCL_HIT_QTY
                , FCDD_COWD_NO_STOCK_HIT_QTY + FCDD_COWD_CANCEL_HIT_QTY AS FCDD_COWD_NS_CNCL_HIT_QTY

            FROM (

                SELECT
                    CAST('FRDD' AS CHAR(4)) AS METRIC_TYPE

                    , CAL.MONTH_DT AS COMPLETE_MTH
                    , MATL.PBU_NBR
                    , CASE WHEN CUST.CUST_GRP_ID = '3R' THEN 'Y' ELSE 'N' END AS COWD_IND

                    , SUM(ZEROIFNULL(POL.CURR_ORD_QTY)) AS ORDER_QTY
                    , SUM(ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS HIT_QTY
                    , SUM(ZEROIFNULL(POL.CURR_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS ONTIME_QTY

                    , SUM(ZEROIFNULL(POL.IF_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
                    , SUM(ZEROIFNULL(POL.IF_HIT_CO_QTY)) AS CANCEL_HIT_QTY

                FROM NA_BI_VWS.PRFCT_ORD_LINE POL

                    INNER JOIN (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL
                        ON CAL.DAY_DATE = POL.CMPL_DT
                        AND CAL.DAY_DATE < CAL.TODAY_DT

                    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR CUST
                        ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID

                    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
                        ON MATL.MATL_ID = POL.MATL_ID
                        AND MATL.PBU_NBR IN ('01', '03')
                        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

                WHERE
                    POL.CMPL_IND = 1
                    AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99

                GROUP BY
                    METRIC_TYPE
                    , CAL.MONTH_DT
                    , COWD_IND
                    , MATL.PBU_NBR

                UNION ALL

                SELECT
                    CAST('FCDD' AS CHAR(4)) AS METRIC_TYPE
                    , CAL.MONTH_DT AS COMPLETE_MTH

                    , MATL.PBU_NBR
                    , CASE WHEN CUST.CUST_GRP_ID = '3R' THEN 'Y' ELSE 'N' END AS COWD_IND

                    , SUM(ZEROIFNULL(POL.FPDD_ORD_QTY)) AS ORDER_QTY
                    , SUM(ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY)) AS HIT_QTY
                    , SUM(ZEROIFNULL(POL.FPDD_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY)) AS ONTIME_QTY

                    , SUM(ZEROIFNULL(POL.IF_FPDD_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
                    , SUM(ZEROIFNULL(POL.IF_FPDD_HIT_CO_QTY)) AS CANCEL_HIT_QTY

                FROM NA_BI_VWS.PRFCT_ORD_LINE POL

                    INNER JOIN (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL
                        ON CAL.DAY_DATE = POL.FPDD_CMPL_DT
                        AND CAL.DAY_DATE < CAL.TODAY_DT

                    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_CURR CUST
                        ON CUST.SHIP_TO_CUST_ID = POL.SHIP_TO_CUST_ID

                    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
                        ON MATL.MATL_ID = POL.MATL_ID
                        AND MATL.PBU_NBR IN ('01', '03')
                        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

                WHERE
                    POL.FPDD_CMPL_IND = 1
                    AND POL.FRST_PROM_DELIV_DT IS NOT NULL
                    AND POL.PRFCT_ORD_FPDD_HIT_SORT_KEY <> 99

                GROUP BY
                    METRIC_TYPE
                    , CAL.MONTH_DT
                    , COWD_IND
                    , MATL.PBU_NBR

                ) OTD

            GROUP BY
                OTD.COMPLETE_MTH
                , OTD.PBU_NBR

            ) POLS
        ON POLS.PBU_NBR = MM.PBU_NBR
        AND POLS.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                ICG.MATL_ID
                , ICG.MONTH_DT
                , AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                          (ICG.SUM_SHIP_INTERVAL / 2)) + AVERAGE(ZEROIFNULL(ICA.MIN_INV_ADJ_QTY)) AS MIN_INV
                , AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                         (ICG.SUM_SHIP_INTERVAL / 2) + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) + AVERAGE(ZEROIFNULL(ICA.MIN_INV_ADJ_QTY)) +
                         AVERAGE(ZEROIFNULL(ICA.SHIP_STD_DEVN_MATL_ADJ_QTY)) + AVERAGE(ZEROIFNULL(ICA.MIN_PROD_RUN_INV_ADJ_QTY)) AS MAX_INV
                , (MIN_INV + MAX_INV) / 2 AS TARGET_INV

            FROM (

                SELECT
                    ICC.MATL_ID
                    , CAL.DAY_DATE
                    , CAL.MONTH_DT
                    , SUM(ZEROIFNULL(ICC.DMAN_VAR_CMPNT_INV_QTY)) AS SUM_DEMAND_VAR
                    , SUM(ZEROIFNULL(ICC.TRANSP_VAR_CMPNT_INV_QTY)) AS SUM_TRANS_VAR
                    , SUM(ZEROIFNULL(ICC.SPLY_VAR_CMPNT_INV_QTY)) AS SUM_SUPPLY_VAR
                    , SUM(ZEROIFNULL(ICC.GEO_CMPNT_INV_QTY)) AS SUM_GEO
                    , SUM(ZEROIFNULL(ICC.SHIP_LOT_SZ_CMPNT_INV_QTY)) AS SUM_SHIP_LOT_SIZE
                    , SUM(ZEROIFNULL(ICC.SHIP_INTVL_CMPNT_INV_QTY)) AS SUM_SHIP_INTERVAL
                    , SUM(ZEROIFNULL(ICC.MFG_LOT_SZ_CMPNT_INV_QTY)) AS SUM_MFG_LOT_SIZE
                    , SUM(ZEROIFNULL(ICC.INFO_CYCL_CMPNT_INV_QTY)) AS SUM_INFO_CYCLE

                FROM NA_BI_VWS.INV_COMPONENT_CURR ICC

                    INNER JOIN (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL
                        ON CAL.DAY_DATE = ICC.SRC_CRT_DT
                        AND CAL.DAY_DATE < CAL.TODAY_DT

                    INNER JOIN GDYR_VWS.FACILITY F
                        ON F.FACILITY_ID = ICC.FACILITY_ID
                        AND F.EXP_DT = DATE '5555-12-31'
                        AND F.ORIG_SYS_ID = 2
                        AND F.LANG_ID = 'EN'
                        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                        AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                        AND F.DISTR_CHAN_CD = '81'

                    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                        ON MH.MATL_ID = ICC.MATL_ID
                        AND MH.PBU_NBR IN ('01','03')
                        AND MH.EXT_MATL_GRP_ID = 'TIRE'

                GROUP BY
                    ICC.MATL_ID
                    , CAL.DAY_DATE
                    , CAL.MONTH_DT

                UNION ALL

                SELECT
                    Q.MATL_ID
                    , CAL.DAY_DATE
                    , CAL.MONTH_DT
                    , Q.SUM_DEMAND_VAR
                    , Q.SUM_TRANS_VAR
                    , Q.SUM_SUPPLY_VAR
                    , Q.SUM_GEO
                    , Q.SUM_SHIP_LOT_SIZE
                    , Q.SUM_SHIP_INTERVAL
                    , Q.SUM_MFG_LOT_SIZE
                    , Q.SUM_INFO_CYCLE

                FROM (
                    SELECT
                        DAY_DATE
                        , MONTH_DT
                        , BEGIN_DT
                        , TTL_DAYS_IN_MNTH
                        , CAL_MTH
                        , CAL_YR
                        , MNTH
                        , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                        , MNTH_NAME
                        , MNTH_DESCR
                        , CURRENT_DATE AS TODAY_DT
                        , CURRENT_DATE-1 AS YESTERDAY_DT

                    FROM GDYR_BI_VWS.GDYR_CAL

                    WHERE
                        DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                            AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                ) CAL

                    FULL OUTER JOIN (
                            SELECT
                                ICC.MATL_ID
                                , SUM(ZEROIFNULL(ICC.DMAN_VAR_CMPNT_INV_QTY)) AS SUM_DEMAND_VAR
                                , SUM(ZEROIFNULL(ICC.TRANSP_VAR_CMPNT_INV_QTY)) AS SUM_TRANS_VAR
                                , SUM(ZEROIFNULL(ICC.SPLY_VAR_CMPNT_INV_QTY)) AS SUM_SUPPLY_VAR
                                , SUM(ZEROIFNULL(ICC.GEO_CMPNT_INV_QTY)) AS SUM_GEO
                                , SUM(ZEROIFNULL(ICC.SHIP_LOT_SZ_CMPNT_INV_QTY)) AS SUM_SHIP_LOT_SIZE
                                , SUM(ZEROIFNULL(ICC.SHIP_INTVL_CMPNT_INV_QTY)) AS SUM_SHIP_INTERVAL
                                , SUM(ZEROIFNULL(ICC.MFG_LOT_SZ_CMPNT_INV_QTY)) AS SUM_MFG_LOT_SIZE
                                , SUM(ZEROIFNULL(ICC.INFO_CYCL_CMPNT_INV_QTY)) AS SUM_INFO_CYCLE

                            FROM NA_BI_VWS.INV_COMPONENT_CURR ICC

                                INNER JOIN GDYR_VWS.FACILITY F
                                    ON F.FACILITY_ID = ICC.FACILITY_ID
                                    AND F.EXP_DT = DATE '5555-12-31'
                                    AND F.ORIG_SYS_ID = 2
                                    AND F.LANG_ID = 'EN'
                                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                                    AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                                    AND F.DISTR_CHAN_CD = '81'

                                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MH
                                    ON MH.MATL_ID = ICC.MATL_ID
                                    AND MH.PBU_NBR IN ('01','03')
                                    AND MH.EXT_MATL_GRP_ID = 'TIRE'

                            WHERE
                                ICC.SRC_CRT_DT = CURRENT_DATE-1

                            GROUP BY
                                ICC.MATL_ID
                            ) Q
                        ON 1=1

                WHERE
                    CAL.DAY_DATE >= CAL.TODAY_DT

                ) ICG

                LEFT OUTER JOIN NA_BI_VWS.INV_COMPONENT_ADJ_CURR ICA
                    ON ICA.MATL_ID = ICG.MATL_ID
                    AND ICA.SRC_CRT_DT = ICG.DAY_DATE

            GROUP BY
                ICG.MATL_ID
                , ICG.MONTH_DT
            )INV
        ON INV.MATL_ID = MM.MATL_ID
        AND INV.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
                SELECT
                    Q.MATL_ID
                    , Q.MONTH_DT
                    , Q.INV_QTY_UOM
                    , SUM(ZEROIFNULL(Q.TOT_QTY) + ZEROIFNULL(Q.IN_TRANS_QTY)) AS GROSS_INV
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.TOT_QTY ELSE 0 END) AS FACT_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS LC_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS OTHER_END_INV

                    , SUM(Q.UNRSTR_QTY) AS NTWK_UNRSTR_INV
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.UNRSTR_QTY ELSE 0 END) AS FACT_UNRSTR_INV
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.UNRSTR_QTY ELSE 0 END) AS LC_UNRSTR_INV
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.UNRSTR_QTY ELSE 0 END) AS OTHER_UNRSTR_INV

                    , SUM(Q.ATP_QTY) AS NTWK_ATP_INV
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.ATP_QTY ELSE 0 END) AS FACT_ATP_INV
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.ATP_QTY ELSE 0 END) AS LC_ATP_INV
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.ATP_QTY ELSE 0 END) AS OTHER_ATP_INV

                    , SUM(Q.IN_TRANS_QTY) AS NTWK_IN_TRANS_INV
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.IN_TRANS_QTY ELSE 0 END) AS FACT_IN_TRANS_INV
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.IN_TRANS_QTY ELSE 0 END) AS LC_IN_TRANS_INV
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.IN_TRANS_QTY ELSE 0 END) AS OTHER_IN_TRANS_INV

                    , SUM(Q.TOT_QTY) AS NTWK_TOT_INV
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.TOT_QTY ELSE 0 END) AS FACT_TOT_INV
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.TOT_QTY ELSE 0 END) AS LC_TOT_INV
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.TOT_QTY ELSE 0 END) AS OTHER_TOT_INV

                    , SUM(Q.TOT_QTY + Q.IN_TRANS_QTY) AS TOT_END_INV

                    , SUM(CASE WHEN Q.FACILITY_ID = 'N602' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N602_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N623' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N623_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N636' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N636_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N637' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N637_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N639' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N639_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N699' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N699_END_INV
                    , SUM(CASE WHEN Q.FACILITY_ID = 'N6D3' THEN Q.TOT_QTY + Q.IN_TRANS_QTY ELSE 0 END) AS N6D3_END_INV

                    , MAX(CASE WHEN Q.FACILITY_ID = 'N602' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N602_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N623' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N623_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N636' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N636_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N637' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N637_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N639' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N639_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N699' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N699_EST_DSI
                    , MAX(CASE WHEN Q.FACILITY_ID = 'N6D3' THEN Q.EST_DAYS_SUPPLY ELSE 0 END) AS N6D3_EST_DSI

                    , SUM(Q.ATP_QTY) AS ATP_INV_QTY
                    , SUM(Q.FORC_SKU_QTY_1) AS FORC_QTY_1
                    , SUM(Q.FORC_SKU_QTY_2) AS FORC_QTY_2
                    , SUM(Q.FORC_SKU_QTY_3) AS FORC_QTY_3
                    , SUM(Q.FORC_SKU_QTY_4) AS FORC_QTY_4
                    , SUM(Q.FORC_SKU_QTY_5) AS FORC_QTY_5
                    , SUM(Q.FORC_SKU_QTY_6) AS FORC_QTY_6
                    , SUM(Q.FORC_SKU_QTY_7) AS FORC_QTY_7
                    , SUM(Q.FORC_SKU_QTY_8) AS FORC_QTY_8
                    , SUM(Q.FORC_SKU_QTY_9) AS FORC_QTY_9
                    , SUM(Q.FORC_SKU_QTY_10) AS FORC_QTY_10
                    , SUM(Q.FORC_SKU_QTY_11) AS FORC_QTY_11
                    , SUM(Q.FORC_SKU_QTY_12) AS FORC_QTY_12
                    , CASE
                        WHEN ATP_INV_QTY <= 0
                            THEN 0
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9 + FORC_QTY_10 + FORC_QTY_11 + FORC_QTY_12) <= ATP_INV_QTY
                            THEN 360
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9 + FORC_QTY_10 + FORC_QTY_11) <= ATP_INV_QTY
                            THEN 330 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9 + FORC_QTY_10 + FORC_QTY_11)) / NULLIFZERO(FORC_QTY_12))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9 + FORC_QTY_10) <= ATP_INV_QTY
                            THEN 300 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9 + FORC_QTY_10)) / NULLIFZERO(FORC_QTY_11))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9) <= ATP_INV_QTY
                            THEN 270 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8 + FORC_QTY_9)) / NULLIFZERO(FORC_QTY_10))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8) <= ATP_INV_QTY
                            THEN 240 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7 + FORC_QTY_8)) / NULLIFZERO(FORC_QTY_9))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7) <= ATP_INV_QTY
                            THEN 210 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6 + FORC_QTY_7)) / NULLIFZERO(FORC_QTY_8))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6) <= ATP_INV_QTY
                            THEN 180 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5 + FORC_QTY_6)) / NULLIFZERO(FORC_QTY_7))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5) <= ATP_INV_QTY
                            THEN 150 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4 + FORC_QTY_5)) / NULLIFZERO(FORC_QTY_6))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4) <= ATP_INV_QTY
                            THEN 120 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3 + FORC_QTY_4)) / NULLIFZERO(FORC_QTY_5))
                        WHEN (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3) <= ATP_INV_QTY
                            THEN 90 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2 + FORC_QTY_3)) / NULLIFZERO(FORC_QTY_4))
                        WHEN (FORC_QTY_1 + FORC_QTY_2) <= ATP_INV_QTY
                            THEN 60 + (30 * (ATP_INV_QTY - (FORC_QTY_1 + FORC_QTY_2)) / NULLIFZERO(FORC_QTY_3))
                        WHEN (FORC_QTY_1) <= ATP_INV_QTY
                            THEN 30 + (30 * (ATP_INV_QTY - FORC_QTY_1) / NULLIFZERO(FORC_QTY_2))
                        ELSE 30 * (ATP_INV_QTY / NULLIFZERO(FORC_QTY_1))
                        END AS NETWORK_EST_DSI

                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.ATP_QTY ELSE 0 END) AS LC_ATP_INV_QTY
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_1 ELSE 0 END) AS LC_FORC_QTY_1
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_2 ELSE 0 END) AS LC_FORC_QTY_2
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_3 ELSE 0 END) AS LC_FORC_QTY_3
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_4 ELSE 0 END) AS LC_FORC_QTY_4
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_5 ELSE 0 END) AS LC_FORC_QTY_5
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_6 ELSE 0 END) AS LC_FORC_QTY_6
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_7 ELSE 0 END) AS LC_FORC_QTY_7
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_8 ELSE 0 END) AS LC_FORC_QTY_8
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_9 ELSE 0 END) AS LC_FORC_QTY_9
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_10 ELSE 0 END) AS LC_FORC_QTY_10
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_11 ELSE 0 END) AS LC_FORC_QTY_11
                    , SUM(CASE WHEN Q.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_12 ELSE 0 END) AS LC_FORC_QTY_12
                    , CASE
                        WHEN LC_ATP_INV_QTY > 0 AND (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10 + LC_FORC_QTY_11 + LC_FORC_QTY_12) <= 0
                            THEN -1
                        WHEN LC_ATP_INV_QTY <= 0 AND (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10 + LC_FORC_QTY_11 + LC_FORC_QTY_12) <= 0
                            THEN -2
                        WHEN LC_ATP_INV_QTY <= 0
                            THEN 0
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10 + LC_FORC_QTY_11 + LC_FORC_QTY_12) <= LC_ATP_INV_QTY
                            THEN 360
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10 + LC_FORC_QTY_11) <= LC_ATP_INV_QTY
                            THEN 330 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10 + LC_FORC_QTY_11)) / NULLIFZERO(LC_FORC_QTY_12))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10) <= LC_ATP_INV_QTY
                            THEN 300 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9 + LC_FORC_QTY_10)) / NULLIFZERO(LC_FORC_QTY_11))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9) <= LC_ATP_INV_QTY
                            THEN 270 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8 + LC_FORC_QTY_9)) / NULLIFZERO(LC_FORC_QTY_10))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8) <= LC_ATP_INV_QTY
                            THEN 240 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7 + LC_FORC_QTY_8)) / NULLIFZERO(LC_FORC_QTY_9))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7) <= LC_ATP_INV_QTY
                            THEN 210 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6 + LC_FORC_QTY_7)) / NULLIFZERO(LC_FORC_QTY_8))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6) <= LC_ATP_INV_QTY
                            THEN 180 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5 + LC_FORC_QTY_6)) / NULLIFZERO(LC_FORC_QTY_7))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5) <= LC_ATP_INV_QTY
                            THEN 150 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4 + LC_FORC_QTY_5)) / NULLIFZERO(LC_FORC_QTY_6))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4) <= LC_ATP_INV_QTY
                            THEN 120 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3 + LC_FORC_QTY_4)) / NULLIFZERO(LC_FORC_QTY_5))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3) <= LC_ATP_INV_QTY
                            THEN 90 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2 + LC_FORC_QTY_3)) / NULLIFZERO(LC_FORC_QTY_4))
                        WHEN (LC_FORC_QTY_1 + LC_FORC_QTY_2) <= LC_ATP_INV_QTY
                            THEN 60 + (30 * (LC_ATP_INV_QTY - (LC_FORC_QTY_1 + LC_FORC_QTY_2)) / NULLIFZERO(LC_FORC_QTY_3))
                        WHEN (LC_FORC_QTY_1) <= LC_ATP_INV_QTY
                            THEN 30 + (30 * (LC_ATP_INV_QTY - LC_FORC_QTY_1) / NULLIFZERO(LC_FORC_QTY_2))
                        ELSE 30 * (LC_ATP_INV_QTY / NULLIFZERO(LC_FORC_QTY_1))
                        END AS LC_NETWORK_EST_DSI

                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.ATP_QTY ELSE 0 END) AS FACT_ATP_INV_QTY
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_1 ELSE 0 END) AS FACT_FORC_QTY_1
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_2 ELSE 0 END) AS FACT_FORC_QTY_2
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_3 ELSE 0 END) AS FACT_FORC_QTY_3
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_4 ELSE 0 END) AS FACT_FORC_QTY_4
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_5 ELSE 0 END) AS FACT_FORC_QTY_5
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_6 ELSE 0 END) AS FACT_FORC_QTY_6
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_7 ELSE 0 END) AS FACT_FORC_QTY_7
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_8 ELSE 0 END) AS FACT_FORC_QTY_8
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_9 ELSE 0 END) AS FACT_FORC_QTY_9
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_10 ELSE 0 END) AS FACT_FORC_QTY_10
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_11 ELSE 0 END) AS FACT_FORC_QTY_11
                    , SUM(CASE WHEN Q.FACILITY_ID LIKE 'N5%' THEN Q.FORC_SKU_QTY_12 ELSE 0 END) AS FACT_FORC_QTY_12
                    , CASE
                        WHEN FACT_ATP_INV_QTY > 0 AND (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10 + FACT_FORC_QTY_11 + FACT_FORC_QTY_12) <= 0
                            THEN -1
                        WHEN FACT_ATP_INV_QTY <= 0 AND (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10 + FACT_FORC_QTY_11 + FACT_FORC_QTY_12) <= 0
                            THEN -2
                        WHEN FACT_ATP_INV_QTY <= 0
                            THEN 0
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10 + FACT_FORC_QTY_11 + FACT_FORC_QTY_12) <= FACT_ATP_INV_QTY
                            THEN 360
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10 + FACT_FORC_QTY_11) <= FACT_ATP_INV_QTY
                            THEN 330 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10 + FACT_FORC_QTY_11)) / NULLIFZERO(FACT_FORC_QTY_12))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10) <= FACT_ATP_INV_QTY
                            THEN 300 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9 + FACT_FORC_QTY_10)) / NULLIFZERO(FACT_FORC_QTY_11))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9) <= FACT_ATP_INV_QTY
                            THEN 270 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8 + FACT_FORC_QTY_9)) / NULLIFZERO(FACT_FORC_QTY_10))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8) <= FACT_ATP_INV_QTY
                            THEN 240 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7 + FACT_FORC_QTY_8)) / NULLIFZERO(FACT_FORC_QTY_9))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7) <= FACT_ATP_INV_QTY
                            THEN 210 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6 + FACT_FORC_QTY_7)) / NULLIFZERO(FACT_FORC_QTY_8))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6) <= FACT_ATP_INV_QTY
                            THEN 180 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5 + FACT_FORC_QTY_6)) / NULLIFZERO(FACT_FORC_QTY_7))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5) <= FACT_ATP_INV_QTY
                            THEN 150 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4 + FACT_FORC_QTY_5)) / NULLIFZERO(FACT_FORC_QTY_6))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4) <= FACT_ATP_INV_QTY
                            THEN 120 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3 + FACT_FORC_QTY_4)) / NULLIFZERO(FACT_FORC_QTY_5))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3) <= FACT_ATP_INV_QTY
                            THEN 90 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2 + FACT_FORC_QTY_3)) / NULLIFZERO(FACT_FORC_QTY_4))
                        WHEN (FACT_FORC_QTY_1 + FACT_FORC_QTY_2) <= FACT_ATP_INV_QTY
                            THEN 60 + (30 * (FACT_ATP_INV_QTY - (FACT_FORC_QTY_1 + FACT_FORC_QTY_2)) / NULLIFZERO(FACT_FORC_QTY_3))
                        WHEN (FACT_FORC_QTY_1) <= FACT_ATP_INV_QTY
                            THEN 30 + (30 * (FACT_ATP_INV_QTY - FACT_FORC_QTY_1) / NULLIFZERO(FACT_FORC_QTY_2))
                        ELSE 30 * (FACT_ATP_INV_QTY / NULLIFZERO(FACT_FORC_QTY_1))
                        END AS FACT_NETWORK_EST_DSI

                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.ATP_QTY ELSE 0 END) AS OTHER_ATP_INV_QTY
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_1 ELSE 0 END) AS OTHER_FORC_QTY_1
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_2 ELSE 0 END) AS OTHER_FORC_QTY_2
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_3 ELSE 0 END) AS OTHER_FORC_QTY_3
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_4 ELSE 0 END) AS OTHER_FORC_QTY_4
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_5 ELSE 0 END) AS OTHER_FORC_QTY_5
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_6 ELSE 0 END) AS OTHER_FORC_QTY_6
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_7 ELSE 0 END) AS OTHER_FORC_QTY_7
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_8 ELSE 0 END) AS OTHER_FORC_QTY_8
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_9 ELSE 0 END) AS OTHER_FORC_QTY_9
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_10 ELSE 0 END) AS OTHER_FORC_QTY_10
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_11 ELSE 0 END) AS OTHER_FORC_QTY_11
                    , SUM(CASE WHEN Q.FACILITY_ID NOT LIKE 'N5%' AND Q.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN Q.FORC_SKU_QTY_12 ELSE 0 END) AS OTHER_FORC_QTY_12
                    , CASE
                        WHEN OTHER_ATP_INV_QTY > 0 AND (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10 + OTHER_FORC_QTY_11 + OTHER_FORC_QTY_12) <= 0
                            THEN -1
                        WHEN OTHER_ATP_INV_QTY <= 0 AND (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10 + OTHER_FORC_QTY_11 + OTHER_FORC_QTY_12) <= 0
                            THEN -2
                        WHEN OTHER_ATP_INV_QTY <= 0
                            THEN 0
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10 + OTHER_FORC_QTY_11 + OTHER_FORC_QTY_12) <= OTHER_ATP_INV_QTY
                            THEN 360
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10 + OTHER_FORC_QTY_11) <= OTHER_ATP_INV_QTY
                            THEN 330 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10 + OTHER_FORC_QTY_11)) / NULLIFZERO(OTHER_FORC_QTY_12))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10) <= OTHER_ATP_INV_QTY
                            THEN 300 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9 + OTHER_FORC_QTY_10)) / NULLIFZERO(OTHER_FORC_QTY_11))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9) <= OTHER_ATP_INV_QTY
                            THEN 270 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8 + OTHER_FORC_QTY_9)) / NULLIFZERO(OTHER_FORC_QTY_10))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8) <= OTHER_ATP_INV_QTY
                            THEN 240 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7 + OTHER_FORC_QTY_8)) / NULLIFZERO(OTHER_FORC_QTY_9))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7) <= OTHER_ATP_INV_QTY
                            THEN 210 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6 + OTHER_FORC_QTY_7)) / NULLIFZERO(OTHER_FORC_QTY_8))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6) <= OTHER_ATP_INV_QTY
                            THEN 180 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5 + OTHER_FORC_QTY_6)) / NULLIFZERO(OTHER_FORC_QTY_7))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5) <= OTHER_ATP_INV_QTY
                            THEN 150 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4 + OTHER_FORC_QTY_5)) / NULLIFZERO(OTHER_FORC_QTY_6))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4) <= OTHER_ATP_INV_QTY
                            THEN 120 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3 + OTHER_FORC_QTY_4)) / NULLIFZERO(OTHER_FORC_QTY_5))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3) <= OTHER_ATP_INV_QTY
                            THEN 90 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2 + OTHER_FORC_QTY_3)) / NULLIFZERO(OTHER_FORC_QTY_4))
                        WHEN (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2) <= OTHER_ATP_INV_QTY
                            THEN 60 + (30 * (OTHER_ATP_INV_QTY - (OTHER_FORC_QTY_1 + OTHER_FORC_QTY_2)) / NULLIFZERO(OTHER_FORC_QTY_3))
                        WHEN (OTHER_FORC_QTY_1) <= OTHER_ATP_INV_QTY
                            THEN 30 + (30 * (OTHER_ATP_INV_QTY - OTHER_FORC_QTY_1) / NULLIFZERO(OTHER_FORC_QTY_2))
                        ELSE 30 * (OTHER_ATP_INV_QTY / NULLIFZERO(OTHER_FORC_QTY_1))
                        END AS OTHER_NETWORK_EST_DSI

                FROM (

                SELECT
                    INV.MATL_ID
                    , INV.FACILITY_ID
                    , INV.DAY_DT AS MONTH_DT
                    , INV.INV_QTY_UOM
                    , ZEROIFNULL(INV.DEF_QTY) AS DEF_QTY
                    , ZEROIFNULL(INV.BACK_ORDER_QTY) AS BACK_ORDER_QTY
                    , ZEROIFNULL(INV.NET_BACK_ORDER_QTY) AS NET_BACK_ORDER_QTY
                    , ZEROIFNULL(INV.COMMIT_QTY) AS COMMIT_QTY
                    , ZEROIFNULL(INV.UN_COMMIT_QTY) AS UN_COMMIT_QTY
                    , ZEROIFNULL(INV.TOT_QTY) AS TOT_QTY
                    , ZEROIFNULL(INV.AVAIL_TO_PROM_QTY) AS ATP_QTY
                    , ZEROIFNULL(INV.STO_INBOUND_QTY) AS STO_INBOUND_QTY
                    , ZEROIFNULL(INV.IN_TRANS_QTY) AS IN_TRANS_QTY
                    , ZEROIFNULL(INV.STO_OUTBOUND_QTY) AS STO_OUTBOUND_QTY
                    , ZEROIFNULL(INV.IN_PROS_TO_CUST_QTY) AS IN_PROS_TO_CUST_QTY
                    , ZEROIFNULL(INV.OPEN_FACT_UNIT_QTY) AS OPEN_FACT_UNIT_QTY
                    , ZEROIFNULL(INV.FACT_SHR) AS FACT_SHR
                    , ZEROIFNULL(INV.RSVR_QTY) AS RSVR_QTY
                    , ZEROIFNULL(INV.QUAL_INSP_QTY) AS QUAL_INSP_QTY
                    , ZEROIFNULL(INV.BLOCKED_STK_QTY) AS BLOCKED_STK_QTY
                    , ZEROIFNULL(INV.RSTR_QTY) AS RSTR_QTY
                    , ZEROIFNULL(INV.STK_RET_QTY) AS STK_RET_QTY
                    , ZEROIFNULL(INV.SAFE_STK_QTY) AS SAFE_STK_QTY
                    , ZEROIFNULL(INV.COMMIT_ON_HAND_QTY) AS COMMIT_ON_HAND_QTY
                    , ZEROIFNULL(INV.COMMIT_IN_TRANS_QTY) AS COMMIT_IN_TRANS_QTY
                    , ZEROIFNULL(INV.PAST_DUE_QTY) AS PAST_DUE_QTY
                    , ZEROIFNULL(INV.DELAYED_QTY) AS DELAYED_QTY
                    , ZEROIFNULL(INV.TOT_QTY) - ZEROIFNULL(INV.BLOCKED_STK_QTY) - ZEROIFNULL(INV.QUAL_INSP_QTY) - ZEROIFNULL(INV.RSTR_QTY) + ZEROIFNULL(INV.STK_RET_QTY) AS UNRSTR_QTY
                    , SUM(CASE WHEN INV.DAY_DT / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_1
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 1) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_2
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 2) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_3
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 3) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_4
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 4) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_5
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 5) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_6
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 6) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_7
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 7) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_8
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 8) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_9
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 9) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_10
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 10) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_11
                    , SUM(CASE WHEN ADD_MONTHS(INV.DAY_DT, 11) / 100 = SF.FORC_MTH_DT / 100 THEN ZEROIFNULL(SF.FORC_SKU_QTY) ELSE 0 END) AS FORC_SKU_QTY_12
                    , CASE
                        WHEN ATP_QTY > 0 AND (FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 + FORC_SKU_QTY_10 + FORC_SKU_QTY_11 + FORC_SKU_QTY_12) <= 0
                            THEN -1
                        WHEN ATP_QTY <= 0 AND (FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 + FORC_SKU_QTY_10 + FORC_SKU_QTY_11 + FORC_SKU_QTY_12) <= 0
                            THEN -2
                        WHEN ATP_QTY <= 0
                            THEN 0
                        WHEN (FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 + FORC_SKU_QTY_10 + FORC_SKU_QTY_11 + FORC_SKU_QTY_12) <= ATP_QTY
                            THEN 360
                        WHEN (FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 + FORC_SKU_QTY_10 + FORC_SKU_QTY_11) <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6 - FORC_SKU_QTY_7 - FORC_SKU_QTY_8 - FORC_SKU_QTY_9 - FORC_SKU_QTY_10 - FORC_SKU_QTY_11) / NULLIFZERO(FORC_SKU_QTY_12) * 30) + 330
                        WHEN (FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 + FORC_SKU_QTY_10) <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6 - FORC_SKU_QTY_7 - FORC_SKU_QTY_8 - FORC_SKU_QTY_9 - FORC_SKU_QTY_10) / NULLIFZERO(FORC_SKU_QTY_11) * 30) + 300
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 + FORC_SKU_QTY_9 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6 - FORC_SKU_QTY_7 - FORC_SKU_QTY_8 - FORC_SKU_QTY_9) / NULLIFZERO(FORC_SKU_QTY_10) * 30) + 270
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 + FORC_SKU_QTY_8 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6 - FORC_SKU_QTY_7 - FORC_SKU_QTY_8) / NULLIFZERO(FORC_SKU_QTY_9) * 30) + 240
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 + FORC_SKU_QTY_7 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6 - FORC_SKU_QTY_7) / NULLIFZERO(FORC_SKU_QTY_8) * 30) + 210
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 + FORC_SKU_QTY_6 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5 - FORC_SKU_QTY_6) / NULLIFZERO(FORC_SKU_QTY_7) * 30) + 180
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 + FORC_SKU_QTY_5 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4 - FORC_SKU_QTY_5) / NULLIFZERO(FORC_SKU_QTY_6) * 30) + 150
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 + FORC_SKU_QTY_4 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3 - FORC_SKU_QTY_4) / NULLIFZERO(FORC_SKU_QTY_5) * 30) + 120
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 + FORC_SKU_QTY_3 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2 - FORC_SKU_QTY_3) / NULLIFZERO(FORC_SKU_QTY_4) * 30) + 90
                        WHEN FORC_SKU_QTY_1 + FORC_SKU_QTY_2 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1 - FORC_SKU_QTY_2) / NULLIFZERO(FORC_SKU_QTY_3) * 30) + 60
                        WHEN FORC_SKU_QTY_1 <= ATP_QTY
                            THEN((ATP_QTY - FORC_SKU_QTY_1) / NULLIFZERO(FORC_SKU_QTY_2) * 30) + 30
                        ELSE ATP_QTY / NULLIFZERO(FORC_SKU_QTY_1) * 30
                    END AS EST_DAYS_SUPPLY

                FROM (
                    SELECT
                        I.FACILITY_ID
                        , I.MATL_ID
                        , CAL.MONTH_DT AS DAY_DT
                        , CAL.MONTH_DT+15 AS IDES_OF_MTH
                        , ADD_MONTHS(CAL.MONTH_DT,1)-1 AS END_OF_MTH
                        , I.DEF_QTY
                        , I.BACK_ORDER_QTY
                        , I.NET_BACK_ORDER_QTY
                        , I.COMMIT_QTY
                        , I.UN_COMMIT_QTY
                        , I.TOT_QTY
                        , I.AVAIL_TO_PROM_QTY
                        , I.STO_INBOUND_QTY
                        , I.IN_TRANS_QTY
                        , I.STO_OUTBOUND_QTY
                        , I.IN_PROS_TO_CUST_QTY
                        , I.OPEN_FACT_UNIT_QTY
                        , I.FACT_SHR
                        , I.RSVR_QTY
                        , I.QUAL_INSP_QTY
                        , I.BLOCKED_STK_QTY
                        , I.RSTR_QTY
                        , I.STK_RET_QTY
                        , I.SAFE_STK_QTY
                        , I.COMMIT_ON_HAND_QTY
                        , I.COMMIT_IN_TRANS_QTY
                        , I.PAST_DUE_QTY
                        , I.DELAYED_QTY
                        , I.INV_QTY_UOM

                    FROM GDYR_VWS.NAT_INV_MTH_END I

                        INNER JOIN (
                            SELECT
                                DAY_DATE
                                , MONTH_DT
                                , BEGIN_DT
                                , TTL_DAYS_IN_MNTH
                                , CAL_MTH
                                , CAL_YR
                                , MNTH
                                , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                                , MNTH_NAME
                                , MNTH_DESCR
                                , CURRENT_DATE AS TODAY_DT
                                , CURRENT_DATE-1 AS YESTERDAY_DT

                            FROM GDYR_BI_VWS.GDYR_CAL

                            WHERE
                                DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                    AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                        ) CAL
                            ON CAL.DAY_DATE = I.DAY_DT
                            AND CAL.DAY_DATE < CAL.TODAY_DT

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = I.MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = I.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                    UNION

                    SELECT
                        I.FACILITY_ID
                        , I.MATL_ID
                        , CAL.MONTH_DT AS DAY_DT
                        , I.DAY_DT AS IDES_OF_MTH
                        , ADD_MONTHS(CAL.MONTH_DT,1)-1 AS END_OF_MTH
                        , I.DEF_QTY
                        , I.BACK_ORDER_QTY
                        , I.NET_BACK_ORDER_QTY
                        , I.COMMIT_QTY
                        , I.UN_COMMIT_QTY
                        , I.TOT_QTY
                        , I.AVAIL_TO_PROM_QTY
                        , I.STO_INBOUND_QTY
                        , I.IN_TRANS_QTY
                        , I.STO_OUTBOUND_QTY
                        , I.IN_PROS_TO_CUST_QTY
                        , I.OPEN_FACT_UNIT_QTY
                        , I.FACT_SHR
                        , I.RSVR_QTY
                        , I.QUAL_INSP_QTY
                        , I.BLOCKED_STK_QTY
                        , I.RSTR_QTY
                        , I.STK_RET_QTY
                        , I.SAFE_STK_QTY
                        , I.COMMIT_ON_HAND_QTY
                        , I.COMMIT_IN_TRANS_QTY
                        , I.PAST_DUE_QTY
                        , I.DELAYED_QTY
                        , I.INV_QTY_UOM

                    FROM GDYR_VWS.NAT_INV_CURR I

                        INNER JOIN (
                            SELECT
                                DAY_DATE
                                , MONTH_DT
                                , BEGIN_DT
                                , TTL_DAYS_IN_MNTH
                                , CAL_MTH
                                , CAL_YR
                                , MNTH
                                , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                                , MNTH_NAME
                                , MNTH_DESCR
                                , CURRENT_DATE AS TODAY_DT
                                , CURRENT_DATE-1 AS YESTERDAY_DT

                            FROM GDYR_BI_VWS.GDYR_CAL

                            WHERE
                                DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                    AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                        ) CAL
                            ON CAL.DAY_DATE = I.DAY_DT

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = I.MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = I.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'
                    ) INV

                    LEFT OUTER JOIN GDYR_VWS.SKU_FORC SF
                        ON INV.IDES_OF_MTH BETWEEN SF.EFF_DT AND SF.EXP_DT
                        AND SF.FACILITY_ID = INV.FACILITY_ID
                        AND SF.MATL_ID = INV.MATL_ID
                        AND SF.SBU_ID = 2

                GROUP BY
                    INV.MATL_ID
                    , INV.FACILITY_ID
                    , INV.DAY_DT
                    , INV.INV_QTY_UOM
                    , DEF_QTY
                    , BACK_ORDER_QTY
                    , NET_BACK_ORDER_QTY
                    , COMMIT_QTY
                    , UN_COMMIT_QTY
                    , TOT_QTY
                    , ATP_QTY
                    , STO_INBOUND_QTY
                    , IN_TRANS_QTY
                    , STO_OUTBOUND_QTY
                    , IN_PROS_TO_CUST_QTY
                    , OPEN_FACT_UNIT_QTY
                    , FACT_SHR
                    , RSVR_QTY
                    , QUAL_INSP_QTY
                    , BLOCKED_STK_QTY
                    , RSTR_QTY
                    , STK_RET_QTY
                    , SAFE_STK_QTY
                    , COMMIT_ON_HAND_QTY
                    , COMMIT_IN_TRANS_QTY
                    , PAST_DUE_QTY
                    , DELAYED_QTY
                    , UNRSTR_QTY

                    ) Q

                GROUP BY
                    Q.MATL_ID
                    , Q.MONTH_DT
                    , Q.INV_QTY_UOM
            ) INVE
        ON INVE.MATL_ID = MM.MATL_ID
        AND INVE.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                Q.MONTH_DT
                , Q.MATL_ID
                , Q.SRC_FACILITY_ID
                , CAST(COUNT(Q.SRC_FACILITY_ID) OVER (PARTITION BY Q.MONTH_DT, Q.MATL_ID) AS DECIMAL(15,3)) AS SRC_FACILITY_CNT
                , Q.LVL_GRP_ID
                , Q.LVL_GRP_CNT
                , Q.PROD_CREDIT_QTY
                , Q.TOT_PROD_CREDIT_QTY
                , Q.PROD_CREDIT_PCT
                , Q.PROD_PLAN_QTY
                , Q.GRN_TIRE_CTGY_CD
                , Q.SAFE_STK_QTY
                , Q.MATL_MIN_INV_RQT_QTY

                , Q.MATL_CYCL_STK_QTY
                , Q.MATL_MAX_INV_QTY
                , Q.MATL_AVG_INV_QTY
                , Q.MIN_RUN_QTY

            FROM (

            SELECT
                PRD.MONTH_DT
                , PRD.MATL_ID
                , PRD.SRC_FACILITY_ID

                , SF.LVL_GRP_ID
                , CAST(COUNT(SF.LVL_GRP_ID) OVER (PARTITION BY PRD.MONTH_DT, PRD.SRC_FACILITY_ID, PRD.MATL_ID) AS DECIMAL(15,3))AS LVL_GRP_CNT
                , PRD.CREDIT_QTY AS PROD_CREDIT_QTY
                , SUM(PRD.CREDIT_QTY) OVER (PARTITION BY PRD.MONTH_DT, PRD.MATL_ID) AS TOT_PROD_CREDIT_QTY
                , PRD.CREDIT_QTY / NULLIFZERO(TOT_PROD_CREDIT_QTY) AS PROD_CREDIT_PCT
                , PRD.PLAN_QTY AS PROD_PLAN_QTY
                , SF.GRN_TIRE_CTGY_CD
                , SF.SAFE_STK_QTY
                , SF.MATL_MIN_INV_RQT_QTY
                , SF.MATL_CYCL_STK_QTY
                , SF.MATL_MAX_INV_QTY
                , SF.MATL_AVG_INV_QTY
                , SF.MIN_RUN_QTY

            FROM (

                SELECT
                    PPC.MONTH_DT
                    , PPC.MATL_ID
                    , PPC.FACILITY_ID AS SRC_FACILITY_ID
                    , SUM(CASE WHEN PPC.QUERY_TYPE = 'C' THEN ZEROIFNULL(PPC.QUANTITY) ELSE 0 END) AS CREDIT_QTY
                    , SUM(CASE WHEN PPC.QUERY_TYPE = 'P' THEN ZEROIFNULL(PPC.QUANTITY) ELSE 0 END) AS PLAN_QTY

                FROM (

                    SELECT
                        CAST('C' AS CHAR(1)) AS QUERY_TYPE
                        , C.MONTH_DT
                        , PC.MATL_ID
                        , PC.FACILITY_ID
                        , SUM(PC.PROD_QTY) AS QUANTITY

                    FROM NA_BI_VWS.PROD_CREDIT_DY PC

                        INNER JOIN (
                            SELECT
                                DAY_DATE
                                , MONTH_DT
                                , BEGIN_DT
                                , TTL_DAYS_IN_MNTH
                                , CAL_MTH
                                , CAL_YR
                                , MNTH
                                , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                                , MNTH_NAME
                                , MNTH_DESCR
                                , CURRENT_DATE AS TODAY_DT
                                , CURRENT_DATE-1 AS YESTERDAY_DT

                            FROM GDYR_BI_VWS.GDYR_CAL

                            WHERE
                                DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                    AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                        ) C
                            ON C.DAY_DATE = PC.PROD_DT

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = PC.MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = PC.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                    WHERE
                        PC.PROD_QTY <> 0

                    GROUP BY
                        QUERY_TYPE
                        , C.MONTH_DT
                        , PC.MATL_ID
                        , PC.FACILITY_ID

                    UNION ALL

                    SELECT
                        CAST('P' AS CHAR(1)) AS QUERY_TYPE
                        , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
                        , PP.PLN_MATL_ID AS MATL_ID
                        , PP.FACILITY_ID
                        , SUM(CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3))) AS QUANTITY

                    FROM GDYR_VWS.PROD_PLN PP

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = PP.PLN_MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = PP.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                        INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
                            ON C.MEAS_DT = PP.PROD_WK_DT
                            AND C.FNL_PERDY_ID = 'D'
                            AND C.PERDY_ID = 'W'
                            AND C.EXP_DT = DATE '5555-12-31'
                            --AND C.SBU_ID = 2
                            -- BEGINNING OF PREVIOUS YEAR
                            AND C.POSTED_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE)

                    WHERE
                        PP.PROD_PLN_CD IN ('0', '7')
                        AND CAST(PP.PROD_WK_DT-3 AS DATE) BETWEEN PP.EFF_DT AND PP.EXP_DT
                        AND PP.PROD_WK_DT <= CURRENT_DATE

                    GROUP BY
                        QUERY_TYPE
                        , MONTH_DT
                        , PP.PLN_MATL_ID
                        , PP.FACILITY_ID

                    UNION ALL

                    -- FUTURE WEEKS WITHIN PLANNER HORIZON

                    SELECT
                        CAST('P' AS CHAR(1)) AS QUERY_TYPE
                        , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
                        , PP.PLN_MATL_ID AS MATL_ID
                        , PP.FACILITY_ID
                        , SUM(CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3))) AS QUANTITY

                    FROM GDYR_VWS.PROD_PLN PP

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = PP.PLN_MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = PP.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                        INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
                            ON C.MEAS_DT = PP.PROD_WK_DT
                            AND C.FNL_PERDY_ID = 'D'
                            AND C.PERDY_ID = 'W'
                            AND C.EXP_DT = DATE '5555-12-31'
                            --AND C.SBU_ID = 2

                    WHERE
                        PP.PROD_PLN_CD IN ('0', '7')
                        AND PP.EXP_DT = DATE '5555-12-31'
                        AND PP.PROD_WK_DT BETWEEN CURRENT_DATE+1 AND CURRENT_DATE+56

                    GROUP BY
                        QUERY_TYPE
                        , MONTH_DT
                        , PP.PLN_MATL_ID
                        , PP.FACILITY_ID

                    UNION ALL

                    -- PLAN CODE A, SNP PRODUCTION PLANS

                    SELECT
                        CAST('P' AS CHAR(1)) AS QUERY_TYPE
                        , C.POSTED_DT - (EXTRACT(DAY FROM C.POSTED_DT)-1) AS MONTH_DT
                        , PP.PLN_MATL_ID AS MATL_ID
                        , PP.FACILITY_ID
                        , SUM(CAST(PP.PLN_QTY / 7.00 AS DECIMAL(15,3))) AS QUANTITY

                    FROM GDYR_VWS.PROD_PLN PP

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = PP.PLN_MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'
                            --AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08','09')

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = PP.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                        INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR C
                            ON C.MEAS_DT = PP.PROD_WK_DT
                            AND C.FNL_PERDY_ID = 'D'
                            AND C.PERDY_ID = 'W'
                            AND C.EXP_DT = DATE '5555-12-31'
                            --AND C.SBU_ID = 2
                            -- ROLLING 6 MONTHS FORWARD
                            AND C.POSTED_DT <= ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))

                    WHERE
                        PP.PROD_PLN_CD = 'A'
                        AND PP.EXP_DT = DATE '5555-12-31'
                        AND PP.PROD_WK_DT > CURRENT_DATE+56

                    GROUP BY
                        QUERY_TYPE
                        , MONTH_DT
                        , PP.PLN_MATL_ID
                        , PP.FACILITY_ID

                    ) PPC

                GROUP BY
                    PPC.MONTH_DT
                    , PPC.MATL_ID
                    , PPC.FACILITY_ID

                ) PRD

                LEFT OUTER JOIN (
                    SELECT
                        CAL.MONTH_DT
                        , FMC.MATL_ID
                        , FMC.FACILITY_ID AS SRC_FACILITY_ID
                        , FMC.LVL_GRP_ID
                        , FMC.LVL_DESIGN_EFF_DT
                        , FMC.GRN_TIRE_CTGY_CD
                        , FMC.SAFE_STK_QTY
                        , FMC.MATL_MIN_INV_RQT_QTY
                        , FMC.MATL_CYCL_STK_QTY
                        , FMC.MATL_MAX_INV_QTY
                        , FMC.MATL_AVG_INV_QTY
                        , FMC.MIN_RUN_QTY

                    FROM (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL

                        INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                            ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                            AND FMC.ORIG_SYS_ID = 2
                            AND FMC.LVL_DESIGN_STA_CD = 'A'

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = FMC.MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = FMC.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                    WHERE
                        CAL.DAY_DATE = CAL.MONTH_DT
                        AND CAL.DAY_DATE < CAL.TODAY_DT

                    QUALIFY
                        ROW_NUMBER() OVER (PARTITION BY CAL.MONTH_DT, FMC.MATL_ID, FMC.FACILITY_ID, FMC.LVL_GRP_ID ORDER BY FMC.LVL_DESIGN_EFF_DT DESC) = 1

                    UNION ALL

                    SELECT
                        CAL.MONTH_DT
                        , Q.MATL_ID
                        , Q.FACILITY_ID
                        , Q.LVL_GRP_ID
                        , Q.LVL_DESIGN_EFF_DT
                        , Q.GRN_TIRE_CTGY_CD
                        , Q.SAFE_STK_QTY
                        , Q.MATL_MIN_INV_RQT_QTY
                        , Q.MATL_CYCL_STK_QTY
                        , Q.MATL_MAX_INV_QTY
                        , Q.MATL_AVG_INV_QTY
                        , Q.MIN_RUN_QTY

                    FROM (
                        SELECT
                            DAY_DATE
                            , MONTH_DT
                            , BEGIN_DT
                            , TTL_DAYS_IN_MNTH
                            , CAL_MTH
                            , CAL_YR
                            , MNTH
                            , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                            , MNTH_NAME
                            , MNTH_DESCR
                            , CURRENT_DATE AS TODAY_DT
                            , CURRENT_DATE-1 AS YESTERDAY_DT

                        FROM GDYR_BI_VWS.GDYR_CAL

                        WHERE
                            DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                                AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
                    ) CAL

                        INNER JOIN (
                            SELECT
                                FMC.MATL_ID
                                , FMC.FACILITY_ID
                                , FMC.LVL_GRP_ID
                                , FMC.LVL_DESIGN_EFF_DT
                                , FMC.GRN_TIRE_CTGY_CD
                                , FMC.SAFE_STK_QTY
                                , FMC.MATL_MIN_INV_RQT_QTY
                                , FMC.MATL_CYCL_STK_QTY
                                , FMC.MATL_MAX_INV_QTY
                                , FMC.MATL_AVG_INV_QTY
                                , FMC.MIN_RUN_QTY

                            FROM NA_VWS.FACL_MATL_CYCASGN FMC

                                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                                    ON M.MATL_ID = FMC.MATL_ID
                                    AND M.PBU_NBR IN ('01', '03')
                                    AND M.EXT_MATL_GRP_ID = 'TIRE'

                                INNER JOIN GDYR_VWS.FACILITY F
                                    ON F.FACILITY_ID = FMC.FACILITY_ID
                                    AND F.EXP_DT = DATE '5555-12-31'
                                    AND F.ORIG_SYS_ID = 2
                                    AND F.LANG_ID = 'EN'
                                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                                    AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                                    AND F.DISTR_CHAN_CD = '81'

                            WHERE
                                FMC.EXP_DT = DATE '5555-12-31'
                                AND FMC.ORIG_SYS_ID = 2
                                AND FMC.LVL_DESIGN_STA_CD = 'A'

                            QUALIFY
                                ROW_NUMBER() OVER (PARTITION BY FMC.MATL_ID, FMC.FACILITY_ID, FMC.LVL_GRP_ID ORDER BY FMC.LVL_DESIGN_EFF_DT DESC) = 1
                        ) Q
                        ON 1=1

                    WHERE
                        CAL.DAY_DATE = CAL.MONTH_DT
                        AND CAL.DAY_DATE >= CAL.TODAY_DT

                        ) SF
                    ON SF.SRC_FACILITY_ID = PRD.SRC_FACILITY_ID
                    AND SF.MATL_ID = PRD.MATL_ID
                    AND SF.MONTH_DT = PRD.MONTH_DT

            QUALIFY
                ROW_NUMBER() OVER (PARTITION BY PRD.MONTH_DT, PRD.MATL_ID, PRD.SRC_FACILITY_ID ORDER BY SF.LVL_DESIGN_EFF_DT DESC) = 1

                ) Q
            ) MTI
        ON MTI.MATL_ID = MM.MATL_ID
        AND MTI.MONTH_DT = GC.MONTH_DT

    LEFT OUTER JOIN (
            SELECT
                CAL.MONTH_DT
                , FMC.MATL_ID

                , MAX(FMC.MATL_MIN_INV_RQT_QTY) AS MATL_MIN_INV_RQT_QTY
                , MAX(FMC.MATL_MAX_INV_QTY) AS MATL_MAX_INV_QTY


            FROM (
                SELECT
                    DAY_DATE
                    , MONTH_DT
                    , BEGIN_DT
                    , TTL_DAYS_IN_MNTH
                    , CAL_MTH
                    , CAL_YR
                    , MNTH
                    , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                    , MNTH_NAME
                    , MNTH_DESCR
                    , CURRENT_DATE AS TODAY_DT
                    , CURRENT_DATE-1 AS YESTERDAY_DT

                FROM GDYR_BI_VWS.GDYR_CAL

                WHERE
                    DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                        AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
            ) CAL

                INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                    ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                    AND FMC.ORIG_SYS_ID = 2
                    AND FMC.LVL_DESIGN_STA_CD = 'A'

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = FMC.MATL_ID
                    AND M.PBU_NBR IN ('01', '03')
                    AND M.EXT_MATL_GRP_ID = 'TIRE'

                INNER JOIN GDYR_VWS.FACILITY F
                    ON F.FACILITY_ID = FMC.FACILITY_ID
                    AND F.EXP_DT = DATE '5555-12-31'
                    AND F.ORIG_SYS_ID = 2
                    AND F.LANG_ID = 'EN'
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                    AND F.DISTR_CHAN_CD = '81'
            WHERE
                CAL.DAY_DATE = CAL.MONTH_DT
                -- BEGINNING OF LAST YEAR TO END OF +6 MONTHS
                AND CAL.DAY_DATE < CAL.TODAY_DT

            GROUP BY
                CAL.MONTH_DT
                , FMC.MATL_ID

            UNION ALL

            SELECT
                CAL.MONTH_DT
                , Q.MATL_ID

                , MAX(Q.MATL_MIN_INV_RQT_QTY) AS MATL_MIN_INV_RQT_QTY
                , MAX(Q.MATL_MAX_INV_QTY) AS MATL_MAX_INV_QTY

            FROM (
                SELECT
                    DAY_DATE
                    , MONTH_DT
                    , BEGIN_DT
                    , TTL_DAYS_IN_MNTH
                    , CAL_MTH
                    , CAL_YR
                    , MNTH
                    , (MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
                    , MNTH_NAME
                    , MNTH_DESCR
                    , CURRENT_DATE AS TODAY_DT
                    , CURRENT_DATE-1 AS YESTERDAY_DT

                FROM GDYR_BI_VWS.GDYR_CAL

                WHERE
                    DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, -13)) -1)
                        AND ADD_MONTHS(CURRENT_DATE-1, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE-1, 7))
            ) CAL

                INNER JOIN (
                    SELECT
                        FMC.MATL_ID
                        , FMC.FACILITY_ID
                        , FMC.LVL_GRP_ID
                        , FMC.LVL_DESIGN_EFF_DT
                        , FMC.GRN_TIRE_CTGY_CD
                        , FMC.SAFE_STK_QTY
                        , FMC.MATL_MIN_INV_RQT_QTY
                        , FMC.MATL_CYCL_STK_QTY
                        , FMC.MATL_MAX_INV_QTY
                        , FMC.MATL_AVG_INV_QTY
                        , FMC.MIN_RUN_QTY

                    FROM NA_VWS.FACL_MATL_CYCASGN FMC

                        INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                            ON M.MATL_ID = FMC.MATL_ID
                            AND M.PBU_NBR IN ('01', '03')
                            AND M.EXT_MATL_GRP_ID = 'TIRE'

                        INNER JOIN GDYR_VWS.FACILITY F
                            ON F.FACILITY_ID = FMC.FACILITY_ID
                            AND F.EXP_DT = DATE '5555-12-31'
                            AND F.ORIG_SYS_ID = 2
                            AND F.LANG_ID = 'EN'
                            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                            AND F.PURCH_ORG_ID IN ('N701', 'N702', 'N703')
                            AND F.DISTR_CHAN_CD = '81'

                    WHERE
                        FMC.EXP_DT = DATE '5555-12-31'
                        AND FMC.ORIG_SYS_ID = 2
                        AND FMC.LVL_DESIGN_STA_CD = 'A'

                    QUALIFY
                        ROW_NUMBER() OVER (PARTITION BY FMC.MATL_ID, FMC.FACILITY_ID, FMC.LVL_GRP_ID ORDER BY FMC.LVL_DESIGN_EFF_DT DESC) = 1
                ) Q
                ON 1=1

            WHERE
                CAL.DAY_DATE = CAL.MONTH_DT
                AND CAL.MONTH_DT > CAL.YESTERDAY_DT

            GROUP BY
                CAL.MONTH_DT
                , Q.MATL_ID
        ) INVMM
        ON INVMM.MONTH_DT = GC.MONTH_DT
        AND INVMM.MATL_ID = MM.MATL_ID

    LEFT OUTER JOIN (
        SELECT
            MSA.MATL_ID
            , MSA.FACILITY_ID AS SRC_FACILITY_ID

        FROM GDYR_VWS.MATL_SRC_ALLOC MSA

            INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                ON M.MATL_ID = MSA.MATL_ID
                AND M.PBU_NBR IN ('01', '03')
                AND M.EXT_MATL_GRP_ID = 'TIRE'

        WHERE
            MSA.SRC_SYS_ID = 2
            AND MSA.EXP_DT >= ADD_MONTHS(CURRENT_DATE-1, -36)

        QUALIFY
            ROW_NUMBER() OVER (PARTITION BY MSA.MATL_ID ORDER BY MSA.EXP_DT DESC) = 1
            ) MAXSF
        ON MAXSF.MATL_ID = MM.MATL_ID

WHERE
    GC.DAY_DATE = GC.MONTH_DT

ORDER BY
    MM.MATL_ID
    , GC.MONTH_DT
