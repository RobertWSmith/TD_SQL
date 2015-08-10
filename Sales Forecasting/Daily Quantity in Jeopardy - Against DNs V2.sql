﻿SELECT
    OO.DAY_DATE
    , OO.MONTH_DT
    , OO.END_OF_MONTH_DT
    , OO.WEEK_OF_MONTH

    --, OO.ORDER_FISCAL_YR
    --, OO.ORDER_ID
    --, OO.ORDER_LINE_NBR
    , OO.ORDER_CAT_ID
    , OO.ORDER_TYPE_ID
    , OO.PO_TYPE_ID

    , OO.SHIP_COND_ID
    , OO.PROD_ALLCT_DETERM_PROC_ID
    , OO.CUST_GRP2_CD

    , OO.SNAP_HDR_DELIV_BLK_CD
    , OO.SNAP_SL_DELIV_BLK_CD
    , OO.SNAP_DELIV_PRTY_ID
    , OO.SNAP_SPCL_PROC_ID

    , OO.CURR_HDR_DELIV_BLK_CD
    , OO.CURR_SL_DELIV_BLK_CD
    , OO.CURR_DELIV_PRTY_ID
    , OO.CURR_SPCL_PROC_ID

    , OO.REJ_REAS_ID
    , OO.CANCEL_DT

    , OO.SOLD_TO_CUST_ID
    , OO.CUST_NAME
    , OO.OWN_CUST_ID
    , OO.OWN_CUST_NAME
    , OO.SALES_ORG_CD
    , OO.SALES_ORG_NAME
    , OO.DISTR_CHAN_CD
    , OO.DISTR_CHAN_NAME
    , OO.CUST_GRP_ID
    , OO.CUST_GRP_NAME
    , OO.OE_REPL_IND

    , OO.MATL_ID
    , OO.DESCR
    , OO.PBU_NBR
    , OO.PBU_NAME

    , OO.SNAP_FACILITY_ID
    , OO.SNAP_FACILITY_NAME
    , OO.CURR_FACILITY_ID
    , CASE
        WHEN OO.SNAP_FACILITY_ID = OO.CURR_FACILITY_ID
            THEN 'Same Facility'
        ELSE 'Redirected'
        END AS REDIRECT_IND

    , OO.HDR_CRT_DT
    , OO.ITM_CRT_DT
    , OO.SNAP_ORDD
    , OO.SNAP_FRDD_FMAD
    , OO.SNAP_FRDD_FPGI
    , OO.SNAP_FRDD
    , OO.SNAP_FCDD_FMAD
    , OO.SNAP_FCDD_FPGI
    , OO.SNAP_FCDD

    , OO.CURR_ORDD
    , OO.CURR_FRDD_FMAD
    , OO.CURR_FRDD_FPGI
    , OO.CURR_FRDD
    , OO.CURR_FCDD_FMAD
    , OO.CURR_FCDD_FPGI
    , OO.CURR_FCDD

    , OO.SLS_QTY_UNIT_MEAS_ID
    , OO.SNAP_ORDER_QTY
    , OO.SNAP_PM_OPEN_CNFRM_QTY
    , OO.SNAP_CM_OPEN_CNFRM_QTY
    , OO.SNAP_FM_OPEN_CNFRM_QTY
    , OO.SNAP_UNCNFRM_QTY
    , OO.SNAP_BACK_ORDER_QTY
    , OO.SNAP_WAIT_LIST_QTY

    , OO.CURR_ORDER_QTY
    , OO.CURR_OPEN_CNFRM_QTY
    , OO.CURR_UNCNFRM_QTY
    , OO.CURR_BACK_ORDER_QTY
    , OO.CURR_WAIT_LIST_QTY

    , ZEROIFNULL(SUM(CASE
        WHEN DDC.DELIV_NOTE_CREA_DT > OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS TOT_DELIV_NOTE_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND DDC.DELIV_NOTE_CREA_DT > OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS IN_PROC_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT BETWEEN OO.MONTH_DT AND OO.END_OF_MONTH_DT AND DDC.DELIV_NOTE_CREA_DT > OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS GOODS_ISS_IN_MNTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT > OO.END_OF_MONTH_DT AND DDC.DELIV_NOTE_CREA_DT >= OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS GOODS_ISS_AFTER_MNTH_QTY

    , ZEROIFNULL(SUM(DDC.DELIV_QTY)) AS ALL_TOT_DELIV_NOTE_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT IS NULL AND DDC.DELIV_NOTE_CREA_DT <= OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS PRIOR_IN_PROC_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT < OO.MONTH_DT AND DDC.DELIV_NOTE_CREA_DT <= OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS PRIOR_GOODS_ISS_BEFORE_MNTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT BETWEEN OO.MONTH_DT AND OO.END_OF_MONTH_DT AND DDC.DELIV_NOTE_CREA_DT <= OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS PRIOR_GOODS_ISS_IN_MNTH_QTY
    , ZEROIFNULL(SUM(CASE
        WHEN DDC.ACTL_GOODS_ISS_DT > OO.END_OF_MONTH_DT AND DDC.DELIV_NOTE_CREA_DT <= OO.DAY_DATE
            THEN DDC.DELIV_QTY
        ELSE 0
        END)) AS PRIOR_GOODS_ISS_AFTER_MNTH_QTY

FROM (

SELECT
    OO.DAY_DATE
    , OO.MONTH_DT
    , OO.END_OF_MONTH_DT
    , OO.WEEK_OF_MONTH

    , OO.ORDER_FISCAL_YR
    , OO.ORDER_ID
    , OO.ORDER_LINE_NBR
    , OO.ORDER_CAT_ID
    , OO.ORDER_TYPE_ID
    , OO.PO_TYPE_ID

    , OO.SHIP_COND_ID
    , OO.PROD_ALLCT_DETERM_PROC_ID
    , OO.CUST_GRP2_CD

    , OO.ORDER_DELIV_BLK_CD AS SNAP_HDR_DELIV_BLK_CD
    , OO.SCHD_LN_DELIV_BLK AS SNAP_SL_DELIV_BLK_CD
    , OO.DELIV_PRTY_ID AS SNAP_DELIV_PRTY_ID
    , OO.SPCL_PROC_ID AS SNAP_SPCL_PROC_ID

    , OD.ORDER_DELIV_BLK_CD AS CURR_HDR_DELIV_BLK_CD
    , MAX(OD.DELIV_BLK_CD) AS CURR_SL_DELIV_BLK_CD
    , OD.DELIV_PRTY_ID AS CURR_DELIV_PRTY_ID
    , OD.SPCL_PROC_ID AS CURR_SPCL_PROC_ID

    , OD.REJ_REAS_ID
    , OD.CANCEL_DT

    , OO.SOLD_TO_CUST_ID
    , OO.CUST_NAME
    , OO.OWN_CUST_ID
    , OO.OWN_CUST_NAME
    , OO.SALES_ORG_CD
    , OO.SALES_ORG_NAME
    , OO.DISTR_CHAN_CD
    , OO.DISTR_CHAN_NAME
    , OO.CUST_GRP_ID
    , OO.CUST_GRP_NAME
    , OO.OE_REPL_IND

    , OO.MATL_ID
    , OO.DESCR
    , OO.PBU_NBR
    , OO.PBU_NAME

    , OO.FACILITY_ID AS SNAP_FACILITY_ID
    , OO.FACILITY_NAME AS SNAP_FACILITY_NAME
    , OD.FACILITY_ID AS CURR_FACILITY_ID

    , OO.ORDER_DT AS HDR_CRT_DT
    , OO.ORDER_LN_CRT_DT AS ITM_CRT_DT
    , OO.CUST_RDD AS SNAP_ORDD
    , OO.FRST_MATL_AVL_DT AS SNAP_FRDD_FMAD
    , OO.FRST_PLN_GOODS_ISS_DT AS SNAP_FRDD_FPGI
    , OO.FRST_RDD AS SNAP_FRDD
    , OO.FC_MATL_AVL_DT AS SNAP_FCDD_FMAD
    , OO.FC_PLN_GOODS_ISS_DT AS SNAP_FCDD_FPGI
    , OO.FRST_PROM_DELIV_DT AS SNAP_FCDD

    , OD.CUST_RDD AS CURR_ORDD
    , OD.FRST_MATL_AVL_DT AS CURR_FRDD_FMAD
    , OD.FRST_PLN_GOODS_ISS_DT AS CURR_FRDD_FPGI
    , OD.FRST_RDD AS CURR_FRDD
    , OD.FC_MATL_AVL_DT AS CURR_FCDD_FMAD
    , OD.FC_PLN_GOODS_ISS_DT AS CURR_FCDD_FPGI
    , OD.FRST_PROM_DELIV_DT AS CURR_FCDD

    , OO.SLS_QTY_UNIT_MEAS_ID
    , OO.ORDER_QTY AS SNAP_ORDER_QTY
    , OO.PM_OPEN_CNFRM_QTY AS SNAP_PM_OPEN_CNFRM_QTY
    , OO.CM_OPEN_CNFRM_QTY AS SNAP_CM_OPEN_CNFRM_QTY
    , OO.FM_OPEN_CNFRM_QTY AS SNAP_FM_OPEN_CNFRM_QTY
    , OO.UNCNFRM_QTY AS SNAP_UNCNFRM_QTY
    , OO.BACK_ORDER_QTY AS SNAP_BACK_ORDER_QTY
    , OO.WAIT_LIST_QTY AS SNAP_WAIT_LIST_QTY

    , MAX(OD.ORDER_QTY) AS CURR_ORDER_QTY
    , ZEROIFNULL(SUM(OOL.OPEN_CNFRM_QTY)) AS CURR_OPEN_CNFRM_QTY
    , ZEROIFNULL(SUM(OOL.UNCNFRM_QTY)) AS CURR_UNCNFRM_QTY
    , ZEROIFNULL(SUM(OOL.BACK_ORDER_QTY)) AS CURR_BACK_ORDER_QTY
    , ZEROIFNULL(SUM(OOL.WAIT_LIST_QTY)) AS CURR_WAIT_LIST_QTY

FROM (

SELECT
    CAL.DAY_DATE
    , CAL.MONTH_DT
    , ADD_MONTHS(CAL.MONTH_DT, 1) - CAST(1 AS INTERVAL DAY) AS END_OF_MONTH_DT
    , CAL.WEEK_OF_MONTH

    , OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR

    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
    , OD.PO_TYPE_ID

    , OD.ORDER_DELIV_BLK_CD
    , MAX(OD.DELIV_BLK_CD) AS SCHD_LN_DELIV_BLK
    , OD.SHIP_COND_ID
    , OD.DELIV_PRTY_ID
    , OD.SPCL_PROC_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.CUST_GRP2_CD

    , OD.SOLD_TO_CUST_ID
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
        ELSE 'Replacement'
        END OE_REPL_IND

    , OD.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME

    , OD.FACILITY_ID
    , F.FACILITY_NAME

    , OD.ORDER_DT
    , OD.ORDER_LN_CRT_DT
    , OD.CUST_RDD
    , OD.FRST_MATL_AVL_DT
    , OD.FRST_PLN_GOODS_ISS_DT
    , OD.FRST_RDD
    , OD.FC_MATL_AVL_DT
    , OD.FC_PLN_GOODS_ISS_DT
    , OD.FRST_PROM_DELIV_DT

    , OOL.SLS_QTY_UNIT_MEAS_ID
    , MAX(OD.ORDER_QTY) AS ORDER_QTY
    , SUM(CASE WHEN OD.PLN_GOODS_ISS_DT < CAL.MONTH_DT THEN OOL.OPEN_CNFRM_QTY ELSE 0 END) AS PM_OPEN_CNFRM_QTY
    , SUM(CASE WHEN OD.PLN_GOODS_ISS_DT BETWEEN CAL.MONTH_DT AND END_OF_MONTH_DT THEN OOL.OPEN_CNFRM_QTY ELSE 0 END) AS CM_OPEN_CNFRM_QTY
    , SUM(CASE WHEN OD.PLN_GOODS_ISS_DT > END_OF_MONTH_DT THEN OOL.OPEN_CNFRM_QTY ELSE 0 END) AS FM_OPEN_CNFRM_QTY
    , SUM(OOL.UNCNFRM_QTY) AS UNCNFRM_QTY
    , SUM(OOL.BACK_ORDER_QTY) AS BACK_ORDER_QTY
    , SUM(OOL.WAIT_LIST_QTY) AS WAIT_LIST_QTY

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN NA_VWS.OPEN_ORDER_SCHDLN OOL
        ON CAL.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOL.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.REJ_REAS_ID = ''

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SOLD_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OD.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

WHERE
    CAL.DAY_DATE BETWEEN DATE '2015-03-01' AND CURRENT_DATE-1
    AND M.PBU_NBR = '01'
    AND OE_REPL_IND = 'Replacement'
    AND (
        OOL.OPEN_CNFRM_QTY > 0
        AND OD.PLN_GOODS_ISS_DT BETWEEN CAL.MONTH_DT AND END_OF_MONTH_DT
        )

GROUP BY
    CAL.DAY_DATE
    , CAL.MONTH_DT
    , END_OF_MONTH_DT
    , CAL.WEEK_OF_MONTH

    , OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR

    , OD.ORDER_CAT_ID
    , OD.ORDER_TYPE_ID
    , OD.PO_TYPE_ID

    , OD.ORDER_DELIV_BLK_CD
    --, MAX(OD.DELIV_BLK_CD) AS SCHD_LN_DELIV_BLK
    , OD.SHIP_COND_ID
    , OD.DELIV_PRTY_ID
    , OD.SPCL_PROC_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , OD.CUST_GRP2_CD

    , OD.SOLD_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME
    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME

    , OD.MATL_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME

    , OD.FACILITY_ID
    , F.FACILITY_NAME

    , OD.ORDER_DT
    , OD.ORDER_LN_CRT_DT
    , OD.CUST_RDD
    , OD.FRST_MATL_AVL_DT
    , OD.FRST_PLN_GOODS_ISS_DT
    , OD.FRST_RDD
    , OD.FC_MATL_AVL_DT
    , OD.FC_PLN_GOODS_ISS_DT
    , OD.FRST_PROM_DELIV_DT

    , OOL.SLS_QTY_UNIT_MEAS_ID

    ) OO

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OO.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OO.ORDER_ID
        AND OD.ORDER_LINE_NBR = OO.ORDER_LINE_NBR
        AND OD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'

    LEFT OUTER JOIN NA_VWS.OPEN_ORDER_SCHDLN OOL
        ON OOL.ORDER_FISCAL_YR = OD.ORDER_FISCAL_YR
        AND OOL.ORDER_ID = OD.ORDER_ID
        AND OOL.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = OD.SCHED_LINE_NBR
        AND OOL.EXP_DT = CAST('5555-12-31' AS DATE)

GROUP BY
    OO.DAY_DATE
    , OO.MONTH_DT
    , OO.END_OF_MONTH_DT
    , OO.WEEK_OF_MONTH

    , OO.ORDER_FISCAL_YR
    , OO.ORDER_ID
    , OO.ORDER_LINE_NBR
    , OO.ORDER_CAT_ID
    , OO.ORDER_TYPE_ID
    , OO.PO_TYPE_ID

    , OO.SHIP_COND_ID
    , OO.PROD_ALLCT_DETERM_PROC_ID
    , OO.CUST_GRP2_CD

    , OO.ORDER_DELIV_BLK_CD
    , OO.SCHD_LN_DELIV_BLK 
    , OO.DELIV_PRTY_ID 
    , OO.SPCL_PROC_ID 

    , OD.ORDER_DELIV_BLK_CD
    --, MAX(OD.DELIV_BLK_CD) AS CURR_SL_DELIV_BLK_CD
    , OD.DELIV_PRTY_ID 
    , OD.SPCL_PROC_ID 

    , OD.REJ_REAS_ID
    , OD.CANCEL_DT

    , OO.SOLD_TO_CUST_ID
    , OO.CUST_NAME
    , OO.OWN_CUST_ID
    , OO.OWN_CUST_NAME
    , OO.SALES_ORG_CD
    , OO.SALES_ORG_NAME
    , OO.DISTR_CHAN_CD
    , OO.DISTR_CHAN_NAME
    , OO.CUST_GRP_ID
    , OO.CUST_GRP_NAME
    , OO.OE_REPL_IND

    , OO.MATL_ID
    , OO.DESCR
    , OO.PBU_NBR
    , OO.PBU_NAME
    
    , OO.FACILITY_ID 
    , OO.FACILITY_NAME
    , OD.FACILITY_ID 

    , OO.ORDER_DT 
    , OO.ORDER_LN_CRT_DT
    , OO.CUST_RDD 
    , OO.FRST_MATL_AVL_DT 
    , OO.FRST_PLN_GOODS_ISS_DT 
    , OO.FRST_RDD 
    , OO.FC_MATL_AVL_DT 
    , OO.FC_PLN_GOODS_ISS_DT
    , OO.FRST_PROM_DELIV_DT 

    , OD.CUST_RDD 
    , OD.FRST_MATL_AVL_DT 
    , OD.FRST_PLN_GOODS_ISS_DT 
    , OD.FRST_RDD 
    , OD.FC_MATL_AVL_DT 
    , OD.FC_PLN_GOODS_ISS_DT
    , OD.FRST_PROM_DELIV_DT

    , OO.SLS_QTY_UNIT_MEAS_ID
    , OO.ORDER_QTY
    , OO.PM_OPEN_CNFRM_QTY
    , OO.CM_OPEN_CNFRM_QTY
    , OO.FM_OPEN_CNFRM_QTY
    , OO.UNCNFRM_QTY 
    , OO.BACK_ORDER_QTY 
    , OO.WAIT_LIST_QTY 

    ) OO

    LEFT OUTER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
        ON DDC.ORDER_FISCAL_YR = OO.ORDER_FISCAL_YR
        AND DDC.ORDER_ID = OO.ORDER_ID
        AND DDC.ORDER_LINE_NBR = OO.ORDER_LINE_NBR

WHERE
    OO.SNAP_CM_OPEN_CNFRM_QTY > 0 

GROUP BY
    OO.DAY_DATE
    , OO.MONTH_DT
    , OO.END_OF_MONTH_DT
    , OO.WEEK_OF_MONTH

    --, OO.ORDER_FISCAL_YR
    --, OO.ORDER_ID
    --, OO.ORDER_LINE_NBR
    , OO.ORDER_CAT_ID
    , OO.ORDER_TYPE_ID
    , OO.PO_TYPE_ID

    , OO.SHIP_COND_ID
    , OO.PROD_ALLCT_DETERM_PROC_ID
    , OO.CUST_GRP2_CD

    , OO.SNAP_HDR_DELIV_BLK_CD
    , OO.SNAP_SL_DELIV_BLK_CD
    , OO.SNAP_DELIV_PRTY_ID
    , OO.SNAP_SPCL_PROC_ID

    , OO.CURR_HDR_DELIV_BLK_CD
    , OO.CURR_SL_DELIV_BLK_CD
    , OO.CURR_DELIV_PRTY_ID
    , OO.CURR_SPCL_PROC_ID

    , OO.REJ_REAS_ID
    , OO.CANCEL_DT

    , OO.SOLD_TO_CUST_ID
    , OO.CUST_NAME
    , OO.OWN_CUST_ID
    , OO.OWN_CUST_NAME
    , OO.SALES_ORG_CD
    , OO.SALES_ORG_NAME
    , OO.DISTR_CHAN_CD
    , OO.DISTR_CHAN_NAME
    , OO.CUST_GRP_ID
    , OO.CUST_GRP_NAME
    , OO.OE_REPL_IND

    , OO.MATL_ID
    , OO.DESCR
    , OO.PBU_NBR
    , OO.PBU_NAME

    , OO.SNAP_FACILITY_ID
    , OO.SNAP_FACILITY_NAME
    , OO.CURR_FACILITY_ID
    , REDIRECT_IND

    , OO.HDR_CRT_DT
    , OO.ITM_CRT_DT
    , OO.SNAP_ORDD
    , OO.SNAP_FRDD_FMAD
    , OO.SNAP_FRDD_FPGI
    , OO.SNAP_FRDD
    , OO.SNAP_FCDD_FMAD
    , OO.SNAP_FCDD_FPGI
    , OO.SNAP_FCDD

    , OO.CURR_ORDD
    , OO.CURR_FRDD_FMAD
    , OO.CURR_FRDD_FPGI
    , OO.CURR_FRDD
    , OO.CURR_FCDD_FMAD
    , OO.CURR_FCDD_FPGI
    , OO.CURR_FCDD

    , OO.SLS_QTY_UNIT_MEAS_ID
    , OO.SNAP_ORDER_QTY
    , OO.SNAP_PM_OPEN_CNFRM_QTY
    , OO.SNAP_CM_OPEN_CNFRM_QTY
    , OO.SNAP_FM_OPEN_CNFRM_QTY
    , OO.SNAP_UNCNFRM_QTY
    , OO.SNAP_BACK_ORDER_QTY
    , OO.SNAP_WAIT_LIST_QTY

    , OO.CURR_ORDER_QTY
    , OO.CURR_OPEN_CNFRM_QTY
    , OO.CURR_UNCNFRM_QTY
    , OO.CURR_BACK_ORDER_QTY
    , OO.CURR_WAIT_LIST_QTY

ORDER BY
    OO.DAY_DATE
    , OO.ORDER_FISCAL_YR
    , OO.ORDER_ID
    , OO.ORDER_LINE_NBR
