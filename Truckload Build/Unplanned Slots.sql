﻿-- paul advised to not pursue due to TLB version 2 plans 2014-11-20

SELECT
    OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR
    , OOL.SCHED_LINE_NBR

    , OD.SHIP_TO_CUST_ID
    , CUST.CUST_NAME AS SHIP_TO_CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME

    , OD.MATL_ID
    , MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
    , MATL.PBU_NBR
    , MATL.PBU_NAME

    , CUST.PRIM_SHIP_FACILITY_ID
    , OD.FACILITY_ID
    , OD.SHIP_PT_ID

    , OD.ORDER_TYPE_ID

    , OD.ROUTE_ID
    , OD.SHIP_COND_ID
    , OD.SPCL_PROC_ID

    , OD.ORDER_DELIV_BLK_CD
    , OD.DELIV_BLK_CD
    , OD.DELIV_PRTY_ID
    , OD.DELIV_GRP_CD

    , OD.PLN_MATL_AVL_DT AS MAD_FIRST_DATE
    , OD.PLN_GOODS_ISS_DT AS PGI_FIRST_DATE
    , OD.PLN_DELIV_DT AS FIRST_DATE

    , OD.CUST_RDD AS ORDD

    , OD.FRST_MATL_AVL_DT AS FRDD_FMAD
    , OD.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI
    , OD.FRST_RDD AS FRDD

    , OD.QTY_UNIT_MEAS_ID
    , OD.ORDER_QTY

    , OOL.OPEN_CNFRM_QTY
    --, OOL.UNCNFRM_QTY
    --, OOL.BACK_ORDER_QTY

    , OD.WT_UNITS_MEAS_ID
    , CAST(OOL.OPEN_CNFRM_QTY * MATL.UNIT_WT AS DECIMAL(15,3)) AS OPEN_CNFRM_WT

    , CMP.CMPRS_FCTR_QTY
    , CMP.MATL_HIER_CMPRS_DESC

    , OD.VOL_UNIT_MEAS_ID
    , CAST(OOL.OPEN_CNFRM_QTY * MATL.UNIT_VOL * CMP.CMPRS_FCTR_QTY AS DECIMAL(15,3)) AS OPEN_CNFRM_VOL

FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOL.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = 1
        AND OD.EXP_DT = DATE '5555-12-31'
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.CUST_GRP2_CD = 'TLB'
        AND OD.REJ_REAS_ID = ''

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
        AND CUST.CUST_GRP2_CD = 'TLB'
    
    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = OD.MATL_ID
    
    INNER JOIN NA_BI_VWS.TL_CMPRS_MSTR_CURR CMP
        ON CMP.MATL_HIER_ID = MATL.PBU_NBR || MATL.MKT_AREA_NBR

WHERE
    OOL.OPEN_CNFRM_QTY > 0



/*    OR OOL.UNCNFRM_QTY > 0
    OR OOL.BACK_ORDER_QTY > 0*/



/*SELECT
    TLC.CUST_ID
    , TLC.DELIV_DT
    , TLC.TRLR_TYP_ID
    , TLT.TRLR_TYP_DESC
    , TLC.RPT_TL_SEQ_ID
    , TLC.MIN_WT_QTY
    , TLT.MAX_WT_QTY
    , TLT.VOL_QTY AS MAX_VOL_QTY

FROM NA_BI_VWS.TL_CAP_DELIV_SCHD_CURR TLC

    INNER JOIN NA_BI_VWS.TL_TRLR_MSTR_CURR TLT
        ON TLT.TRLR_TYP_ID = TLC.TRLR_TYP_ID

WHERE
    TLC.DELIV_DT > CURRENT_DATE
    AND TLC.DELIV_GRP_CD = '000'
    AND TLC.TL_PLN_CD IS NULL*/