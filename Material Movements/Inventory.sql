﻿SELECT
    I.DAY_DT
    , I.MATL_ID
    , I.FACILITY_ID
    , I.INV_QTY_UOM
    , I.TOT_QTY
    , I.IN_TRANS_QTY
    , I.DEF_QTY
    , I.BACK_ORDER_QTY
    , I.NET_BACK_ORDER_QTY
    , I.COMMIT_QTY
    , I.UN_COMMIT_QTY
    , I.AVAIL_TO_PROM_QTY
    , I.STO_INBOUND_QTY
    , I.STO_OUTBOUND_QTY
    , I.IN_PROS_TO_CUST_QTY
    , I.RSVR_QTY
    , I.RSTR_QTY
    , I.QUAL_INSP_QTY
    , I.BLOCKED_STK_QTY

FROM NA_BI_VWS.FACL_MATL_INV I