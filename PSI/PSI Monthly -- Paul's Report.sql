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
MTI.FACILITY_ID AS "Source",
MTI.LVL_GRP_ID AS "Work Center",
CAST (MM.MATL_PRTY AS INTEGER) AS "Priority",
CAST(CASE
    WHEN MTI.PPC_FACILITY_ID_CNT IS NULL OR MTI.PPC_FACILITY_ID_CNT < 2
        THEN 1
    ELSE CASE
        WHEN MTI.CREDIT_PCT IS NULL AND ZEROIFNULL(MTI.TOT_CREDIT_QTY) = 0
            THEN 1/CAST (MTI.PPC_FACILITY_ID_CNT AS DECIMAL(15,3))
        ELSE CAST (ZEROIFNULL(MTI.CREDIT_PCT) AS DECIMAL(15,3))
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
    ELSE SP.OFFCL_SOP_LAG0 * PROD_MULTIPLIER
END AS "Sales Plan Lag0",
CASE
    WHEN SP.OFFCL_SOP_LAG2 IS NULL
        THEN ZEROIFNULL(SPB.LAG2_QTY) * PROD_MULTIPLIER
    ELSE SP.OFFCL_SOP_LAG2 * PROD_MULTIPLIER
END AS "Sales Plan Lag2",
ZEROIFNULL(INVE.FACT_END_INV) * PROD_MULTIPLIER AS "Fact End Inv",
CASE
    WHEN GC.MONTH_DT / 100 >= (CURRENT_DATE-1) / 100
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
CASE
    WHEN MTI.FACILITY_ID IS NOT NULL OR GC.MONTH_DT / 100 <= (CURRENT_DATE-1) / 100
        THEN ZEROIFNULL(INV.MIN_INV) * PROD_MULTIPLIER
    ELSE 0
END AS "Min Inv",
CASE
    WHEN MTI.FACILITY_ID IS NOT NULL OR GC.MONTH_DT / 100 <= (CURRENT_DATE-1) / 100
        THEN ZEROIFNULL(INV.MAX_INV) * PROD_MULTIPLIER
    ELSE 0
END AS "Max Inv",
CASE
    WHEN MTI.FACILITY_ID IS NOT NULL OR GC.MONTH_DT / 100 <= (CURRENT_DATE-1) / 100
        THEN ZEROIFNULL(INV.MIN_INV + ((INV.MAX_INV - INV.MIN_INV)/2)) * PROD_MULTIPLIER
    ELSE 0
END AS "Target Inv",
/*ZEROIFNULL(BU.UNITS) * PROD_MULTIPLIER AS "Billed Units",
ZEROIFNULL(BU.COLLECTIBLES) * PROD_MULTIPLIER AS "Collect Sales",
ZEROIFNULL(BU.COLL_STD_MARGIN) * PROD_MULTIPLIER AS "Collect Margin",*/
ZEROIFNULL(MTI.CREDIT_QTY) AS "Prod Credit",
ZEROIFNULL(MTI.PLAN_QTY) AS "Prod Plan Lag0",
CASE
    WHEN GC.DAY_DATE/100 = (CURRENT_DATE-1)/100
        THEN 1 - (CAST(EXTRACT(DAY FROM (CURRENT_DATE-1)) AS DECIMAL(15,3)) / CAST(GC.TTL_DAYS_IN_MNTH AS DECIMAL(15,3)))
    ELSE 1.000
END AS CURR_MTH_BALANCE,
CASE
    WHEN "Order Qty" > "Sales Plan Lag2"
        THEN "Order Qty"
    ELSE "Sales Plan Lag2"
END AS SP_VS_ORD_QTY,
CASE -- in current month, add current gross_inv
    WHEN GC.DAY_DATE/100 = (CURRENT_DATE-1)/100
        THEN ( CURR_MTH_BALANCE * (ZEROIFNULL(MTI.PLAN_QTY) - SP_VS_ORD_QTY) ) + INVC.GROSS_INV
    -- future months use this from the cumulative sum operation
    WHEN GC.DAY_DATE/100 > (CURRENT_DATE-1)/100
        THEN CURR_MTH_BALANCE * (ZEROIFNULL(MTI.PLAN_QTY) - SP_VS_ORD_QTY)
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

LEFT OUTER JOIN
(
SELECT
EXTRACT (YEAR FROM A.PERD_BEGIN_MTH_DT) AS SP_YEAR,
EXTRACT (MONTH FROM A.PERD_BEGIN_MTH_DT) AS SP_MONTH,
A.MATL_ID,
SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 0') THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS OFFCL_SOP_LAG0,
SUM(CASE WHEN (A.DP_LAG_DESC = 'LAG 2') THEN A.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS OFFCL_SOP_LAG2

FROM NA_BI_VWS.CUST_SLS_PLN_SNAP A

LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
ON M.MATL_ID = A.MATL_ID

WHERE
M.PBU_NBR IN ('01', '03')
AND M.EXT_MATL_GRP_ID = 'TIRE'
AND A.DP_LAG_DESC IN ('LAG 0','LAG 2')
AND A.PERD_BEGIN_MTH_DT BETWEEN DATE AND DATE + 180

GROUP BY
A.MATL_ID,
SP_YEAR,
SP_MONTH
) SP

ON SP.MATL_ID = MM.MATL_ID AND SP.SP_YEAR = GC.CAL_YR AND SP.SP_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
SELECT
EXTRACT (YEAR FROM SP.PERD_BEGIN_MTH_DT) AS SP_YEAR,
EXTRACT (MONTH FROM SP.PERD_BEGIN_MTH_DT) AS SP_MONTH,
CAST (SP.MATL_ID AS INTEGER) AS MATL_ID,
SUM(CASE WHEN SP.LAG_DESC = 0 THEN SP.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS LAG0_QTY,
SUM(CASE WHEN SP.LAG_DESC = 2 THEN SP.OFFCL_SOP_SLS_PLN_QTY ELSE 0 END) AS LAG2_QTY

FROM NA_BI_VWS.CUST_SLS_PLN_SNAP SP

LEFT OUTER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M1
ON M1.MATL_ID = SP.MATL_ID

WHERE
SP.PERD_BEGIN_MTH_DT < DATE
AND SP.LAG_DESC IN (0,2)
AND M1.PBU_NBR IN('01','03')
AND M1.EXT_MATL_GRP_ID = 'TIRE'

GROUP BY
SP_YEAR,
SP_MONTH,
SP.MATL_ID
)SPB

ON SPB.MATL_ID = MM.MATL_ID AND SPB.SP_YEAR = GC.CAL_YR AND SPB.SP_MONTH = GC.CAL_MTH

/*LEFT OUTER JOIN
(
SELECT
                    PROD.MATERIAL_NO AS PROD_MATL_NBR,
                    EXTRACT (YEAR FROM SI.BILL_DT) AS BILL_YEAR,
                    EXTRACT (MONTH FROM SI.BILL_DT) AS BILL_MONTH,
                    SUM(SI.COLLCT_SLS_GRP_AMT) AS COLLECTIBLES,
                    SUM(SI.COLLCT_STD_MRGN_GRP_AMT) AS COLL_STD_MARGIN,
                    SUM(SI.SLS_QTY) AS UNITS

FROM RBNATP.SLS_HDR SH

INNER JOIN RBNATP.SLS_ITM SI
                    ON SI.SLS_HDR_SK = SH.SLS_HDR_SK
                    AND SI.BILL_DT=SH.BILL_DT

INNER JOIN RBNATP.PRODUCT PROD
                    ON SI.PROD_SK = PROD.PROD_SK

WHERE
SI.RPT_VIEW_TYP_SK=3

GROUP BY
                    PROD.MATERIAL_NO,
                    BILL_YEAR,
                    BILL_MONTH
)BU

ON BU.PROD_MATL_NBR = MM.MATL_ID AND BU.BILL_YEAR = GC.CAL_YR AND BU.BILL_MONTH = GC.CAL_MTH*/


LEFT OUTER JOIN
(
SELECT
ODC.MATL_ID,
SUM(CASE WHEN ODC.PO_TYPE_ID <> 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS ORDER_QTY,
SUM(CASE WHEN ODC.PO_TYPE_ID = 'RO' THEN ODC.ORDER_QTY ELSE 0 END) AS RO_ORDER_QTY,
SUM(ODC.CNFRM_QTY) AS CONFIRM_QTY,
EXTRACT (YEAR FROM ODC.FRST_RDD) AS FRDD_YEAR,
EXTRACT (MONTH FROM ODC.FRST_RDD) AS FRDD_MONTH

FROM  NA_BI_VWS.ORDER_DETAIL_CURR ODC

WHERE
ODC.ORDER_CAT_ID = 'C'
AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
--AND ODC.PO_TYPE_ID <> 'RO'
AND (ODC.CANCEL_IND = 'N' OR ODC.REJ_REAS_ID = 'Z2')
AND ODC.ORDER_QTY > 0
AND ODC.FRST_RDD < DATE + 180

GROUP BY
ODC.MATL_ID,
FRDD_YEAR,
FRDD_MONTH
)ODCG

ON ODCG.MATL_ID = MM.MATL_ID AND ODCG.FRDD_YEAR = GC.CAL_YR AND ODCG.FRDD_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
SELECT
ODC.MATL_ID,
SUM(OOSL.OPEN_CNFRM_QTY) AS OPEN_CONFIRM_QTY,
EXTRACT (YEAR FROM ODC.PLN_DELIV_DT) AS PLN_DELIV_YEAR,
EXTRACT (MONTH FROM ODC.PLN_DELIV_DT) AS PLN_DELIV_MONTH

FROM  NA_BI_VWS.ORDER_DETAIL_CURR ODC

INNER JOIN NA_BI_VWS.OPEN_ORDER_SCHDLN_CURR OOSL
ON OOSL.ORDER_ID = ODC.ORDER_ID AND OOSL.ORDER_LINE_NBR = ODC.ORDER_LINE_NBR AND
OOSL.SCHED_LINE_NBR = ODC.SCHED_LINE_NBR

WHERE
ODC.ORDER_CAT_ID = 'C'
AND ODC.ORDER_TYPE_ID NOT IN ('ZLS', 'ZLZ')
AND ODC.PO_TYPE_ID <> 'RO'
AND OOSL.OPEN_CNFRM_QTY > 0
AND ODC.PLN_DELIV_DT < DATE + 180
AND ODC.PLN_DELIV_DT > DATE

GROUP BY
ODC.MATL_ID,
PLN_DELIV_YEAR,
PLN_DELIV_MONTH
)OO

ON OO.MATL_ID = MM.MATL_ID AND OO.PLN_DELIV_YEAR = GC.CAL_YR AND OO.PLN_DELIV_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(SELECT
SDI.MATL_ID,
SUM(SDI.SLS_UNIT_CUM_ORD_QTY) AS ORDER_QTY,
EXTRACT (YEAR FROM SDSL.SCHD_LN_DELIV_DT) AS FRDD_YEAR,
EXTRACT (MONTH FROM SDSL.SCHD_LN_DELIV_DT) AS FRDD_MONTH

FROM  GDYR_BI_VWS.NAT_SLS_DOC_CURR SD

INNER JOIN NA_BI_VWS.NAT_SLS_DOC_ITM_CURR SDI
ON SDI.SLS_DOC_ID = SD.SLS_DOC_ID

INNER JOIN GDYR_BI_VWS.NAT_SLS_DOC_SCHD_LN_CURR SDSL
ON SDSL.SLS_DOC_ID = SDI.SLS_DOC_ID AND SDSL.SLS_DOC_ITM_ID = SDI.SLS_DOC_ITM_ID AND SDSL.SCHD_LN_ID = 1

WHERE SD.SD_DOC_CTGY_CD IN  ('E')
AND SDI.REJ_REAS_ID IS NULL
AND SDSL.SCHD_LN_DELIV_DT < DATE + 180
AND SDSL.SCHD_LN_DELIV_DT >= '2013-01-01'

GROUP BY
SDI.MATL_ID,
FRDD_YEAR,
FRDD_MONTH
)SA

ON SA.MATL_ID = MM.MATL_ID AND SA.FRDD_YEAR = GC.CAL_YR AND SA.FRDD_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
SELECT
DDC.MATL_ID,
SUM(DDC.DELIV_QTY) AS DELIVERY_QTY,
EXTRACT (YEAR FROM DDC.ACTL_GOODS_ISS_DT) AS AGI_YEAR,
EXTRACT (MONTH FROM DDC.ACTL_GOODS_ISS_DT) AS AGI_MONTH

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

WHERE  DDC.DELIV_QTY > 0
AND DDC.RETURN_IND = 'N'
AND DDC.DISTR_CHAN_CD <> '81'  --INTERNAL SHIPMENTS

GROUP BY
DDC.MATL_ID,
AGI_YEAR,
AGI_MONTH
)DDCG

ON DDCG.MATL_ID = MM.MATL_ID AND DDCG.AGI_YEAR = GC.CAL_YR AND DDCG.AGI_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
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

FROM
                    NA_BI_VWS.PRFCT_ORD_LINE POL

WHERE POL.CMPL_IND = 1 AND POL.CMPL_DT < DATE

GROUP BY
FRDD_CMPL_YEAR,
FRDD_CMPL_MONTH,
POL.MATL_ID,
POL.PBU_NBR
)POLG

ON POLG.MATL_ID = MM.MATL_ID AND POLG.FRDD_CMPL_YEAR = GC.CAL_YR AND POLG.FRDD_CMPL_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
-- first union grabs records from months in the past ending with the month before the current month
-- second union portion grabs the current month and copies one record per future month per material
SELECT
    ICG.MATL_ID,
    ICG.INV_YEAR,
    ICG.INV_MONTH,
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO) AS MIN_INV,
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
             ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) AS TARGET_INV,
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
             ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) +
             ZEROIFNULL(AVERAGE(ICA.SHIP_STD_DEVN_MATL_ADJ_QTY)) + ZEROIFNULL(AVERAGE(ICA.MIN_PROD_RUN_INV_ADJ_QTY)) AS MAX_INV

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
        IC.SRC_CRT_DT BETWEEN CAST(SUBSTR(CAST(ADD_MONTHS((CURRENT_DATE-1), -24) AS CHAR(10)),1,7) || '-01' AS DATE)
            AND ( CAST(SUBSTR(CAST((CURRENT_DATE-1) AS CHAR(10)),1,7) || '-01' AS DATE) - 1 )

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
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO) AS MIN_INV,
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
             ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) AS TARGET_INV,
    AVERAGE(ICG.SUM_DEMAND_VAR + ICG.SUM_TRANS_VAR + ICG.SUM_SUPPLY_VAR + ICG.SUM_GEO + ICG.SUM_SHIP_LOT_SIZE +
             ICG.SUM_SHIP_INTERVAL + ICG.SUM_MFG_LOT_SIZE + ICG.SUM_INFO_CYCLE) + ZEROIFNULL(AVERAGE(ICA.MIN_INV_ADJ_QTY)) +
             ZEROIFNULL(AVERAGE(ICA.SHIP_STD_DEVN_MATL_ADJ_QTY)) + ZEROIFNULL(AVERAGE(ICA.MIN_PROD_RUN_INV_ADJ_QTY)) AS MAX_INV

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
            IC.SRC_CRT_DT >= CAST(SUBSTR(CAST((CURRENT_DATE-1) AS CHAR(10)),1,7) || '-01' AS DATE)

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

ON INV.MATL_ID = MM.MATL_ID AND INV.INV_YEAR = GC.CAL_YR AND INV.INV_MONTH = GC.CAL_MTH


INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
ON MH.MATL_ID = MM.MATL_ID

--LEFT OUTER JOIN                    NA_BI_VWS.NAT_INV_AGG_MTH_BEGIN IB
--ON IB.MATL_ID = MM.MATL_ID AND EXTRACT (YEAR FROM IB.BEG_INV_DT) = GC.CAL_YR AND EXTRACT(MONTH FROM IB.BEG_INV_DT) = GC.CAL_MTH

LEFT OUTER JOIN
(
SELECT
IE.MATL_ID,
EXTRACT (YEAR FROM IE.DAY_DT) AS INV_YEAR,
EXTRACT (MONTH FROM IE.DAY_DT) AS INV_MONTH,
SUM(CASE WHEN SUBSTR(IE.FACILITY_ID,1,2)='N5' THEN IE.TOT_QTY ELSE 0 END) AS FACT_END_INV,
SUM(CASE WHEN IE.FACILITY_ID IN ('N602','N623','N636','N637','N639','N699','N6D3')THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS LC_END_INV,
SUM(CASE WHEN SUBSTR(IE.FACILITY_ID,1,2) <> 'N5' AND
                    IE.FACILITY_ID NOT IN ('N602','N623','N636','N637','N639','N699','N6D3') THEN TOT_QTY + IN_TRANS_QTY ELSE 0 END) AS OTHER_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N602' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N602_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N623' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N623_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N636' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N636_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N637' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N637_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N639' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N639_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N699' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N699_END_INV,
SUM(CASE WHEN IE.FACILITY_ID = 'N6D3' THEN IE.TOT_QTY + IE.IN_TRANS_QTY ELSE 0 END) AS N6D3_END_INV

FROM GDYR_BI_VWS.INV_MTH_END_SNAP IE

GROUP BY
IE.MATL_ID,
INV_YEAR,
INV_MONTH
)INVE

ON INVE.MATL_ID = MM.MATL_ID AND INVE.INV_YEAR = GC.CAL_YR AND INVE.INV_MONTH = GC.CAL_MTH

LEFT OUTER JOIN
(
/*
PSI Monthly - Master

Created: 2014-04-24

This query unions past production plans (effective the Friday before the Monday of the production week),
currently effective production plans for future production weeks and the historical production credits.
Finally, the Production Facility Level Design details are left joined to the production plans & credits to
provide supporting information.

This query is unique at the Busines Month, Material ID & Facility ID level.

*/

SELECT
    PPC.PLN_TYP,

    PPC.BUS_MTH,
    EXTRACT( YEAR FROM PPC.BUS_MTH ) AS PROD_YEAR,
    EXTRACT( MONTH FROM PPC.BUS_MTH ) AS PROD_MONTH,

    PPC.MATL_ID,
    PPC.FACILITY_ID,
    PPC.PLAN_QTY,

    SUM( PPC.PLAN_QTY ) OVER ( PARTITION BY PPC.BUS_MTH, PPC.MATL_ID ) AS TOT_PLAN_QTY,
    PPC.PLAN_QTY / NULLIFZERO( TOT_PLAN_QTY ) AS PLAN_PCT,
    PPC.CREDIT_QTY,

    SUM( PPC.CREDIT_QTY ) OVER ( PARTITION BY PPC.BUS_MTH, PPC.MATL_ID ) AS TOT_CREDIT_QTY,
    PPC.CREDIT_QTY / NULLIFZERO( TOT_CREDIT_QTY ) AS CREDIT_PCT,
    CAST( COUNT( PPC.FACILITY_ID ) OVER ( PARTITION BY PPC.BUS_MTH, PPC.MATL_ID ) AS DECIMAL(15,3) ) AS PPC_FACILITY_ID_CNT,

    LD.LVL_GRP_ID,
    LD.LVL_GRP_ID_CNT,

    LD.GRN_TIRE_CTGY_CD,
    LD.GRN_TIRE_PERD_ON_QTY,
    LD.GRN_TIRE_PERD_OFF_QTY,
    LD.MATL_PERD_ON_QTY,
    LD.MATL_PERD_OFF_QTY,
    LD.MOLD_INV_QTY,
    LD.RING_INV_QTY,
    LD.MOLD_UNAVL_QTY,
    LD.RING_ADJ_INV_QTY,
    LD.RING_REQ_IND,
    LD.MATL_TURN_RT_QTY,
    LD.MATL_INV_QTY,
    LD.DY_SPLY_INV_QTY,
    LD.SRC_FCTR_QTY,
    LD.AVG_MTH_VOL_QTY,
    LD.AVG_MTH_VOL_PCT,
    LD.OE_YIELD_PCT,
    LD.OE_YIELD_RQT_ADJ_QTY,
    LD.MOLD_DY_QTY,
    LD.MOLD_RQT_QTY,
    LD.MOLD_DFCT_QTY,
    LD.SAFE_STK_QTY,
    LD.MATL_MIN_INV_RQT_QTY,
    LD.MATL_CYCL_STK_QTY,
    LD.MATL_MAX_INV_QTY,
    LD.MATL_AVG_INV_QTY,
    LD.PROD_CNSTR_ARRAY_IND,
    LD.LOAD_SAFE_STK_IND,
    LD.MIN_RUN_QTY,
    LD.MATL_DEL_IND

FROM (

    /*
    PSI Monthly - Production Plans & Credits

    Created: 2014-04-23

    Individually aggregates plans & credits to the monthly level, unions the queries together and finally denormalizes to show plans & credits side by side for comparison

    Update: 2014-04-24
    Date logic updates applied
    */

    SELECT
        PPC.PLN_TYP,
        PPC.BUS_MTH,
        PPC.MATL_ID,
        PPC.FACILITY_ID,
        SUM( CASE WHEN PPC.QRY_TYP = 'Production Plan' THEN PPC.PLN_QTY ELSE 0 END ) AS PLAN_QTY,
        SUM( CASE WHEN PPC.QRY_TYP = 'Production Credit' THEN PPC.PLN_QTY ELSE 0 END ) AS CREDIT_QTY

    FROM (

        SELECT
            CAST( 'Production Plan' AS VARCHAR(25)) AS QRY_TYP,
            CAST( CASE WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'History' END AS VARCHAR(25) ) AS PLN_TYP,
            CAL.DAY_DATE AS BUS_DT,
            PP.PROD_WK_DT AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,
            PP.PLN_MATL_ID AS MATL_ID,
            PP.FACILITY_ID,
            CASE
                WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                    THEN ( CASE
                        WHEN ( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                            THEN CEIL( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                        ELSE FLOOR( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                    END )
                ELSE CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000
            END AS PLN_QTY

        FROM GDYR_VWS.GDYR_CAL CAL

            INNER JOIN GDYR_VWS.PROD_PLN PP
                ON CAL.DAY_DATE BETWEEN PP.PROD_WK_DT AND CAST( PP.PROD_WK_DT + 6 AS DATE )
                AND CAST( PP.PROD_WK_DT - 3 AS DATE ) BETWEEN PP.EFF_DT AND PP.EXP_DT
                AND PP.PROD_PLN_CD = '0'
                AND PP.SBU_ID = 2

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = PP.PLN_MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            CAL.DAY_DATE BETWEEN
                CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )
                AND
                (
                    SELECT
                        MAX( PROD_WK_DT ) + 6 AS END_OF_CURRENT_PROD_WK
                    FROM GDYR_VWS.PROD_PLN
                    WHERE
                        SBU_ID = 2
                        AND PROD_PLN_CD = '0'
                        AND PROD_WK_DT < CURRENT_DATE
                )

        UNION ALL

        SELECT
            CAST( 'Production Plan' AS VARCHAR(25)) AS QRY_TYP,
            CAST( CASE WHEN CAL.DAY_DATE / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'Future' END AS VARCHAR(25) ) AS PLN_TYP,
            CAL.DAY_DATE AS BUS_DT,
            PP.PROD_WK_DT AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,
            PP.PLN_MATL_ID AS MATL_ID,
            PP.FACILITY_ID,
            CASE
                WHEN MATL.EXT_MATL_GRP_ID = 'TIRE'
                    THEN ( CASE
                        WHEN ( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 ) MOD 1 >= 0.5000
                            THEN CEIL( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                        ELSE FLOOR( CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000 )
                    END )
                ELSE CAST( PP.PLN_QTY AS DECIMAL(15,3) ) / 7.000
            END AS PLN_QTY

        FROM GDYR_VWS.GDYR_CAL CAL

            INNER JOIN GDYR_VWS.PROD_PLN PP
                ON CAL.DAY_DATE BETWEEN PP.PROD_WK_DT AND CAST( PP.PROD_WK_DT + 6 AS DATE )
                AND PP.EXP_DT = CAST( '5555-12-31' AS DATE )
                AND PP.SBU_ID = 2

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = PP.PLN_MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            CAL.DAY_DATE BETWEEN (
                    SELECT
                        MIN( PP.PROD_WK_DT ) AS BEGIN_OF_NEXT_WK
                    FROM GDYR_VWS.PROD_PLN PP
                    WHERE
                        PP.PROD_PLN_CD = '0'
                        AND PP.SBU_ID = 2
                        AND PP.PROD_WK_DT > CURRENT_DATE
                ) AND
            ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 25 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- END MONTH FOR OF +12 MONTHS
            AND PP.PROD_PLN_CD = (
                CASE
                    WHEN  CAL.DAY_DATE > ( SELECT ( BEGIN_DT + 7 ) + ( 7 * 7 ) FROM GDYR_BI_VWS.GDYR_CAL WHERE CAL.DAY_DATE = CURRENT_DATE )
                        THEN 'A'
                    ELSE '0'
                END
            )

        UNION ALL

        SELECT
            CAST( 'Production Credit' AS VARCHAR(25) ) AS QRY_TYP,
            CAST( CASE WHEN PCD.PROD_DT / 100 = CURRENT_DATE / 100 THEN 'Current Month' ELSE 'History' END AS VARCHAR(25) ) AS PROD_TYP,
            PCD.PROD_DT AS BUS_DT,
            CAST( CASE
                WHEN CAL.DAY_DATE > CAL.BEGIN_DT
                    THEN CAL.BEGIN_DT + 1
                ELSE CAL.BEGIN_DT - 6
            END AS DATE ) AS BUS_WK,
            CAL.MONTH_DT AS BUS_MTH,
            PCD.MATL_ID,
            PCD.FACILITY_ID,
            SUM( ZEROIFNULL( CASE WHEN PCD.PROD_QTY > 0 THEN PCD.PROD_QTY END ) ) AS PROD_QTY

        FROM GDYR_VWS.PROD_CREDIT_DY PCD

            INNER JOIN GDYR_VWS.GDYR_CAL CAL
                ON CAL.DAY_DATE = PCD.PROD_DT
                AND CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND CURRENT_DATE

            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = PCD.MATL_ID
                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

        WHERE
            PCD.PROD_DT >= CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE )
            AND PCD.SBU_ID = 2
            AND PCD.SRC_SYS_ID = 2

        GROUP BY
            QRY_TYP,
            PROD_TYP,
            PCD.PROD_DT,
            BUS_WK,
            CAL.MONTH_DT,
            PCD.MATL_ID,
            PCD.FACILITY_ID

        ) PPC

    GROUP BY
        PPC.PLN_TYP,
        PPC.BUS_MTH,
        PPC.MATL_ID,
        PPC.FACILITY_ID

    HAVING
        PLAN_QTY > 0
        OR CREDIT_QTY > 0

    ) PPC

    LEFT OUTER JOIN (

            /*
            PSI Monthly - Level Design

            Created: 2014-04-23

            Daily Level Design per Facility ID

            Update: 2014-04-24
            -> Updated method of handling multiple active level designs on a given production date. Currently selects the first level design when sorted in ascending order. Additionally, when multiple level designs are present on a given produciton date, level designs are excluded if they have 0 (zero) present for Mold Inventory Qty.
            */

            SELECT
                CAL.MONTH_DT AS BUS_MTH,

                FMC.MATL_ID,
                FMC.FACILITY_ID,

                FMC.LVL_GRP_ID,
                CAST( COUNT( DISTINCT FMC.LVL_GRP_ID ) AS DECIMAL(15,3) ) AS LVL_GRP_ID_CNT,
                FMC.GRN_TIRE_CTGY_CD,
                FMC.GRN_TIRE_PERD_ON_QTY,
                FMC.GRN_TIRE_PERD_OFF_QTY,
                FMC.MATL_PERD_ON_QTY,
                FMC.MATL_PERD_OFF_QTY,
                FMC.MOLD_INV_QTY,
                FMC.RING_INV_QTY,
                FMC.MOLD_UNAVL_QTY,
                FMC.RING_ADJ_INV_QTY,
                FMC.RING_REQ_IND,
                FMC.MATL_TURN_RT_QTY,
                FMC.MATL_INV_QTY,
                FMC.DY_SPLY_INV_QTY,
                FMC.SRC_FCTR_QTY,
                FMC.AVG_MTH_VOL_QTY,
                FMC.AVG_MTH_VOL_PCT,
                FMC.OE_YIELD_PCT,
                FMC.OE_YIELD_RQT_ADJ_QTY,
                FMC.MOLD_DY_QTY,
                FMC.MOLD_RQT_QTY,
                FMC.MOLD_DFCT_QTY,
                FMC.SAFE_STK_QTY,
                FMC.MATL_MIN_INV_RQT_QTY,
                FMC.MATL_CYCL_STK_QTY,
                FMC.MATL_MAX_INV_QTY,
                FMC.MATL_AVG_INV_QTY,
                FMC.PROD_CNSTR_ARRAY_IND,
                FMC.LOAD_SAFE_STK_IND,
                FMC.MIN_RUN_QTY,
                FMC.MATL_DEL_IND

            FROM GDYR_BI_VWS.GDYR_CAL CAL

                INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                    ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                    AND FMC.LVL_DESIGN_EFF_DT <= CAL.DAY_DATE
                    AND FMC.LVL_DESIGN_STA_CD = 'A'
                    AND FMC.SBU_ID = 2

                INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                    ON MATL.MATL_ID = FMC.MATL_ID
                    AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

                INNER JOIN (
                        SELECT
                            CAL.DAY_DATE AS BUS_DT,
                            MAX( FMC.LVL_DESIGN_EFF_DT ) AS MAX_LD_EFF_DT,
                            FMC.MATL_ID,
                            FMC.FACILITY_ID

                        FROM GDYR_BI_VWS.GDYR_CAL CAL

                            INNER JOIN NA_VWS.FACL_MATL_CYCASGN FMC
                                ON CAL.DAY_DATE BETWEEN FMC.EFF_DT AND FMC.EXP_DT
                                AND FMC.LVL_DESIGN_EFF_DT <= CAL.DAY_DATE
                                AND FMC.LVL_DESIGN_STA_CD = 'A'
                                AND FMC.SBU_ID = 2

                            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                                ON MATL.MATL_ID = FMC.MATL_ID
                                AND MATL.PBU_NBR IN ( '01', '03', '04', '05', '07', '08', '09' )

                        WHERE
                            CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND
                                ( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 25 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) -- END OF 12TH MONTH

                        GROUP BY
                            CAL.DAY_DATE,
                            FMC.MATL_ID,
                            FMC.FACILITY_ID
                        ) LIM
                    ON LIM.BUS_DT = CAL.DAY_DATE
                    AND LIM.MAX_LD_EFF_DT = FMC.LVL_DESIGN_EFF_DT
                    AND LIM.MATL_ID = FMC.MATL_ID
                    AND LIM.FACILITY_ID = FMC.FACILITY_ID

            WHERE
                CAL.DAY_DATE BETWEEN CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, -24 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) AND
                                CAST(( CAST( SUBSTR( CAST( ADD_MONTHS( CURRENT_DATE, 25 ) AS CHAR(10) ), 1, 7 ) || '-01' AS DATE ) - 1 ) AS DATE) -- END OF 12TH MONTH

            GROUP BY
                CAL.MONTH_DT,

                FMC.MATL_ID,
                FMC.FACILITY_ID,

                FMC.LVL_GRP_ID,
                FMC.GRN_TIRE_CTGY_CD,
                FMC.GRN_TIRE_PERD_ON_QTY,
                FMC.GRN_TIRE_PERD_OFF_QTY,
                FMC.MATL_PERD_ON_QTY,
                FMC.MATL_PERD_OFF_QTY,
                FMC.MOLD_INV_QTY,
                FMC.RING_INV_QTY,
                FMC.MOLD_UNAVL_QTY,
                FMC.RING_ADJ_INV_QTY,
                FMC.RING_REQ_IND,
                FMC.MATL_TURN_RT_QTY,
                FMC.MATL_INV_QTY,
                FMC.DY_SPLY_INV_QTY,
                FMC.SRC_FCTR_QTY,
                FMC.AVG_MTH_VOL_QTY,
                FMC.AVG_MTH_VOL_PCT,
                FMC.OE_YIELD_PCT,
                FMC.OE_YIELD_RQT_ADJ_QTY,
                FMC.MOLD_DY_QTY,
                FMC.MOLD_RQT_QTY,
                FMC.MOLD_DFCT_QTY,
                FMC.SAFE_STK_QTY,
                FMC.MATL_MIN_INV_RQT_QTY,
                FMC.MATL_CYCL_STK_QTY,
                FMC.MATL_MAX_INV_QTY,
                FMC.MATL_AVG_INV_QTY,
                FMC.PROD_CNSTR_ARRAY_IND,
                FMC.LOAD_SAFE_STK_IND,
                FMC.MIN_RUN_QTY,
                FMC.MATL_DEL_IND

            QUALIFY
                ( CASE WHEN COUNT(*) OVER ( PARTITION BY CAL.MONTH_DT, FMC.MATL_ID, FMC.FACILITY_ID ) > 1 THEN FMC.MOLD_INV_QTY ELSE 1 END ) > 0
                AND ROW_NUMBER( ) OVER ( PARTITION BY CAL.MONTH_DT, FMC.MATL_ID, FMC.FACILITY_ID ORDER BY FMC.LVL_GRP_ID ) = 1

            ) LD
        ON LD.BUS_MTH = PPC.BUS_MTH
        AND LD.MATL_ID = PPC.MATL_ID
        AND LD.FACILITY_ID = PPC.FACILITY_ID

    ) MTI

ON MTI.MATL_ID = MM.MATL_ID AND MTI.PROD_YEAR = GC.CAL_YR AND MTI.PROD_MONTH = GC.CAL_MTH

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
MM.EXT_MATL_GRP_ID = 'TIRE'
AND MM.PBU_NBR IN ('01','03')
-- AND MM.MATL_ID ='000000000000019032'
AND GC.DAY_DATE = GC.MONTH_DT
AND GC.CAL_YR > 2012
AND ("Sales Plan Lag0" + "Sales Plan Lag2" + /*"Billed Units" +*/ "Order Qty" + "Ship Qty" + "No Stock Qty") > .9