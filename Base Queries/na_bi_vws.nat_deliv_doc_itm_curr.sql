SELECT
    DI.FISCAL_YR                     	/* The 4 digit year for this fiscal year. In this case it is used to avoid issues with sales document reused from the past.*/
    , DI.DELIV_DOC_ID                  	/* Delivery. The number that uniquely identifies the delivery.*/
    , DI.DELIV_DOC_ITM_ID              	/* Delivery item. The number that uniquely identifies the item in a delivery.*/
    , DI.ITM_CTGY_CD                   	/* Delivery item category. A classification that distinguishes between different types of delivery items (for example, return items and text items).*/
    , DI.SRC_CRT_USR_ID                	/* Name of Person who Created the Object*/
    , DI.SRC_CRT_TS                    	/* Entry time. The time of day at which the document was posted and stored in the system.*/
    , DI.MATL_ID                       	/* Alphanumeric key uniquely identifying the material.*/
    , DI.ORIG_REQ_MATL_ID              	/* Material entered. The number of the material for which you actually post goods issue.*/
    , DI.MATL_GRP_CD                   	/* Material group. Key that you use to group together several materials or services with the same attributes, and to assign them to a particular material group.*/
    , DI.FACILITY_ID                   	/* Key uniquely identifying a plant.*/
    , DI.STOR_LOC_CD                   	/* Storage location. Number of the storage location at which the material is stored. A plant may contain one or more storage locations.*/
    , DI.CUST_MATL_ID                  	/* Material belonging to the customer. The identifier that the customer uses to identify a particular material.*/
    , DI.MATL_HIER_ID                  	/* Product hierarchy. Alphanumeric character string for grouping together materials by combining different characteristics. It is used for analyses and price determination.*/
    , DI.ACTL_DELIV_QTY                	/* Actual quantity delivered (in sales units).The quantity of the item for delivery. The quantity is expressed in sales units.*/
    , DI.BASE_UOM_CD                   	/* Base unit of measure. Unit of measure in which stocks of the material are managed. The system converts all the quantities you enter in other units of measure (alternative units of measure) to the base unit of measure.*/
    , DI.SLS_UOM_CD                    	/* Sales unit. Unit of measure in which the material is sold.*/
    , DI.SKU_NUMER_CNVRSN_FCTR_QTY     	/* Numerator (factor) for conversion of sales quantity into SKU. Numerator of the conversion factor that the system uses to convert sales units base units of measure.*/
    , DI.SKU_DENOM_CNVRSN_FCTR_QTY     	/* Denominator (divisor) for conversion of sales qty. into SKU. Denominator of the conversion factor that the system uses to convert sales units base units of measure.*/
    , DI.TOT_NET_WT_QTY                	/* Net weight. The total net weight of all items in the delivery.*/
    , DI.TOT_GROSS_WT_QTY              	/* Gross weight. The total gross weight of all items in the delivery. The gross weight represents the net weight plus the weight of packaging.*/
    , DI.WT_UOM_CD                     	/* Weight Unit. Unit referring to the gross weight and/or net weight of the material.*/
    , DI.TOT_VOL_QTY                   	/* Volume. The total volume of all items in the delivery.*/
    , DI.VOL_UOM_CD                    	/* Volume unit. Unit referring to the volume of the material.*/
    , DI.PRTL_DELIV_ICD                	/* Partial delivery at item level. Specifies whether the customer requires full or partial delivery for the item.*/
    , DI.UNLMT_OVER_DELIV_ALLOW_IND    	/* Indicator: Unlimited overdelivery allowed Indicator that specifies whether unlimited overdelivery can be accepted for the item.*/
    , DI.OVR_DELIV_LMT_PCT             	/* Overdelivery tolerance limit. Percentage (based on the order quantity) up to which an overdelivery of this item will be accepted.*/
    , DI.UNDER_DELIV_LMT_PCT           	/* Underdelivery tolerance limit. Percentage (based on the order quantity) up to which an underdelivery of this item will be accepted.*/
    , DI.BILL_BLK_CD                   	/* Block. Indicates if the item is blocked for billing.*/
    , DI.MATL_AVAIL_DT                 	/* Material availability date. The date by which sufficient quantities of the item must be available for picking to begin.*/
    , DI.SLS_DOC_ID                    	/* Sales Document. The number that uniquely identifies the sales document.*/
    , DI.SLS_DOC_ITM_ID                	/* Sales document item. The number that uniquely identifies the item in the sales document.*/
    , DI.SKU_ACTL_DELIV_QTY            	/* Actual quantity delivered in stock keeping units. The item quantity, expressed in base units of measure.*/
    , DI.ITM_RLVNT_BILL_ICD            	/* Relevant for billing. Indicates what the basis for billing should be.*/
    , DI.LD_GRP_CD                     	/* Loading group. A grouping of materials that share the same loading requirements.*/
    , DI.TRANSP_GRP_CD                 	/* Transportation group. A grouping of materials that share the same route and transportation requirements.*/
    , DI.PICK_CNTRL_ICD                	/* Indicator for picking control*/
    , DI.WHSE_ID                       	/* Warehouse Number / Warehouse Complex. Number that identifies a complex, physical warehouse structure within the Warehouse Management system.*/
    , DI.STOR_TYP_CD                   	/* Storage Type. The storage type is a subdivision of a complex, physical warehouse. Different storage types are identified by their warehousing technique, form of organization, or their function.*/
    , DI.STOR_BIN_CD                   	/* Storage bin. The storage bin (sometimes referred to as a "slot") is the smallest addressable unit in a warehouse. It identifies the exact location in the warehouse where goods can be stored.A storage bin can be further sub-divided into bin sections. Sever*/
    , DI.MVT_TYP_CD                    	/* Movement type (inventory management).Specifies a key for the type of goods movement. Each goods movement (for example, purchase order to warehouse) is allocated to a movement type in the system.*/
    , DI.RQT_TYP_CD                    	/* Requirement type. Determines the way in which the SAP system handles requirements planning. You can use the requirement type to control, for example, lot sizing, inventory management, and storage costs. When you create a sales order, for example, you can*/
    , DI.RQT_PLN_TYP_CD                	/* Requirement Planning type. Determines the way in which the SAP system handles requirements planning. You can use the planning type to control, for example, lot sizing, inventory management, and storage costs. When you create a sales order, for example, yo*/
    , DI.ITM_TYP_CD                    	/* Item type. A way of classifying items that require different kinds of processing by the SAP system.*/
    , DI.VAL_TYP_CD                    	/* Valuation type. Uniquely identifies separately valuated stocks of a material.*/
    , DI.AVAIL_CHK_GRP_CD              	/* Checking group for availability check. This field has two uses: 1. Specifies whether and how the system checks availability and generates requirements for materials planning. 2. In Flexible Planning, defines - together with the checking rule - the differe*/
    , DI.BUS_AREA_CD                   	/* Business Area. Key identifying a business area.*/
    , DI.SLS_OFFC_CD                   	/* Sales office. A physical location (for example, a branch office) that has responsibility for the sale of certain products or services within a given geographical area.*/
    , DI.SLS_GRP_CD                    	/* Sales group. A group of sales people who are responsible for processing sales of certain products or services.*/
    , DI.DISTR_CHAN_CD                 	/* The way in which products or services reach the customer. Typical examples of distribution channels are wholesale, retail, or direct sales.*/
    , DI.DIV_CD                        	/* A way of grouping materials, products, or services. The system uses divisions to determine the sales areas and the business areas for a material, product, or service.*/
    , DI.DELIV_GRP_CD                  	/* Delivery group (items are delivered together). A combination of items that should be delivered together.*/
    , DI.SPCL_STK_TYP_CD               	/* Special stock indicator. Specifies the special stock type.*/
    , DI.SRC_UPD_DT                    	/* Last changed on*/
    , DI.CUST_GRP_ID_1                 	/* Customer group 1. Specifies a customer-defined group of customers.*/
    , DI.CUST_GRP_ID_2                 	/* Customer group 2. Specifies a customer-defined group of customers.*/
    , DI.CUST_GRP_ID_3                 	/* Customer group 3. Specifies a customer-defined group of customers.*/
    , DI.CUST_GRP_ID_4                 	/* Customer group 4. Specifies a customer-defined group of customers.*/
    , DI.CUST_GRP_ID_5                 	/* Customer group 5. Specifies a customer-defined group of customers.*/
    , DI.MATL_GRP_CD_1                 	/* Material group 1.You can use material groups when maintaining a material master record. Since these material groups are not used in the standard SAP R/3 System, you can use them as required, for example, for analyses.*/
    , DI.MATL_GRP_CD_2                 	/* Material group 2.You can use material groups when maintaining a material master record. Since these material groups are not used in the standard SAP R/3 System, you can use them as required, for example, for analyses.*/
    , DI.MATL_GRP_CD_3                 	/* Material group 3.You can use material groups when maintaining a material master record. Since these material groups are not used in the standard SAP R/3 System, you can use them as required, for example, for analyses.*/
    , DI.MATL_GRP_CD_4                 	/* Material group 4.You can use material groups when maintaining a material master record. Since these material groups are not used in the standard SAP R/3 System, you can use them as required, for example, for analyses.*/
    , DI.MATL_GRP_CD_5                 	/* Material group 5.You can use material groups when maintaining a material master record. Since these material groups are not used in the standard SAP R/3 System, you can use them as required, for example, for analyses.*/
    , DI.ALLOC_ICD                     	/* Allocation indicator. Controls the consumption of customer requirements with planned independent requirements whereby the customer requirements type is only allocated one consumption strategy.*/
    , DI.SD_DOC_CTGY_CD                	/* Sales and Distribution document category. A classification for the different types of documents that you can process in the sales and distribution system (for example: quotations, sales orders, deliveries, and invoices).*/
    , DI.COST_CNTR_CD                  	/* Cost Center. Key uniquely identifying a cost center.*/
    , DI.CNTRL_AREA_CD                 	/* Controlling Area. Uniquely identifies a controlling area.The controlling area is the highest organizational unit in Controlling.*/
    , DI.PROFT_CNTR_ID                 	/* Profit center. Key that uniquely identifies the profit center in the current controlling area.*/
    , DI.ORD_ID                        	/* Order Number. Number which identifies an order within a client.*/
    , DI.RQT_CLS_CD                    	/* Requirements class. Key which specifies the planning strategy internally within the system. One or more requirements types can be allocated to the requirements class. Planning strategies and requirements are linked via the requirements type.*/
    , DI.CRED_MGMT_FUNCT_ACTV_IND      	/* ID: Item with active credit function / relevant for credit. Indicates whether the credit management functions (credit checks and updating statistics) are active for the order, delivery, or invoice items.*/
    , DI.MATL_USE_ICD                  	/* Usage indicator. Defines how the material is used.*/
    , DI.RET_IND                       	/* Returns item. This item is a returns item if the field is selected.*/
    , DI.NET_PRC_DOC_AMT               	/* Net price. The net price that results from the net value divided by the order quantity.*/
    , DI.NET_PRC_GRP_AMT               	/* Net price. The net price that results from the net value divided by the order quantity. (Group Currency).Derived.*/
    , DI.NET_PRC_GLBL_AMT              	/* Net price. The net price that results from the net value divided by the order quantity. (Global Currency).Derived.*/
    , DI.NET_VAL_DOC_AMT               	/* Net value in document currency. Net value of the document item.*/
    , DI.NET_VAL_GRP_AMT               	/* Net value in document currency. Net value of the document item. (Group Currency).Derived.*/
    , DI.NET_VAL_GLBL_AMT              	/* Net value in document currency. Net value of the document item. (Global Currency).Derived.*/
    , DI.MVT_ICD                       	/* Movement indicator. Specifies the type of document (such as purchase order or delivery note) that constitutes the basis for the movement.*/
    , DI.VAL_CONTRACT_ID               	/* Value contract no. Number of value contract, to which this document is assigned.*/
    , DI.VAL_CONTRACT_ITM_ID           	/* Value contract item. Item number of value contract item assigned to this document. The document number of the value contract is in the 'WKTNR' field.*/
    , DI.KANBAN_SEQ_ID                 	/* KANBAN/sequence number*/
    , DI.SPCL_STK_VAL_ICD              	/* Indicator: valuation of special stock. Determines whether sales order stock or project stock is managed on a valuated or nonvaluated basis.*/
    , DI.INTRNTL_DELIV_DOC_ID          	/* Worldwide unique key for LIPS-VBELN & LIPS_POSNR*/
    , DI.REF_DOC_ID                    	/* Document number of a reference document. Number that uniquely identifies a reference document.*/
    , DI.REF_DOC_ITM_ID                	/* Item of a reference document. Indicates the number of the reference document item.*/
    , DI.DELIV_CTGY_CD                 	/* Delivery category. Goods movements (movement types) are assigned to delivery categories here.*/
    , DI.VAL_CLS_ID                    	/* Valuation class. Default value for the valuation class for valuated stocks of this material.*/
    , DI.NON_MATCH_DELIV_DT_ICD        	/* Non Matching Delivery Date Indicator Code : Non matching request delivery date compared to fixed delivery date*/
    , DI.SLSMN_ID                      	/* Salesman Identifier.*/
    , DI.SLSMN_HIER_LVL_1_ID           	/* Salesman Hierarchy Level 1 Identifier.*/
    , DI.SLSMN_HIER_LVL_2_ID           	/* Salesman Hierarchy Level 2 Identifier.*/
    , DI.SLSMN_HIER_LVL_3_ID           	/* Salesman Hierarchy Level 3 Identifier.*/
    , DI.BATCH_NBR                     	/* Identifies batch number. A specific batch number is assigned to material that is manufactured in batches or production lots.*/

FROM NA_BI_VWS.NAT_DELIV_DOC_ITM_CURR DI
