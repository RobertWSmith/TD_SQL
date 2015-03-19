SELECT
    CAL.DAY_DATE AS BUS_DT
    , M.PBU_NBR
    , M.MKT_AREA_NBR
    , M.MATL_ID
    , SOP.OFFCL_SOP_LAG0 / NULLIFZERO(CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(18,3))) AS SOP_LAG0
    , SOP.OFFCL_SOP_LAG2 / NULLIFZERO(CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(18,3))) AS SOP_LAG2
    , DP.DP_LAG0 / NULLIFZERO(CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(18,3))) AS DP_LAG0
    , DP.DP_LAG2 / NULLIFZERO(CAST(CAL.TTL_DAYS_IN_MNTH AS DECIMAL(18,3))) AS DP_LAG2
    , BU.QTY_UOM
    , BU.BILLED_UNIT_QTY
    , ORD.ORDER_QTY
    , ORD.RO_ORDER_QTY
    , ORD.CONFIRM_QTY
    , OO.OPEN_CONFIRMED_QTY
    , SA.SA_ORDER_QTY
    , SHIP.DELIVERY_QTY
    , IP.IN_PROC_QTY
    , FRDD.NO_STOCK_QTY
    , FRDD.CANCEL_QTY
    , FRDD.OTHER_NO_STOCK_QTY
    , FRDD.N602_NO_STOCK_QTY
    , FRDD.N623_NO_STOCK_QTY
    , FRDD.N636_NO_STOCK_QTY
    , FRDD.N637_NO_STOCK_QTY
    , FRDD.N639_NO_STOCK_QTY
    , FRDD.N699_NO_STOCK_QTY
    , FRDD.N6D3_NO_STOCK_QTY

FROM GDYR_BI_VWS.GDYR_CAL CAL

    INNER JOIN GDYR_VWS.MATL M
        ON CAL.DAY_DATE BETWEEN M.EFF_DT AND M.EXP_DT
        AND M.ORIG_SYS_ID = 2
        AND M.PBU_NBR IN ('01', '03', '04', '07')
        AND M.MATL_TYPE_ID IN ('ACCT', 'PCTL')

    LEFT OUTER JOIN (
            SELECT
                A.PERD_BEGIN_MTH_DT
                , A.MATL_ID
                , ZEROIFNULL(SUM(CASE WHEN A.DP_LAG_DESC = 'LAG 0' THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS OFFCL_SOP_LAG0
                , ZEROIFNULL(SUM(CASE WHEN A.DP_LAG_DESC = 'LAG 2' THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS OFFCL_SOP_LAG2

            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A
            
            WHERE
                A.DP_LAG_DESC IN ('LAG 0', 'LAG 2')
                AND A.PERD_BEGIN_MTH_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                        AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
                AND A.OFFCL_SOP_SLS_PLN_QTY > 0

            GROUP BY
                A.PERD_BEGIN_MTH_DT
                , A.MATL_ID
            ) SOP
        ON SOP.MATL_ID = M.MATL_ID
        AND SOP.PERD_BEGIN_MTH_DT = CAL.MONTH_DT
    
    LEFT OUTER JOIN (
                SELECT
                    A.PERD_BEGIN_MTH_DT
                    , A.MATL_ID
                    , ZEROIFNULL(SUM(CASE WHEN A.LAG_DESC = 0 THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS DP_LAG0
                    , ZEROIFNULL(SUM(CASE WHEN A.LAG_DESC = 2 THEN A.OFFCL_SOP_SLS_PLN_QTY END)) AS DP_LAG2

                FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A

                WHERE
                    A.LAG_DESC IN (0,2)
                    AND A.PERD_BEGIN_MTH_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                            AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
                    AND A.OFFCL_SOP_SLS_PLN_QTY > 0

                GROUP BY
                    A.PERD_BEGIN_MTH_DT
                    , A.MATL_ID
            ) DP
        ON DP.MATL_ID = M.MATL_ID
        AND DP.PERD_BEGIN_MTH_DT = CAL.MONTH_DT
        
    LEFT OUTER JOIN (
            SELECT
                SA.BILL_DT AS BUS_DT
                , SA.MATL_NO AS MATL_ID
                , SA.SLS_UOM AS QTY_UOM
                , SUM(SA.SLS_QTY) AS BILLED_UNIT_QTY
                
            FROM NA_VWS.SLS_AGG SA

            WHERE
                SA.BILL_REF_MTH_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
            
            GROUP BY
                SA.BILL_DT
                , SA.MATL_NO
                , SA.SLS_UOM
            ) BU
        ON BU.BILL_DT = CAL.DAY_DATE
        AND BU.MATL_ID = M.MATL_ID
    
    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID
                , ODC.FRST_RDD AS FRDD
                , SUM(CASE WHEN ODC.PO_TYPE_ID <> 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS ORDER_QTY
                , SUM(CASE WHEN ODC.PO_TYPE_ID = 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS RO_ORDER_QTY
                , SUM(ODC.CNFRM_QTY) AS CONFIRM_QTY
            
            FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
            
            WHERE
                ODC.ORDER_CAT_ID = 'C'
                AND (ODC.CANCEL_IND = 'N' OR ODC.REJ_REAS_ID = 'Z2')
                AND ODC.ORDER_QTY > 0
                AND ODC.FRST_RDD BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
            
            GROUP BY
                ODC.MATL_ID
                , ODC.FRST_RDD
            ) ORD
        ON ORD.MATL_ID = M.MATL_ID
        AND ORD.FRDD = CAL.DAY_DATE
    
    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID
                , ODC.PLN_DELIV_DT
                , SUM(OOSL.OPEN_CNFRM_QTY) AS OPEN_CONFIRMED_QTY
            
            FROM NA_BI_VWS.ORDER_DETAIL_CURR ODC
            
                INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
                    ON OOSL.ORDER_FISCAL_YR = ODC.ORDER_FISCAL_YR
                    AND OOSL.ORDER_ID = ODC.ORDER_ID 
                    AND OOSL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR 
                    AND OOSL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
            
            WHERE
                ODC.ORDER_CAT_ID = 'C'
                AND ODC.PO_TYPE_ID <> 'RO'
                AND OOSL.OPEN_CNFRM_QTY > 0
                AND ODC.PLN_DELIV_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
            
            GROUP BY
                ODC.MATL_ID
                , ODC.PLN_DELIV_DT
            )OO
        ON OO.MATL_ID = M.MATL_ID 
        AND OO.PLN_DELIV_DT = CAL.DAY_DATE

    LEFT OUTER JOIN (
            SELECT
                SDI.MATL_ID
                , SDSL.SCHD_LN_DELIV_DT AS FRDD
                , SUM(SDI.SLS_UNIT_CUM_ORD_QTY) AS SA_ORDER_QTY
            
            FROM GDYR_BI_VWS.NAT_SLS_DOC_CURR SD
            
                INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM_CURR SDI
                    ON SDI.SLS_DOC_ID = SD.SLS_DOC_ID
                
                INNER JOIN GDYR_BI_VWS.NAT_SLS_DOC_SCHD_LN_CURR SDSL
                    ON SDSL.SLS_DOC_ID = SDI.SLS_DOC_ID 
                    AND SDSL.SLS_DOC_ITM_ID = SDI.SLS_DOC_ITM_ID 
                    AND SDSL.SCHD_LN_ID = 1
            
            WHERE 
                SD.SD_DOC_CTGY_CD = 'E'
                AND SDI.REJ_REAS_ID IS NULL
                AND SDSL.SCHD_LN_DELIV_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
            
            GROUP BY
                SDI.MATL_ID
                , SDSL.SCHD_LN_DELIV_DT
            ) SA
        ON SA.MATL_ID = M.MATL_ID 
        AND SA.FRDD = CAL.DAY_DATE

    LEFT OUTER JOIN (
            
            SELECT
                DDC.MATL_ID
                , DDC.ACTL_GOODS_ISS_DT
                , SUM(DDC.DELIV_QTY) AS DELIVERY_QTY
            
            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
            
            WHERE  
                DDC.DELIV_QTY > 0
                AND DDC.DELIV_CAT_ID = 'J'
                AND DDC.RETURN_IND = 'N'
                AND DDC.DISTR_CHAN_CD <> '81'  --INTERNAL SHIPMENTS
                AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
                AND DDC.ACTL_GOODS_ISS_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)
                AND DDC.GOODS_ISS_IND = 'Y'
            
            GROUP BY
                DDC.MATL_ID
                , DDC.ACTL_GOODS_ISS_DT
                
            ) SHIP
        ON SHIP.MATL_ID = M.MATL_ID 
        AND SHIP.ACTL_GOODS_ISS_DT = CAL.DAY_DATE
    
    LEFT OUTER JOIN (
            SELECT
                DDC.MATL_ID
                , DDC.PLN_GOODS_MVT_DT
                , SUM(DDC.DELIV_QTY) AS IN_PROC_QTY
            
            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
            
            WHERE  
                DDC.DELIV_QTY > 0
                AND DDC.DELIV_CAT_ID = 'J'
                AND DDC.RETURN_IND = 'N'
                AND DDC.DISTR_CHAN_CD <> '81'  --INTERNAL SHIPMENTS
                AND DDC.GOODS_ISS_IND = 'N'
            
            GROUP BY
                DDC.MATL_ID
                , DDC.PLN_GOODS_MVT_DT
            ) IP
        ON IP.MATL_ID = M.MATL_ID 
        AND IP.PLN_GOODS_MVT_DT = CAL.DAY_DATE

    LEFT OUTER JOIN (
            SELECT
                POL.MATL_ID
                , POL.CMPL_DT
                , SUM(ZEROIFNULL(POL.IF_HIT_NS_QTY)) AS NO_STOCK_QTY
                , SUM(ZEROIFNULL(POL.IF_HIT_CO_QTY)) AS CANCEL_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS OTHER_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N602' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N602_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N623' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N623_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N636' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N636_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N637' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N637_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N639' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N639_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N699' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N699_NO_STOCK_QTY
                , SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N6D3' THEN ZEROIFNULL(POL.IF_HIT_NS_QTY) ELSE 0 END) AS N6D3_NO_STOCK_QTY
            
            FROM NA_BI_VWS.PRFCT_ORD_LINE POL
            
            WHERE 
                POL.CMPL_IND = 1 
                AND POL.CMPL_DT BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
                                AND (CURRENT_DATE-1)
                AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99
            
            GROUP BY
                POL.CMPL_DT
                , POL.MATL_ID
            ) FRDD
        ON FRDD.MATL_ID = M.MATL_ID 
        AND FRDD.CMPL_DT = CAL.DAY_DATE

WHERE
    CAL.DAY_DATE BETWEEN CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1)) || '-01-01' AS DATE)
        AND (CAST(EXTRACT(YEAR FROM (CURRENT_DATE-1))+1 || '-01-01' AS DATE) - 1)

ORDER BY
    CAL.DAY_DATE
    , M.PBU_NBR
    , M.MKT_AREA_NBR
    , M.MATL_ID

