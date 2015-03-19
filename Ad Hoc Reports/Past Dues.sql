﻿-- SCHEDULE LINE TO SCHEDULE LINE JOIN

SELECT
    M.PBU_NBR
    , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY

FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
        ON ODC.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND ODC.ORDER_ID = OOL.ORDER_ID
        AND ODC.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND ODC.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND ODC.ORDER_CAT_ID = 'C'
        AND ODC.RO_PO_TYPE_IND = 'N'
        AND ODC.FRST_RDD < CURRENT_DATE

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = ODC.MATL_ID
        AND M.PBU_NBR = '01'
        AND M.EXT_MATL_GRP_ID = 'TIRE'
        AND M.MATL_TYPE_ID IN ('ACCT', 'PCTL')

GROUP BY
    M.PBU_NBR
;

-- SCHEDULE LINE ONE ONLY FROM ORDER_DETAIL_CURR

SELECT
    M.PBU_NBR
    , SUM(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY

FROM NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL_CURR ODC
        ON ODC.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND ODC.ORDER_ID = OOL.ORDER_ID
        AND ODC.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND ODC.SCHED_LINE_NBR = 1
        AND ODC.ORDER_CAT_ID = 'C'
        AND ODC.RO_PO_TYPE_IND = 'N'
        AND ODC.FRST_RDD < CURRENT_DATE

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = ODC.MATL_ID
        AND M.PBU_NBR = '01'
        AND M.EXT_MATL_GRP_ID = 'TIRE'
        AND M.MATL_TYPE_ID IN ('ACCT', 'PCTL')

GROUP BY
    M.PBU_NBR
;