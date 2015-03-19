

SELECT 
    MM.RPT_TYPE
    , MM.DATA_TYPE
    , MM.MVMNT_TYP_CD
    , MM.ACCTNG_DOC_TYP_CD
    , MM.POST_MONTH_DT
    , MM.FACILITY_ID
    , MM.MATL_ID
    
    , MM.CUST_ID
    , CUST.CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , CUST.SALES_ORG_CD
    , CUST.DISTR_CHAN_CD
    , CUST.DISTR_CHAN_NAME
    , CUST.CUST_GRP_ID
    , CUST.CUST_GRP_NAME
    
    , MM.BASE_UOM_CD
    , SUM(MM.ITM_QTY) AS ITEM_QTY
FROM (
    SELECT CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
        , CAST(CASE 
                WHEN MDI.MVMNT_TYP_CD IN ('909', '910', '911')
                    THEN 'PC' --PRODUCTION CREDITS
                WHEN MDI.MVMNT_TYP_CD IN ('601', '602', '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994')
                    THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
                WHEN MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17')
                    THEN (
                            CASE 
                                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                                    THEN 'RT' -- STOCK TRANSFER RECEIPT REVERSAL
                                ELSE 'TR' -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
                                END
                            )
                WHEN MDI.MVMNT_TYP_CD = '641'
                    THEN (
                            CASE 
                                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                                END
                            )
                WHEN MDI.MVMNT_TYP_CD = '642'
                    THEN 'TC'
                WHEN MDI.MVMNT_TYP_CD = '643'
                    THEN 'CO' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
                WHEN MDI.MVMNT_TYP_CD = '644'
                    THEN 'CC'
                WHEN MDI.MVMNT_TYP_CD IN ('978', '979')
                    THEN 'RR' -- RETURN RECEIPTED
                WHEN MDI.MVMNT_TYP_CD LIKE '7%'
                    OR MDI.MVMNT_TYP_CD IN ('551', '552', '553', '554', '851', '852', '921', '922', '923', '924', '925', '926', '928', '935', '936', '941', '942', '943', '951', '952', '959', '960', '961', '962')
                    THEN (
                            CASE 
                                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                                    THEN 'IL' -- INVENTORY LOSS
                                ELSE 'IG' -- INVENTORY GAIN
                                END
                            )
                WHEN MDI.MVMNT_TYP_CD LIKE '2%'
                    THEN 'GC' -- GOODS ISSUE FOR CONSUMPTION
                WHEN MDI.MVMNT_TYP_CD LIKE ANY (
                        '3%'
                        , '4%'
                        )
                    THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, MDI.ETC.)
                ELSE 'NC' -- NOT CLASSIFIED
                END AS VARCHAR(25)) AS DATA_TYPE
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
        , MDI.REF_DOC_FISCAL_YR AS ITM_REF_DOC_FISCAL_YR
        , MDI.REF_DOC_ID AS ITM_REF_DOC_ID
        , MDI.REF_DOC_ITM_ID AS ITM_REF_DOC_ITM_ID
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
    WHERE MDI.CO_CD IN ('N101', 'N102', 'N266')
        AND NOT (
            MDI.MVMNT_TYP_CD LIKE ANY (
                '2%'
                , '3%'
                , '4%'
                )
            OR MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', '643', '644', 'Y17')
            )
        AND M.MATL_TYPE_ID = 'PCTL'
        AND M.EXT_MATL_GRP_ID = 'TIRE'
        AND M.PBU_NBR = CAST('01' AS CHAR(2))
        AND PD_CAL.DAY_DATE BETWEEN CAST('2014-01-01' AS DATE) - CAST(EXTRACT(DAY FROM CAST('2014-01-01' AS DATE)) - 1 AS INTERVAL DAY(4)) AND ADD_MONTHS(CAST('2014-12-31' AS DATE), 1) - CAST(EXTRACT(DAY FROM ADD_MONTHS(CAST('2014-12-31' AS DATE), 1)) AS INTERVAL DAY(4))
    ) MM

    
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = MM.CUST_ID
        AND CUST.SALES_ORG_CD IN ('N304', 'N305', 'N306', 'N309', 'N326')
    
WHERE MM.DATA_TYPE = 'GI'

GROUP BY
    MM.RPT_TYPE
    , MM.DATA_TYPE
    , MM.MVMNT_TYP_CD
    , MM.ACCTNG_DOC_TYP_CD
    , MM.POST_MONTH_DT
    , MM.FACILITY_ID
    , MM.MATL_ID
    
    , MM.CUST_ID
    , CUST.CUST_NAME
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , CUST.SALES_ORG_CD
    , CUST.DISTR_CHAN_CD
    , CUST.DISTR_CHAN_NAME
    , CUST.CUST_GRP_ID
    , CUST.CUST_GRP_NAME
    
    , MM.BASE_UOM_CD
