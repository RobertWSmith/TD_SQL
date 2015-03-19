SELECT
    XREF.FRT_MVMNT_ID
    , XREF.FRT_MVMNT_SCHD_ID
    
    , XREF.TM_DELIV_ID
    , XREF.TM_PLN_SCHD_ID
    , XREF.TM_DELIV_SPLIT_ID
    
    , XREF.SAP_DELIV_FISCAL_YR
    , XREF.SAP_DELIV_ID
    
    , FM.MSTR_BILL_LADING_ID
    , FMS.STOP_BILL_LADING_ID

    , FM.FRT_MVMNT_STA_CD
    , FMS.STOP_TYP_CD
    
    , FM.TRANSP_MODE_CD
    , FM.FROM_TM_LOC_ID
    , FM.TO_TM_LOC_ID
    , FMS.TM_LOC_ID

    , FM.STOP_QTY
    , FM.TM_CARR_ID
    , FM.TRLR_TYP_ID

    , FM.WT_QTY
    , FM.CU_VOL_QTY
    , FM.PC_QTY

    , FM.XDOCK_CD

    , FMS.WT_QTY
    , FMS.CU_VOL_QTY
    , FMS.PC_QTY

    , FMS.DEPART_TS

    , FMS.CARR_APPT_DT
    , FMS.CARR_APPT_TS
    
    , TDC.TM_DELIV_TYP_CD
    , TDC.TM_SHIP_FROM_LOC_ID
    , TDC.TM_SHIP_TO_LOC_ID
    
    , TDC.TM_DELIV_STA_CD
    , TDC.TM_DELIV_STA_TS
    
    , TDC.APPT_CD
    , TDC.CUST_APPT_TS
    
    , CASE
        WHEN CDM.FRT_MVMNT_ID IS NOT NULL
            THEN 'Y'
        ELSE 'N'
        END AS EDI_AVAIL_IND
    
    , CDM.CARR_ACCEPT_TS
    , CDM.READYBYPLN_DT
    , CDM.ARRV_AT_PKUP_TS
    , CDM.DEPART_FROM_PKUP_TS
    , CDM.REQ_DELIV_DT
    , CDM.PLN_ARRV_TS
    , CDM.LPC_APPT_TS
    , CDM.ARRV_AT_DELIV_TS

FROM (
    SELECT
        X.SAP_DELIV_ID_FISCAL_YR AS SAP_DELIV_FISCAL_YR
        , X.SAP_DELIV_ID
        , X.TM_DELIV_ID
        , X.TM_PLN_SCHD_ID
        , X.TM_DELIV_SPLIT_ID
        , X.FRT_MVMNT_ID
        , X.FRT_MVMNT_SCHD_ID
        , X.FRT_MVMNT_STOP_ID

    FROM NA_BI_VWS.TM_FRTMV_DLV_XREF_CURR X

    WHERE
        X.SAP_DELIV_ID_FISCAL_YR IS NOT NULL
        AND X.SAP_DELIV_ID IS NOT NULL
        AND X.SAP_DELIV_ID_FISCAL_YR = CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) AS CHAR(4))

    QUALIFY
        ROW_NUMBER() OVER (PARTITION BY X.SAP_DELIV_ID_FISCAL_YR, X.SAP_DELIV_ID ORDER BY X.FRT_MVMNT_ID DESC, X.FRT_MVMNT_STOP_ID DESC) = 1
    ) XREF
    
    INNER JOIN (
            SELECT --TOP 1000
                M.FRT_MVMNT_ID
                , M.FRT_MVMNT_SCHD_ID
                
                , M.FRT_MVMNT_STA_CD
                , M.BILL_LADING_ID AS MSTR_BILL_LADING_ID
                
                , M.TRANSP_MODE_CD
                , M.FROM_TM_LOC_ID
                , M.TO_TM_LOC_ID
                
                , M.STOP_QTY
                , M.TM_CARR_ID
                , M.TRLR_TYP_ID
                
                , M.WT_QTY
                , M.CU_VOL_QTY
                , M.PC_QTY
                
                , M.XDOCK_CD

            FROM NA_BI_VWS.TM_FRT_MVMNT_CURR M

            WHERE
                M.DOCK_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
            ) FM
        ON FM.FRT_MVMNT_ID = XREF.FRT_MVMNT_ID
        AND FM.FRT_MVMNT_SCHD_ID = XREF.FRT_MVMNT_SCHD_ID

    INNER JOIN (
            SELECT --TOP 1000
                S.FRT_MVMNT_ID
                , S.FRT_MVMNT_SCHD_ID
                , S.FRT_MVMNT_STOP_ID
                
                , S.BILL_LADING_ID AS STOP_BILL_LADING_ID
                
                , S.TM_LOC_ID
                , S.STOP_TYP_CD
                
                , S.WT_QTY
                , S.CU_VOL_QTY
                , S.PC_QTY
                
                , CAST(S.DEPART_DT AS TIMESTAMP(0)) + (S.DEPART_TM - TIME '00:00:00' HOUR TO SECOND) AS DEPART_TS
                
                , S.CARR_APPT_DT
                , CAST(S.CARR_APPT_DT AS TIMESTAMP(0)) + (S.CARR_APPT_TM - TIME '00:00:00' HOUR TO SECOND) AS CARR_APPT_TS

            FROM NA_BI_VWS.TM_FRT_MVMNT_STOP_CURR S

            WHERE
                S.DEPART_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
            ) FMS
        ON FMS.FRT_MVMNT_ID = XREF.FRT_MVMNT_ID
        AND FMS.FRT_MVMNT_SCHD_ID = XREF.FRT_MVMNT_SCHD_ID
        AND FMS.FRT_MVMNT_STOP_ID = XREF.FRT_MVMNT_STOP_ID

    INNER JOIN (
            SELECT
                D.TM_DELIV_ID
                , D.TM_PLN_SCHD_ID
                , D.TM_DELIV_SPLIT_ID
                
                , D.SAP_DELIV_ID_FISCAL_YR AS SAP_DELIV_FISCAL_YR
                , D.SAP_DELIV_ID
                
                , D.TM_DELIV_TYP_CD
                , D.TM_SHIP_FROM_LOC_ID
                , D.TM_SHIP_TO_LOC_ID
                
                , D.TM_DELIV_STA_CD
                , CAST(D.TM_DELIV_STA_DT AS TIMESTAMP(0)) + (D.TM_DELIV_STA_TM - TIME '00:00:00' HOUR TO SECOND) AS TM_DELIV_STA_TS
                
                , D.OWN_TXT AS APPT_CD
                , CAST(D.CUST_APPT_DT AS TIMESTAMP(0)) + (D.CUST_APPT_TM - TIME '00:00:00' HOUR TO SECOND) AS CUST_APPT_TS

            FROM NA_BI_VWS.TM_DELIV_CURR D
            WHERE
                D.TM_DELIV_STA_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
            ) TDC
        ON TDC.TM_DELIV_ID = XREF.TM_DELIV_ID
        AND TDC.TM_PLN_SCHD_ID = XREF.TM_PLN_SCHD_ID
        AND TDC.TM_DELIV_SPLIT_ID = XREF.TM_DELIV_SPLIT_ID

    LEFT OUTER JOIN (
                SELECT
                    DM.FRT_MVMNT_ID
                    
                    , DM.TM_DELIV_FISCAL_YR
                    , DM.TM_DELIV_ID
                    , DM.TM_PLN_SCHD_ID
                    
                    , DM.SAP_DELIV_FISCAL_YR
                    , DM.SAP_DELIV_ID
                    
                    , DM.TM_DEST_TYP_CD
                    , DM.TM_SHIP_FROM_LOC_ID
                    , DM.TM_SHIP_TO_LOC_ID
                    , DM.CUST_ID
                    , DM.TM_CARR_ID
                    , DM.CARR_SCAC_ID
                    , DM.MSTR_BOL
                    , DM.SHIP_BOL
                    
                    , DM.CARR_ACCEPT_TS
                    , DM.READYBYPLN_DT
                    , DM.ARRV_AT_PKUP_TS
                    , DM.DEPART_FROM_PKUP_TS
                    , DM.REQ_DELIV_DT
                    , DM.PLN_ARRV_TS
                    , DM.LPC_APPT_TS
                    , DM.ARRV_AT_DELIV_TS
                    , DM.SRC_CRT_TS
                    , DM.SRC_UPD_TS
                    
                FROM NA_BI_VWS.TM_CARR_DELIV_MSG_CURR DM
                WHERE
                    DM.REQ_DELIV_DT >= CAST(EXTRACT(YEAR FROM CURRENT_DATE-1) || '-01-01' AS DATE)
                    AND DM.TM_DEST_TYP_CD = 'CUST'
                    
            ) CDM
        ON CDM.FRT_MVMNT_ID = XREF.FRT_MVMNT_ID
        AND CDM.TM_DELIV_ID = XREF.TM_DELIV_ID
        AND CDM.TM_PLN_SCHD_ID = XREF.TM_PLN_SCHD_ID
        AND CDM.SAP_DELIV_ID = XREF.SAP_DELIV_ID

