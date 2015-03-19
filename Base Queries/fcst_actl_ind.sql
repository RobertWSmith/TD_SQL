SELECT
    cal.day_date AS bus_dt,
    CAST('Actual' AS VARCHAR(10)) AS fcst_actl_ind

FROM gdyr_bi_vws.gdyr_cal cal

WHERE
    cal.day_date BETWEEN CAST(ADD_MONTHS(CURRENT_DATE, -72) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, -72)) AS DATE) AND (CURRENT_DATE-1)

UNION ALL

SELECT
    cal.day_date AS bus_dt,
    CAST('Forecast' AS VARCHAR(10)) AS fcst_actl_ind

FROM gdyr_bi_vws.gdyr_cal cal

WHERE
    cal.day_date BETWEEN CURRENT_DATE AND ADD_MONTHS(CURRENT_DATE, 73) - EXTRACT(DAY FROM ADD_MONTHS(CURRENT_DATE, 73))

ORDER BY
    1
