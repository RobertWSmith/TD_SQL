SELECT
    DC.FISCAL_YR                     	/* The 4 digit year for this fiscal year. In this case it is used to avoid issues with sales document reused from the past.*/
    , DC.DELIV_DOC_ID                  	/* Delivery. The number that uniquely identifies the delivery.*/
    , DC.SRC_CRT_USR_ID                	/* Name of Person who Created the Object*/
    , DC.SRC_CRT_TS                    	/* Date and Time on which the record was created*/
    , DC.SALES_DISTR_CD                	/* Sales district. A geographical sales district or region.*/
    , DC.SHIP_RCVE_PT_CD               	/* Shipping point/receiving point. The physical location (for example,a warehouse or collection of loading ramps) from which you ship the item.*/
    , DC.SALES_ORG_CD                  	/* Sales organization. An organizational unit responsible for the sale of certain products or services. The responsibility of a sales organization may include legal liability for products and customer claims.*/
    , DC.DELIV_TYP_CD                  	/* Delivery type. A classification that distinguishes between different types of delivery.*/
    , DC.SNGL_DELIV_IND                	/* Complete delivery defined for each sales order? Indicates whether a sales order must be delivered completely in a single delivery or whether the order can be partially delivered and completed over a number of deliveries.*/
    , DC.CMBN_ORD_IND                  	/* Order combination indicator. Indicates whether you are allowed to combine orders during delivery processing.*/
    , DC.PLN_GOODS_MVT_DT              	/* Planned goods movement date. The date on which the goods must physically leave the shipping point to reach the customer on time.*/
    , DC.LD_DT                         	/* Load.date. The date by which picking and packing must be completed so that the goods are ready for loading and for the delivery to reach the customer on time. Any special packaging materials required for loading must also be available by this date.*/
    , DC.TRANSP_PLN_DT                 	/* Transportation planning date. The date by which you must arrange transportation so that the delivery can reach the customer on time.*/
    , DC.DELIV_DT                      	/* Delivery date. The date by which the delivery should be received by the customer.*/
    , DC.PICK_DT                       	/* Picking date. The date by which picking must begin for the delivery item to reach the customer on time.*/
    , DC.UNLD_PT_TXT                   	/* Unloading point. Specifies the point at which the material is to be unloaded (for example,ramp 1).*/
    , DC.INCOTERM_CD_1                 	/* Incoterms (part 1).Commonly-used trading terms that comply with the standards established by the International Chamber of Commerce (ICC).*/
    , DC.INCOTERM_CD_2                 	/* Incoterms (part 2). Additional information for the primary Incoterm.*/
    , DC.EXPT_IND                      	/* Export indicator. Indicates whether the delivery will be exported.*/
    , DC.ROUTE_CD                      	/* Route. Route by which the delivery item is to be delivered to the customer. You can use the route in a delivery to represent the following situations: One or more legs,Connection between point of departure and destination point,Target area*/
    , DC.BILL_BLK_CD                   	/* Billing block in SD document. Indicates if the entire sales document is blocked for billing.*/
    , DC.DELIV_BLK_CD                  	/* Delivery block (document header).Indicates if an entire sales document (a sales order,for example) is blocked for delivery.*/
    , DC.SD_DOC_CTGY_CD                	/* SD document category. A classification for the different types of documents that you can process in the sales and distribution system (for example: quotations,sales orders,deliveries,and invoices).*/
    , DC.CUST_FACL_CAL_CD              	/* Key that uniquely identifies the factory calendar that is valid for this plant.*/
    , DC.DELIV_PRTY_CD                 	/* Delivery priority. The delivery priority assigned to an item.*/
    , DC.SHIP_COND_CD                  	/* Shipping conditions. General shipping strategy for the delivery of goods from the vendor to the customer. Use You can define shipping conditions in your system which correspond to the requirements of your company. You can specify a shipping condition*/
    , DC.SHIP_TO_CUST_ID               	/* Ship To Customer Identifier.*/
    , DC.SOLD_TO_CUST_ID               	/* Sold To Customer Identifier.*/
    , DC.BILL_TO_CUST_ID               	/* Bill To Customer Identifier. Uniquely identify a customer.*/
    , DC.PAY_CUST_ID                   	/* Payor Customer Identifier. Uniquely identify a customer.*/
    , DC.CUST_GRP_CD                   	/* Customer group. Identifies a particular group of customers (for example,wholesale or retail) for the purpose of pricing or generating statistics.*/
    , DC.TOT_WT_QTY                    	/* Total weight. The total gross weight of all items in the delivery.*/
    , DC.TOT_NET_WT_QTY                	/* Net weight. The total net weight of all items in the delivery.*/
    , DC.WT_UOM_CD                     	/* Weight Unit Of Measure. Unit referring to the gross weight or net weight of the material.*/
    , DC.TOT_VOL_QTY                   	/* Volume. The total volume of all items in the delivery.*/
    , DC.VOL_UOM_CD                    	/* Volume unit. Unit referring to the volume of the material.*/
    , DC.DELIV_TM                      	/* Time of delivery. The time at which the item should arrive at the customer site. The time is proposed for the scheduled day of delivery.*/
    , DC.WT_GRP_CD                     	/* Weight group for delivery (To group).Specifies a group according to weight.*/
    , DC.TRANSP_GRP_CD                 	/* Transportation group. A grouping of materials that share the same route and transportation requirements.*/
    , DC.BILL_DT                       	/* Billing date for billing index and printout. The date on which the billing is processed and booked for accounting purposes.*/
    , DC.INVC_FACL_CAL_CD              	/* Key that uniquely identifies the factory calendar that is valid for this plant.*/
    , DC.PRC_COND_TYP_CD               	/* Procedure (pricing,output control,acct. det.,costing,...).Specifies the conditions that are allowed for a document and defines the sequence in which they are used.*/
    , DC.DOC_CRNCY_ID                  	/* SD document currency. The currency that applies to the document (for example,to a sales order or an invoice).*/
    , DC.LOC_CRNCY_ID                  	/* Local Currency Identifier. The currency that applies to the country/state.*/
    , DC.GRP_CRNCY_ID                  	/* Group Currency Identifier. Currency depending on the SBU (example: 'EUR' for SBU_ID = 1,'USD' for SBU_ID = 2,...).*/
    , DC.DOC_TO_LCL_EXCHG_RT           	/* Document to Local Exchange Rate. This would be the exchange rate to go from document currency to local currency (currency from the country/state).*/
    , DC.DOC_TO_GRP_EXCHG_RT           	/* Document to Group Exchange Rate. This would be the exchange rate to go from document currency to SBU group currency ('EUR' for SBU=1,'USD' for SBU=2,...).*/
    , DC.DOC_TO_GLBL_EXCHG_RT          	/* Document to Global Exchange Rate. Global would be the exchange rate to go from document currency to USD currency (target currency is always USD).*/
    , DC.SLS_OFFC_CD                   	/* Sales office. A physical location (for example,a branch office) that has responsibility for the sale of certain products or services within a given geographical area.*/
    , DC.SRC_UPD_USR_ID                	/* Name of person who changed object*/
    , DC.SRC_UPD_DT                    	/* Last changed on*/
    , DC.WHSE_ID                       	/* Warehouse Number / Warehouse Complex. Number that identifies a complex,physical warehouse structure within the Warehouse Management system.*/
    , DC.INTRCO_BILL_SALES_ORG_CD      	/* Sales organization for intercompany billing. Specifies the sales organization of the sales area to which the delivering plant is assigned.*/
    , DC.INTRCO_BILL_DISTR_CHAN_CD     	/* Distribution channel for intercompany billing. Specifies the distribution channel of the sales area to which the delivering plant is assigned.*/
    , DC.INTRCO_BILL_DIV_CD            	/* Division for intercompany billing. Specifies the division of the sales area to which the delivering plant is assigned.*/
    , DC.INTRCO_BILL_BILL_TYP_CD       	/* Billing type for intercompany billing. Specifies the billing type that the system automatically proposes when you create billing documents for inter-company billing.*/
    , DC.INTRCO_BILL_FACL_CAL_CD       	/* Key that uniquely identifies the factory calendar that is valid for this plant.*/
    , DC.INTRCO_BILL_BILL_DT           	/* Billing date for intercompany billing*/
    , DC.INTRCO_BILL_CUST_ID           	/* Customer number for intercompany billing. The number assigned to the master record which has been created to represent: An internal customer (sales organization) in intercompany billing. Your own sales organization in opportunity management*/
    , DC.CRED_CNTRL_AREA_CD            	/* Credit control area.The credit control area is an organizational entity which grants and monitors a credit limit for customers. A credit control area can include one or more company codes.You can also enter the credit control area separately for each post*/
    , DC.CRED_LIMIT_CUST_ID            	/* Customer's account number with credit limit reference. This field is needed if the credit limit is to be specified for a group of customers rather than for an individual customer. In this case,the credit limit is specified for one of the customers within*/
    , DC.CUST_CRED_GRP_ID              	/* Customer Credit Group. Freely definable grouping term.*/
    , DC.CRED_REP_GRP_ID               	/* Credit representative group for credit management. A customer can be allocated to a credit representative group for credit control. This credit representative group is copied into the order and can be used as a selection criterion for evaluations and rele*/
    , DC.CRED_MGMT_RISK_CTGY_ID        	/* Credit management: Risk category. A customer can be assigned to a credit risk category. The credit risk category controls all credit checks.*/
    , DC.BILL_LADING_ID                	/* Bill of lading. Identifies the number of the bill of lading with which the goods are to be transported.*/
    , DC.VEND_ID                       	/* Vendor's account number. Alphanumeric key uniquely identifying a vendor.*/
    , DC.PKG_MATL_TYP_CD               	/* Means of Transport Type. Key which specifies how the goods are transported. This key identifies the means of transport type. The means of transport type is a packaging material type in the category 'means of transport' or 'transport equipment'.*/
    , DC.CRED_MGMT_DOC_REL_DT          	/* Release date of the document determined by credit management. Specifies the date on which the sales order or delivery was released after being blocked for credit reasons.*/
    , DC.NXT_PLN_DELIV_DT              	/* Next date. In the sales order header,this field specifies the next planned delivery date. In the delivery header,the field specifies the next planned picking or goods issue date.*/
    , DC.ORIG_DOC_DT                   	/* Document date in document. The document date is the date on which the original document was issued.*/
    , DC.ACTL_GOODS_MVT_DT             	/* Actual goods movement date. You can preset the posting date for goods movement with the actual goods movement date. For example,if the posting should occur in a previous period or month,you can do so with this default.If the goods movement date is not f*/
    , DC.SHIP_BLK_REAS_CD              	/* Shipment Blocking Reason. Indicates the reason why the delivery is blocked for transportation planning.*/
    , DC.NET_VAL_DOC_AMT               	/* Net Value of the Sales Order in Document Currency.The total value of all items in the sales document,after any discounts and surcharges are taken into account. The value is expressed in the document currency.*/
    , DC.NET_VAL_GRP_AMT               	/* Net Value of the Sales Order in Group Currency.The total value of all items in the sales document,after any discounts and surcharges are taken into account. The value is expressed in the group currency.Derived.*/
    , DC.NET_VAL_GLBL_AMT              	/* Net Value of the Sales Order in Global Currency.The total value of all items in the sales document,after any discounts and surcharges are taken into account. The value is expressed in the Global currency.Derived.*/
    , DC.FACILITY_ID                   	/* Receiving plant for deliveries.Receiving plant (for customer number) for a delivery.How this field is filled and interpreted depends on the document category/delivery type. You can distinguish between the following cases:Delivery from stock transport orde*/
    , DC.PICK_TM                       	/* Picking time (local time,with reference to a plant).Date on which picking must begin in order for the delivery item to reach the customer in time.*/
    , DC.TRANSP_PLN_TM                 	/* Transportation planning -time (local w/ref. to shipping pnt)*/
    , DC.LOAD_TM                       	/* Loading time (local time with reference to a shipping point)*/
    , DC.GOODS_ISS_TM                  	/* Time of goods issue (local time,with reference to a plant)*/
    , DC.REF_DOC_ID                    	/* Reference document number. The reference document contains the document number of the business partner.*/
    , DC.INTRNTL_DELIV_DOC_ID          	/* Worldwide unique key for LIKP-VBELN*/
    , DC.DISTR_STA_CD                  	/* Distribution status (decentralized warehouse processing).This field displays the processing status of the delivery in terms of decentralized Warehouse Management System processing. This field cannot be changed manually. Instead,the system determines the*/
    , DC.SAP_TRANS_CD                  	/* Transaction code.A combination of alphabetical and numerical characters forming a code for a business task.*/
    , DC.SHIP_TYP_CD                   	/* Shipping type.Shipping type (for example,by road or rail) that has been selected for the transportation of the goods for the shipment legs.*/
    , DC.CUST_BRANCH_ID                	/* Customer Branch*/
    , DC.INDUS_CD_1                    	/* Industry code 1.Specifies the code that uniquely identifies the industry (or industries) of the customer.*/
    , DC.ASN_REL_TS                    	/* ASN (Advance Shipping Notice) Release Timestamp.*/
    , DC.RACK_WT_QTY                   	/* Rack Weight.*/
    , DC.DUNNAGE_WT_QTY                	/* Dunnage Weight.*/

FROM NA_BI_VWS.NAT_DELIV_DOC_CURR DC

WHERE
    dc.sd_doc_ctgy_cd = 'J'
    AND dc.fiscal_yr = '2014'
    --AND dc.intrco_bill_distr_chan_cd <> '81'
