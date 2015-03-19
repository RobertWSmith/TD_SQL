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
    , MM.RPT_MTH_DT
    , MM.MATL_ID
    , MM.FACILITY_ID

    , MM.VEND_ID
    , MM.CUST_ID

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

FROM (

    SELECT
        CAST('' AS VARCHAR(25)) DOC_TYPE
        , PD_CAL.MONTH_DT AS RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID

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

        --INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
            --ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

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

        --AND MD.POST_DT BETWEEN CAST('2015-01-01' AS DATE) AND CURRENT_DATE
        AND MD.POST_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
            AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = CAST(#prompt('P_PBU', 'text')# AS CHAR(2))
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
        , RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID
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
        , PD_CAL.MONTH_DT AS RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID

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

        --AND MD.POST_DT BETWEEN CAST('2015-01-01' AS DATE) AND CURRENT_DATE
        AND MD.POST_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
            AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

        -- POST CURRENT, COUNT OTHER
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = CAST(#prompt('P_PBU', 'text')# AS CHAR(2))
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
        , RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID
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
        , PD_CAL.MONTH_DT AS RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID

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

        --AND MD.ACCTNG_DOC_CREATE_DT BETWEEN CAST('2015-01-01' AS DATE) AND CURRENT_DATE
        AND MD.ACCTNG_DOC_CREATE_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
            AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

        -- POST CURRENT, COUNT OTHER
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT

        AND MDI.MATL_ID IN (
                SELECT
                    MATL_ID
                FROM GDYR_BI_VWS.NAT_MATL_CURR
                WHERE
                    MATL_TYPE_ID = 'PCTL'
                    AND EXT_MATL_GRP_ID = 'TIRE'
                    AND PBU_NBR = CAST(#prompt('P_PBU', 'text')# AS CHAR(2))
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
        , RPT_MTH_DT
        , MDI.MATL_ID
        , MDI.FACILITY_ID
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
