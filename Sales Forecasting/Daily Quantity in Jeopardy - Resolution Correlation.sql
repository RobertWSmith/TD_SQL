﻿SELECT
    ORD.DAY_DATE
    , ORD.WEEK_OF_MONTH
    , ORD.MONTH_DT
    , ORD.END_OF_MONTH_DT

    , ORD.ORDER_FISCAL_YR
    , ORD.ORDER_ID
    , ORD.ORDER_LINE_NBR

    , ORD.ORDER_CAT_ID
    , ORD.ORDER_TYPE_ID
    , ORD.PO_TYPE_ID

    , ORD.SNAP_ORDER_DELIV_BLK_CD
    , ORD.CURR_HDR_DELIV_BLK_CD
    , ORD.SNAP_DELIV_BLK_CD
    , ORD.CURR_SL_DELIV_BLK_CD
    , ORD.SNAP_SPCL_PROC_ID
    , ORD.CURR_SPCL_PROC_ID

    , ORD.SNAP_DELIV_PRTY_ID
    , ORD.CURR_DELIV_PRTY_ID

    , ORD.CUST_GRP2_CD
    , ORD.SHIP_COND_ID
    , ORD.PROD_ALLCT_DETERM_PROC_ID
    , ORD.AVAIL_CHK_GRP_CD

    , ORD.CURR_REJ_REAS_ID
    , ORD.CURR_CANCEL_DT

    --, ORD.SHIP_TO_CUST_ID
    --, ORD.CUST_NAME
    , ORD.OWN_CUST_ID
    , ORD.OWN_CUST_NAME

    , ORD.SALES_ORG_CD
    , ORD.SALES_ORG_NAME
    , ORD.DISTR_CHAN_CD
    , ORD.DISTR_CHAN_NAME
    , ORD.CUST_GRP_ID
    , ORD.CUST_GRP_NAME
    , ORD.OE_REPL_IND
    , ORD.OE_REPL_DESC

    , ORD.MATL_ID
    , ORD.MATL_DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.MKT_AREA_NBR
    , ORD.MKT_AREA_NAME
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NAME
    , ORD.PROD_LINE_NBR
    , ORD.PROD_LINE_NAME

    , ORD.TEST_PRIM_SHIP_FACILITY_ID
    , ORD.PRIM_SHIP_FACILITY_ID
    , ORD.SNAP_FACILITY_ID
    , ORD.SNAP_FACILITY_NAME
    , ORD.CURR_FACILITY_ID

    , ORD.SLS_QTY_UNIT_MEAS_ID
    --, ORD.SLS_UNIT_CUM_ORD_QTY AS SNAP_ORD_QTY
    , SDI.SLS_UNIT_CUM_ORD_QTY AS CURR_ORD_QTY

    , ORD.SNAP_OPEN_CNFRM_QTY
    , ORD.CURR_OPEN_CNFRM_QTY

    , ORD.SNAP_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , ORD.SNAP_PGI_IN_MTH_OPEN_CNFRM_QTY
    , ORD.SNAP_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , ORD.CURR_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , ORD.CURR_PGI_IN_MTH_OPEN_CNFRM_QTY
    , ORD.CURR_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , ORD.SNAP_UNCNFRM_QTY
    , ORD.CURR_UNCNFRM_QTY

    , ORD.SNAP_BACK_ORDER_QTY
    , ORD.CURR_BACK_ORDER_QTY

    , ORD.SNAP_WAIT_LIST_QTY
    , ORD.CURR_WAIT_LIST_QTY

    , ORD.SNAP_DEFER_QTY
    , ORD.CURR_DEFER_QTY

    , ORD.SNAP_OTHR_ORDER_QTY
    , ORD.CURR_OTHR_ORDER_QTY

    , ZEROIFNULL(SUM(DDC.DELIV_QTY)) AS TOT_DELIV_NOTE_QTY

    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_AGID_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL AND DDC.ACTL_GOODS_ISS_DT < ORD.MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_AGID_BEFORE_PGI_MTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL AND DDC.ACTL_GOODS_ISS_DT BETWEEN ORD.MONTH_DT AND ORD.END_OF_MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_AGID_IN_PGI_MTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NOT NULL AND DDC.ACTL_GOODS_ISS_DT > ORD.END_OF_MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_AGID_AFTER_PGI_MTH_QTY

    , TOT_DELIV_NOTE_QTY - TOT_AGID_QTY AS TOT_IN_PROC_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND DDC.PLN_GOODS_MVT_DT < ORD.MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_PGMV_BEFORE_PGI_MTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND DDC.PLN_GOODS_MVT_DT BETWEEN ORD.MONTH_DT AND ORD.END_OF_MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_PGMV_IN_PGI_MTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND DDC.PLN_GOODS_MVT_DT > ORD.END_OF_MONTH_DT
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_PGMV_AFTER_PGI_MTH_QTY

FROM (

SELECT
    OOD.DAY_DATE
    , OOD.WEEK_OF_MONTH
    , OOD.MONTH_DT
    , OOD.END_OF_MONTH_DT

    , OOD.ORDER_FISCAL_YR
    , OOD.ORDER_ID
    , OOD.ORDER_LINE_NBR

    , OOD.ORDER_CAT_ID
    , OOD.ORDER_TYPE_ID
    , OOD.PO_TYPE_ID

    , OOD.ORDER_DELIV_BLK_CD AS SNAP_ORDER_DELIV_BLK_CD
    , OD.ORDER_DELIV_BLK_CD AS CURR_HDR_DELIV_BLK_CD
    , OOD.SL_DELIV_BLK_CD AS SNAP_DELIV_BLK_CD
    , MAX(OD.DELIV_BLK_CD) AS CURR_SL_DELIV_BLK_CD
    , OOD.SPCL_PROC_ID AS SNAP_SPCL_PROC_ID
    , OD.SPCL_PROC_ID AS CURR_SPCL_PROC_ID

    , OOD.DELIV_PRTY_ID AS SNAP_DELIV_PRTY_ID
    , OD.DELIV_PRTY_ID AS CURR_DELIV_PRTY_ID

    , OOD.CUST_GRP2_CD
    , OOD.SHIP_COND_ID
    , OOD.PROD_ALLCT_DETERM_PROC_ID
    , OOD.AVAIL_CHK_GRP_CD

    , NULLIF(OD.REJ_REAS_ID, '') AS CURR_REJ_REAS_ID
    , OD.CANCEL_DT AS CURR_CANCEL_DT

    , OOD.SHIP_TO_CUST_ID
    , OOD.CUST_NAME
    , OOD.OWN_CUST_ID
    , OOD.OWN_CUST_NAME

    , OOD.SALES_ORG_CD
    , OOD.SALES_ORG_NAME
    , OOD.DISTR_CHAN_CD
    , OOD.DISTR_CHAN_NAME
    , OOD.CUST_GRP_ID
    , OOD.CUST_GRP_NAME
    , OOD.OE_REPL_IND
    , OOD.OE_REPL_DESC

    , OOD.MATL_ID
    , OOD.MATL_DESCR
    , OOD.PBU_NBR
    , OOD.PBU_NAME
    , OOD.MKT_AREA_NBR
    , OOD.MKT_AREA_NAME
    , OOD.MKT_CTGY_MKT_AREA_NBR
    , OOD.MKT_CTGY_MKT_AREA_NAME
    , OOD.PROD_LINE_NBR
    , OOD.PROD_LINE_NAME

    , OOD.TEST_PRIM_SHIP_FACILITY_ID
    , OOD.PRIM_SHIP_FACILITY_ID
    , OOD.FACILITY_ID AS SNAP_FACILITY_ID
    , OOD.FACILITY_NAME AS SNAP_FACILITY_NAME
    , OD.FACILITY_ID AS CURR_FACILITY_ID

    , OOD.SLS_QTY_UNIT_MEAS_ID
    --, OOD.SLS_UNIT_CUM_ORD_QTY

    , OOD.OPEN_CNFRM_QTY AS SNAP_OPEN_CNFRM_QTY
    , ZEROIFNULL(SUM(OOL.OPEN_CNFRM_QTY)) AS CURR_OPEN_CNFRM_QTY

    , OOD.PGI_BEFORE_MTH_OPEN_CNFRM_QTY AS SNAP_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , OOD.PGI_IN_MTH_OPEN_CNFRM_QTY AS SNAP_PGI_IN_MTH_OPEN_CNFRM_QTY
    , OOD.PGI_AFTER_MTH_OPEN_CNFRM_QTY AS SNAP_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , SUM(CASE
        WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT < OOD.MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS CURR_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , SUM(CASE
        WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT <= OOD.END_OF_MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS CURR_PGI_IN_MTH_OPEN_CNFRM_QTY
    , SUM(CASE
        WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT > OOD.END_OF_MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS CURR_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , OOD.UNCNFRM_QTY AS SNAP_UNCNFRM_QTY
    , SUM(OOL.UNCNFRM_QTY) AS CURR_UNCNFRM_QTY

    , OOD.BACK_ORDER_QTY AS SNAP_BACK_ORDER_QTY
    , SUM(OOL.BACK_ORDER_QTY) AS CURR_BACK_ORDER_QTY

    , OOD.WAIT_LIST_QTY AS SNAP_WAIT_LIST_QTY
    , SUM(OOL.WAIT_LIST_QTY) AS CURR_WAIT_LIST_QTY

    , OOD.DEFER_QTY AS SNAP_DEFER_QTY
    , SUM(OOL.DEFER_QTY) AS CURR_DEFER_QTY

    , OOD.OTHR_ORDER_QTY AS SNAP_OTHR_ORDER_QTY
    , SUM(OOL.OTHR_ORDER_QTY) AS CURR_OTHR_ORDER_QTY

FROM (

SELECT
    CAL.DAY_DATE
    , CAL.WEEK_OF_MONTH
    , CAL.MONTH_DT
    , ADD_MONTHS(CAL.MONTH_DT, 1) - INTERVAL '1' DAY AS END_OF_MONTH_DT

    , OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR

    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
    , OD.PO_TYPE_ID

    , OD.ORDER_DELIV_BLK_CD
    , MAX(OD.DELIV_BLK_CD) AS SL_DELIV_BLK_CD
    , OD.SPCL_PROC_ID
    , OD.CUST_GRP2_CD
    , OD.DELIV_PRTY_ID
    , OD.SHIP_COND_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.AVAIL_CHK_GRP_CD

    , OD.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME
    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME
    , CASE 
        WHEN C.SALES_ORG_CD IN ('N302', 'N312', 'N322') OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD = '32')
            THEN 'OE'
        ELSE 'REPL'
        END OE_REPL_IND
    , CASE 
        WHEN OE_REPL_IND = 'OE'
            THEN 'OEM'
        WHEN OE_REPL_IND = 'REPL'
            THEN 'Replacement'
        ELSE OE_REPL_IND
        END OE_REPL_DESC

    , OD.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME

    , CASE
        WHEN OD.FACILITY_ID IN ('N5US', 'N5CA')
            THEN 'N5US / N5CA'
        WHEN OD.FACILITY_ID = C.PRIM_SHIP_FACILITY_ID
            THEN 'Primary LC'
        WHEN OD.FACILITY_ID LIKE 'N5%'
            THEN 'Factory Direct'
        ELSE 'Out of Area'
        END AS TEST_PRIM_SHIP_FACILITY_ID
    , C.PRIM_SHIP_FACILITY_ID
    , OD.FACILITY_ID
    , F.FACILITY_NAME

    , OOL.SLS_QTY_UNIT_MEAS_ID
    --, SDI.SLS_UNIT_CUM_ORD_QTY
    
    , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY

    , SUM(CASE
        WHEN OD.PLN_GOODS_ISS_DT < CAL.MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , SUM(CASE
        WHEN OD.PLN_GOODS_ISS_DT BETWEEN CAL.MONTH_DT AND END_OF_MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS PGI_IN_MTH_OPEN_CNFRM_QTY
    , SUM(CASE
        WHEN OD.PLN_GOODS_ISS_DT > END_OF_MONTH_DT
            THEN OOL.OPEN_CNFRM_QTY
        ELSE 0
        END) AS PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , SUM(OOL.UNCNFRM_QTY) AS UNCNFRM_QTY
    , SUM(OOL.BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , SUM(OOL.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , SUM(OOL.DEFER_QTY) AS DEFER_QTY
    , SUM(OOL.OTHR_ORDER_QTY) AS OTHR_ORDER_QTY

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN NA_VWS.OPEN_ORDER_SCHDLN OOL
        ON CAL.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOL.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.CO_CD IN ('N101', 'N102', 'N266')
        AND OD.REJ_REAS_ID = ''

    --INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM SDI
        --ON SDI.FISCAL_YR = OOL.ORDER_FISCAL_YR
        --AND SDI.SLS_DOC_ID = OOL.ORDER_ID
        --AND SDI.SLS_DOC_ITM_ID = OOL.ORDER_LINE_NBR
        --AND CAL.DAY_DATE BETWEEN SDI.EFF_DT AND SDI.EXP_DT

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OD.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_cURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

WHERE
    CAL.DAY_DATE BETWEEN DATE '2015-02-01' AND DATE '2015-02-28'

    AND M.PBU_NBR = '01'

    AND OE_REPL_IND = 'REPL'

GROUP BY
    CAL.DAY_DATE
    , CAL.WEEK_OF_MONTH
    , CAL.MONTH_DT
    , END_OF_MONTH_DT

    , OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR

    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
    , OD.PO_TYPE_ID

    , OD.ORDER_DELIV_BLK_CD
    --, OD.DELIV_BLK_CD
    , OD.SPCL_PROC_ID
    , OD.CUST_GRP2_CD
    , OD.DELIV_PRTY_ID
    , OD.SHIP_COND_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.AVAIL_CHK_GRP_CD

    , OD.SHIP_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME
    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME
    , OE_REPL_IND
    , OE_REPL_DESC

    , OD.MATL_ID
    , MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME

    , TEST_PRIM_SHIP_FACILITY_ID
    , C.PRIM_SHIP_FACILITY_ID
    , OD.FACILITY_ID
    , F.FACILITY_NAME

    , OOL.SLS_QTY_UNIT_MEAS_ID
    --, SDI.SLS_UNIT_CUM_ORD_QTY
    --, SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , OOL.RPT_QTY_UNIT_MEAS_ID
    --, SUM(OOL.RPT_OPEN_CNFRM_QTY) AS RPT_OPEN_CNFRM_QTY

    ) OOD

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OOD.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOD.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOD.ORDER_LINE_NBR
        AND OD.EXP_DT = CAST('5555-12-31' AS DATE)

    LEFT OUTER JOIN NA_VWS.OPEN_ORDER_SCHDLN OOL
        ON OOL.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
        AND OOL.ORDER_ID = OD.ORDER_ID
        AND OOL.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = OD.SCHED_LINE_NBR
        AND OOL.EXP_DT = CAST('5555-12-31' AS DATE)

GROUP BY
    OOD.DAY_DATE
    , OOD.WEEK_OF_MONTH
    , OOD.MONTH_DT
    , OOD.END_OF_MONTH_DT

    , OOD.ORDER_FISCAL_YR
    , OOD.ORDER_ID
    , OOD.ORDER_LINE_NBR

    , OOD.ORDER_CAT_ID
    , OOD.ORDER_TYPE_ID
    , OOD.PO_TYPE_ID

    , OOD.ORDER_DELIV_BLK_CD 
    , OD.ORDER_DELIV_BLK_CD 
    , OOD.SL_DELIV_BLK_CD 
    --, MAX(OD.DELIV_BLK_CD) AS CURR_SL_DELIV_BLK_CD
    , OOD.SPCL_PROC_ID 
    , OD.SPCL_PROC_ID 

    , OOD.DELIV_PRTY_ID 
    , OD.DELIV_PRTY_ID 

    , OOD.CUST_GRP2_CD
    , OOD.SHIP_COND_ID
    , OOD.PROD_ALLCT_DETERM_PROC_ID
    , OOD.AVAIL_CHK_GRP_CD

    , OD.REJ_REAS_ID 
    , OD.CANCEL_DT 

    , OOD.SHIP_TO_CUST_ID
    , OOD.CUST_NAME
    , OOD.OWN_CUST_ID
    , OOD.OWN_CUST_NAME

    , OOD.SALES_ORG_CD
    , OOD.SALES_ORG_NAME
    , OOD.DISTR_CHAN_CD
    , OOD.DISTR_CHAN_NAME
    , OOD.CUST_GRP_ID
    , OOD.CUST_GRP_NAME
    , OOD.OE_REPL_IND
    , OOD.OE_REPL_DESC

    , OOD.MATL_ID
    , OOD.MATL_DESCR
    , OOD.PBU_NBR
    , OOD.PBU_NAME
    , OOD.MKT_AREA_NBR
    , OOD.MKT_AREA_NAME
    , OOD.MKT_CTGY_MKT_AREA_NBR
    , OOD.MKT_CTGY_MKT_AREA_NAME
    , OOD.PROD_LINE_NBR
    , OOD.PROD_LINE_NAME

    , OOD.TEST_PRIM_SHIP_FACILITY_ID
    , OOD.PRIM_SHIP_FACILITY_ID
    , OOD.FACILITY_ID 
    , OOD.FACILITY_NAME 
    , OD.FACILITY_ID 

    , OOD.SLS_QTY_UNIT_MEAS_ID
    --, OOD.SLS_UNIT_CUM_ORD_QTY

    , OOD.OPEN_CNFRM_QTY 
    --, ZEROIFNULL(SUM(OOL.OPEN_CNFRM_QTY)) AS CURR_OPEN_CNFRM_QTY

    , OOD.PGI_BEFORE_MTH_OPEN_CNFRM_QTY 
    , OOD.PGI_IN_MTH_OPEN_CNFRM_QTY 
    , OOD.PGI_AFTER_MTH_OPEN_CNFRM_QTY 

    --, SUM(CASE
        --WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT < OOD.MONTH_DT
            --THEN OOL.OPEN_CNFRM_QTY
        --ELSE 0
        --END) AS CURR_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    --, SUM(CASE
        --WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT <= OOD.END_OF_MONTH_DT
            --THEN OOL.OPEN_CNFRM_QTY
        --ELSE 0
        --END) AS CURR_PGI_IN_MTH_OPEN_CNFRM_QTY
    --, SUM(CASE
        --WHEN CURRENT_DATE <= OOD.END_OF_MONTH_DT AND OD.PLN_GOODS_ISS_DT > OOD.END_OF_MONTH_DT
            --THEN OOL.OPEN_CNFRM_QTY
        --ELSE 0
        --END) AS CURR_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , OOD.UNCNFRM_QTY 
    --, SUM(OOL.UNCNFRM_QTY) AS CURR_UNCNFRM_QTY

    , OOD.BACK_ORDER_QTY 
    --, SUM(OOL.BACK_ORDER_QTY) AS CURR_BACK_ORDER_QTY

    , OOD.WAIT_LIST_QTY 
    --, SUM(OOL.WAIT_LIST_QTY) AS CURR_WAIT_LIST_QTY

    , OOD.DEFER_QTY
    --, SUM(OOL.DEFER_QTY) AS CURR_DEFER_QTY

    , OOD.OTHR_ORDER_QTY 
    --, SUM(OOL.OTHR_ORDER_QTY) AS CURR_OTHR_ORDER_QTY

    ) ORD

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM SDI
        ON SDI.FISCAL_YR = ORD.ORDER_FISCAL_YR
        AND SDI.SLS_DOC_ID = ORD.ORDER_ID
        AND SDI.SLS_DOC_ITM_ID = ORD.ORDER_LINE_NBR
        AND SDI.EXP_DT = CAST('5555-12-31' AS DATE)
    
    LEFT OUTER JOIN NA_BI_vWS.DELIVERY_DETAIL_CURR DDC
        ON DDC.ORDER_FISCAL_YR = ORD.ORDER_FISCAL_YR
        AND DDC.ORDER_ID = ORD.ORDER_ID
        AND DDC.ORDER_LINE_NBR = ORD.ORDER_LINE_NBR
        AND DDC.DELIV_CAT_ID = 'J'
        AND DDC.SD_DOC_CTGY_CD = 'C'

GROUP BY
    ORD.DAY_DATE
    , ORD.WEEK_OF_MONTH
    , ORD.MONTH_DT
    , ORD.END_OF_MONTH_DT

    , ORD.ORDER_FISCAL_YR
    , ORD.ORDER_ID
    , ORD.ORDER_LINE_NBR

    , ORD.ORDER_CAT_ID
    , ORD.ORDER_TYPE_ID
    , ORD.PO_TYPE_ID

    , ORD.SNAP_ORDER_DELIV_BLK_CD
    , ORD.CURR_HDR_DELIV_BLK_CD
    , ORD.SNAP_DELIV_BLK_CD
    , ORD.CURR_SL_DELIV_BLK_CD
    , ORD.SNAP_SPCL_PROC_ID
    , ORD.CURR_SPCL_PROC_ID

    , ORD.SNAP_DELIV_PRTY_ID
    , ORD.CURR_DELIV_PRTY_ID

    , ORD.CUST_GRP2_CD
    , ORD.SHIP_COND_ID
    , ORD.PROD_ALLCT_DETERM_PROC_ID
    , ORD.AVAIL_CHK_GRP_CD

    , ORD.CURR_REJ_REAS_ID
    , ORD.CURR_CANCEL_DT

    --, ORD.SHIP_TO_CUST_ID
    --, ORD.CUST_NAME
    , ORD.OWN_CUST_ID
    , ORD.OWN_CUST_NAME

    , ORD.SALES_ORG_CD
    , ORD.SALES_ORG_NAME
    , ORD.DISTR_CHAN_CD
    , ORD.DISTR_CHAN_NAME
    , ORD.CUST_GRP_ID
    , ORD.CUST_GRP_NAME
    , ORD.OE_REPL_IND
    , ORD.OE_REPL_DESC

    , ORD.MATL_ID
    , ORD.MATL_DESCR
    , ORD.PBU_NBR
    , ORD.PBU_NAME
    , ORD.MKT_AREA_NBR
    , ORD.MKT_AREA_NAME
    , ORD.MKT_CTGY_MKT_AREA_NBR
    , ORD.MKT_CTGY_MKT_AREA_NAME
    , ORD.PROD_LINE_NBR
    , ORD.PROD_LINE_NAME

    , ORD.TEST_PRIM_SHIP_FACILITY_ID
    , ORD.PRIM_SHIP_FACILITY_ID
    , ORD.SNAP_FACILITY_ID
    , ORD.SNAP_FACILITY_NAME
    , ORD.CURR_FACILITY_ID

    , ORD.SLS_QTY_UNIT_MEAS_ID
    --, ORD.SLS_UNIT_CUM_ORD_QTY
    , SDI.SLS_UNIT_CUM_ORD_QTY

    , ORD.SNAP_OPEN_CNFRM_QTY
    , ORD.CURR_OPEN_CNFRM_QTY

    , ORD.SNAP_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , ORD.SNAP_PGI_IN_MTH_OPEN_CNFRM_QTY
    , ORD.SNAP_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , ORD.CURR_PGI_BEFORE_MTH_OPEN_CNFRM_QTY
    , ORD.CURR_PGI_IN_MTH_OPEN_CNFRM_QTY
    , ORD.CURR_PGI_AFTER_MTH_OPEN_CNFRM_QTY

    , ORD.SNAP_UNCNFRM_QTY
    , ORD.CURR_UNCNFRM_QTY

    , ORD.SNAP_BACK_ORDER_QTY
    , ORD.CURR_BACK_ORDER_QTY

    , ORD.SNAP_WAIT_LIST_QTY
    , ORD.CURR_WAIT_LIST_QTY

    , ORD.SNAP_DEFER_QTY
    , ORD.CURR_DEFER_QTY

    , ORD.SNAP_OTHR_ORDER_QTY
    , ORD.CURR_OTHR_ORDER_QTY

