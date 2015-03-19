-- SQL last updated 2014-03-11
-- Fountain Tire report to aggregate Orders & Delivered Qty

SELECT
    OL.ORDER_MONTH AS "Order Month",
    OL.FOUNTAIN_RDD_MONTH AS "Fountain RDD Month",
    OL.FRDD_MONTH AS "FRDD Month",
    
    CUST.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.CUST_NAME AS "Ship To Cust Name",
    
    CUST.OWN_CUST_ID AS "Common Owner ID",
    CUST.OWN_CUST_NAME AS "Common Owner Name",
    
    MATL.MATL_ID AS "Material ID",
    MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS "Material",
    MATL.PBU_NBR AS "PBU Nbr",
    MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU,
    
    SUM( CASE
        WHEN OL.REJ_REAS_ID IS NULL OR ( OL.REJ_REAS_ID = 'Z2' AND OL.PO_TYPE_ID IN ( 'DT', 'WA', 'WC', 'WS' ) ) OR ( OL.REJ_REAS_ID IN ( 'Z6', 'ZW', 'ZX', 'ZY' ) ) 
            THEN ( CASE
                WHEN DL.DELIV_QTY > OL.ORDER_QTY
                    THEN DL.DELIV_QTY
                ELSE OL.ORDER_QTY
            END )
        ELSE ( CASE
            WHEN DL.DELIV_DT IS NULL
                THEN 0
            ELSE ( CASE
                WHEN DL.DELIV_QTY > OL.CNFRM_QTY
                    THEN DL.DELIV_QTY
                ELSE OL.CNFRM_QTY
            END )
        END )
    END ) AS "Adjusted Order Qty",
    SUM( OL.ORDER_QTY ) AS "Original Order Qty",
    SUM( OL.CNFRM_QTY ) AS "Confirmed Qty",
    SUM( ZEROIFNULL( DL.DELIV_QTY ) ) AS "Delivered Qty",
    OL.QTY_UNIT_MEAS_ID AS "Quantity Unit of Measure"

FROM ( 
            SELECT
                O.ORDER_ID,
                O.ORDER_LINE_NBR,
                O.MATL_ID,
                O.SHIP_TO_CUST_ID,
                O.ORDER_DT,
                O.ORDER_DT - ( EXTRACT( DAY FROM O.ORDER_DT ) - 1 ) AS ORDER_MONTH,
                O.FRST_RDD,
                O.FRST_RDD - ( EXTRACT( DAY FROM O.FRST_RDD ) - 1 ) AS FRDD_MONTH,
                CASE
                    WHEN CAST( COALESCE( O.CUST_RDD, O.FRST_RDD ) - O.ORDER_DT AS INTEGER ) < 14
                        THEN CAST( O.ORDER_DT + 14 AS DATE )
                    ELSE COALESCE( O.CUST_RDD, O.FRST_RDD )
                END AS FOUNTAIN_RDD,
                FOUNTAIN_RDD - ( EXTRACT( DAY FROM FOUNTAIN_RDD ) - 1 ) AS FOUNTAIN_RDD_MONTH,
                NULLIF( O.REJ_REAS_ID, ' ' ) AS REJ_REAS_ID,
                NULLIF( O.PO_TYPE_ID, ' ' ) AS PO_TYPE_ID,
                MAX( O.ORDER_QTY ) AS ORDER_QTY,
                SUM( O.CNFRM_QTY ) AS CNFRM_QTY,
                O.QTY_UNIT_MEAS_ID
                
            FROM NA_BI_VWS.ORDER_DETAIL_CURR O
                    
            WHERE
                O.ORDER_DT >= CAST( ( EXTRACT( YEAR FROM CURRENT_DATE ) - 2 ) || '-01-01' AS DATE )
                AND O.ORDER_TYPE_ID NOT IN ( 'ZLS', 'ZLZ' )
                AND O.ORDER_CAT_ID = 'C'
                AND O.RO_PO_TYPE_IND = 'N'
                AND O.CUST_GRP_ID <> '3R'
                AND O.SHIP_TO_CUST_ID IN (
                    SELECT
                        C.SHIP_TO_CUST_ID
                    FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C
                    WHERE
                        C.CUST_GRP_ID <> '3R'
                        AND C.OWN_CUST_ID = '00A0009337'
                    )
                AND O.MATL_ID IN ( 
                    SELECT
                        M.MATL_ID
                    FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                    WHERE
                        M.EXT_MATL_GRP_ID = 'TIRE'
                )        
                
            GROUP BY
                O.ORDER_ID,
                O.ORDER_LINE_NBR,
                O.ORDER_DT,
                ORDER_MONTH,
                O.FRST_RDD,
                FRDD_MONTH,
                FOUNTAIN_RDD,
                FOUNTAIN_RDD_MONTH,
                REJ_REAS_ID,
                PO_TYPE_ID,
                O.QTY_UNIT_MEAS_ID,
                O.MATL_ID,
                O.SHIP_TO_CUST_ID
    ) OL
    
    LEFT OUTER JOIN (
            SELECT
                D.ORDER_ID,
                D.ORDER_LINE_NBR,
                MAX( D.DELIV_DT ) AS DELIV_DT,
                MAX( DLVCAL.MONTH_DT ) AS DELIVERY_MONTH,
                SUM( D.DELIV_QTY ) AS DELIV_QTY,
                D.QTY_UNIT_MEAS_ID
            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR D
                INNER JOIN GDYR_BI_VWS.GDYR_CAL DLVCAL
                    ON DLVCAL.DAY_DATE = D.DELIV_DT
            WHERE
                D.DELIV_QTY > 0
                AND D.DELIV_DT >= CAST( ( EXTRACT( YEAR FROM CURRENT_DATE ) - 2 ) || '-01-01' AS DATE )
                AND D.SHIP_TO_CUST_ID IN ( SELECT C.SHIP_TO_CUST_ID FROM GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR C WHERE C.CUST_GRP_ID <> '3R' AND C.OWN_CUST_ID = '00A0009337' )
                AND D.MATL_ID IN ( SELECT M.MATL_ID FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M WHERE M.EXT_MATL_GRP_ID = 'TIRE' )
            GROUP BY
                D.ORDER_ID,
                D.ORDER_LINE_NBR,
                D.QTY_UNIT_MEAS_ID
    ) DL    
        ON DL.ORDER_ID = OL.ORDER_ID
        AND DL.ORDER_LINE_NBR = OL.ORDER_LINE_NBR

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = OL.MATL_ID
        AND MATL.EXT_MATL_GRP_ID = 'TIRE'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = OL.SHIP_TO_CUST_ID
        AND CUST.OWN_CUST_ID = '00A0009337'    

WHERE
    OL.ORDER_MONTH = ( SELECT MONTH_DT FROM GDYR_VWS.GDYR_CAL WHERE DAY_DATE = CURRENT_DATE )

GROUP BY
    OL.ORDER_MONTH,
    OL.FOUNTAIN_RDD_MONTH,
    OL.FRDD_MONTH,
    
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    CUST.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    
    MATL.MATL_ID,
    "Material",
    MATL.PBU_NBR,
    PBU,
    OL.QTY_UNIT_MEAS_ID

ORDER BY
    OL.ORDER_MONTH,
    OL.FRDD_MONTH,
    OL.FOUNTAIN_RDD_MONTH