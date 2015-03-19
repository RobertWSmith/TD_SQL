SELECT
    V.VEND_ID
    , V.VEND_NM
    , V.VEND_ID || ' - ' || V.VEND_NM AS VEND

    , V.TRADE_PARTNER_ID
    , T.TRADE_PARTNER_NM
    , T.TRADE_PARTNER_ID || ' - ' || T.TRADE_PARTNER_NM AS TRADE_PARTNER

    , T.CNTRY_NAME_CD
    , T.CNTRY_NAME
    , T.GDYR_RGN_NM

FROM GDYR_BI_VWS.VENDOR_CURR V

    LEFT OUTER JOIN (
        SELECT
            T.TRADE_PARTNER_ID
            , T.TRADE_PARTNER_NM
            , T.CNTRY_NAME_CD
            , C.CNTRY_NAME
            , C.GDYR_RGN_NM

        FROM GDYR_BI_VWS.TRADE_PARTNER_CURR T

            INNER JOIN GDYR_VWS.CNTRY C
                ON C.CNTRY_NAME_CD = T.CNTRY_NAME_CD
                AND C.ORIG_SYS_ID = 2
                AND C.LANG_ID = 'E'
                AND C.EXP_DT = DATE '5555-12-31'
        WHERE
            T.ORIG_SYS_ID = 2

            ) T
        ON T.TRADE_PARTNER_ID = V.TRADE_PARTNER_ID

WHERE
    V.ORIG_SYS_ID = 2
    AND V.LANG_ID = 'E'

ORDER BY
	V.VEND_ID
