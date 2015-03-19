-- Paul's Rescheduling Query

SELECT
    RS.ORDER_ID,
    RS.ORDER_LINE_NBR,
    RS.RESCHD_DT,
    RS.SHIP_TO_CUST_ID,
    RS.CMN_OWN_CUST_ID,
    RS.MATL_ID,
    RS.PBU_NBR,
    RS.SCHD_LN_DELIV_BLOCK,
    RS.HEADER_DELIV_BLOCK,
    RS.MIN_PLN_DELIV_DT,
    RS.MAX_PLN_DELIV_DT,
    RS.MIN_RESCHD_DELIV_DT,
    RS.MAX_RESCHD_DELIV_DT,
    RS.MAX_PLN_MAD,
    RS.MAX_RESCHD_MAD,
    RS.MAX_DATE_QTY_DELETED,
    RS.MAX_DATE_QTY_ADDED,
    RS.MAX_DATE_QTY_INCREASED,
    RS.MAX_DATE_QTY_DECREASED,
    RS.SUM_QTY_DECREASED,
    RS.SUM_QTY_INCREASED,
    RS.SCHD_LINE_COUNT,
    RS.DATE_IMPROVED_QTY,
    RS.DATE_PUSH_QTY,
    RS.QUANTITY_ADDED,
    RS.QUANTITY_DELETED,
    RS.SUM_CNFRM_QTY,
    RS.SUM_RESCHD_CNFRM_QTY,
    -- CNFRM_INCR_QTY BEGIN
    SUM( CASE
        WHEN RS.SUM_CNFRM_QTY > RS.SUM_RESCHD_CNFRM_QTY
            THEN ( CASE
                WHEN RS.SUM_CNFRM_QTY > ( O.CNFRM_ORDER_QTY + OO.UNCNFRM_ORDER_QTY + OO.BACK_ORDER_QTY + OO.OTHER_ORDER_QTY )
                    THEN 0
                ELSE RS.SUM_CNFRM_QTY - RS.SUM_RESCHD_CNFRM_QTY
            END )
        ELSE 0
    END ) AS CNFRM_DECR_QTY,
    SUM( CASE
        WHEN RS.SUM_CNFRM_QTY < RS.SUM_RESCHD_CNFRM_QTY
            THEN RS.SUM_RESCHD_CNFRM_QTY - RS.SUM_CNFRM_QTY
        ELSE 0
    END ) AS CNFRM_INCR_QTY,
    
    -- CONFIRM_DATE_IMPR_QTY BEGIN
    SUM( CASE
        WHEN RS.SCHD_LINE_COUNT = 1
            THEN RS.DATE_IMPROVED_QTY
        ELSE ( CASE
            WHEN RS.SCHD_LINE_COUNT = 2
                THEN ( CASE
                    WHEN RS.MAX_RESCHD_MAD < RS.MAX_PLN_MAD AND RS.DATE_PUSH_QTY = 0 AND
                            ( RS.SUM_QTY_DECREASED <> RS.SUM_QTY_INCREASED OR RS.DATE_IMPROVED_QTY > 0 )
                        THEN RS.DATE_IMPROVED_QTY + RS.SUM_QTY_INCREASED + RS.QUANTITY_ADDED
                    ELSE ( CASE
                        WHEN RS.MAX_PLN_MAD = RS.MAX_RESCHD_MAD AND RS.DATE_IMPROVED_QTY = 0
                            THEN RS.SUM_QTY_INCREASED
                        ELSE RS.DATE_IMPROVED_QTY
                    END )
                END )
            ELSE ( CASE
                WHEN RS.MAX_DATE_QTY_DELETED > RS.MAX_DATE_QTY_INCREASED
                    THEN ( CASE
                        WHEN ( RS.QUANTITY_DELETED + RS.SUM_QTY_DECREASED ) > RS.SUM_QTY_INCREASED
                            THEN RS.SUM_QTY_INCREASED + RS.DATE_IMPROVED_QTY
                        ELSE RS.DATE_IMPROVED_QTY + RS.QUANTITY_DELETED
                    END )
                ELSE ( CASE
                    WHEN RS.MAX_DATE_QTY_INCREASED > RS.MAX_DATE_QTY_DECREASED AND 
                            ( RS.SUM_QTY_INCREASED + RS.QUANTITY_ADDED) = ( RS.SUM_QTY_DECREASED + RS.QUANTITY_ADDED ) AND
                            ( RS.MAX_RESCND_MAD < RS.MAX_PLN_MAD )
                        THEN RS.DATE_IMPROVED_QTY
                    ELSE ( CASE
                        WHEN RS.MAX_RESCHD_MAD < RS.MAX_PLN_MAD
                            THEN RS.DATE_IMPROVED_QTY + RS.SUM_QTY_DECREASED
                        ELSE RS.DATE_IMPROVED_QTY
                    END )
                END )                
            END )            
        END )
    END ) AS CONFIRM_DATE_IMPR_QTY,
    
    -- CONFIRM_DATE_PUSH_QTY
    SUM( CASE
        WHEN RS.SCHD_LINE_COUNT = 1
            THEN RS.DATE_PUSH_QTY
        ELSE ( CASE
            WHEN RS.SCHD_LINE_COUNT = 2
                THEN ( CASE
                    WHEN RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                        THEN RS.DATE_PUSH_QTY + RS.SUM_QTY_DECREASED + RS.QUANTITY_DELETED
                    ELSE RS.DATE_PUSH_QTY
                END ) 
            ELSE ( CASE
                WHEN RS.MAX_DATE_QTY_ADDED > RS.MAX_DATE_QTY_DECREASED
                    THEN ( CASE
                        WHEN RS.QUANTITY_ADDED >= RS.SUM_QTY_DECREASED AND RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                            THEN RS.SUM_QTY_DECREASED + RS.DATE_PUSH_QTY
                        ELSE ( CASE
                            WHEN RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD OR RS.QUANTITY_ADDED = RS.SUM_QTY_DECREASED
                                THEN RS.DATE_PUSH_QTY
                            ELSE ( CASE
                                WHEN RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                                    THEN RS.DATE_PUSH_QTY + RS.QUANTITY_ADDED
                                ELSE 0
                        END )                        
                    END )
                END )
            ELSE ( CASE
                WHEN RS.MAX_DATE_QTY_INCREASED > RS.MAX_DATE_QTY_DECREASED AND 
                        ( RS.SUM_QTY_INCREASED + RS.QUANTITY_ADDED ) = ( RS.SUM_QTY_DECREASED + RS.QUANTITY_DELETED ) AND
                        RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                    THEN RS.SUM_QTY_INCREASED + RS.DATE_PUSH_QTY
                ELSE ( CASE
                    WHEN RS.SUM_QTY_DECREASED < RS.SUM_QTY_INCREASED AND RS.SUM_QTY_DECREASED > 0 AND RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                        THEN ( CASE
                            WHEN ( RS.SUM_QTY_INCREASED + RS.QUANTITY_ADDED ) = ( RS.SUM_QTY_DECREASED + RS.QUANTITY_DELETED )
                                THEN RS.DATE_PUSH_QTY + RS.QUANTITY_DELETED
                            ELSE RS.SUM_QTY_DECREASED + RS.DATE_PUSH_QTY
                        END )                        
                    ELSE ( CASE
                        WHEN RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD AND RS.SUM_QTY_DECREASED = RS.SUM_QTY_INCREASED
                            THEN RS.SUM_QTY_INCREASED
                        ELSE ( CASE
                            WHEN RS.MAX_DATE_QTY_INCREASED > RS.MAX_DATE_QTY_DECREASED
                                THEN ( CASE
                                    WHEN RS.SUM_QTY_DECREASED = RS.SUM_QTY_INCREASED
                                        THEN RS.SUM_QTY_INCREASED
                                    ELSE RS.DATE_PUSH_QTY + RS.SUM_QTY_DECREASED
                                END )
                            ELSE 0
                        END )
                    END )
                END )
            END )
        END )
    END ) AS CONFIRM_DATE_PUSH_QTY,