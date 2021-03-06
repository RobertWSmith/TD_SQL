﻿SELECT
    CAST('R32' AS VARCHAR(3)) AS DATA_CTGY
    , CAST('EI' AS VARCHAR(25)) AS DATA_TYPE
    , CAL.MONTH_DT AS RPT_MTH_DT
    , I.FACILITY_ID
    , I.MATL_ID

    , I.INV_QTY_UOM
    , I.TOT_QTY
    , I.IN_TRANS_QTY
    , I.TOT_QTY + I.IN_TRANS_QTY AS GROSS_QTY

FROM NA_BI_VWS.FACL_MATL_INV I

    INNER JOIN GDYR_BI_VWS.GDYR_CAL CAL
        ON CAL.DAY_DATE = I.DAY_DT
        AND CAL.CAL_LAST_DAY_MO_IND = 'Y'

WHERE
    -- OFFSETTING THE MONTHS BY ONE TO GET END OF MONTH INVENTORY
    I.DAY_DT BETWEEN CAST(#sq(prompt('P_BeginDate', 'date'))# AS DATE)
        AND CAST(#sq(prompt('P_EndDate', 'date'))# AS DATE)

    -- USING THE PBU PROMPT TO FILTER THE MATERIAL HIERARCHY
    AND I.MATL_ID IN (
            SELECT
                MATL_ID
            FROM GDYR_BI_VWS.NAT_MATL_CURR
            WHERE
                MATL_TYPE_ID = 'PCTL'
                AND EXT_MATL_GRP_ID = 'TIRE'
                --AND PBU_NBR = CAST('01' AS CHAR(2))
                AND PBU_NBR = CAST(#prompt('P_PBU', 'text')# AS CHAR(2))
        )
