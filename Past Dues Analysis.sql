﻿SELECT
    OOL.DAY_DATE
    , OOL.MONTH_DT
    , OOL.MNTH_DESCR
    , OOL.YEAR_SLASH_QTR

    , C.SALES_ORG_CD
    , C.SALES_ORG_CD || ' - ' || C.SALES_ORG_NAME AS SALES_ORG
    , C.DISTR_CHAN_CD
    , C.DISTR_CHAN_CD || ' - ' || C.DISTR_CHAN_NAME AS DISTR_CHAN
    , C.CUST_GRP_ID
    , C.CUST_GRP_ID || ' - ' || C.CUST_GRP_NAME AS CUST_GRP
    --, C.OWN_CUST_ID
    --, C.OWN_CUST_ID || ' - ' || C.OWN_CUST_NAME AS COMMON_OWNER
    --, C.SHIP_TO_CUST_ID
    --, C.SHIP_TO_CUST_ID || ' - ' || C.CUST_NAME AS SHIP_TO_CUSTOMER
    --, OD.CUST_GRP2_CD

    --, OD.MATL_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , M.PBU_NBR
    , M.PBU_NBR || ' - ' || M.PBU_NAME AS PBU
    , M.MKT_AREA_NBR
    , M.MKT_AREA_NBR || ' - ' || M.MKT_AREA_NAME AS MKT_AREA
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NBR || ' - ' || M.MKT_CTGY_MKT_AREA_NAME AS CATEGORY
    --, M.PROD_LINE_NBR
    --, M.PROD_LINE_NBR || ' - ' || M.PROD_LINE_NAME AS PROD_LINE
    --, M.MATL_NO_8 || ' - ' || M.DESCR AS MATL_DESCR
    , CAST(CASE WHEN M.PBU_NBR = '01' THEN M.MKT_CTGY_PROD_GRP_NAME ELSE M.TIERS END AS VARCHAR(50)) AS TIER
    , M.MATL_PRTY
    --, M.MATL_STA_ID
    --, M.HVA_TXT
    --, M.HMC_TXT
    , M.PRTY_SRC_FACL_ID || ' - ' || M.PRTY_SRC_FACL_NM AS SOURCE_FACILITY

    , F.FACILITY_ID || ' - ' || F.FACILITY_NAME AS SHIP_FACILITY

    --, OD.ORDER_DELIV_BLK_CD
    --, OD.DELIV_BLK_CD
    --, OD.DELIV_BLK_IND

    , CAST(CASE WHEN OD.FRST_RDD < OOL.DAY_DATE THEN 'Y' ELSE 'N' END AS CHAR(1)) AS PAST_DUE_IND
    , CAST(MONTHS_BETWEEN(OOL.MONTH_DT, CAST((OD.FRST_RDD - EXTRACT(DAY FROM OD.FRST_RDD) + 1) AS DATE)) AS INTEGER) AS PAST_DUE_MONTHS
    , CASE
        WHEN PAST_DUE_MONTHS <= 0
            THEN '0 Months Past Due'
        WHEN PAST_DUE_MONTHS BETWEEN 1 AND 3
            THEN '1-3 Months Past Due'
        WHEN PAST_DUE_MONTHS BETWEEN 4 AND 6
            THEN '4-6 Months Past Due'
        ELSE '6+ Months Past Due'
        END AS PAST_DUE_CLASSIFICATION

    , OD.QTY_UNIT_MEAS_ID
    , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY
    , SUM(CASE WHEN PAST_DUE_IND = 'Y' THEN OOL.OPEN_CNFRM_QTY ELSE 0 END) AS PAST_DUE_CNFRM_QTY
    , SUM(OOL.UNCNFRM_QTY) + SUM(OOL.BACK_ORDER_QTY) AS UNCNFRM_QTY
    , SUM(OOL.WAIT_LIST_QTY) AS WAIT_LIST_QTY
    , SUM(OOL.OTHR_ORDER_QTY) + SUM(OOL.DEFER_QTY) AS OTHR_ORDER_QTY

FROM (

SELECT
    GC.DAY_DATE
    , GC.MONTH_DT
    , GC.MNTH_DESCR
    , GC.YEAR_SLASH_QTR
    , OOL.*

FROM GDYR_BI_VWS.GDYR_CAL GC

    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN OOL
        ON GC.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT

WHERE
    (GC.CAL_LAST_DAY_MO_IND = 'Y' OR GC.DAY_DATE = CURRENT_DATE-1)
    AND GC.DAY_DATE BETWEEN ADD_MONTHS(CURRENT_DATE-1, -13) AND CURRENT_DATE-1

    ) OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OOL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
        AND OD.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOL.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
        AND (
            C.SALES_ORG_CD IN ('N301', 'N311', 'N302', 'N312', 'N322', 'N336') 
            OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323')AND C.DISTR_CHAN_CD IN ('30', '31', '32'))
            )

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID
        AND M.PBU_NBR IN ('01', '03')
        AND M.MKT_AREA_NBR <> '04'
        AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')
        AND M.EXT_MATL_GRP_ID = 'TIRE'

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OD.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

WHERE
    PAST_DUE_IND = 'Y'

GROUP BY
    OOL.DAY_DATE
    , OOL.MONTH_DT
    , OOL.MNTH_DESCR
    , OOL.YEAR_SLASH_QTR

    , C.SALES_ORG_CD
    , SALES_ORG
    , C.DISTR_CHAN_CD
    , DISTR_CHAN
    , C.CUST_GRP_ID
    , CUST_GRP
    , C.OWN_CUST_ID
    , COMMON_OWNER
    --, C.SHIP_TO_CUST_ID
    --, SHIP_TO_CUSTOMER
    --, OD.CUST_GRP2_CD

    --, OD.MATL_ID
    , OD.PROD_ALLCT_DETERM_PROC_ID
    , M.PBU_NBR
    , PBU
    , M.MKT_AREA_NBR
    , MKT_AREA
    , M.MKT_CTGY_MKT_AREA_NBR
    , CATEGORY
    --, M.PROD_LINE_NBR
    --, PROD_LINE
    --, MATL_DESCR
    , TIER
    , M.MATL_PRTY
    --, M.MATL_STA_ID
    --, M.HVA_TXT
    --, M.HMC_TXT
    , SOURCE_FACILITY

    , SHIP_FACILITY

    --, OD.ORDER_DELIV_BLK_CD
    --, OD.DELIV_BLK_CD
    --, OD.DELIV_BLK_IND

    , PAST_DUE_IND
    , PAST_DUE_MONTHS

    , OD.QTY_UNIT_MEAS_ID

ORDER BY
    OOL.DAY_DATE
    , C.SALES_ORG_CD
    , C.DISTR_CHAN_CD
    , C.CUST_GRP_ID
    , C.OWN_CUST_ID
    , SOURCE_FACILITY
    , SHIP_FACILITY
    , M.PBU_NBR
    , M.MKT_AREA_NBR
    , M.MKT_CTGY_MKT_AREA_NBR
    , M.MATL_PRTY
;
