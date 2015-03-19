SELECT
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    
    ODC.CUST_RDD,
    ODC.FRST_RDD,
    
    ODC.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    CUST.CUST_GRP_ID,
    CUST.CUST_GRP2_CD,
    SD.CUST_GRP_ID_2,
    ODC.PO_TYPE_ID,
    
    ODC.MATL_ID,
    MATL.DESCR,
    MATL.PBU_NBR,
    MATL.PBU_NAME

FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC

    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON SD.EXP_DT = DATE '5555-12-31'
        AND SD.SLS_DOC_ID = ODC.ORDER_ID
        AND SD.ORIG_SYS_ID = 2
        AND SD.SRC_SYS_ID = 2
        AND SD.SBU_ID = 2
        AND SD.CUST_GRP_ID_2 = 'TLB'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODC.SHIP_TO_CUST_ID
        --AND CUST.CUST_GRP2_CD = 'TLB'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODC.MATL_ID

WHERE
    ODC.ORDER_DT >= DATE '2012-01-01'
    AND ODC.CUST_RDD > ODC.FRST_RDD

GROUP BY
    ODC.ORDER_ID,
    ODC.ORDER_LINE_NBR,
    
    ODC.CUST_RDD,
    ODC.FRST_RDD,
    
    ODC.SHIP_TO_CUST_ID,
    CUST.CUST_NAME,
    CUST.OWN_CUST_ID,
    CUST.OWN_CUST_NAME,
    CUST.CUST_GRP_ID,
    CUST.CUST_GRP2_CD,
    SD.CUST_GRP_ID_2,
    ODC.PO_TYPE_ID,
    
    ODC.MATL_ID,
    MATL.DESCR,
    MATL.PBU_NBR,
    MATL.PBU_NAME