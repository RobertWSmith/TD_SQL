SELECT
    CAST('BI' AS VARCHAR(25)) AS DATA_TYPE
    , CAL.DAY_DATE AS RPT_DT
    , ADD_MONTHS(CAL.MONTH_DT, 1) AS RPT_MTH_DT

    , I.MATL_ID

    , I.FACILITY_ID
    , F.SALES_ORG_CD AS FACL_SALES_ORG_CD
    , F.DISTR_CHAN_CD AS FACL_DISTR_CHAN_CD

    , I.INV_QTY_UOM
    , I.TOT_QTY
    , I.IN_TRANS_QTY
    , I.TOT_QTY + I.IN_TRANS_QTY AS GROSS_QTY

FROM NA_BI_VWS.FACL_MATL_INV I

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = I.DAY_DT

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
        ON M.MATL_ID = I.MATL_ID

    INNER JOIN GDYR_BI_VWS.NAT_FACILITY_EN_CURR F
        ON F.FACILITY_ID = I.FACILITY_ID

WHERE
    CAL.CAL_LAST_DAY_MO_IND = 'Y'
    AND M.MATL_TYPE_ID = 'PCTL'
    AND M.EXT_MATL_GRP_ID = 'TIRE'
    AND M.PBU_NBR = CAST(#prompt('P_PBU', 'text', '''01''')# AS CHAR(2))
    AND CAL.CAL_YR = CAST(#prompt('P_CalYear', 'integer', '2014')# AS INTEGER)
    AND CAL.CAL_MTH BETWEEN (
        CASE
            WHEN CAST(#prompt('P_BeginCalMonth', 'integer', '1')# AS INTEGER) - 1 = 0
                THEN 12
            ELSE CAST(#prompt('P_BeginCalMonth', 'integer', '1')# AS INTEGER) - 1
        END) 
        AND (
        CASE
            WHEN CAST(#prompt('P_EndCalMonth', 'integer', '12')# AS INTEGER) - 1 = 0
                THEN 12
            ELSE CAST(#prompt('P_EndCalMonth', 'integer', '12')# AS INTEGER) - 1
        END)
