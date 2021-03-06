﻿


SELECT
    SL.FISCAL_YR
    , SL.SLS_DOC_ID
    , SL.SLS_DOC_ITM_ID
    , SL.SCHD_LN_ID

    , CAL.MONTH_DT - CAST(1 AS INTERVAL DAY(4)) AS END_OF_PRIOR_MONTH_DT
    , CAL.MONTH_DT AS MEAS_BEGIN_MONTH_DT
    , ADD_MONTHS(CAL.MONTH_DT, 1) - CAST(1 AS INTERVAL DAY(4)) AS MEAS_END_MONTH_DT
    , OC.LAST_ORDER_DAY_OF_MONTH

    , SD.CUST_PRCH_ORD_ID
    , SD.CUST_PRCH_ORD_TYP_CD
    , SD.CUST_PRCH_ORD_DT

    , SD.SOLD_TO_CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , SD.SRC_CRT_DT AS HDR_CRT_DT
    , SD.SRC_CRT_TM AS HDR_CRT_TM
    , SD.SRC_CRT_USR_ID AS HDR_CRT_USR_ID
    , SD.SAP_TRANS_CD AS HDR_SAP_TRANS_CD
    , SD.SRC_UPD_DT AS HDR_UPD_DT
    , SDI.SRC_CRT_TS AS ITM_CRT_TS
    , SDI.SRC_UPD_DT AS ITM_UPD_DT

    , SD.OUTLN_AGRMNT_VLD_FRM_DT
    , SD.OUTLN_AGRMNT_VLD_TO_DT

    , SD.SD_DOC_CTGY_CD
    , SD.TRANS_GRP_CD
    , SD.SLS_DOC_TYP_CD

    , SD.CO_CD
    , SD.SALES_ORG_CD
    , SD.DISTR_CHAN_CD
    , SD.DIV_CD

    , SDI.SLS_DOC_ITM_CTGY_CD
    , SDI.ITM_RLVNT_DELIV_IND
    , SDI.ITM_RLVNT_BILL_ICD
    , SDI.REJ_REAS_ID
    , SDI.DELIV_GRP_ID
    , SDI.BILL_BLK_CD
    , SDI.DELIV_PRTY_CD
    , SDI.AVAIL_CHK_GRP_CD

    , SDI.FACILITY_ID
    , F.FACILITY_NAME
    , SDI.STOR_LOC_CD
    , SDI.SHIP_RCVE_PT_CD

    , SDI.MATL_ID
    , SDI.MATL_HIER_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME

    , SL.SCHD_LN_CTGY_CD
    , SL.ITM_RLVNT_DELIV_IND
    , SL.EARLY_PSSBL_RSRV_DT
    , SL.ITM_RLVNT_DELIV_IND
    , SL.DELIV_DT_CNFRM_IND

    , SL.MATL_AVAIL_DT
    , SL.GOODS_ISS_DT
    , SL.SCHD_LN_DELIV_DT
    , CASE
        WHEN SL.MATL_AVAIL_DT BETWEEN SD.OUTLN_AGRMNT_VLD_FRM_DT AND SD.OUTLN_AGRMNT_VLD_TO_DT
            THEN '='
        WHEN SL.MATL_AVAIL_DT < SD.OUTLN_AGRMNT_VLD_FRM_DT
            THEN '<'
        WHEN SL.MATL_AVAIL_DT > SD.OUTLN_AGRMNT_VLD_TO_DT
            THEN '>'
        END AS TEST_MAD_IN_VALIDITY_PERIOD

    , SDI.SLS_UOM_CD AS QTY_UOM_CD
    , SDI.SLS_UNIT_CUM_ORD_QTY AS ITM_ORD_QTY
    , SDI.SLS_UNIT_CUM_REQ_DELIV_QTY AS ITM_REQ_DELIV_QTY
    , SDI.SLS_UNIT_CUM_CNFRM_QTY AS ITM_CNFRM_QTY
    , SDI.SLS_UNIT_CUM_CNFRM_QTY / SDI.SLS_UNIT_CUM_ORD_QTY AS ITM_CNFRM_PCT

    , SL.SLS_UNIT_CNFRM_QTY AS SL_CNFRM_QTY
    , SL.SLS_UNIT_CNFRM_QTY / SDI.SLS_UNIT_CUM_ORD_QTY AS SL_CNFRM_PCT
    , CASE WHEN TEST_MAD_IN_VALIDITY_PERIOD IN ('<'. '=') THEN SL.SLS_UNIT_CNFRM_QTY ELSE 0 END AS SL_CNFRM_QTY_IN_VLDTY_PD
    , SL_CNFRM_QTY_IN_VLDTY_PD / SDI.SLS_UNIT_CUM_ORD_QTY AS SL_CNFRM_IN_VLDTY_PD_PCT

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON END_OF_PRIOR_MONTH_DT BETWEEN SD.EFF_DT AND SD.EXP_DT
        AND SD.SD_DOC_CTGY_CD = 'E'
        AND SD.SLS_DOC_TYP_CD = 'ZLZ'
        AND MEAS_BEGIN_MONTH_DT >= SD.OUTLN_AGRMNT_VLD_FRM_DT
        AND MEAS_END_MONTH_DT <= OUTLN_AGRMNT_VLD_TO_DT

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = SD.SOLD_TO_CUST_ID

    INNER JOIN (
        SELECT
            CAL.MONTH_DT
            , O.ORD_DAY_DATE AS LAST_ORDER_DAY_OF_MONTH
            , O.ORD_DAY
        FROM GDYR_BI_VWS.GDYR_CAL_ORD O
            INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                ON CAL.DAY_DATE = O.ORD_DAY_DATE
        WHERE
            CAL.DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE, -12) AND ADD_MONTHS(CURRENT_DATE, 3)
        QUALIFY
            -- FIND FIRST DAY_DATE IN LAST ORDER DAY OF MONTH
            ROW_NUMBER() OVER (PARTITION BY CAL.MONTH_DT ORDER BY O.ORD_DAY DESC, O.ORD_DAY_DATE ASC) = 1
            ) OC
        ON OC.MONTH_DT = CAL.MONTH_DT

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM SDI
        ON SDI.FISCAL_YR = SD.FISCAL_YR
        AND SDI.SLS_DOC_ID = SD.SLS_DOC_ID
        AND END_OF_PRIOR_MONTH_DT BETWEEN SDI.EFF_DT AND SDI.EXP_DT
        --AND SDI.SLS_DOC_ITM_CTGY_CD = 'ZLMA'
        AND SDI.SRC_CRT_TS BETWEEN CURRENT_TIMESTAMP - INTERVAL '12' MONTH AND CURRENT_TIMESTAMP

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = SDI.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = SDI.MATL_ID
        AND M.PBU_NBR = '01'

    INNER JOIN NA_BI_vWS.NAT_SLS_DOC_SCHD_LN SL
        ON SL.FISCAL_YR = SDI.FISCAL_YR
        AND SL.SLS_DOC_ID = SDI.SLS_DOC_ID
        AND SL.SLS_DOC_ITM_ID = SDI.SLS_DOC_ITM_ID
        AND END_OF_PRIOR_MONTH_DT BETWEEN SL.EFF_DT AND SL.EXP_DT
        --AND SL.SCHD_LN_CTGY_CD = 'L3'
        AND SL.SCHD_LN_DELIV_DT BETWEEN CURRENT_DATE - INTERVAL '12' MONTH AND CURRENT_DATE + INTERVAL '3' MONTH

WHERE
    CAL.MONTH_DT = DATE '2015-01-01'
    AND CAL.DAY_DATE = CAL.MONTH_DT

ORDER BY
    SL.FISCAL_YR
    , SL.SLS_DOC_ID
    , SL.SLS_DOC_ITM_ID
    , SL.SCHD_LN_ID
