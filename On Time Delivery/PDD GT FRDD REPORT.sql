﻿SELECT 
    OOSL.ORDER_FISCAL_YR
    , OOSL.ORDER_ID
    , OOSL.ORDER_LINE_NBR
    , OOSL.SCHED_LINE_NBR
    
    , OOSL.CREDIT_HOLD_FLG
    
    , ODC.SHIP_TO_CUST_ID
    , CUST.CUST_NAME AS SHIP_TO_CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , ODC.SALES_ORG_CD
    , ODC.DISTR_CHAN_CD
    , ODC.CUST_GRP_ID
    , CUST.TIRE_CUST_TYP_CD
    
    , NULLIF(ODC.PO_TYPE_ID, '') AS PO_TYPE_ID
    , ODC.ORDER_CAT_ID
    , ODC.ORDER_TYPE_ID
    , CASE WHEN ODC.CANCEL_IND = 'Y' THEN 'Y' ELSE 'N' END AS CANCEL_IND
    , CASE WHEN ODC.RETURN_IND = 'Y' THEN 'Y' ELSE 'N' END AS RETURN_IND
    
    , ODC.CUST_GRP2_CD
    
    , MATL.MATL_NO_8
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
    , MATL.TIC_CD
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , MATL.EXT_MATL_GRP_ID
    , MATL.MATL_PRTY_DESCR
    , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS MKT_AREA
    , MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS MKT_GRP
    , MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS PROD_GRP
    , MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS PROD_LINE
    
    , ODC.ITEM_CAT_ID
    , SP.SRC_FACILITY_ID
    , MATL.MATL_STA_ID
    
    , ODC.ORDER_DT
    , SL.PLN_DELIV_DT AS FIRST_DATE
    , ODC.CUST_RDD AS ORDD
    , ODC.FRST_RDD AS FRDD
    , ODC.FRST_PROM_DELIV_DT AS FCDD
    , ODC.PLN_MATL_AVL_DT
    , ODC.PLN_GOODS_ISS_DT
    , ODC.PLN_DELIV_DT
    
    , CAST(CAST(ODC.PLN_DELIV_DT - FRDD AS INTEGER) AS FORMAT '-9(3)') AS PDD_TO_FRDD_DAYS
    , CAST(CAST(FRDD - CURRENT_DATE AS INTEGER) AS FORMAT '-9(3)') AS FRDD_LEAD_DAYS
    , CAST(CAST(FRDD_LEAD_DAYS / 7 AS INTEGER) AS FORMAT '-9(3)') AS FRDD_LEAD_WEEKS
    
    , CAST(CAST(ODC.PLN_DELIV_DT - FCDD AS INT) AS FORMAT '-9(3)') AS PDD_TO_FCDD_DAYS
    , CAST(CAST(CURRENT_DATE AS FORMAT 'YYYY-MMM-DD') AS CHAR(11)) AS REPORTING_DT
    , CAST(CAST(FCDD - CURRENT_DATE AS INT) AS FORMAT '-9(3)') AS FCDD_LEAD_DAYS
    , CAST(CAST(FCDD_LEAD_DAYS / 7 AS INT) AS FORMAT '-9(3)') AS FCDD_LEAD_WKS
    
    , CASE
        WHEN OOSL.OPEN_CNFRM_QTY > 0
            THEN 'C'
        WHEN OOSL.UNCNFRM_QTY > 0
            THEN 'U'
        WHEN OOSL.BACK_ORDER_QTY > 0
            THEN 'B'
        END AS LINE_STATUS_CD
    , ZEROIFNULL(OOSL.OPEN_CNFRM_QTY) + ZEROIFNULL(OOSL.UNCNFRM_QTY) + ZEROIFNULL(OOSL.BACK_ORDER_QTY) AS OPEN_QTY
    
    , CAST(OOSL.OPEN_CNFRM_QTY * MATL.UNIT_WT AS DECIMAL(15, 3)) AS OPEN_CONFIRMED_WT
    , ODC.QTY_UNIT_MEAS_ID
    
    , ODC.ORDER_DELIV_BLK_CD
    , ODC.DELIV_BLK_CD
    
    , ODC.DELIV_PRTY_ID
    , ODC.SHIP_COND_ID
    
    , ODC.SHIP_PT_ID
    , ODC.FACILITY_ID
    , ZEROIFNULL(SP.AVAIL_TO_PROM_QTY) AS CURR_LC_ATP_QTY

FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
        ON ODC.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
        AND ODC.ORDER_ID = OOSL.ORDER_ID
        AND ODC.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
        AND ODC.SCHED_LINE_NBR = OOSL.SCHED_LINE_NBR
        AND ODC.ORDER_CAT_ID = 'C'
        AND ODC.RO_PO_TYPE_IND = 'N'
        AND ODC.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE)-2 AS CHAR(4))
        AND ODC.REJ_REAS_ID = ''
    
    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.PBU_NBR IN ('01', '07') --IN ('01', '03', '04', '05', '07', '08', '09')
        AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
        AND CUST.TIRE_CUST_TYP_CD = 'OE'

    INNER JOIN NA_BI_VWS.ORDER_DETAIL SL
        ON SL.ORDER_FISCAL_YR = OOSL.ORDER_FISCAL_YR
        AND SL.ORDER_ID = OOSL.ORDER_ID
        AND SL.ORDER_LINE_NBR = OOSL.ORDER_LINE_NBR
        AND SL.SCHED_LINE_NBR = 1
        AND SL.EXP_DT = DATE '5555-12-31'
        AND SL.ORDER_CAT_ID = 'C'
        AND SL.RO_PO_TYPE_IND = 'N'
        AND SL.ORDER_FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE)-2 AS CHAR(4))
        AND SL.REJ_REAS_ID = ''

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
            , FMI.AVAIL_TO_PROM_QTY
            , FMI.BACK_ORDER_QTY
            , FMI.COMMIT_QTY
            , FMI.UN_COMMIT_QTY
            , FMI.TOT_QTY
            , FMI.STO_INBOUND_QTY
            , FMI.IN_TRANS_QTY
            , FMI.STO_OUTBOUND_QTY
            , FMI.IN_PROS_TO_CUST_QTY
            , FMI.RSVR_QTY
            , FMI.BLOCKED_STK_QTY
            , FMI.RSTR_QTY
            , FMI.STK_RET_QTY
            , FMI.SAFE_STK_QTY
            , FMI.COMMIT_ON_HAND_QTY
            , FMI.COMMIT_IN_TRANS_QTY
            , FMI.PAST_DUE_QTY
            , FMI.DELAYED_QTY
            , FMI.INV_QTY_UOM

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
            
            LEFT OUTER JOIN NA_BI_VWS.FACILITY_MATL_INVENTORY FMI
                ON FMI.FACILITY_ID = FM.FACILITY_ID
                AND FMI.MATL_ID = FM.MATL_ID
                AND FMI.DAY_DT = (CURRENT_DATE-1)
            
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
            , FMI.AVAIL_TO_PROM_QTY
            , FMI.BACK_ORDER_QTY
            , FMI.COMMIT_QTY
            , FMI.UN_COMMIT_QTY
            , FMI.TOT_QTY
            , FMI.STO_INBOUND_QTY
            , FMI.IN_TRANS_QTY
            , FMI.STO_OUTBOUND_QTY
            , FMI.IN_PROS_TO_CUST_QTY
            , FMI.RSVR_QTY
            , FMI.BLOCKED_STK_QTY
            , FMI.RSTR_QTY
            , FMI.STK_RET_QTY
            , FMI.SAFE_STK_QTY
            , FMI.COMMIT_ON_HAND_QTY
            , FMI.COMMIT_IN_TRANS_QTY
            , FMI.PAST_DUE_QTY
            , FMI.DELAYED_QTY
            , FMI.INV_QTY_UOM

            ) SP
        ON SP.MATL_ID = MATL.MATL_ID
        AND SP.SHIP_FACILITY_ID = ODC.FACILITY_ID

WHERE
    (OOSL.OPEN_CNFRM_QTY > 0 AND ODC.PLN_DELIV_DT > ODC.FRST_RDD)
    OR OOSL.UNCNFRM_QTY > 0
    OR OOSL.BACK_ORDER_QTY > 0

ORDER BY
    1,2,3


