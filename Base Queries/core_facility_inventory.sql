SELECT
    FMI.MATL_ID
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N602' THEN FMI.AVAIL_TO_PROM_QTY END) AS LOCKBOURNE_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N602' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS LOCKBOURNE_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N607' THEN FMI.AVAIL_TO_PROM_QTY END) AS MCDONOUGH_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N607' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS MCDONOUGH_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N623' THEN FMI.AVAIL_TO_PROM_QTY END) AS STOCKBRIDGE_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N623' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS STOCKBRIDGE_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N636' THEN FMI.AVAIL_TO_PROM_QTY END) AS YORK_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N636' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS YORK_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N637' THEN FMI.AVAIL_TO_PROM_QTY END) AS DEKALB_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N637' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS DEKALB_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N699' THEN FMI.AVAIL_TO_PROM_QTY END) AS VICTORVILLE_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N699' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS VICTORVILLE_EST_DSI
    
    , MAX(CASE WHEN FMI.FACILITY_ID = 'N6D3' THEN FMI.AVAIL_TO_PROM_QTY END) AS SHELBY_ATP
    , MAX(CASE 
        WHEN FMI.FACILITY_ID = 'N6D3' 
            THEN (CASE
                WHEN FMI.EST_DAYS_SUPPLY < 15
                    THEN 'Less than 15 DSI'
                WHEN FMI.EST_DAYS_SUPPLY BETWEEN 15 AND 30
                    THEN 'Between 15 and 30 DSI'
                WHEN FMI.EST_DAYS_SUPPLY > 30
                    THEN 'Greater than 30 DSI'
            END)
        END) AS SHELBY_EST_DSI
    , MAX_DSI.FACILITY_ID AS MAX_DSI_FACILITY_ID
    , MAX_DSI.AVAIL_TO_PROM_QTY AS MAX_DSI_ATP_QTY
    , MAX_DSI.EST_DAYS_SUPPLY AS MAX_DSI_EST_DSI

FROM NA_BI_VWS.FACILITY_MATL_INVENTORY FMI

    INNER JOIN (
                SELECT
                    F.MATL_ID
                    , F.FACILITY_ID
                    , F.AVAIL_TO_PROM_QTY
                    , F.EST_DAYS_SUPPLY
                    
                FROM NA_BI_VWS.FACILITY_MATL_INVENTORY F
                
                    INNER JOIN GDYR_BI_VWS.NAT_MATL_CURR M
                        ON M.MATL_ID = F.MATL_ID
                        AND M.PBU_NBR IN ('01', '03', '04', '05', '07', '08', '09')
                        AND M.MATL_TYPE_ID IN ('PCTL', 'ACCT')
                
                WHERE
                    F.DAY_DT = (CURRENT_DATE-1)
                    AND F.FACILITY_ID IN ('N602', 'N607', 'N623', 'N636', 'N637', 'N699', 'N6D3')
                
                QUALIFY
                    ROW_NUMBER() OVER (PARTITION BY F.MATL_ID ORDER BY F.EST_DAYS_SUPPLY DESC, F.AVAIL_TO_PROM_QTY DESC) = 1

            ) MAX_DSI
        ON MAX_DSI.MATL_ID = FMI.MATL_ID

WHERE
    FMI.DAY_DT = (CURRENT_DATE-1)
    AND FMI.AVAIL_TO_PROM_QTY > 0
    AND FMI.FACILITY_ID IN ('N602', 'N607', 'N623', 'N636', 'N637', 'N699', 'N6D3')

GROUP BY
    FMI.MATL_ID
    , MAX_DSI.FACILITY_ID
    , MAX_DSI.AVAIL_TO_PROM_QTY
    , MAX_DSI.EST_DAYS_SUPPLY
