﻿SELECT
    S.PBU_NBR
    , S.OWN_CUST_ID
    , S.OWN_CUST_NAME
    , S.OE_REPL_IND
    , S.ORDER_LN_CRT_DT
    , SUM(S.ORD_QTY) AS ORDER_QTY
    , ORDER_QTY - CANCEL_QTY AS NET_ORDER_QTY
    , SUM(S.CAN_QTY) AS CANCEL_QTY
    , SUM(S.UNCNFRM_QTY) AS UNCNFRM_QTY
    , SUM(S.BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , SUM(S.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , SUM(S.OTHR_ORDER_QTY) AS OTH_ORDER_QTY
    , SUM(S.CNFRM_CURR_QTY) AS CNFRM_CURR_QTY
    , SUM(S.CNFRM_FUTR_QTY) AS CNFRM_FUTR_QTY
    , SUM(S.IN_PROC_QTY) AS IN_PROC_QTY
    , SUM(S.ACTL_SHIP_CURR_MTH_QTY) AS SHIPPED_QTY
    , SUM(S.IN_PROC_CURR_QTY) AS IN_PROC_QTY_CURR
    , SUM(S.IN_PROC_FUTR_QTY) AS IN_PROC_QTY_FUTR
   
FROM (
 
SELECT
    O.ORDER_FISCAL_YR
    , O.ORDER_ID
    , O.ORDER_LINE_NBR
 
    , O.ORDER_DT
    , O.ORDER_CRT_TM
    , O.ORDER_LN_CRT_DT
    , O.ORDER_LN_CRT_TM
    , O.ORDER_CREATOR
 
    , O.CUST_PO_NBR
    , O.PO_TYPE_ID
    , O.ORDER_CAT_ID
    , O.ORDER_TYPE_ID
 
    , O.MATL_ID
    , O.DESCR
    , O.PBU_NBR
    , O.PBU_NAME
    , O.MKT_CTGY_MKT_AREA_NBR
    , O.MKT_CTGY_MKT_AREA_NAME
 
    , O.SHIP_TO_CUST_ID
    , O.CUST_NAME
    , O.OWN_CUST_ID
    , O.OWN_CUST_NAME
    , O.OE_REPL_IND
 
    , O.PRIM_SHIP_FACILITY_ID
    , O.FACILITY_ID
    , O.SHIP_PT_ID
 
    , O.CANCEL_DT
    , O.CANCEL_IND
    , O.REJ_REAS_ID
    , O.REJ_REAS_DESC
    , O.WAIT_LIST_CD
    , O.ORDER_DELIV_BLK_CD
    , O.DELIV_BLK_CD
    , O.CUST_GRP2_CD
    , O.PRTL_DLVY_CD
    , O.SHIP_COND_ID
    , O.DELIV_PRTY_ID
    , O.HANDSHAKE_TYP_CD
    , O.ROUTE_ID
    , O.PROD_ALLCT_DETERM_PROC_ID
    , O.SPCL_PROC_ID
    , O.AVAIL_CHK_GRP_CD
 
    , O.QTY_UNIT_MEAS_ID
    , ODMS.ORDER_TOT_QTY
    , ODMS.OPEN_ORDER_TOT_QTY
    , ODMS.UNCNFRM_TOT_QTY
    , ODMS.CNFRM_TOT_QTY
    , ZEROIFNULL(ODMS.ACTL_SHIP_CURR_MTH_QTY) AS ACTL_SHIP_CURR_MTH_QTY
 
    , O.ORDER_QTY AS ORD_QTY
    , O.CNFRM_QTY AS CNFM_QTY
    , CASE
        WHEN O.CANCEL_IND = 'N'
            THEN 0
        ELSE ODMS.ORDER_TOT_QTY - ODMS.ACTL_SHIP_CURR_MTH_QTY
        END AS CAN_QTY
    , O.CNFRM_CURR_QTY
    , O.CNFRM_FUTR_QTY
 
    , ZEROIFNULL(OPN.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , ZEROIFNULL(OPN.UNCNFRM_QTY) AS UNCNFRM_QTY
    , ZEROIFNULL(OPN.BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , ZEROIFNULL(OPN.DEFER_QTY) AS DEFER_QTY
    , ZEROIFNULL(OPN.IN_PROC_QTY) AS IN_PROC_QTY
    , ZEROIFNULL(OPN.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , ZEROIFNULL(OPN.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY
 
    , CASE
        WHEN ZEROIFNULL(OPN.IN_PROC_QTY) > O.CNFRM_CURR_QTY
            THEN O.CNFRM_CURR_QTY
        ELSE ZEROIFNULL(OPN.IN_PROC_QTY)
        END AS IN_PROC_CURR_QTY
    , CASE
        WHEN ZEROIFNULL(OPN.IN_PROC_QTY) > O.CNFRM_CURR_QTY
            THEN ZEROIFNULL(OPN.IN_PROC_QTY) - O.CNFRM_CURR_QTY
        ELSE 0
        END AS IN_PROC_FUTR_QTY
 
FROM (
 
SELECT
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
   
    , OD.ORDER_DT
    , OD.ORDER_CRT_TM
    , OD.ORDER_LN_CRT_DT
    , OD.ORDER_LN_CRT_TM
    , OD.ORDER_CREATOR
   
    , OD.CUST_PO_NBR
    , OD.PO_TYPE_ID
   
    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
   
    , OD.MATL_ID
    , MATL.DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , MATL.MKT_CTGY_MKT_AREA_NBR
    , MATL.MKT_CTGY_MKT_AREA_NAME
   
    , OD.SHIP_TO_CUST_ID
    , CUST.CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , CASE
        WHEN CUST.SALES_ORG_GRP_DESC = 'NA'
            THEN 'REPL'
        ELSE CUST.SALES_ORG_GRP_DESC
        END AS OE_REPL_IND
   
    , CUST.PRIM_SHIP_FACILITY_ID
    , OD.FACILITY_ID
    , OD.SHIP_PT_ID
   
    , OD.CANCEL_DT
    , OD.CANCEL_IND
    , OD.REJ_REAS_ID
    , REJ.REJ_REAS_DESC
    , OD.WAIT_LIST_CD
    , OD.ORDER_DELIV_BLK_CD
    , OD.DELIV_BLK_CD
    , OD.CUST_GRP2_CD
    , OD.PRTL_DLVY_CD
    , OD.SHIP_COND_ID
    , OD.DELIV_PRTY_ID
    , OD.HANDSHAKE_TYP_CD
    , OD.ROUTE_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.SPCL_PROC_ID
    , OD.AVAIL_CHK_GRP_CD
   
    , OD.QTY_UNIT_MEAS_ID
    , MAX(OD.ORDER_QTY) AS ORDER_QTY
    , SUM(OD.CNFRM_QTY) AS CNFRM_QTY
    , SUM(CASE
        WHEN OD.PLN_GOODS_ISS_DT / 100 = OD.ORDER_LN_CRT_DT / 100
            THEN OD.CNFRM_QTY
        ELSE 0
        END) AS CNFRM_CURR_QTY
    , SUM(CASE
        WHEN OD.PLN_GOODS_ISS_DT / 100 > OD.ORDER_LN_CRT_DT / 100
            THEN OD.CNFRM_QTY
        ELSE 0
        END) AS CNFRM_FUTR_QTY
 
    , OD.CUST_RDD
    , OD.FRST_MATL_AVL_DT
    , OD.FRST_PLN_GOODS_ISS_DT
    , OD.FRST_RDD
    , OD.FC_MATL_AVL_DT
    , OD.FC_PLN_GOODS_ISS_DT
    , OD.FRST_PROM_DELIV_DT
 
FROM NA_BI_VWS.ORDER_DETAIL OD
 
    LEFT OUTER JOIN GDYR_VWS.ORDER_REJ_REAS REJ
        ON REJ.REJ_REAS_ID = OD.REJ_REAS_ID
        AND REJ.ORIG_SYS_ID = 2
        AND REJ.EXP_DT = DATE '5555-12-31'
        AND REJ.LANG_ID = 'E'
 
    INNER JOIN (
            SELECT
                DAY_DATE
                , MONTH_DT
 
            FROM GDYR_BI_VWS.GDYR_CAL
 
            WHERE
                DAY_DATE BETWEEN '2015-02-01' AND CURRENT_DATE-1
                --DAY_DATE BETWEEN CURRENT_DATE-90 AND CURRENT_DATE-1
            ) CAL
        ON CAL.DAY_DATE = OD.ORDER_LN_CRT_DT
        AND CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
 
    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = OD.MATL_ID
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'
        AND MATL.PBU_NBR IN ('01','03')
   
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
 
WHERE
    OD.ORDER_CAT_ID = 'C'
    AND OD.RO_PO_TYPE_IND = 'N'
    AND OD.ORDER_LN_CRT_DT BETWEEN '2015-02-01' AND CURRENT_DATE - 1
 
GROUP BY
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
   
    , OD.ORDER_DT
    , OD.ORDER_CRT_TM
    , OD.ORDER_LN_CRT_DT
    , OD.ORDER_LN_CRT_TM
    , OD.ORDER_CREATOR
   
    , OD.CUST_PO_NBR
    , OD.PO_TYPE_ID
   
    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
   
    , OD.MATL_ID
    , MATL.DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME
    , MATL.MKT_CTGY_MKT_AREA_NBR
    , MATL.MKT_CTGY_MKT_AREA_NAME
   
    , OD.SHIP_TO_CUST_ID
    , CUST.CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , OE_REPL_IND
   
    , CUST.PRIM_SHIP_FACILITY_ID
    , OD.FACILITY_ID
    , OD.SHIP_PT_ID
   
    , OD.CANCEL_DT
    , OD.CANCEL_IND
    , OD.REJ_REAS_ID
    , REJ.REJ_REAS_DESC
    , OD.WAIT_LIST_CD
    , OD.ORDER_DELIV_BLK_CD
    , OD.DELIV_BLK_CD
    , OD.CUST_GRP2_CD
    , OD.PRTL_DLVY_CD
    , OD.SHIP_COND_ID
    , OD.DELIV_PRTY_ID
    , OD.HANDSHAKE_TYP_CD
    , OD.ROUTE_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.SPCL_PROC_ID
    , OD.AVAIL_CHK_GRP_CD
   
    , OD.QTY_UNIT_MEAS_ID
 
    , OD.CUST_RDD
    , OD.FRST_MATL_AVL_DT
    , OD.FRST_PLN_GOODS_ISS_DT
    , OD.FRST_RDD
    , OD.FC_MATL_AVL_DT
    , OD.FC_PLN_GOODS_ISS_DT
    , OD.FRST_PROM_DELIV_DT
 
    ) O
 
    INNER JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS
        ON ODMS.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND ODMS.ORDER_ID = O.ORDER_ID
        AND ODMS.ORDER_LINE_NBR = O.ORDER_LINE_NBR
        AND ODMS.REF_DT = O.ORDER_LN_CRT_DT
 
    LEFT OUTER JOIN (
 
        SELECT
            O.ORDER_FISCAL_YR
            , O.ORDER_ID
            , O.ORDER_LINE_NBR
            , O.DAY_DATE
           
            , SUM(O.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
            , SUM(O.UNCNFRM_QTY) AS UNCNFRM_QTY
            , SUM(O.BACK_ORDER_QTY) AS BACK_ORDER_QTY
            , SUM(O.DEFER_QTY) AS DEFER_QTY
            , SUM(O.IN_PROC_QTY) AS IN_PROC_QTY
            , SUM(O.WAIT_LIST_QTY) AS WAIT_LIST_QTY
            , SUM(O.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY
 
        FROM (
 
            SELECT
                OOL.ORDER_FISCAL_YR
                , OOL.ORDER_ID
                , OOL.ORDER_LINE_NBR
                , CAL.DAY_DATE
 
                , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
                , SUM(OOL.UNCNFRM_QTY) AS UNCNFRM_QTY
                , SUM(OOL.BACK_ORDER_QTY) AS BACK_ORDER_QTY
                , SUM(OOL.DEFER_QTY) AS DEFER_QTY
                , CAST(0 AS DECIMAL(15,3)) AS IN_PROC_QTY
                , SUM(OOL.WAIT_LIST_QTY) AS WAIT_LIST_QTY
                , SUM(OOL.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY
 
            FROM NA_VWS.OPEN_ORDER_SCHDLN OOL
 
                INNER JOIN (
                    SELECT
                        C.DAY_DATE
                        , C.MONTH_DT
                        , OD.ORDER_FISCAL_YR
                        , OD.ORDER_ID
                        , OD.ORDER_LINE_NBR
 
                    FROM GDYR_BI_VWS.GDYR_CAL C
 
                        INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
                            ON C.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
                            AND OD.ORDER_LN_CRT_DT = C.DAY_DATE
                            AND OD.SCHED_LINE_NBR = 1
                            AND OD.ORDER_CAT_ID = 'C'
                            AND OD.RO_PO_TYPE_IND = 'N'
 
                    WHERE
                        --DAY_DATE = CURRENT_DATE-1 --BETWEEN CURRENT_DATE-15 AND CURRENT_DATE-1
                        C.DAY_DATE BETWEEN CURRENT_DATE-90 AND CURRENT_DATE-1
                    ) CAL
                ON CAL.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT
                AND CAL.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
                AND CAL.ORDER_ID = OOL.ORDER_ID
                AND CAL.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
 
            WHERE
                CAL.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT
                AND OOL.EXP_DT BETWEEN '2015-02-01' AND CURRENT_DATE-1
 
            GROUP BY
                OOL.ORDER_FISCAL_YR
                , OOL.ORDER_ID
                , OOL.ORDER_LINE_NBR
                , CAL.DAY_DATE
 
            UNION ALL
 
            SELECT
                DIP.ORDER_FISCAL_YR
                , DIP.ORDER_ID
                , DIP.ORDER_LINE_NBR
                , CAL.DAY_DATE
 
                , CAST(0 AS DECIMAL(15,3)) AS OPEN_CNFRM_QTY
                , CAST(0 AS DECIMAL(15,3)) AS UNCNFRM_QTY
                , CAST(0 AS DECIMAL(15,3)) AS BACK_ORDER_QTY
                , CAST(0 AS DECIMAL(15,3)) AS DEFER_QTY
                , SUM(DIP.QTY_TO_SHIP) AS IN_PROC_QTY
                , CAST(0 AS DECIMAL(15,3)) AS WAIT_LIST_QTY
                , CAST(0 AS DECIMAL(15,3)) AS OTHR_ORDER_QTY
 
            FROM GDYR_VWS.DELIV_IN_PROC DIP
 
                INNER JOIN (
                    SELECT
                        C.DAY_DATE
                        , C.MONTH_DT
                        , OD.ORDER_FISCAL_YR
                        , OD.ORDER_ID
                        , OD.ORDER_LINE_NBR
 
                    FROM GDYR_BI_VWS.GDYR_CAL C
 
                        INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
                            ON C.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
                            AND OD.ORDER_LN_CRT_DT = C.DAY_DATE
                            AND OD.SCHED_LINE_NBR = 1
                            AND OD.ORDER_CAT_ID = 'C'
                            AND OD.RO_PO_TYPE_IND = 'N'
 
                    WHERE
                        C.DAY_DATE BETWEEN '2015-02-01' AND CURRENT_DATE-1
                        --C.DAY_DATE BETWEEN CURRENT_DATE-90 AND CURRENT_DATE-1
                    ) CAL
                ON CAL.DAY_DATE BETWEEN DIP.EFF_DT AND DIP.EXP_DT
                AND CAL.ORDER_FISCAL_YR = DIP.ORDER_FISCAL_YR
                AND CAL.ORDER_ID = DIP.ORDER_ID
                AND CAL.ORDER_LINE_NBR = DIP.ORDER_LINE_NBR
 
            WHERE
                DIP.ORIG_SYS_ID = 2
                AND DIP.INTRA_CMPNY_FLG = 'N'
                AND DIP.EXP_DT BETWEEN '2015-02-01' AND CURRENT_DATE-1
 
            GROUP BY
                DIP.ORDER_FISCAL_YR
                , DIP.ORDER_ID
                , DIP.ORDER_LINE_NBR
                , CAL.DAY_DATE
           
            ) O
 
        GROUP BY
            O.ORDER_FISCAL_YR
            , O.ORDER_ID
            , O.ORDER_LINE_NBR
            , O.DAY_DATE
        ) OPN
    ON OPN.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
    AND OPN.ORDER_ID = O.ORDER_ID
    AND OPN.ORDER_LINE_NBR = O.ORDER_LINE_NBR
    AND OPN.DAY_DATE = O.ORDER_LN_CRT_DT
 
    ) S
 
GROUP BY
    S.PBU_NBR
    , S.OWN_CUST_ID
    , S.OWN_CUST_NAME
    , S.OE_REPL_IND
    , S.ORDER_LN_CRT_DT
