/**
 * @Author : Kandisa Technologies
 * @description : This class is used for Invoice Generation.
 * @created on        : 2023
 * @last modified on  : 16-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 8/10 by Twinkle
 */ 
public with sharing class InvoiceController {
     /**__
     * @description Get account with opportunity
     * @param oppId Opportunity Id
     * @return opportunity account id
     */
    @AuraEnabled
    public static String getAccountWithOpp(Id oppId) {
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppId WITH USER_MODE LIMIT 1];
        return opp.AccountId;
    }
    /**__
     * @description Inserts a product into QuickBooks and updates corresponding Salesforce records.
     *
     * @param lineItemData JSON string containing information about the product.
     *                    Should be in the format expected by the OppproductWrapper class.
     * @return String indicating the result of the operation ('success' or an error message).
     */
    @AuraEnabled
    public static String insertProductOnQb(String lineItemData) {
        try {
            Map<String, String> oppProdMap = new Map<String, String>();
            OppproductWrapper oppProducts = (OppproductWrapper)JSON.deserialize(lineItemData, OppproductWrapper.class);
    
            String productName = (oppProducts.productName == '') ? 'test' : oppProducts.productName;
            string itemsJSON = InvoiceControllerHelper.buildItemsJSON(oppProducts, productName);
            CalloutUtlityController.CalloutCredentials cred = CalloutUtlityController.calloutToCreateUpdateItemInQb(new OpportunityLineItem(), itemsJSON);
    
            if (String.isNotBlank(cred.responseBody.getBody()) && String.valueOf(cred.responseBody.getStatusCode()) == '200') {
                SingleProductWrapper wrapProduct = (SingleProductWrapper)JSON.deserialize(cred.responseBody.getBody(), SingleProductWrapper.class);
                oppProdMap.put(oppProducts.productId, wrapProduct.item.id);
    
                if (oppProdMap.size() > 0) {
                    return InvoiceControllerHelper.updateProductRecords(oppProdMap,cred);
                }
            } else if (cred.responseBody.getStatus() == 'Unauthorized') {
                return 'Check Quickbook Connection to Salesforce';
            } else {
                CalloutUtlityController.createQBLog(cred, '');
    
                if (CalloutUtlityController.qbLogs.size() > 0) {
                    insert as user CalloutUtlityController.qbLogs;
                }
    
                ProductFaultQueryResponseMain wrapProduct1 = (ProductFaultQueryResponseMain)JSON.deserialize(cred.responseBody.getBody(), ProductFaultQueryResponseMain.class);
                return wrapProduct1.fault.error[0].Detail;
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return 'Something Went Wrong';
    }
    /**
     * @description Checks if the specified currency is present in QuickBooks.
     *
     * @param sFCurrencyCode Salesforce currency code to be checked.
     * @return 'success' if the currency is present in QuickBooks, an empty string otherwise.
     */
    @AuraEnabled
    public static string checkCurrencyIsPresentInQB(string sFCurrencyCode){
        if(sFCurrencyCode != '' || sFCurrencyCode != NULL){
            list<KTQB__QB_MetaData__c> metaData = [select id, KTQB__QB_Id__c from KTQB__QB_MetaData__c where KTQB__Currency_Code__c = :sFCurrencyCode and KTQB__Type__c ='companycurrency'  WITH USER_MODE limit 1];
            if(metaData.size() > 0) {return 'success';}
        }
        return '';
    }
    
    /**
     * @description Retrieves a list of Opportunity Line Items for the specified Opportunity Id.
     *
     * @param oppId Id of the Opportunity for which to retrieve the line items.
     * @return List of OpportunityLineItem objects associated with the specified Opportunity Id.
     */
    @AuraEnabled
    public static list<OpportunityLineItem> getProductList(string oppId){
        list<OpportunityLineItem> oli = [select id, Name, ProductCode ,OpportunityId,Description,Quantity,UnitPrice,TotalPrice,Product2.name, Product2.Id, Product2.KTQB__Item_QB_Id__c from OpportunityLineItem where OpportunityId = :oppId WITH USER_MODE];
        return oli;
    }
    /**
     * @description Retrieves an Account object with the specified Account Id.
     *
     * @param accid The ID of the Account to retrieve.
     * @return The Account object with the specified Id, or null if no matching Account is found.
     */
    @AuraEnabled
    public static account getAccountWithId(string accid){
        Account accList = [SELECT id, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,ShippingCity, ShippingCountry,
                           ShippingPostalCode, ShippingState, ShippingStreet 
                           FROM Account 
                           WHERE id = :accid WITH USER_MODE  limit 1];
    	return accList;
    }
    /**
     * @description Checks if the configured Invoice object has a parent Account relationship of the specified type.
     *
     * @param type Relationship type to be checked.
     * @return True if the Invoice object has a parent Account relationship of the specified type, false otherwise.
     */
    @AuraEnabled
    public static boolean checkInvoiceObjectHasParentAccount(string type){
        KTQB__InvoiceConfigurationOptions__c config = [SELECT Id, Name, KTQB__Create_Update_Qb_Payment_In_Sf__c, SetupOwnerId, KTQB__Invoice_Save__c, KTQB__Invoice_Save_and_Send__c, KTQB__Invoice_Date__c, KTQB__Invoice_Due_Date__c, 
                                                             KTQB__Income_Account__c, KTQB__Terms__c, KTQB__Tax__c, KTQB__LineItem_Object_Name__c, KTQB__Invoice_Customer_ChildObject_Api_Name__c, KTQB__Invoice_Object_Name__c, KTQB__Payment_Object_Name__c 
                                                             FROM KTQB__InvoiceConfigurationOptions__c 
                                                             WHERE SetupOwnerId = :UserInfo.getOrganizationId() WITH USER_MODE];
        if(config.KTQB__Invoice_Object_Name__c != '' || config.KTQB__Invoice_Object_Name__c != null){
            String result = InvoiceControllerHelper.getAccountApiNameForObject(config.KTQB__Invoice_Object_Name__c, type);
            if(result != '' && result != null){
                return true;
            }
        }
        return false;
    }

    /**
     * @description Sends an email for the specified QuickBooks Invoice.
     *
     * @param invoiceId Id of the QuickBooks Invoice for which to send the email.
     * @return 'success' if the email is sent successfully, 'Check Quickbook Connection to Salesforce' if unauthorized,
     *         'Something went wrong' for other errors, and 'Something Went Wrong' if an exception occurs.
     */
    @AuraEnabled
    public static string sendInvoiceEmail(string invoiceId){
        try{
            CalloutUtlityController.CalloutCredentials credSendEmail = new CalloutUtlityController.CalloutCredentials();
            string endstring ='invoice/'+invoiceId+'/send?';
            credSendEmail = CalloutUtlityController.calloutHelperMethod('POST', endstring,'EmailSent', new KTQB__QB_Invoice__c());
            CalloutUtlityController.createQBLog(credSendEmail,'');
            if(CalloutUtlityController.qbLogs.size() > 0){
                insert as user CalloutUtlityController.qbLogs;}
            if(String.isNotBlank(credSendEmail.responseBody.getBody()) &&  String.valueOf(credSendEmail.responsebody.getStatusCode()) == '200'){
                return 'success';
            }if(credSendEmail.responsebody.getStatus() == 'Unauthorized'){
                return 'Check Quickbook Connection to Salesforce';
            }else{
                return 'Something went wrong';
            }
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return 'Something Went Wrong';
    }
    /**
     * @description Generates an invoice in QuickBooks based on the provided details.
     *
     * @param contactDetails Details about the contact.
     * @param lineItemData Data about line items.
     * @param invoiceCustomeData Custom data for the invoice.
     * @return A string indicating the result of the invoice generation.
     *         Possible values: 'success = <InvoiceId>' if successful, 'Check Quickbook Connection to Salesforce' if unauthorized,
     *         an error message if there is an issue, and 'Something Went Wrong' if an exception occurs.
     */
    @AuraEnabled
    public static string generateInvoice(string contactDetails, string lineItemData, string invoiceCustomeData){
         string response = 'Something went wrong';
         string invoiceRecordId='';
         string invoiceQBId='';
         double synToken = 0.0;
        try{
           
            product2 product = new product2();
            CustomerConfigWrapper conDetails = (CustomerConfigWrapper)JSON.deserialize(contactDetails,CustomerConfigWrapper.class);
            invoiceCustomeData invCustomeData = (invoiceCustomeData)JSON.deserialize(invoiceCustomeData,InvoiceCustomeData.class);

            List<QBProductController.OppproductWrapper> oppProducts = (list<QBProductController.OppproductWrapper>)JSON.deserialize(lineItemData,list<QBProductController.OppproductWrapper>.class);
            string itemsJSON = '';
            itemsJSON = InvoiceControllerHelper.buildLineItemsJSON(invCustomeData,oppProducts,conDetails);
            CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
            cred = CalloutUtlityController.calloutHelperMethod('POST', 'invoice?',itemsJSON,product);
            CalloutUtlityController.createQBLog(cred,'');
            if(CalloutUtlityController.qbLogs.size() > 0){
                	insert as user CalloutUtlityController.qbLogs;}
            if(String.isNotBlank(cred.responseBody.getBody()) &&  String.valueOf(cred.responsebody.getStatusCode()) == '200'){
                SingleInvoiceWrapper wrapInvoice = new SingleInvoiceWrapper();
                wrapInvoice = (SingleInvoiceWrapper) JSON.deserialize(cred.responseBody.getBody(), SingleInvoiceWrapper.class);
                synToken = wrapInvoice.invoice.syncToken;
				invoiceQBId = wrapInvoice.invoice.Id;
                KTQB__InvoiceConfigurationOptions__c config = [ SELECT KTQB__Invoice_Customer_ChildObject_Api_Name__c,KTQB__LineItem_ChildObject_Name__c,
                                                         KTQB__LineItem_Object_Name__c,KTQB__Invoice_Object_Name__c FROM KTQB__InvoiceConfigurationOptions__c 
                                                     WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
                Map<String, SObject> dataMap = InvoiceControllerHelper.getConfigurationFieldMap('KTQB__Invoice_Object_Field_Mapping__c');
                if(config.KTQB__Invoice_Object_Name__c != null && dataMap.size() > 0 && wrapInvoice != null){
                	SObject invoiceRecord = InvoiceControllerHelper.prepareInvoiceRecord(dataMap,wrapInvoice,invCustomeData);
                    if(Utils.getIsMultiCurrencyOrg()){
                         invoiceRecord.put('CurrencyIsoCode', conDetails.PersonalInfo.currencyCode);
                    }
                   
                    string billAddress = '';
                    string shipAddress = '';
  					if(wrapInvoice.invoice.billAddr != null && (String)dataMap.get('Billing Address').get('KTQB__Field_API_Name__c') != null){
                        billAddress = InvoiceControllerHelper.getInvoiceBillAddress(wrapInvoice);
                        invoiceRecord.put((String)dataMap.get('Billing Address').get('KTQB__Field_API_Name__c'),billAddress.replaceAll('null',''));
                    }
                    if(conDetails.PersonalInfo.currencyCode != null && (String)dataMap.get('Currency Reference').get('KTQB__Field_API_Name__c') != null){
                        invoiceRecord.put((String)dataMap.get('Currency Reference').get('KTQB__Field_API_Name__c'),conDetails.PersonalInfo.currencyCode);
                    }
                    if(wrapInvoice.invoice.shipAddr != null && (String)dataMap.get('Shipping Address').get('KTQB__Field_API_Name__c') != null){
                        shipAddress = InvoiceControllerHelper.getInvoiceShipAddress(wrapInvoice);
                   		invoiceRecord.put((String)dataMap.get('Shipping Address').get('KTQB__Field_API_Name__c'),shipAddress.replaceAll('null',''));
                    }
                    if ((String)dataMap.get('QB Customer').get('KTQB__Field_API_Name__c') != null) {
    					invoiceRecord.put((String)dataMap.get('QB Customer').get('KTQB__Field_API_Name__c'), conDetails.id);}
					Boolean isNotEmpty = false;
                    for (SObjectField field : invoiceRecord.getSObjectType().getDescribe().fields.getMap().values()) {
                        if (invoiceRecord.isSet(field)) {
                            isNotEmpty = true;
                            break;
                        }
                    }
                    if(invCustomeData.getAccid != '' && invCustomeData.getAccid != null){
                        string result = InvoiceControllerHelper.getAccountApiNameForObject(config.KTQB__Invoice_Object_Name__c,'Account');
                        if(result !='' && result != null){invoiceRecord.put(result,invCustomeData.getAccid);}
                    }
                    if(invCustomeData.getOppid != '' && invCustomeData.getOppid != null){
                        string result = InvoiceControllerHelper.getAccountApiNameForObject(config.KTQB__Invoice_Object_Name__c,'Opportunity');
                        if(result !='' && result != null){invoiceRecord.put(result,invCustomeData.getOppid);}
                    }
                    if (isNotEmpty) { 
                        List<SObject> invoiceRecords = new List<SObject>();
						invoiceRecords.add(invoiceRecord);
                        
                        invoiceRecordId = invoiceRecord.Id;
                        List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{config.KTQB__Invoice_Object_Name__c});
                        Schema.DescribeSObjectResult describeResult = describeResults[0]; 
                        //if (Schema.getGlobalDescribe().get(config.KTQB__Invoice_Object_Name__c).getDescribe().isCreateable()) {
                        if (describeResult.isCreateable()) {
                           insert as user invoiceRecord;
                           invoiceRecordId = invoiceRecord.Id;
                        }              

                        if(config.KTQB__LineItem_Object_Name__c != null && wrapInvoice.invoice.line.size()>0){
                            Map<String, SObject> lineItemMap = InvoiceControllerHelper.getConfigurationFieldMap('KTQB__LineItem_Object_Field_Mapping__c');
                            if(lineItemMap.size() > 0){
                                List<SObject> lineItemList = new List<SObject>();
                                for(Integer i=0;i<oppProducts.size();i++){
                                    //SObject lineItemRecord = Schema.getGlobalDescribe().get(config.KTQB__LineItem_Object_Name__c).newSObject();
                                    List<Schema.DescribeSObjectResult> describeResults1 = Schema.describeSObjects(new String[]{config.KTQB__LineItem_Object_Name__c});
                                    Schema.DescribeSObjectResult describeResult1 = describeResults1[0]; 
                                    SObject lineItemRecord = describeResult1.getSObjectType().newSObject(); 
                                    
                                    if ((String)lineItemMap.get('Name').get('KTQB__Field_API_Name__c') != null) {
    								lineItemRecord.put((String)lineItemMap.get('Name').get('KTQB__Field_API_Name__c'), 'LineItem-'+(i+1)+' | '+'Invoice #' + wrapInvoice.invoice.docNumber);}
                                    if ((String)lineItemMap.get('Description').get('KTQB__Field_API_Name__c') != null) {
    								lineItemRecord.put((String)lineItemMap.get('Description').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.line[i].description);}
                                    if(Utils.getIsMultiCurrencyOrg()){
                                        lineItemRecord.put('CurrencyIsoCode', conDetails.PersonalInfo.currencyCode);
                                    }
                                    if ((String)lineItemMap.get('Line Item Id').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Line Item Id').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.Id +'#'+wrapInvoice.invoice.line[i].id);}
                                    if(wrapInvoice.invoice.line[i].SalesItemLineDetail != null){
                                        if ((String)lineItemMap.get('Unit Price').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Unit Price').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.line[i].SalesItemLineDetail.unitPrice);}
                                        if ((String)lineItemMap.get('Quantity').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Quantity').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.line[i].SalesItemLineDetail.qty);}
                                        if ((String)lineItemMap.get('Taxable').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Taxable').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.line[i].SalesItemLineDetail.taxCodeRef.value);}
                                        /*if ((String)lineItemMap.get('Line Item Id').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Line Item Id').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.Id +'#'+wrapInvoice.invoice.line[i].SalesItemLineDetail.itemRef.value);}*/
                                        if ((String)lineItemMap.get('Product/Service Ref Name').get('KTQB__Field_API_Name__c') != null) {
    									lineItemRecord.put((String)lineItemMap.get('Product/Service Ref Name').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.line[i].SalesItemLineDetail.itemRef.name);}
                                    	
                                    }
                                    Boolean isEmpty = false;
                                    for (SObjectField field : lineItemRecord.getSObjectType().getDescribe().fields.getMap().values()) {
                                         if (lineItemRecord.isSet(field)) {
                                             isEmpty = true;
                                        	 break;
                                         }
                                    }
                                    if (isEmpty && config.KTQB__LineItem_ChildObject_Name__c != null) {
                                        lineItemRecord.put(config.KTQB__LineItem_ChildObject_Name__c, invoiceRecord.id);
                                    	lineItemList.add(lineItemRecord);
                                    }
                                }
                                if(lineItemList.size() > 0){ 
                                    insert as user lineItemList;
                                }
                            }
                        }
                    }
                    
                }
               
                response = 'success=true&invoiceId=' + wrapInvoice.invoice.Id + '&recordId=' + invoiceRecordId;
                //return 'success = '+wrapInvoice.invoice.Id;
                
            }if(cred.responsebody.getStatus() == 'Unauthorized'){
                response = 'Check Quickbook Connection to Salesforce';
            }
            else if(String.valueOf(cred.responsebody.getStatusCode()) != '200'){
                InvoiceFaultWrapper wrapInvoiceErrWrp = (InvoiceFaultWrapper) JSON.deserialize(cred.responsebody.getBody(), InvoiceFaultWrapper.class);
                response = wrapInvoiceErrWrp.fault.error[0].Detail;
            } 
            if(invoiceQBId != '' && invoiceRecordId == ''){
                response = 'createInQb';
            }
        }catch(exception e){
            response = 'success=fail in SF&errorMessage=' + e.getMessage() +  '&invoiceQBID='+ invoiceQBId +'&invoiceSyncToken=' +String.valueOf(synToken.intValue());
            HandleCustomException.logException(e);
        }
        return response;
    }
    /**
     * @description Retrieves a list of customer details based on the provided Account Id.
     * @return A list of CustomerConfigWrapper objects containing customer details.
     *         Each CustomerConfigWrapper object represents a customer and includes various fields such as
     *         givenName, fax, mobile, shipping details, billing details, email, and more.
     *         The list is empty if no customer details are found or an exception occurs.
     */
    @AuraEnabled
    public static list<CustomerConfigWrapper> getCustomerList(){
        list<CustomerConfigWrapper> lstCustomerWrapper = new list<CustomerConfigWrapper>();
        try{
            KTQB__InvoiceConfigurationOptions__c config = [ SELECT KTQB__Invoice_Customer_ChildObject_Api_Name__c FROM KTQB__InvoiceConfigurationOptions__c 
                                                      WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            list<KTQB__Invoice_Object_Field_Mapping__c> invoiceField = [SELECT Id,Name,KTQB__Field_Value__c,KTQB__Field_API_Name__c from Invoice_Object_Field_Mapping__c 
                                                                  WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            list<KTQB__Customer_Object_Field_Mapping__c> customerField = [SELECT Id,Name,KTQB__Field_Value__c,KTQB__Field_API_Name__c from Customer_Object_Field_Mapping__c 
                                                                    WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            Map<String, KTQB__Invoice_Object_Field_Mapping__c> dataMap = InvoiceControllerHelper.createFieldMappingMap(invoiceField);
            Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap = InvoiceControllerHelper.createFieldMappingMap(customerField);
            
            if(InvoiceControllerHelper.isValidConfiguration(dataMap, config, customerMap)) {
                String customerQBIdFieldAPIName = customerMap.get('QB Customer Id').KTQB__Field_API_Name__c;
                String displayNameFieldAPIName = customerMap.get('Display Name').KTQB__Field_API_Name__c;
                //Set<String> customerObjectFields = Schema.getGlobalDescribe().get(config.KTQB__Invoice_Customer_ChildObject_Api_Name__c).getDescribe().fields.getMap().keySet();
                List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(
                    new List<String>{config.KTQB__Invoice_Customer_ChildObject_Api_Name__c}
                );
                Set<String> customerObjectFields = describeResults[0].fields.getMap().keySet();
                List<String> fieldChecks =  InvoiceControllerHelper.getFieldChecks(customerMap);
                if(!fieldChecks.isEmpty()) {
                    String query = 'SELECT ' + String.join(new List<String>(customerObjectFields), ',') +
                        ' FROM ' + config.KTQB__Invoice_Customer_ChildObject_Api_Name__c +
                        ' WHERE ' + customerQBIdFieldAPIName + ' != null AND (' + String.join(fieldChecks, ' OR ') + ') ORDER BY ' + displayNameFieldAPIName;
                    for(sObject so : Database.query(String.escapeSingleQuotes(query),AccessLevel.USER_MODE)){
                        CustomerConfigWrapper custWrap = InvoiceControllerHelper.createCustomerWrapper(so, customerMap);
                        lstCustomerWrapper.add(custWrap);
                    }
                }
            }
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return lstCustomerWrapper;
    }
	
    /**
     * @description Checking blank.
     * @param fieldValue The CalloutCredentials for making the callout.
     * @return Boolean
     */
    @TestVisible private static Boolean isNotBlank(Object fieldValue) {
        return fieldValue != null && String.valueOf(fieldValue).trim() != '';
    }
    /**
     * @description Inserts a customer record into Salesforce based on QuickBooks customer data.
     *
     * @param cred               The CalloutCredentials for making the callout.
     * @param responseMap        The response map containing QuickBooks customer data.
     * @param customerData       The CustomerConfigWrapper object containing customer information.
     * @return                   A success message or the QuickBooks customer ID.
     */
    public static String insertCustomerInSF(CalloutUtlityController.CalloutCredentials cred,Map<String, Object> responseMap,CustomerConfigWrapper customerData) {
        string response = '';
        KTQB__InvoiceConfigurationOptions__c config = [ SELECT KTQB__Invoice_Customer_ChildObject_Api_Name__c FROM KTQB__InvoiceConfigurationOptions__c 
                                                        WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            Map<String, SObject> dataMap  =  InvoiceControllerHelper.getConfigurationFieldMap('KTQB__Invoice_Object_Field_Mapping__c');
            Map<String, SObject> customerMap = InvoiceControllerHelper.getConfigurationFieldMap('KTQB__Customer_Object_Field_Mapping__c');
            Map<String, Object> customerResponseMap = (Map<String, Object>) responseMap.get('Customer');
        try{
            if (dataMap.size() > 0 && config.KTQB__Invoice_Customer_ChildObject_Api_Name__c != null && (String)dataMap.get('QB Customer').get('KTQB__Field_API_Name__c') !=null
                && customerMap.size() > 0 && (String)customerMap.get('QB Customer Id').get('KTQB__Field_API_Name__c') !=null) {
            		List<Schema.DescribeSObjectResult> objectDescriptions = Schema.describeSObjects(new String[] { config.KTQB__Invoice_Customer_ChildObject_Api_Name__c });
            		Schema.DescribeSObjectResult describeResult = objectDescriptions[0];
            		Schema.SObjectType customerObjectType = describeResult.getSObjectType();
                    
                    SObject customerRecord = InvoiceControllerHelper.getCustomerMap(config.KTQB__Invoice_Customer_ChildObject_Api_Name__c,customerMap,customerData,customerResponseMap);
                    if((String)customerMap.get('Qb Customer Sync Token').get('KTQB__Field_API_Name__c') != null){
                        String syncTokenStr = (String)customerResponseMap.get('SyncToken');
                        Decimal syncTokenDec = Decimal.valueOf(syncTokenStr);
                        customerRecord.put((String)customerMap.get('Qb Customer Sync Token').get('Field_API_Name__c'), syncTokenDec);
                    }
                    if((String)customerMap.get('QB Customer Id').get('KTQB__Field_API_Name__c') != null){
                        customerRecord.put((String)customerMap.get('QB Customer Id').get('KTQB__Field_API_Name__c'), (string)customerResponseMap.get('Id'));
                    } 
                    if((String)customerMap.get('Customer Currency Reference').get('KTQB__Field_API_Name__c') != null){
                        customerRecord.put((String)customerMap.get('Customer Currency Reference').get('KTQB__Field_API_Name__c'), (string)customerData.PersonalInfo.CurrencyCode);
                    } 
                    if(customerData.accid != '' && customerData.accid != null){
                        string result = InvoiceControllerHelper.getAccountApiNameForObject(config.KTQB__Invoice_Customer_ChildObject_Api_Name__c,'Account');
                        if(result != '' && result != null){
                            customerRecord.put(result, customerData.accid);}
                    }
                    if(customerData.oppid != '' && customerData.oppid != null){
                        string result = InvoiceControllerHelper.getAccountApiNameForObject(config.KTQB__Invoice_Customer_ChildObject_Api_Name__c,'Opportunity');
                        if(result != '' && result != null){
                            customerRecord.put(result, customerData.oppid);}
                    }
                    Boolean isNotEmpty = false;
                    for (SObjectField field : customerRecord.getSObjectType().getDescribe().fields.getMap().values()) {
                        if (customerRecord.isSet(field)) {
                            isNotEmpty = true;
                            break;
                        }
                    }
                    //if (isNotEmpty && Schema.getGlobalDescribe().get(config.KTQB__Invoice_Customer_ChildObject_Api_Name__c).getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()) {
                    if (isNotEmpty && customerObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()) {    
                    	if(customerData.action == 'update'){
                            customerRecord.put('Id', customerData.id);
                        }
                        List<SObject> customerRecords = new List<SObject>();
						customerRecords.add(customerRecord);
                        
                        upsert as user customerRecords;
                        return InvoiceControllerHelper.insertCustomerRecord(customerRecord,cred);
                    }
                }            
            response = 'success'+(string)customerResponseMap.get('Id');
        }catch(exception e){
            response = 'status=fail customer insert&customerQBID='+(string)customerResponseMap.get('Id')+'&errorMessage='+e.getMessage()+'&customerSyncToken='+(string)customerResponseMap.get('SyncToken');
            HandleCustomException.logException(e);
        }
       	return response;
    }

    
    /**
     * @description Inserts a new customer record in QuickBooks and Salesforce, and returns the result.
     *
     * @param contactData The data for the customer to be inserted.
     * @param accid The Salesforce Account Id to associate with the customer.
     * @param oppid The Related OpportunityId.
     * @return A string indicating the result of the insertion:
     *         - "success" followed by the Salesforce Id if the insertion is successful.
     *         - "Check Quickbook Connection to Salesforce" if the QuickBooks connection is not authorized.
     *         - An error message if the insertion fails, including details about the error.
     */
    @AuraEnabled
    public static string insertCustomer(object contactData, string accid, string oppid){
        CustomerConfigWrapper customerData = (CustomerConfigWrapper) System.JSON.deserialize(Json.serialize(contactData), CustomerConfigWrapper.class);
        try{
            BillingInfo billingInfo = customerData.billingInfo;
            ShippingInfo shippingInfo = customerData.shippingInfo;
            PersonalInfo personalInfo = customerData.personalInfo;
            if(personalInfo.contactSameAsBilling == true){
                shippingInfo.shippingLine = billingInfo.billingLine;
                shippingInfo.shippingCountrySubDivisionCode = billingInfo.billingCountrySubDivisionCode;
                shippingInfo.shippingPostalCode = billingInfo.billingPostalCode;
                shippingInfo.shippingCountry = billingInfo.billingCountry;
                shippingInfo.shippingCity = billingInfo.billingCity;
            }
            customerData.accid = accid;
            customerData.oppid = oppid;
            KTQB__QB_Setting__c setting = KTQB__QB_Setting__c.getInstance();
            string authorizationHeader = 'Bearer '+Utils.processDecryption(CalloutUtlityController.qbInfo.KTQB__Access_Token__c);
            string endpoint =  CalloutUtlityController.qbInfo.KTQB__Sandbox_Url__c+Utils.processDecryption(CalloutUtlityController.qbInfo.KTQB__QB_Company_Id__c)+'/customer?minorversion='+setting.KTQB__QB_version__c;
            Http hp =new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization',authorizationHeader);
            req.setHeader('Accept', 'application/json');
            string body = InvoiceControllerHelper.buildCustomerRequestBody(customerData);
            req.setBody(body);
            CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
            HttpResponse res = hp.send(req);
            cred.responsebody = res;
            cred.requestbody = req;
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            CalloutUtlityController.createQBLog(cred,customerData.id);
            if(CalloutUtlityController.qbLogs.size() > 0){
                insert as user CalloutUtlityController.qbLogs;
            }
            if(String.valueOf(res.getStatusCode()) == '200'){
                if(customerData.action == 'update'){
                    Map<String, Object> selectedCustomerMap = (Map<String, Object>) responseMap.get('Customer');
                    return 'success '+(String) selectedCustomerMap.get('SyncToken');
                }else{
                    return insertCustomerInSF(cred,responseMap,customerData);
                }
            }
            if(res.getStatus() == 'Unauthorized'){
                return 'Check Quickbook Connection to Salesforce';
            }else{
                Map<String, Object> errorMap = (Map<String, Object>) responseMap.get('Fault');
                List<Object> errorList = (List<Object>) errorMap.get('Error');
                Map<String, Object> errorDetails = (Map<String, Object>) errorList[0];
                return (String) errorDetails.get('Detail');
            }
            
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return 'Something Went Wrong';
    }
    /**
     * @description Retrieves the Invoice configuration options for the current organization.
     *
     * @return An instance of InvoiceConfigWrapper containing the Invoice configuration options:
     *         - id: Id of the configuration record.
     *         - save: Indicates whether saving invoices is enabled.
     *         - saveAndSend: Indicates whether saving and sending invoices is enabled.
     *         - terms: Default terms for invoices.
     *         - tax: Default tax for invoices.
     *         - oppTerms: Map of Opportunity term field API names to their labels.
     *         - salesTax: Map of sales tax field API names to their labels.
     *         - incomeAccount: Income account for invoices.
     *         - createOpportunityProduct: Indicates whether to create opportunity products as QB items.
     *         - enableOpportunityProduct: Indicates whether to enable opportunity products.
     */
    @AuraEnabled
    public static InvoiceConfigWrapper getInvoiceConfiguration(){
        InvoiceConfigWrapper icw = new InvoiceConfigWrapper();
        try{
            KTQB__InvoiceConfigurationOptions__c config = [ SELECT Id, Name,KTQB__Create_Update_Qb_Payment_In_Sf__c, SetupOwnerId, KTQB__Invoice_Save__c, KTQB__Invoice_Save_and_Send__c, KTQB__Invoice_Date__c, KTQB__Invoice_Due_Date__c, 
                                                      KTQB__Income_Account__c, KTQB__Terms__c, KTQB__Tax__c ,KTQB__Create_opportunity_product_as_QB_Item__c , KTQB__Enable_Opportunity_Product__c
                                                      FROM KTQB__InvoiceConfigurationOptions__c 
                                                      WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            icw.id = config.Id;
            icw.save = config.KTQB__Invoice_Save__c;
            icw.saveAndSend = config.KTQB__Invoice_Save_and_Send__c;
            // OPPORTUNITY FIELDS API NAME AND LABEL MAP
			
            icw.terms = config.KTQB__Terms__c; 
            icw.tax = config.KTQB__Tax__c; 
            icw.oppTerms = getFieldOption('Term');
            icw.salesTax = getFieldOption('salesTax');
			icw.incomeAccount=config.KTQB__Income_Account__c;
            icw.createOpportunityProduct = config.KTQB__Create_opportunity_product_as_QB_Item__c;
            icw.enableOpportunityProduct = config.KTQB__Enable_Opportunity_Product__c;
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return icw;
    }
    /**
     * @description Get org Currency
     *
     * @return Get all Org Currency
     */
    @AuraEnabled
    public static string orgCurrency(){
        string orgCurr = UserInfo.getDefaultCurrency();
        return orgCurr;
    }
    /**
     * @description Retrieves a list of QuickBooks metadata options based on the specified type.
     *
     * @param type The type of metadata options to retrieve.
     * @return A list of QB_MetaData__c objects representing the metadata options of the specified type.
     */
    @AuraEnabled
     public static List<QB_MetaData__c> getFieldOption(string type){
        List<QB_MetaData__c> options = new List<QB_MetaData__c>();
        try{
            options = [Select Id, Name, Type__c, Active__c,Sales_Tax_Rate__c, QB_Id__c From QB_MetaData__c where Type__c =:type and Active__c =true WITH USER_MODE order by Name Asc];

        }
        catch(Exception e){
            HandleCustomException.logException(e);
        }
        return options;
    }
    /**
     * @description Represents the main response structure for product fault queries.
     */
    public class ProductFaultQueryResponseMain{
        /**
         * @description The wrapper containing information about product faults.
         */
        @AuraEnabled public ProductFaultQueryWrapper fault;
    }
    /**
     * @description Wrapper class for product fault queries, containing a list of product data wrappers.
     */
    public class ProductFaultQueryWrapper{
        /**
         * @description List of product data wrappers representing errors.
         */
        public List<ProductDataWrapper> error; 
    }
    /**
     * @description Wrapper class for holding configuration options related to invoices.
     */
    public class InvoiceConfigWrapper{
        /**
         * The ID of the invoice configuration.
         */
        @AuraEnabled
        public String id;
        /**
         * @description Indicates whether to save invoices.
         */
        @AuraEnabled
        public boolean save;

        /**
         * @description Indicates whether to save and send invoices.
         */
        @AuraEnabled
        public boolean saveAndSend;

        /**
         * @description List of QuickBooks metadata options for opportunity terms.
         */
        @AuraEnabled
        public List<KTQB__QB_MetaData__c> oppTerms;

        /**
         * @description List of QuickBooks metadata options for sales tax.
         */
        @AuraEnabled
        public List<KTQB__QB_MetaData__c> salesTax;

        /**
         * @description The default terms for invoices.
         */
        @AuraEnabled
        public String terms;

        /**
         * @description The default tax for invoices.
         */
        @AuraEnabled
        public String tax;

        /**
         * @description The income account associated with invoices.
         */
        @AuraEnabled
        public String incomeAccount;

        /**
         * @description Indicates whether to create opportunity products as QuickBooks items.
         */
        @AuraEnabled
        public Boolean createOpportunityProduct;

        /**
         * @description Indicates whether to enable opportunity products.
         */
        @AuraEnabled
        public Boolean enableOpportunityProduct;
    }
    /**
     * @description Wrapper class representing customer configuration details.
    */
    public class CustomerConfigWrapper {
        /**
         * @description id with the customer.
         * @AuraEnabled
         */
        @AuraEnabled public String id;
        /**
         * @description invoiceType i.e with opp product or without.
         * @AuraEnabled
         */
        @AuraEnabled public String invoiceType;
        /**
         * @description qbCustomerSyncToken is QB Customer sync token.
         * @AuraEnabled
         */
        @AuraEnabled public String qbCustomerSyncToken;
        /**
         * @description customerQBId is QB Customer Id.
         * @AuraEnabled
         */
        @AuraEnabled public String customerQBId;
        /**
         * @description Personal information associated with the customer.
         * @AuraEnabled
         */
        @AuraEnabled
        public PersonalInfo personalInfo;

        /**
         * @description Billing information associated with the customer.
         * @AuraEnabled
         */
        @AuraEnabled
        public BillingInfo billingInfo;

        /**
         * @description Shipping information associated with the customer.
         * @AuraEnabled
         */
        @AuraEnabled
        public ShippingInfo shippingInfo;
        /**
         * @description Account id associated with the customer.
         * @AuraEnabled
         */
        @AuraEnabled
        public string accid;
        /**
         * @description Opportunity id associated with the customer.
         * @AuraEnabled
         */
        @AuraEnabled
        public string oppid;
        
        @AuraEnabled
        public string action;
    }

    /**
     * @description Wrapper class representing billing information.
     */
    public class BillingInfo {
        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String billingLine;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String billingCountrySubDivisionCode;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String billingPostalCode;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String billingCountry;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String billingCity;
    }
    /**
     * @description Wrapper class representing Customer information.
     */
    public class PersonalInfo {
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String givenName;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String fax;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String mobile;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String email;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String middleName;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String familyName;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String displayName;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String website;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String phone;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String companyName;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public boolean contactSameAsBilling;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public String currencyCode;
        /**
         * @AuraEnabled
         */
        @AuraEnabled public boolean isTaxable;
    }
    /**
     * @description Wrapper class representing shipping information.
     */
    public class ShippingInfo {
        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String shippingLine;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String shippingCountrySubDivisionCode;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String shippingPostalCode;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String shippingCountry;

        /**
         * @AuraEnabled
         */
        @AuraEnabled
        public String shippingCity;
    }


    /**
     * @description Wrapper class for holding product data.
     */
    public class ProductDataWrapper {
        
        /**
         * @description The ID of the product record.
         */
        @AuraEnabled
        public String id; 

        /**
         * @description The synchronization token of the product record.
         */
        @AuraEnabled
        public String syncToken;

        /**
         * @description The name of the product.
         */
        @AuraEnabled
        public String name;

        /**
         * @description The SKU (Stock Keeping Unit) of the product.
         */
        @AuraEnabled
        public String sku;

        /**
         * @description A message related to the product.
         */
        @AuraEnabled
        public String message;

        /**
         * @description A detailed description of the product.
         */
        @AuraEnabled
        public String detail;

        /**
         * @description The description of the product.
         */
        @AuraEnabled
        public String description;

        /**
         * @description Indicates whether the product is active or not.
         */
        @AuraEnabled
        public Boolean active;
    }

    /**
     * @description Wrapper class for holding a single product record or an error response.
     */
    public class SingleProductWrapper {

        /**
         * @description The product record when the operation is successful.
         */
        public ProductDataWrapper item;

        /**
         * @description Error details when the operation encounters an issue.
         */
        public ProductDataWrapper fault;
    }
    /**
     * @description Wrapper class for holding information related to an opportunity product.
     */
    public class OppproductWrapper {
        /** 
         * @description The ID of the product.
         */
        @AuraEnabled 
        public String productId { get; set; }

        /** 
         * @description The name of the product.
         */
        @AuraEnabled 
        public String productName { get; set; }

        /** 
         * @description The expense account associated with the product.
         */
        @AuraEnabled 
        public String expenseAccount { get; set; }

        /** 
         * @description The income account associated with the product.
         */
        @AuraEnabled 
        public String incomeAccount { get; set; }

        /** 
         * @description The product code.
         */
        @AuraEnabled 
        public String code { get; set; }

        /** 
         * @description The description of the product.
         */
        @AuraEnabled 
        public String productDesc { get; set; }

        /** 
         * @description The quantity of the product.
         */
        @AuraEnabled 
        public Double quantity { get; set; }

        /** 
         * @description The rate of the product.
         */
        @AuraEnabled 
        public Double rate { get; set; }

        /** 
         * @description The total amount for the product.
         */
        @AuraEnabled 
        public Double amount { get; set; }

        /** 
         * @description Indicates whether the product is taxable.
         */
        @AuraEnabled 
        public Boolean taxable { get; set; }

        /** 
         * @description The QuickBooks product code.
         */
        @AuraEnabled 
        public String qbProductCode { get; set; }
    }

    /**
     * @description Wrapper class for holding information related to a single invoice.
     */
    public class SingleInvoiceWrapper {

        /** 
         * @description The invoice data.
         */
        @AuraEnabled 
        public DataInvoiceWrap invoice { get; set; }

        /** 
         * @description The fault data in case of an issue.
         */
        @AuraEnabled 
        public DataInvoiceWrap fault { get; set; }
    }

    /**
     * @description Wrapper class for holding information related to invoice faults.
     */
    public class InvoiceFaultWrapper {

        /** 
         * @description The fault data containing a list of errors related to invoices.
         */
        public InvoiceFaultQueryWrapper fault;
    }

    /**
     * @description Wrapper class for holding error information related to invoices.
     */
    public class InvoiceFaultQueryWrapper {

        /** 
         * @description List of error data containing details about the issues related to invoices.
         */
        public List<DataInvoiceWrap> error;
    }

    /**
     * @description Wrapper class for holding data related to invoices.
     */
    public class DataInvoiceWrap {

        /** 
         * @description Details of the invoice.
         */
        @AuraEnabled public String detail;

        /** 
         * @description Message related to the invoice.
         */
        @AuraEnabled public String message;

        /** 
         * @description Transaction date of the invoice.
         */
        @AuraEnabled public Date txnDate;

        /** 
         * @description Reference to the sales term associated with the invoice.
         */
        @AuraEnabled public SalesTermRef salesTermRef;

        /** 
         * @description Total amount of the invoice.
         */
        @AuraEnabled public Double totalAmt;
		/** 
         * @description Home Total amount of the invoice.
         */
        @AuraEnabled public Double homeTotalAmt;
        /** 
         * @description ExchangeRate of the invoice.
         */
        @AuraEnabled public Double exchangeRate;
      
        /** 
         * @description Due date of the invoice.
         */
        @AuraEnabled public Date dueDate;
        
        /** 
         * @description Document number associated with the invoice.
         */
        @AuraEnabled public String docNumber;

        /** 
         * @description Transaction tax details of the invoice.
         */
        @AuraEnabled public ClsTxnTaxDetail txnTaxDetail;

        /** 
         * @description Billing email details associated with the invoice.
         */
        @AuraEnabled public ClsBillEmail billEmail;

        /** 
         * @description Billing address details associated with the invoice.
         */
        @AuraEnabled public ClsBillAddr billAddr;

        /** 
         * @description Shipping address details associated with the invoice.
         */
        @AuraEnabled public ClsShipAddr shipAddr;

        /** 
         * @description Array of line items associated with the invoice.
         */
        @AuraEnabled public ClsLine[] line;

        /** 
         * @description ID of the invoice.
         */
        @AuraEnabled public String id;

        /** 
         * @description Remaining balance of the invoice.
         */
        @AuraEnabled public Double balance;
		/** 
         * @description Home Balance amount of the invoice.
         */
        @AuraEnabled public Double homeBalance;
        /** 
         * @description Synchronization token of the invoice.
         */
        @AuraEnabled public Double syncToken;
    }

    /**
     * @description Wrapper class for holding billing email details associated with an invoice.
     */
    public class ClsBillEmail {

        /** 
         * @description Email address associated with the billing details.
         */
        @AuraEnabled public String address;
    }

    /**
     * @description Wrapper class for holding line item details associated with an invoice.
     */
    public class ClsLine {

        /** 
         * @description Description of the line item.
         */
        @AuraEnabled public String description;

        /**
         * @description Details specific to a sales item line.
         */
        @AuraEnabled public ClsSalesItemLineDetail salesItemLineDetail;

        /**
         * @description Amount associated with the line item.
         */
        @AuraEnabled public double amount;

        /**
         * @description Identifier for the line item.
         */
        @AuraEnabled public String id;
    }

    /**
     * @description Wrapper class for holding details specific to a sales item line associated with an invoice.
     */
    public class ClsSalesItemLineDetail {

        /** 
         * @description Reference to the tax code associated with the sales item line.
         */
        @AuraEnabled public ClsTaxCodeRef taxCodeRef;

        /**
         * @description Quantity of the item.
         */
        @AuraEnabled public double qty;

        /**
         * @description Unit price of the item.
         */
        @AuraEnabled public double unitPrice;

        /**
         * @description Reference to the item associated with the sales item line.
         */
        @AuraEnabled public ClsItemRef itemRef;
    }

    /**
     * @description Wrapper class for holding reference details of an item associated with a sales item line.
     */
    public class ClsItemRef {

        /** 
         * @description Value representing the unique identifier of the item.
         */
        @AuraEnabled public String value;

        /**
         * @description Name of the item.
         */
        @AuraEnabled public String name;
    }

    /**
     * @description Wrapper class for holding reference details of a tax code associated with a sales item line.
     */
    public class ClsTaxCodeRef {

        /** 
         * @description Value representing the unique identifier of the tax code.
         */
        @AuraEnabled public String value;
    }

    /**
     * @description Wrapper class for holding shipping address details.
     */
    public class ClsShipAddr {

        /** 
         * @description The city in the shipping address.
         */
        @AuraEnabled public String city;

        /** 
         * @description The first line of the shipping address.
         */
        @AuraEnabled public String line1;

        /** 
         * @description The second line of the shipping address.
         */
        @AuraEnabled public String line2;

        /** 
         * @description The third line of the shipping address.
         */
        @AuraEnabled public String line3;

        /** 
         * @description The postal code in the shipping address.
         */
        @AuraEnabled public String postalCode;

        /** 
         * @description The country in the shipping address.
         */
        @AuraEnabled public String country;

        /** 
         * @description The country subdivision code in the shipping address.
         */
        @AuraEnabled public String countrySubDivisionCode;
    }

    /**
     * @description Wrapper class for holding billing address details.
     */
    public class ClsBillAddr {

        /** 
         * @description The first line of the billing address.
         */
        @AuraEnabled public String line1;

        /** 
         * @description The second line of the billing address.
         */
        @AuraEnabled public String line2;

        /** 
         * @description The third line of the billing address.
         */
        @AuraEnabled public String line3;

        /** 
         * @description The fourth line of the billing address.
         */
        @AuraEnabled public String line4;
    }

    /**
     * @description Wrapper class for holding transaction tax details.
     */
    public class ClsTxnTaxDetail {

        /** 
         * @description The total tax amount for the transaction.
         */
        @AuraEnabled public Double totalTax;

        /** 
         * @description The reference to the tax rate for the transaction.
         */
        @AuraEnabled public ClsTaxRateRef taxRateRef;

        /** 
         * @description The array of tax lines associated with the transaction.
         */
        @AuraEnabled public ClsTaxLine[] taxLine;
    }

    /**
     * @description Wrapper class for holding tax line details.
     */
    public class ClsTaxLine {

        /** 
         * @description The details associated with the tax line.
         */
        @AuraEnabled public ClsTaxLineDetail taxLineDetail;
    }

    /**
     * @description Wrapper class for holding tax line details.
     */
    public class ClsTaxLineDetail {

        /** 
         * @description The tax percentage associated with the tax line.
         */
        @AuraEnabled public Double taxPercent;  
    }

    /**
     * @description Wrapper class for holding tax rate reference.
     */
    public class ClsTaxRateRef {

        /** 
         * @description The value associated with the tax rate reference.
         */
        @AuraEnabled public String value;
    }

    /**
     * @description Wrapper class for holding sales term reference.
     */
    public class SalesTermRef {

        /** 
         * @description The value associated with the sales term reference.
         */
        @AuraEnabled public String value;

        /**
         * @description The name associated with the sales term reference.
         */
        @AuraEnabled public String name;
    }

    /**
     * @description Wrapper class for holding Invoice Custome Data.
     */
    public class InvoiceCustomeData {
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string terms;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public date dueDate;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string discountTypeValue;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string discountValue;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string discountTotal;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string taxId;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string taxRate;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string taxAmount;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public date invoiceDate;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string getAccid;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string getOppid;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string shipping;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string customerQBId;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string taxSFID;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string termSFID;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public boolean discountAfterTax;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string syncToken;
        /** 
         * @description The value associated with the Invoice Custome Data.
         */
        @AuraEnabled public string invoiceQBID;
    }

}