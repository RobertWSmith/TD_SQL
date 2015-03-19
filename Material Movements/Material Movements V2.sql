SELECT
    CAST('MM' AS VARCHAR(3)) AS QRY_CTGY
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
                -- GOODS RECEIPT MOVEMENTS AT IMPORT FACILITIES INDICATE A INBOUND IMPORT
                -- OTHERWISE THIS MOVEMENT INDICATES
                WHEN FAC.FACILITY_CAT_ID = 'I'
                    THEN 'IR' -- IMPORT SHIPMENT NOTIFICATION - PAPER WAREHOUSE
                ELSE 'TR' -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('641', '642')
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('643', '644')
            THEN 'IP' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
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
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS CHAR(2)) AS QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , PD_CAL.MONTH_DT AS RPT_MTH_DT
    , MDI.BASE_UOM_CD
    , SUM(MDI.ITM_QTY) AS ITM_QTY

FROM GDYR_BI_VWS.NAT_MATL_DOC_CURR MD

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI
        ON MDI.MATL_DOC_YR = MD.MATL_DOC_YR
        AND MDI.MATL_DOC_ID = MD.MATL_DOC_ID
        AND MDI.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = MDI.FACILITY_ID
        AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND FAC.DISTR_CHAN_CD = '81'

WHERE
    MD.POST_DT BETWEEN CAST('2014-01-01' AS DATE) AND CAST('2014-12-31' AS DATE)

    -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
    AND NOT (
        -- ONLY RECEIPTS FOR IMPORT LOCATIONS
         (MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17') AND FAC.FACILITY_CAT_ID <> 'I')
         OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
         OR MDI.MVMNT_TYP_CD IN ('641', '642', '643', '644')
        )
    AND MDI.MATL_ID IN (
            SELECT
                MATL_ID
            FROM GDYR_BI_VWS.NAT_MATL_CURR
            WHERE
                MATL_TYPE_ID = 'PCTL'
                AND PBU_NBR = '01'
        )

GROUP BY
    QRY_CTGY
    , QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , RPT_MTH_DT
    , MDI.BASE_UOM_CD

UNION ALL

SELECT
    CAST('MP' AS VARCHAR(3)) AS QRY_CTGY
    , CAST(CASE
        WHEN MDI.MVMNT_TYP_CD IN ('909', '910', '911')
            THEN 'PC' --PRODUCTION CREDITS
        WHEN MDI.MVMNT_TYP_CD IN (
                    '601', '602'
                    , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                )
            THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
        WHEN MDI.MVMNT_TYP_CD IN (
                    '101', '102'
                    , '561', '562'
                    , 'Y17'
                )
            THEN (CASE
                -- GOODS RECEIPT MOVEMENTS AT IMPORT FACILITIES INDICATE A INBOUND IMPORT
                -- OTHERWISE THIS MOVEMENT INDICATES
                WHEN FAC.FACILITY_CAT_ID = 'I'
                    THEN 'IR' -- IMPORT SHIPMENT NOTIFICATION - PAPER WAREHOUSE
                ELSE 'TR' -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('641', '642')
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('643', '644')
            THEN 'IP' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
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
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS CHAR(2)) AS QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , PD_CAL.MONTH_DT AS RPT_MTH_DT
    , MDI.BASE_UOM_CD
    , (-1 * SUM(MDI.ITM_QTY)) AS ITM_QTY

FROM GDYR_BI_VWS.NAT_MATL_DOC_CURR MD

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
        ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI
        ON MDI.MATL_DOC_YR = MD.MATL_DOC_YR
        AND MDI.MATL_DOC_ID = MD.MATL_DOC_ID
        AND MDI.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = MDI.FACILITY_ID
        AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND FAC.DISTR_CHAN_CD = '81'

WHERE
    (
        -- POST DATE IN RANGE, ACCOUNTING DOC NOT IN SAME MONTH AS POST DATE
        MD.POST_DT BETWEEN CAST('2014-01-01' AS DATE) AND CAST('2014-12-31' AS DATE)
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT
    )
    -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
    AND NOT (
        -- ONLY RECEIPTS FOR IMPORT LOCATIONS
         (MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17') AND FAC.FACILITY_CAT_ID <> 'I')
         OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
         OR MDI.MVMNT_TYP_CD IN ('641', '642', '643', '644')
        )
    AND MDI.MATL_ID IN (
            SELECT
                MATL_ID
            FROM GDYR_BI_VWS.NAT_MATL_CURR
            WHERE
                MATL_TYPE_ID = 'PCTL'
                AND PBU_NBR = '01'
        )

GROUP BY
    QRY_CTGY
    , QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , RPT_MTH_DT
    , MDI.BASE_UOM_CD

UNION ALL

SELECT
    CAST('MA' AS VARCHAR(3)) AS QRY_CTGY
    , CAST(CASE
        WHEN MDI.MVMNT_TYP_CD IN ('909', '910', '911')
            THEN 'PC' --PRODUCTION CREDITS
        WHEN MDI.MVMNT_TYP_CD IN (
                    '601', '602'
                    , '983', '984', '985', '986', '987', '988', '989', '990', '991', '992', '993', '994'
                )
            THEN 'GI' -- GODDS ISSUE TO CUSTOMERS
        WHEN MDI.MVMNT_TYP_CD IN (
                    '101', '102'
                    , '561', '562'
                    , 'Y17'
                )
            THEN (CASE
                -- GOODS RECEIPT MOVEMENTS AT IMPORT FACILITIES INDICATE A INBOUND IMPORT
                -- OTHERWISE THIS MOVEMENT INDICATES
                WHEN FAC.FACILITY_CAT_ID = 'I'
                    THEN 'IR' -- IMPORT SHIPMENT NOTIFICATION - PAPER WAREHOUSE
                ELSE 'TR' -- STOCK TRANSFER RECEIPT TO TOTAL INVENTORY
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('641', '642')
            THEN (CASE
                WHEN MDI.DEBIT_CREDIT_IND = 'C'
                    THEN 'TO' -- STOCK TRANSFER OUTBOUND POST
                ELSE 'TI' -- STOCK TRANSFER INBOUND POST
                END)
        WHEN MDI.MVMNT_TYP_CD IN ('643', '644')
            THEN 'IP' -- INTERCOMPANY STOCK TRANSFER OUTBOUND POST
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
            THEN 'TF' -- STOCK STATUS TRANSFER (BLOCKED TO UNBLOCKED, ETC.)
        ELSE 'NC' -- NOT CLASSIFIED
        END AS CHAR(2)) AS QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , AD_CAL.MONTH_DT AS RPT_MTH_DT
    , MDI.BASE_UOM_CD
    , SUM(MDI.ITM_QTY) AS ITM_QTY

FROM GDYR_BI_VWS.NAT_MATL_DOC_CURR MD

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
        ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI
        ON MDI.MATL_DOC_YR = MD.MATL_DOC_YR
        AND MDI.MATL_DOC_ID = MD.MATL_DOC_ID
        AND MDI.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = MDI.FACILITY_ID
        AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND FAC.DISTR_CHAN_CD = '81'

WHERE
    (
        -- ACCOUNTING DOC IN RANGE, POST DATE NOT IN SAME MONTH AS ACCOUNTING DOC
        MD.ACCTNG_DOC_CREATE_DT BETWEEN CAST('2014-01-01' AS DATE) AND CAST('2014-12-31' AS DATE)
        AND PD_CAL.MONTH_DT <> AD_CAL.MONTH_DT
    )
    -- EXCLUDE THE FOLLOWING MOVEMENT TYPES
    AND NOT (
        -- ONLY RECEIPTS FOR IMPORT LOCATIONS
         (MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17') AND FAC.FACILITY_CAT_ID <> 'I')
         OR MDI.MVMNT_TYP_CD LIKE ANY ('2%', '3%', '4%')
         OR MDI.MVMNT_TYP_CD IN ('641', '642', '643', '644')
        )
    AND MDI.MATL_ID IN (
            SELECT
                MATL_ID
            FROM GDYR_BI_VWS.NAT_MATL_CURR
            WHERE
                MATL_TYPE_ID = 'PCTL'
                AND PBU_NBR = '01'
        )

GROUP BY
    QRY_CTGY
    , QRY_TYPE

    , MDI.MATL_ID
    , MDI.FACILITY_ID

    , MDI.CUST_ID
    , MDI.VEND_ID

    , RPT_MTH_DT
    , MDI.BASE_UOM_CD
