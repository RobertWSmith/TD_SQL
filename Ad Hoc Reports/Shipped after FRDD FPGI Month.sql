SELECT
    CAL.MONTH_DT AS ACTL_GOODS_ISS_MTH
    , COALESCE(OD.FRST_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.FRST_PLN_GOODS_ISS_DT) - 1), FCDD_FPGI_MTH) AS FRDD_FPGI_MTH
    , CASE
        WHEN OD.FC_PLN_GOODS_ISS_DT IS NOT NULL
            THEN OD.FC_PLN_GOODS_ISS_DT - (EXTRACT(DAY FROM OD.FC_PLN_GOODS_ISS_DT) - 1) 
        WHEN OD.FRST_PROM_DELIV_dt IS NOT NULL
            THEN OD.FRST_PROM_DELIV_DT - (OD.FRST_RDD - OD.FRST_PLN_GOODS_ISS_DT) - (EXTRACT(DAY FROM (OD.FRST_PROM_DELIV_DT - (OD.FRST_RDD - OD.FRST_PLN_GOODS_ISS_DT))) - 1)
        ELSE OD.PLN_DELIV_DT - (EXTRACT(DAY FROM OD.PLN_DELIV_DT) - 1)
        END AS FCDD_FPGI_MTH

    , CASE
        WHEN FRDD_FPGI_MTH = FCDD_FPGI_MTH
            THEN 'FRDD = FCDD'
        WHEN FRDD_FPGI_MTH > FCDD_FPGI_MTH
            THEN 'FRDD > FCDD'
        WHEN FRDD_FPGI_MTH < FCDD_FPGI_MTH
            THEN 'FRDD < FCDD'
        END AS FRDD_FCDD_MONTH_TEST

    , CAST((FCDD_FPGI_MTH - FRDD_FPGI_MTH MONTH(4)) AS INTEGER) AS FRDD_FPGI_TO_FCDD_FPGI_MONTHS
    , CAST((CAL.MONTH_DT - FRDD_FPGI_MTH MONTH(4)) AS INTEGER) AS FRDD_FPGI_TO_AGID_MONTHS
    , CAST((CAL.MONTH_DT - FCDD_FPGI_MTH MONTH(4)) AS INTEGER) AS FCDD_FPGI_TO_AGID_MONTHS

    , CASE
        WHEN FRDD_FPGI_TO_AGID_MONTHS > 12
            THEN '> +12 Months'
        WHEN FRDD_FPGI_TO_AGID_MONTHS BETWEEN 10 AND 12
            THEN '+10-12 Months'
        WHEN FRDD_FPGI_TO_AGID_MONTHS BETWEEN 7 AND 9
            THEN '+7-9 Months'
        WHEN FRDD_FPGI_TO_AGID_MONTHS BETWEEN 4 AND 6
            THEN '+4-6 Months'
        WHEN FRDD_FPGI_TO_AGID_MONTHS BETWEEN 2 AND 3
            THEN TRIM('+' || CAST(FRDD_FPGI_TO_AGID_MONTHS AS CHAR(1))) || ' Months'
        WHEN FRDD_FPGI_TO_AGID_MONTHS = 1
            THEN '+1 Month'
        WHEN FRDD_FPGI_TO_AGID_MONTHS <= 0
            THEN (CASE
                WHEN DDC.ACTL_GOODS_ISS_DT > OD.FRST_PLN_GOODS_ISS_DT
                    THEN '< +1 Month'
                ELSE 'AGID <= FRDD FPGI'
            END)
        END AS FRDD_TIME_PAST_DUE

    , CASE
        WHEN FCDD_FPGI_TO_AGID_MONTHS > 12
            THEN '> +12 Months'
        WHEN FCDD_FPGI_TO_AGID_MONTHS BETWEEN 10 AND 12
            THEN '+10-12 Months'
        WHEN FCDD_FPGI_TO_AGID_MONTHS BETWEEN 7 AND 9
            THEN '+7-9 Months'
        WHEN FCDD_FPGI_TO_AGID_MONTHS BETWEEN 4 AND 6
            THEN '+4-6 Months'
        WHEN FCDD_FPGI_TO_AGID_MONTHS BETWEEN 2 AND 3
            THEN TRIM('+' || CAST(FCDD_FPGI_TO_AGID_MONTHS AS CHAR(1))) || ' Months'
        WHEN FCDD_FPGI_TO_AGID_MONTHS = 1
            THEN '+1 Month'
        WHEN FCDD_FPGI_TO_AGID_MONTHS = 0
            THEN (CASE
                WHEN DDC.ACTL_GOODS_ISS_DT > OD.FC_PLN_GOODS_ISS_DT
                    THEN '< +1 Month'
                ELSE 'AGID <= FCDD FPGI'
            END)
        END AS FCDD_TIME_PAST_DUE

    , CASE
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS > 12
            THEN '> +12 Months'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS BETWEEN 10 AND 12
            THEN '+10-12 Months'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS BETWEEN 7 AND 9
            THEN '+7-9 Months'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS BETWEEN 4 AND 6
            THEN '+4-6 Months'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS BETWEEN 2 AND 3
            THEN TRIM('+' || CAST(FRDD_FPGI_TO_FCDD_FPGI_MONTHS AS CHAR(1))) || ' Months'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS = 1
            THEN '+1 Month'
        WHEN FRDD_FPGI_TO_FCDD_FPGI_MONTHS = 0
            THEN (CASE
                WHEN OD.FC_PLN_GOODS_ISS_DT > OD.FRST_PLN_GOODS_ISS_DT
                    THEN '< +1 Month'
                ELSE 'FRDD FPGI >= FCDD FPGI'
            END)
        END AS FCDD_TIME_PAST_FRDD

    , CUST.SALES_ORG_CD || ' - ' || CUST.SALES_ORG_NAME AS SALES_ORG
    , CUST.DISTR_CHAN_CD || ' - ' || CUST.DISTR_CHAN_NAME AS DISTR_CHAN
    , CUST.CUST_GRP_ID || ' - ' || CUST.CUST_GRP_NAME AS CUST_GRP
    , CUST.OWN_CUST_ID || ' - ' || CUST.OWN_CUST_NAME AS OWN_CUST

    , CASE
        WHEN CUST.TIRE_CUST_TYP_CD = 'NA'
            THEN 'REPL'
        ELSE CUST.TIRE_CUST_TYP_CD
        END AS OE_REPL_IND

    , CASE
        WHEN CUST.PRIM_SHIP_FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
            THEN 'Primary LC'
        WHEN DDC.DELIV_LINE_FACILITY_ID LIKE 'N5%'
            THEN 'Factory Direct'
        ELSE 'Out of Area'
        END AS TEST_PRIM_SHIP_FACILITY
    , CUST.PRIM_SHIP_FACILITY_ID
    , FAC.FACILITY_ID || ' - ' || FAC.FACILITY_NAME AS FACILITY
    , SF.SRC_FACILITY_ID || ' - ' || SF.SRC_FACILITY_NAME AS SRC_FACILITY

    --, MATL.MATL_ID
    --, MATL.MATL_NO_8 || ' - ' || MATL.DESCR AS MATL_DESCR
    --, MATL.TIC_CD
    , CASE
        WHEN MATL.PBU_NBR = '01'
            THEN MATL.MKT_CTGY_PROD_GRP_NAME
        ELSE MATL.TIERS
        END AS TIER
    , MATL.HVA_TXT
    , MATL.HMC_TXT

    , MATL.PBU_NBR || ' - ' || MATL.PBU_NAME AS PBU
    , MATL.MKT_CTGY_MKT_AREA_NBR || ' - ' || MATL.MKT_CTGY_MKT_AREA_NAME AS CATEGORY_DESC
    , MATL.MKT_CTGY_MKT_GRP_NBR || ' - ' || MATL.MKT_CTGY_MKT_GRP_NAME AS SEGMENT_DESC
    , MATL.MKT_CTGY_PROD_GRP_NBR || ' - ' || MATL.MKT_CTGY_PROD_GRP_NAME AS SALES_PROD_GRP
    , MATL.MKT_CTGY_PROD_LINE_NBR || ' - ' || MATL.MKT_CTGY_PROD_LINE_NAME AS SALES_PROD_LINE

    , DDC.QTY_UNIT_MEAS_ID AS QTY_UOM
    , SUM(DDC.DELIV_QTY) AS DELIV_QTY
/*    , SUM(CASE
        WHEN POL.NO_STK_DT IS NOT NULL AND POL.IF_HIT_NS_QTY > 0
            THEN DDC.DELIV_QTY
        ELSE 0
        END) AS PAST_DUE_DELIV_QTY*/

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
        AND FAC.SALES_ORG_CD IN ('N306', 'N316', 'N326')
        AND FAC.DISTR_CHAN_CD = '81'

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = DDC.MATL_ID
        AND MATL.PBU_NBR = '01'

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = DDC.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = DDC.ACTL_GOODS_ISS_DT
        AND CAL.CAL_YR = EXTRACT(YEAR FROM CURRENT_DATE-1)
--        AND CAL.DAY_DATE >= CURRENT_DATE-90

    INNER JOIN NA_BI_VWS.ORDER_DETAIL OD
        ON OD.ORDER_FISCAL_YR = DDC.ORDER_FISCAL_YR
        AND OD.ORDER_ID = DDC.ORDER_ID
        AND OD.ORDER_LINE_NBR = DDC.ORDER_LINE_NBR
        AND OD.SCHED_LINE_NBR = 1
        AND OD.EXP_DT = DATE '5555-12-31'
        AND OD.ORDER_CAT_ID = 'C'
        AND OD.RO_PO_TYPE_IND = 'N'
        AND OD.FRST_RDD >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1)-1 || '-01-01' AS DATE)

    LEFT OUTER JOIN (
            SELECT
                FM.FACILITY_ID AS SHIP_FACILITY_ID
                , FM.MATL_ID AS MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , CAST( CASE FM.SPCL_PRCU_TYP_CD
                    WHEN 'AA' THEN 'N501'
                    WHEN 'AB' THEN 'N502'
                    WHEN 'AC' THEN 'N503'
                    WHEN 'AD' THEN 'N504'
                    WHEN 'AE' THEN 'N505'
                    WHEN 'AH' THEN 'N508'
                    WHEN 'AI' THEN 'N509'
                    WHEN 'AJ' THEN 'N510'
                    WHEN 'AM' THEN 'N513'
                    WHEN 'S1' THEN 'N6BD'
                    WHEN 'S2' THEN 'N6BE'
                    WHEN 'S4' THEN 'N6BS'
                    WHEN 'S6' THEN 'N6J2'
                    WHEN 'S7' THEN 'N6J3'
                    WHEN 'S8' THEN 'N6J4'
                    WHEN 'S9' THEN 'N6J7'
                    WHEN 'SA' THEN 'N526'
                    WHEN 'SC' THEN 'N6A1'
                    WHEN 'SD' THEN 'N6A2'
                    WHEN 'SE' THEN 'N6A3'
                    WHEN 'SF' THEN 'N6A4'
                    WHEN 'SG' THEN 'N6A6'
                    WHEN 'SH' THEN 'N6A8'
                    WHEN 'SI' THEN 'N6A9'
                    WHEN 'SJ' THEN 'N6AA'
                    WHEN 'SL' THEN 'N6AC'
                    WHEN 'SM' THEN 'N6AE'
                    WHEN 'SN' THEN 'N6AG'
                    WHEN 'SO' THEN 'N6AH'
                    WHEN 'SQ' THEN 'N6AK'
                    WHEN 'SR' THEN 'N6AL'
                    WHEN 'SS' THEN 'N6J8'
                    WHEN 'ST' THEN 'N6AO'
                    WHEN 'SU' THEN 'N6AQ'
                    WHEN 'SV' THEN 'N6AR'
                    WHEN 'SW' THEN 'N6AS'
                    WHEN 'SX' THEN 'N6AT'
                    WHEN 'SY' THEN 'N6AX'
                    WHEN 'SZ' THEN 'N6BB'
                    WHEN 'WA' THEN 'N637'
                    WHEN 'WB' THEN 'N636'
                    WHEN 'WF' THEN 'N623'
                    WHEN 'WG' THEN 'N639'
                    WHEN 'WH' THEN 'N699'
                    WHEN 'WK' THEN 'N602'
                    ELSE COALESCE(FMX.FACILITY_ID, '')
                    END AS CHAR(4) ) AS SRC_FACILITY_ID
                , SF.FACILITY_NAME AS SRC_FACILITY_NAME

            FROM GDYR_VWS.FACILITY_MATL FM

                INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                    ON M.MATL_ID = FM.MATL_ID
                    AND M.PBU_NBR = '01' -- IN ('01', '03', '04', '05', '07', '08', '09')
                    AND M.MATL_TYPE_ID IN ('PCTL', 'ACCT')

                LEFT OUTER JOIN GDYR_VWS.FACILITY_MATL FMX
                    ON FMX.MATL_ID = FM.MATL_ID
                    AND FMX.ORIG_SYS_ID = 2
                    AND FMX.EXP_DT = DATE '5555-12-31'
                    AND FMX.MRP_TYPE_ID = 'X0'
                
                INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
                    ON F.FACILITY_ID = FM.FACILITY_ID
                    AND F.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND F.DISTR_CHAN_CD = '81'
                
                INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR SF
                    ON SF.FACILITY_ID = SRC_FACILITY_ID
                    AND SF.SALES_ORG_CD IN ('N306', 'N316', 'N326')
                    AND SF.DISTR_CHAN_CD = '81'
                
            WHERE
                FM.EXP_DT = DATE '5555-12-31'
                AND FM.MRP_TYPE_ID = 'XB'
                AND FM.ORIG_SYS_ID = 2
                AND FMX.EXP_DT = DATE '5555-12-31'

            GROUP BY
                FM.FACILITY_ID
                , FM.MATL_ID
                , M.PBU_NBR
                , M.MATL_STA_ID
                , SRC_FACILITY_ID
                , SRC_FACILITY_NAME
            ) SF
        ON SF.SHIP_FACILITY_ID = DDC.DELIV_LINE_FACILITY_ID
        AND SF.MATL_ID = DDC.MATL_ID

/*    LEFT OUTER JOIN NA_BI_VWS.PRFCT_ORD_LINE POL
        ON POL.ORDER_ID = DDC.ORDER_ID
        AND POL.ORDER_LINE_NBR = DDC.ORDER_LINE_NBR
        AND POL.CMPL_IND = 1
        AND POL.CMPL_DT < CURRENT_DATE
        AND POL.PRFCT_ORD_HIT_SORT_KEY <> 99*/

WHERE
    DDC.GOODS_ISS_IND = 'Y'
    AND DDC.ACTL_GOODS_ISS_DT IS NOT NULL
    AND DDC.DELIV_CAT_ID = 'J'
    AND DDC.DELIV_QTY > 0
    AND DDC.SALES_ORG_CD NOT IN ('N306', 'N316', 'N326')
    AND DDC.DISTR_CHAN_CD <> '81'

GROUP BY
    ACTL_GOODS_ISS_MTH
    , FRDD_FPGI_MTH
    , FCDD_FPGI_MTH
    
    , FRDD_FCDD_MONTH_TEST
    
    , FRDD_FPGI_TO_FCDD_FPGI_MONTHS
    , FRDD_FPGI_TO_AGID_MONTHS
    , FCDD_FPGI_TO_AGID_MONTHS
    
    , FRDD_TIME_PAST_DUE
    , FCDD_TIME_PAST_DUE
    , FCDD_TIME_PAST_FRDD
    
    , SALES_ORG
    , DISTR_CHAN
    , CUST_GRP
    , OWN_CUST

    , OE_REPL_IND
    
    , TEST_PRIM_SHIP_FACILITY
    , CUST.PRIM_SHIP_FACILITY_ID
    , FACILITY
    , SRC_FACILITY
    
    --, MATL.MATL_ID
    --, MATL_DESCR
    --, MATL.TIC_CD
    , TIER
    , MATL.HVA_TXT
    , MATL.HMC_TXT
    
    , PBU
    , CATEGORY_DESC
    , SEGMENT_DESC
    , SALES_PROD_GRP
    , SALES_PROD_LINE
    
    , QTY_UOM
