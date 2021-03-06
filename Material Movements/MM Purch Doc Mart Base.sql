﻿SELECT
    PDI.PRCH_DOC_ID
    , PDI.PRCH_DOC_ITM_ID

    , PD.CO_CD AS HDR_CO_CD
    , PDI.CO_CD AS ITM_CO_CD
    , PD.PO_CROSS_CO_ID

    , PD.PRCH_CTGY_CD
    , PD.PRCH_TYPE_CD
    , PD.PRCH_TYPE_CNTL_IND
    , PDI.PRCH_ITM_CTGY_CD
    , PD.PRCH_ORG_CD
    , PD.PRCH_GRP_CD

    , PD.CREATE_DT
    , PD.PRCH_DT
    , PDI.PRICE_DT
    , PDI.CHANGE_DT AS ITM_UPD_DT

    , PD.CREATOR_ID
    , PD.STATUS_IND
    , PD.DEL_IND AS HDR_DEL_IND
    , PDI.DEL_IND AS ITM_DEL_IND
    , PDI.RFQ_STATUS_IND
    , PDI.DELIV_FULL_IND
    , PDI.INVC_FINAL_IND
    , PDI.GR_IND AS ITM_GR_IND

    , PD.VEND_ID

    , PDI.MATL_ID
    , PDI.MATL_GRP_CD
    , PDI.MATL_TYPE_ID

    , PD.FACILITY_ID AS HDR_FACILITY_ID
    , PDI.FACILITY_ID AS ITM_FACILITY_ID
    , PDI.STOR_LOC_ID

    , PDI.PO_UOM_CD
    , PDI.ORIG_PO_QTY
    , PDI.PO_QTY

    , PDI.GOODS_RCPT_DY_QTY
    , PDI.INCOTERM_CD
    , PDI.INCOTERM_TXT
    , PDI.RETURN_IND
    , PDI.ORDER_REAS_CD
    , PDI.DELIV_TYPE_ID
    , PDI.POST_LOGIC_IND
    , PDI.CNFRM_CNTRL_ID
    , PDI.MAX_ONTIME_SHIP_DT
    , PDI.MIN_EST_DELIV_DT
    , PDI.MAX_EST_DELIV_DT

FROM GDYR_VWS.PRCH_DOC_ITM PDI

    INNER JOIN GDYR_VWS.PRCH_DOC PD
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
        AND PD.ORIG_SYS_ID = 2
        AND PD.EXP_DT = CAST('5555-12-31' AS DATE)

WHERE
    PDI.ORIG_SYS_ID = 2
    AND PDI.EXP_DT = CAST('5555-12-31' AS DATE)
