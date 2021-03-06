SELECT
/*    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR,*/
    DDC.ORDER_ID,
    DDC.ORDER_LINE_NBR,
    DDC.BILL_LADING_ID,
    DDC.DELIV_DT

FROM NA_BI_VWS.DELIVERY_DETAIL_CURR DDC

WHERE
    DDC.BILL_LADING_ID = '9405026295'
    OR DDC.BILL_LADING_ID = '9405025862'
    OR DDC.BILL_LADING_ID = '9405025633'
    OR DDC.BILL_LADING_ID = '9405025244'
    OR DDC.BILL_LADING_ID = '9405024896'
    OR DDC.BILL_LADING_ID = '9405024697'
    OR DDC.BILL_LADING_ID = '9405023493'
    OR DDC.BILL_LADING_ID = '7821003860'
    OR DDC.BILL_LADING_ID = '7821002270'
    OR DDC.BILL_LADING_ID = '7821001954'
    OR DDC.BILL_LADING_ID = '7821001924'
    OR DDC.BILL_LADING_ID = '7821001732'
    OR DDC.BILL_LADING_ID = '7821001640'
    OR DDC.BILL_LADING_ID = '7821001548'
    OR DDC.BILL_LADING_ID = '7821001397'
    OR DDC.BILL_LADING_ID = '7821001283'
    OR DDC.BILL_LADING_ID = '7821001122'
    OR DDC.BILL_LADING_ID = '7821000906'
    OR DDC.BILL_LADING_ID = '7821000787'
    OR DDC.BILL_LADING_ID = '7821000502'
    OR DDC.BILL_LADING_ID = '7821000221'
    OR DDC.BILL_LADING_ID = '3208022772'
    OR DDC.BILL_LADING_ID = '3208019313'
    OR DDC.BILL_LADING_ID = '1308010490'
    OR DDC.BILL_LADING_ID = '1308008210'

GROUP BY
/*    DDC.DELIV_ID,
    DDC.DELIV_LINE_NBR,*/
    DDC.ORDER_ID,
    DDC.ORDER_LINE_NBR,
    DDC.BILL_LADING_ID,
    DDC.DELIV_DT

ORDER BY
    DDC.BILL_LADING_ID,
    DDC.DELIV_DT