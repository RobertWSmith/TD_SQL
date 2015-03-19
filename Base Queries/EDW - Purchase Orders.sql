
SELECT
	M.PBU_NBR,
	M.DESCR,
	PDI.PRCH_DOC_ID,
	PDI.PRCH_DOC_ITM_ID,
	PSL.SCHED_LINE_ID,
	PDI.MATL_ID,
	PD.VEND_ID,
	VM.VEND_NM,
	PDI.FACILITY_ID AS RECV_FACILITY_ID,
	PDI_F.FACILITY_DESC AS RECV_FACILITY_NAME,
	PD.PRCH_DT,
	PSL.REQ_DELIV_DT,			--Original Delivery Date (STO Delivery Date)
	PSL.EST_DELIV_DT,			-- Estimated Delivery Date
	PSL.SCHED_QTY,				-- Scheduled Units
--	PSL.DELIV_QTY,				-- Issued Units
	PSL.GOODS_RCVD_QTY,	-- Received Units
	PSL.SCHED_QTY - PSL.GOODS_RCVD_QTY AS TOTAL_OPEN_QTY,
--	PSL.REDUCE_QTY,			-- Inbound Delivery Qty
	INBOUND_DELIV.MAX_DELIV_DT,
	COALESCE(INBOUND_DELIV.INBOUND_DELIV_QTY, 0) AS INBOUND_QTY,	-- Inbound Delivery Qty
	TOTAL_OPEN_QTY - INBOUND_QTY AS OPEN_NO_INBOUND_QTY
	--INBOUND_DELIV_QTY_1
	
	
FROM
	GDYR_BI_VWS.PRCH_DOC_CURR PD

    INNER JOIN  GDYR_BI_VWS.PRCH_DOC_ITM_CURR PDI
    	ON PD.PRCH_DOC_ID = PDI.PRCH_DOC_ID
    	AND PD.SBU_ID = PDI.SBU_ID
    	AND PD.ORIG_SYS_ID = PDI.ORIG_SYS_ID

    --------------------------------------------------------------------------------------------------------------------------------------------------
    -- Joining to PSL will cause duplicates when there are multiple schedule lines.
    -- This does not happen often with STOs and Paul Scott is OK with the small amount of duplication that is happening.
    -- Currently this amounts to less than 1% variance on Outbound Qty for 2012-01 to 2013-01
    --------------------------------------------------------------------------------------------------------------------------------------------------	

    INNER JOIN GDYR_BI_VWS.PRCH_SCHED_LINE_CURR PSL
    	ON PDI.PRCH_DOC_ID = PSL.PRCH_DOC_ID
    	AND PDI.PRCH_DOC_ITM_ID = PSL.PRCH_DOC_ITM_ID
    	AND PDI.SBU_ID = PSL.SBU_ID
    	AND PDI.ORIG_SYS_ID = PSL.ORIG_SYS_ID

    INNER JOIN GDYR_BI_VWS.NAT_MATL_HIER_DESCR_EN_CURR M
    	ON PDI.MATL_ID = M.MATL_ID

    INNER JOIN GDYR_BI_VWS.FACILITY_CURR PDI_F
        ON PDI.FACILITY_ID = PDI_F.FACILITY_ID
        AND PDI.ORIG_SYS_ID = PDI_F.ORIG_SYS_ID
    	
    LEFT JOIN GDYR_BI_VWS.VENDOR_EN_CURR VM
    	ON VM.VEND_ID = PD.VEND_ID
    	AND VM.ORIG_SYS_ID = PD.ORIG_SYS_ID

    LEFT JOIN (
    	SELECT 
    		DDI.SLS_DOC_ID, 
    		DDI.SLS_DOC_ITM_ID, 
    --		SUM(ACTL_DELIV_QTY) AS INBOUND_DELIV_QTY_1,
    		SUM(CASE WHEN ACTL_GOODS_MVT_DT IS NULL THEN ACTL_DELIV_QTY ELSE 0 END) AS INBOUND_DELIV_QTY,
    		MAX(DELIV_DT) AS MAX_DELIV_DT
    	FROM GDYR_BI_VWS.DELIV_DOC_CURR DD
    	INNER JOIN GDYR_BI_VWS.DELIV_DOC_ITM_CURR DDI
    		ON DD.ORIG_SYS_ID = DDI.ORIG_SYS_ID
    		AND DD.DELIV_DOC_ID = DDI.DELIV_DOC_ID
    		AND DD.EXP_DT = DDI.EXP_DT
    	WHERE DD.ORIG_SYS_ID = 2 
    	AND DD.DELIV_TYP_CD = 'EL'
    	GROUP BY
    		DDI.SLS_DOC_ID, 
    		DDI.SLS_DOC_ITM_ID
    	) INBOUND_DELIV		
    	ON PDI.PRCH_DOC_ID = INBOUND_DELIV.SLS_DOC_ID
    	AND PDI.PRCH_DOC_ITM_ID = INBOUND_DELIV.SLS_DOC_ITM_ID

WHERE
	PD.SBU_ID = 2
	AND PD.ORIG_SYS_ID = 2
    AND PD.PRCH_TYPE_CD = 'NB'
	AND PD.PRCH_DT >= CAST('2012-01-01' AS DATE)
	AND SUBSTRING(PDI.FACILITY_ID FROM 1 FOR 1) = 'N'  -- Destination Facility is a Plant  Warehouse
	AND M.PBU_NBR IN ('01','03')
	AND M.EXT_MATL_GRP_ID =  'TIRE'
	AND (PDI.DEL_IND ='' OR PDI.DEL_IND IS NULL)  -- PO is NOT cancelled
	AND PDI.DELIV_FULL_IND <> 'Y'  -- PO is Open
--	AND PSL.SCHED_QTY > PSL.REDUCE_QTY  -- Has more Scheduled Units than what are accounted for in delivery planning
--	AND PSL.SCHED_QTY > INBOUND_QTY  -- Still has Scheduled Units with no inbound delivery confirmation
	AND PSL.SCHED_QTY > PSL.GOODS_RCVD_QTY  -- Still has Open Qty
	AND 
		(
			(INBOUND_DELIV.MAX_DELIV_DT >= DATE  -- Inbound Delivery date is in the Future and there is no Inbound Qty
--				AND INBOUND_DELIV.INBOUND_DELIV_QTY <> 0)
			)
			OR
			( (INBOUND_DELIV.MAX_DELIV_DT IS NULL OR INBOUND_DELIV.MAX_DELIV_DT< DATE)   -- Inbound Delivery does not exist or is in the past
				AND PSL.EST_DELIV_DT >= DATE-1) -- Open STO's that should shipped today or later (based on current RDD) to make it On Time.  One day adjustment to account for timing of EDW compared to SAP.
		)
