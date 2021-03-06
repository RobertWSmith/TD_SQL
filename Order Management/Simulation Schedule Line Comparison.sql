﻿SELECT
    COALESCE(R.ORDER_FISCAL_YR, SM.ORDER_FISCAL_YR) AS RS_ORDER_FISCAL_YR
    , COALESCE(R.ORDER_ID, SM.ORDER_ID) AS RS_ORDER_ID
    , COALESCE(R.ORDER_LINE_NBR, SM.ORDER_LINE_NBR) AS RS_ORDER_LINE_NBR
    , COALESCE(R.SCHED_LINE_NBR, SM.SCHED_LINE_NBR) AS RS_SCHD_LN_ID
    
    , COALESCE(R.RESCHD_DT, SM.RESCHD_DT) AS RS_RESCHD_DT
    , R.RESCHD_TM AS PD_RESCHD_TM
    , SM.RESCHD_TM AS SIM_RESCHD_TM

    , CASE
        WHEN R.ORDER_ID IS NOT NULL
            THEN 'Y'
        ELSE 'N'
        END PROD_RSCHD_IND
    , CASE
        WHEN SM.ORDER_ID IS NOT NULL
            THEN 'Y'
        ELSE 'N'
        END SIM_RSCHD_IND

    , SDI.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME

    , SDI.FACILITY_ID
    , F.FACILITY_NAME

    , SD.SOLD_TO_CUST_ID
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
        WHEN C.SALES_ORG_CD IN ('N301', 'N311', 'N321', 'N307', 'N317', 'N336') OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD IN ('30', '31'))
            THEN 'REPL'
        ELSE 'OE'
        END AS OE_REPL_IND

    , R.DELIV_DT_CHG_CD AS PD_DELIV_DT_CHG_CD
    , R.PLN_MATL_AVAIL_DT AS PD_PLN_MATL_AVAIL_DT
    , R.RESCHD_MATL_AVAIL_DT AS PD_RESCHD_MATL_AVAIL_DT
    , ZEROIFNULL(R.MATL_AVAIL_DT_VAR_QTY) AS PD_MATL_AVAIL_DT_VAR_QTY
    , R.PLN_DELIV_DT AS PD_PLN_DELIV_DT
    , R.RESCHD_DELIV_DT AS PD_RESCHD_DELIV_DT
    , ZEROIFNULL(R.DELIV_DT_VAR_QTY) AS PD_DELIV_DT_VAR_QTY
    , CASE
        WHEN R.PLN_DELIV_DT IS NOT NULL AND R.RESCHD_DELIV_DT IS NULL
            THEN 'Created SL'
        WHEN R.PLN_DELIV_DT IS NULL AND R.RESCHD_DELIV_DT IS NOT NULL
            THEN 'Deleted SL'
        WHEN R.PLN_DELIV_DT = R.RESCHD_DELIV_DT
            THEN 'No Change'
        WHEN R.PLN_DELIV_DT < R.RESCHD_DELIV_DT
            THEN 'Push'
        WHEN R.PLN_DELIV_DT > R.RESCHD_DELIV_DT
            THEN 'Pull'
        ELSE 'Undefined'
        END AS PD_RESCHD_DELIV_DT_CMP

    , R.CNFRM_QTY_CHG_CD AS PD_CNFRM_QTY_CHG_CD
    , ZEROIFNULL(R.CNFRM_QTY) AS PD_CNFRM_QTY
    , ZEROIFNULL(R.RESCHD_CNFRM_QTY) AS PD_RESCHD_CNFRM_QTY
    , ZEROIFNULL(R.CNFRM_VAR_QTY) AS PD_CNFRM_VAR_QTY

    , CASE
        WHEN R.CNFRM_QTY = R.RESCHD_CNFRM_QTY
            THEN 'No Change'
        WHEN R.CNFRM_QTY < R.RESCHD_CNFRM_QTY
            THEN 'Increase'
        WHEN R.CNFRM_QTY > R.RESCHD_CNFRM_QTY
            THEN 'Decrease'
        ELSE 'Undefined'
        END AS PD_CNFRM_QTY_CMP

    , SM.DELIV_DT_CHG_CD AS SIM_DELIV_DT_CHG_CD
    , SM.PLN_MATL_AVAIL_DT AS SIM_PLN_MATL_AVAIL_DT
    , SM.RESCHD_MATL_AVAIL_DT AS SIM_RESCHD_MATL_AVAIL_DT
    , ZEROIFNULL(SM.MATL_AVAIL_DT_VAR_QTY) AS SIM_MATL_AVAIL_DT_VAR_QTY
    , SM.PLN_DELIV_DT AS SIM_PLN_DELIV_DT
    , SM.RESCHD_DELIV_DT AS SIM_RESCHD_DELIV_DT
    , ZEROIFNULL(SM.DELIV_DT_VAR_QTY) AS SIM_DELIV_DT_VAR_QTY

    , CASE
        WHEN SM.PLN_DELIV_DT IS NOT NULL AND SM.RESCHD_DELIV_DT IS NULL
            THEN 'Created SL'
        WHEN SM.PLN_DELIV_DT IS NULL AND SM.RESCHD_DELIV_DT IS NOT NULL
            THEN 'Deleted SL'
        WHEN SM.PLN_DELIV_DT = SM.RESCHD_DELIV_DT
            THEN 'No Change'
        WHEN SM.PLN_DELIV_DT < SM.RESCHD_DELIV_DT
            THEN 'Push'
        WHEN SM.PLN_DELIV_DT > SM.RESCHD_DELIV_DT
            THEN 'Pull'
        ELSE 'Undefined'
        END AS SIM_RESCHD_DELIV_DT_CMP

    , SM.CNFRM_QTY_CHG_CD AS SIM_CNFRM_QTY_CHG_CD
    , ZEROIFNULL(SM.CNFRM_QTY) AS SIM_CNFRM_QTY
    , ZEROIFNULL(SM.RESCHD_CNFRM_QTY) AS SIM_RESCHD_CNFRM_QTY
    , ZEROIFNULL(SM.CNFRM_VAR_QTY) AS SIM_CNFRM_VAR_QTY

    , CASE
        WHEN SM.CNFRM_QTY = SM.RESCHD_CNFRM_QTY
            THEN 'No Change'
        WHEN SM.CNFRM_QTY < SM.RESCHD_CNFRM_QTY
            THEN 'Prod Confirme'
        WHEN SM.CNFRM_QTY > SM.RESCHD_CNFRM_QTY
            THEN 'Decrease'
        ELSE 'Undefined'
        END AS SIM_CNFRM_QTY_CMP

    , CASE
        WHEN R.PLN_MATL_AVAIL_DT = SM.PLN_MATL_AVAIL_DT
            THEN 'No Difference'
        WHEN R.PLN_MATL_AVAIL_DT < SM.PLN_MATL_AVAIL_DT
            THEN 'Prod PDD < Sim PDD'
        WHEN R.PLN_MATL_AVAIL_DT > SM.PLN_MATL_AVAIL_DT
            THEN 'Prod PDD > Sim PDD'
        ELSE 'Undefined'
        END AS PD_SIM_MAD_CMP
    , CASE
        WHEN R.RESCHD_MATL_AVAIL_DT = SM.RESCHD_MATL_AVAIL_DT
            THEN 'No Difference'
        WHEN R.RESCHD_MATL_AVAIL_DT < SM.RESCHD_MATL_AVAIL_DT
            THEN 'Prod Reschd PDD < Sim Reschd PDD'
        WHEN R.RESCHD_MATL_AVAIL_DT > SM.RESCHD_MATL_AVAIL_DT
            THEN 'Prod Reschd PDD > Sim Reschd PDD'
        ELSE 'Undefined'
        END AS PD_SIM_RESCHD_MAD_CMP

    , CASE
        WHEN R.PLN_DELIV_DT = SM.PLN_DELIV_DT
            THEN 'No Difference'
        WHEN R.PLN_DELIV_DT < SM.PLN_DELIV_DT
            THEN 'Prod PDD < Sim PDD'
        WHEN R.PLN_DELIV_DT > SM.PLN_DELIV_DT
            THEN 'Prod PDD > Sim PDD'
        ELSE 'Undefined'
        END AS PD_SIM_PDD_CMP
    , CASE
        WHEN R.RESCHD_DELIV_DT = SM.RESCHD_DELIV_DT
            THEN 'No Difference'
        WHEN R.RESCHD_DELIV_DT < SM.RESCHD_DELIV_DT
            THEN 'Prod Reschd PDD < Sim Reschd PDD'
        WHEN R.RESCHD_DELIV_DT > SM.RESCHD_DELIV_DT
            THEN 'Prod Reschd PDD > Sim Reschd PDD'
        ELSE 'Undefined'
        END AS PD_SIM_RESCHD_PDD_CMP

    , CASE
        WHEN R.CNFRM_QTY = SM.CNFRM_QTY
            THEN 'No Difference'
        WHEN R.CNFRM_QTY < SM.CNFRM_QTY
            THEN 'Prod Cnfrm Qty < Sim Cnfrm Qty'
        WHEN R.CNFRM_QTY > SM.CNFRM_QTY
            THEN 'Prod Cnfrm Qty > Sim Cnfrm Qty'
        ELSE 'Undefined'
        END AS PD_SIM_CNFRM_QTY_CMP
    , CASE
        WHEN R.RESCHD_CNFRM_QTY = SM.RESCHD_CNFRM_QTY
            THEN 'No Difference'
        WHEN R.RESCHD_CNFRM_QTY < SM.RESCHD_CNFRM_QTY
            THEN 'Prod Reschd Cnfrm Qty < Sim Reschd Cnfrm Qty'
        WHEN R.RESCHD_CNFRM_QTY > SM.RESCHD_CNFRM_QTY
            THEN 'Prod Reschd Cnfrm Qty > Sim Reschd Cnfrm Qty'
        ELSE 'Undefined'
        END AS PD_SIM_RESCHD_CNFMR_QTY_CMP

FROM NA_BI_VWS.ORD_RESCHD R

    FULL OUTER JOIN SUPP_EDW.ORD_RESCHD SM
        ON SM.ORDER_FISCAL_YR = R.ORDER_FISCAL_YR
        AND SM.ORDER_ID = R.ORDER_ID
        AND SM.ORDER_LINE_NBR = R.ORDER_LINE_NBR
        AND SM.SCHED_LINE_NBR = R.SCHED_LINE_NBR
        AND SM.RESCHD_DT = R.RESCHD_DT
        AND SM.DOC_TYP_CD = 'O'
        AND SM.TRANS_UPD_CD = 'R'
        -- SCENARIO FILTER
        AND SM.EDW_JOB_ID = 150320000

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON SD.FISCAL_YR = RS_ORDER_FISCAL_YR
        AND SD.SLS_DOC_ID = RS_ORDER_ID
        AND SD.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_cURR C
        ON C.SHIP_TO_CUST_ID = SD.SOLD_TO_CUST_ID

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM SDI
        ON SDI.FISCAL_YR = RS_ORDER_FISCAL_YR
        AND SDI.SLS_DOC_ID = RS_ORDER_ID
        AND SDI.SLS_DOC_ITM_ID = RS_ORDER_LINE_NBR
        AND SDI.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = SDI.FACILITY_ID
        AND F.FACILITY_ID IN ('N636', 'N637')

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = SDI.MATL_ID

WHERE
    R.RESCHD_DT = CAST('2015-03-20' AS DATE)
    AND R.DOC_TYP_CD = 'O'
    AND R.TRANS_UPD_CD = 'R'

ORDER BY 1,2,3,4
