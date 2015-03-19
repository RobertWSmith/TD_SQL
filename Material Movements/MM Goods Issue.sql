SELECT
    CAST('MM' AS VARCHAR(3)) AS DATA_CTGY
    , CAST('GI' || MM.UNION_TYPE AS VARCHAR(25)) AS DATA_TYPE
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
        CAST('' AS VARCHAR(25)) AS UNION_TYPE
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

        -- GOODS ISSUE TO CUSTOMER MOVEMENT TYPES
        AND MDI.MVMNT_TYP_CD IN (
                        '601', '602'
                        , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                    )

        -- CAST('2015-01-01' AS DATE) AND CURRENT_DATE
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
        UNION_TYPE
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
    -- INVERTS QUANTITY TO ACCOUNT FOR WALL CLOCK VS. OFFICIAL TIMING ISSUES

    SELECT
        CAST('PCCO' AS VARCHAR(25)) AS UNION_TYPE
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

        -- GOODS ISSUE TO CUSTOMER MOVEMENT TYPES
        AND MDI.MVMNT_TYP_CD IN (
                        '601', '602'
                        , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                    )

        -- CAST('2015-01-01' AS DATE) AND CURRENT_DATE
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
        UNION_TYPE
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
        CAST('CCPO' AS VARCHAR(25)) AS UNION_TYPE
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

        -- GOODS ISSUE TO CUSTOMER MOVEMENT TYPES
        AND MDI.MVMNT_TYP_CD IN (
                        '601', '602'
                        , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                    )

        -- CAST('2015-01-01' AS DATE) AND CURRENT_DATE
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
        UNION_TYPE
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
