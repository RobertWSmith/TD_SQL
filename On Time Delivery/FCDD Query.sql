﻿SELECT
    FCDD.ORDER_FISCAL_YR
    , FCDD.ORDER_ID
    , FCDD.ORDER_LINE_NBR
    , FCDD.SEQ_ID
    , FCDD.FRST_PROM_MATL_AVL_DT AS FCDD_FMAD
    , FCDD.FRST_PROM_PLN_GOODS_ISS_DT AS FCDD_FPGI
    , FCDD.FRST_PROM_DELIV_DT AS FCDD
    , FCDD.CNFRM_QTY AS FCDD_QTY

FROM NA_VWS.ORD_FPDD FCDD

    INNER JOIN (
            SELECT
                ORDER_FISCAL_YR
                , ORDER_ID
                , ORDER_LINE_NBR
                , SEQ_ID
            FROM NA_VWS.ORD_FPDD
            WHERE
                EXP_DT = DATE '5555-12-31'
                AND SRC_CRT_DT >= ADD_MONTHS(CURRENT_DATE, -2)
            QUALIFY
                ROW_NUMBER() OVER (PARTITION BY ORDER_FISCAL_YR, ORDER_ID, ORDER_LINE_NBR ORDER BY FRST_PROM_DELIV_DT DESC) = 1
        ) LIM
    ON LIM.ORDER_FISCAL_YR = FCDD.ORDER_FISCAL_YR
    AND LIM.ORDER_ID = FCDD.ORDER_ID
    AND LIM.ORDER_LINE_NBR = FCDD.ORDER_LINE_NBR
    AND LIM.SEQ_ID = FCDD.SEQ_ID

WHERE
    FCDD.EXP_DT = DATE '5555-12-31'

