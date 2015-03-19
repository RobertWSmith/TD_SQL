SELECT
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    ODC.SCHED_LINE_NBR,
    
    ODC.SHIP_TO_CUST_ID,
    CUST.CUST_NAME AS SHIP_TO_CUST_NAME,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    ODC.SALES_ORG_CD,
    ODC.DISTR_CHAN_CD,
    ODC.CUST_GRP_ID,
    ODC.CUST_GRP2_CD,
    
    ODC.DELIV_GRP_CD,
    ODC.DELIV_PRTY_ID,
    
    ODC.MATL_ID,
    CAST(CASE MATL.PBU_NBR || MATL.MKT_AREA_NBR
        WHEN '0101'
            THEN 0.75
        WHEN '0108'
            THEN 0.80
        WHEN '0305'
            THEN 1.20
        WHEN '0314'
            THEN 1.20
        ELSE 1
    END AS DECIMAL(15,3)) AS COMPRESSION_FACTOR,
    
    ODC.PLN_DELIV_DT,
    
    ZEROIFNULL(OOL.OPEN_CNFRM_QTY) AS OPEN_CNFRM_QTY,
    ODC.QTY_UNIT_MEAS_ID,
    ZEROIFNULL(OOL.OPEN_CNFRM_QTY) * MATL.UNIT_WT AS OPEN_WT,
    ODC.WT_UNITS_MEAS_ID,
    ZEROIFNULL(OOL.OPEN_CNFRM_QTY) * (MATL.UNIT_VOL * COMPRESSION_FACTOR) AS OPEN_VOL,
    ODC.VOL_UNIT_MEAS_ID

FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
    
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03')

    INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOL
        ON OOL.ORDER_ID = ODC.ORDER_ID
        AND OOL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR
        AND OOL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
        AND OOL.OPEN_CNFRM_QTY > 0

WHERE
    ODC.ORDER_DT >= DATE '2014-02-01'
    AND ODC.ORDER_CAT_ID = 'C'
    AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
    AND ODC.PO_TYPE_ID <> 'RO'
    AND ODC.CUST_GRP2_CD = 'TLB'

ORDER BY
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    ODC.SCHED_LINE_NBR