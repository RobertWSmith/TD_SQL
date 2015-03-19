SELECT
    MATL_DOC_YR
    , MATL_DOC_ID
    , MATL_DOC_ITM_ID

    , CO_CD

    , MVMNT_TYP_CD
    , CAST(CASE
        WHEN MVMNT_TYP_CD IN ('909', '910', '911')
            THEN 'PC' --PRODUCTION CREDITS
        WHEN MVMNT_TYP_CD IN (
                    '601', '602'
                    , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                )
            THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
        WHEN MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17')
            THEN (CASE
                WHEN DEBIT_CREDIT_IND = 'C'
                    THEN 'RT'-- STOCK TRANSFER RECEIPT REVERSAL
                ELSE 'TR'  -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
            END)
        WHEN MVMNT_TYP_CD IN ('641', '642')
            THEN (CASE
                WHEN DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MVMNT_TYP_CD IN ('643', '644')
            THEN 'IP' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
        WHEN MVMNT_TYP_CD IN ('978', '979')
            THEN 'RR' -- RETURN RECEIPTED
        WHEN MVMNT_TYP_CD LIKE '7%' OR MVMNT_TYP_CD IN (
                    '551', '552', '553', '554'
                    , '851', '852'
                    , '921', '922', '923', '924', '925', '926', '928', '935', '936', '941', '942', '943', '951', '952', '959', '960', '961', '962'
                )
            THEN (CASE
                WHEN DEBIT_CREDIT_IND = 'C'
                    THEN 'IL' -- INVENTORY LOSS
                ELSE 'IG' -- INVENTORY GAIN
                END)
        WHEN MVMNT_TYP_CD LIKE '2%'
            THEN 'GC' -- GOODS ISSUE FOR CONSUMPTION
        WHEN MVMNT_TYP_CD LIKE ANY ('3%', '4%')
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS VARCHAR(25)) AS DATA_TYPE

    , STK_TYP_CD
    , SPCL_STK_TYP_CD
    , MVMNT_ICD
    , CNSMPT_POST_ICD
    , RCPT_ICD

    , DEBIT_CREDIT_IND
    , DELIV_COMPL_IND

    , VEND_ID
    , CUST_ID
    , GOODS_RECIPIENT_ID

    , MATL_ID
    , BATCH_ID

    , FACILITY_ID
    , STOR_LOC_ID

    , BASE_UOM_CD
    , ITM_QTY

    , ORDER_UOM_CD
    , GOODS_RCPT_QTY

    , PRCH_DOC_ID
    , PRCH_DOC_ITM_ID

    , SLS_ORD_ID
    , SLS_ORD_ITM_ID

    , FISCAL_YR
    , ORDER_ID
    , ORDER_LINE_NBR

    , REF_DOC_FISCAL_YR
    , REF_DOC_ID
    , REF_DOC_ITM_ID

FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR 
