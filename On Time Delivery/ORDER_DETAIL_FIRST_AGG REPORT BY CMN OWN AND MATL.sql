SELECT
    OLN.OWN_CUST AS "Common Owner",
    OLN.MATL_ID AS "Material ID",
    OLN.DESCR AS "Material Description",
    OLN.STK_CLASS_ID AS "Material Class of Stock",
    OLN.PBU,
    OLN.FACILITY_ID AS "Facility ID",
    OLN.ORDER_DT AS "Order Create Date",

    SUM( OLN.ORDERED_QTY ) AS "Total Ordered Qty",
    SUM( CASE
        WHEN OLN.DELIV_QTY = 0
            THEN OLN.CANCELLED_QTY
        WHEN OLN.DELIV_QTY > 0 AND OLN.CANCELLED_QTY > 0
            THEN OLN.ORDERED_QTY - OLN.DELIV_QTY
        ELSE 0
    END ) AS "Cancelled Qty",
    -- SUM( OLN.CANCELLED_QTY ) - SUM( OLN.DELIV_QTY ) AS "Cancelled Qty", -- OLNd calculation

    SUM( CASE
        WHEN OLN.FCDD_IND = 'Current' AND OLN.NEW_MATL_IND <> 'New Product'
            THEN OLN.TOT_CONFIRMED_QTY
        ELSE 0
    END ) AS "Current Month - Confirmed Qty",

    SUM( CASE
        WHEN OLN.NEW_MATL_IND = 'New Product'
            THEN ( CASE
                WHEN OLN.CANCELLED_QTY > 0
                    THEN OLN.ORDERED_QTY - OLN.CANCELLED_QTY
                ELSE OLN.ORDERED_QTY
            END )
        ELSE 0
    END ) AS "New Product Ordered Qty",

    SUM( CASE
        WHEN OLN.FRDD_IND = 'Future' AND OLN.NEW_MATL_IND <> 'New Product'
            THEN OLN.ORDERED_QTY
        ELSE 0
    END ) AS "RDD Future Month - Ordered Qty",

    ( "Total Ordered Qty" ) - ( "Cancelled Qty" + "New Product Ordered Qty" + "Current Month - Confirmed Qty" + "RDD Future Month - Ordered Qty" ) AS "No Supply Qty",

    OLN.QTY_UNIT_MEAS_ID AS "Quantity Unit of Measure"

FROM (

    SELECT
        OL.ORDER_ID,
        OL.ORDER_LINE_NBR,
        OL.SHIP_TO_CUST_ID,
        OL.OWN_CUST,
        OL.MATL_ID,
        OL.DESCR,
        OL.PBU_NBR,
        OL.PBU,
        OL.STK_CLASS_ID,
        OL.NEW_MATL_IND,
        OL.ORDER_DT,
        OL.FRDD,
        OL.FCDD,
        OL.FACILITY_ID,
        OL.FRDD_IND,
        OL.FCDD_IND,
        OL.FRDD_EQ_FCDD_IND,
        OL.CANCEL_IND,
        OL.ORDERED_QTY,
        OL.CANCELLED_QTY,
        OL.TOT_CONFIRMED_QTY,
        SUM( ZEROIFNULL( DDC.DELIV_QTY ) ) AS DELIV_QTY,
        OL.QTY_UNIT_MEAS_ID

    FROM (

    SELECT
        OD.ORDER_ID,
        OD.ORDER_LINE_NBR,

        OD.SHIP_TO_CUST_ID,
        CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS OWN_CUST,

        OD.MATL_ID,
        MATL.DESCR,
        MATL.PBU_NBR,
        MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
        CASE
            WHEN MATL.STK_CLASS_ID = 0
                THEN 'Replacement'
            WHEN MATL.STK_CLASS_ID = 1
                THEN 'OE'
            ELSE 'Uncategorized'
        END AS STK_CLASS_ID,

        -- CATEGORIZE BY NEW / OLD MATL
        CASE
            WHEN MATL.MATL_STA_ID = 'PD'
                THEN 'New Product'
            ELSE 'Established Product'
        END AS NEW_MATL_IND,

        OD.ORDER_DT,
        OD.FRST_RDD AS FRDD,
        OD.FRST_PROM_DELIV_DT AS FCDD,

        OD.FACILITY_ID,

        -- EVALUATE FRDD FOR CURRENT / FUTURE MONTH
        CASE
            WHEN CAST( OD.ORDER_DT / 100 AS INTEGER ) < CAST( FRDD / 100 AS INTEGER )
                THEN 'Future Month FRDD'
            ELSE 'Current Month FRDD'
        END AS FRDD_IND,
        -- EVALUATE FCDD FOR CURRENT / FUTURE MONTH
        CASE
            WHEN FCDD IS NULL
                THEN 'Unconfirmed'
            WHEN CAST( OD.ORDER_DT / 100 AS INTEGER ) < CAST( FCDD / 100 AS INTEGER )
                THEN 'Future Month FCDD'
            ELSE 'Current Month FCDD'
        END AS FCDD_IND,
        -- COMPARE FRDD AND FCDD FOR EQUIVALENCE
        CASE
            WHEN FRDD = FCDD
                THEN 'FRDD == FCDD'
            ELSE 'FRDD <> FCDD'
        END AS FRDD_EQ_FCDD_IND,

        MAX( CASE WHEN OD.CANCEL_IND = 'Y' THEN 1 ELSE 0 END ) OVER ( PARTITION BY OD.ORDER_ID, OD.ORDER_LINE_NBR, OD.EFF_DT ) AS CANCEL_IND,

        MAX( OD.ORDER_QTY ) OVER ( PARTITION BY OD.ORDER_ID, OD.ORDER_LINE_NBR, OD.EFF_DT ) AS ORDERED_QTY,
        MAX( CASE WHEN OD.CANCEL_IND = 'Y' THEN OD.ORDER_QTY ELSE 0 END ) OVER ( PARTITION BY OD.ORDER_ID, OD.ORDER_LINE_NBR, OD.EFF_DT ) AS CANCELLED_QTY,
        SUM( OD.CNFRM_QTY ) OVER ( PARTITION BY OD.ORDER_ID, OD.ORDER_LINE_NBR, OD.EFF_DT ) AS TOT_CONFIRMED_QTY,
        OD.QTY_UNIT_MEAS_ID

    FROM NA_BI_VWS.ORDER_DETAIL OD

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = OD.MATL_ID
            AND MATL.PBU_NBR = '01'
            AND MATL.EXT_MATL_GRP_ID = 'TIRE'

        INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
            ON CUST.SHIP_TO_CUST_ID = OD.SHIP_TO_CUST_ID
            AND CUST.CUST_GRP_ID <> '3R'

    WHERE
        OD.ORDER_DT >= DATE '2014-02-01'
        AND OD.ORDER_TYPE_ID <> 'ZLZ'
        AND OD.CUST_GRP_ID <> '3R'
        AND OD.PO_TYPE_ID <> 'RO'
        AND OD.RETURN_IND <> 'Y'

    QUALIFY
        ROW_NUMBER( ) OVER ( PARTITION BY OD.ORDER_ID, OD.ORDER_LINE_NBR ORDER BY OD.EFF_DT ASC ) = 1

        ) OL

        LEFT OUTER JOIN NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
            ON DDC.ORDER_ID = OL.ORDER_ID
            AND DDC.ORDER_LINE_NBR = OL.ORDER_LINE_NBR
            AND DDC.DELIV_QTY > 0

    GROUP BY
        OL.ORDER_ID,
        OL.ORDER_LINE_NBR,
        OL.SHIP_TO_CUST_ID,
        OL.OWN_CUST,
        OL.MATL_ID,
        OL.DESCR,
        OL.PBU_NBR,
        OL.PBU,
        OL.STK_CLASS_ID,
        OL.NEW_MATL_IND,
        OL.FACILITY_ID,
        OL.ORDER_DT,
        OL.FRDD,
        OL.FCDD,
        OL.FRDD_IND,
        OL.FCDD_IND,
        OL.FRDD_EQ_FCDD_IND,
        OL.CANCEL_IND,
        OL.ORDERED_QTY,
        OL.CANCELLED_QTY,
        OL.TOT_CONFIRMED_QTY,
        OL.QTY_UNIT_MEAS_ID

    ) OLN

GROUP BY
    OLN.OWN_CUST,
    OLN.MATL_ID,
    OLN.DESCR,
    OLN.PBU,
    OLN.STK_CLASS_ID,
    OLN.ORDER_DT,
    OLN.QTY_UNIT_MEAS_ID,
    OLN.FACILITY_ID

/*HAVING
    "RDD Future Month - Ordered Qty" > 0
    OR "No Supply Qty" > 0
    OR "Cancelled Qty" > 0*/

ORDER BY
    OLN.ORDER_DT,
    OLN.OWN_CUST,
    OLN.MATL_ID,
    OLN.FACILITY_ID