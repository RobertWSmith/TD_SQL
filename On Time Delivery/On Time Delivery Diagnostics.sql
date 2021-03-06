﻿ SELECT
    OD.ORDER_ID,
    OD.ORDER_LINE_NBR,
    OD.SCHED_LINE_NBR,

    CAL.DAY_DATE,
    OD.EFF_DT,
    OD.EXP_DT,

    OD.MATL_ID,
    M.DESCR,
    M.PBU_NBR,
    M.PBU_NAME,
    M.EXT_MATL_GRP_ID,
    OD.ITEM_CAT_ID,
    NULLIF(OD.BATCH_NBR, '') AS BATCH_NBR,

    OD.SHIP_TO_CUST_ID,
    C.CUST_NAME AS SHIP_TO_CUST_NAME,
    C.OWN_CUST_ID,
    C.OWN_CUST_NAME,
    OD.SALES_ORG_CD,
    OD.DISTR_CHAN_CD,
    OD.CUST_GRP_ID,
    OD.CO_CD,
    OD.DIV_CD,

    OD.ORDER_CAT_ID,
    OD.ORDER_TYPE_ID,
    NULLIF(OD.PO_TYPE_ID , '') AS PO_TYPE_ID,
    NULLIF(OD.ORDER_CREATOR, '') AS ORDER_CREATOR,
    NULLIF(OD.REJ_REAS_ID, '') AS REJ_REAS_ID,
    NULLIF(OD.ORDER_REAS_CD, '') AS ORDER_REAS_CD,
    NULLIF(OD.PROD_ALLCT_DETERM_PROC_ID, '') AS PROD_ALLCT_DETERM_PROC_ID,

    OD.FACILITY_ID,
    OD.SHIP_PT_ID,
    NULLIF(OD.DELIV_BLK_CD, '') AS DELIV_BLK_CD,
    OD.DELIV_PRTY_ID,
    NULLIF(OD.ROUTE_ID, '') AS ROUTE_ID,
    OD.DELIV_GRP_CD,
    NULLIF(OD.SPCL_PROC_ID, '') AS SPCL_PROC_ID,
    NULLIF(OD.RPT_FRT_PLCY_CD, '') AS CUST_GRP2_CD,
    NULLIF(OD.SHIP_COND_ID, '') AS SHIP_COND_ID,

    OD.CANCEL_IND,
    COALESCE(OD.RETURN_IND, 'N') AS RETURN_IND,
    COALESCE(OOL.CREDIT_HOLD_FLG, 'N') AS CREDIT_HOLD_FLG,
    OD.DELIV_BLK_IND,
    NULLIF(OD.PRTL_DLVY_CD, '') AS PRTL_DLVY_CD,
    NULLIF(OD.HANDSHAKE_TYP_CD, '') AS HANDSHAKE_TYP_CD,

    OD.ORDER_DT,
    OD.CUST_RDD AS ORDD,
    OD.FRST_RDD AS FRDD,
    OD.FRST_MATL_AVL_DT AS FRDD_FMAD,
    OD.FRST_PLN_GOODS_ISS_DT AS FRDD_FPGI,

    OD.FRST_PROM_DELIV_DT AS FCDD,
    FCDD - (CAST(OD.FRST_RDD - FRDD_FMAD AS INTEGER)) AS FCDD_FMAD,
    FCDD - (CAST(OD.FRST_RDD - FRDD_FPGI AS INTEGER)) AS FCDD_FPGI,

    OD.PLN_TRANSP_PLN_DT,
    OD.PLN_MATL_AVL_DT,
    OD.PLN_GOODS_ISS_DT,
    OD.PLN_LOAD_DT,
    OD.PLN_DELIV_DT,

    CAST(CASE
        WHEN OD.PLN_DELIV_DT > OD.FRST_RDD
            THEN 'PDD > FRDD'
        WHEN OD.PLN_DELIV_DT = OD.FRST_RDD
            THEN 'PDD = FRDD'
        WHEN OD.PLN_DELIV_DT < OD.FRST_RDD
            THEN 'PDD < FRDD'
    END AS CHAR(10)) AS PDD_VS_FRDD_TEST,
    CAST(CASE
        WHEN OD.PLN_DELIV_DT > FCDD
            THEN 'PDD > FCDD'
        WHEN OD.PLN_DELIV_DT = FCDD
            THEN 'PDD = FCDD'
        WHEN OD.PLN_DELIV_DT < FCDD
            THEN 'PDD < FCDD'
    END AS CHAR(10)) AS PDD_VS_FCDD_TEST,

    OD.QTY_UNIT_MEAS_ID,
    OD.ORDER_QTY,
    OD.CNFRM_QTY,
    OOL.OPEN_CNFRM_QTY,
    OOL.UNCNFRM_QTY,
    OOL.BACK_ORDER_QTY,
    OOL.DEFER_QTY,
    OOL.IN_PROC_QTY,
    OOL.WAIT_LIST_QTY,
    OOL.OTHR_ORDER_QTY,

    OD.WT_UNITS_MEAS_ID,
    OD.NET_WT,
    OD.GROSS_WT,
    OD.VOL_UNIT_MEAS_ID,
    OD.VOL

FROM GDYR_VWS.GDYR_CAL CAL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT
        AND OD.ORDER_ID = '?OrderID'
        AND OD.ORDER_LINE_NBR = ?OrderLineNbr

    LEFT OUTER JOIN NA_VWS.OPEN_ORDER_SCHDLN OOL
        ON CAL.DAY_DATE BETWEEN OOL.EFF_DT AND OOL.EXP_DT
        AND OOL.ORDER_ID = OD.ORDER_ID
        AND OOL.ORDER_LINE_NBR = OD.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = OD.SCHED_LINE_NBR

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID

WHERE
    CAL.DAY_DATE < CURRENT_DATE

ORDER BY
    CAL.DAY_DATE,
    OD.ORDER_ID,
    OD.ORDER_LINE_NBR,
    OD.SCHED_LINE_NBR
;

SELECT
    DDC.FISCAL_YR,
    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR,
    DDC.ORDER_ID,
    DDC.ORDER_LINE_NBR,

    DDC.SHIP_TO_CUST_ID,
    DDC.CUST_GRP_ID,
    DDC.CUST_GRP2_CD,
    DDC.SALES_ORG_CD,
    DDC.DISTR_CHAN_CD,

    DDC.FACILITY_ID,
    DDC.DELIV_LINE_FACILITY_ID,
    DDC.SHIP_PT_ID,
    DDC.SHIP_FACILITY_ID,

    DDC.MATL_ID,

    DDC.DELIV_TYPE_ID,
    DDC.DELIV_CAT_ID,
    DDC.DELIV_PRTY_ID,
    DDC.PRTL_DLVY_CD,
    DDC.BILL_LADING_ID,
    DDC.SHIP_COND_ID,
    DDC.RTG_ID,
    DDC.TERMS_ID,
    DDC.UNLD_PT_CD,
    DDC.SPCL_PROC_ID,
    DDC.PRM_SHIP_CARR_CD,
    DDC.TRANSP_VEH_NO,
    DDC.SRC_CRT_USR_ID,

    DDC.DELIV_NOTE_CREA_DT,
    DDC.DELIV_LINE_CREA_DT,
    DDC.TRANSP_PLN_DT,
    DDC.LOAD_DT,
    DDC.PICK_DT,
    DDC.ACTL_GOODS_ISS_DT,
    DDC.DELIV_DT,

    DDC.QTY_UNIT_MEAS_ID AS QTY_UOM,
    DDC.DELIV_QTY,
    DDC.VOL_UNIT_MEAS_ID AS VOL_UOM,
    DDC.VOL,
    DDC.WT_UNIT_MEAS_ID AS WT_UOM,
    DDC.NET_WT,
    DDC.GROSS_WT

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

WHERE
    DDC.ORDER_ID = '?OrderID'
    AND DDC.ORDER_LINE_NBR = ?OrderLineNbr

ORDER BY
    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR,
    DDC.ORDER_ID,
    DDC.ORDER_LINE_NBR
;

SELECT
    POL.ORDER_ID,
    POL.ORDER_LINE_NBR,
    
    CASE
        WHEN POL.CMPL_IND = 1 AND POL.CMPL_DT < CURRENT_DATE
            THEN (CASE
                WHEN pol.prfct_ord_hit_sort_key <> 99
                    THEN 'FRDD Complete'
                WHEN pol.prfct_ord_hit_sort_key = 99
                    THEN 'FRDD Complete - Excluded'
                ELSE 'FRDD Complete - Indeterminate Status'
            end)
        ELSE 'FRDD Incomplete'
    END AS FRDD_COMPLETE_DESC,
    
    CASE
        WHEN POL.FRST_PROM_DELIV_DT IS NOT NULL
            THEN (CASE
                WHEN POL.FPDD_CMPL_IND = 1 AND POL.FPDD_CMPL_DT < CURRENT_DATE
                    THEN (CASE
                        WHEN POL.PRFCT_ORD_FPDD_HIT_SORT_KEY <> 99
                            THEN 'FCDD Complete'
                        WHEN POL.PRFCT_ORD_FPDD_HIT_SORT_KEY = 99
                            THEN 'FCDD Complete - Excluded'
                        ELSE 'FCDD Complete - Indeterminate Status'
                    END)
                ELSE 'FCDD Incomplete'
            END)
        ELSE 'FCDD Incomplete'
    END AS FCDD_COMPLETE_DESC,

    POL.CMPL_DT AS FRDD_CMPL_DT,
    POL.CMPL_DT - (EXTRACT(DAY FROM POL.CMPL_DT) - 1) AS FRDD_CMPL_MTH,
    POL.FPDD_CMPL_DT AS FCDD_CMPL_DT,
    POL.FPDD_CMPL_DT - (EXTRACT(DAY FROM POL.FPDD_CMPL_DT) - 1) AS FCDD_CMPL_MTH,
    POL.CMPL_IND AS FRDD_CMPL_IND,
    POL.FPDD_CMPL_IND AS FCDD_CMPL_IND,

    POL.SHIP_TO_CUST_ID,
    POL.MATL_ID,
    POL.PBU_NBR,
    POL.SHIP_FACILITY_ID,
    NULLIF(POL.MAX_CARR_SCAC_ID, '') AS MAX_CARR_SCAC_ID,

    NULLIF(POL.CAN_REJ_REAS_ID, '') AS CAN_REJ_REAS_ID,
    NULLIF(POL.PO_TYPE_ID, '') AS PO_TYPE_ID,
    CASE WHEN POL.CREDIT_HOLD_FLG = 'Y' THEN 'Y' ELSE 'N' END AS CREDIT_HOLD_FLG,
    CASE WHEN POL.DELIV_BLK_IND = 'Y' THEN 'Y' ELSE 'N' END AS DELIV_BLK_IND,
    CASE WHEN POL.CANCEL_IND = 'Y' THEN 'Y' ELSE 'N' END AS CANCEL_IND,
    POL.A_IND,
    POL.R_IND,
    NULLIF(POL.SPCL_PROC_ID, '') AS SPCL_PROC_ID,

    POL.ORDER_DT,
    POL.FMAD_DT AS FRDD_FMAD,
    POL.FPGI_DT AS FRDD_FPGI,
    POL.REQ_DELIV_DT AS FRDD,

    FCDD - (FRDD - FRDD_FMAD) AS FCDD_FMAD,
    FCDD - (FRDD - FRDD_FPGI) AS FCDD_FPGI,
    POL.FRST_PROM_DELIV_DT AS FCDD,

    POL.CUST_APPT_DT,
    POL.MAX_DELIV_NOTE_CREA_DT,
    POL.MAX_EDI_DELIV_DT,
    POL.MAX_SAP_DELIV_DT,
    POL.ACTL_DELIV_DT,
    POL.NO_STK_DT AS FRDD_NO_STOCK_DT,
    POL.FPDD_NO_STK_DT AS FCDD_NO_STOCK_DT,

    POL.PRFCT_ORD_HIT_DESC AS FRDD_HIT_DESC,
    POL.PRFCT_ORD_HIT_SORT_KEY AS FRDD_HIT_SORT_KEY,

    ZEROIFNULL(POL.ORIG_ORD_QTY) AS ORIG_ORDER_QTY,
    ZEROIFNULL(POL.CANCEL_QTY) AS CANCEL_QTY,

    ZEROIFNULL(POL.CURR_ORD_QTY) AS FRDD_ORDER_QTY,
    ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY) AS FRDD_HIT_QTY,
    ZEROIFNULL(POL.CURR_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_HIT_QTY) AS FRDD_ONTIME_QTY,
    ZEROIFNULL(POL.REL_LATE_QTY) AS FRDD_REL_LATE_QTY,
    ZEROIFNULL(POL.REL_ONTIME_QTY) AS FRDD_REL_ONTIME_QTY,
    ZEROIFNULL(POL.COMMIT_ONTIME_QTY) AS FRDD_COMMIT_ONTIME_QTY,
    ZEROIFNULL(POL.DELIV_LATE_QTY) AS FRDD_DELIV_LATE_QTY,
    ZEROIFNULL(POL.DELIV_ONTIME_QTY) AS FRDD_DELIV_ONTIME_QTY,

    ZEROIFNULL(POL.NE_HIT_RT_QTY) AS FRDD_RETURN_HIT_QTY,
    ZEROIFNULL(POL.NE_HIT_CL_QTY) AS FRDD_CLAIM_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_FP_QTY) AS FRDD_FREIGHT_POLICY_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_CARR_PICKUP_QTY) + ZEROIFNULL(POL.OT_HIT_WI_QTY) AS FRDD_PHYS_LOG_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_MB_QTY) AS FRDD_MAN_BLK_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_CH_QTY) AS FRDD_CREDIT_HOLD_HIT_QTY,
    ZEROIFNULL(POL.IF_HIT_NS_QTY) AS FRDD_NO_STOCK_HIT_QTY,
    ZEROIFNULL(POL.IF_HIT_CO_QTY) AS FRDD_CANCEL_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_CG_QTY) AS FRDD_CUST_GEN_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_CG_99_QTY) AS FRDD_MAN_REL_CUST_GEN_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_99_QTY) AS FRDD_MAN_REL_HIT_QTY,
    ZEROIFNULL(POL.OT_HIT_LO_QTY) AS FRDD_OTHER_HIT_QTY,

    POL.PRFCT_ORD_FPDD_HIT_DESC AS FCDD_HIT_DESC,
    POL.PRFCT_ORD_FPDD_HIT_SORT_KEY AS FCDD_HIT_SORT_KEY,

    ZEROIFNULL(POL.FPDD_ORD_QTY) AS FCDD_ORDER_QTY,
    ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY) AS FCDD_HIT_QTY,
    ZEROIFNULL(POL.FPDD_ORD_QTY) - ZEROIFNULL(POL.PRFCT_ORD_FPDD_HIT_QTY) AS FCDD_ONTIME_QTY,
    ZEROIFNULL(POL.DELIV_FPDD_LATE_QTY) AS FCDD_DELIV_LATE_QTY,
    ZEROIFNULL(POL.DELIV_FPDD_ONTIME_QTY) AS FCDD_DELIV_ONTIME_QTY,
    ZEROIFNULL(POL.FPDD_COMMIT_ONTIME_QTY) AS FCDD_COMMIT_ONTIME_QTY,
    ZEROIFNULL(POL.REL_FPDD_LATE_QTY) AS FCDD_REL_LATE_QTY,
    ZEROIFNULL(POL.REL_FPDD_ONTIME_QTY) AS FCDD_REL_ONTIME_QTY,

    ZEROIFNULL(POL.NE_FPDD_HIT_RT_QTY) AS FCDD_RETURN_HIT_QTY,
    ZEROIFNULL(POL.NE_FPDD_HIT_CL_QTY) AS FCDD_CLAIM_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_FP_QTY) AS FCDD_FREIGHT_POLICY_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_CARR_QTY) + ZEROIFNULL(POL.OT_FPDD_HIT_WI_QTY) AS FCDD_PHYS_LOG_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_MB_QTY) AS FCDD_MAN_BLK_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_CH_QTY) AS FCDD_CREDIT_HOLD_HIT_QTY,
    ZEROIFNULL(POL.IF_FPDD_HIT_NS_QTY) AS FCDD_NO_STOCK_HIT_QTY,
    ZEROIFNULL(POL.IF_FPDD_HIT_CO_QTY) AS FCDD_CANCEL_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_CG_QTY) AS FCDD_CUST_GEN_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_CG_99_QTY) AS FCDD_MAN_REL_CUST_GEN_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_99_QTY) AS FCDD_MAN_REL_HIT_QTY,
    ZEROIFNULL(POL.OT_FPDD_HIT_LO_QTY) AS FCDD_OTHER_HIT_QTY

FROM NA_BI_VWS.PRFCT_ORD_LINE POL

WHERE
    POL.ORDER_ID =  '?OrderID'
    AND POL.ORDER_LINE_NBR = ?OrderLineNbr
;

SELECT
    INV.DAY_DT AS BUS_DT,
    INV.FACILITY_ID || ' - ' || FAC.XTND_NAME AS FACILITY,

    INV.MATL_ID,
    MATL.DESCR,
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
    MATL.MKT_AREA_NBR || ' - ' || MATL.MKT_AREA_NAME AS MKT_AREA,

    INV.TOT_QTY,
    INV.COMMIT_QTY,
    INV.UN_COMMIT_QTY,
    INV.AVAIL_TO_PROM_QTY,
    INV.IN_PROS_TO_CUST_QTY,
    INV.BACK_ORDER_QTY,
    INV.NET_BACK_ORDER_QTY,
    INV.BLOCKED_STK_QTY,
    INV.RSVR_QTY,

    INV.STO_INBOUND_QTY,
    INV.STO_OUTBOUND_QTY,
    INV.IN_TRANS_QTY,

    INV.QUAL_INSP_QTY,
    INV.BLOCKED_STK_QTY,
    INV.RSTR_QTY,
    INV.STK_RET_QTY,
    INV.UNRSTR_QTY,
    INV.EST_DAYS_SUPPLY

FROM NA_BI_VWS.INVENTORY INV

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = INV.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_HIER_EN_CURR FAC
        ON FAC.FACILITY_ID = INV.FACILITY_ID

WHERE
    (INV.MATL_ID, INV.FACILITY_ID) IN (
            SELECT
                MATL_ID,
                FACILITY_ID
            FROM NA_BI_VWS.ORDER_DETAIL_CURR
            WHERE
                ORDER_ID = '?OrderID'
                AND ORDER_LINE_NBR = ?OrderLineNbr
            GROUP BY
                MATL_ID,
                FACILITY_ID
        )
    AND INV.DAY_DT BETWEEN (CURRENT_DATE - 60) AND CURRENT_DATE

ORDER BY
    INV.DAY_DT DESC