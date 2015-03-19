SELECT
    MATLS.MATL_ID
    , MATLS.PBU_NBR
    , MATLS.CATEGORY
    , MATLS.TIER
    , MATLS.FACILITY_ID AS SHIP_FACILITY_ID
    , SF.SRC_FACILITY_ID
    , COUNT(*) OVER (PARTITION BY MATLS.MATL_ID, MATLS.FACILITY_ID) AS SRC_FACILITY_CNT
    , COUNT(*) OVER (PARTITION BY MATLS.MATL_ID) AS SHIP_FACILITY_CNT
    , OTD.METRIC_ORDER_QTY
    , OTD.METRIC_HIT_QTY
    , OTD.METRIC_ONTIME_QTY
    , OTD.NO_STOCK_HIT_QTY
    , OTD.CANCEL_HIT_QTY
    , OTD.NO_STOCK_AND_CANCEL_HIT_QTY

FROM (

    SELECT
        ODC.MATL_ID
        , MATL.PBU_NBR
        , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS CATEGORY
        , MATL.MKT_CTGY_PROD_GRP_NAME AS TIER
        , ODC.FACILITY_ID
        
        , ODC.QTY_UNIT_MEAS_ID
        , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
        , SUM(OOL.UNCNFRM_QTY) AS UNCNFRM_QTY
        , SUM(OOL.BACK_ORDER_QTY) AS BACK_ORDER_QTY

    FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL

        INNER JOIN NA_BI_VWS.ORDER_DETAIL ODC
            ON ODC.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
            AND ODC.ORDER_ID = OOL.ORDER_ID
            AND ODC.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
            AND ODC.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
            AND ODC.EXP_DT = DATE '5555-12-31'
            AND ODC.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-2 AS CHAR(4))
            AND ODC.ORDER_CAT_ID = 'C'
            AND ODC.PO_TYPE_ID <> 'RO'
            AND ODC.REJ_REAS_ID = ''

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = ODC.MATL_ID

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
            AND CUST.OWN_CUST_ID IN ('00A0006054', '00A0006090')

        LEFT OUTER JOIN NA_BI_VWS.FACILITY_MATL_INVENTORY INV
            ON INV.FACILITY_ID = ODC.FACILITY_ID
            AND INV.MATL_ID = ODC.MATL_ID
            AND INV.DAY_DT = (CURRENT_DATE-1)

    WHERE
        OOL.OPEN_CNFRM_QTY > 0
        OR OOL.UNCNFRM_QTY > 0
        OR OOL.BACK_ORDER_QTY > 0

    GROUP BY
        ODC.MATL_ID
        , MATL.PBU_NBR
        , CATEGORY
        , TIER
        , ODC.FACILITY_ID
        , ODC.QTY_UNIT_MEAS_ID

    ) MATLS

    LEFT OUTER JOIN (
            SELECT
                FM.FACILITY_ID AS SHIP_FACILITY_ID
                , FM.MATL_ID AS MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , CAST( CASE FM.SPCL_PRCU_TYP_CD
                    WHEN 'AA' THEN 'N501'
                    WHEN 'AB' THEN 'N502'
                    WHEN 'AC' THEN 'N503'
                    WHEN 'AD' THEN 'N504'
                    WHEN 'AE' THEN 'N505'
                    WHEN 'AH' THEN 'N508'
                    WHEN 'AI' THEN 'N509'
                    WHEN 'AJ' THEN 'N510'
                    WHEN 'AM' THEN 'N513'
                    WHEN 'S1' THEN 'N6BD'
                    WHEN 'S2' THEN 'N6BE'
                    WHEN 'S4' THEN 'N6BS'
                    WHEN 'S6' THEN 'N6J2'
                    WHEN 'S7' THEN 'N6J3'
                    WHEN 'S8' THEN 'N6J4'
                    WHEN 'S9' THEN 'N6J7'
                    WHEN 'SA' THEN 'N526'
                    WHEN 'SC' THEN 'N6A1'
                    WHEN 'SD' THEN 'N6A2'
                    WHEN 'SE' THEN 'N6A3'
                    WHEN 'SF' THEN 'N6A4'
                    WHEN 'SG' THEN 'N6A6'
                    WHEN 'SH' THEN 'N6A8'
                    WHEN 'SI' THEN 'N6A9'
                    WHEN 'SJ' THEN 'N6AA'
                    WHEN 'SL' THEN 'N6AC'
                    WHEN 'SM' THEN 'N6AE'
                    WHEN 'SN' THEN 'N6AG'
                    WHEN 'SO' THEN 'N6AH'
                    WHEN 'SQ' THEN 'N6AK'
                    WHEN 'SR' THEN 'N6AL'
                    WHEN 'SS' THEN 'N6J8'
                    WHEN 'ST' THEN 'N6AO'
                    WHEN 'SU' THEN 'N6AQ'
                    WHEN 'SV' THEN 'N6AR'
                    WHEN 'SW' THEN 'N6AS'
                    WHEN 'SX' THEN 'N6AT'
                    WHEN 'SY' THEN 'N6AX'
                    WHEN 'SZ' THEN 'N6BB'
                    WHEN 'WA' THEN 'N637'
                    WHEN 'WB' THEN 'N636'
                    WHEN 'WF' THEN 'N623'
                    WHEN 'WG' THEN 'N639'
                    WHEN 'WH' THEN 'N699'
                    WHEN 'WK' THEN 'N602'
                    ELSE COALESCE(FMX.FACILITY_ID, '')
                END AS CHAR(4) ) AS SRC_FACILITY_ID

            FROM GDYR_VWS.FACILITY_MATL FM

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = FM.MATL_ID
                    AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                    AND M.MATL_TYPE_ID IN ('PCTL', 'ACCT')

                LEFT OUTER JOIN GDYR_VWS.FACILITY_MATL FMX
                    ON FMX.MATL_ID = FM.MATL_ID
                    AND FMX.ORIG_SYS_ID = 2
                    AND FMX.EXP_DT = DATE '5555-12-31'
                    AND FMX.MRP_TYPE_ID = 'X0'
                
                INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = FM.FACILITY_ID
                    AND F.SALES_ORG_CD <> 'N340' -- EXCLUDE COWD LOCATIONS

            WHERE
                FM.EXP_DT = DATE '5555-12-31'
                AND FM.MRP_TYPE_ID = 'XB'
                AND FM.ORIG_SYS_ID = 2
                AND FMX.EXP_DT = DATE '5555-12-31'
                --AND SRC_FACILITY_ID = ''

            GROUP BY
                FM.FACILITY_ID
                , FM.MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , SRC_FACILITY_ID
            ) SF
        ON SF.SHIP_FACILITY_ID = MATLS.FACILITY_ID
        AND SF.MATL_ID = MATLS.MATL_ID

    LEFT OUTER JOIN (
            SELECT
                POL.MATL_ID
                , POL.SHIP_FACILITY_ID
                , SUM(ZEROIFNULL(POL.CURR_ORD_QTY)) AS METRIC_ORDER_QTY
                , SUM(ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS METRIC_HIT_QTY
                , SUM(ZEROIFNULL(POL.CURR_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY)) AS METRIC_ONTIME_QTY
                , SUM(ZEROIFNULL(POL.IF_HIT_NS_QTY)) AS NO_STOCK_HIT_QTY
                , SUM(ZEROIFNULL(POL.IF_HIT_CO_QTY)) AS CANCEL_HIT_QTY
                , NO_STOCK_HIT_QTY + CANCEL_HIT_QTY AS NO_STOCK_AND_CANCEL_HIT_QTY
                
            FROM NA_BI_VWS.PRFCT_ORD_LINE POL
                    
            WHERE
                POL.CMPL_DT BETWEEN (CURRENT_DATE-1) - (EXTRACT(DAY FROM CURRENT_DATE-1)-1) AND CURRENT_DATE-1
                AND POL.CMPL_IND = 1
                AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99
                AND POL.PO_TYPE_ID <> 'RO'
                AND POL.CUST_GRP_ID <> '3R'
                
            GROUP BY
                POL.MATL_ID
                , POL.SHIP_FACILITY_ID
            ) OTD
        ON OTD.MATL_ID = MATLS.MATL_ID
        AND OTD.SHIP_FACILITY_ID = MATLS.FACILITY_ID
