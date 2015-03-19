WITH MY_CALENDAR (DAY_DATE) AS (
    SELECT
        DAY_DATE
    
    FROM GDYR_BI_VWS.GDYR_CAL
    
    WHERE
        DAY_DATE BETWEEN CURRENT_DATE+1 AND ADD_MONTHS(CURRENT_DATE+1, 1)
)

SELECT
    TLC.DELIV_DT
    , TLC.CUST_ID
    , CUST.CUST_NAME
    
    , CUST.DISTRICT_NAME
    , CUST.CITY_NAME
    , CUST.TERR_NAME
    , CUST.POSTAL_CD
    , CUST.CNTRY_NAME_CD
    
    , CUST.OWN_CUST_ID
    , CUST.OWN_CUST_NAME
    
    , TLC.TL_PLN_CD
    , CASE
        WHEN TLC.TL_PLN_CD IS NULL
            THEN 'Not Planned'
        WHEN TLC.TL_PLN_CD = 'M'
            THEN 'Minimum Planned'
        WHEN TLC.TL_PLN_CD = 'X'
            THEN 'Full Truckload Planned'
        ELSE 'Not Planned'
        END AS TL_PLN_DESC
    
    , TLC.TL_SEQ_ID
    --, TLC.RPT_TL_SEQ_ID
    
    , TLC.DELIV_GRP_CD
    
    , TLM.FACILITY_ID
    , TLM.ITM_QTY
    
    , TLC.TRLR_TYP_ID
    , TRL.TRLR_TYP_DESC

    , TLC.MIN_WT_QTY
    , TLM.ITM_GROSS_WT
    , TRL.MAX_WT_QTY
    , CASE
        WHEN TLM.ITM_GROSS_WT BETWEEN TLC.MIN_WT_QTY AND TRL.MAX_WT_QTY OR TLC.TL_PLN_CD IS NULL
            THEN 'ok'
        WHEN TLM.ITM_GROSS_WT > TRL.MAX_WT_QTY
            THEN 'high'
        ELSE 'low'
        END AS TEST_GROSS_WT

    , TLM.ITM_VOL
    , TRL.VOL_QTY AS MAX_VOL_QTY
    , CASE
        WHEN TLM.ITM_VOL <= TRL.VOL_QTY OR TLC.TL_PLN_CD IS NULL
            THEN 'ok'
        ELSE 'high'
        END AS TEST_VOL
    
FROM NA_BI_vWS.TL_CAP_DELIV_SCHD_CURR TLC

    INNER JOIN MY_CALENDAR CAL
        ON CAL.DAY_DATE = TLC.DELIV_DT

    INNER JOIN NA_BI_vWS.TL_TRLR_MSTR_CURR TRL
        ON TRL.TRLR_TYP_ID = TLC.TRLR_TYP_ID

    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
        ON CUST.SHIP_TO_CUST_ID = TLC.CUST_ID

    LEFT OUTER JOIN (
            SELECT
                TLM.CUST_ID
                , TLM.DELIV_GRP_CD
                , TLM.DELIV_DT
                , TLM.FACILITY_ID
                , SUM(TLM.ITM_QTY) AS ITM_QTY
                , SUM(TLM.GROSS_WT_QTY) AS ITM_GROSS_WT
                , SUM(TLM.VOL_QTY) AS ITM_VOL
            
            FROM NA_BI_VWS.TL_MSTR_CURR TLM
                
                INNER JOIN MY_CALENDAR CAL
                    ON CAL.DAY_DATE = TLM.DELIV_DT
            
            GROUP BY
                TLM.CUST_ID
                , TLM.DELIV_GRP_CD
                , TLM.DELIV_DT
                , TLM.FACILITY_ID
        ) TLM
        ON TLM.CUST_ID = TLC.CUST_ID
        AND TLM.DELIV_DT = TLC.DELIV_DT
        AND TLM.DELIV_GRP_CD = TLC.DELIV_GRP_CD

ORDER BY
    TLC.DELIV_DT
    , TLC.CUST_ID
    