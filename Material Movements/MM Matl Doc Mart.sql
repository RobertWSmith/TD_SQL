﻿SELECT
    CAST('CCPO' AS VARCHAR(25)) AS TIMING_CD
    , MDI.MATL_DOC_YR
    , MDI.MATL_DOC_ID
    , MDI.MATL_DOC_ITM_ID

    , MD.TRANS_TYP_CD
    , MD.ACCTNG_DOC_TYP_CD

    , MD.DOC_ISSUE_DT

    , PD_CAL.MONTH_DT AS POST_MONTH_DT
    , MD.POST_DT

    , AD_CAL.MONTH_DT AS ACCTNG_DOC_CRT_MONTH_DT
    , MD.ACCTNG_DOC_CREATE_DT
    , MD.ACCTNG_DOC_CREATE_TM

    , MD.CREATOR_ID
    , MD.REF_DOC_ID AS HDR_REF_DOC_ID
    , MD.GOODS_RCPT_BOL_ID
    , MD.DOC_HDR_TXT

    , MDI.CO_CD

    , MDI.MVMNT_TYP_CD
    , CAST(CASE
        WHEN MDI.MVMNT_TYP_CD IN ('909', '910', '911')
            THEN 'PC' --PRODUCTION CREDITS
        WHEN MDI.MVMNT_TYP_CD IN (
                    '601', '602'
                    , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                )
            THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
        WHEN MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17')
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'RT'-- STOCK TRANSFER RECEIPT REVERSAL
                ELSE 'TR'  -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
            END)
        WHEN MDI.MVMNT_TYP_CD = '641'
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MDI.MVMNT_TYP_CD = '642'
            THEN 'TC'
        WHEN MDI.MVMNT_TYP_CD = '643'
            THEN 'IP' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
        WHEN MDI.MVMNT_TYP_CD = '644'
            THEN 'IC'
        WHEN MDI.MVMNT_TYP_CD IN ('978', '979')
            THEN 'RR' -- RETURN RECEIPTED
        WHEN MDI.MVMNT_TYP_CD LIKE '7%' OR MDI.MVMNT_TYP_CD IN (
                    '551', '552', '553', '554'
                    , '851', '852'
                    , '921', '922', '923', '924', '925', '926', '928', '935', '936', '941', '942', '943', '951', '952', '959', '960', '961', '962'
                )
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'IL' -- INVENTORY LOSS
                ELSE 'IG' -- INVENTORY GAIN
                END)
        WHEN MDI.MVMNT_TYP_CD LIKE '2%'
            THEN 'GC' -- GOODS ISSUE FOR CONSUMPTION
        WHEN MDI.MVMNT_TYP_CD LIKE ANY ('3%', '4%')
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, MDI.ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS VARCHAR(25)) AS DATA_TYPE

    , MDI.STK_TYP_CD
    , MDI.SPCL_STK_TYP_CD
    , MDI.MVMNT_ICD
    , MDI.CNSMPT_POST_ICD
    , MDI.RCPT_ICD
    , MDI.MVMNT_REAS_ID

    , MDI.DEBIT_CREDIT_IND
    , MDI.DELIV_COMPL_IND

    , MDI.VEND_ID
    , MDI.CUST_ID
    , MDI.GOODS_RECIPIENT_ID

    , MDI.MATL_ID
    , MDI.BATCH_ID

    , MDI.FACILITY_ID
    , MDI.STOR_LOC_ID

    , MDI.BASE_UOM_CD
    , MDI.ITM_QTY

    , MDI.ORDER_UOM_CD
    , MDI.GOODS_RCPT_QTY

    , MDI.PRCH_DOC_ID
    , MDI.PRCH_DOC_ITM_ID

    , MDI.SLS_ORD_ID
    , MDI.SLS_ORD_ITM_ID

    , MDI.FISCAL_YR
    , MDI.ORDER_ID
    , MDI.ORDER_LINE_NBR

    , MDI.REF_DOC_FISCAL_YR AS ITM_REF_DOC_FISCAL_YR
    , MDI.REF_DOC_ID AS ITM_REF_DOC_ID
    , MDI.REF_DOC_ITM_ID AS ITM_REF_DOC_ITM_ID

    , MDI.TRNSFR_RQMNT_ID
    , MDI.TRNSFR_RQMNT_ITM_ID
    , MDI.TRNSFR_ORDER_ID
    , MDI.TRNSFR_PRTY_ID

FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI

    INNER JOIN GDYR_BI_vWS.NAT_MATL_CURR M
        ON M.MATL_ID = MDI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = MDI.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
        AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
        ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

WHERE
    MDI.CO_CD IN ('N101', 'N102', 'N266')
    AND MDI.MVMNT_TYP_CD NOT LIKE ANY ('2%', '3%', '4%')
    AND MDI.MVMNT_TYP_CD NOT IN ('101', '102', '561', '562', 'Y17')

    AND M.MATL_TYPE_ID = 'PCTL'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    --AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT

    AND M.PBU_NBR = CAST(#prompt('P_PBU', 'text', '''01''')# AS CHAR(2))
    --AND PD_CAL.CAL_YR = CAST(#prompt('P_CalYear', 'integer', '2014')# AS INTEGER)
    --AND PD_CAL.CAL_MTH BETWEEN CAST(#prompt('P_BeginCalMonth', 'integer', '1')# AS INTEGER)
        --AND CAST(#prompt('P_EndCalMonth', 'integer', '12')# AS INTEGER)
    --AND AD_CAL.CAL_YR = CAST(#prompt('P_CalYear', 'integer', '2014')# AS INTEGER)
    --AND AD_CAL.CAL_MTH BETWEEN CAST(#prompt('P_BeginCalMonth', 'integer', '1')# AS INTEGER)
        --AND CAST(#prompt('P_EndCalMonth', 'integer', '12')# AS INTEGER)

