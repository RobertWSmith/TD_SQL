SELECT
    Q.MSTR_BOL AS "Master BOL",
    Q.SHIP_DT AS "Ship Date",
    Q.DELIV_DATE AS "Delivery Date",
    Q.CUST_GRP2_CD AS "Customer Group 2 Code",
    Q.SHIP_TO_CUST_ID AS "Ship To Customer ID",
    CUST.CUST_NAME AS "Ship To Customer Name",
    CUST.OWN_CUST_ID AS "Common Owner ID",
    CUST.OWN_CUST_NAME AS "Common Owner Name",
    Q.DELIV_LINE_FACILITY_ID AS "Delivery Line Facility ID",
/*    Q.PBU_NBR,
    Q.PBU_NAME,*/
    COUNT( DISTINCT Q.MATL_ID ) AS "Unq. Material ID Count",
    Q.VOL_UOM AS "Volume UOM",
    SUM( Q.VOL ) AS "Volume",
    SUM( Q.COMPRESSED_VOL ) AS "Compressed Volume",
    Q.WT_UOM AS "Weight UOM",
    SUM( Q.NET_WT ) AS "Net Weight",
    SUM( Q.GROSS_WT ) AS "Gross Weight",
    Q.QTY_UOM AS "Quantity UOM",
    SUM( Q.DELIV_QTY ) AS "Delivered Qty"

FROM (

    SELECT
        DDC.FISCAL_YR,
        DDC.DELIV_ID,
        DDC.DELIV_LINE_NBR,

        DDC.SHIP_TO_CUST_ID,
        DDC.CUST_GRP_ID,
        COALESCE(DDC.CUST_GRP2_CD, 'INT' ) AS CUST_GRP2_CD,

        DDC.MATL_ID,
/*        MATL.PBU_NBR,
        MATL.PBU_NAME,*/

        NULLIF( DDC.DELIV_LINE_FACILITY_ID, '' ) AS DELIV_LINE_FACILITY_ID,

        SUM( ZEROIFNULL( DDC.DELIV_QTY ) ) AS DELIV_QTY,
        DDC.QTY_UNIT_MEAS_ID AS QTY_UOM,

        SUM( ZEROIFNULL( DDC.VOL ) ) AS VOL,
        SUM( ZEROIFNULL( DDC.VOL ) *  CAST( CASE MATL.PBU_NBR || MATL.MKT_AREA_NBR
            WHEN '0101'
                THEN 0.75
            WHEN '0108'
                THEN 0.80
            WHEN '0305'
                THEN 1.20
            WHEN '0314'
                THEN 1.20
            ELSE 1
        END AS DECIMAL(15,3) ) ) AS COMPRESSED_VOL,
        DDC.VOL_UNIT_MEAS_ID AS VOL_UOM,
        SUM( ZEROIFNULL( DDC.NET_WT ) ) AS NET_WT,
        SUM( ZEROIFNULL( DDC.GROSS_WT ) ) AS GROSS_WT,
        DDC.WT_UNIT_MEAS_ID AS WT_UOM,

        FPS.MSTR_BOL,
        --FPC.SHIP_TS,
        CAST( FPC.SHIP_TS AS DATE ) AS SHIP_DT,
        --FPC.DELIV_TS,
        CAST( FPC.DELIV_TS AS DATE ) AS DELIV_DATE

    FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
            ON MATL.MATL_ID = DDC.MATL_ID
            AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        INNER JOIN GDYR_BI_VWS.FP_SHP_ORD_LN_CST_CURR FPS
            ON FPS.ORD_ID = DDC.DELIV_ID
            AND FPS.MATL_ID = DDC.MATL_ID

        INNER JOIN GDYR_BI_VWS.FP_SHP_CURR FPC
            ON FPC.MSTR_BOL = FPS.MSTR_BOL
            AND CAST( FPC.DELIV_TS AS DATE ) BETWEEN DATE '2014-01-01' AND ( CURRENT_DATE - 1 )

    WHERE
        DDC.DELIV_QTY > 0
        AND DDC.DELIV_DT < CURRENT_DATE
        AND NULLIF( DDC.SHIP_COND_ID, '' ) IS NOT NULL
        AND NULLIF( DDC.SHIP_COND_ID, '' ) <> 'EG'
        AND DDC.DELIV_DT >= CAST( '2013-09-01' AS DATE )
        -- AND DDC.CUST_GRP2_CD = 'TLB'

    GROUP BY
        DDC.FISCAL_YR,
        DDC.DELIV_ID,
        DDC.DELIV_LINE_NBR,

        DDC.SHIP_TO_CUST_ID,
        DDC.CUST_GRP_ID,
        DDC.CUST_GRP2_CD,

        DDC.MATL_ID,
/*        MATL.PBU_NBR,
        MATL.PBU_NAME,*/

        DELIV_LINE_FACILITY_ID,

        DDC.QTY_UNIT_MEAS_ID,

        VOL_UOM,
        WT_UOM,

        FPS.MSTR_BOL,
        SHIP_DT,
        DELIV_DATE

    ) Q

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = Q.SHIP_TO_CUST_ID

GROUP BY
    Q.MSTR_BOL,
    Q.CUST_GRP2_CD,
    Q.SHIP_DT,
    Q.DELIV_DATE,
    Q.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    Q.DELIV_LINE_FACILITY_ID,
    Q.VOL_UOM,
    Q.WT_UOM,
    Q.QTY_UOM