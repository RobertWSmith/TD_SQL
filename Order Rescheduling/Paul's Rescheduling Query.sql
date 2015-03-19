SELECT
    --RS.ORDER_ID,
    --RS.ORDER_LINE_NBR,
    RS.RESCHD_DT,
    --RS.SHIP_TO_CUST_ID,
    RS.CMN_OWN_CUST_ID,
    RS.MATL_ID,
    RS.PBU_NBR,
    --RS.SCHD_LN_DELIV_BLOCK,
    --RS.HEADER_DELIV_BLOCK,
    --RS.MIN_PLN_DELIV_DT,
    --RS.MAX_PLN_DELIV_DT,
    --RS.MIN_RESCHED_DELIV_DT,
    --RS.MAX_RESCHD_DELIV_DT,
    --RS.MAX_PLN_MAD,
    --RS.MAX_RESCHD_MAD,
    --RS.MAX_DATE_QTY_DELETED,
    --RS.MAX_DATE_QTY_ADDED,
    --RS.MAX_DATE_QTY_INCREASED,
    --RS.MAX_DATE_QTY_DECREASED,
    --RS.SUM_QTY_DECREASED,
    --RS.SUM_QTY_INCREASED,
    --RS.SCHD_LINE_COUNT,
    --RS.DATE_IMPROVED_QTY,
    --RS.DATE_PUSH_QTY,
    --RS.QUANTITY_ADDED,
    --RS.QUANTITY_DELETED,
    --RS.SUM_CNFRM_QTY,
    --RS.SUM_RESCHD_CNFRM_QTY,
    SUM(CASE 
            WHEN RS.SUM_CNFRM_QTY > RS.SUM_RESCHD_CNFRM_QTY
                THEN CASE 
                        WHEN RS.SUM_CNFRM_QTY > (
                                OO.CNFRM_ORDER_QTY + OO.UNCFRM_ORDER_QTY + OO.
                                BACK_ORDER_QTY + OO.OTHER_ORDER_QTY
                                )
                            THEN 0
                        ELSE RS.SUM_CNFRM_QTY - RS.SUM_RESCHD_CNFRM_QTY
                        END
            ELSE 0
            END) AS CNFRM_DECR_QTY,
    SUM(CASE 
            WHEN RS.SUM_CNFRM_QTY < RS.SUM_RESCHD_CNFRM_QTY
                THEN RS.SUM_RESCHD_CNFRM_QTY - RS.SUM_CNFRM_QTY
            ELSE 0
            END) AS CNFRM_INCR_QTY,
    SUM(CASE 
            WHEN RS.SCHD_LINE_COUNT = 1
                THEN RS.DATE_IMPROVED_QTY
            ELSE CASE 
                    WHEN RS.SCHD_LINE_COUNT = 2
                        THEN CASE 
                                WHEN RS.MAX_RESCHD_MAD < RS.MAX_PLN_MAD
                                    AND RS.DATE_PUSH_QTY = 0
                                    AND (
                                        RS.SUM_QTY_DECREASED <> RS.
                                        SUM_QTY_INCREASED
                                        OR RS.DATE_IMPROVED_QTY > 0
                                        )
                                    THEN RS.DATE_IMPROVED_QTY + RS.
                                        SUM_QTY_INCREASED + RS.QUANTITY_ADDED
                                ELSE CASE 
                                        WHEN RS.MAX_PLN_MAD = RS.MAX_RESCHD_MAD
                                            AND RS.DATE_IMPROVED_QTY = 0
                                            THEN RS.SUM_QTY_INCREASED
                                        ELSE RS.DATE_IMPROVED_QTY
                                        END
                                END
                    ELSE CASE 
                            WHEN RS.MAX_DATE_QTY_DELETED > RS.
                                MAX_DATE_QTY_INCREASED
                                THEN CASE 
                                        WHEN (
                                                RS.QUANTITY_DELETED + RS.
                                                SUM_QTY_DECREASED
                                                ) > RS.SUM_QTY_INCREASED
                                            THEN RS.SUM_QTY_INCREASED + RS.
                                                DATE_IMPROVED_QTY
                                        ELSE RS.DATE_IMPROVED_QTY + RS.
                                            QUANTITY_DELETED
                                        END
                            ELSE CASE 
                                    WHEN RS.MAX_DATE_QTY_INCREASED > RS.
                                        MAX_DATE_QTY_DECREASED
                                        AND (
                                            RS.SUM_QTY_INCREASED + RS.
                                            QUANTITY_ADDED
                                            ) = (
                                            RS.SUM_QTY_DECREASED + RS.
                                            QUANTITY_DELETED
                                            )
                                        AND RS.MAX_RESCHD_MAD < RS.MAX_PLN_MAD
                                        THEN RS.DATE_IMPROVED_QTY
                                    ELSE CASE 
                                            WHEN RS.MAX_RESCHD_MAD < RS.MAX_PLN_MAD
                                                THEN RS.DATE_IMPROVED_QTY + RS.
                                                    SUM_QTY_DECREASED
                                            ELSE RS.DATE_IMPROVED_QTY
                                            END
                                    END
                            END
                    END
            END) AS CONFIRM_DATE_IMPR_QTY,
    --CNFRM_DATE_PUSH_QTY
    SUM(CASE 
            WHEN RS.SCHD_LINE_COUNT = 1
                THEN RS.DATE_PUSH_QTY
            ELSE CASE 
                    WHEN RS.SCHD_LINE_COUNT = 2
                        THEN CASE 
                                WHEN RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                                    THEN RS.DATE_PUSH_QTY + RS.SUM_QTY_DECREASED + RS
                                        .QUANTITY_DELETED
                                ELSE RS.DATE_PUSH_QTY
                                END
                    ELSE CASE 
                            WHEN RS.MAX_DATE_QTY_ADDED > RS.MAX_DATE_QTY_DECREASED
                                THEN CASE 
                                        WHEN RS.QUANTITY_ADDED >= RS.
                                            SUM_QTY_DECREASED
                                            AND RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                                            THEN RS.SUM_QTY_DECREASED + RS.
                                                DATE_PUSH_QTY
                                        ELSE CASE 
                                                WHEN RS.MAX_RESCHD_MAD > RS.
                                                    MAX_PLN_MAD
                                                    OR RS.QUANTITY_ADDED = RS.
                                                    SUM_QTY_DECREASED
                                                    THEN RS.DATE_PUSH_QTY
                                                ELSE CASE 
                                                        WHEN RS.MAX_RESCHD_MAD > RS
                                                            .MAX_PLN_MAD
                                                            THEN RS.DATE_PUSH_QTY 
                                                                + RS.
                                                                QUANTITY_ADDED
                                                        ELSE 0
                                                        END
                                                END
                                        END
                            ELSE CASE 
                                    WHEN RS.MAX_DATE_QTY_INCREASED > RS.
                                        MAX_DATE_QTY_DECREASED
                                        AND (
                                            RS.SUM_QTY_INCREASED + RS.
                                            QUANTITY_ADDED
                                            ) = (
                                            RS.SUM_QTY_DECREASED + RS.
                                            QUANTITY_DELETED
                                            )
                                        AND RS.MAX_RESCHD_MAD > RS.MAX_PLN_MAD
                                        THEN RS.SUM_QTY_INCREASED + RS.
                                            DATE_PUSH_QTY
                                    ELSE CASE 
                                            WHEN RS.SUM_QTY_DECREASED < RS.
                                                SUM_QTY_INCREASED
                                                AND RS.SUM_QTY_DECREASED > 0
                                                AND RS.MAX_RESCHD_MAD > RS.
                                                MAX_PLN_MAD
                                                THEN CASE 
                                                        WHEN (
                                                                RS.
                                                                SUM_QTY_INCREASED 
                                                                + RS.
                                                                QUANTITY_ADDED
                                                                ) = (
                                                                RS.
                                                                SUM_QTY_DECREASED 
                                                                + RS.
                                                                QUANTITY_DELETED
                                                                )
                                                            THEN RS.DATE_PUSH_QTY 
                                                                + RS.
                                                                QUANTITY_DELETED
                                                        ELSE RS.SUM_QTY_DECREASED 
                                                            + RS.DATE_PUSH_QTY
                                                        END
                                            ELSE CASE 
                                                    WHEN RS.MAX_RESCHD_MAD > RS.
                                                        MAX_PLN_MAD
                                                        AND RS.SUM_QTY_DECREASED = 
                                                        RS.SUM_QTY_INCREASED
                                                        THEN RS.SUM_QTY_INCREASED
                                                    ELSE CASE 
                                                            WHEN RS.
                                                                MAX_DATE_QTY_INCREASED 
                                                                > RS.
                                                                MAX_DATE_QTY_DECREASED
                                                                THEN CASE 
                                                                        WHEN RS.
                                                                            SUM_QTY_DECREASED 
                                                                            = RS.
                                                                            SUM_QTY_INCREASED
                                                                            THEN 
                                                                                RS
                                                                                .
                                                                                SUM_QTY_INCREASED
                                                                        ELSE RS.
                                                                            DATE_PUSH_QTY 
                                                                            + RS.
                                                                            SUM_QTY_DECREASED
                                                                        END
                                                            ELSE 0
                                                            END
                                                    END
                                            END
                                    END
                            END
                    END
            END) AS CONFIRM_DATE_PUSH_QTY,
    SUM(CASE 
            WHEN RS.DELIV_BLOCK + RS.POLICY + RS.MAD_IN_PAST_MAN + RS.
                MAD_IN_PAST_SUPPLY <= CONFIRM_DATE_PUSH_QTY
                THEN CONFIRM_DATE_PUSH_QTY - (
                        RS.DELIV_BLOCK + RS.POLICY + RS.MAD_IN_PAST_MAN + RS.
                        MAD_IN_PAST_SUPPLY
                        )
            ELSE CONFIRM_DATE_PUSH_QTY
            END) AS ADJ_CONFIRM_DATE_PUSH_QTY,
    SUM(CASE 
            WHEN RS.DELIV_BLOCK > CONFIRM_DATE_PUSH_QTY
                THEN CONFIRM_DATE_PUSH_QTY
            ELSE RS.DELIV_BLOCK
            END) AS DELIV_BLOCK_QTY,
    SUM(CASE 
            WHEN RS.POLICY > CONFIRM_DATE_PUSH_QTY
                THEN CONFIRM_DATE_PUSH_QTY
            ELSE RS.POLICY
            END) AS POLICY_QTY,
    SUM(CASE 
            WHEN RS.MAD_IN_PAST_MAN > CONFIRM_DATE_PUSH_QTY
                THEN CONFIRM_DATE_PUSH_QTY
            ELSE RS.MAD_IN_PAST_MAN
            END) AS MAD_IN_PAST_MAN_QTY,
    SUM(CASE 
            WHEN RS.MAD_IN_PAST_SUPPLY > CONFIRM_DATE_PUSH_QTY
                THEN CONFIRM_DATE_PUSH_QTY
            ELSE RS.MAD_IN_PAST_SUPPLY
            END) AS MAD_IN_PAST_SUPPLY_QTY,
    SUM(OO.BACK_ORDER_QTY) AS BO_QTY,
    SUM(OO.CNFRM_ORDER_QTY) AS CNFRM_QTY,
    SUM(OO.UNCFRM_ORDER_QTY) AS UNCFRM_QTY,
    SUM(OO.OTHER_ORDER_QTY) AS OTHER_QTY
FROM (
    SEL SC.ORDER_ID,
    SC.ORDER_LINE_NBR,
    SC.RESCHD_DT,
    MAX(SC.SHIP_TO_CUST_ID) AS SHIP_TO_CUST_ID,
    SC.CMN_OWN_CUST_ID,
    SC.MATL_ID,
    SC.PBU_NBR,
    SC.PRIOR_DY_RESCHD_DT,
    COUNT(SC.SCHED_LINE_NBR) AS SCHD_LINE_COUNT,
    MAX(SC.PLN_MATL_AVAIL_DT) AS MAX_PLN_MAD,
    MAX(SC.PLN_DELIV_DT) AS MAX_PLN_DELIV_DT,
    MAX(SC.RESCHD_MATL_AVAIL_DT) AS MAX_RESCHD_MAD,
    MAX(SC.RESCHD_DELIV_DT) AS MAX_RESCHD_DELIV_DT,
    MIN(SC.PLN_DELIV_DT) AS MIN_PLN_DELIV_DT,
    MIN(SC.RESCHD_DELIV_DT) AS MIN_RESCHED_DELIV_DT,
    SUM(SC.CNFRM_QTY) AS SUM_CNFRM_QTY,
    SUM(SC.RESCHD_CNFRM_QTY) AS SUM_RESCHD_CNFRM_QTY,
    MAX(SDSL.SCHD_LN_DELIV_BLK_CD) AS SCHD_LN_DELIV_BLOCK,
    MAX(SD.DELIV_BLK_CD) AS HEADER_DELIV_BLOCK,
    SUM(CASE 
            WHEN (
                    SDSL.SCHD_LN_DELIV_BLK_CD IS NOT NULL
                    OR SD.DELIV_BLK_CD IS NOT NULL
                    )
                AND SC.PLN_MATL_AVAIL_DT < SC.RESCHD_DT
                AND SDSL.SCHD_LN_DELIV_BLK_CD <> 'YF'
                THEN SC.CNFRM_QTY
            ELSE 0
            END) AS DELIV_BLOCK,
    SUM(CASE 
            WHEN DLR.REJ_DT IS NOT NULL
                OR (
                    SDSL.SCHD_LN_DELIV_BLK_CD = 'YF'
                    AND SC.PLN_MATL_AVAIL_DT < SC.RESCHD_DT
                    )
                THEN SC.CNFRM_QTY
            ELSE 0
            END) AS POLICY,
    SUM(CASE 
            WHEN SC.PLN_MATL_AVAIL_DT < SC.RESCHD_DT
                AND CH.CUST_GRP2_CD = 'MAN'
                AND SDSL.SCHD_LN_DELIV_BLK_CD IS NULL
                THEN SC.CNFRM_QTY
            ELSE 0
            END) AS MAD_IN_PAST_MAN,
    SUM(CASE 
            WHEN SC.PLN_MATL_AVAIL_DT < SC.RESCHD_DT
                AND CH.CUST_GRP2_CD <> 'MAN'
                AND SDSL.SCHD_LN_DELIV_BLK_CD IS NULL
                THEN SC.CNFRM_QTY
            ELSE 0
            END) AS MAD_IN_PAST_SUPPLY,
    MAX(CASE 
            WHEN SC.RESCHD_MATL_AVAIL_DT IS NULL
                THEN SC.PLN_MATL_AVAIL_DT
            END) AS MAX_DATE_QTY_DELETED,
    MAX(CASE 
            WHEN SC.PLN_MATL_AVAIL_DT IS NULL
                THEN SC.RESCHD_MATL_AVAIL_DT
            END) AS MAX_DATE_QTY_ADDED,
    SUM(CASE 
            WHEN SC.RESCHD_MATL_AVAIL_DT IS NOT NULL
                AND SC.PLN_MATL_AVAIL_DT IS NOT NULL
                AND SC.CNFRM_QTY > SC.RESCHD_CNFRM_QTY
                THEN SC.CNFRM_QTY - SC.RESCHD_CNFRM_QTY
            ELSE 0
            END) AS SUM_QTY_DECREASED,
    SUM(CASE 
            WHEN SC.RESCHD_MATL_AVAIL_DT IS NOT NULL
                AND SC.PLN_MATL_AVAIL_DT IS NOT NULL
                AND SC.CNFRM_QTY < SC.RESCHD_CNFRM_QTY
                THEN SC.RESCHD_CNFRM_QTY - SC.CNFRM_QTY
            ELSE 0
            END) AS SUM_QTY_INCREASED,
    MAX(CASE 
            WHEN SC.RESCHD_MATL_AVAIL_DT IS NOT NULL
                AND SC.PLN_MATL_AVAIL_DT IS NOT NULL
                AND SC.CNFRM_QTY > SC.RESCHD_CNFRM_QTY
                THEN SC.RESCHD_MATL_AVAIL_DT
            END) AS MAX_DATE_QTY_DECREASED,
    MAX(CASE 
            WHEN SC.RESCHD_MATL_AVAIL_DT IS NOT NULL
                AND SC.PLN_MATL_AVAIL_DT IS NOT NULL
                AND SC.CNFRM_QTY < SC.RESCHD_CNFRM_QTY
                THEN SC.RESCHD_MATL_AVAIL_DT
            END) AS MAX_DATE_QTY_INCREASED,
    SUM(CASE 
            WHEN SC.PLN_MATL_AVAIL_DT > SC.RESCHD_MATL_AVAIL_DT
                AND SC.PLN_DELIV_DT IS NOT NULL
                THEN CASE 
                        WHEN SC.CNFRM_QTY > SC.RESCHD_CNFRM_QTY
                            THEN SC.RESCHD_CNFRM_QTY
                        ELSE SC.CNFRM_QTY
                        END
            ELSE 0
            END) AS DATE_IMPROVED_QTY,
    --DATE PUSH
    SUM(CASE 
            WHEN SC.PLN_MATL_AVAIL_DT < SC.RESCHD_MATL_AVAIL_DT
                AND SC.PLN_DELIV_DT IS NOT NULL
                THEN CASE 
                        WHEN SC.CNFRM_QTY > SC.RESCHD_CNFRM_QTY
                            THEN SC.RESCHD_CNFRM_QTY
                        ELSE SC.CNFRM_QTY
                        END
            ELSE 0
            END) AS DATE_PUSH_QTY,
    SUM(CASE 
            WHEN SC.PLN_DELIV_DT IS NULL
                THEN SC.RESCHD_CNFRM_QTY
            ELSE 0
            END) AS QUANTITY_ADDED,
    SUM(CASE 
            WHEN SC.RESCHD_DELIV_DT IS NULL
                THEN SC.CNFRM_QTY
            ELSE 0
            END) AS QUANTITY_DELETED FROM NA_BI_VWS.ORD_RESCHD SC
    LEFT JOIN (
        SELECT ORDER_ID,
            ORDER_LINE_NBR,
            REJ_DT
        FROM GDYR_VWS.DELIV_LINE_REJ
        GROUP BY ORDER_ID,
            ORDER_LINE_NBR,
            REJ_DT
        ) DLR
        ON DLR.ORDER_ID = SC.ORDER_ID
            AND DLR.ORDER_LINE_NBR = SC.ORDER_LINE_NBR
            AND DLR.REJ_DT = SC.PRIOR_DY_RESCHD_DT
    LEFT JOIN NA_BI_VWS.NAT_SLS_DOC_SCHD_LN SDSL
        ON SDSL.SLS_DOC_ID = SC.ORDER_ID
            AND SDSL.SLS_DOC_ITM_ID = SC.ORDER_LINE_NBR
            AND SDSL.SCHD_LN_ID = SC.SCHED_LINE_NBR
            AND SC.PRIOR_DY_RESCHD_DT BETWEEN SDSL.EFF_DT
                AND SDSL.EXP_DT
    INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CH
        ON SC.SHIP_TO_CUST_ID = CH.SHIP_TO_CUST_ID
    INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
        ON SD.SLS_DOC_ID = SC.ORDER_ID
            AND SC.PRIOR_DY_RESCHD_DT BETWEEN SD.EFF_DT
                AND SD.EXP_DT
    WHERE SC.RESCHD_DT BETWEEN '2014-02-01'
            AND '2014-02-28'
        AND SC.PBU_NBR IN (
            '01',
            '03'
            )
        AND CH.OWN_CUST_ID <> '00A0005538' --COWD
        AND CH.CUST_GRP_ID <> '3R' --COWD
        AND SD.SLS_DOC_TYP_CD NOT IN (
            'ZLS',
            'ZLZ'
            )
        AND SD.CUST_PRCH_ORD_TYP_CD <> 'RO'
        AND (
            CASE 
                WHEN CH.OWN_CUST_ID = '00A0000632'
                    AND SUBSTR(SD.CUST_PRCH_ORD_ID, 5, 2) <> '62'
                    THEN 0
                ELSE 1
                END
            ) = 1 --SAMS KIOSK
    GROUP BY SC.ORDER_ID,
        SC.ORDER_LINE_NBR,
        SC.RESCHD_DT,
        SC.CMN_OWN_CUST_ID,
        SC.MATL_ID,
        SC.PBU_NBR,
        SC.PRIOR_DY_RESCHD_DT
    ) RS
--INNER JOIN GDYR_BI_VWS.NAT_CUST_HIER_DESCR_EN_CURR CH
--ON RS.SHIP_TO_CUST_ID = CH.SHIP_TO_CUST_ID
INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR MH
    ON RS.MATL_ID = MH.MATL_ID
--INNER JOIN NA_BI_VWS.NAT_SLS_DOC SD
--ON SD.SLS_DOC_ID = RS.ORDER_ID AND RS.PRIOR_DY_RESCHD_DT BETWEEN SD.EFF_DT AND SD.EXP_DT
LEFT JOIN (
    SELECT OOS.ORDER_ID,
        OOS.ORDER_LINE_NBR,
        OOS.EFF_DT,
        OOS.EXP_DT,
        SUM(CASE 
                WHEN OOS.OPEN_ORDER_STATUS_CD = 'B'
                    THEN OOS.OPEN_ORDER_QTY
                ELSE 0
                END) AS BACK_ORDER_QTY,
        SUM(CASE 
                WHEN OOS.OPEN_ORDER_STATUS_CD = 'U'
                    THEN OOS.OPEN_ORDER_QTY
                ELSE 0
                END) AS UNCFRM_ORDER_QTY,
        SUM(CASE 
                WHEN OOS.OPEN_ORDER_STATUS_CD = 'C'
                    THEN OOS.OPEN_ORDER_QTY
                ELSE 0
                END) AS CNFRM_ORDER_QTY,
        SUM(CASE 
                WHEN OOS.OPEN_ORDER_STATUS_CD NOT IN (
                        'B',
                        'U',
                        'C'
                        )
                    THEN OOS.OPEN_ORDER_QTY
                ELSE 0
                END) AS OTHER_ORDER_QTY
    FROM GDYR_VWS.OPEN_ORDER OOS
    GROUP BY OOS.ORDER_ID,
        OOS.ORDER_LINE_NBR,
        OOS.EFF_DT,
        OOS.EXP_DT
    ) OO
    ON OO.ORDER_ID = RS.ORDER_ID
        AND OO.ORDER_LINE_NBR = RS.ORDER_LINE_NBR
        AND RS.PRIOR_DY_RESCHD_DT BETWEEN OO.EFF_DT
            AND OO.EXP_DT
GROUP BY RS.RESCHD_DT,
    RS.CMN_OWN_CUST_ID,
    RS.MATL_ID,
    RS.PBU_NBR
WHERE MH.EXT_MATL_GRP_ID = 'TIRE'
    --AND RS.ORDER_ID = '0084154981' AND RS.ORDER_LINE_NBR = '660'
    --AND SD.SLS_DOC_TYP_CD NOT IN ('ZLS', 'ZLZ')
    --AND SD.CUST_PRCH_ORD_TYP_CD <>'RO'
    --AND CH.OWN_CUST_ID <> '00A0005538' --COWD
    --AND CH.CUST_GRP_ID <> '3R' --COWD
    --AND (CASE WHEN CH.OWN_CUST_ID = '00A0000632' AND SUBSTR(SD.CUST_PRCH_ORD_ID,5,2)<>'62'THEN 0 ELSE 1 END) = 1 --SAMS KIOSK
