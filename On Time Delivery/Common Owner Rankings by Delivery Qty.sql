SELECT
    Q.ADJ_OWN_CUST_RNK
    , CASE
        WHEN Q.ADJ_OWN_CUST_RNK = 101
            THEN 'OTHER'
        ELSE Q.COMMON_OWNER_CD
        END AS COMMON_OWNER_CODE
    , CASE
        WHEN Q.ADJ_OWN_CUST_RNK = 101
            THEN 'OTHER'
        ELSE Q.COMMON_OWNER_DESC
        END AS COMMON_OWNER_DESCR
    , Q.OE_REPL_IND
    , Q.EXPORT_IND
    , Q.PBU_NBR
    , Q.PBU_NAME
    , Q.EXT_MATL_GRP_ID
    , Q.QTY_UOM
    , SUM(Q.CO_DELIV_QTY) AS DELIV_QTY

FROM (

    SELECT
        D.COMMON_OWNER_CD
        , D.COMMON_OWNER_DESC
        , D.OE_REPL_IND
        , D.EXPORT_IND
        , D.PBU_NBR
        , D.PBU_NAME
        , D.EXT_MATL_GRP_ID
        , D.QTY_UOM
        , D.CO_DELIV_QTY
        , ROW_NUMBER() OVER (PARTITION BY D.PBU_NBR, D.OE_REPL_IND, D.EXT_MATL_GRP_ID, D.QTY_UOM ORDER BY D.CO_DELIV_QTY DESC) AS OWN_CUST_RNK
        , CASE
            WHEN OWN_CUST_RNK > 100
                THEN 101
            ELSE OWN_CUST_RNK
            END AS ADJ_OWN_CUST_RNK

    FROM (

        SELECT
            CASE
                WHEN EXPORT_IND = 'D'
                    THEN CUST.OWN_CUST_ID
                ELSE 'EXPORT'
                END AS COMMON_OWNER_CD
            , CASE
                WHEN EXPORT_IND = 'D'
                    THEN CUST.OWN_CUST_NAME
                ELSE 'EXPORT'
                END AS COMMON_OWNER_DESC
            , CASE WHEN CUST.TIRE_CUST_TYP_CD = 'NA' THEN 'REPL' ELSE CUST.TIRE_CUST_TYP_CD END AS OE_REPL_IND
            , CASE WHEN CUST.SALES_ORG_CD IN ('N303', 'N313', 'N323') THEN 'X' ELSE 'D' END AS EXPORT_IND
            , MATL.PBU_NBR
            , MATL.PBU_NAME
            , MATL.EXT_MATL_GRP_ID
            , DDC.QTY_UNIT_MEAS_ID AS QTY_UOM
            , SUM(DDC.DELIV_QTY) AS CO_DELIV_QTY

        FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

            INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT
                AND CAL.DAY_DATE BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE) AND CURRENT_DATE-1

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = DDC.MATL_ID
                AND MATL.PBU_NBR IN ('01', '03')

            INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
                ON FAC.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
                AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                AND FAC.DISTR_CHAN_CD = '81'

            INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
                ON CUST.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID
                AND CUST.CUST_GRP_ID <> '3R'

        WHERE
            DDC.GOODS_ISS_IND = 'Y'
            AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
            AND DDC.ACTL_GOODS_ISS_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE) AND CURRENT_DATE-1
            AND DDC.DELIV_CAT_ID = 'J'
            AND DDC.DELIV_QTY > 0
            AND DDC.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
            AND DDC.DISTR_CHAN_CD <> '81'

        GROUP BY
            COMMON_OWNER_CD
            , COMMON_OWNER_DESC
            , OE_REPL_IND
            , EXPORT_IND
            , MATL.PBU_NBR
            , MATL.PBU_NAME
            , MATL.EXT_MATL_GRP_ID
            , DDC.QTY_UNIT_MEAS_ID

        ) D

    ) Q

GROUP BY
    Q.ADJ_OWN_CUST_RNK
    , COMMON_OWNER_CODE
    , COMMON_OWNER_DESCR
    , Q.OE_REPL_IND
    , Q.EXPORT_IND
    , Q.PBU_NBR
    , Q.PBU_NAME
    , Q.EXT_MATL_GRP_ID
    , Q.QTY_UOM

ORDER BY
    Q.PBU_NBR
    , Q.EXT_MATL_GRP_ID
    , Q.OE_REPL_IND
    , Q.ADJ_OWN_CUST_RNK
