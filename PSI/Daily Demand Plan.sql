﻿SELECT
    SP.PERD_BEGIN_MTH_DT
    , PF.POSTED_DT
    , SP.MATL_ID
    , SP.SALES_ORG_CD
    , SP.DISTR_CHAN_CD
    , SP.CUST_GRP_ID
    , CAST(SUBSTR(SP.DP_LAG_DESC, 5, 1) AS CHAR(1)) AS LAG_DESCR
    , SP.SLS_UOM_CD
    , SUM(CASE
        WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
            THEN ROUND(ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) / CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(15,3)))
        ELSE ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) / CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(15,3))
        END) AS SLS_PLN_QTY

FROM NA_BI_VWS.CUST_SLS_PLN_SNAP SP

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = SP.PERD_BEGIN_MTH_DT

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR PF
        ON PF.MEAS_DT = SP.PERD_BEGIN_MTH_DT
        AND PF.PERDY_ID = 'M'
        AND PF.FNL_PERDY_ID = 'D'
        AND PF.SBU_ID = 2
        AND PF.EXP_DT = DATE '5555-12-31'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
        ON MATL.MATL_ID = SP.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03')
        AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')
        AND MATL.MATL_STA_ID <> 'DN'
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

WHERE
    SP.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
    AND SP.DISTR_CHAN_CD <> '81'
    AND SP.PERD_BEGIN_MTH_DT BETWEEN CURRENT_DATE AND ADD_MONTHS(CURRENT_DATE, 7) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 7))
    AND SP.DP_LAG_DESC IN ('LAG 0', 'LAG 2')
    AND SP.OFFCL_SOP_SLS_PLN_QTY <> 0

GROUP BY
    SP.PERD_BEGIN_MTH_DT
    , PF.POSTED_DT
    , SP.MATL_ID
    , SP.SALES_ORG_CD
    , SP.DISTR_CHAN_CD
    , SP.CUST_GRP_ID
    , LAG_DESCR
    , SP.SLS_UOM_CD

UNION ALL

SELECT
    SP.PERD_BEGIN_MTH_DT
    , PF.POSTED_DT
    , SP.MATL_ID
    , SP.SALES_ORG_CD
    , SP.DISTR_CHAN_CD
    , SP.CUST_GRP_ID
    , CAST(SP.LAG_DESC AS CHAR(1)) AS LAG_DESCR
    , SP.SLS_UOM_CD
    , SUM(CASE
        WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
            THEN ROUND(ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) / CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(15,3)))
        ELSE ZEROIFNULL(SP.OFFCL_SOP_SLS_PLN_QTY) / CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(15,3))
        END) AS SLS_PLN_QTY

FROM NA_BI_VWS.CUST_SLS_PLN_SNAP SP

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = SP.PERD_BEGIN_MTH_DT

    INNER JOIN GDYR_VWS.DMAN_GRP_PRD_FCTR PF
        ON PF.MEAS_DT = SP.PERD_BEGIN_MTH_DT
        AND PF.PERDY_ID = 'M'
        AND PF.FNL_PERDY_ID = 'D'
        AND PF.SBU_ID = 2
        AND PF.EXP_DT = DATE '5555-12-31'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
        ON MATL.MATL_ID = SP.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03')
        AND MATL.MATL_TYPE_ID IN ('ACCT', 'PCTL')
        AND MATL.MATL_STA_ID <> 'DN'
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

WHERE
    SP.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
    AND SP.DISTR_CHAN_CD <> '81'
    AND SP.PERD_BEGIN_MTH_DT BETWEEN ADD_MONTHS(CURRENT_DATE, 3) - (EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 3))-1) AND CURRENT_DATE-1
    AND SP.LAG_DESC IN ('0', '2')
    AND SP.OFFCL_SOP_SLS_PLN_QTY <> 0

GROUP BY
    SP.PERD_BEGIN_MTH_DT
    , PF.POSTED_DT
    , SP.MATL_ID
    , SP.SALES_ORG_CD
    , SP.DISTR_CHAN_CD
    , SP.CUST_GRP_ID
    , LAG_DESCR
    , SP.SLS_UOM_CD

