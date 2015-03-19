﻿SELECT
    CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
    , CAST(CASE
        WHEN MDI.MVMNT_TYP_CD = '643'
            THEN 'CO'
        ELSE 'CC'
        END AS VARCHAR(25)) AS DATA_TYPE
    , DI.FISCAL_YR
    , DI.DELIV_DOC_ID
    , DI.DELIV_DOC_ITM_ID

    , DD.ORIG_DOC_DT
    , CAL.MONTH_DT AS ORIG_DOC_MONTH_DT
    , DD.SD_DOC_CTGY_CD AS DELIV_CTGY_CD
    , DD.DELIV_TYP_CD
    , DI.ITM_CTGY_CD

    , DI.SD_DOC_CTGY_CD
    , DI.SLS_DOC_FISCAL_YR
    , DI.SLS_DOC_ID
    , DI.SLS_DOC_ITM_ID

    , DD.SHIP_TO_CUST_ID
    , DD.VEND_ID

    , DD.FACILITY_ID AS HDR_FACILITY_ID
    , DI.FACILITY_ID AS ITM_FACILITY_ID
    , DI.STOR_LOC_CD

    , DI.MATL_ID
    , DI.BATCH_NBR

    , DI.BASE_UOM_CD
    , DI.ACTL_DELIV_QTY * CASE WHEN MDI.MVMNT_TYP_CD = '643' THEN 1 ELSE -1 END AS ITM_QTY

    , MDI.MVMNT_TYP_CD
    , MDI.DEBIT_CREDIT_IND

FROM GDYR_VWS.DELIV_DOC_ITM DI

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = DI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DI.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_VWS.DELIV_DOC DD
        ON DD.FISCAL_YR = DI.FISCAL_YR
        AND DD.DELIV_DOC_ID = DI.DELIV_DOC_ID
        AND DD.ORIG_SYS_ID = 2
        AND DD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND DD.SD_DOC_CTGY_CD = '7'
        AND DD.DELIV_TYP_CD = 'EL'

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DD.ORIG_DOC_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI
        ON MDI.PRCH_DOC_ID = DI.SLS_DOC_ID
        AND MDI.PRCH_DOC_ITM_ID = DI.SLS_DOC_ITM_ID
        AND MDI.MVMNT_TYP_CD IN ('643', '644')

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
        AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID
        AND MD.GOODS_RCPT_BOL_ID = DD.BILL_LADING_ID

WHERE
    DI.ORIG_SYS_ID = 2
    AND DI.EXP_DT = CAST('5555-12-31' AS DATE)
    AND DI.SD_DOC_CTGY_CD = 'V'
    AND M.MATL_TYPE_ID = 'PCTL'
    AND M.EXT_MATL_GRP_ID = 'TIRE'

    AND M.PBU_NBR = CAST(#prompt('P_PBU', 'text', '''01''')# AS CHAR(2))
    AND CAL.CAL_YR = CAST(#prompt('P_CalYear', 'integer', '2014')# AS INTEGER)
    AND CAL.CAL_MTH BETWEEN CAST(#prompt('P_BeginCalMonth', 'integer', '1')# AS INTEGER)
        AND CAST(#prompt('P_EndCalMonth', 'integer', '12')# AS INTEGER)
