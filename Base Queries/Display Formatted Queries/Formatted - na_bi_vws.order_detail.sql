SELECT
    CAL.DAY_DATE AS "Business Date",
    OD.ORDER_ID AS "Order ID",
    OD.ORDER_LINE_NBR AS "Order Line Nbr",
    OD.SCHED_LINE_NBR AS "Schedule Line Nbr",

    OD.MATL_ID AS "Material ID",
    M.DESCR AS "Material Description",
    M.PBU_NBR AS "PBU Nbr",
    M.PBU_NAME AS "PBU Name",
    M.EXT_MATL_GRP_ID AS "External Material Group ID",

    OD.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    C.CUST_NAME AS "Ship To Customer Name",
    C.OWN_CUST_ID AS "Common Owner ID",
    C.OWN_CUST_NAME AS "Common Owner Name",
    OD.SALES_ORG_CD AS "Sales Org Code",
    OD.DISTR_CHAN_CD AS "Distribution Channel Code",
    OD.CUST_GRP_ID AS "Customer Group ID",
    OD.CO_CD AS "Company Code",
    OD.DIV_CD AS "Division Code",

    OD.ORDER_CAT_ID AS "Order Category ID",
    OD.ORDER_TYPE_ID AS "Order Type ID",
    NULLIF( OD.PO_TYPE_ID , ' ' ) AS "PO Type ID",
    NULLIF( OD.ORDER_CREATOR, ' ' ) AS "Order Creator",
    NULLIF( OD.REJ_REAS_ID, ' ' ) AS "Rejection Reason ID",

    OD.FACILITY_ID AS "Facility ID",
    OD.SHIP_PT_ID AS "Shipping Point ID",
    NULLIF( OD.DELIV_BLK_CD, ' ' ) AS "Delivery Block Code",
    OD.DELIV_PRTY_ID AS "Delivery Priority ID",
    NULLIF( OD.ROUTE_ID, ' ' ) AS "Route ID",
    OD.DELIV_GRP_CD AS "Delivery Group Code",
    NULLIF( OD.SPCL_PROC_ID, ' ' ) AS "Special Process ID",
    NULLIF( OD.RPT_FRT_PLCY_CD, ' ' ) AS "Customer Group 2 Code",
    NULLIF( OD.SHIP_COND_ID, ' ' ) AS "Shipping Condition ID",

    CASE WHEN OD.CANCEL_IND = 'Y' THEN 'Y' ELSE 'N' END AS "Cancellation Ind.",
    CASE WHEN OD.RETURN_IND = 'Y' THEN 'Y' ELSE 'N' END AS "Return Ind.",
    CASE WHEN OD.DELIV_BLK_IND = 'Y' THEN 'Y' ELSE 'N' END AS "Delivery Block Ind.",

    OD.ORDER_DT AS "Order Create Date",
    OD.CUST_RDD AS ORDD,
    OD.FRST_RDD AS FRDD,
    OD.FRST_MATL_AVL_DT AS "FMAD for FRDD",
    OD.FRST_PLN_GOODS_ISS_DT AS "FPGI for FRDD",

    FCDD - ( CAST( OD.FRST_RDD - OD.FRST_MATL_AVL_DT AS INTEGER ) ) AS "FMAD for FCDD",
    FCDD - ( CAST( OD.FRST_RDD - OD.FRST_PLN_GOODS_ISS_DT AS INTEGER ) ) AS "FPGI for FCDD",
    CASE WHEN OD.FRST_PROM_DELIV_DT < OD.FRST_RDD THEN OD.FRST_RDD ELSE OD.FRST_PROM_DELIV_DT END AS FCDD,

    OD.PLN_TRANSP_PLN_DT AS "Pln. Transp. Plan Date",
    OD.PLN_MATL_AVL_DT AS "Pln. MAD",
    OD.PLN_LOAD_DT AS "Pln. Load Date",
    OD.PLN_DELIV_DT AS "Pln. Delivery Date",

    OD.QTY_UNIT_MEAS_ID AS "Qty. UOM",
    OD.ORDER_QTY AS "Order Qty",
    OD.CNFRM_QTY AS "Confirmed Qty",

    OD.WT_UNITS_MEAS_ID AS "Wt. UOM",
    OD.NET_WT as "Net Wt.",
    OD.GROSS_WT as "Gross Wt.",
    OD.VOL_UNIT_MEAS_ID AS "Vol. UOM",
    OD.VOL AS "Volume"

FROM GDYR_VWS.GDYR_CAL CAL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON CAL.DAY_DATE BETWEEN OD.EFF_DT AND OD.EXP_DT

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
        AND C.CUST_GRP_ID <> '3R'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
        ON M.MATL_ID = OD.MATL_ID

WHERE
    OD.CUST_GRP_ID <> '3R'
    AND OD.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
    AND OD.RO_PO_TYPE_IND = 'N'
    AND OD.ORDER_ID = '0084637774'
    AND OD.ORDER_LINE_NBR = 20
    AND CAL.DAY_DATE < CURRENT_DATE

ORDER BY
    OD.ORDER_ID,
    OD.ORDER_LINE_NBR,
    OD.SCHED_LINE_NBR,
    CAL.DAY_DATE