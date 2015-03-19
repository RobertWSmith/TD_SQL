SELECT
    CAL.DAY_DATE AS "Business Date",
    OPN.ORDER_ID AS "Order ID",
    OPN.ORDER_LINE_NBR AS "Order Line Nbr",
    OPN.INTRA_CMPNY_FLG AS "Intra-Company Flag",
    OPN.CREDIT_HOLD_FLG AS "Credit Hold Flag",
    OPN.SLS_QTY_UNIT_MEAS_ID AS "Qty. UOM",
    SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'C' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS "Open Confirmed Qty",
    SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'U' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS "Unconfirmed Qty",
    SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'B' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS "Back Order Qty",
    SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'W' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS "Wait List Qty",
    SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'D' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS "Deferred Qty"

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN GDYR_VWS.OPEN_ORDER OPN
        ON CAL.DAY_DATE BETWEEN OPN.EFF_DT AND OPN.EXP_DT
        AND OPN.SBU_ID = 2
        AND OPN.ORIG_SYS_ID = 2
        AND OPN.SRC_SYS_ID = 2

WHERE
    CAL.DAY_DATE < CURRENT_DATE

GROUP BY
    CAL.DAY_DATE,
    OPN.ORDER_ID,
    OPN.ORDER_LINE_NBR,
    OPN.INTRA_CMPNY_FLG,
    OPN.CREDIT_HOLD_FLG,
    OPN.SLS_QTY_UNIT_MEAS_ID