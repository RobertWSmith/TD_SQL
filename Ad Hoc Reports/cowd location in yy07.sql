SELECT
    i.day_dt
    , i.facility_id

FROM na_bi_vws.facl_matl_inv i

    INNER JOIN gdyr_bi_vws.nat_facility_en_Curr f
        ON f.facility_id = i.facility_id
        AND f.sales_org_Cd = 'n340'

GROUP BY
    1,2