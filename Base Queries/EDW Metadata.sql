﻿SELECT 
    V.DATABASENAME
	, V.TABLENAME
	, V.COLUMNNAME
	, CAST(ALIAS1 || ALIAS2 || ALIAS3 || ALIAS4 || ALIAS5 AS VARCHAR(5)) AS TABLE_ALIAS
    , CAST(',' AS CHAR(1)) AS COMMA
	, TRIM(TABLE_ALIAS) || '.' || V.COLUMNNAME AS ALIASED_COLUMN
	, '/* ' || CASE 
		WHEN IDX.DATABASENAME IS NOT NULL
			THEN 'INDEXED '
		ELSE ''
		END || REGEXP_REPLACE(B.COMMENTSTRING, '(\r+|\n+)', ' ', 1, 0, 'i') || '*/' AS COMMENT_STRING
	, CASE 
		WHEN V.TABLENAME LIKE ANY ('NAT_SLS_DOC_SCHD_LN%', 'NAT_SLS_DOC_ITM%', 'NAT_SLS_DOC%', 
                                    'BATCH_INV', 'DELIV_IN_PROC%', 'SD_DOC_%', 'NAT_DELIV_DOC%')
			THEN 'GDYR_EDW'
		WHEN V.TABLENAME LIKE ANY ('ORDER_DETAIL%', 'TM_INOUTBND_DELIV%','DELIVERY_DETAIL%')
			THEN 'NA_MART'
		WHEN V.TABLENAME LIKE ANY ('OPEN_ORDER_ORDLN_CURR', 'OPEN_ORDER_SCHDLN%' 'TM_%')
			THEN 'NA_EDW'
		END AS BASE_TABLE_DATABASENAME
	, CAST(CASE
            WHEN V.TABLENAME = 'DELIVERY_DETAIL_CURR'
                THEN 'DELIV_DTL'
            WHEN V.TABLENAME LIKE 'ORDER_DETAIL%'
                THEN 'ORD_DTL'
            ELSE REGEXP_REPLACE(V.TABLENAME, '(NAT\_|\_CURR|\_ALL)', '', 1, 0, 'I') 
            END AS CHAR(30)) AS BASE_TABLE_TABLENAME
        
	, CASE 
		WHEN V.TABLENAME LIKE 'ORDER_DETAIL%' AND V.COLUMNNAME LIKE 'FC_%'
			THEN CAST('FRST_PROM_' || SUBSTR(V.COLUMNNAME, 4, 30) AS CHAR(30))
		ELSE V.COLUMNNAME
		END AS BASE_TABLE_COLUMNNAME
	, V.COLUMNID
	, IDX.NUPI_IND
	, IDX.UPI_IND
	, IDX.JI_IND
	, IDX.PI_IND
	, IDX.OTHER_IND
	, CASE 
		WHEN IDX.UPI_IND = 'UPI' THEN 0
		WHEN IDX.PI_IND = 'PI' THEN 1
		WHEN IDX.NUPI_IND = 'NUPI' THEN 2
		WHEN IDX.JI_IND = 'JI' THEN 3
		ELSE 4
		END AS IDX_SORT_KEY
	, COALESCE(CAST(REGEXP_SUBSTR(INITCAP(REGEXP_REPLACE(TRIM(V.TABLENAME), '\_', ' ', 1, 0, 'i')), '([[:upper:]]{1,})', 1, 1, 'c') AS VARCHAR(1)), '') AS ALIAS1
	, COALESCE(CAST(REGEXP_SUBSTR(INITCAP(REGEXP_REPLACE(TRIM(V.TABLENAME), '\_', ' ', 1, 0, 'i')), '([[:upper:]]{1,})', 1, 2, 'c') AS VARCHAR(1)), '') AS ALIAS2
	, COALESCE(CAST(REGEXP_SUBSTR(INITCAP(REGEXP_REPLACE(TRIM(V.TABLENAME), '\_', ' ', 1, 0, 'i')), '([[:upper:]]{1,})', 1, 3, 'c') AS VARCHAR(1)), '') AS ALIAS3
	, COALESCE(CAST(REGEXP_SUBSTR(INITCAP(REGEXP_REPLACE(TRIM(V.TABLENAME), '\_', ' ', 1, 0, 'i')), '([[:upper:]]{1,})', 1, 4, 'c') AS VARCHAR(1)), '') AS ALIAS4
	, COALESCE(CAST(REGEXP_SUBSTR(INITCAP(REGEXP_REPLACE(TRIM(V.TABLENAME), '\_', ' ', 1, 0, 'i')), '([[:upper:]]{1,})', 1, 5, 'c') AS VARCHAR(1)), '') AS ALIAS5

FROM DBC.COLUMNS V

    LEFT OUTER JOIN DBC.TABLES T
    	ON T.DATABASENAME = BASE_TABLE_DATABASENAME
    		AND T.TABLENAME = BASE_TABLE_TABLENAME
            
    LEFT OUTER JOIN DBC.COLUMNS B
    	ON B.COLUMNNAME = BASE_TABLE_COLUMNNAME
    		AND B.DATABASENAME = BASE_TABLE_DATABASENAME
    		AND B.TABLENAME = BASE_TABLE_TABLENAME
            
    LEFT OUTER JOIN (
    	SELECT 
            MAX(CASE WHEN TRIM(INDEXNAME) LIKE '%_NUPI' THEN 'NUPI' END) AS NUPI_IND
    		, MAX(CASE WHEN TRIM(INDEXNAME) LIKE '%_UPI' AND TRIM(INDEXNAME) NOT LIKE '%_NUPI' THEN 'UPI' END) AS UPI_IND
    		, MAX(CASE WHEN TRIM(INDEXNAME) LIKE '%_JI%' AND TRIM(INDEXNAME) NOT LIKE '%_JI' THEN 'JI' END) AS JI_IND
    		, MAX(CASE WHEN TRIM(INDEXNAME) LIKE '%_PI' THEN 'PI' END) AS PI_IND
    		, MAX(CASE 
                WHEN TRIM(INDEXNAME) NOT LIKE ANY ('%_JI', '%_UPI', '%_NUPI') 
                    THEN SUBSTR(TRIM(INDEXNAME), LENGTH(TRIM(INDEXNAME)) - 5, LENGTH(TRIM(INDEXNAME)))
                END) AS OTHER_IND
    		, I.DATABASENAME
    		, I.TABLENAME
    		, I.COLUMNNAME
    	FROM DBC.INDICES I
    	WHERE DATABASENAME IN ('GDYR_EDW', 'NA_EDW', 'NA_MART') -- 'GYDR_MART',
    	GROUP BY I.DATABASENAME
    		, I.TABLENAME
    		, I.COLUMNNAME
    	) IDX
    	ON IDX.DATABASENAME = BASE_TABLE_DATABASENAME
    		AND IDX.TABLENAME = BASE_TABLE_TABLENAME
    		AND IDX.COLUMNNAME = BASE_TABLE_COLUMNNAME

WHERE 
    V.DATABASENAME IN ('GDYR_VWS', 'GDYR_BI_VWS', 'NA_BI_VWS')
	AND V.TABLENAME IN (
		'NAT_SLS_DOC', 'NAT_SLS_DOC_ITM', 'NAT_SLS_DOC_SCHD_LN', 
        'NAT_DELIV_DOC_CURR', 'NAT_DELIV_DOC_CURR_ALL', 'NAT_DELIV_DOC_ITM_CURR', 
        'ORDER_DETAIL', 'ORDER_DETAIL_CURR', 'OPEN_ORDER_SCHDLN_CURR', 
        'SD_DOC_BUS_DATA', 'SD_DOC_FLOW', 'SD_DOC_PARTNER', 
        'TM_CARR_CURR', 'TM_CARR_DELIV_MSG_CURR', 'TM_CARR_DELIV_STA_CURR', 
        'TM_CARR_DTL_CURR', 'TM_CARR_EQUIP_CURR', 'TM_CARR_TARIFF_CURR', 
        'TM_COMIT_VOL_AWRD_CURR', 'TM_COMIT_VOL_PLN_CURR', 'TM_DELIV_CURR', 
        'TM_DELIV_ITM_CURR', 'TM_DELIV_PRFL_CURR', 'TM_DLV_FRTMV_ACC_CURR', 
        'TM_DLV_FRTMV_CST_CURR', 'TM_DLV_FRTMV_SEQ_CURR', 'TM_FRT_MVMNT_CURR', 
        'TM_FRT_MVMNT_SMRY_CURR', 'TM_FRT_MVMNT_STA', 'TM_FRT_MVMNT_STOP_CURR', 
        'TM_FRTMV_DLV_XREF_CURR', 'TM_GDYR_SPLC_CURR', 'TM_INBNDTRNS_DTL_CURR', 
        'TM_INBNDTRNS_SMRY_CURR', 'TM_INOUTBND_DELIV_CURR', 'TM_INTRANSIT_DTL_CURR', 
        'TM_LANE_RT_NTWRK_CURR', 'TM_LANE_TRANSITTM_CURR', 'TM_LOCATION_CURR', 'TM_RADL_RT', 
        'TM_RADL_RT_BAND_CURR', 'TM_RADL_RT_CURR', 'TM_RADL_RT_PERD_CURR', 'TM_RAIL_RT_CURR', 
        'TM_RAIL_RT_TYPE_CURR', 'TM_REGION_KEY_CURR', 'TM_SHIP_LANE_CURR', 'TM_SHIP_STA_CURR', 
        'TM_TL_RT_CURR', 'TM_TL_RT_TYPE_CURR', 'TM_TRANSIT_SMRY'
		)
        
ORDER BY 
    V.DATABASENAME
	, V.TABLENAME
	, IDX_SORT_KEY
	, V.COLUMNID
