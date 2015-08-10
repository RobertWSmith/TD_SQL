SELECT
    CAST('MM' AS VARCHAR(3)) AS DATA_CTGY
    , CAST(CAST(CASE
        WHEN MM.MVMNT_TYP_CD IN ('909', '910', '911')
            THEN 'PC' --PRODUCTION CREDITS
        WHEN MM.MVMNT_TYP_CD IN (
                    '601', '602'
                    , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                )
            THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
        WHEN MM.MVMNT_TYP_CD IN (
                    '101', '102'
                    , '561', '562'
                    , 'Y17'
                )
            THEN 'TR' -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
        WHEN MM.MVMNT_TYP_CD IN ('641', '642')
            THEN (CASE
                WHEN MM.DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MM.MVMNT_TYP_CD IN ('643', '644')
            THEN 'IC' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
        WHEN MM.MVMNT_TYP_CD IN ('978', '979')
            THEN 'RR' -- RETURN RECEIPTED
        WHEN MM.MVMNT_TYP_CD LIKE '7%' OR MM.MVMNT_TYP_CD IN (
                    '551', '552', '553', '554'
                    , '851', '852'
                    , '921', '922', '923', '924', '925', '926', '928', '935', '936', '941', '942', '943', '951', '952', '959', '960', '961', '962'
                )
            THEN (CASE
                WHEN MM.DEBIT_CREDIT_IND = 'C'
                    THEN 'IL' -- INVENTORY LOSS
                ELSE 'IG' -- INVENTORY GAIN
                END)
        WHEN MM.MVMNT_TYP_CD LIKE '2%'
            THEN 'GC' -- GOODS ISSUE FOR CONSUMPTION
        WHEN MM.MVMNT_TYP_CD LIKE ANY ('3%', '4%')
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS CHAR(2)) || MM.DOC_TYPE AS VARCHAR(25)) AS DATA_TYPE
    , CASE DATA_TYPE
        WHEN 'PC' THEN 'Production Credits'
        WHEN 'GI' THEN 'Goods Issue to Customers'
        WHEN 'TR' THEN 'Stock Transfer Receipt to Total Inventory'
        WHEN 'TO' THEN 'Stock Transfer Outbound Created'
        WHEN 'TI' THEN 'Stock Transfer Inbound Created'
        WHEN 'IC' THEN 'Intercompany Stock Transfer Outbound Post'
        WHEN 'RR' THEN 'Return Receipted'
        WHEN 'IL' THEN 'Inventory Loss'
        WHEN 'IG' THEN 'Inventory Gain'
        WHEN 'GC' THEN 'Goods Issue for Consumption'
        WHEN 'TF' THEN 'Stock Status Transfer (ex. Blocked -> Unrestricted)'
        WHEN 'NC' THEN 'Not Classified'
        ELSE 'Undefined'
        END AS DATA_DESCR
    , MM.DAY_DATE

    , MM.MATL_ID
    , M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME
    , M.MKT_CTGY_PROD_LINE_NBR
    , M.MKT_CTGY_PROD_LINE_NAME
    
    , MM.FACILITY_ID
    , F.FACILITY_NAME

    , MM.CO_CD
    , MM.VEND_ID
    , V.VEND_NM
    , MM.CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME

    , MM.BASE_UOM_CD
    , MM.ITM_QTY

    , MM.TRANS_TYP_CD
    , MM.ACCTNG_DOC_TYP_CD
    , MM.DEBIT_CREDIT_IND
    , MM.MVMNT_TYP_CD
    , MM.SPCL_STK_TYP_CD
    , MM.MVMNT_ICD
    , MM.RCPT_ICD
    , MM.CNSMPT_POST_ICD
    , MTD.MVMNT_TYP_DESC

FROM (

    SELECT
        CAST('' AS VARCHAR(25)) DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID

        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID

        , MDI.BASE_UOM_CD
        , SUM(MDI.ITM_QTY) AS ITM_QTY

        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , COALESCE(MDI.SPCL_STK_TYP_CD, '') AS SPCL_STK_TYP_CD
        , COALESCE(MDI.MVMNT_ICD, '') AS MVMNT_ICD
        , COALESCE(MDI.RCPT_ICD, '') AS RCPT_ICD
        , COALESCE(MDI.CNSMPT_POST_ICD, '') AS CNSMPT_POST_ICD

    FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
            AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID

        INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
            ON PD_CAL.DAY_DATE = MD.POST_DT

    WHERE
        MDI.CO_CD IN ('N101', 'N102', 'N266')

        -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
        AND NOT (
             MDI.MVMNT_TYP_CD IN (
                -- GOODS ISSUE TO CUSTOMER
                '601', '602', '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                -- STOCK TRANSFER CODES
                , '101', '102', '561', '562', '641', '642', '643', '644', 'Y17'
                -- PRODUCTION
                , '909', '910', '911'
                )
             OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
            )

        --AND MD.POST_DT BETWEEN CAST('2015-04-01' AS DATE) AND CURRENT_DATE
        AND MD.POST_DT BETWEEN DATE '2015-01-01' AND CURRENT_DATE-1

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = '07'
            )
        AND MDI.FACILITY_ID IN (
                SELECT
                    FACILITY_ID
                FROM GDYR_BI_VWS.NAT_FACILITY_EN_CURR
                WHERE
                    SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND DISTR_CHAN_CD = '81'
            )

    GROUP BY
        DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID
        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID
        , MDI.BASE_UOM_CD
        --, SUM(MDI.ITM_QTY) AS ITM_QTY
        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , SPCL_STK_TYP_CD
        , MVMNT_ICD
        , RCPT_ICD
        , CNSMPT_POST_ICD


    UNION ALL


    -- (OFFICIAL) POST MONTH <> (WALL CLOCK) ACCOUNTING MONTH
    -- INVERTS QUANTITY TO REPORT MONTH TO ACCOUNT FOR WALL CLOCK VS. OFFICIAL TIMING ISSUES

    SELECT
        CAST('PCCO' AS VARCHAR(25)) AS DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID

        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID

        , MDI.BASE_UOM_CD
        , (-1 * SUM(MDI.ITM_QTY)) AS ITM_QTY

        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , COALESCE(MDI.SPCL_STK_TYP_CD, '') AS SPCL_STK_TYP_CD
        , COALESCE(MDI.MVMNT_ICD, '') AS MVMNT_ICD
        , COALESCE(MDI.RCPT_ICD, '') AS RCPT_ICD
        , COALESCE(MDI.CNSMPT_POST_ICD, '') AS CNSMPT_POST_ICD

    FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
            AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID

        INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
            ON PD_CAL.DAY_DATE = MD.POST_DT

        INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
            ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

    WHERE
        MDI.CO_CD IN ('N101', 'N102', 'N266')

        -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
        AND NOT (
             MDI.MVMNT_TYP_CD IN (
                -- GOODS ISSUE TO CUSTOMER
                '601', '602', '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                -- STOCK TRANSFER CODES
                , '101', '102', '561', '562', '641', '642', '643', '644', 'Y17'
                -- PRODUCTION
                , '909', '910', '911'
                )
             OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
            )

        AND MD.POST_DT BETWEEN CAST('2015-04-01' AS DATE) AND CURRENT_DATE-1
        --AND MD.POST_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
            --AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

        -- POST CURRENT, COUNT OTHER
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = '07'
            )
        AND MDI.FACILITY_ID IN (
                SELECT
                    FACILITY_ID
                FROM GDYR_BI_VWS.NAT_FACILITY_EN_CURR
                WHERE
                    SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND DISTR_CHAN_CD = '81'
            )

    GROUP BY
        DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID
        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID
        , MDI.BASE_UOM_CD
        --, SUM(MDI.ITM_QTY) AS ITM_QTY
        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , SPCL_STK_TYP_CD
        , MVMNT_ICD
        , RCPT_ICD
        , CNSMPT_POST_ICD

    UNION ALL

    -- (OFFICIAL) POST MONTH <> (WALL CLOCK) ACCOUNTING MONTH
    -- ADDS QUANTITY TO REPORT MONTH TO ACCOUNT FOR WALL CLOCK VS. OFFICIAL TIMING ISSUES

    SELECT
        CAST('CCPO' AS VARCHAR(25)) AS DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID

        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID

        , MDI.BASE_UOM_CD
        , SUM(MDI.ITM_QTY) AS ITM_QTY

        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , COALESCE(MDI.SPCL_STK_TYP_CD, '') AS SPCL_STK_TYP_CD
        , COALESCE(MDI.MVMNT_ICD, '') AS MVMNT_ICD
        , COALESCE(MDI.RCPT_ICD, '') AS RCPT_ICD
        , COALESCE(MDI.CNSMPT_POST_ICD, '') AS CNSMPT_POST_ICD

    FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI

        INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
            ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
            AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID

        INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
            ON PD_CAL.DAY_DATE = MD.POST_DT

        INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
            ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

    WHERE
        MDI.CO_CD IN ('N101', 'N102', 'N266')

        -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
        AND NOT (
             MDI.MVMNT_TYP_CD IN (
                -- GOODS ISSUE TO CUSTOMER
                '601', '602', '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                -- STOCK TRANSFER CODES
                , '101', '102', '561', '562', '641', '642', '643', '644', 'Y17'
                -- PRODUCTION
                , '909', '910', '911'
                )
             OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
            )

        AND MD.ACCTNG_DOC_CREATE_DT BETWEEN CAST('2015-04-01' AS DATE) AND CURRENT_DATE
        --AND MD.ACCTNG_DOC_CREATE_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
            --AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

        -- POST CURRENT, COUNT OTHER
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = '07'
            )
        AND MDI.FACILITY_ID IN (
                SELECT
                    FACILITY_ID
                FROM GDYR_BI_VWS.NAT_FACILITY_EN_CURR
                WHERE
                    SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND DISTR_CHAN_CD = '81'
            )

    GROUP BY
        DOC_TYPE
        , PD_CAL.DAY_DATE
        , MDI.MATL_ID
        , MDI.FACILITY_ID
        , MDI.CO_CD
        , MDI.VEND_ID
        , MDI.CUST_ID
        , MDI.BASE_UOM_CD
        --, SUM(MDI.ITM_QTY) AS ITM_QTY
        , MD.TRANS_TYP_CD
        , MD.ACCTNG_DOC_TYP_CD
        , MDI.DEBIT_CREDIT_IND
        , MDI.MVMNT_TYP_CD
        , SPCL_STK_TYP_CD
        , MVMNT_ICD
        , RCPT_ICD
        , CNSMPT_POST_ICD

    ) MM

    LEFT OUTER JOIN GDYR_VWS.MVMNT_TYP_DESC MTD
        ON MTD.MVMNT_TYP_CD = MM.MVMNT_TYP_CD
        AND MTD.SPCL_STK_TYP_CD = MM.SPCL_STK_TYP_CD
        AND MTD.MVMNT_ICD = MM.MVMNT_ICD
        AND MTD.RCPT_ICD = MM.RCPT_ICD
        AND MTD.CNSMPT_POST_ICD = MM.CNSMPT_POST_ICD
        AND MTD.ORIG_SYS_ID = 2
        AND MTD.LANG_ID = 'E'
        AND MTD.EXP_DT = CAST('5555-12-31' AS DATE)

    LEFT OUTER JOIN GDYR_BI_VWS.VENDOR_EN_CURR V
        ON V.VEND_ID = MM.VEND_ID
        AND V.ORIG_SYS_ID =2

    LEFT OUTER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = MM.CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = MM.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = MM.FACILITY_ID

