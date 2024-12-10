/**
 * @Author : Kandisa Technologies
 * @description : Helper class for InvoiceController providing various utility methods.
 * Modified on 08/10/2024 by Twinkle
 */
public with sharing class InvoiceControllerHelper {
    /**
     * @description Retrieves the billing address from the provided InvoiceController.SingleInvoiceWrapper.
     * @param wrapInvoice The SingleInvoiceWrapper containing the invoice data.
     * @return The formatted billing address as a string.
     */
    public static string getInvoiceBillAddress(InvoiceController.SingleInvoiceWrapper wrapInvoice){
        string billAddress='';
        if(wrapInvoice.invoice.billAddr.line1 != null || wrapInvoice.invoice.billAddr.line1 != ''){
            billAddress += wrapInvoice.invoice.billAddr.line1+'\n';
        }
        if(wrapInvoice.invoice.billAddr.line2 != null || wrapInvoice.invoice.billAddr.line2 != ''){
            billAddress += wrapInvoice.invoice.billAddr.line2+'\n';
        }
        if(wrapInvoice.invoice.billAddr.line3 != null || wrapInvoice.invoice.billAddr.line3 != ''){
            billAddress += wrapInvoice.invoice.billAddr.line3+'\n';
        }
        if(wrapInvoice.invoice.billAddr.line4 != null || wrapInvoice.invoice.billAddr.line4 != ''){
            billAddress += wrapInvoice.invoice.billAddr.line4+'\n';
        }
        return billAddress;
    }
    /**
     * @description Retrieves the shipping address from the provided InvoiceController.SingleInvoiceWrapper.
     * @param wrapInvoice The SingleInvoiceWrapper containing the invoice data.
     * @return The formatted shipping address as a string.
     */
    public static string getInvoiceShipAddress(InvoiceController.SingleInvoiceWrapper wrapInvoice){
        string shipAddress='';
        if(wrapInvoice.invoice.shipAddr.line1 != null || wrapInvoice.invoice.shipAddr.line1 != ''){
            shipAddress += wrapInvoice.invoice.shipAddr.line1+'\n';
        }
        if(wrapInvoice.invoice.shipAddr.line2 != null || wrapInvoice.invoice.shipAddr.line2 != ''){
            shipAddress += wrapInvoice.invoice.shipAddr.line2+'\n';
        }
        if(wrapInvoice.invoice.shipAddr.line3 != null || wrapInvoice.invoice.shipAddr.line3 != ''){
            shipAddress += wrapInvoice.invoice.shipAddr.line3+'\n';
        }
        if(wrapInvoice.invoice.shipAddr.city != null || wrapInvoice.invoice.shipAddr.country != null || wrapInvoice.invoice.shipAddr.postalCode != null || wrapInvoice.invoice.shipAddr.city != '' || wrapInvoice.invoice.shipAddr.country != '' || wrapInvoice.invoice.shipAddr.postalCode != ''){
            shipAddress += wrapInvoice.invoice.shipAddr.city +' '+wrapInvoice.invoice.shipAddr.countrySubDivisionCode+' '+wrapInvoice.invoice.shipAddr.postalCode+' '+wrapInvoice.invoice.shipAddr.country;
        }
        return shipAddress;
    }
    /**
     * @description Prepares an invoice record based on the provided dataMap, wrapInvoice, and invCustomeData.
     * @param dataMap A map of field configurations.
     * @param wrapInvoice The SingleInvoiceWrapper containing the invoice data.
     * @param invCustomeData Custom data related to the invoice.
     * @return The prepared SObject representing the invoice record.
     */
    public static SObject prepareInvoiceRecord(Map<String, SObject> dataMap,InvoiceController.SingleInvoiceWrapper wrapInvoice
    ,InvoiceController.invoiceCustomeData invCustomeData){
        KTQB__InvoiceConfigurationOptions__c config = [ SELECT KTQB__Invoice_Customer_ChildObject_Api_Name__c,KTQB__LineItem_ChildObject_Name__c,
                                                         KTQB__LineItem_Object_Name__c,KTQB__Invoice_Object_Name__c FROM KTQB__InvoiceConfigurationOptions__c 
                                                     WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
        boolean percentBased = (invCustomeData.discountTypeValue == 'Value') ? false : true;
        SObject invoiceRecord = Schema.getGlobalDescribe().get(config.Invoice_Object_Name__c).newSObject();
        string invoiceNum = (wrapInvoice.invoice.docNumber != null) ? 'Invoice #'+wrapInvoice.invoice.docNumber : 'Invoice';
        setFieldValue(dataMap, 'Name', 'KTQB__Field_API_Name__c', invoiceNum, invoiceRecord);
        if (String.isNotBlank(invCustomeData.discountTotal)) {setFieldValue(dataMap, 'Discount Amount', 'KTQB__Field_API_Name__c', Math.abs(decimal.valueOf(invCustomeData.discountTotal)), invoiceRecord);}
        setFieldValue(dataMap, 'Balance Due', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.balance, invoiceRecord);
        setFieldValue(dataMap, 'Invoice Number', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.docNumber, invoiceRecord);
        setFieldValue(dataMap, 'Invoice Date', 'KTQB__Field_API_Name__c', invCustomeData.invoiceDate, invoiceRecord);
        setFieldValue(dataMap, 'Transaction Date', 'KTQB__Field_API_Name__c', date.valueOf(wrapInvoice.invoice.txnDate), invoiceRecord);
        setFieldValue(dataMap, 'Total Amount', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.totalAmt, invoiceRecord);
        setFieldValue(dataMap, 'Home Total Amount', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.homeTotalAmt, invoiceRecord);
        setFieldValue(dataMap, 'Home Balance', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.homeBalance, invoiceRecord);
        setFieldValue(dataMap, 'Exchange Rate', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.exchangeRate, invoiceRecord);
        setFieldValue(dataMap, 'Invoice Status', 'KTQB__Field_API_Name__c', 'Open', invoiceRecord);
        setFieldValue(dataMap, 'Due Date', 'KTQB__Field_API_Name__c', date.valueOf(wrapInvoice.invoice.dueDate), invoiceRecord);
        setFieldValue(dataMap, 'Qb Invoice Sync Token', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.syncToken, invoiceRecord);
        setFieldValue(dataMap, 'Invoice Qb Id', 'KTQB__Field_API_Name__c', wrapInvoice.invoice.id, invoiceRecord);
        if (String.isNotBlank(invCustomeData.shipping)) {setFieldValue(dataMap, 'Shipping Charges', 'KTQB__Field_API_Name__c', decimal.valueOf(invCustomeData.shipping), invoiceRecord);}
        setFieldValue(dataMap, 'Percent Based Discount', 'KTQB__Field_API_Name__c', percentBased, invoiceRecord);
        if (String.isNotBlank(invCustomeData.discountValue)) {setFieldValue(dataMap, 'Discount Percent / Discount Value', 'KTQB__Field_API_Name__c', decimal.valueOf(invCustomeData.discountValue), invoiceRecord);}
        setFieldValue(dataMap, 'QB Customer Ref ID', 'KTQB__Field_API_Name__c', invCustomeData.customerQBId, invoiceRecord);
		setFieldValue(dataMap, 'Apply discount after sales tax', 'KTQB__Field_API_Name__c', !invCustomeData.discountAfterTax, invoiceRecord);
        //setFieldValue(dataMap, 'Currency Reference', 'KTQB__Field_API_Name__c', !invCustomeData.discountAfterTax, invoiceRecord);
        if (invCustomeData.taxId != null) {
            if (String.isNotBlank(invCustomeData.taxAmount)) setFieldValue(dataMap, 'Total Tax', 'KTQB__Field_API_Name__c', Decimal.valueOf(invCustomeData.taxAmount), invoiceRecord);
            if (String.isNotBlank(invCustomeData.taxRate)) setFieldValue(dataMap, 'Tax Rate', 'KTQB__Field_API_Name__c', Decimal.valueOf(invCustomeData.taxRate), invoiceRecord);
            setFieldValue(dataMap, 'Tax Code', 'KTQB__Field_API_Name__c', invCustomeData.taxSFID, invoiceRecord);
        }
        if (wrapInvoice.invoice.salesTermRef != null && hasField(dataMap, 'Terms', 'KTQB__Field_API_Name__c')) {
            //invoiceRecord.put((String)dataMap.get('Terms').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.salesTermRef.name);
            invoiceRecord.put((String)dataMap.get('Terms').get('KTQB__Field_API_Name__c'), invCustomeData.termSFID);
        }

        if (wrapInvoice.invoice.billEmail != null && (String)dataMap.get('BillEmail').get('KTQB__Field_API_Name__c') != null) {
            invoiceRecord.put((String)dataMap.get('BillEmail').get('KTQB__Field_API_Name__c'), wrapInvoice.invoice.billEmail.address);}
            return invoiceRecord;
    }
    /** 
     * @description Sets the field value on the given SObject record.
     * 
     * @param dataMap A map containing SObject field information.
     * @param fieldName The name of the field.
     * @param apiName The API name of the field.
     * @param value The value to set.
     * @param invoiceRecord The SObject record to update.
     */
    public static void setFieldValue(Map<String, SObject> dataMap, String fieldName, String apiName, Object value,SObject invoiceRecord) {
         if (hasField(dataMap, fieldName, apiName)) {
            invoiceRecord.put((String)dataMap.get(fieldName).get(apiName), value);
         }
    }
    /**
     * @description Checks if a field is present in the data map.
     * 
     * @param dataMap A map containing SObject field information.
     * @param fieldName The name of the field.
     * @param apiName The API name of the field.
     * @return true if the field is present, false otherwise.
     */
    public static boolean hasField(Map<String, SObject> dataMap, String fieldName, String apiName) {
        return (String)dataMap.get(fieldName).get(apiName) != null;
    }
    /**
     * @description Builds the JSON representation of line items for an invoice.
     * 
     * @param invCustomeData Invoice custom data.
     * @param oppProducts List of opportunity products.
     * @param conDetails Customer configuration details.
     * @return The JSON representation of line items.
     */
    public static string buildLineItemsJSON(InvoiceController.invoiceCustomeData invCustomeData,
                                            List<QBProductController.OppproductWrapper> oppProducts,
                                            InvoiceController.CustomerConfigWrapper conDetails){
        double discountAmt = (invCustomeData.discountTypeValue == 'Value') ? decimal.valueOf(invCustomeData.discountValue) : 0;
        product2 product = new product2();
        boolean percentBased = (invCustomeData.discountTypeValue == 'Value') ? false : true;
        double discountPercent = (invCustomeData.discountTypeValue == 'Value') ? 0 : decimal.valueOf(invCustomeData.discountValue);
        KTQB__InvoiceConfigurationOptions__c configProduct = [select id, KTQB__Enable_Opportunity_Product__c , KTQB__Invoice_Date__c,KTQB__Create_opportunity_product_as_QB_Item__c from KTQB__InvoiceConfigurationOptions__c WITH USER_MODE LIMIT 1 ];    
        string itemsJSON = '{"TxnDate": "'+invCustomeData.invoiceDate+'",';
            itemsJSON += '"Line":[';
            Set<Id> productIds = new Set<Id>();
            for(QBProductController.OppproductWrapper oppwrap : oppProducts){
                string qbId = oppwrap.qbProductCode;
                if (qbId == null && conDetails.invoiceType == 'oppProduct' && configProduct.Create_opportunity_product_as_QB_Item__c == true) {
                    productIds.add(oppwrap.productId);
                }
            }
            Map<Id, product2> productMap = new Map<Id, product2>([SELECT id, KTQB__Item_QB_Id__c FROM product2 WHERE id IN :productIds]);
            for(QBProductController.OppproductWrapper oppwrap : oppProducts){
                string qbId = oppwrap.qbProductCode;
                string tax= (oppwrap.taxable == true) ? 'TAX' : 'NON';
                if (qbId == null && conDetails.invoiceType == 'oppProduct' /*&& configProduct.KTQB__Create_opportunity_product_as_QB_Item__c == true*/) {
                    product = productMap.get(oppwrap.productId);
                    qbId = product != null ? product.KTQB__Item_QB_Id__c : null;
                } 
                itemsJSON += '{"DetailType":"SalesItemLineDetail",'+'"Description": "'+oppwrap.productDesc+'","Amount":'+oppwrap.amount+',"SalesItemLineDetail":{"TaxCodeRef": {"value": "'+tax+'"},"UnitPrice": '+oppwrap.rate+',"Qty": '+oppwrap.quantity;
                if(conDetails.invoiceType == 'oppProduct' /*&& configProduct.KTQB__Create_opportunity_product_as_QB_Item__c == true */&& qbId != null){
                    itemsJSON += ',"ItemRef":{"value":"'+qbId+'"}';}
                if(qbId == ''){
                    itemsJSON += ',"ItemRef":{"value":"1"}';
                }
                itemsJSON += '}},';
            }
			itemsJSON += '{"DetailType": "DiscountLineDetail","Amount": '+discountAmt+',"DiscountLineDetail": {"PercentBased": '+percentBased+',"DiscountPercent": '+discountPercent+'}}';
            if(invCustomeData.shipping != '' || invCustomeData.shipping != null){
                itemsJSON += ',{"Amount":'+invCustomeData.shipping+',"DetailType":"SalesItemLineDetail","SalesItemLineDetail":{"ItemRef":{"value":"SHIPPING_ITEM_ID"}}}';
            }
            itemsJSON += '],"TxnTaxDetail": {"TxnTaxCodeRef": {"value": "'+invCustomeData.taxId+'"}},"CustomerRef":{"value":"'+conDetails.customerQBId+'"},"EmailStatus":"EmailSent","BillEmail": {"Address": "'+conDetails.PersonalInfo.Email+'"},"BillAddr": {"Line1": "'+conDetails.PersonalInfo.givenName + ' '+conDetails.PersonalInfo.FamilyName+'", "Line2": "'+conDetails.PersonalInfo.DisplayName+'","Line3": "'+conDetails.BillingInfo.BillingLine+'", "Line4": "'+conDetails.BillingInfo.BillingCity+' '+conDetails.BillingInfo.BillingCountry+' '+conDetails.BillingInfo.BillingPostalCode+' '+conDetails.BillingInfo.BillingCountrySubDivisionCode+'"}, "ShipAddr": {"Line1": "'+conDetails.PersonalInfo.GivenName+' '+conDetails.PersonalInfo.FamilyName+'", "Line2": "'+conDetails.PersonalInfo.DisplayName+'","City": "'+conDetails.ShippingInfo.ShippingCity+'", "Line3": "'+conDetails.ShippingInfo.shippingLine+'","PostalCode": "'+conDetails.ShippingInfo.ShippingPostalCode+'","Country": "'+conDetails.ShippingInfo.ShippingCountry+'","CountrySubDivisionCode": "'+conDetails.ShippingInfo.ShippingCountrySubDivisionCode+'" },"SalesTermRef": {"value": "'+invCustomeData.terms+'"},"ApplyTaxAfterDiscount":"'+invCustomeData.discountAfterTax+'","DueDate": "'+invCustomeData.dueDate+'"';
            if(invCustomeData.invoiceQBID != '' && invCustomeData.invoiceQBID != null){
                itemsJSON += ', "Id":"'+invCustomeData.invoiceQBID+'","SyncToken":"'+invCustomeData.syncToken+'"';
            }
        itemsJSON += '}';
        	itemsJSON = itemsJSON.replace('null','');
            return itemsJSON;
    }
    /**
     * @description Builds the JSON representation of customer request body.
     * 
     * @param customerData Customer configuration details.
     * @return The JSON representation of customer request body.
     */
    public static String buildCustomerRequestBody(InvoiceController.CustomerConfigWrapper customerData) {
        string body = '';
        try{
            body = '{' +
                + ' "GivenName":"'+customerData.PersonalInfo.givenName+'",'
                + ' "FamilyName":"'+customerData.PersonalInfo.familyName+'",'
                + ' "FullyQualifiedName":"'+customerData.PersonalInfo.givenName+' '+customerData.PersonalInfo.familyName+'",'
                + ' "PrimaryPhone": { "FreeFormNumber": "'+customerData.PersonalInfo.phone+'" },' 
                + ' "Mobile": { "FreeFormNumber": "'+customerData.PersonalInfo.mobile+'" },'
                + ' "WebAddr": { "URI": "'+customerData.PersonalInfo.website+'" },'
                + ' "Fax": { "FreeFormNumber": "'+customerData.PersonalInfo.fax+'" },'
                + ' "PrimaryEmailAddr": { "Address": "'+customerData.PersonalInfo.email+'" },' 
                + ' "DisplayName": "'+customerData.PersonalInfo.displayName+'",'
                + ' "MiddleName": "'+customerData.PersonalInfo.middleName+'",'
                + ' "CompanyName": "'+customerData.PersonalInfo.companyName+'",'
                + ' "Taxable": "'+customerData.PersonalInfo.isTaxable+'",'   
                + ' "BillAddr": { "CountrySubDivisionCode": "'+customerData.BillingInfo.billingCountrySubDivisionCode+'", "City": "'+customerData.BillingInfo.billingCity+'", "PostalCode": "'+customerData.BillingInfo.billingPostalCode+'", "Line1": "'+customerData.BillingInfo.billingLine+'", "Country": "'+customerData.BillingInfo.billingCountry+'" },'+
                + ' "ShipAddr": { "CountrySubDivisionCode": "'+customerData.ShippingInfo.shippingCountrySubDivisionCode+'", "City": "'+customerData.ShippingInfo.shippingCity+'", "PostalCode": "'+customerData.ShippingInfo.shippingPostalCode+'", "Line1": "'+customerData.ShippingInfo.shippingLine+'", "Country": "'+customerData.ShippingInfo.shippingCountry+'" }';
            if(customerData.PersonalInfo.currencyCode != '' && customerData.PersonalInfo.currencyCode != null){
               body += ',"CurrencyRef": {"value": "'+customerData.PersonalInfo.currencyCode+'"}'; 
            }
            if(customerData.customerQBId != null && customerData.qbCustomerSyncToken != null){
                body += ',"sparse": true,"Id": "'+customerData.customerQBId+'","SyncToken": "'+customerData.qbCustomerSyncToken+'"';
            }
            body += '}';
            body = body.replace('null','');
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return body;
    }
    /**
     * @description Inserts a customer record and creates a QuickBooks log.
     * 
     * @param customerRecord The customer record to insert.
     * @param cred Callout credentials.
     * @return A success message with the customer ID if successful, an empty string otherwise.
     */
    public static String insertCustomerRecord(SObject customerRecord,CalloutUtlityController.CalloutCredentials cred) {
        if(customerRecord.id != null){
            return 'success '+customerRecord.id;
        }
        return '';
    }
    /**
     * @description Creates a customer wrapper from an SObject and a field mapping.
     * 
     * @param so The SObject representing the customer.
     * @param customerMap Field mapping for the customer.
     * @return The customer wrapper.
     */
    public static InvoiceController.CustomerConfigWrapper createCustomerWrapper(SObject so, Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap) {
        InvoiceController.CustomerConfigWrapper custWrap = new InvoiceController.CustomerConfigWrapper();
        try{
            custWrap.id = so.Id;
            InvoiceController.PersonalInfo personalInfo = new InvoiceController.PersonalInfo();
            InvoiceController.ShippingInfo shippingInfo = new InvoiceController.ShippingInfo();
            InvoiceController.BillingInfo billingInfo = new InvoiceController.BillingInfo();
            personalInfo.givenName = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'GivenName');
            personalInfo.fax = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Fax');
            personalInfo.mobile = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Mobile');
            shippingInfo.shippingLine = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Shipping Line');
            shippingInfo.shippingCountrySubDivisionCode = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Shipping Country Sub DivisionCode');
            shippingInfo.shippingPostalCode = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Shipping PostalCode');
            shippingInfo.shippingCountry = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Shipping Country');
            shippingInfo.shippingCity = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Shipping City');
            personalInfo.email = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Email');
            billingInfo.billingLine = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Billing Line');
            billingInfo.billingCountrySubDivisionCode = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Billing Country Sub DivisionCode');
            billingInfo.billingPostalCode = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Billing PostalCode');
            billingInfo.billingCountry = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Billing Country');
            billingInfo.billingCity = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Billing City');
            personalInfo.middleName = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'MiddleName');
            personalInfo.familyName = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'FamilyName');
            personalInfo.displayName = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Display Name');
            personalInfo.website = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Website');
            custWrap.qbCustomerSyncToken = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Qb Customer Sync Token');
            custWrap.customerQBId = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'QB Customer Id');
            //custWrap.customerQBId = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Customer Currency Reference');
            personalInfo.companyName = InvoiceControllerHelper.getValueFromSObject(so, customerMap, 'Company Name');
            if(Utils.getIsMultiCurrencyOrg()){ 
                personalInfo.currencyCode = String.valueOf(so.get('CurrencyIsoCode'));
            }else{
                String curr = UserInfo.getDefaultCurrency();
                personalInfo.currencyCode = curr;
            }
            custWrap.PersonalInfo = personalInfo;
            custWrap.ShippingInfo = shippingInfo;
            custWrap.BillingInfo = billingInfo;
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return custWrap;
    }
    /**
     * @description Retrieves a mapping of configuration field names to SObject records based on the provided API name.
     *
     * @param apiName The API name of the configuration object from which to retrieve fields.
     * @return A Map where keys are configuration field names and values are corresponding SObject records.
     *         The Map is empty if no records are found or if an exception occurs.
     */
    public static Map<String, SObject> getConfigurationFieldMap(string apiName){
        String orgId = UserInfo.getOrganizationId();
        String query = 'SELECT Id, Name, KTQB__Field_Value__c, KTQB__Field_API_Name__c ' +
                       'FROM ' + apiName + ' ' +
                       'WHERE SetupOwnerId = :bindOrgId';
        
        
        Map<String, Object> bindVars = new Map<String, Object>{
            'bindOrgId' => orgId
        };
            // changed user mode to system mode
        List<SObject> dataField = Database.queryWithBinds(
            String.escapeSingleQuotes(query),
            bindVars,
            AccessLevel.SYSTEM_MODE
        );
        //List<SObject> dataField = Database.query(query.replace(':orgId', '\'' + UserInfo.getOrganizationId() + '\''));
        Map<String, SObject> dataMap = new Map<String, SObject>();
        for (SObject record : dataField) {
            dataMap.put((String)record.get('Name'), record);
        }
        return dataMap;
    }
    /**
     * @description Retrieves the value of a specified field from an SObject based on the provided field name and field mapping.
     * 
     * @param so The SObject from which to retrieve the field value.
     * @param customerMap The mapping of customer object field names to their corresponding API names.
     * @param fieldName The name of the field for which to retrieve the value.
     * @return A String representing the value of the specified field, or an empty string if the field is not present.
     */
    public static String getValueFromSObject(SObject so, Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap, String fieldName) {
        try{
            if (customerMap.get(fieldName).KTQB__Field_API_Name__c != null) {
                return String.valueOf(so.get(customerMap.get(fieldName).KTQB__Field_API_Name__c));
            }
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return '';
    }
    /**
     * @description Gets the API name of an account field for the specified object and relationship type.
     *
     * @param objectApiName API name of the object for which to find the account field.
     * @param type Relationship type to match with the lookup field's data type.
     * @return The API name of the account field if found, an empty string otherwise.
     */
    public static string getAccountApiNameForObject(string objectApiName, string type){
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
		for (String fieldName : fieldsMap.keySet()) {
            Schema.SObjectField field = fieldsMap.get(fieldName);
    		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
                String lookupFieldDataType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                if(lookupFieldDataType == type){
                    return fieldName;}
            }
        }
        return '';
    }
    /**
     * @description Builds a JSON representation of an item based on the provided Opportunity Product details.
     * 
     * @param oppProducts The Opportunity Product details used to construct the item JSON.
     * @param productName The name of the product associated with the item.
     * @return A String containing the JSON representation of the item.
     */
    public static String buildItemsJSON(InvoiceController.OppproductWrapper oppProducts, String productName) {
        return '{' +
            ' "Name":"' + productName + '",' +
            ' "Description":"' + oppProducts.productDesc + '",' +
            ' "Sku":"' + oppProducts.code + '",' +
            ' "Taxable":"' + oppProducts.taxable + '",' +
            ' "Active":true,' +
            ' "UnitPrice":"' + oppProducts.rate + '",' +
            ' "Type":"Service",' +
            ' "ExpenseAccountRef": { "value":' + oppProducts.expenseAccount + '},' +
            ' "IncomeAccountRef": { "value":' + oppProducts.incomeAccount + '}}';
    }
    /**
     * @description Updates the Item_QB_Id__c field on Product2 records based on the provided mapping.
     * 
     * @param oppProdMap A map containing Product2 record Ids as keys and corresponding QuickBooks Item Ids as values.
     * @param cred The CalloutCredentials used for logging the update in QuickBooks.
     * @return A string indicating the result of the update operation.
     *         - 'success' if the update was successful.
     *         - 'Field Item_QB_Id__c is not updateable' if the Item_QB_Id__c field is not updateable.
     *         - 'Something went wrong' if an unspecified error occurred.
     */
    public static string updateProductRecords(Map<String, String> oppProdMap,CalloutUtlityController.CalloutCredentials cred) {
        if (oppProdMap.size() > 0) {
            List<Product2> productList = [SELECT Id, KTQB__Item_QB_Id__c FROM Product2 WHERE Id IN :oppProdMap.keySet() WITH USER_MODE];
            List<Product2> proListToUpdate = new List<Product2>();
    
            for (Product2 pro : productList) {
                pro.KTQB__Item_QB_Id__c = oppProdMap.get(pro.id);
                CalloutUtlityController.createQBLog(cred, pro.id);
                proListToUpdate.add(pro);
            }
    
            if (CalloutUtlityController.qbLogs.size() > 0 && KTQB__QB_Log__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()) {
                insert as user CalloutUtlityController.qbLogs;
            }
    
            if (proListToUpdate.size() > 0 && Product2.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()) {
                update as user proListToUpdate;
                return 'success';
            }else{
                return 'KTQB__Field Item_QB_Id__c is not updateable';
            }
        }
        return 'Something went wrong';
    }
    /**
     * @description Generates a list of field checks based on the provided Customer_Object_Field_Mapping__c.
     * 
     * @param customerMap A map containing field names as keys and corresponding Customer_Object_Field_Mapping__c records as values.
     * @return A list of field checks represented as strings.
     *         Each string contains the field API name followed by '!= null' for the specified fields.
     */
    public static List<String> getFieldChecks(Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap) {
        List<String> fieldChecks = new List<String>();
        for (String fieldName : new List<String>{ 'Display Name'/*, 'GivenName', 'FamilyName','MiddleName'*/ }) {
            String fieldAPIName = customerMap.get(fieldName)?.KTQB__Field_API_Name__c;
            if (fieldAPIName != null) {
                fieldChecks.add(fieldAPIName + ' != null');
            }
        }
        return fieldChecks;
    }
    /**
     * @description Checks if the provided configuration is valid for performing QuickBooks invoice operations.
     * 
     * @param dataMap A map containing field mappings for QuickBooks invoice objects.
     * @param config The configuration options for QuickBooks invoices.
     * @param customerMap A map containing field mappings for the customer object.
     * @return A boolean indicating whether the configuration is valid.
     *         - Returns true if the configuration is valid.
     *         - Returns false if the configuration is not valid.
     *         
     * The configuration is considered valid if:
     * - There are fields mapped for QuickBooks customer and QuickBooks invoice in the dataMap.
     * - The configuration options, including the Invoice_Customer_ChildObject_Api_Name__c field, are not null.
     * - The customerMap contains field mappings for 'QB Customer Id' in the expected format.
     */
    public static boolean isValidConfiguration(Map<String, KTQB__Invoice_Object_Field_Mapping__c> dataMap, KTQB__InvoiceConfigurationOptions__c config, Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap) {
        return dataMap.size() > 0 && config.KTQB__Invoice_Customer_ChildObject_Api_Name__c != null &&
               dataMap.containsKey('QB Customer') && dataMap.get('QB Customer').KTQB__Field_API_Name__c != null &&
               customerMap.size() > 0 && customerMap.containsKey('QB Customer Id') && customerMap.get('QB Customer Id').KTQB__Field_API_Name__c != null;
    }
    /**
     * @description Creates a map of Invoice_Object_Field_Mapping__c records based on their Name field.
     * 
     * @param fieldMappings A list of Invoice_Object_Field_Mapping__c records to be mapped.
     * @return A map where the key is the Name field of the mapping records and the value is the mapping record itself.
     */
    public static Map<String, KTQB__Invoice_Object_Field_Mapping__c> createFieldMappingMap(List<KTQB__Invoice_Object_Field_Mapping__c> fieldMappings) {
        Map<String, KTQB__Invoice_Object_Field_Mapping__c> fieldMap = new Map<String, KTQB__Invoice_Object_Field_Mapping__c>();
        for (KTQB__Invoice_Object_Field_Mapping__c record : fieldMappings) {
            fieldMap.put(record.Name, record);
        }
        return fieldMap;
    }
    /**
     * @description Creates a map of Customer_Object_Field_Mapping__c records based on their Name field.
     * 
     * @param fieldMappings A list of Customer_Object_Field_Mapping__c records to be mapped.
     * @return A map where the key is the Name field of the mapping records and the value is the mapping record itself.
     */
    public static Map<String, KTQB__Customer_Object_Field_Mapping__c> createFieldMappingMap(List<KTQB__Customer_Object_Field_Mapping__c> fieldMappings) {
        Map<String, KTQB__Customer_Object_Field_Mapping__c> fieldMap = new Map<String, KTQB__Customer_Object_Field_Mapping__c>();
        for (KTQB__Customer_Object_Field_Mapping__c record : fieldMappings) {
            fieldMap.put(record.Name, record);
        }
        return fieldMap;
    }
    /**
     * @description Retrieves the field value from the provided customer data based on the specified field API name.
     * 
     * @param fieldApiName The field API name to retrieve from the customer data.
     * @param customerData The wrapper class containing customer information.
     * @param customerResponseMap A map containing additional customer response data.
     * @return The value of the specified field from the customer data.
     *         Returns null if the field is not found or has no value.
     */
    public static Object getFieldFromCustomerData(String fieldApiName, InvoiceController.CustomerConfigWrapper customerData, Map<String, Object> customerResponseMap) {
        switch on fieldApiName {
            when 'GivenName' { return customerData.PersonalInfo.givenName; }
            when 'Fax' { return customerData.PersonalInfo.fax; }
            when 'Mobile' { return customerData.PersonalInfo.mobile; }
            when 'Shipping Line' { return customerData.ShippingInfo.shippingLine; }
            when 'Shipping Country Sub DivisionCode' { return customerData.ShippingInfo.shippingCountrySubDivisionCode; }
            when 'Shipping PostalCode' { return customerData.ShippingInfo.shippingPostalCode; }
            when 'Shipping Country' { return customerData.ShippingInfo.shippingCountry; }
            when 'Shipping City' { return customerData.ShippingInfo.shippingCity; }
            when 'Email' { return customerData.PersonalInfo.email; }
            when 'Billing Line' { return customerData.BillingInfo.billingLine; }
            when 'Billing Country Sub DivisionCode' { return customerData.BillingInfo.billingCountrySubDivisionCode; }
            when 'Billing PostalCode' { return customerData.BillingInfo.billingPostalCode; }
            when 'Billing Country' { return customerData.BillingInfo.billingCountry; }
            when 'Billing City' { return customerData.BillingInfo.billingCity; }
            when 'MiddleName' { return customerData.PersonalInfo.middleName; }
            when 'FamilyName' { return customerData.PersonalInfo.familyName; }
            when 'Display Name' { return customerData.PersonalInfo.displayName; }
            when 'Website' { return customerData.PersonalInfo.website; }
            when 'Phone' { return customerData.PersonalInfo.phone; }
            when 'Qb Customer Sync Token' { return customerData.qbCustomerSyncToken; }
            when 'QB Customer Id' { return customerData.id; }
            when 'Company Name' { return customerData.PersonalInfo.companyName; }
            when 'Is Taxable' { return customerData.PersonalInfo.isTaxable; }
            when else { return null; }
        }
    }
    /**
     * @description Creates a new SObject record for the specified invoice customer object and populates its fields based on the provided mappings and customer data.
     * 
     * @param invoiceCustomerObject The API name of the invoice customer object.
     * @param customerMap A map containing field mappings for the customer object.
     * @param customerData The wrapper class containing customer information.
     * @param customerResponseMap A map containing additional customer response data.
     * @return An SObject record representing the customer with populated fields.
     */
    public static SObject getCustomerMap(
    String invoiceCustomerObject,
    Map<String, SObject> customerMap,
    InvoiceController.CustomerConfigWrapper customerData,
    Map<String, Object> customerResponseMap
    ) {
        SObject customerRecord = Schema.getGlobalDescribe().get(invoiceCustomerObject).newSObject();
        Map<String, Schema.SObjectField> fieldsMap = customerRecord.getSObjectType().getDescribe().fields.getMap();

        for (String fieldApiName : customerMap.keySet()) {
            if (customerMap.get(fieldApiName).get('KTQB__Field_API_Name__c') != null) {
                Object fieldValue = getFieldFromCustomerData(fieldApiName, customerData, customerResponseMap);

                if (customerData.PersonalInfo.CurrencyCode != '' && customerData.PersonalInfo.CurrencyCode != null) {
                    if(Utils.getIsMultiCurrencyOrg()) {
                        customerRecord.put('CurrencyIsoCode', customerData.PersonalInfo.CurrencyCode);
                    }
                }

                if (fieldValue != null && !String.isBlank(String.valueOf(fieldValue))) {
                    String targetFieldApiName = (String)customerMap.get(fieldApiName).get('KTQB__Field_API_Name__c');
                    Schema.SObjectField targetField = fieldsMap.get(targetFieldApiName);
                    // Get the field's describe result
                    Schema.DescribeFieldResult fieldDescribe = targetField.getDescribe();

                    // Check the field type and convert the value accordingly
                    if (fieldDescribe.getType() == Schema.DisplayType.Integer) {
                        customerRecord.put(targetFieldApiName, Integer.valueOf(String.valueOf(fieldValue)));
                    } else if (fieldDescribe.getType() == Schema.DisplayType.Double || fieldDescribe.getType() == Schema.DisplayType.Currency) {
                        customerRecord.put(targetFieldApiName, Decimal.valueOf(String.valueOf(fieldValue)));
                    } else if (fieldDescribe.getType() == Schema.DisplayType.String) {
                        customerRecord.put(targetFieldApiName, String.valueOf(fieldValue));
                    } else {
                        // Handle other types if necessary
                        customerRecord.put(targetFieldApiName, fieldValue);
                    }
                }
            }
        }
        return customerRecord;
    }
}