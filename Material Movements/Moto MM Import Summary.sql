﻿SELECT
    Q.DATA_TYPE
    , CASE
        WHEN Q.DATA_TYPE LIKE 'PC%' THEN 'Production Credits'
        WHEN Q.DATA_TYPE LIKE 'GI%' THEN 'Goods Issue to Customers'
        WHEN Q.DATA_TYPE LIKE 'RT%' THEN 'Reversal - Stock Transfer Receipt'
        WHEN Q.DATA_TYPE LIKE 'TR%' THEN 'Stock Transfer Receipt'
        WHEN Q.DATA_TYPE LIKE 'TO%' THEN 'STO Outbound'
        WHEN Q.DATA_TYPE LIKE 'TI%' THEN 'STO Inbound'
        WHEN Q.DATA_TYPE LIKE 'TC%' THEN 'Reversal - STO'
        WHEN Q.DATA_TYPE LIKE 'CO%' THEN 'Intercompany STO Outbound'
        WHEN Q.DATA_TYPE LIKE 'CC%' THEN 'Reversal - Intercompany STO Outbound'
        WHEN Q.DATA_TYPE LIKE 'RR%' THEN 'Return Receipt'
        WHEN Q.DATA_TYPE LIKE 'IL%' THEN 'Inventory Loss'
        WHEN Q.DATA_TYPE LIKE 'IG%' THEN 'Inventory Gain'
        WHEN Q.DATA_TYPE LIKE 'GC%' THEN 'Goods Issue for Consumption'
        WHEN Q.DATA_TYPE LIKE 'TF%' THEN 'Stock Status Transfer'
        WHEN Q.DATA_TYPE LIKE 'IC%' THEN 'Reversal - Import Receipt'
        WHEN Q.DATA_TYPE LIKE 'IP%' THEN 'Import Receipt'
        WHEN Q.DATA_TYPE LIKE 'SN%' THEN 'Import Shipment Notification'
        WHEN Q.DATA_TYPE LIKE 'SC%' THEN 'Reversal - Import Shipment Notification'
        --WHEN Q.DATA_TYPE LIKE '' THEN ''
        WHEN Q.DATA_TYPE LIKE 'NC%' THEN 'Not Classified'
        ELSE 'Undefined'
        END AS DATA_TYPE_DESC
    , CASE
        WHEN Q.DATA_TYPE LIKE '%CCPO'
            THEN 'Counted Current, Posted Other'
        WHEN q.data_type LIKE '%PCCO'
            THEN 'Posted Current, Counted Other'
        ELSE ''
        END AS TIMING_DESC

    , Q.DAY_DATE

    , Q.CO_CD

    , Q.VEND_ID
    , V.VEND_NM

    , Q.CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME
    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME

    , Q.MATL_ID
    , Q.BATCH_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.MATL_TYPE_ID
    , M.MATL_STA_ID
    , M.EXT_MATL_GRP_ID
    , M.STK_CLASS_ID

    , Q.FACILITY_ID
    , Q.STOR_LOC_ID
    , F.FACILITY_NAME

    , Q.BASE_UOM_CD
    , SUM(Q.ITM_QTY) AS ITM_QTY

FROM (

-- NON-ASN IMPORTS

SELECT
    CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
    , CAST(CASE WHEN MDI.MVMNT_TYP_CD IN ('102', '562') THEN 'IC' ELSE 'IP' END AS VARCHAR(25)) AS DATA_TYPE

    , PD_CAL.DAY_DATE

    , MDI.CO_CD

    , MDI.VEND_ID
    , MDI.CUST_ID

    , MDI.MATL_ID
    , MDI.BATCH_ID

    , MDI.FACILITY_ID
    , MDI.STOR_LOC_ID

    , MDI.BASE_UOM_CD
    , SUM(MDI.ITM_QTY) AS ITM_QTY

FROM GDYR_BI_VWS.NAT_MATL_DOC_ITM_CURR MDI

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = MDI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = MDI.FACILITY_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_DOC_CURR MD
        ON MD.MATL_DOC_YR = MDI.MATL_DOC_YR
        AND MD.MATL_DOC_ID = MDI.MATL_DOC_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL PD_CAL
        ON PD_CAL.DAY_DATE = MD.POST_DT

    INNER JOIN GDYR_BI_VWS.GDYR_CAL AD_CAL
        ON AD_CAL.DAY_DATE = MD.ACCTNG_DOC_CREATE_DT

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = MDI.PRCH_DOC_ID
        AND PDI.PRCH_DOC_ITM_ID = MDI.PRCH_DOC_ITM_ID
        AND PDI.ORIG_SYS_ID = 2
        AND PDI.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_VWS.PRCH_DOC PD
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
        AND PD.ORIG_SYS_ID = 2
        AND PD.EXP_DT = CAST('5555-12-31' AS DATE)

WHERE
    MDI.CO_CD IN ('N101', 'N102', 'N266')
    AND MDI.MVMNT_TYP_CD IN ('101', '102', '561', '562', 'Y17')

    AND (PDI.CNFRM_CNTRL_ID IS NULL OR PDI.CNFRM_CNTRL_ID NOT IN ('Z004', 'Z005'))

    AND PD.PRCH_CTGY_CD = 'F'
    AND PD.PRCH_TYPE_CD = 'NB'

    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
    AND F.DISTR_CHAN_CD = '81'

    AND M.PBU_NBR = '07'
    AND MD.POST_DT BETWEEN DATE '2015-04-01' AND CURRENT_DATE-1

GROUP BY
    RPT_TYPE
    , DATA_TYPE
    , PD_CAL.DAY_DATE
    , MDI.CO_CD
    , MDI.VEND_ID
    , MDI.CUST_ID
    , MDI.MATL_ID
    , MDI.BATCH_ID
    , MDI.FACILITY_ID
    , MDI.STOR_LOC_ID
    , MDI.BASE_UOM_CD


UNION ALL

-- ASN IMPORT BASE

SELECT
    CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
    , CAST('SN' AS VARCHAR(25)) AS DATA_TYPE

    , CAL.DAY_DATE

    , PDI.CO_CD

    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID

    , DDI.MATL_ID
    , DDI.BATCH_NBR

    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD

    , DDI.BASE_UOM_CD
    , SUM(DDI.ACTL_DELIV_QTY) AS DELIV_QTY

FROM GDYR_VWS.DELIV_DOC_ITM DDI

    INNER JOIN GDYR_VWS.DELIV_DOC DD
        ON DD.FISCAL_YR = DDI.FISCAL_YR
        AND DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
        AND DD.ORIG_SYS_ID = 2
        AND DD.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = DDI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDI.FACILITY_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DD.ORIG_DOC_DT

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = DDI.SLS_DOC_ID
        AND PDI.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
        AND PDI.ORIG_SYS_ID = 2
        AND PDI.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_VWS.PRCH_DOC PD
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
        AND PD.ORIG_SYS_ID = 2
        AND PD.EXP_DT = CAST('5555-12-31' AS DATE)

WHERE
    DDI.ORIG_SYS_ID = 2
    AND DDI.EXP_DT = CAST('5555-12-31' AS DATE)

    AND DD.SD_DOC_CTGY_CD = '7'
    AND DD.DELIV_TYP_CD = 'EL'

    AND DDI.SD_DOC_CTGY_CD = 'V'

    AND PD.PRCH_CTGY_CD = 'F'
    AND PD.PRCH_TYPE_CD = 'NB'

    AND PDI.CO_CD IN ('N101', 'N102', 'N266')
    AND PDI.CNFRM_CNTRL_ID IN ('Z004', 'Z005')

    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
    AND F.DISTR_CHAN_CD = '81'

    AND M.PBU_NBR = '07'
    AND DD.ORIG_DOC_DT BETWEEN DATE '2015-04-01' AND CURRENT_DATE-1

GROUP BY
    RPT_TYPE
    , DATA_TYPE
    , CAL.DAY_DATE
    , PDI.CO_CD
    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID
    , DDI.MATL_ID
    , DDI.BATCH_NBR
    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD
    , DDI.BASE_UOM_CD


UNION ALL

-- CURRENTLY CANCELLED ASN IMPORTS BY CREATE DATE

SELECT
    CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
    , CAST('SN' AS VARCHAR(25)) AS DATA_TYPE

    , CAL.DAY_DATE
    , PDI.CO_CD

    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID

    , DDI.MATL_ID
    , DDI.BATCH_NBR

    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD

    , DDI.BASE_UOM_CD
    , SUM(DDI.ACTL_DELIV_QTY) AS DELIV_QTY

FROM GDYR_VWS.DELIV_DOC_ITM DDI

    INNER JOIN GDYR_VWS.DELIV_DOC DD
        ON DD.FISCAL_YR = DDI.FISCAL_YR
        AND DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
        AND DD.ORIG_DOC_DT BETWEEN DD.EFF_DT AND DD.EXP_DT
        AND DD.ORIG_SYS_ID = 2

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = DDI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDI.FACILITY_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = DDI.SLS_DOC_ID
        AND PDI.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
        AND PDI.ORIG_SYS_ID = 2
        AND PDI.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_VWS.PRCH_DOC PD
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
        AND PD.ORIG_SYS_ID = 2
        AND PD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND PD.CO_CD IN ('N101', 'N102', 'N266')

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DD.ORIG_DOC_DT

WHERE
    DDI.ORIG_SYS_ID = 2
    AND DD.ORIG_DOC_DT BETWEEN DDI.EFF_DT AND DDI.EXP_DT

    AND DDI.SD_DOC_CTGY_CD = 'V'

    AND DD.SD_DOC_CTGY_CD = '7'
    AND DD.DELIV_TYP_CD = 'EL'

    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
    AND F.DISTR_CHAN_CD = '81'

    AND PD.PRCH_CTGY_CD = 'F'
    AND PD.PRCH_TYPE_CD = 'NB'

    AND PDI.CO_CD IN ('N101', 'N102', 'N266')
    AND PDI.CNFRM_CNTRL_ID IN ('Z004', 'Z005')

    AND M.PBU_NBR = '07'
    AND DD.ORIG_DOC_DT BETWEEN DATE '2015-04-01' AND CURRENT_DATE-1

    AND (DDI.DELIV_DOC_ID, DDI.DELIV_DOC_ITM_ID) IN (
        SELECT
            CDI.DOC_ID
            , CDI.DOC_ITM_ID
        FROM GDYR_BI_VWS.CHG_DOC_ITM CDI
        WHERE
            CDI.ORIG_SYS_ID = 2
            AND CDI.OBJ_CLS_CD = 'LIEFERUNG'
            AND CDI.SAP_TBL_NM = 'LIPS'
            AND CDI.SAP_COL_NM  = 'KEY'
            AND CDI.CHG_TYP_CD = 'D'
            AND CDI.SRC_CRT_DT BETWEEN DATE '2015-04-01' AND CURRENT_DATE-1
        GROUP BY 1,2
    )

GROUP BY
    RPT_TYPE
    , DATA_TYPE
    , CAL.DAY_DATE
    , PDI.CO_CD
    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID
    , DDI.MATL_ID
    , DDI.BATCH_NBR
    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD
    , DDI.BASE_UOM_CD


UNION ALL

-- CURRENTLY CANCELLED ASN'S BY THEIR CANCEL DATE

SELECT
    CAST('MM' AS VARCHAR(3)) AS RPT_TYPE
    , CAST('SC' AS VARCHAR(25)) AS DOC_TYPE

    , CHG.SRC_CRT_DT AS DEL_DT
    , PDI.CO_CD

    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID

    , DDI.MATL_ID
    , DDI.BATCH_NBR

    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD

    , DDI.BASE_UOM_CD
    , SUM((-1 * DDI.ACTL_DELIV_QTY)) AS ITM_QTY

FROM GDYR_VWS.DELIV_DOC_ITM DDI

    INNER JOIN (
        SELECT
            CDI.DOC_ID
            , CDI.DOC_ITM_ID
            , CDI.SRC_CRT_DT
            , CAST(CDI.SRC_CRT_DT-1 AS DATE) AS EXP_REC_DT
            , CAL.MONTH_DT AS DEL_MTH_DT

        FROM GDYR_BI_VWS.CHG_DOC_ITM CDI

            INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                ON CAL.DAY_DATE = CDI.SRC_CRT_DT

        WHERE
            CDI.ORIG_SYS_ID = 2
            AND CDI.OBJ_CLS_CD = 'LIEFERUNG'
            AND CDI.SAP_TBL_NM = 'LIPS'
            AND CDI.SAP_COL_NM  = 'KEY'
            AND CDI.CHG_TYP_CD = 'D'
            AND CDI.SRC_CRT_DT BETWEEN DATE '2015-04-01' AND CURRENT_DATE-1
            ) CHG
        ON CHG.DOC_ID = DDI.DELIV_DOC_ID
        AND CHG.DOC_ITM_ID = DDI.DELIV_DOC_ITM_ID

    INNER JOIN GDYR_VWS.DELIV_DOC DD
        ON DD.FISCAL_YR = DDI.FISCAL_YR
        AND DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
        AND CHG.EXP_REC_DT BETWEEN DD.EFF_DT AND DD.EXP_DT
        AND DD.ORIG_SYS_ID = 2

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = DDI.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = DDI.FACILITY_ID

    INNER JOIN GDYR_VWS.PRCH_DOC_ITM PDI
        ON PDI.PRCH_DOC_ID = DDI.SLS_DOC_ID
        AND PDI.PRCH_DOC_ITM_ID = DDI.SLS_DOC_ITM_ID
        AND PDI.ORIG_SYS_ID = 2
        AND PDI.EXP_DT = CAST('5555-12-31' AS DATE)

    INNER JOIN GDYR_VWS.PRCH_DOC PD
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
        AND PD.ORIG_SYS_ID = 2
        AND PD.EXP_DT = CAST('5555-12-31' AS DATE)

WHERE
    DDI.ORIG_SYS_ID = 2
    AND CHG.EXP_REC_DT BETWEEN DDI.EFF_DT AND DDI.EXP_DT

    -- DELIV ORIGINATED FROM PURCHASE ORDER
    AND DDI.SD_DOC_CTGY_CD = 'V'

    -- ASN Category / Type of Deliv Doc
    AND DD.SD_DOC_CTGY_CD = '7'
    AND DD.DELIV_TYP_CD = 'EL'

    -- NAT Facilities
    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
    AND F.DISTR_CHAN_CD = '81'

    -- External to Goodyear PO
    AND PD.PRCH_CTGY_CD = 'F'
    AND PD.PRCH_TYPE_CD = 'NB'

    -- NAT Company Code / PO Item Field that controls if ASNs are created
    AND PDI.CO_CD IN ('N101', 'N102', 'N266')
    AND PDI.CNFRM_CNTRL_ID IN ('Z004', 'Z005')

    AND M.PBU_NBR = '07'

GROUP BY
    RPT_TYPE
    , DOC_TYPE
    , DEL_DT
    , PDI.CO_CD
    , DD.VEND_ID
    , DD.SHIP_TO_CUST_ID
    , DDI.MATL_ID
    , DDI.BATCH_NBR
    , DDI.FACILITY_ID
    , DDI.STOR_LOC_CD
    , DDI.BASE_UOM_CD

    ) Q

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = Q.MATL_ID

    LEFT OUTER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = Q.FACILITY_ID

    LEFT OUTER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = Q.CUST_ID

    LEFT OUTER JOIN GDYR_BI_VWS.VENDOR_CURR V
        ON V.VEND_ID = Q.VEND_ID
        AND V.ORIG_SYS_ID = 2

GROUP BY
    Q.DATA_TYPE
    , DATA_TYPE_DESC
    , TIMING_DESC

    , Q.DAY_DATE

    , Q.CO_CD

    , Q.VEND_ID
    , V.VEND_NM

    , Q.CUST_ID
    , C.CUST_NAME
    , C.OWN_CUST_ID
    , C.OWN_CUST_NAME
    , C.SALES_ORG_CD
    , C.SALES_ORG_NAME
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_NAME
    , C.CUST_GRP_ID
    , C.CUST_GRP_NAME

    , Q.MATL_ID
    , Q.BATCH_ID
    , M.DESCR
    , M.PBU_NBR
    , M.PBU_NAME
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NAME
    , M.PROD_LINE_NBR
    , M.PROD_LINE_NAME
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NAME
    , M.MATL_TYPE_ID
    , M.MATL_STA_ID
    , M.EXT_MATL_GRP_ID
    , M.STK_CLASS_ID

    , Q.FACILITY_ID
    , Q.STOR_LOC_ID
    , F.FACILITY_NAME

    , Q.BASE_UOM_CD
