﻿SELECT
	TRANS.SHIP_FROM_FACILITY_ID,
	TRANS.SHIP_FROM_CITY_NM,
	TRANS.SHIP_TO_FACILITY_ID,
	TRANS.SHIP_TO_CITY_NM,
	TRANS.GOODS_ISS_DT,
	TRANS.GOODS_RCPT_DT,
	TRANS.GOODS_RCPT_WEEK,
	TRANS.RND_TRANSIT_DY_GOAL,
	TRANS.RND_DAYS_IN_TRANSIT,
	CASE WHEN RND_DAYS_IN_TRANSIT < 1 THEN 1 ELSE 0 END AS LT_ONE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 1 THEN 1 ELSE 0 END AS ONE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 2 THEN 1 ELSE 0 END AS TWO,
	CASE WHEN RND_DAYS_IN_TRANSIT = 3 THEN 1 ELSE 0 END AS THREE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 4 THEN 1 ELSE 0 END AS FOUR,
	CASE WHEN RND_DAYS_IN_TRANSIT = 5 THEN 1 ELSE 0 END AS FIVE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 6 THEN 1 ELSE 0 END AS SIX,
	CASE WHEN RND_DAYS_IN_TRANSIT = 7 THEN 1 ELSE 0 END AS SEVEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 8 THEN 1 ELSE 0 END AS EIGHT,
	CASE WHEN RND_DAYS_IN_TRANSIT = 9 THEN 1 ELSE 0 END AS NINE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 10 THEN 1 ELSE 0 END AS TEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 11 THEN 1 ELSE 0 END AS ELEVEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 12 THEN 1 ELSE 0 END AS TWELVE,
	CASE WHEN RND_DAYS_IN_TRANSIT = 13 THEN 1 ELSE 0 END AS THIRTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 14 THEN 1 ELSE 0 END AS FOURTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 15 THEN 1 ELSE 0 END AS FIFTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 16 THEN 1 ELSE 0 END AS SIXTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 17 THEN 1 ELSE 0 END AS SEVENTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 18 THEN 1 ELSE 0 END AS EIGHTEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 19 THEN 1 ELSE 0 END AS NINETEEN,
	CASE WHEN RND_DAYS_IN_TRANSIT = 20 THEN 1 ELSE 0 END AS TWENTY,
	CASE WHEN RND_DAYS_IN_TRANSIT > 20 THEN 1 ELSE 0 END AS GT_TWENTY,
	CASE WHEN TRANS.GOAL_STATUS = 'In Time' THEN 1 ELSE 0 END AS IN_TIME,
	CASE WHEN TRANS.GOAL_STATUS = 'LATE' THEN 1 ELSE 0 END AS LATE,
	1 AS SHIPMENT,
	TRANS.LAST_SUNDAY,
	TRANS.LAST_WEEK_MON
FROM
	(
		SELECT
			--YTRANSIT DATA ROLLED UP  TO SAP BOL
			YTRANSIT.BILL_LADING_ID,
			YTRANSIT.SHIP_FROM_FACILITY_ID,
			YTRANSIT.SHIP_FROM_CITY_NM,
			YTRANSIT.SHIP_TO_FACILITY_ID,
			YTRANSIT.SHIP_TO_CITY_NM,
			YTRANSIT.LANE,
			YTRANSIT.TM_CARR_ID AS CARRIER,
			YTRANSIT.TRANSP_ID AS TRAILER,
			YTRANSIT.GOODS_ISS_TS,
			YTRANSIT.GOODS_ISS_DT,
			GI_CAL.DAY_OF_WEEK_NAME_ABBREV AS GOODS_ISS_DAY,
			GI_CAL.WEEK_OF_YEAR_ISO AS GOODS_ISS_WEEK,
			GI_CAL.CAL_MTH AS GOODS_ISS_MONTH,
			GI_CAL.CAL_YR AS GOODS_ISS_YEAR,
			YTRANSIT.GOODS_RCPT_TS,
			YTRANSIT.GOODS_RCPT_DT,
			GR_CAL.DAY_OF_WEEK_NAME_ABBREV AS GOODS_RCPT_DAY,
			GR_CAL.WEEK_OF_YEAR_ISO AS GOODS_RCPT_WEEK,
			GR_CAL.CAL_MTH AS GOODS_RCPT_MONTH,
			GR_CAL.CAL_YR AS GOODS_RCPT_YEAR,
			YTRANSIT.DAYS_IN_TRANSIT,
			CAST(YTRANSIT.DAYS_IN_TRANSIT AS DECIMAL(4, 0)) AS RND_DAYS_IN_TRANSIT,
			--SHPPING LANE ATRRIBUTE
			YTRANSIT.TRANSIT_TM_QTY,
			--FRIEGHT MOVEMENT (LOAD) ATTRIBUTES
			FRT_MVMNT.GATE_OUT_TS,
			FRT_MVMNT.GATE_IN_TS,
			FRT_MVMNT.MI_QTY,
			FRT_MVMNT.PLN_NOTE_1_TXT,
			FRT_MVMNT.PLN_NOTE_2_TXT,
			--ORDER (DELIVERY) CONTRACT TYPE
			FRT_MVMNT.CONTRACT_TYPE,
			--EWM PLANNING DATES
			EWM_PLAN.PLN_START_DT,
			EWM_PLAN.PLN_START_DAY,
			EWM_PLAN.PLN_START_TM,
			EWM_PLAN.PLN_START_TS,
			--TRANSPORT PERFORMANCE METRICS IN DAYS
			YTRANSIT.DAYS_IN_TRANSIT - YTRANSIT.TRANSIT_TM_QTY AS TRANSIT_GOAL_VS_ACTUAL,
			CAST(((FRT_MVMNT.GATE_OUT_TS - YTRANSIT.GOODS_ISS_TS) HOUR(4)) AS DECIMAL(6, 2)) / CAST(24 AS DECIMAL(6, 2)) AS GI_TO_GATE_OUT_DAYS,
			CAST(((FRT_MVMNT.GATE_OUT_TS - FRT_MVMNT.GATE_IN_TS) HOUR(4)) AS DECIMAL(6, 2)) / CAST(24 AS DECIMAL(6, 2)) AS GATE_OUT_TO_IN_DAYS,
			CAST(((FRT_MVMNT.GATE_IN_TS - YTRANSIT.GOODS_RCPT_TS) HOUR(4)) AS DECIMAL(6, 2)) / CAST(24 AS DECIMAL(6, 2)) AS GATE_IN_TO_GR_DAYS,
			CAST(((FRT_MVMNT.GATE_OUT_TS - EWM_PLAN.PLN_START_TS) HOUR(4)) AS DECIMAL(6, 2)) / CAST(24 AS DECIMAL(6, 2)) AS GATE_IN_TO_APPT_DAYS,
			CASE
				WHEN YTRANSIT.GOODS_RCPT_DT - EWM_PLAN.PLN_START_DT < 416.6
					THEN CAST(((YTRANSIT.GOODS_RCPT_TS - EWM_PLAN.PLN_START_TS) HOUR(4)) AS DECIMAL(6, 2)) / CAST(24 AS DECIMAL(6, 2))
				ELSE YTRANSIT.GOODS_RCPT_DT - EWM_PLAN.PLN_START_DT
			END AS APPT_TO_GR_DAYS,
			--WEIGHT ROLLED UP TO BOL FROM AND TO FACILITY
			YTRANSIT.WEIGHT_QTY,
			--TOTAL LANE TRANSIT GOAL
			YTRANSIT.TRANSIT_DY_GOAL,
			CAST(YTRANSIT.TRANSIT_DY_GOAL AS DECIMAL(4, 0)) AS RND_TRANSIT_DY_GOAL,
			--PREVIOUS SUNDAY FOR FILTERING LAST WEEK
			FILTER.LAST_SUNDAY,
			FILTER.LAST_SUNDAY - 6 AS LAST_WEEK_MON,
			CASE
				WHEN RND_DAYS_IN_TRANSIT IS NULL
					THEN 'Not Applicable'
				WHEN RND_DAYS_IN_TRANSIT <= RND_TRANSIT_DY_GOAL
					THEN 'In Time'
				ELSE 'Late'
			END AS GOAL_STATUS
		FROM
			NA_BI_VWS.TM_TRANSIT_SMRY YTRANSIT
			INNER JOIN GDYR_BI_VWS.GDYR_CAL GI_CAL
			ON
				YTRANSIT.GOODS_ISS_DT = GI_CAL.DAY_DATE
			LEFT OUTER JOIN GDYR_BI_VWS.GDYR_CAL GR_CAL
			ON
				YTRANSIT.GOODS_RCPT_DT = GR_CAL.DAY_DATE
			LEFT OUTER JOIN NA_BI_VWS.TM_INBNDTRNS_SMRY_CURR EWM_PLAN
			ON
				YTRANSIT.BILL_LADING_ID = EWM_PLAN.BILL_LADING_ID
				AND YTRANSIT.SHIP_FROM_FACILITY_ID = EWM_PLAN.SHIP_FROM_FACILITY_ID
				AND YTRANSIT.SHIP_TO_FACILITY_ID = EWM_PLAN.SHIP_TO_FACILITY_ID
			LEFT OUTER JOIN NA_BI_VWS.TM_FRT_MVMNT_SMRY_CURR FRT_MVMNT
			ON
				FRT_MVMNT.BOL_ID = YTRANSIT.BILL_LADING_ID
				AND FRT_MVMNT.SHIP_FROM_FACILITY_ID = YTRANSIT.SHIP_FROM_FACILITY_ID
				AND FRT_MVMNT.SHIP_TO_FACILITY_ID = YTRANSIT.SHIP_TO_FACILITY_ID
			INNER JOIN
				(
					SELECT
						DAY_DATE AS LAST_SUNDAY
					FROM
						GDYR_BI_VWS.GDYR_CAL
					WHERE
						DAY_OF_WEEK = 1
						AND DAY_DATE BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE
				)
				FILTER
			ON
				1 = 1
	)
	TRANS