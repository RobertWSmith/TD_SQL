SELECT
    PDI.MATL_ID
    , M.EXT_MATL_GRP_ID
    , M.STK_CLASS_ID
    , PDI.FACILITY_ID AS DEST_FACILITY_ID
    , PD.FACILITY_ID AS SOURCE_FACILITY_ID
    , DD.GOODS_RCPT_POST_DT
    , CASE
        WHEN DD.OUTBOUND_DELIV_IND = 'Y'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS OUTBOUND_QTY
    , CASE
        WHEN DD.GOODS_RCPT_POST_DT <= (PSL.REQ_DELIV_DT + PDI.GOODS_RCPT_DY_QTY) AND DD.OUTBOUND_DELIV_IND = 'Y'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS STO_ONTIME_QTY
    , CASE
        WHEN DD.GOODS_RCPT_POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY) AND DD.OUTBOUND_DELIV_IND = 'Y'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS GOODS_ISSUE_ONTIME_DELIV_QTY
    , CASE
        WHEN DD.ACTL_GOODS_ISS_DT <= DD.PLN_GOODS_MVT_DT AND DD.OUTBOUND_DELIV_IND = 'Y'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS GOODS_ISSUE_ONTIME_QTY
    , CASE
        WHEN DD.ACTL_GOODS_ISS_DT > DD.PLN_GOODS_MVT_DT AND DD.OUTBOUND_DELIV_IND = 'Y'
            THEN DD.ACTL_GOODS_ISS_DT - DD.PLN_GOODS_MVT_DT
        ELSE NULL
        END AS GOODS_ISSUE_DAYS_LATE
    , CASE
        WHEN DD.OUTBOUND_DELIV_IND = 'N'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS INBOUND_QTY
    , CASE
        WHEN DD.GOODS_RCPT_POST_DT <= (DD.DELIV_DT + PDI.GOODS_RCPT_DY_QTY) AND DD.OUTBOUND_DELIV_IND = 'N'
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS GOODS_RECEIPT_ONTIME_QTY
    , CASE
        WHEN DD.OUTBOUND_DELIV_IND = 'Y' AND PDI.ORIG_PO_QTY > PDI.PO_QTY
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS OUTBOUND_PARTIAL_QTY
    , CASE
        WHEN DD.OUTBOUND_DELIV_IND = 'Y' AND PDI.ORIG_PO_QTY <= PDI.PO_QTY
            THEN DD.RPT_DELIV_QTY
        ELSE 0
        END AS OUTBOUND_COMPLETE_QTY

FROM GDYR_BI_VWS.PRCH_DOC_CURR PD

    INNER JOIN GDYR_BI_VWS.PRCH_DOC_ITM_CURR PDI
        ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
            AND PD.ORIG_SYS_ID = PDI.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
        ON PDI.PRCH_DOC_ID = PSL.PRCH_DOC_ID
            AND PDI.PRCH_DOC_ITM_ID = PSL.PRCH_DOC_ITM_ID
            AND PDI.ORIG_SYS_ID = PSL.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN NA_VWS.DELIV_DTL DD
        ON PDI.PRCH_DOC_ID = DD.ORDER_ID
            AND PDI.PRCH_DOC_ITM_ID = DD.ORDER_LINE_NBR
            AND PDI.ORIG_SYS_ID = DD.ORIG_SYS_ID
            AND DD.EXP_DT = CAST('5555-12-31' AS DATE)
            AND DD.ORIG_SYS_ID = 2

WHERE
    PD.ORIG_SYS_ID = 2
    AND PD.PRCH_TYPE_CD IN ('ZB', 'ZS', 'IB', 'CS', 'CB', 'UB')
    AND DD.GOODS_RCPT_POST_DT >= CAST('2014-01-01' AS DATE)
