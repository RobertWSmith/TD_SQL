WITH ON_TIME_DELIVERY (
    METRIC_TYPE
    , COMPLETE_MTH
    , PBU_NBR
    , PBU
    , CATEGORY
    , TIER
    , OWN_CUST_ID
    , OWN_CUST_NAME
    , TIRE_CUST_TYP_CD
    , SHIP_FACILITY_ID
    , SHIP_FACILITY
    , CUST_GRP2_CD
    , ORDER_QTY
    , HIT_QTY
    , ONTIME_QTY
    , RETURN_HIT_QTY
    , CLAIM_HIT_QTY
    , FREIGHT_POLICY_HIT_QTY
    , PHYS_LOG_HIT_QTY
    , MAN_BLK_HIT_QTY
    , CREDIT_HOLD_HIT_QTY
    , NO_STOCK_HIT_QTY
    , CANCEL_HIT_QTY
    , CUST_GEN_HIT_QTY
    , MAN_REL_CUST_GEN_HIT_QTY
    , MAN_REL_HIT_QTY
    , OTHER_HIT_QTY
    
    ) AS (
    

)




SELECT
    SMRY.METRIC_TYPE
    , SMRY.COMPLETE_MTH
    , SMRY.SHIP_FACILITY_ID
    , SMRY.SHIP_FACILITY
    , SMRY.PBU_NBR
    , SMRY.PBU
    , SMRY.CATEGORY
    , SMRY.TIER
    , SMRY.TIRE_CUST_TYP_CD
    , SMRY.OWN_CUST_ID
    , SMRY.OWN_CUST_NAME
    , SMRY.CUST_GRP2_CD
    , SMRY.ORDER_QTY
    , SMRY.HIT_QTY
    , SMRY.ONTIME_QTY
    , SMRY.PHYS_LOG_HIT_QTY
    , ZEROIFNULL(DD.DELIV_QTY) AS MTH_SHIP_QTY
    , ZEROIFNULL(SF.FORC_SKU_QTY) AS FORC_SKU_QTY
    , ZEROIFNULL(PL.YTD_LOC_PHYS_LOG_HIT_QTY) AS YTD_LOC_PHYS_LOG_HIT_QTY
    , CO.PHYS_LOG_HIT_QTY AS CO_MTD_PHYS_LOG_HIT_QTY
    , CO.MTD_OWN_CUST_RNK AS CO_MTD_OWN_CUST_RNK
    , CO.YTD_CO_LOC_PHYS_LOG_HIT_QTY
    , CO.YTD_OWN_CUST_RNK

FROM ON_TIME_DELIVERY SMRY
    
    INNER JOIN (
        SELECT
            SQ.METRIC_TYPE
            , SQ.COMPLETE_MTH
            , SQ.SHIP_FACILITY_ID
            , SQ.PBU_NBR
            , SUM(SQ.PHYS_LOG_HIT_QTY) OVER (PARTITION BY SQ.METRIC_TYPE, SQ.SHIP_FACILITY_ID, SQ.PBU_NBR ORDER BY SQ.COMPLETE_MTH ROWS UNBOUNDED PRECEDING) AS YTD_LOC_PHYS_LOG_HIT_QTY
        FROM (
            SELECT
                Q.METRIC_TYPE
                , Q.COMPLETE_MTH
                , Q.SHIP_FACILITY_ID
                , Q.PBU_NBR
                , SUM(Q.PHYS_LOG_HIT_QTY) AS PHYS_LOG_HIT_QTY
            FROM ON_TIME_DELIVERY Q
            GROUP BY
                Q.METRIC_TYPE
                , Q.COMPLETE_MTH
                , Q.SHIP_FACILITY_ID
                , Q.PBU_NBR
            ) SQ
        ) PL
        ON PL.METRIC_TYPE = SMRY.METRIC_TYPE
        AND PL.COMPLETE_MTH = SMRY.COMPLETE_MTH
        AND PL.SHIP_FACILITY_ID = SMRY.SHIP_FACILITY_ID
        AND PL.PBU_NBR = SMRY.PBU_NBR
    
    INNER JOIN (
        SELECT
            C.METRIC_TYPE
            , C.COMPLETE_MTH
            , C.SHIP_FACILITY_ID
            , C.OWN_CUST_ID
            , C.PBU_NBR
            , C.PHYS_LOG_HIT_QTY
            , ROW_NUMBER() OVER (PARTITION BY C.COMPLETE_MTH, C.METRIC_TYPE, C.SHIP_FACILITY_ID, C.PBU_NBR ORDER BY C.PHYS_LOG_HIT_QTY DESC) AS MTD_OWN_CUST_RNK
            , C.YTD_CO_LOC_PHYS_LOG_HIT_QTY
            , ROW_NUMBER() OVER (PARTITION BY C.COMPLETE_MTH, C.METRIC_TYPE, C.SHIP_FACILITY_ID, C.PBU_NBR ORDER BY C.YTD_CO_LOC_PHYS_LOG_HIT_QTY DESC) AS YTD_OWN_CUST_RNK
        FROM (
            SELECT
                SQ.METRIC_TYPE
                , SQ.COMPLETE_MTH
                , SQ.SHIP_FACILITY_ID
                , SQ.OWN_CUST_ID
                , SQ.PBU_NBR
                , SQ.PHYS_LOG_HIT_QTY
                , SUM(SQ.PHYS_LOG_HIT_QTY) OVER (PARTITION BY SQ.METRIC_TYPE, SQ.SHIP_FACILITY_ID, SQ.PBU_NBR, SQ.OWN_CUST_ID ORDER BY SQ.COMPLETE_MTH ROWS UNBOUNDED PRECEDING) AS YTD_CO_LOC_PHYS_LOG_HIT_QTY
            FROM (
                SELECT
                    Q.METRIC_TYPE
                    , Q.COMPLETE_MTH
                    , Q.SHIP_FACILITY_ID
                    , Q.OWN_CUST_ID
                    , Q.PBU_NBR
                    , SUM(Q.PHYS_LOG_HIT_QTY) AS PHYS_LOG_HIT_QTY
                FROM ON_TIME_DELIVERY Q
                GROUP BY
                    Q.METRIC_TYPE
                    , Q.COMPLETE_MTH
                    , Q.SHIP_FACILITY_ID
                    , Q.OWN_CUST_ID
                    , Q.PBU_NBR
                ) SQ
            ) C
        ) CO
        ON CO.METRIC_TYPE = SMRY.METRIC_TYPE
        AND CO.COMPLETE_MTH = SMRY.COMPLETE_MTH
        AND CO.SHIP_FACILITY_ID = SMRY.SHIP_FACILITY_ID
        AND CO.PBU_NBR = SMRY.PBU_NBR
        AND CO.OWN_CUST_ID = SMRY.OWN_CUST_ID
    
    LEFT OUTER JOIN (
            SELECT
                DDC.DELIV_LINE_FACILITY_ID
                , MATL.PBU_NBR
                , CAL.MONTH_DT
                , SUM(DDC.DELIV_QTY) AS DELIV_QTY

            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
            
                INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
                    ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT
                
                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
                    ON MATL.MATL_ID = DDC.MATL_ID
                    AND MATL.PBU_NBR IN ('01', '03')
                    AND MATL.EXT_MATL_GRP_ID = 'TIRE'
                
            WHERE
                DDC.DELIV_CAT_ID = 'J'
                AND DDC.DISTR_CHAN_CD <> '81'
                AND DDC.DELIV_QTY > 0
                AND DDC.GOODS_ISS_IND = 'Y'
                AND DDC.ACTL_GOODS_ISS_DT BETWEEN 
                    ADD_MONTHS((CURRENT_DATE-1), -6) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -6)) - 1) 
                    AND CURRENT_DATE-1

            GROUP BY
                DDC.DELIV_LINE_FACILITY_ID
                , MATL.PBU_NBR
                , CAL.MONTH_DT
            ) DD
        ON DD.DELIV_LINE_FACILITY_ID = SMRY.SHIP_FACILITY_ID
        AND DD.PBU_NBR = SMRY.PBU_NBR
        AND DD.MONTH_DT = SMRY.COMPLETE_MTH
    
    LEFT OUTER JOIN (
            SELECT
                SKU.FACILITY_ID
                , MATL.PBU_NBR
                , SKU.FORC_MTH_DT
                , SUM(SKU.FORC_SKU_QTY) AS FORC_SKU_QTY

            FROM GDYR_VWS.SKU_FORC SKU

                INNER JOIN GDYR_BI_vWS.NAT_MATL_CURR MATL
                    ON MATL.MATL_ID = SKU.MATL_ID
                    AND MATL.PBU_NBR IN ('01', '03')
                    AND MATL.EXT_MATL_GRP_ID = 'TIRE'

            WHERE
                SKU.FORC_MTH_DT BETWEEN SKU.EFF_DT AND SKU.EXP_DT
                AND SKU.SBU_ID = 2
                AND SKU.FORC_MTH_DT BETWEEN 
                    ADD_MONTHS((CURRENT_DATE-1), -6) - (EXTRACT(DAY FROM ADD_MONTHS((CURRENT_DATE-1), -6)) - 1)
                    AND CURRENT_DATE-1

            GROUP BY
                SKU.FACILITY_ID
                , MATL.PBU_NBR
                , SKU.FORC_MTH_DT
            ) SF
        ON SF.FACILITY_ID = SMRY.SHIP_FACILITY_ID
        AND SF.PBU_NBR = SMRY.PBU_NBR
        AND SF.FORC_MTH_DT = SMRY.COMPLETE_MTH
