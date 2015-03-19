SELECT
    odc.*
    , ddc.*
    --, ool.*

FROM na_bi_vws.order_detail_curr odc

    INNER JOIN na_bi_vws.delivery_detail_curr ddc
        ON ddc.order_fiscal_yr = odc.order_fiscal_yr
        AND ddc.order_id = odc.order_id
        AND ddc.order_line_nbr = odc.order_line_nbr

/*    INNER JOIN na_bi_vws.open_order_schdln_curr ool
        ON ool.order_fiscal_yr = odc.order_fiscal_yr
        AND ool.order_id = odc.order_id
        AND ool.order_line_nbr = odc.order_line_nbr
        AND ool.sched_line_nbr = odc.sched_line_nbr*/

WHERE
    odc.frst_rdd >= DATE '2020-01-01'

