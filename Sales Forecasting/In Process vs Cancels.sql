﻿SELECT
    Q.ORDER_DT
    , Q.ORDER_CAT_ID
    , Q.REJ_REAS_ID
    , SUM(Q.ORDER_QTY) AS ORDER_QTY
    , SUM(Q.IN_PROC_QTY) AS IN_PROC_QTY
    , SUM(Q.AGID_QTY) AS AGID_QTY

FROM (

SELECT
    O.ORDER_FISCAL_YR
    , O.ORDER_ID
    , O.ORDER_LINE_NBR
    , O.ORDER_DT
    , O.REJ_REAS_ID
    , O.ORDER_CAT_ID
    , O.ORDER_QTY
    , ZEROIFNULL(SUM(CASE WHEN DD.ACTL_GOODS_ISS_DT IS NULL THEN DIP.QTY_TO_SHIP ELSE 0 END)) AS IN_PROC_QTY
    , ZEROIFNULL(SUM(CASE WHEN DD.ACTL_GOODS_ISS_DT IS NOT NULL THEN DD.DELIV_QTY  ELSE 0 END)) AS AGID_QTY

FROM (

SELECT
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , OD.ORDER_DT
    , OD.ORDER_CAT_ID
    , OD.REJ_REAS_ID
    , SUM(OD.ORDER_QTY) AS ORDER_QTY

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_Dt
        AND OD.ORDER_DT = CAL.DAY_DATE
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.REJ_REAS_ID > ''

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID
        AND M.PBU_NBR = '01'

WHERE
    CAL.DAY_DATE BETWEEN DATE '2015-03-01' AND CURRENT_DATE-1

GROUP BY
    OD.ORDER_FISCAL_YR
    , OD.ORDER_ID
    , OD.ORDER_LINE_NBR
    , OD.ORDER_DT
    , OD.ORDER_CAT_ID
    , OD.REJ_REAS_ID

    ) O

    LEFT OUTER JOIN NA_VWS.DELIV_DTL DD
        ON DD.ORDER_FISCAL_YR = O.ORDER_FISCAL_YR
        AND DD.ORDER_ID = O.ORDER_ID
        AND DD.ORDER_LINE_NBR = O.ORDER_LINE_NBR
        AND O.ORDER_DT BETWEEN DD.EFF_DT AND DD.EXP_DT
    
    LEFT OUTER JOIN GDYR_VWS.DELIV_IN_PROC DIP
        ON DIP.DELIV_FISCAL_YR = DD.FISCAL_YR
        AND DIP.DELIV_ID = DD.DELIV_ID
        AND DIP.DELIV_LINE_NBR = DD.DELIV_LINE_NBR
        AND O.ORDER_DT BETWEEN DIP.EFF_DT AND DIP.EXP_DT
        AND DIP.ORIG_SYS_ID = 2
        AND DIP.INTRA_CMPNY_FLG = 'N'

GROUP BY
    O.ORDER_FISCAL_YR
    , O.ORDER_ID
    , O.ORDER_LINE_NBR
    , O.ORDER_DT
    , O.REJ_REAS_ID
    , O.ORDER_CAT_ID
    , O.ORDER_QTY

    ) Q

GROUP BY
    Q.ORDER_DT
    , Q.ORDER_CAT_ID
    , Q.REJ_REAS_ID