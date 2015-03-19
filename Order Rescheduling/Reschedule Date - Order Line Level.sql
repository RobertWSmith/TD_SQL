SELECT
    RES.ORDER_ID,
    RES.ORDER_LINE_NBR,
    RES.RESCHD_DT,
    RES.SHIP_TO_CUST_ID,
    RES.OWN_CUST_ID,
    RES.MATL_ID,
    RES.PBU_NBR,
    RES.SCHED_LINE_DELIV_BLK_CD,
    RES.HEADER_DELIV_BLK_CD,
    RES.MIN_PLN_DELIV_DT,
    RES.MAX_PLN_DELIV_DT,
    RES.MIN_RESCHD_DELIV_DT,
    RES.MAX_RESCHD_DELIV_DT,
    RES.MAX_PLN_MAD,
    RES.MAX_RESCHD_MAD,
    RES.MAX_DATE_QTY_DELETED,
    RES.MAX_DATE_QTY_ADDED,
    RES.MAX_DATE_QTY_INCREASED,
    RES.MAX_DATE_QTY_DECREASED,
    RES.SUM_QTY_DECREASED,
    RES.SUM_QTY_INCREASED,
    RES.SCHED_LINE_COUNT,
    RES.DATE_IMPROVED_QTY,
    RES.DATE_PUSH_QTY,
    RES.QUANTITY_ADDED,
    RES.QUANTITY_DELETED,
    RES.SUM_CNFRM_QTY,
    RES.SUM_RESCHD_CNFRM_QTY,
    RES.CONFIRM_DATE_IMPR_QTY,
    RES.CONFIRM_DATE_PUSH_QTY,
    SUM( CASE
        WHEN RES.SUM_CNFRM_QTY > RES.SUM_RESCHD_CNFRM_QTY
            THEN ( CASE
                WHEN RES.SUM_CNFRM_QTY > ( OO.OPEN_CNFRM_QTY + OO.UNCNFRM_QTY + OO.BACK_ORDER_QTY + OO.OTHER_OPEN_QTY )
                    THEN 0
                ELSE ( RES.SUM_CNFRM_QTY - RES.SUM_RESCHD_CNFRM_QTY )
            END )
        ELSE 0
    END ) AS CNFRM_DECR_QTY,
    SUM( CASE
        WHEN RES.SUM_CNFRM_QTY < RES.SUM_RESCHD_CNFRM_QTY
            THEN ( RES.SUM_RESCHD_CNFRM_QTY - RES.SUM_CNFRM_QTY )
        ELSE 0
    END ) AS CNFRM_INCR_QTY,

    SUM( CASE
        WHEN ( RES.DELIV_BLK_QTY + RES.FREIGHT_PLCY_QTY + RES.MAD_IN_PAST_MAN + RES.MAD_IN_PAST_SUPPLY ) <= RES.CONFIRM_DATE_PUSH_QTY
            THEN RES.CONFIRM_DATE_PUSH_QTY - ( RES.DELIV_BLK_QTY + RES.FREIGHT_PLCY_QTY + RES.MAD_IN_PAST_MAN + RES.MAD_IN_PAST_SUPPLY )
        ELSE RES.CONFIRM_DATE_PUSH_QTY
    END ) AS ADJ_CONFIRM_DATE_PUSH_QTY,
    SUM( CASE
        WHEN RES.DELIV_BLK_QTY > RES.CONFIRM_DATE_PUSH_QTY
            THEN RES.CONFIRM_DATE_PUSH_QTY
        ELSE RES.DELIV_BLK_QTY
    END ) AS DELIV_BLOCK_QTY,
    SUM( CASE
        WHEN RES.FREIGHT_PLCY_QTY > RES.CONFIRM_DATE_PUSH_QTY
            THEN RES.CONFIRM_DATE_PUSH_QTY
        ELSE RES.FREIGHT_PLCY_QTY
    END ) AS FREIGHT_POLICY_QTY,
    SUM( CASE
        WHEN RES.MAD_IN_PAST_MAN > RES.CONFIRM_DATE_PUSH_QTY
            THEN RES.CONFIRM_DATE_PUSH_QTY
        ELSE RES.MAD_IN_PAST_MAN
    END ) AS MAD_IN_PAST_MAN_QTY,
    SUM( CASE
        WHEN RES.MAD_IN_PAST_SUPPLY > RES.CONFIRM_DATE_PUSH_QTY
            THEN RES.CONFIRM_DATE_PUSH_QTY
        ELSE RES.MAD_IN_PAST_SUPPLY
    END ) AS MAD_IN_PAST_SUPPLY_QTY,
    MAX( CASE
        WHEN OO.ORDER_ID IS NULL AND OO.ORDER_LINE_NBR IS NULL
            THEN 'N'
        ELSE 'Y'
    END ) AS OPEN_ORDER_IND,        
    SUM( ZEROIFNULL( OO.BACK_ORDER_QTY ) ) AS BACK_ORDER_QTY,
    SUM( ZEROIFNULL( OO.OPEN_CNFRM_QTY ) ) AS OPEN_CONFIRMED_QTY,
    SUM( ZEROIFNULL( OO.UNCNFRM_QTY ) ) AS UNCONFIRMED_QTY,
    SUM( ZEROIFNULL( OO.OTHER_OPEN_QTY ) ) AS OTHER_OPEN_QTY

FROM (

        SELECT
            R.ORDER_ID,
            R.ORDER_LINE_NBR,
            R.RESCHD_DT,
            CAL.DAY_DATE AS PRIOR_DY_RESCHD_DT,
            
            MAX( R.SHIP_TO_CUST_ID ) AS SHIP_TO_CUST_ID,
            R.CMN_OWN_CUST_ID AS OWN_CUST_ID,

            MAX( R.MATL_ID ) AS MATL_ID,
            R.PBU_NBR,
    
            COUNT( DISTINCT R.ORDER_ID || R.ORDER_LINE_NBR || R.SCHED_LINE_NBR ) AS SCHED_LINE_COUNT,
            MAX( R.PLN_MATL_AVAIL_DT ) AS MAX_PLN_MAD,
            MAX( R.RESCHD_MATL_AVAIL_DT ) AS MAX_RESCHD_MAD,
            MAX( R.PLN_DELIV_DT ) AS MAX_PLN_DELIV_DT,
            MAX( R.RESCHD_DELIV_DT ) AS MAX_RESCHD_DELIV_DT,
            MIN( R.PLN_DELIV_DT ) AS MIN_PLN_DELIV_DT,
            MIN( R.RESCHD_DELIV_DT ) AS MIN_RESCHD_DELIV_DT,
            SUM( R.CNFRM_QTY ) AS SUM_CNFRM_QTY,
            SUM( R.RESCHD_CNFRM_QTY ) AS SUM_RESCHD_CNFRM_QTY,
            MAX( SDSL.SCHD_LN_DELIV_BLK_CD ) AS SCHED_LINE_DELIV_BLK_CD,
            MAX( SD.DELIV_BLK_CD ) AS HEADER_DELIV_BLK_CD,
            
            SUM( CASE
                WHEN ( SDSL.SCHD_LN_DELIV_BLK_CD IS NOT NULL OR SD.DELIV_BLK_CD IS NOT NULL ) AND R.PLN_MATL_AVAIL_DT < R.RESCHD_DT AND SDSL.SCHD_LN_DELIV_BLK_CD <> 'YF'
                    THEN R.CNFRM_QTY
                ELSE 0
            END ) AS DELIV_BLK_QTY,
            SUM( CASE
                WHEN DLR.REJ_DT IS NOT NULL OR ( SDSL.SCHD_LN_DELIV_BLK_CD = 'YF' AND R.PLN_MATL_AVAIL_DT < R.RESCHD_DT )
                    THEN R.CNFRM_QTY
                ELSE 0
            END ) AS FREIGHT_PLCY_QTY,
            SUM( CASE
                WHEN R.PLN_MATL_AVAIL_DT < R.RESCHD_DT AND CUST.CUST_GRP2_CD = 'MAN' AND SDSL.SCHD_LN_DELIV_BLK_CD IS NULL
                    THEN R.CNFRM_QTY
                ELSE 0
            END ) AS MAD_IN_PAST_MAN,
            SUM( CASE
                WHEN R.PLN_MATL_AVAIL_DT < R.RESCHD_DT AND CUST.CUST_GRP2_CD <> 'MAN' AND SDSL.SCHD_LN_DELIV_BLK_CD IS NULL
                    THEN R.CNFRM_QTY
                ELSE 0
            END ) AS MAD_IN_PAST_SUPPLY,
            
            MAX( CASE
                WHEN R.RESCHD_MATL_AVAIL_DT IS NULL 
                    THEN R.PLN_MATL_AVAIL_DT        
            END ) AS MAX_DATE_QTY_DELETED,
            MAX( CASE
                WHEN R.PLN_MATL_AVAIL_DT IS NULL
                    THEN R.RESCHD_MATL_AVAIL_DT
            END ) AS MAX_DATE_QTY_ADDED,
            
            SUM( CASE
                WHEN R.RESCHD_MATL_AVAIL_DT IS NOT NULL AND R.PLN_MATL_AVAIL_DT IS NOT NULL AND R.CNFRM_QTY > R.RESCHD_CNFRM_QTY
                    THEN  ( R.CNFRM_QTY - R.RESCHD_CNFRM_QTY )
                ELSE 0
            END ) AS SUM_QTY_DECREASED,
            SUM( CASE
                WHEN R.RESCHD_MATL_AVAIL_DT IS NOT NULL AND R.PLN_MATL_AVAIL_DT IS NOT NULL AND R.CNFRM_QTY < R.RESCHD_CNFRM_QTY
                    THEN ( R.RESCHD_CNFRM_QTY - R.CNFRM_QTY )
                ELSE 0
            END ) AS SUM_QTY_INCREASED,
            
            MAX( CASE
                WHEN R.RESCHD_MATL_AVAIL_DT IS NOT NULL AND R.PLN_MATL_AVAIL_DT IS NOT NULL AND R.CNFRM_QTY > R.RESCHD_CNFRM_QTY
                    THEN R.RESCHD_MATL_AVAIL_DT
            END ) AS MAX_DATE_QTY_DECREASED,
            MAX( CASE
                WHEN R.RESCHD_MATL_AVAIL_DT IS NOT NULL AND R.PLN_MATL_AVAIL_DT IS NOT NULL AND R.CNFRM_QTY < R.RESCHD_CNFRM_QTY
                    THEN R.RESCHD_MATL_AVAIL_DT
            END ) AS MAX_DATE_QTY_INCREASED,
            
            SUM( CASE
                WHEN R.PLN_MATL_AVAIL_DT> R.RESCHD_MATL_AVAIL_DT AND R.PLN_DELIV_DT IS NOT NULL
                    THEN ( CASE
                        WHEN R.CNFRM_QTY > R.RESCHD_CNFRM_QTY
                            THEN R.RESCHD_CNFRM_QTY
                        ELSE R.CNFRM_QTY
                    END )
                ELSE 0
            END ) AS DATE_IMPROVED_QTY,
            SUM( CASE
                WHEN R.PLN_MATL_AVAIL_DT < R.RESCHD_MATL_AVAIL_DT AND R.PLN_DELIV_DT IS NOT NULL
                    THEN ( CASE
                        WHEN R.CNFRM_QTY > R.RESCHD_CNFRM_QTY
                            THEN R.RESCHD_CNFRM_QTY
                        ELSE R.CNFRM_QTY
                    END )
                ELSE 0
            END ) AS DATE_PUSH_QTY,
            SUM( CASE
                WHEN R.PLN_DELIV_DT IS NULL
                    THEN R.RESCHD_CNFRM_QTY
                ELSE 0
            END ) AS QUANTITY_ADDED,
            SUM( CASE
                WHEN R.RESCHD_DELIV_DT IS NULL
                    THEN R.CNFRM_QTY
                ELSE 0
            END ) AS QUANTITY_DELETED,
            
            ZEROIFNULL( CASE
                WHEN SCHED_LINE_COUNT = 1
                    THEN DATE_PUSH_QTY
                WHEN SCHED_LINE_COUNT = 2
                    THEN ( CASE
                        WHEN MAX_RESCHD_MAD > MAX_PLN_MAD
                            THEN ( DATE_PUSH_QTY + SUM_QTY_DECREASED + QUANTITY_DELETED )
                        ELSE DATE_PUSH_QTY
                    END )
                ELSE ( CASE
                    WHEN MAX_DATE_QTY_ADDED > MAX_DATE_QTY_DECREASED
                        THEN ( CASE
                            WHEN QUANTITY_ADDED >= SUM_QTY_DECREASED AND MAX_RESCHD_MAD > MAX_PLN_MAD
                                THEN ( SUM_QTY_DECREASED + DATE_PUSH_QTY )
                            ELSE ( CASE
                                WHEN MAX_RESCHD_MAD > MAX_PLN_MAD OR QUANTITY_ADDED = SUM_QTY_DECREASED
                                    THEN DATE_PUSH_QTY
                                ELSE ( CASE
                                    WHEN MAX_RESCHD_MAD > MAX_PLN_MAD
                                        THEN ( DATE_PUSH_QTY + QUANTITY_ADDED )
                                    ELSE 0
                                END )
                            END )
                        END )
                    ELSE ( CASE
                        WHEN MAX_DATE_QTY_INCREASED > MAX_DATE_QTY_DECREASED  AND MAX_RESCHD_MAD > MAX_PLN_MAD AND
                                ( SUM_QTY_INCREASED + QUANTITY_ADDED ) = ( SUM_QTY_DECREASED + QUANTITY_DELETED )
                            THEN SUM_QTY_INCREASED + DATE_PUSH_QTY
                        ELSE ( CASE
                            WHEN SUM_QTY_DECREASED < SUM_QTY_INCREASED AND SUM_QTY_DECREASED > 0 AND MAX_RESCHD_MAD > MAX_PLN_MAD
                                THEN ( CASE
                                    WHEN ( SUM_QTY_INCREASED + QUANTITY_ADDED ) = ( SUM_QTY_DECREASED + QUANTITY_ADDED )
                                        THEN ( DATE_PUSH_QTY + QUANTITY_DELETED )
                                    ELSE ( SUM_QTY_DECREASED + DATE_PUSH_QTY )
                                END )
                            ELSE ( CASE
                                WHEN MAX_RESCHD_MAD > MAX_PLN_MAD AND SUM_QTY_DECREASED = SUM_QTY_INCREASED
                                    THEN SUM_QTY_INCREASED
                                ELSE ( CASE
                                    WHEN MAX_DATE_QTY_INCREASED > MAX_DATE_QTY_DECREASED
                                    THEN ( CASE
                                        WHEN SUM_QTY_DECREASED = SUM_QTY_INCREASED
                                            THEN SUM_QTY_INCREASED
                                        ELSE ( DATE_PUSH_QTY + SUM_QTY_DECREASED )
                                    END )
                                END )
                            END )
                        END )
                    END )
                END )
            END ) AS CONFIRM_DATE_PUSH_QTY,
            ZEROIFNULL( CASE
                WHEN SCHED_LINE_COUNT = 1
                    THEN DATE_IMPROVED_QTY
                WHEN SCHED_LINE_COUNT = 2
                    THEN ( CASE
                        WHEN MAX_RESCHD_MAD < MAX_PLN_MAD AND DATE_PUSH_QTY = 0 AND ( SUM_QTY_DECREASED <> SUM_QTY_INCREASED OR DATE_IMPROVED_QTY > 0 )
                            THEN ( DATE_IMPROVED_QTY + SUM_QTY_INCREASED + QUANTITY_ADDED )
                        ELSE ( CASE
                            WHEN MAX_PLN_MAD = MAX_RESCHD_MAD AND DATE_IMPROVED_QTY = 0 
                                THEN SUM_QTY_INCREASED
                            ELSE DATE_IMPROVED_QTY
                        END )
                    END )
                ELSE ( CASE
                    WHEN MAX_DATE_QTY_DELETED > MAX_DATE_QTY_INCREASED
                        THEN ( CASE
                            WHEN ( QUANTITY_DELETED + SUM_QTY_DECREASED ) > SUM_QTY_INCREASED
                                THEN ( SUM_QTY_INCREASED + DATE_IMPROVED_QTY )
                            ELSE ( DATE_IMPROVED_QTY + QUANTITY_DELETED )
                        END )
                    ELSE ( CASE
                        WHEN MAX_DATE_QTY_INCREASED > MAX_DATE_QTY_DECREASED AND MAX_RESCHD_MAD < MAX_PLN_MAD AND 
                                ( SUM_QTY_INCREASED + QUANTITY_ADDED ) = ( SUM_QTY_DECREASED + QUANTITY_DELETED )
                            THEN DATE_IMPROVED_QTY
                        ELSE ( CASE
                            WHEN MAX_RESCHD_MAD < MAX_PLN_MAD
                                THEN DATE_IMPROVED_QTY + SUM_QTY_DECREASED
                            ELSE DATE_IMPROVED_QTY
                        END )                            
                    END )
                END )
            END ) AS CONFIRM_DATE_IMPR_QTY
        
        FROM GDYR_BI_VWS.GDYR_CAL CAL
        
            INNER JOIN NA_BI_VWS.ORD_RESCHD R
                ON R.PRIOR_DY_RESCHD_DT = CAL.DAY_DATE
                AND R.PBU_NBR IN ( '01', '03' )
                AND R.PRIOR_DY_RESCHD_DT BETWEEN CAST( '2014-02-01' AS DATE ) AND CAST( '2014-02-28' AS DATE )
                AND R.CMN_OWN_CUST_ID <> '00A0005538' -- COWD
                AND R.ORIG_SYS_ID = 2
                AND R.SBU_ID = 2
                AND R.MATL_ID IN ( 
                        SELECT
                            M.MATL_ID
                        FROM GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
                        WHERE
                            M.EXT_MATL_GRP_ID = 'TIRE'
                            AND M.PBU_NBR IN ( '01', '03' )
                        )
        
            INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MATL
                ON MATL.MATL_ID = R.MATL_ID
                AND MATL.EXT_MATL_GRP_ID = 'TIRE'

            INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CUST
                ON CUST.SHIP_TO_CUST_ID = R.SHIP_TO_CUST_ID
                AND CUST.CUST_GRP_ID <> '3R'
                AND CUST.OWN_CUST_ID <> '00A0005538' -- COWD

            INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
                ON SD.SLS_DOC_ID = R.ORDER_ID
                AND CAL.DAY_DATE BETWEEN SD.EFF_DT AND SD.EXP_DT     
                AND SD.ORIG_SYS_ID = 2
                AND SD.SBU_ID = 2
                AND SD.SRC_SYS_ID = 2
                AND SD.SLS_DOC_TYP_CD NOT IN ( 'ZLS', 'ZLZ' )
                AND SD.CUST_PRCH_ORD_TYP_CD <> 'RO'
                AND SD.DOC_DT >= CAST( ( EXTRACT( YEAR FROM CURRENT_DATE ) - 1 ) || '-01-01' AS DATE )
    
            INNER JOIN NA_BI_VWS.NAT_SLS_DOC_SCHD_LN SDSL
                ON SDSL.SLS_DOC_ID = R.ORDER_ID
                AND SDSL.SLS_DOC_ITM_ID = R.ORDER_LINE_NBR
                AND SDSL.SCHD_LN_ID = R.SCHED_LINE_NBR
                AND CAL.DAY_DATE BETWEEN SDSL.EFF_DT AND SDSL.EXP_DT
                AND SDSL.ORIG_SYS_ID = 2
                AND SDSL.SRC_SYS_ID = 2
                AND SDSL.SBU_ID = 2
    
            LEFT OUTER JOIN (
                    SELECT
                        D.ORDER_ID,
                        D.ORDER_LINE_NBR,
                        D.REJ_DT
                    FROM GDYR_VWS.DELIV_LINE_REJ D
                    WHERE
                        D.ORIG_SYS_ID = 2
                        AND D.SRC_SYS_ID = 2
                        AND D.SBU_ID = 2
                    GROUP BY
                        D.ORDER_ID,
                        D.ORDER_LINE_NBR,
                        D.REJ_DT
                    ) DLR
                ON DLR.ORDER_ID = R.ORDER_ID
                AND DLR.ORDER_LINE_NBR = R.ORDER_LINE_NBR
                AND DLR.REJ_DT = CAL.DAY_DATE
    
        WHERE
            ( CASE WHEN R.CMN_OWN_CUST_ID = '00A0000632' AND SUBSTR( SD.CUST_PRCH_ORD_ID, 5, 2 ) <> '62' THEN 0 ELSE 1 END ) = 1
            
        GROUP BY
            R.ORDER_ID,
            R.ORDER_LINE_NBR,
            R.RESCHD_DT,
            CAL.DAY_DATE,
    
            R.CMN_OWN_CUST_ID,
    
            R.PBU_NBR
            
        ) RES

    LEFT OUTER JOIN (
        SELECT
            OPN.ORDER_ID,
            OPN.ORDER_LINE_NBR,
            OPN.EFF_DT,
            OPN.EXP_DT,
            SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'B' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS BACK_ORDER_QTY,
            SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'U' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS UNCNFRM_QTY,
            SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD = 'C' THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS OPEN_CNFRM_QTY,
            SUM( CASE WHEN OPN.OPEN_ORDER_STATUS_CD NOT IN ( 'B', 'U', 'C' ) THEN OPN.OPEN_ORDER_QTY ELSE 0 END ) AS OTHER_OPEN_QTY,
            OPN.SLS_QTY_UNIT_MEAS_ID AS QTY_UNIT_MEAS_ID
        FROM GDYR_VWS.OPEN_ORDER OPN
        WHERE
            OPN.ORIG_SYS_ID = 2
            AND OPN.SBU_ID = 2        
        GROUP BY
            OPN.ORDER_ID,
            OPN.ORDER_LINE_NBR,
            OPN.EFF_DT,
            OPN.EXP_DT,
            OPN.SLS_QTY_UNIT_MEAS_ID
        ) OO
        ON OO.ORDER_ID = RES.ORDER_ID
        AND OO.ORDER_LINE_NBR = RES.ORDER_LINE_NBR
        AND RES.PRIOR_DY_RESCHD_DT BETWEEN OO.EFF_DT AND OO.EXP_DT
        
GROUP BY
    RES.ORDER_ID,
    RES.ORDER_LINE_NBR,
    RES.RESCHD_DT,
    RES.SHIP_TO_CUST_ID,
    RES.OWN_CUST_ID,
    RES.MATL_ID,
    RES.PBU_NBR,
    RES.SCHED_LINE_DELIV_BLK_CD,
    RES.HEADER_DELIV_BLK_CD,
    RES.MIN_PLN_DELIV_DT,
    RES.MAX_PLN_DELIV_DT,
    RES.MIN_RESCHD_DELIV_DT,
    RES.MAX_RESCHD_DELIV_DT,
    RES.MAX_PLN_MAD,
    RES.MAX_RESCHD_MAD,
    RES.MAX_DATE_QTY_DELETED,
    RES.MAX_DATE_QTY_ADDED,
    RES.MAX_DATE_QTY_INCREASED,
    RES.MAX_DATE_QTY_DECREASED,
    RES.SUM_QTY_DECREASED,
    RES.SUM_QTY_INCREASED,
    RES.SCHED_LINE_COUNT,
    RES.DATE_IMPROVED_QTY,
    RES.DATE_PUSH_QTY,
    RES.QUANTITY_ADDED,
    RES.QUANTITY_DELETED,
    RES.SUM_CNFRM_QTY,
    RES.SUM_RESCHD_CNFRM_QTY,
    RES.CONFIRM_DATE_IMPR_QTY,
    RES.CONFIRM_DATE_PUSH_QTY