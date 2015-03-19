SELECT
    CUST.OWN_CUST_ID AS "Common Owner ID"
    , CUST.OWN_CUST_NAME AS "Common Owner Name"
    , ODMS.ORDER_ID AS "Order ID"
    , ODMS.ORDER_LINE_NBR AS "Order Line"
    , MATL.MATL_NO_8 AS "Material ID"
    , MATL.DESCR AS "Material Desc"
    , ODMS.FACILITY_ID AS "Ship Facility"
    , FAC.FACILITY_NAME AS "Ship Facility Name"
    , SF.SRC_FACILITY_ID AS "Source Facility"
    , SF.SRC_FACILITY_NAME AS "Source Facility Name"
    , SUM(ODMS.OPEN_ORDER_TOT_QTY) AS "Open Order Qty"
    , MATL.PBU_NBR AS "PBU"
    , PSC.SRC_CRT_DT AS "0 ATP Date"
    
FROM NA_BI_VWS.CLCT_PROC_ERR_LOG_CURR ELC

    INNER JOIN NA_BI_VWS.CLCT_PROC_SD_CURR PSC
        ON PSC.FISCAL_YR = ELC.FISCAL_YR
        AND PSC.PROC_GRP_ID = ELC.PROC_GRP_ID

    INNER JOIN NA_BI_VWS.ORDER_DETAIL ODS
        ON ODS.ORDER_FISCAL_YR = ELC.SD_DOC_FISCAL_YR
        AND ODS.ORDER_ID = ELC.SLS_DOC_ID
        AND ODS.ORDER_LINE_NBR = ELC.SLS_DOC_ITM_ID
        AND ODS.SCHED_LINE_NBR = 1
        AND ODS.EXP_DT = CAST('5555-12-31' AS DATE)
        AND ODS.ORDER_CAT_ID = 'C'
        AND ODS.RO_PO_TYPE_IND = 'N'

    INNER JOIN NA_BI_VWS.ORD_DLV_MTH_SMRY ODMS
       ON ODMS.ORDER_FISCAL_YR = ELC.SD_DOC_FISCAL_YR
       AND ODMS.ORDER_ID = ELC.SLS_DOC_ID
       AND ODMS.ORDER_LINE_NBR = ELC.SLS_DOC_ITM_ID
       AND ODMS.REF_DT = PSC.SRC_CRT_DT

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = ODMS.SHIP_TO_CUST_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
        ON MATL.MATL_ID = ODMS.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR FAC
        ON FAC.FACILITY_ID = ODMS.FACILITY_ID

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
                    AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
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
        ON SF.SHIP_FACILITY_ID = ODMS.FACILITY_ID
        AND SF.MATL_ID = ODMS.MATL_ID

WHERE
    ELC.SYS_MSG_CD = '150'
    AND PSC.SRC_CRT_DT = DATE - 1
    --AND PSC.SRC_CRT_DT BETWEEN '2014-10-01' AND DATE - 1
    --AND PSC.SRC_CRT_DT >= DATE - (EXTRACT(DAY FROM DATE)-1)
    AND MATL.PBU_NBR IN ('01','03')
    AND MATL.EXT_MATL_GRP_ID = 'TIRE'
    AND ODS.CUST_GRP2_CD = 'TLB'

GROUP BY
    CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    , ODMS.ORDER_ID
    , ODMS.ORDER_LINE_NBR
    , MATL.MATL_NO_8
    , MATL.DESCR
    , SF.SRC_FACILITY_ID
    , SF.SRC_FACILITY_NAME
    , ODMS.FACILITY_ID
    , FAC.FACILITY_NAME
    , MATL.PBU_NBR
    , PSC.SRC_CRT_DT

ORDER BY
    MATL.MATL_NO_8
    , ODMS.FACILITY_ID
    , CUST.OWN_CUST_ID
    , SF.SRC_FACILITY_ID
    , ODMS.FACILITY_ID
    , PSC.SRC_CRT_DT
