﻿SELECT
    SD.FISCAL_YR
    , SD.SLS_DOC_ID
    , SDI.SLS_DOC_ITM_ID
    , SD.INTRNTL_SLS_DOC_ID

    , SD.SRC_CRT_DT AS ORD_HDR_CRT_DT
    , SD.SRC_CRT_TM AS ORD_HDR_CRT_TM
    , SD.SRC_CRT_USR_ID AS ORD_HDR_CRT_USR_ID
    , SD.SRC_UPD_DT AS ORD_HDR_UPD_DT
    , SDI.SRC_CRT_TS AS ORD_ITM_CRT_TS
    , SDI.SRC_CRT_USR_ID
    , SDI.SRC_UPD_DT

    , SD.DOC_DT
    , SD.SD_DOC_CTGY_CD -- ORDER CATEGORY
    , SDI.SLS_DOC_ITM_CTGY_CD -- ORDER LINE CATEGORY
    , SD.TRANS_GRP_CD
    , SD.SLS_DOC_TYP_CD -- ORDER TYPE
    , SD.ORD_REAS_CD
    , SDI.DELIV_GRP_ID -- DELIVERY GROUP (ITEMS WILL BE DELIVERED TOGETHER)
    , SDI.REJ_REAS_ID
    , SD.DOC_COND_ID -- DOCUMENT CONDIONS? B = DELIVERY ORDER, E = DELIVERY ORDER CORRECTION
    , SDI.DELIV_PRTY_CD

    , SD.DELIV_BLK_CD
    , SD.BILL_BLK_CD
    , SDI.BILL_BLK_CD

    , SD.COMPL_DELIV_IND -- INDICATES COMPLETE IF ALL ITEMS ARE COMPLETE -- HEADER

    , SD.PROP_DT_TYP_CD
    , SD.SD_DOC_ICD
    , SD.PRC_COND_TYP_CD

    , SD.SHIP_COND_CD -- SHIPPING CONDITION / TRANSPORTATION TYPE
    , SD.BILL_TYP_CD
    , SD.SLS_PRBL_PCT -- ?

    , SD.CUST_PRCH_ORD_ID
    , SD.CUST_PRCH_ORD_TYP_CD -- PO TYPE ID
    , SD.CUST_PRCH_ORD_DT

    , SD.SHIP_TO_CUST_ID

    , SD.SALES_ORG_CD
    , SD.DISTR_CHAN_CD
    , SD.DIV_CD
    , SDI.REPL_PART_ICD
    , SDI.DIV_CD
    , SD.CO_CD
    , SD.REF_DOC_ID

    , SD.CUST_GRP_ID_1
    , SD.CUST_GRP_ID_2
    , SD.CUST_GRP_ID_3
    , SD.CUST_GRP_ID_4
    , SD.CUST_GRP_ID_5

    -- , SD.REBATE_AGRMNT_ID

    , SD.NXT_PLN_DELIV_DT -- HEADER NEXT PLAN DELIVERY DATE
    , SD.REF_DOC_SLS_DOC_ID
    , SD.ORD_ID
    , SD.NTFCTN_ID

    , SD.PICK_UP_FRM_TS
    , SD.PICK_UP_TO_TS
    , SD.MATL_AVAIL_DT
    , SD.SHIP_REQ_ARRV_TS
    , SD.REQ_DELIV_DT -- REQUESTED DELIVERY DATE (VBAK - VDATU)
    , SDI.CUST_DELIV_DT -- ACTUAL DELIVERY DATE?

    , SDI.ORIG_REQ_DELIV_DT -- ORDD?
    , SDI.REQ_DELIV_DT -- FRDD? (VBAP)
    , SDI.CUST_DELIV_PROM_DT -- FCDD?
    , SDI.CUST_DELIV_PROM_DT_TYP_CD
    , SDI.SHIP_REQ_ARRV_TS -- SEEMS POTENTIALLY IMPORTANT?

    , SD.TOT_QTY

    , SDI.FACILITY_ID
    , SDI.SHIP_RCVE_PT_CD -- SHIPPING POINT
    , SDI.STOR_LOC_CD -- STORAGE LOCATION CODE
    , SDI.ROUTE_CD -- ROUTE ID
    , SDI.ORIG_FACILITY_ID
    , SDI.APO_FACILITY_ID
    , SDI.APO_STOR_LOC_ID

    , SDI.MATL_ID
    , SDI.ORIG_MATL_ID -- ?
    , SDI.ORIG_REQ_MATL_ID -- ?
    , SDI.MATL_GRP_ID
    , SDI.MATL_HIER_ID

    , SDI.ITM_TYP_CD
    , SDI.ITM_RLVNT_DELIV_IND
    , SDI.ITM_RLVNT_BILL_ICD

    , SDI.SLS_UNIT_TGT_QTY

    , SDI.DELIV_RND_QTY
    , SDI.ALLOW_DEVIATE_QTY

    , SDI.FIXED_QTY_IND
    , SDI.ALLOW_UNLMT_OVR_DELIV_IND
    , SDI.OVR_DELIV_LMT_PCT
    , SDI.UNDER_DELIV_LMT_PCT

    , SDI.MAX_PRTL_DELIV_QTY -- MAX NUMBER OF PARTIAL DELIVERIES ALLOWED PER ITEM
    , SDI.PRTL_DELIV_ICD -- PARTIAL DELIVERY AT ITEM LEVEL

    , SDI.SLS_UNIT_CUM_ORD_QTY -- CUMULATIVE ORDER QUANTITY IN SALES UNITS
    , SDI.SLS_UNIT_CUM_REQ_DELIV_QTY -- CUMULATIVE REQUIRED DELIVERY QTY (ALL DELIVERY RELATED SCHEDULE LINES)
    , SDI.SLS_UNIT_CUM_CNFRM_QTY -- CUMULATIVE CONFIRMED QUANTITY IN SALES UNITS
    , SDI.BASE_UNIT_CUM_CNFRM_QTY -- CUMULARIVE CONFIRMED QTY IN BASE UNITS
    , SDI.BASE_UOM_CD -- BASE UNIT OF MEASURE
    , SDI.SLS_UOM_CD -- SALES UNIT OF MEASURE

    , SDI.TOT_GROSS_WT_QTY
    , SDI.TOT_NET_WT_QTY
    , SDI.WT_UOM_CD

    , SDI.TOT_VOL_QTY
    , SDI.VOL_UOM_CD

    , SDI.ORIG_SLS_DOC_ID -- ORIGINATING DOCUMENT
    , SDI.ORIG_SLS_DOC_ITM_ID -- ORIGINATING ITEM
    , SDI.REF_DOC_SLS_DOC_ID -- DOCUMENT NUMBER OF THE REFERENCE DOCUMENT
    , SDI.REF_DOC_SLS_DOC_ITM_ID -- ITEM NUMBER OF THE REFERENCE DOCUMENT

    , SDI.ORD_PRBL_PCT -- ORDER PROBABILITY OF THE ITEM

    , SDI.FIX_SHIP_DY_QTY -- FIXED SHIPPING PROCESSING TIME IN DAYS (= SETUP TIME)
    , SDI.DELIV_DT_QTY_FIX_IND -- DELIVERY DATE AND QUANTITY FIXED INDICATOR

    , SDI.RET_IND -- RETURNS ITEM

    , SDI.AVAIL_CHK_GRP_CD
    , SDI.MATL_PRC_GRP_CD
    , SDI.ACCT_ASSGN_GRP_CD
    , SDI.VOL_REBATE_GRP_CD
    , SDI.PRC_AGR_IND

    , SDI.VAL_TYP_CD
    , SDI.SEPRT_VAL_IND

    , SDI.PROFT_CNTR_ID

    , SDI.MATL_GRP_CD_1
    , SDI.MATL_GRP_CD_2
    , SDI.MATL_GRP_CD_3
    , SDI.MATL_GRP_CD_4
    , SDI.MATL_GRP_CD_5

    , SDI.MATL_SUBST_REAS_CD -- REASON FOR MATERIAL SUBSTITUTION
    , SDI.SPCL_STK_TYP_CD -- SPECIAL STOCK INDICATOR

    , SDI.ALLOC_ICD -- ALLOCATION INDICATOR
    , SDI.PROFT_SEG_ID -- PROFITABILITY SEGMENT NUMBER (CO-PA)

    , SDI.ORD_ID -- ORDER NUMBER (VBAP-AUFNR)
    , SDI.ACCT_ASSGN_CTGY_CD -- ACCOUNT ASSIGNMENT CATEGORY
    , SDI.CONS_POST_ICD -- CONSUMPTION POSTING
    , SDI.RQT_TYP_CD -- REQUIREMENTS TYPE

    , SDI.CRED_MGMT_FUNCT_ACTV_IND -- ITEM WITH ACTIVE CREDIT FUNCTION / RELEVANT FOR CREDIT INDICATOR
    , SDI.EXPCT_PRC_STA_CD
    , SDI.MNL_PRC_CHG_STA_CD
    , SDI.BUS_TRANS_TYP_CD
    , SDI.COST_SHEET_CD
    , SDI.PRC_CALC_REF_MATL_ID
    , SDI.PLN_DELIV_SCHD_INSTR_CD
    , SDI.KANBAN_SEQ_ID
    , SDI.VAL_CONTRACT_ID
    , SDI.VAL_CONTRACT_ITM_ID

    , SDI.SPCL_STK_VAL_ICD

    , SDI.B2B_GRP_ID
    , SDI.B2B_CMPGN_ID
    , SDI.GLS_SLSMN_ID
    , SDI.TTS_SLSMN_ID
    , SDI.FTS_SLSMN_ID
    , SDI.ETS_SLSMN_ID
    , SDI.AVIAT_SLSMN_ID
    , SDI.CAR_DLR_SLSMN_ID
    , SDI.GLS_DIST_SLSMN_ID
    , SDI.TTS_DIST_SLSMN_ID
    , SDI.SLSMN_ID
    , SDI.SLSMN_HIER_LVL_1_ID
    , SDI.SLSMN_HIER_LVL_2_ID
    , SDI.SLSMN_HIER_LVL_3_ID

    , SDI.SAP_TRANS_CD
    , SDI.EXTRA_DMAN_ICD
    , SDI.BILL_PROFT_CNTR_CD

    , SDI.SPCL_APRVL_ID -- SPECIAL APPROVAL NUMBER

    , SDI.CLAIM_STA_CD_1 -- CLAIM STATUS FOR NET SHORT CLAIMS (ZNS DOC TYPE ONLY)
    , SDI.CLAIM_STA_DT_1 -- DATE DETERMINED FOR CLAIM STATUS
    , SDI.CLAIM_STA_CD_2 -- CLAIM STATUS FOR NET SHORT CLAIMS (ZNS DOC TYPE ONLY)
    , SDI.CLAIM_STA_DT_2 -- DATE DETERMINED FOR CLAIM STATUS

    , SDI.CLEAN_CHRG_PCT_IND -- FLAG FOR CLEANING CHARGS %
    , SDI.FINISHED_TIRE_RIM_DIAM

    , SDI.PSEUDO_TERM_DT_1 -- DATE FOR PSEUDO TERMS
    , SDI.PSEUDO_TERM_DT_2
    , SDI.TERM_PAY_ID_1 -- TERMS OF PAYMENT KEY
    , SDI.TERM_PAY_ID_2
    , SDI.TERM_PAY_ID_3

    , SDI.CROSS_DISTR_CHAIN_MATL_STA_CD
    , SDI.DFS_IND
    , SDI.PREC_SD_DOC_CTGY_CD

    , SDI.BOM_STRCTR_HI_LVL_ITM_ID
    , SDI.BATCH_NBR

    , SDI.NTFCTN_ID

    , SDI.FOS_SRV_CNTRY_NAME_CD
    , SDI.FOS_DFLT_SVC_IND

    , SDI.PN_IND
    , SDI.PN_TXT

    , SDI.GRNTE_PRC_DT_CD
    , SDI.EXTRA_DMAN_INQR_BLK_IND
    , SDI.EXTRA_DMAN_INQR_BLK_MNL_IND

    , SDI.EXTN_SLS_DOC_TYP_CD
    , SDI.EXTN_SLS_DOC_ITM_CTGY_CD

    , SDI.KEEP_PLANT_IND
    , SDI.SRV_LVL_TYP_CD -- ?

    , SDI.REL_PROC_CD
    , SDI.REL_SEQ_PROC_IND

    , SDI.CHG_BILL_BLK_STA_IND

    , SDI.BRAND_ID

    , SDI.TAX_SCEN_ID
    , SDI.DELIV_LOC_TYP_CD
    , SDI.MNL_CLOSE_IND

FROM NA_BI_VWS.NAT_SLS_DOC_ITM SDI

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = SDI.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
        AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON SD.FISCAL_YR = SDI.FISCAL_YR
        AND SD.SLS_DOC_ID = SDI.SLS_DOC_ID
        AND SD.EXP_DT = SDI.EXP_DT
        --AND SD.SD_DOC_CTGY_CD = 'C' -- SALES ORDER
        -- ZLZ = SCHEDULING AGREEMENT
        -- ZDB = DELIVERY ON BEHALF OF GOODYEAR
        -- ZKB = CONSIGN SHIPMENT
        -- ZKB = CONSIGN WITHDRAWL
        --AND SD.SLS_DOC_TYP_CD NOT IN ('ZLZ', 'ZKB', 'ZKE') -- 'ZDB',
        --AND SD.CUST_PRCH_ORD_TYP_CD <> 'RO' -- RESERVE ORDERS

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = SD.SHIP_TO_CUST_ID

WHERE
    SDI.EXP_DT = DATE '5555-12-31'
    AND CAST(SDI.SRC_CRT_TS AS DATE) = CURRENT_DATE-1
        --BETWEEN CAST(CURRENT_DATE-1 || ' 00:00:00' AS TIMESTAMP(0)) AND CAST(CURRENT_DATE-1 || ' 11:59:59' AS TIMESTAMP(0))
    AND CUST.OWN_CUST_ID = '00A0006582'

ORDER BY
    SDI.FISCAL_YR
    , SDI.SLS_DOC_ID
    , SDI.SLS_DOC_ITM_ID