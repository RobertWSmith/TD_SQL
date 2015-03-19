﻿SELECT
    DAY_DATE
    , DAY_DATE - CAST(1 AS INTERVAL DAY(4)) AS PRIOR_DATE
    , MONTH_DT
    , ADD_MONTHS(MONTH_DT, -1) AS PRIOR_MONTH_DT
    , MONTH_DT - CAST(1 AS INTERVAL DAY(4)) AS PRIOR_EOM_DATE

    , TTL_DAYS_IN_MNTH
    , MTH_WRK_DYS
    , MTD_WRK_DYS

    , DAY_OF_WEEK_NAME_ABBREV
    , DAY_OF_WEEK_NAME_DESC
    , CAL_LAST_DAY_MO_IND
    , CAL_LAST_DAY_YR_IND

    , CAL_MTH
    , QUARTER_OF_YEAR
    , CAL_YR

    , WEEK_OF_MONTH
    , WEEK_OF_YEAR

    , INITCAP(MNTH_NAME_ABBREV) AS MNTH_NAME_ABBREV
    , MNTH_NAME

    , QUARTER

FROM GDYR_BI_VWS.GDYR_CAL