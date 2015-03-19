﻿SELECT
    DDI.FISCAL_YR
    , DDI.DELIV_DOC_ID
    , DDI.DELIV_DOC_ITM_ID
    
    , DD.SRC_CRT_TS AS DOC_SRC_CRT_TS
    , DDI.SRC_CRT_TS AS ITM_SRC_CRT_TS
    
    , DDI.DELIV_GRP_CD
    
FROM NA_BI_VWS.NAT_DELIV_DOC_ITM_CURR DDI

    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR MATL
        ON MATL.MATL_ID = DDI.MATL_ID
        AND MATL.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
        
    INNER JOIN NA_BI_VWS.NAT_DELIV_DOC_CURR DD
        ON DD.FISCAL_YR = DDI.FISCAL_YR
        AND DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
        AND DD.SD_DOC_CTGY_CD = 'J'
        AND DD.SRC_CRT_TS >= CAST('2013-01-01 00:00:00' AS TIMESTAMP(0))
        AND DD.ACTL_GOODS_MVT_DT >= DATE '2014-01-01'
        AND DD.TOT_WT_QTY > 0

WHERE
    DDI.DISTR_CHAN_CD <> '81'
    AND DDI.SRC_CRT_TS >= CAST('2013-01-01 00:00:00' AS TIMESTAMP(0))
    AND DDI.CUST_GRP_ID_2 = 'TLB'
    AND DDI.TOT_GROSS_WT_QTY > 0

ORDER BY
    DDI.FISCAL_YR
    , DDI.DELIV_DOC_ID
    , DDI.DELIV_DOC_ITM_ID

