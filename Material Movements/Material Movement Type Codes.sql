-- EDW table appears to be similar to T156SY in  NAT AP0
-- complete list of movement types and descriptions -- see IMG MM-IM
/*
http://www.slideshare.net/vinitlodha/movement-typesinsapmm
-- SAP movement types deck / documentation of process

-- central table -- T156S (T156SY + T156SC)

SAP Material Movement Tables:
-> T156 - Definition
-> T156B - Screen layout & Batch determination
-> T156SC - WM movement, availability check (complete key)
-> T156Q - QM inspection lot origin, HU
-> T156X - Account modifier
-> T156T - Short text
-> T158B - Allowed movement types per transaction
-> T157H - Longer text per transaction / special stock
-> T157D - Reason for movement
-> TMCA - LIS statistic group
-> T156SY - Quantity / value strings
    -> T156W - Value strings
    -> T156M - Quantity Strings


T-code OMJJ manages customizable movement types


*/

-- when '' then ''

SELECT
    -- movement type code
    MVMNT_TYP_CD

    -- special stock type code
    , SPCL_STK_TYP_CD
    , CAST(CASE SPCL_STK_TYP_CD
        WHEN ' ' THEN 'Undefined'
        WHEN 'E' THEN 'Orders on hand'
        WHEN 'K' THEN 'Consignment (vendor)'
        WHEN 'M' THEN 'Ret. trans. pkg vendor'
        WHEN 'O' THEN 'Parts prov. vendor'
        WHEN 'P' THEN 'Pipeline material'
        WHEN 'Q' THEN 'Project stock'
        WHEN 'V' THEN 'Ret. pkg w. customer'
        WHEN 'W' THEN 'Consignment (cust)'
        WHEN 'Y' THEN 'Shipping unit (whse)'
        END AS VARCHAR(255)) AS SPCL_STK_TYP_DESC

    -- goods movement category indicator -- T156S-KZBEW -- Depends on AP0 table T158
    , MVMNT_ICD
    , CAST(CASE MVMNT_ICD
        WHEN ' ' THEN 'Movement w/o reference to purchase/production order'
        WHEN 'B' THEN 'Purchase Order'
        WHEN 'F' THEN 'Production Order'
        WHEN 'L' THEN 'LE-SHP delivery'
        END AS VARCHAR(255)) AS MVMNT_DESC

    -- receipt category indicator -- T156S-KZZUG --
    -- filled only in the case of transport orders, GR 101 or GI 351/641/643
    , RCPT_ICD
    , CAST(CASE RCPT_ICD
        WHEN ' ' THEN 'Normal Receipt'
        WHEN 'X' THEN 'Stock Transport Order'
        WHEN 'L' THEN 'Tied Empties'
        END AS VARCHAR(255)) AS RCPT_DESC

    -- consumption posting category indicator -- T156S-KZVBR -- depends on AT0 table T163K / T-code OME9
        -- available on AP0 - LIPS, EKPO, AFPO
    , CNSMPT_POST_ICD
    , CAST(CASE CNSMPT_POST_ICD
        WHEN ' ' THEN 'No consumption'
        WHEN 'V' THEN 'Consumption'
        WHEN 'A' THEN 'Asset'
        WHEN 'E' THEN 'Sales Order'
        WHEN 'P' THEN 'Project'
        END AS VARCHAR(255)) AS CNSMPT_POST_DESC

    , MVMNT_TYP_DESC

    , CAST(CASE
        WHEN MVMNT_TYP_CD LIKE ANY ('1%', '5%')
            THEN 'GR'
        WHEN MVMNT_TYP_CD LIKE '2%'
            THEN 'GI'
        WHEN MVMNT_TYP_CD LIKE ANY ('3%', '4%')
            THEN 'TF'
        WHEN MVMNT_TYP_CD LIKE '6%'
            THEN 'LE'
        WHEN MVMNT_TYP_CD LIKE '7%'
            THEN 'PI'
        WHEN MVMNT_TYP_CD LIKE '8%'
            THEN 'BZ'
        WHEN MVMNT_TYP_CD LIKE ANY ('9%', 'X%', 'Y%', 'Z%')
            THEN 'CR'
        ELSE 'UC'
        END AS CHAR(2)) AS SAP_MVMNT_TYP_CLSS_CD

    -- more detailed than the codes -- uses slightly more specific grouping logic
    , CAST(CASE
        WHEN MVMNT_TYP_CD LIKE '1%'
            THEN 'GR from purchasing/production + returns'
        WHEN MVMNT_TYP_CD LIKE '2%'
            THEN 'GI for consumption'
        WHEN MVMNT_TYP_CD LIKE ANY ('3%', '4%')
            THEN 'Transfers'
        WHEN MVMNT_TYP_CD LIKE '5%'
            THEN 'GR without reference to PO or PP order'
        WHEN MVMNT_TYP_CD LIKE '6%'
            THEN 'LE-SHP movement types'
        WHEN MVMNT_TYP_CD LIKE '7%'
            THEN 'Physical inventory (MM-IM: 70x / WM: 71x)'
        WHEN MVMNT_TYP_CD LIKE '8%'
            THEN 'Brazil'
        WHEN MVMNT_TYP_CD LIKE ANY ('9%', 'X%', 'Y%', 'Z%')
            THEN 'Customer Range'
        ELSE 'Unclassified'
        END AS VARCHAR(255)) AS SAP_MVMNT_TYP_CLSS_DESC

FROM GDYR_VWS.MVMNT_TYP_DESC

WHERE
    ORIG_SYS_ID = 2
    AND LANG_ID = 'E'
    AND EXP_DT = DATE '5555-12-31'

ORDER BY
    MVMNT_TYP_CD
    , SPCL_STK_TYP_CD
    , MVMNT_ICD
    , RCPT_ICD
    , CNSMPT_POST_ICD
