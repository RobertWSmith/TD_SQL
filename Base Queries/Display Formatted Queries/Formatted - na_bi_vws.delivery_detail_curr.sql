SELECT
    DDC.DELIV_ID AS "Delivery ID",
    DDC.DELIV_LINE_NBR AS "Delivery Line Nbr",
    DDC.ORDER_ID AS "Order ID",
    DDC.ORDER_LINE_NBR AS "Order Line Nbr",

    DDC.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    DDC.CUST_GRP_ID AS "Customer Group ID",
    DDC.CUST_GRP2_CD AS "Customer Group 2 Code",

    DDC.MATL_ID AS "Material ID",

    DDC.FACILITY_ID AS "Facility ID",
    DDC.DELIV_LINE_FACILITY_ID AS "Delivery Line Facility ID",
    DDC.SHIP_PT_ID AS "Ship Point ID",

    DDC.DELIV_TYPE_ID AS "Delivery Type ID",
    DDC.DELIV_CAT_ID AS "Delivery Category ID",
    DDC.DELIV_PRTY_ID AS "Delivery Priority ID",
    DDC.SHIP_COND_ID AS "Shipping Condition ID",
    DDC.BILL_LADING_ID AS "Bill of Lading ID",
    DDC.UNLD_PT_CD AS "Unloading Point Text",
    DDC.SPCL_PROC_ID AS "Special Process Ind",
    DDC.SRC_CRT_USR_ID AS "Delvery Creator",

    CASE WHEN DDC.RETURN_IND = 'Y' THEN 'Y' ELSE 'N' END AS "Return Ind",

    DDC.QTY_UNIT_MEAS_ID AS "Qty. UOM",
    DDC.DELIV_QTY AS "Delivery Qty",

    DDC.VOL_UNIT_MEAS_ID AS "Vol. UOM",
    DDC.VOL AS "Volume",

    DDC.WT_UNIT_MEAS_ID AS "Wt. UOM",
    DDC.NET_WT AS "Net Wt.",
    DDC.GROSS_WT AS "Gross Wt.",

    DDC.TRANSP_PLN_DT AS "Transp. Plan Date",
    DDC.LOAD_DT AS "Load Date",
    DDC.PICK_DT AS "Pick Date",
    DDC.ACTL_GOODS_ISS_DT AS "Actual Goods Issue Date",
    DDC.DELIV_DT AS "Delivery Date"

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

WHERE
    DDC.DELIV_QTY > 0
    AND DDC.DELIV_DT >= CAST( EXTRACT( YEAR FROM CURRENT_DATE ) - 2 || '-01-01' AS DATE )

ORDER BY
    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR