
CREATE TABLE [Delivery Details] (
    [Delivery Fiscal Year] char(4) primary key
    , [Delivery Doc ID] char(10) primary key
    , [Delivery Doc Item ID] long primary key

    , [Division Code] char(2)
    , [Sales Org Code] CHAR(4)
    , [Distribution Channel Code] CHAR(2)
    , [Customer Group Code] CHAR(2)
    , [Sold To Customer ID] CHAR(10)
    , [Ship To Customer ID] CHAR(10)
    , [Bill To Customer ID] CHAR(10)
    , [Payor Customer ID] CHAR(10)

    , [Order Fiscal Year] char(4)
    , [Order ID] char(10)
    , [Order Line Nbr] integer

    , [Header Facility ID] char(4)
    , [Item Facility ID] char(4)

    , [Ship Point ID] char(4)
    , [Return Ind] char(1)
    , [Delivery Type ID] char(4)
    , [Delivery Category ID] char(1)
    , [Delivery Note Create Date] date
    , [Delivery Line Create Date] date
    , [Item Category ID] char(4)

    , [Material ID] char(18)
    , [Customer Part Nbr] varchar(35)
    , [Batch Nbr] varchar(10)

    , [Delivery Priority ID] char(2)
    , [Delivery Qty] decimal(15,3)
    , [Quantity Unit of Measure] char(3)
    , [Sales Delivery Qty] decimal(15,3)
    , [Sales Quantity Unit of Measure] char(3)
    , [Report Delivery Qty] decimal(15,3)
    , [Report Quantity Unit of Measure] char(3)

    , [Volume] decimal(15,3)
    , [Volume Unit of Measure] char(3)

    , [Net Weight] decimal(15,3)
    , [Gross Weight] decimal(15,3)
    , [Weight Unit of Measure] char(3)

    , [Partial Delivery Code] char(1)
    , [SAP Bill of Lading ID] varchar(35)
    , [Shipping Condition ID] char(2)
    , [Original Delivery Line Nbr] long
    
    , [Transportation Planning Date] date
    , [Loading Date] date
    , [Pick Date] date
    , [Actual Goods Issue Date] date
    , [Delivery Date] date
    , [Delivery Time] time
    , [Route ID] char(6)
    , [Incoterms Code] varchar(3)
    , [Unloading Point] varchar(25)
    , [Special Processing Ind] char(4)
    , [Post Goods Issue Time] time
    , [Primary Shipment Carrier Code] char(4)
    , [Transportation Vehicle Nbr] char(10)
    , [Delivery Createor] varchar(12)
    , [Planned Goods Movement Date] date
    , [Next Planned Delivery Date]
);


    , BILL_LADING_ID
    , SHIP_COND_ID
    , ORIG_DELIV_LINE_NBR
    , TRANSP_PLN_DT
    , LOAD_DT
    , PICK_DT
    , ACTL_GOODS_ISS_DT
    , DELIV_DT
    , DELIV_TM
    , RTG_ID
    , TERMS_ID
    , UNLD_PT_CD
    , SPCL_PROC_ID
    , POST_GOODS_ISS_TM
    , PRM_SHIP_CARR_CD
    , TRANSP_VEH_NO
    , SRC_CRT_USR_ID
    , PLN_GOODS_MVT_DT
    , NXT_PLN_DELIV_DT
    , CUST_GRP2_CD
    , RPT_FRT_PLCY_CD
    , RPT_SHIP_FACILITY_ID
    , GOODS_ISS_IND
    , SCHD_AGR_ID
    , SCHD_AGR_ITM_ID
    , DELIV_GRP_CD
    , SD_DOC_CTGY_CD

FROM NA_VWS.DELIV_DTL

WHERE
    EXP_DT = CAST('5555-12-31' AS DATE)
    AND ORIG_SYS_ID = 2
    AND DELIV_LINE_FACILITY_ID IN (
        SELECT
            F.FACILITY_ID
        FROM GDYR_VWS.FACILITY F
        WHERE
            F.ORIG_SYS_ID = 2
            AND F.EXP_DT = CAST('5555-12-31' AS DATE)
            AND F.LANG_ID = 'EN'
            AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
            AND F.DISTR_CHAN_CD = '81'
        )
    AND (
        ACTL_GOODS_ISS_DT IS NULL
        OR (ORDER_FISCAL_YR, ORDER_ID, ORDER_LINE_NBR) IN (
            SELECT
                ORDER_FISCAL_YR
                , ORDER_ID
                , ORDER_LINE_NBR

            FROM NA_BI_vWS.OPEN_ORDER_ORDLN_CURR
        )
        )

ORDER BY
    1,2,3
;