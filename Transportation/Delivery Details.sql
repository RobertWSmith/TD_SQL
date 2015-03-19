SELECT
    DDC.FISCAL_YR AS DELIV_FISCAL_YR
    , DDC.BILL_LADING_ID
    , DDC.DELIV_ID
    , DDC.DELIV_LINE_NBR
    
    , DDC.ORDER_FISCAL_YR
    , DDC.ORDER_ID
    , DDC.ORDER_LINE_NBR
    
    , DDC.DIV_CD
    , DDC.SALES_ORG_CD
    , DDC.DISTR_CHAN_CD
    , DDC.CUST_GRP_ID
    , DDC.CUST_GRP2_CD
    , DDC.SHIP_TO_CUST_ID
    
    , DDC.DELIV_LINE_FACILITY_ID AS FACILITY_ID
    , DDC.SHIP_PT_ID
    , DDC.SHIP_COND_ID
    
    , DDC.QTY_UNIT_MEAS_ID AS QTY_UOM
    , DDC.DELIV_QTY
    
    , DDC.WT_UNIT_MEAS_ID AS WT_UOM
    , DDC.GROSS_WT
    , DDC.NET_WT
    
    , COALESCE(NULLIF(DDC.VOL_UNIT_MEAS_ID, ''), 'FT3') AS VOL_UOM
    , DDC.VOL
    
    , DDC.DELIV_NOTE_CREA_DT
    , DDC.DELIV_LINE_CREA_DT
    
    , DDC.PLN_GOODS_MVT_DT
    , DDC.ACTL_GOODS_ISS_DT
    , DDC.DELIV_DT
    
    , DDC.DELIV_CAT_ID
    , DDC.DELIV_TYPE_ID
    
    , DDC.DELIV_PRTY_ID AS DELIV_PRTY_ID
    , DDC.RTG_ID AS ROUTE_ID
    , DDC.TERMS_ID AS INCOTERMS_CD
    , DDC.UNLD_PT_CD
    , DDC.SPCL_PROC_ID
    , DDC.SRC_CRT_USR_ID
    , DDC.GOODS_ISS_IND
    
FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

WHERE
    DDC.FISCAL_YR >= CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) - 1 AS CHAR(4))
    
    -- Stats collected columns, want to 
    AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
    AND DDC.GOODS_ISS_IND = 'Y'
    
    -- Rolling ~ 3 months by Planned Goods Movement Date
    AND DDC.ACTL_GOODS_ISS_DT >= ADD_MONTHS((CURRENT_DATE-1), -3) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -3)) - 1)
    
    -- Core LC's only -- exclude from factory
    AND DDC.DELIV_LINE_FACILITY_ID IN  ('N602', 'N607', 'N623', 'N636', 'N637', 'N639', 'N699', 'N6D3')
    
    -- Standard deliveries, excluding returns
    AND DDC.DELIV_CAT_ID = 'J'
    
    -- Exclude unneccessary lines
    AND DDC.DELIV_QTY > 0
        
    -- Goodyear US, Canada & GDTNA main Sales Orgs
    AND DDC.SALES_ORG_CD IN (
            'N301', 'N302', 'N303', 
            'N311', 'N312', 'N313', 
            'N321', 'N322', 'N323'
        )
    
    -- Only certain DC's are active within these sales orgs -- trying to hit the db stats
    AND DDC.DISTR_CHAN_CD IN (
            '01', '03', '04', '05', '06', '07', '08', '09'
            , '10', '11', '12', '14', '15', '16'
            , '20', '21', '22'
            , '30', '31', '32'
        )
        
ORDER BY
    DDC.FISCAL_YR AS DELIV_FISCAL_YR
    , DDC.DELIV_ID
    , DDC.DELIV_LINE_NBR