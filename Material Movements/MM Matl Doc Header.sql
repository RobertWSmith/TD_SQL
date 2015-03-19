﻿SELECT
    MD.MATL_DOC_YR
    , MD.MATL_DOC_ID

    , MD.TRANS_TYP_CD
    , MD.ACCTNG_DOC_TYP_CD

    , MD.DOC_ISSUE_DT
    , MD.POST_DT
    , PD_CAL.MONTH_DT AS POST_MTH_DT
    , MD.ACCTNG_DOC_CREATE_DT
    , AD_CAL.MONTH_DT AS ACCTNG_DOC_MTH_DT
    , MD.ACCTNG_DOC_CREATE_TM
    , MD.CREATOR_ID
    , MD.REF_DOC_ID
    , MD.GOODS_RCPT_BOL_ID
    , MD.DOC_HDR_TXT

FROM GDYR_BI_VWS.NAT_MATL_DOC_CURR MD

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
        ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT