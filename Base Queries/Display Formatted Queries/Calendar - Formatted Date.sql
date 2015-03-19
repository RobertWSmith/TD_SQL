SELECT
    cal.day_of_week_name_desc 
    || ' ' || 
    cal.mnth_name 
    || ' ' || 
    CAST(EXTRACT(DAY FROM cal.day_date) AS VARCHAR(2)) || 
    CAST(CASE 
       WHEN CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)) <> '11' AND SUBSTR(CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)), 2, 1) = '1'
            THEN 'st'
        WHEN CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)) <> '12' AND SUBSTR(CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)), 2, 1) = '2'
            THEN 'nd'
        WHEN CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)) <> '13' AND SUBSTR(CAST(CAST(EXTRACT(DAY FROM cal.day_date) AS FORMAT '-9(2)') AS CHAR(2)), 2, 1) = '3'
            THEN 'rd'
        ELSE 'th'
    END AS VARCHAR(2))
    || ', ' || 
    cal.cal_yr AS formatted_date,
    cal.*
    
FROM gdyr_bi_vws.gdyr_cal cal

WHERE
    cal.day_date BETWEEN (CURRENT_DATE - 62) AND (CURRENT_DATE)

ORDER BY
    day_date DESC
