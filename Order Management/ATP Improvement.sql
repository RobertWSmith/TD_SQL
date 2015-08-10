SELECT
    OOL.ORDER_FISCAL_YR "Order Fiscal Year"
    , OOL.ORDER_ID "Order ID"
    , OOL.ORDER_LINE_NBR "Order Line Nbr"
    , OOL.SCHED_LINE_NBR "Schedule Line Nbr"

    , OD.ORDER_DT "Order Create Date"
    , OD.ORDER_LN_CRT_DT "Item Create Date"
    , OD.FRST_MATL_AVL_DT "FRDD FMAD"
    , OD.FRST_PLN_GOODS_ISS_DT "FRDD FPGI"
    , OD.FRST_RDD "FRDD"
    , OD.FRST_PROM_DELIV_DT "FCDD"
    , OD.PLN_MATL_AVL_DT "Planned Matl. Avail. Date"
    , OD.PLN_GOODS_ISS_DT "Planned Goods Issue Date"
    , OD.PLN_DELIV_DT "Planned Delivery Date"

    , OD.SHIP_TO_CUST_ID "Ship To Customer ID"
    , C.CUST_NAME "Ship To Customer Name"
    , C.OWN_CUST_ID "Common Owner ID"
    , C.OWN_CUST_NAME "Common Owner Name"
    , CASE
        WHEN C.SALES_ORG_CD IN ('N302', 'N312', 'N322') OR (C.SALES_ORG_CD IN ('N303', 'N313', 'N323') AND C.DISTR_CHAN_CD = '32')
            THEN 'OE'
        ELSE 'Replacement'
        END "OE-Replacement Ind."
    , C.CO_CD "Company Code"
    , C.CO_DESC "Company Desc"
    , C.SALES_ORG_CD "Sales Org Code"
    , C.SALES_ORG_NAME "Sales Org Desc"
    , C.DISTR_CHAN_CD "Distr. Chan Code"
    , C.DISTR_CHAN_NAME "Distr. Chan Desc"
    , C.CUST_GRP_ID "Customer Group ID"
    , C.CUST_GRP_NAME "Customer Group Name"

    , OD.MATL_ID "Matl ID"
    , M.MATL_NO_8 || ' - ' || M.DESCR "Matl Desc"
    , M.MATL_STA_ID "Matl Status ID"
    , M.PBU_NBR "PBU Nbr"
    , M.PBU_NAME "PBU Name"
    , M.MKT_AREA_NBR "Market Area Nbr"
    , M.MKT_AREA_NAME "Market Area Name"
    , M.MKT_CTGY_MKT_AREA_NBR "Category Code"
    , M.MKT_CTGY_MKT_AREA_NAME "Category Name"
    , M.PROD_LINE_NBR "Product Line Nbr"
    , M.PROD_LINE_NAME "Product Line Name"

    , F.FACILITY_ID "Facility ID"
    , F.FACILITY_NAME "Facility Name"

    , OD.ORDER_CAT_ID "Order Category"
    , OD.ORDER_TYPE_ID "Order Type"
    , OD.PO_TYPE_ID "PO Type"
    , OD.CUST_PO_NBR "Customer PO Nbr"
    , OD.CUST_GRP2_CD "Customer Group 2 Code"
    , OD.ORDER_DELIV_BLK_CD "Header Delivery Block"
    , OD.DELIV_BLK_CD "Sched Line Delivery Block"
    , OOL.CREDIT_HOLD_FLG "Credit Hold Flag"
    , OD.DELIV_PRTY_ID "Delivery Priority"
    , OD.SPCL_PROC_ID "Special Processing Ind"
    , OD.SHIP_COND_ID "Shipping Condition ID"
    , OD.AVAIL_CHK_GRP_CD "Checking Group for Availability"
    , OD.PROD_ALLCT_DETERM_PROC_ID "CSP Ind"

    , OOL.SLS_QTY_UNIT_MEAS_ID "Qty UOM"
    , OD.ORDER_QTY "Order Qty"
    , OOL.OPEN_CNFRM_QTY "Open Confirmed Qty"
    , OOL.UNCNFRM_QTY "Unconfirmed Qty"
    , OOL.BACK_ORDER_QTY "Back Order Qty"
    , OOL.WAIT_LIST_QTY "Wait List Qty"
    , OOL.DEFER_QTY "Deferred Qty"
    , OOL.OTHR_ORDER_QTY "Other Order Qty"
    , OOL.OPEN_CNFRM_QTY + OOL.UNCNFRM_QTY + OOL.BACK_ORDER_QTY + OOL.WAIT_LIST_QTY + OOL.DEFER_QTY + OOL.OTHR_ORDER_QTY "Open Qty"

    , ZEROIFNULL(FMI.AVAIL_TO_PROM_QTY) "Facility-Matl ATP Qty"
    , SUM("Open Qty") OVER (PARTITION BY OD.MATL_ID, OD.FACILITY_ID) "Total Open Qty"
    , SUM("Open Qty") OVER (PARTITION BY OD.MATL_ID, OD.FACILITY_ID ORDER BY OD.DELIV_PRTY_ID, OD.PLN_MATL_AVL_DT, OOL.OPEN_CNFRM_QTY, OD.ORDER_LN_CRT_DT ROWS UNBOUNDED PRECEDING) "Cumulative Open Qty"
    , CASE
        WHEN "Total Open Qty" <= ZEROIFNULL(FMI.AVAIL_TO_PROM_QTY)
            THEN "Open Qty"
        WHEN "Total Open Qty" > ZEROIFNULL(FMI.AVAIL_TO_PROM_QTY) AND "Open Qty" + (ZEROIFNULL(FMI.AVAIL_TO_PROM_QTY) - "Total Open Qty") > 0
            THEN "Open Qty" + (ZEROIFNULL(FMI.AVAIL_TO_PROM_QTY) - "Total Open Qty")
        ELSE 0
        END "Available to Improve Qty"

FROM NA_VWS.OPEN_ORDER_SCHDLN OOL

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = OOL.ORDER_FISCAL_YR
        AND OD.ORDER_ID = OOL.ORDER_ID
        AND OD.ORDER_LINE_NBR = OOL.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = OOL.SCHED_LINE_NBR
        AND OD.EXP_DT = CAST('5555-12-31' AS DATE)
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
        ON C.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M 
        ON M.MATL_ID = OD.MATL_ID
        AND M.PBU_NBR = '01'

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = OD.FACILITY_ID
        AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND F.DISTR_CHAN_CD = '81'

    LEFT OUTER JOIN NA_BI_VWS.FACL_MATL_INV FMI
        ON FMI.DAY_DT = CURRENT_DATE-1
        AND FMI.MATL_ID = OD.MATL_ID
        AND FMI.FACILITY_ID = OD.FACILITY_ID

WHERE
    OOL.EXP_DT = CAST('5555-12-31' AS DATE)
    AND OOL.ORIG_SYS_ID = 2
    AND OD.FRST_PLN_GOODS_ISS_DT > ADD_MONTHS(CURRENT_DATE - EXTRACT(DAY FROM CURRENT_DATE), 1)
    AND "OE-Replacement Ind." = 'Replacement'
    AND (
        OOL.OPEN_CNFRM_QTY > 0
        OR OOL.UNCNFRM_QTY > 0
        OR OOL.BACK_ORDER_QTY > 0
        OR OOL.WAIT_LIST_QTY > 0
        OR OOL.DEFER_QTY > 0
        OR OOL.OTHR_ORDER_QTY > 0
        )

ORDER BY
    OOL.ORDER_FISCAL_YR
    , OOL.ORDER_ID
    , OOL.ORDER_LINE_NBR
    , OOL.SCHED_LINE_NBR
