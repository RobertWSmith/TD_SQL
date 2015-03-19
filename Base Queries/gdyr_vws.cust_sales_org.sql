SELECT
    CUST_ID
	, SALES_ORG_CD
	, DISTR_CHAN_CD
	, DIV_CD
	, EFF_DT
	, EXP_DT
	, FACILITY_ID
	, ORDER_BLK_CD
	, CUST_GRP_ID
	, DELIV_PRTY_CD
	, CUST_GRP2_CD
	, SHIP_COND_ID
	, INCOTERM_CD
	, INCOTERM_TXT
	, DELIV_BLK_CD
FROM GDYR_VWS.CUST_SALES_ORG
WHERE
    ORIG_SYS_ID = 2
    AND EXP_DT = DATE '5555-12-31'
    AND ORDER_BLK_CD = 0
    AND SALES_ORG_CD IN (
            'N301', 'N302', 'N303', 'N304', 'N305', 'N309'
            , 'N311', 'N312', 'N313'
            , 'N321', 'N322', 'N323', 'N325'
        )
    AND DISTR_CHAN_CD IN (
            '01', '03', '04', '05', '06', '07', '08', '09'
            , '10', '11', '12', '14', '15', '16'
            , '20', '21', '22'
            , '30', '31', '32'
            , '40', '41', '42', '43', '44', '45'
            , '50', '51', '55', '56', '62', '84'
        )
