SELECT
    C.ORDER_ID AS "Order ID",
    C.CUST_GRP_ID AS "Customer Group ID",
    C.CUST_GRP2_CD AS "Customer Group 2 Code",
    C.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.OWN_CUST_ID AS "Common Owner ID",
    CUST.OWN_CUST_NAME AS "Common Owner Name",
    CUST.SALES_ORG_CD AS  "Sales Org Code",
    C.MATL_ID AS "Material ID",
    MATL.EXT_MATL_GRP_ID AS "External Material Group ID",
    MATL.DESCR AS "Material Description",
    MATL.PBU_NBR AS "PBU Nbr"
    MATL.PBU_NAME AS "PBU Name",
    C.ORDER_DT AS "Order Create Date",
    C.ORDER_LINE_CNT AS "Current Order Line Count",
    ZEROIFNULL( F.ORDER_LINE_CNT ) AS "Order Create Date Line Count",
    CAST( C.ORDER_QTY AS INTEGER ) AS "Current Order Qty",
    CAST( ZEROIFNULL( F.ORDER_QTY ) AS  INTEGER ) AS "Order Create Date Order Qty",
    "Current Order Qty" - "Order Create Date Order Qty" AS "Current - Original Order Qty",
    C.QTY_UOM AS "Quantity UOM"

FROM (

        SELECT
            ODC.ORDER_ID,
            ODC.MATL_ID,
            ODC.SHIP_TO_CUST_ID,

            ODC.ORDER_DT,
            ODC.CUST_GRP_ID,
            ODC.CUST_GRP2_CD,

            COUNT( DISTINCT ODC.ORDER_LINE_NBR ) AS ORDER_LINE_CNT,
            SUM( ODC.ORDER_QTY ) AS ORDER_QTY,
            ODC.QTY_UNIT_MEAS_ID AS QTY_UOM

        FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

        WHERE
            ( ODC.ORDER_ID, ODC.MATL_ID ) IN (
                SELECT
                    ODC.ORDER_ID,
                    ODC.MATL_ID

                FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

                    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOS
                        ON OOS.ORDER_ID = ODC.ORDER_ID
                        AND OOS.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
                        AND OOS.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR

                WHERE
                    ODC.ORDER_CAT_ID = 'C'
                    AND ODC.PO_TYPE_ID <> 'RO'
                    AND ODC.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
                    AND ODC.SALES_ORG_CD NOT IN ( 'N302', 'N303', 'N312', 'N322' )

                GROUP BY
                    ODC.ORDER_ID,
                    ODC.MATL_ID
                )

        GROUP BY
            ODC.ORDER_ID,
            ODC.MATL_ID,
            ODC.SHIP_TO_CUST_ID,
            ODC.CUST_GRP_ID,
            ODC.CUST_GRP2_CD,
            ODC.ORDER_DT,
            ODC.QTY_UNIT_MEAS_ID

    ) C

LEFT OUTER JOIN (

        SELECT
            OD.ORDER_ID,
            OD.MATL_ID,
            OD.SHIP_TO_CUST_ID,

            COUNT( DISTINCT OD.ORDER_LINE_NBR ) AS ORDER_LINE_CNT,
            SUM( OD.ORDER_QTY ) AS ORDER_QTY

        FROM NA_BI_VWS.ORDER_DETAIL OD

        WHERE
            OD.ORDER_DT BETWEEN OD.EFF_DT AND OD.EXP_DT
            AND ( OD.ORDER_ID, OD.MATL_ID ) IN (
                SELECT
                    ODC.ORDER_ID,
                    ODC.MATL_ID

                FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

                    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOS
                        ON OOS.ORDER_ID = ODC.ORDER_ID
                        AND OOS.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
                        AND OOS.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR

                WHERE
                    ODC.ORDER_CAT_ID = 'C'
                    AND ODC.PO_TYPE_ID <> 'RO'
                    AND ODC.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
                    AND ODC.SALES_ORG_CD NOT IN ( 'N302', 'N303', 'N312', 'N322' )

                GROUP BY
                    ODC.ORDER_ID,
                    ODC.MATL_ID
                )

        GROUP BY
            OD.ORDER_ID,
            OD.MATL_ID,
            OD.SHIP_TO_CUST_ID

    ) F
    ON F.ORDER_ID = C.ORDER_ID
    AND F.MATL_ID = C.MATL_ID
    AND F.ORDER_QTY <> C.ORDER_QTY

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = C.SHIP_TO_CUST_ID
        AND CUST.SALES_ORG_CD NOT IN ( 'N302', 'N312', 'N322' )

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = C.MATL_ID
        AND MATL.PBU_NBR IN ( '01', '03' )
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

WHERE
    ( C.ORDER_QTY - ZEROIFNULL( F.ORDER_QTY ) ) > 0
    AND F.MATL_ID IS NULL

ORDER BY
    C.ORDER_ID,
    C.MATL_ID
