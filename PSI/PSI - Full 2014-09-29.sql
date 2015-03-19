SELECT
    MM.PBU_NBR AS "PBU",
    MH.TIC_CD AS "TIC",
    CAST(MM.MATL_ID AS INTEGER) AS "Material",
    MH.DESCR AS "Material Desc",
    MM.MATL_STA_ID AS "Status",
    CAST(MM.STK_CLASS_ID AS INTEGER) AS "C/S",
    MH.HMC_TXT AS "HMC/LMC",
    GC.CAL_YR AS "Year",
    GC.CAL_MTH AS "Month",
    MH.MKT_CTGY_MKT_AREA_NAME AS "Category",
    MH.TIERS AS "Tier",
    MTI.SRC_FACILITY_ID AS "Source",
    MTI.LVL_GRP_ID AS "Work Center",
    CAST (MM.MATL_PRTY AS INTEGER) AS "Priority",
    CAST(CASE
        WHEN MTI.SRC_FACILITY_CNT IS NULL OR MTI.SRC_FACILITY_CNT < 2
            THEN 1
        ELSE CASE
            WHEN MTI.PROD_CREDIT_PCT IS NULL AND ZEROIFNULL(MTI.TOT_PROD_CREDIT_QTY) = 0
                THEN 1/CAST (MTI.SRC_FACILITY_CNT AS DECIMAL(15,3))
            ELSE CAST (ZEROIFNULL(MTI.PROD_CREDIT_PCT) AS DECIMAL(15,3))
        END
    END AS DECIMAL(15,3)) AS PROD_MULTIPLIER,
    ZEROIFNULL(POLG.NO_STOCK_QTY) * PROD_MULTIPLIER  AS "No Stock Qty",
    ZEROIFNULL(POLG.N602_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N602 NS Qty",
    ZEROIFNULL(POLG.N623_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N623 NS Qty",
    ZEROIFNULL(POLG.N636_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N636 NS Qty",
    ZEROIFNULL(POLG.N637_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N637 NS Qty",
    ZEROIFNULL(POLG.N639_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N639 NS Qty",
    ZEROIFNULL(POLG.N699_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N699 NS Qty",
    ZEROIFNULL(POLG.N6D3_NO_STOCK_QTY)*PROD_MULTIPLIER AS "N6D3 NS Qty",
    ZEROIFNULL(POLG.OTHER_NO_STOCK_QTY)*PROD_MULTIPLIER AS "Other NS Qty",
    ZEROIFNULL(POLG.CANCEL_QTY)*PROD_MULTIPLIER AS "Can Qty",
    ZEROIFNULL(ODCG.ORDER_QTY) * PROD_MULTIPLIER AS "Order Qty",
    ZEROIFNULL(SA.ORDER_QTY) * PROD_MULTIPLIER AS "SA Order Qty",
    ZEROIFNULL(ODCG.RO_ORDER_QTY) * PROD_MULTIPLIER AS "RO Order Qty",
    ZEROIFNULL(DDCG.DELIVERY_QTY) * PROD_MULTIPLIER AS "Ship Qty",
    CASE
        WHEN SP.OFFCL_SOP_LAG0 IS NULL
            THEN ZEROIFNULL(SPB.LAG0_QTY) * PROD_MULTIPLIER
        ELSE ZEROIFNULL(SP.OFFCL_SOP_LAG0) * PROD_MULTIPLIER
    END AS "Sales Plan Lag0",
    CASE
        WHEN SP.OFFCL_SOP_LAG2 IS NULL
            THEN ZEROIFNULL(SPB.LAG2_QTY) * PROD_MULTIPLIER
        ELSE ZEROIFNULL(SP.OFFCL_SOP_LAG2) * PROD_MULTIPLIER
    END AS "Sales Plan Lag2",
    ZEROIFNULL(INVE.FACT_END_INV) * PROD_MULTIPLIER AS "Fact End Inv",
    CASE
        WHEN GC.MONTH_DT / 100 >= (CURRENT_DATE-1) / 100 AND MTI.SRC_FACILITY_ID IS NOT NULL
            THEN ZEROIFNULL(FCST_INV_PROJ)
        ELSE ZEROIFNULL(INVE.LC_END_INV)
    END * PROD_MULTIPLIER  AS "LC End Inv",
    ZEROIFNULL(INVE.OTHER_END_INV) * PROD_MULTIPLIER AS "Other End Inv",
    ZEROIFNULL(INVE.N602_END_INV) * PROD_MULTIPLIER AS "N602 End Inv",
    ZEROIFNULL(INVE.N623_END_INV) * PROD_MULTIPLIER AS "N623 End Inv",
    ZEROIFNULL(INVE.N636_END_INV) * PROD_MULTIPLIER AS "N636 End Inv",
    ZEROIFNULL(INVE.N637_END_INV) * PROD_MULTIPLIER AS "N637 End Inv",
    ZEROIFNULL(INVE.N639_END_INV) * PROD_MULTIPLIER AS "N639 End Inv",
    ZEROIFNULL(INVE.N699_END_INV) * PROD_MULTIPLIER AS "N699 End Inv",
    ZEROIFNULL(INVE.N6D3_END_INV) * PROD_MULTIPLIER AS "N6D3 End Inv",
    
    ZEROIFNULL(N602_DSI) AS "N602 Est. DSI",
    ZEROIFNULL(N623_DSI) AS "N623 Est. DSI",
    ZEROIFNULL(N636_DSI) AS "N636 Est. DSI",
    ZEROIFNULL(N637_DSI) AS "N637 Est. DSI",
    ZEROIFNULL(N639_DSI) AS "N639 Est. DSI",
    ZEROIFNULL(N699_DSI) AS "N699 Est. DSI",
    ZEROIFNULL(N6D3_DSI) AS "N6D3 Est. DSI",
    
    ZEROIFNULL(INV.MIN_INV) * PROD_MULTIPLIER AS "Min Inv",
    ZEROIFNULL(INV.MAX_INV) * PROD_MULTIPLIER AS "Max Inv",
    ZEROIFNULL(INV.MIN_INV + ((INV.MAX_INV - INV.MIN_INV)/2)) * PROD_MULTIPLIER AS "Target Inv",
    ZEROIFNULL(BU.UNITS) * PROD_MULTIPLIER AS "Billed Units",
    ZEROIFNULL(BU.COLLECTIBLES) * PROD_MULTIPLIER AS "Collect Sales",
    ZEROIFNULL(BU.COLL_STD_MARGIN) * PROD_MULTIPLIER AS "Collect Margin",
    ZEROIFNULL(MTI.PROD_CREDIT_QTY) AS "Prod Credit",
    ZEROIFNULL(MTI.PROD_PLAN_QTY) AS "Prod Plan Lag0",
    CASE
        WHEN GC.DAY_DATE/100 = (CURRENT_DATE-1)/100
            THEN 1 - (CAST(EXTRACT(DAY FROM (CURRENT_DATE-1)) AS DECIMAL(15,3)) / CAST(GC.TTL_DAYS_IN_MNTH AS DECIMAL(15,3)))
        ELSE 1.000
    END AS CURR_MTH_BALANCE,
    CASE
        WHEN "Open Cnfm Qty" > "Sales Plan Lag2" AND "Open Cnfm Qty" > "Order Qty"
            THEN "Open Cnfm Qty"
        WHEN "Order Qty" > "Sales Plan Lag2"
            THEN "Order Qty"
        ELSE "Sales Plan Lag2"
    END AS SP_VS_ORD_QTY,
    CASE -- in current month, add current gross_inv
        WHEN GC.DAY_DATE/100 = (CURRENT_DATE-1)/100
            THEN ( CURR_MTH_BALANCE * (ZEROIFNULL(MTI.PROD_PLAN_QTY) - SP_VS_ORD_QTY) ) + INVC.GROSS_INV
        -- future months use this from the cumulative sum operation
        WHEN GC.DAY_DATE/100 > (CURRENT_DATE-1)/100
            THEN CURR_MTH_BALANCE * (ZEROIFNULL(MTI.PROD_PLAN_QTY) - SP_VS_ORD_QTY)
        ELSE 0.000
    END AS INV_QTY_DELTA,
    -- cumulative sum OLAP function -- rows unbounded preceding tells the database to only look at dates before the gc.day_date
    SUM(INV_QTY_DELTA) OVER (PARTITION BY MM.MATL_ID ORDER BY GC.DAY_DATE ROWS UNBOUNDED PRECEDING) AS FCST_INV_PROJ,
    
    "Order Qty" + "SA Order Qty" + "RO Order Qty" AS "Ord+SA+RO",
    ZEROIFNULL(OO.OPEN_CONFIRM_QTY) * PROD_MULTIPLIER AS "Open Cnfm Qty",
    GC.BEGIN_DT AS "Rec Date"

FROM GDYR_VWS.GDYR_CAL GC

    INNER JOIN GDYR_VWS.MATL MM
        ON GC.DAY_DATE BETWEEN MM.EFF_DT AND MM.EXP_DT
        AND MM.EXP_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
        AND MM.EXT_MATL_GRP_ID = 'TIRE'
        AND MM.PBU_NBR IN ('01','03')

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
        ON MH.MATL_ID = MM.MATL_ID
        AND MH.PBU_NBR IN ('01','03')
        AND MH.EXT_MATL_GRP_ID = 'TIRE'

    LEFT OUTER JOIN (
            SELECT
                EXTRACT (YEAR FROM A.PERD_BEGIN_MTH_DT) AS SP_YEAR,
                EXTRACT (MONTH FROM A.PERD_BEGIN_MTH_DT) AS SP_MONTH,
                A.MATL_ID,
                SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 0') THEN A.OFFCL_SOP_SLS_PLN_QTY END) AS OFFCL_SOP_LAG0,
                SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 2') THEN A.OFFCL_SOP_SLS_PLN_QTY END) AS OFFCL_SOP_LAG2
            
            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A
            
                LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                    ON M.MATL_ID = A.MATL_ID
            
            WHERE
                M.PBU_NBR IN ('01', '03')
                AND M.EXT_MATL_GRP_ID = 'TIRE'
                AND A.DP_LAG_DESC IN ('LAG 0','LAG 2')
                AND A.PERD_BEGIN_MTH_DT BETWEEN CURRENT_DATE AND CURRENT_DATE+180
            
            GROUP BY
                A.MATL_ID,
                SP_YEAR,
                SP_MONTH
            ) SP
        ON SP.MATL_ID = MM.MATL_ID 
        AND SP.SP_YEAR = GC.CAL_YR 
        AND SP.SP_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                EXTRACT (YEAR FROM SP.PERD_BEGIN_MTH_DT) AS SP_YEAR,
                EXTRACT (MONTH FROM SP.PERD_BEGIN_MTH_DT) AS SP_MONTH,
                CAST (SP.MATL_ID AS INTEGER) AS MATL_ID,
                SUM(CASE WHEN SP.LAG_DESC = 0 THEN SP.OFFCL_SOP_SLS_PLN_QTY END) AS LAG0_QTY,
                SUM(CASE WHEN SP.LAG_DESC = 2 THEN SP.OFFCL_SOP_SLS_PLN_QTY END) AS LAG2_QTY
            
            FROM NA_BI_VWS.CUST_SLS_PLN_SNAP SP
            
                LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M1
                    ON M1.MATL_ID = SP.MATL_ID
            
            WHERE
                SP.PERD_BEGIN_MTH_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
                AND SP.LAG_DESC IN ('0', '2')
                AND M1.PBU_NBR IN('01','03')
                AND M1.EXT_MATL_GRP_ID = 'TIRE'
            
            GROUP BY
                SP_YEAR,
                SP_MONTH,
                SP.MATL_ID
            )SPB
        ON SPB.MATL_ID = MM.MATL_ID 
        AND SPB.SP_YEAR = GC.CAL_YR 
        AND SPB.SP_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
                SELECT
                    SA.MATL_NO AS PROD_MATL_NBR,
                    EXTRACT (YEAR FROM SA.BILL_DT) AS BILL_YEAR,
                    EXTRACT (MONTH FROM SA.BILL_DT) AS BILL_MONTH,
                    SUM(SA.COLLCT_SLS_GRP_AMT) AS COLLECTIBLES,
                    SUM(SA.COLLCT_STD_MRGN_GRP_AMT) AS COLL_STD_MARGIN,
                    SUM(SA.SLS_QTY) AS UNITS
                        
                FROM NA_VWS.SLS_AGG SA
    
                WHERE 
                    SA.BILL_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
    
                GROUP BY
                    SA.MATL_NO,
                    BILL_YEAR,
                    BILL_MONTH
            )BU
        ON BU.PROD_MATL_NBR = MM.MATL_ID 
        AND BU.BILL_YEAR = GC.CAL_YR 
        AND BU.BILL_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID,
                SUM(CASE WHEN ODC.PO_TYPE_ID <> 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS ORDER_QTY,
                SUM(CASE WHEN ODC.PO_TYPE_ID = 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS RO_ORDER_QTY,
                SUM(ODC.CNFRM_QTY) AS CONFIRM_QTY,
                EXTRACT (YEAR FROM ODC.FRST_RDD) AS FRDD_YEAR,
                EXTRACT (MONTH FROM ODC.FRST_RDD) AS FRDD_MONTH
            
            FROM NA_BI_VWS.ORDER_DETAIL ODC
            
            WHERE
                ODC.EXP_DT = DATE '5555-12-31'
                AND ODC.ORDER_CAT_ID = 'C'
                AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
                AND (ODC.CANCEL_IND = 'N' OR ODC.REJ_REAS_ID = 'Z2')
                AND ODC.ORDER_QTY > 0
                AND ODC.FRST_RDD BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) AND (CURRENT_DATE+180)
            
            GROUP BY
                ODC.MATL_ID,
                FRDD_YEAR,
                FRDD_MONTH
            )ODCG
        ON ODCG.MATL_ID = MM.MATL_ID 
        AND ODCG.FRDD_YEAR = GC.CAL_YR 
        AND ODCG.FRDD_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                ODC.MATL_ID,
                SUM(OOSL.OPEN_CNFRM_QTY) AS OPEN_CONFIRM_QTY,
                EXTRACT (YEAR FROM ODC.PLN_DELIV_DT) AS PLN_DELIV_YEAR,
                EXTRACT (MONTH FROM ODC.PLN_DELIV_DT) AS PLN_DELIV_MONTH
            
            FROM NA_BI_VWS.ORDER_DETAIL ODC
            
                INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
                    ON OOSL.ORDER_FISCAL_YR = ODC.ORDER_FISCAL_YR
                    AND OOSL.ORDER_ID = ODC.ORDER_ID 
                    AND OOSL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR 
                    AND OOSL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR
                    AND OOSL.OPEN_CNFRM_QTY > 0
            
            WHERE
                ODC.EXP_DT = DATE '5555-12-31'
                AND ODC.ORDER_CAT_ID = 'C'
                AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
                AND ODC.PO_TYPE_ID <> 'RO'
                AND ODC.PLN_DELIV_DT BETWEEN CURRENT_DATE AND CURRENT_DATE+180
            
            GROUP BY
                ODC.MATL_ID,
                PLN_DELIV_YEAR,
                PLN_DELIV_MONTH
            )OO
        ON OO.MATL_ID = MM.MATL_ID 
        AND OO.PLN_DELIV_YEAR = GC.CAL_YR 
        AND OO.PLN_DELIV_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                SDI.MATL_ID,
                SUM(SDI.SLS_UNIT_CUM_ORD_QTY) AS ORDER_QTY,
                EXTRACT (YEAR FROM SDSL.SCHD_LN_DELIV_DT) AS FRDD_YEAR,
                EXTRACT (MONTH FROM SDSL.SCHD_LN_DELIV_DT) AS FRDD_MONTH
            
            FROM GDYR_BI_VWS.NAT_SLS_DOC_CURR SD
            
                INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM_CURR SDI
                    ON SDI.FISCAL_YR = SD.FISCAL_YR
                    AND SDI.SLS_DOC_ID = SD.SLS_DOC_ID
                    AND SDI.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 AS CHAR(4))
                    AND SDI.MATL_HIER_ID LIKE ANY ('01%', '03%')
                
                INNER JOIN GDYR_BI_VWS.NAT_SLS_DOC_SCHD_LN_CURR SDSL
                    ON SDSL.FISCAL_YR = SDI.FISCAL_YR
                    AND SDSL.SLS_DOC_ID = SDI.SLS_DOC_ID 
                    AND SDSL.SLS_DOC_ITM_ID = SDI.SLS_DOC_ITM_ID 
                    AND SDSL.SCHD_LN_ID = 1
                    AND SDSL.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 AS CHAR(4))
                    AND SDSL.SCHD_LN_DELIV_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) 
                        AND (CURRENT_DATE+180)
            
            WHERE 
                SD.SD_DOC_CTGY_CD IN  ('E')
                AND SDI.REJ_REAS_ID IS NULL
                AND SD.FISCAL_YR >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 AS CHAR(4))
            
            GROUP BY
                SDI.MATL_ID,
                FRDD_YEAR,
                FRDD_MONTH
            )SA
        ON SA.MATL_ID = MM.MATL_ID 
        AND SA.FRDD_YEAR = GC.CAL_YR 
        AND SA.FRDD_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                DDC.MATL_ID,
                SUM(DDC.DELIV_QTY) AS DELIVERY_QTY,
                EXTRACT (YEAR FROM DDC.ACTL_GOODS_ISS_DT) AS AGI_YEAR,
                EXTRACT (MONTH FROM DDC.ACTL_GOODS_ISS_DT) AS AGI_MONTH
            
            FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC
            
            WHERE  
                DDC.DELIV_QTY > 0
                AND DDC.RETURN_IND = 'N'
                AND DDC.DISTR_CHAN_CD <> '81'  --INTERNAL SHIPMENTS
                AND DDC.GOODS_ISS_IND = 'Y'
                AND DDC.DELIV_CAT_ID = 'J'
                AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
                AND DDC.ACTL_GOODS_ISS_DT BETWEEN CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE) 
                    AND (CURRENT_DATE-1)
            
            GROUP BY
                DDC.MATL_ID,
                AGI_YEAR,
                AGI_MONTH
            )DDCG
        ON DDCG.MATL_ID = MM.MATL_ID 
        AND DDCG.AGI_YEAR = GC.CAL_YR 
        AND DDCG.AGI_MONTH = GC.CAL_MTH

    LEFT OUTER JOIN (
            SELECT
                POL.MATL_ID,
                POL.PBU_NBR,
                EXTRACT (YEAR FROM POL.CMPL_DT) AS FRDD_CMPL_YEAR,
                EXTRACT (MONTH FROM POL.CMPL_DT) AS FRDD_CMPL_MONTH,
                SUM(POL.IF_HIT_NS_QTY) AS NO_STOCK_QTY,
                SUM(POL.IF_HIT_CO_QTY) AS CANCEL_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS OTHER_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N602' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N602_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N623' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N623_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N636' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N636_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N637' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N637_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N639' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N639_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N699' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N699_NO_STOCK_QTY,
                SUM(CASE WHEN POL.SHIP_FACILITY_ID = 'N6D3' THEN POL.IF_HIT_NS_QTY ELSE 0 END) AS N6D3_NO_STOCK_QTY
            
            FROM NA_BI_VWS.PRFCT_ORD_LINE POL
            
            WHERE 
                POL.CMPL_IND = 1 
                AND POL.CMPL_DT BETWEEN CAST('2013-01-01' AS DATE) AND CURRENT_DATE - 1
                AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99
            
            GROUP BY
                FRDD_CMPL_YEAR,
                FRDD_CMPL_MONTH,
                POL.MATL_ID,
                POL.PBU_NBR
            )POLG
        ON POLG.MATL_ID = MM.MATL_ID 
        AND POLG.FRDD_CMPL_YEAR = GC.CAL_YR 
        AND POLG.FRDD_CMPL_MONTH = GC.CAL_MTH
    
    LEFT OUTER JOIN (
            -- first union grabs records from months in the past ending with the month before the current month
            -- second union portion grabs the current month and copies one record per future month per material
            SELECT
                ICG.MATL_ID,
                ICG.INV_YEAR,
                ICG.INV_MONTH,
                
                AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                          (ICG.SUM_SHIP_INTERVAL / 2)) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) AS MIN_INV,
                
            /*    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
                         ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) AS TARGET_INV,*/
                         
                AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                         (ICG.SUM_SHIP_INTERVAL / 2) + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) +
                         ZEROIFNULL(AVERAGE(ICA.SHIP_STD_DEVN_MATL_ADJ_QTY)) + ZEROIFNULL(AVERAGE(ICA.MIN_PROD_RUN_INV_ADJ_QTY)) AS MAX_INV,
                         
                (MIN_INV + MAX_INV) / 2 AS TARGET_INV
            
            FROM (
                SELECT
                    IC.MATL_ID,
                    IC.SRC_CRT_DT,
                    EXTRACT (YEAR FROM IC.SRC_CRT_DT) AS INV_YEAR,
                    EXTRACT (MONTH FROM IC.SRC_CRT_DT) AS INV_MONTH,
                    SUM(IC.DMAN_VAR_CMPNT_INV_QTY) AS SUM_DEMAND_VAR,
                    SUM(IC.TRANSP_VAR_CMPNT_INV_QTY) AS SUM_TRANS_VAR ,
                    SUM(IC.SPLY_VAR_CMPNT_INV_QTY) AS SUM_SUPPLY_VAR,
                    SUM(IC.GEO_CMPNT_INV_QTY) AS SUM_GEO,
                    SUM(IC.SHIP_LOT_SZ_CMPNT_INV_QTY) AS SUM_SHIP_LOT_SIZE,
                    SUM(IC.SHIP_INTVL_CMPNT_INV_QTY) AS SUM_SHIP_INTERVAL,
                    SUM(IC.MFG_LOT_SZ_CMPNT_INV_QTY) AS SUM_MFG_LOT_SIZE,
                    SUM(IC.INFO_CYCL_CMPNT_INV_QTY) AS SUM_INFO_CYCLE
            
                FROM NA_BI_VWS.INV_COMPONENT_CURR IC
            
                    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
                        ON MH.MATL_ID = IC.MATL_ID
                        AND MH.PBU_NBR IN ('01','03')
                WHERE
                    IC.SRC_CRT_DT / 100 BETWEEN ADD_MONTHS((CURRENT_DATE-1), -24) / 100 
                        AND ((CURRENT_DATE-1) / 100) - 1
            
                GROUP BY
                    IC.MATL_ID,
                    IC.SRC_CRT_DT,
                    INV_YEAR,
                    INV_MONTH
                )ICG
            
                LEFT OUTER JOIN NA_BI_VWS.INV_COMPONENT_ADJ_CURR ICA
                    ON ICA.MATL_ID = ICG.MATL_ID
                    AND ICA.SRC_CRT_DT = ICG.SRC_CRT_DT
            
            GROUP BY
                ICG.MATL_ID,
                ICG.INV_YEAR,
                ICG.INV_MONTH
            
            UNION ALL
            
            SELECT
                Q.MATL_ID,
                CAL.CAL_YR,
                CAL.CAL_MTH,
                Q.MIN_INV,
                Q.TARGET_INV,
                Q.MAX_INV
            
            FROM ( SELECT CAL_YR, CAL_MTH FROM GDYR_BI_VWS.GDYR_CAL WHERE DAY_DATE BETWEEN (CURRENT_DATE-1) AND ADD_MONTHS(CURRENT_DATE-1, 18) GROUP BY CAL_YR, CAL_MTH ) CAL
            
            FULL OUTER JOIN (
            
            SELECT
                ICG.MATL_ID,
                AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                        (ICG.SUM_SHIP_INTERVAL / 2)) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) AS MIN_INV,
                        
            /*    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
                         ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) AS TARGET_INV,*/
                         
                AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + (ICG.SUM_SHIP_LOT_SIZE / 2) +
                         (ICG.SUM_SHIP_INTERVAL / 2) + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) +
                         ZEROIFNULL(AVERAGE(ICA.SHIP_STD_DEVN_MATL_ADJ_QTY)) + ZEROIFNULL(AVERAGE(ICA.MIN_PROD_RUN_INV_ADJ_QTY)) AS MAX_INV,
                         
                (MIN_INV + MAX_INV)/2 AS TARGET_INV
            
            FROM (
                    SELECT
                        IC.MATL_ID,
                        IC.SRC_CRT_DT,
                        SUM(IC.DMAN_VAR_CMPNT_INV_QTY) AS SUM_DEMAND_VAR,
                        SUM(IC.TRANSP_VAR_CMPNT_INV_QTY) AS SUM_TRANS_VAR ,
                        SUM(IC.SPLY_VAR_CMPNT_INV_QTY) AS SUM_SUPPLY_VAR,
                        SUM(IC.GEO_CMPNT_INV_QTY) AS SUM_GEO,
                        SUM(IC.SHIP_LOT_SZ_CMPNT_INV_QTY) AS SUM_SHIP_LOT_SIZE,
                        SUM(IC.SHIP_INTVL_CMPNT_INV_QTY) AS SUM_SHIP_INTERVAL,
                        SUM(IC.MFG_LOT_SZ_CMPNT_INV_QTY) AS SUM_MFG_LOT_SIZE,
                        SUM(IC.INFO_CYCL_CMPNT_INV_QTY) AS SUM_INFO_CYCLE
            
                    FROM NA_BI_VWS.INV_COMPONENT_CURR IC
            
                        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
                            ON MH.MATL_ID = IC.MATL_ID
                            AND MH.PBU_NBR IN ('01','03')
                    WHERE
                        IC.SRC_CRT_DT / 100 >= (CURRENT_DATE-1) / 100
            
                    GROUP BY
                        IC.MATL_ID,
                        IC.SRC_CRT_DT
                )ICG
            
                LEFT OUTER JOIN NA_BI_VWS.INV_COMPONENT_ADJ_CURR ICA
                    ON ICA.MATL_ID = ICG.MATL_ID
                    AND ICA.SRC_CRT_DT = ICG.SRC_CRT_DT
            
            GROUP BY
                ICG.MATL_ID
                ) Q
                ON 1=1
            
            )INV
        ON INV.MATL_ID = MM.MATL_ID 
        AND INV.INV_YEAR = GC.CAL_YR 
        AND INV.INV_MONTH = GC.CAL_MTH
    
    LEFT OUTER JOIN (
            SELECT
                IE.MATL_ID,
                EXTRACT (YEAR FROM IE.DAY_DT) AS INV_YEAR,
                EXTRACT (MONTH FROM IE.DAY_DT) AS INV_MONTH,
                MAX(CASE WHEN IE.FACILITY_ID LIKE 'N5%' THEN IE.TOT_QTY ELSE 0 END) AS FACT_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3')THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS LC_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID LIKE 'N5%' AND
                                    IE.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN TOT_QTY + IN_TRANS_QTY ELSE 0 END) AS OTHER_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N602' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N602_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N623' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N623_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N636' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N636_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N637' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N637_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N639' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N639_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N699' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N699_END_INV,
                MAX(CASE WHEN IE.FACILITY_ID = 'N6D3' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N6D3_END_INV,
                
                MAX(CASE WHEN IE.FACILITY_ID = 'N602' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N602_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N623' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N623_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N636' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N636_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N637' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N637_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N639' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N639_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N699' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N699_DSI,
                MAX(CASE WHEN IE.FACILITY_ID = 'N6D3' THEN IE.EST_DAYS_SUPPLY ELSE 0 END) AS N6D3_DSI
            
            FROM NA_BI_VWS.INVENTORY IE
            
            WHERE 
                IE.DAY_DT BETWEEN CAST('2013-01-01' AS DATE) AND CURRENT_DATE
                AND IE.MTH_RPT_IND = 'M'
            
            GROUP BY
                IE.MATL_ID,
                INV_YEAR,
                INV_MONTH
            )INVE
        ON INVE.MATL_ID = MM.MATL_ID 
        AND INVE.INV_YEAR = GC.CAL_YR 
        AND INVE.INV_MONTH = GC.CAL_MTH
    
    LEFT OUTER JOIN (
            SELECT
                PPC.PLAN_TYPE,
                PPC.BUS_MTH,
                EXTRACT(YEAR FROM PPC.BUS_MTH) AS PROD_YEAR,
                EXTRACT(MONTH FROM PPC.BUS_MTH) AS PROD_MONTH,
                PPC.MATL_ID,
                PPC.SRC_FACILITY_ID,
                CAST(COUNT(PPC.SRC_FACILITY_ID) OVER (PARTITION BY PPC.BUS_MTH, PPC.MATL_ID) AS DECIMAL(15,3)) AS SRC_FACILITY_CNT,
                PPC.PROD_CREDIT_QTY,
                SUM(PPC.PROD_CREDIT_QTY) OVER (PARTITION BY PPC.BUS_MTH, PPC.MATL_ID) AS TOT_PROD_CREDIT_QTY,
                PPC.PROD_CREDIT_QTY / NULLIFZERO(TOT_PROD_CREDIT_QTY) AS PROD_CREDIT_PCT,
                PPC.PROD_PLAN_QTY,
                LD.LVL_GRP_ID,
                LD.LVL_GRP_CNT
                
            FROM (
            
                SELECT
                    PP.PLAN_TYPE,
                    PP.BUS_MTH,
                    PP.MATL_ID,
                    PP.SRC_FACILITY_ID,
                    SUM(CASE WHEN PP.CREDIT_CD = 'C' THEN PP.CREDIT_QTY ELSE 0 END) AS PROD_CREDIT_QTY,
                    SUM(CASE WHEN PP.CREDIT_CD <> 'C' THEN PP.CREDIT_QTY ELSE 0 END) AS PROD_PLAN_QTY
                
                FROM (
                
                    SELECT
                        CAST('Production Credit' AS VARCHAR(25)) AS QUERY_TYPE,
                        CAST(CASE
                            WHEN CAL.DAY_DATE / 100 = (CURRENT_DATE-1) / 100
                                THEN 'Current Month'
                            WHEN CAL.DAY_DATE / 100 > (CURRENT_DATE-1) / 100
                                THEN 'Future Month'
                            WHEN CAL.DAY_DATE / 100 < (CURRENT_DATE-1) / 100
                                THEN 'Past Month'
                        END AS VARCHAR(25)) AS PLAN_TYPE,
                        CAL.DAY_DATE AS BUS_DT,
                        CASE
                            WHEN CAL.DAY_DATE = CAL.BEGIN_DT
                                THEN CAST(CAL.BEGIN_DT + 6 AS DATE)
                            ELSE CAST(CAL.BEGIN_DT + 1 AS DATE)
                        END AS BUS_WK,
                        CAL.MONTH_DT AS BUS_MTH,
                        PC.MATL_ID AS MATL_ID,
                        PC.FACILITY_ID AS SRC_FACILITY_ID,
                        CAST('C' AS CHAR(1)) AS CREDIT_CD,
                        CAST(SUM(PC.PROD_QTY) AS DECIMAL(15,3)) AS CREDIT_QTY
                
                    FROM GDYR_BI_VWS.GDYR_CAL CAL
                
                        INNER JOIN GDYR_VWS.PROD_CREDIT_DY PC
                            ON PC.PROD_DT = CAL.DAY_DATE
                            AND PC.PROD_QTY > 0
                
                        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                            ON MATL.MATL_ID = PC.MATL_ID
                            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                
                    WHERE
                        CAL.DAY_DATE >= CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE)
                
                    GROUP BY
                        QUERY_TYPE,
                        PLAN_TYPE,
                        BUS_DT,
                        BUS_WK,
                        BUS_MTH,
                        PC.MATL_ID,
                        PC.FACILITY_ID,
                        CREDIT_CD
                
                    UNION ALL
                
                    SELECT
                        CAST('Production Plan' AS VARCHAR(25)) AS QUERY_TYPE,
                        CAST(CASE
                            WHEN CAL.POSTED_DT / 100 = (CURRENT_DATE-1) / 100
                                THEN 'Current Month'
                            WHEN CAL.POSTED_DT / 100 > (CURRENT_DATE-1) / 100
                                THEN 'Future Month'
                            WHEN CAL.POSTED_DT / 100 < (CURRENT_DATE-1) / 100
                                THEN 'Past Month'
                        END AS VARCHAR(25)) AS PLAN_TYPE,
                        CAL.POSTED_DT AS BUS_DT,
                        PP.PROD_WK_DT AS BUS_WK,
                        CAL.POSTED_DT - (EXTRACT(DAY FROM CAL.POSTED_DT)-1) AS BUS_MTH,
                        PP.PLN_MATL_ID AS MATL_ID,
                        PP.FACILITY_ID AS SRC_FACILITY_ID,
                        PP.PROD_PLN_CD AS PROD_PLN_CD,
                        CAST(CASE
                            WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                                THEN ROUND( PP.PLN_QTY / 7.000, 0)
                            ELSE (PP.PLN_QTY / 7.000)
                        END AS DECIMAL(15,3)) AS PLAN_QTY
                
                    FROM GDYR_VWS.DMAN_GRP_PRD_FCTR CAL
                
                        INNER JOIN GDYR_VWS.PROD_PLN PP
                            ON CAL.MEAS_DT = PP.PROD_WK_DT
                            AND PP.PROD_PLN_CD = '0'
                            AND PP.SBU_ID = 2
                            AND PP.PLN_QTY > 0
                            AND CAST(PP.PROD_WK_DT-3 AS DATE) BETWEEN PP.EFF_DT AND PP.EXP_DT
                
                        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                            ON MATL.MATL_ID = PP.PLN_MATL_ID
                            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                
                    WHERE
                        CAL.SBU_ID = 2
                        AND CAL.FNL_PERDY_ID = 'D'
                        AND CAL.PERDY_ID = 'W'
                        AND CAL.EXP_DT = DATE '5555-12-31'
                        AND CAL.POSTED_DT BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND
                            (SELECT MIN(PP.PROD_WK_DT) - 1 AS END_DT FROM GDYR_VWS.PROD_PLN PP WHERE PP.SBU_ID = 2 AND PP.PROD_PLN_CD = '0' AND PP.PROD_WK_DT > CURRENT_DATE)
                
                    UNION ALL
                
                    SELECT
                        CAST('Production Plan' AS VARCHAR(25)) AS QUERY_TYPE,
                        CAST(CASE
                            WHEN CAL.POSTED_DT / 100 = (CURRENT_DATE-1) / 100
                                THEN 'Current Month'
                            WHEN CAL.POSTED_DT / 100 > (CURRENT_DATE-1) / 100
                                THEN 'Future Month'
                            WHEN CAL.POSTED_DT / 100 < (CURRENT_DATE-1) / 100
                                THEN 'Past Month'
                        END AS VARCHAR(25)) AS PLAN_TYPE,
                        CAL.POSTED_DT AS BUS_DT,
                        PP.PROD_WK_DT AS BUS_WK,
                        CAL.POSTED_DT - (EXTRACT(DAY FROM CAL.POSTED_DT)-1) AS BUS_MTH,
                        PP.PLN_MATL_ID AS MATL_ID,
                        PP.FACILITY_ID AS SRC_FACILITY_ID,
                        PP.PROD_PLN_CD AS PROD_PLN_CD,
                        CAST(CASE
                            WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                                THEN ROUND(PP.PLN_QTY/7.000, 0)
                            ELSE (PP.PLN_QTY / 7.000)
                        END AS DECIMAL(15,3)) AS PLAN_QTY
                
                    FROM GDYR_VWS.DMAN_GRP_PRD_FCTR CAL
                
                        INNER JOIN GDYR_VWS.PROD_PLN PP
                            ON CAL.MEAS_DT = PP.PROD_WK_DT
                            AND PP.PROD_PLN_CD = '0'
                            --ON CAL.POSTED_DT BETWEEN PP.PROD_WK_DT AND CAST(PP.PROD_WK_DT + 6 AS DATE)
                            AND PP.EXP_DT = CAST('5555-12-31' AS DATE)
                            AND PP.SBU_ID = 2
                            AND PP.PLN_QTY > 0
                
                        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                            ON MATL.MATL_ID = PP.PLN_MATL_ID
                            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                
                    WHERE
                        CAL.POSTED_DT BETWEEN (SELECT MIN(PP.PROD_WK_DT) AS BEGIN_DT FROM GDYR_VWS.PROD_PLN PP WHERE PP.PROD_PLN_CD = '0' AND PP.SBU_ID = 2 AND PP.PROD_WK_DT > (CURRENT_DATE-1)) AND
                            (SELECT MIN(PP.PROD_WK_DT) + (7*7) AS END_DT FROM GDYR_VWS.PROD_PLN PP WHERE PP.PROD_PLN_CD = '0' AND PP.SBU_ID = 2 AND PP.PROD_WK_DT > (CURRENT_DATE-1))
                        AND CAL.FNL_PERDY_ID = 'D'
                        AND CAL.PERDY_ID = 'W'
                        AND CAL.EXP_DT = DATE '5555-12-31'

                    UNION ALL
                
                    SELECT
                        CAST('Production Plan' AS VARCHAR(25)) AS QUERY_TYPE,
                        CAST(CASE
                            WHEN CAL.POSTED_DT / 100 = (CURRENT_DATE-1) / 100
                                THEN 'Current Month'
                            WHEN CAL.POSTED_DT / 100 > (CURRENT_DATE-1) / 100
                                THEN 'Future Month'
                            WHEN CAL.POSTED_DT / 100 < (CURRENT_DATE-1) / 100
                                THEN 'Past Month'
                        END AS VARCHAR(25)) AS PLAN_TYPE,
                        CAL.POSTED_DT AS BUS_DT,
                        PP.PROD_WK_DT AS BUS_WK,
                        CAL.POSTED_DT - (EXTRACT(DAY FROM CAL.POSTED_DT)-1) AS BUS_MTH,
                        PP.PLN_MATL_ID AS MATL_ID,
                        PP.FACILITY_ID AS SRC_FACILITY_ID,
                        PP.PROD_PLN_CD AS PROD_PLN_CD,
                        CAST(CASE
                            WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                                THEN ROUND( PP.PLN_QTY / 7.000, 0)
                            ELSE (PP.PLN_QTY / 7.000)
                        END AS DECIMAL(15,3)) AS PLAN_QTY
                
                    FROM GDYR_VWS.DMAN_GRP_PRD_FCTR CAL
                
                        INNER JOIN GDYR_VWS.PROD_PLN PP
                            ON CAL.POSTED_DT = PP.PROD_WK_DT -- BETWEEN PP.PROD_WK_DT AND CAST(PP.PROD_WK_DT + 6 AS DATE)
                            AND PP.EXP_DT = CAST('5555-12-31' AS DATE)
                            AND PP.SBU_ID = 2
                            AND PP.PROD_PLN_CD = 'A'
                            AND PP.PLN_QTY > 0
                
                        INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                            ON MATL.MATL_ID = PP.PLN_MATL_ID
                            AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                            AND MATL.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                
                    WHERE
                        CAL.POSTED_DT BETWEEN
                            -- WHERE PROD PLAN '0' ENDS
                            (SELECT MIN(PP.PROD_WK_DT) + (7*8) AS BEGIN_DT FROM GDYR_VWS.PROD_PLN PP WHERE PP.PROD_PLN_CD = '0' AND PP.SBU_ID = 2 AND PP.PROD_WK_DT > (CURRENT_DATE-1)) AND
                            -- END OF +12 MONTHS
                            (SELECT ADD_MONTHS(MIN(PP.PROD_WK_DT), 13) - EXTRACT(DAY FROM ADD_MONTHS(MIN(PP.PROD_WK_DT), 13)) AS END_DT FROM GDYR_VWS.PROD_PLN PP WHERE PP.PROD_PLN_CD = '0' AND PP.SBU_ID = 2 AND PP.PROD_WK_DT > (CURRENT_DATE-1))
                        AND CAL.FNL_PERDY_ID = 'D'
                        AND CAL.PERDY_ID = 'W'
                        AND CAL.EXP_DT = DATE '5555-12-31'
                        AND CAL.SBU_ID = 2
                
                    ) PP
                
                GROUP BY
                    PP.PLAN_TYPE,
                    PP.BUS_MTH,
                    PP.MATL_ID,
                    PP.SRC_FACILITY_ID
                    
                ) PPC
                
                LEFT OUTER JOIN (
                        
                        SELECT
                            CAL.MONTH_DT AS BUS_MTH,
                        
                            FMC.MATL_ID,
                            FMC.FACILITY_ID,
                            MAX(FMC.LVL_GRP_ID) AS LVL_GRP_ID,
                            COUNT(DISTINCT FMC.LVL_GRP_ID) (DECIMAL(15,3)) AS LVL_GRP_CNT
                        
                        FROM GDYR_BI_VWS.GDYR_CAL CAL
                        
                            INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                                ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                                AND CAL.DAY_DATE >= FMC.LVL_DESIGN_EFF_DT
                                AND FMC.LVL_DESIGN_STA_CD = 'A'
                                AND FMC.SBU_ID = 2
                                AND FMC.ORIG_SYS_ID = 2
                                AND FMC.SRC_SYS_ID = 2
                        
                            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                                ON M.MATL_ID = FMC.MATL_ID
                                AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                                AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                        
                            INNER JOIN (
                                    SELECT
                                        C.DAY_DATE AS BUS_DT,
                                        F.MATL_ID,
                                        F.FACILITY_ID,
                                        MAX(F.LVL_DESIGN_EFF_DT) AS MAX_LD_EFF_DT
                                    FROM GDYR_BI_VWS.GDYR_CAL C
                                        INNER JOIN NA_VWS.FACL_MATL_CYCASGN F
                                            ON C.DAY_DATE BETWEEN F.EFF_DT AND F.EXP_DT
                                            AND C.DAY_DATE >= F.LVL_DESIGN_EFF_DT
                                            AND F.LVL_DESIGN_STA_CD = 'A'
                                            AND F.SBU_ID = 2
                                            AND F.ORIG_SYS_ID = 2
                                            AND F.SRC_SYS_ID = 2
                                    WHERE
                                        C.DAY_DATE BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
                                    GROUP BY
                                        C.DAY_DATE,
                                        F.MATL_ID,
                                        F.FACILITY_ID
                                    ) LIM
                                ON LIM.BUS_DT = CAL.DAY_DATE
                                AND LIM.MATL_ID = FMC.MATL_ID
                                AND LIM.FACILITY_ID = FMC.FACILITY_ID
                                AND LIM.MAX_LD_EFF_DT = FMC.LVL_DESIGN_EFF_DT
                        
                        WHERE
                            CAL.DAY_DATE BETWEEN CAST((EXTRACT(YEAR FROM (CURRENT_DATE-1))-1) || '-01-01' AS DATE) AND (CURRENT_DATE-1)
                        
                        GROUP BY
                            CAL.MONTH_DT,
                        
                            FMC.MATL_ID,
                            FMC.FACILITY_ID
                        
                        UNION
                        
                        SELECT
                            CAL.MONTH_DT AS BUS_MTH,
                        
                            FMC.MATL_ID,
                            FMC.FACILITY_ID,
                            MAX(FMC.LVL_GRP_ID) AS LVL_GRP_ID,
                            COUNT(DISTINCT FMC.LVL_GRP_ID) (DECIMAL(15,3)) AS LVL_GRP_CNT
                        
                        FROM GDYR_BI_VWS.GDYR_CAL CAL
                        
                            INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                                ON FMC.EXP_DT = CAST('5555-12-31' AS DATE)
                                AND CAL.DAY_DATE >= FMC.LVL_DESIGN_EFF_DT
                                AND FMC.LVL_DESIGN_STA_CD = 'A'
                                AND FMC.SBU_ID = 2
                                AND FMC.ORIG_SYS_ID = 2
                                AND FMC.SRC_SYS_ID = 2
                        
                            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                                ON M.MATL_ID = FMC.MATL_ID
                                AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                                AND M.SUPER_BRAND_ID IN ('01', '02', '03', '05')
                        
                            INNER JOIN (
                                    SELECT
                                        C.DAY_DATE AS BUS_DT,
                                        F.MATL_ID,
                                        F.FACILITY_ID,
                                        MAX(F.LVL_DESIGN_EFF_DT) AS MAX_LD_EFF_DT
                                    FROM GDYR_BI_VWS.GDYR_CAL C
                                        INNER JOIN NA_VWS.FACL_MATL_CYCASGN F
                                            ON F.EXP_DT = CAST('5555-12-31' AS DATE)
                                            AND C.DAY_DATE >= F.LVL_DESIGN_EFF_DT
                                            AND F.LVL_DESIGN_STA_CD = 'A'
                                            AND F.SBU_ID = 2
                                            AND F.ORIG_SYS_ID = 2
                                            AND F.SRC_SYS_ID = 2
                                    WHERE
                                        C.DAY_DATE BETWEEN CURRENT_DATE AND CAST(ADD_MONTHS(CURRENT_DATE, 13) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 13)) AS DATE)
                                    GROUP BY
                                        C.DAY_DATE,
                                        F.MATL_ID,
                                        F.FACILITY_ID
                                    ) LIM
                                ON LIM.BUS_DT = CAL.DAY_DATE
                                AND LIM.MATL_ID = FMC.MATL_ID
                                AND LIM.FACILITY_ID = FMC.FACILITY_ID
                                AND LIM.MAX_LD_EFF_DT = FMC.LVL_DESIGN_EFF_DT
                        
                        WHERE
                            CAL.DAY_DATE BETWEEN CURRENT_DATE AND CAST(ADD_MONTHS(CURRENT_DATE, 13) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 13)) AS DATE)
                        
                        GROUP BY
                            CAL.MONTH_DT,
                        
                            FMC.MATL_ID,
                            FMC.FACILITY_ID
                
                    ) LD
                ON LD.BUS_MTH = PPC.BUS_MTH
                AND LD.FACILITY_ID = PPC.SRC_FACILITY_ID
                AND LD.MATL_ID = PPC.MATL_ID
    
            ) MTI
        ON MTI.MATL_ID = MM.MATL_ID 
        AND MTI.PROD_YEAR = GC.CAL_YR 
        AND MTI.PROD_MONTH = GC.CAL_MTH
    
    LEFT OUTER JOIN (
            SELECT
                MATL_ID,
                DAY_DT,
                SUM( ZEROIFNULL(TOT_QTY) + ZEROIFNULL(IN_TRANS_QTY) ) AS GROSS_INV,
                INV_QTY_UOM
            FROM GDYR_VWS.NAT_INV_CURR
            GROUP BY
                MATL_ID,
                DAY_DT,
                INV_QTY_UOM
            ) INVC
        ON INVC.MATL_ID = MM.MATL_ID
        AND INVC.DAY_DT / 100 = GC.DAY_DATE / 100 -- ENSURE WE DON'T LOOK AT IT BEFORE THE REPORTING DATE

WHERE
    -- AND MM.MATL_ID ='000000000000163878'
    GC.DAY_DATE = GC.MONTH_DT
    AND GC.CAL_YR BETWEEN EXTRACT(YEAR FROM CURRENT_DATE-1)-1 AND EXTRACT(YEAR FROM CURRENT_DATE-1)+1
    AND ("Sales Plan Lag0" + "Sales Plan Lag2" + "Billed Units" + "Order Qty" + "Ship Qty" + "No Stock Qty") > .9
