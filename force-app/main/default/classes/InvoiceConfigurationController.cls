/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : [invoiceConfigurationCmp], [generateInvoiceCustomerCreationForm], [generateInvoiceForm] & [qBCustomerSync]
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
/*
NOTE ::: 
	1. commented Product_Configuration_Options__c custom setting by twinkle on 25th-01 as we are not using this.
*/
public with sharing class InvoiceConfigurationController {

    /**
     * @description Invoice and Configuration Component : For data from record in Quickbook_Info__c.
     * @param customerObjectName - From ui (any)
     * @return Object Data
     */
    @AuraEnabled public static InvoiceObjectWrapper getCustomerFieldsNConfiguration(string customerObjectName){
        InvoiceObjectWrapper customerWrp = new InvoiceObjectWrapper();
        try{
            list<Picklistwrapper> objectFields = getFieldMap(customerObjectName);
            List<ObjectInfo> labelValueList = new List<ObjectInfo>();
            String query = 'SELECT Id, Name, Field_API_Name__c,Required__c , Field_Value__c, Data_Type__c,QuickBook_Field_Api_Name__c,Read_Only__c,Sequence_Number__c FROM Customer_Object_Field_Mapping__c ORDER BY Sequence_Number__c';
            Map<String, Object> bindValues = new Map<String, Object> {};
            List<SObject> objectField = Database.queryWithBinds(
                String.escapeSingleQuotes(query),
                bindValues,
                AccessLevel.USER_MODE
            );
            for (SObject obj : objectField) {
                ObjectInfo objInfo = new ObjectInfo();
                objInfo.name = (String) obj.get('Name');
                objInfo.label = (String) obj.get('Field_Value__c');
                objInfo.value = (String) obj.get('Field_API_Name__c');
                objInfo.type = (String) obj.get('Data_Type__c');
                objInfo.qbFieldName = (String) obj.get('QuickBook_Field_Api_Name__c');
                Object requiredValue = obj.get('Required__c');
                if (requiredValue instanceof Boolean) {
                    objInfo.require = (Boolean) requiredValue;
                }
                Object readOnlyValue = obj.get('Read_Only__c');
                if (readOnlyValue instanceof Boolean) {
                    objInfo.readOnly = (Boolean) readOnlyValue;
                }
                labelValueList.add(objInfo);
    		}
            customerWrp.Objectfields = objectFields;
            customerWrp.invoiceField = labelValueList;
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return customerWrp;
    }

    /**
     * @description Invoice and Configuration Component : To save ui data to custom setting.
     * @param objectFields - Default object from custom setting
     * @param objectType - Invoice/LineItem/Payment/Customer
     * @return Boolean
     */
    @AuraEnabled public static boolean saveObjectConfiguration(List<ObjectInfo> objectFields, string objectType){
        boolean updated = false;
        try{
            List<sObject> objectConfigurationListToUpdate = new List<sObject>();
            List<sObject> existingSettings = new list<sObject>();
            string objectName = '';
            if(objectType=='Invoice'){
                existingSettings = Invoice_Object_Field_Mapping__c.getAll().values();
                objectName = 'KTQB__Invoice_Object_Field_Mapping__c';
            }else if(objectType == 'LineItem'){
                existingSettings = LineItem_Object_Field_Mapping__c.getAll().values();
                objectName = 'KTQB__LineItem_Object_Field_Mapping__c';
            }else if(objectType == 'Payment'){
                existingSettings = Payment_Object_Field_Mapping__c.getAll().values();
                objectName = 'KTQB__Payment_Object_Field_Mapping__c';
            }else if(objectType == 'Customer'){
                existingSettings = Customer_Object_Field_Mapping__c.getAll().values();
                objectName = 'KTQB__Customer_Object_Field_Mapping__c';
            }
            for(ObjectInfo fieldName : objectFields){
                for (sObject setting : existingSettings) {
                    if (setting.get('name') == fieldName.Name) {
                        setting.put('Field_API_Name__c', fieldName.value);
                        objectConfigurationListToUpdate.add(setting);
                    }
                }
            }

            if(objectConfigurationListToUpdate.size() > 0){
                if( Schema.getGlobalDescribe().get(objectName).getDescribe().isUpdateable()){
                    update as system objectConfigurationListToUpdate;
                    updated = true;
                    /*List<Database.SaveResult> sR = Database.update(objectConfigurationListToUpdate,AccessLevel.User_mode);
                    for (Database.SaveResult saveResult : sR) {
                        if (saveResult.isSuccess()) {
                            updated = true;
                        }
                    }*/
                }
                
            }
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return updated;
    }

    /**
     * @description Invoice and Configuration Component : .
     * @param objectApiName - Default object from custom setting.
     * @param type - Invoice/LineItem/Payment/Customer.
     * @return Object Data
     */
    @AuraEnabled public static InvoiceObjectWrapper getInvoiceFields(string objectApiName, string type){
        InvoiceObjectWrapper invoiceObjectWrap =  new InvoiceObjectWrapper();
        try{
            list<Picklistwrapper> objectFields = getFieldMap(objectApiName);
            Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
            List<ObjectInfo> childObjectInfos = new List<ObjectInfo>();
            
            for (Schema.ChildRelationship cr : objDescribe.getChildRelationships()) {
                Schema.DescribeSObjectResult childObjDescribe = cr.getChildSObject().getDescribe();
                if (childObjDescribe.isCreateable()) {
                    ObjectInfo objectInfo = new ObjectInfo();
                    objectInfo.value = String.valueOf(cr.getChildSObject());
                    objectInfo.label =  String.valueOf(cr.getChildSObject().getDescribe().getLabel());
                    objectInfo.name = String.valueOf(cr.getRelationshipName());
                    childObjectInfos.add(objectInfo);
                }            
            }
            List<ObjectInfo> labelValueList = new List<ObjectInfo>();
            String query = 'SELECT Id, Name, Field_API_Name__c,Required__c, Field_Value__c, Data_Type__c,Read_Only__c,Help_Text__c,Sequence_Number__c FROM ';
            if (type == 'Invoice') {
                query += 'Invoice_Object_Field_Mapping__c';
            } else if (type == 'Payment') {
                query += 'Payment_Object_Field_Mapping__c';
            } else if (type == 'LineItem') {
                query += 'LineItem_Object_Field_Mapping__c';
            }  else if (type == 'Customer') {
                query += 'Customer_Object_Field_Mapping__c';
            } 
            query += ' ORDER BY Sequence_Number__c';
            Map<String, Object> bindValues = new Map<String, Object> {};
            List<SObject> objectField = Database.queryWithBinds(
                String.escapeSingleQuotes(query),
                bindValues,
                AccessLevel.USER_MODE
            );
            for (SObject obj : objectField) {
                ObjectInfo objInfo = new ObjectInfo();
                objInfo.name = (String) obj.get('Name');
                objInfo.label = (String) obj.get('Field_Value__c');
                objInfo.value = (String) obj.get('Field_API_Name__c');
                objInfo.helpText = (String) obj.get('Help_Text__c');
                objInfo.type = (String) obj.get('Data_Type__c');
                Object requiredValue = obj.get('Required__c');
                if (requiredValue instanceof Boolean) {
                    objInfo.require = (Boolean) requiredValue;
                } 
                Object readOnlyValue = obj.get('Read_Only__c');
                if (readOnlyValue instanceof Boolean) {
                    objInfo.readOnly = (Boolean) readOnlyValue;
                } 
                labelValueList.add(objInfo);
    		}
            invoiceObjectWrap.Objectfields = objectFields;
            invoiceObjectWrap.childObject = childObjectInfos;
            invoiceObjectWrap.invoiceField = labelValueList;
        }catch(Exception e){
            HandleCustomException.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        return invoiceObjectWrap;
    }

    /**
     * @description Invoice and Configuration Component : To set object list.
     * @return Object info
     */
    @AuraEnabled(cacheable=true) public static List<ObjectInfo> getObjectList() {
        List<ObjectInfo> objectInfos = new List<ObjectInfo>();
        for (Schema.SObjectType objectType : Schema.getGlobalDescribe().values()) {
            if(((Schema.DescribeSObjectResult)objectType.getDescribe()).isCreateable() == true && !((Schema.DescribeSObjectResult)objectType.getDescribe()).isCustomSetting()){
                ObjectInfo objectInfo = new ObjectInfo();
                objectInfo.value = String.valueOf(objectType);
                objectInfo.label = ((Schema.DescribeSObjectResult)objectType.getDescribe()).getLabel();
                objectInfos.add(objectInfo);
            }
        }
        return objectInfos;
    }

    /**
     * @description 
     * @return List of Currencies
     */
    @AuraEnabled public static List<String> getCurrency(){
        list<String> currencyIsoCodeList = new List<String>();
        try {
            if(Utils.getIsMultiCurrencyOrg()){
                list<CurrencyType> salesforceCurrList = new List<CurrencyType>([SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate, CreatedDate FROM CurrencyType WHERE IsActive = true ORDER BY CreatedDate DESC]);
                for(CurrencyType obj : salesforceCurrList){
                    currencyIsoCodeList.add(obj.IsoCode);
                }
            }else{
                String curr = UserInfo.getDefaultCurrency();
                currencyIsoCodeList.add(curr);
            }
            
        } catch (Exception e) {
            HandleCustomException.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        return currencyIsoCodeList;
    }

    /**
     * @description
     * @return
     */
    /*@AuraEnabled public static QBConWrapper getProductConfiguration(){
         QBConWrapper xcw = new QBConWrapper();
        try {
            Product_Configuration_Options__c xconfig = new Product_Configuration_Options__c(); 
            xconfig = [SELECT Id, Create_Item_in_Quickbooks__c, Create_Product_in_Salesforce__c FROM Product_Configuration_Options__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            xcw.id = xconfig.Id;
            //Product Configuration fields
            xcw.createItemInSF = xconfig.Create_Product_in_Salesforce__c;
            xcw.createItemInQB = xconfig.Create_Item_in_Quickbooks__c;
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return xcw;
    }*/

    /**
     * @description
     * @param configData -
     * @return Boolean
     */
    /*@AuraEnabled public static Boolean updateProductConfig(String configData){
        boolean updated = false;
        try{
            QBConWrapper cWrap = new QBConWrapper();
            if(String.isNotBlank(configData)){
                cWrap = (QBConWrapper)JSON.deserialize(configData,QBConWrapper.class);
                Product_Configuration_Options__c config = new Product_Configuration_Options__c();
                config.Id = cWrap.id;
                config.Create_Item_in_Quickbooks__c = cWrap.createItemInQB;
                config.Create_Product_in_Salesforce__c = cWrap.createItemInSF;
                Database.SaveResult sR = Database.update(config,AccessLevel.User_mode);
                updated = sR.isSuccess();
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return updated;
    }*/

    

    /**
     * @description Invoice and Configuration Component : To retrive data from Custom Setting.
     * @return Custom setting fields and data.
     */
    @AuraEnabled public static InvoiceConfigWrapper getInvoiceConfiguration(){
        InvoiceConfigWrapper icw = new InvoiceConfigWrapper();
        try{
            InvoiceConfigurationOptions__c config = [ SELECT Id, Name, Create_Update_Qb_Payment_In_Sf__c, SetupOwnerId, Invoice_Save__c, Invoice_Save_and_Send__c, Invoice_Date__c, Invoice_Due_Date__c, 
                                                      Income_Account__c, Terms__c, Tax__c,Payment_Object_Name__c,LineItem_Object_Name__c,Invoice_Customer_ChildObject_Api_Name__c, Invoice_Object_Name__c 
                                                      ,Create_opportunity_product_as_QB_Item__c , Enable_Opportunity_Product__c 
                                                      FROM InvoiceConfigurationOptions__c 
                                                      WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            icw.Id = config.Id;
            icw.Save = config.Invoice_Save__c;
            icw.Save_And_Send = config.Invoice_Save_and_Send__c;
            icw.Create_Update_Qb_Payment_In_Sf = config.Create_Update_Qb_Payment_In_Sf__c;
            //INVOICE FIELDS FROM CUSTOM SETTINGS
            icw.Invoice_Date = config.Invoice_Date__c != null ? config.Invoice_Date__c : '';
            icw.Invoice_Due_Date = config.Invoice_Due_Date__c != null ? config.Invoice_Due_Date__c : '';
            icw.Invoice_Object = config.Invoice_Object_Name__c;
            icw.LineItem_Object = config.LineItem_Object_Name__c;
            icw.Payment_Object = config.Payment_Object_Name__c;
            icw.Customer_Object = config.Invoice_Customer_ChildObject_Api_Name__c;
			icw.CreateOpportunityProduct = config.Create_opportunity_product_as_QB_Item__c;
            icw.EnableOpportunityProduct = config.Enable_Opportunity_Product__c;
            // OPPORTUNITY FIELDS API NAME AND LABEL MAP
            icw.opportunityFieldMap = getFieldMap('Opportunity');
            
            icw.Income_Account = config.Income_Account__c; 
            icw.Terms = config.Terms__c; 
            icw.Tax = config.Tax__c; 
            icw.oppTerms = getFieldOption('Term');
            icw.oppAccount = getFieldOption('Account');
            icw.salesTax = getFieldOption('salesTax');

        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return icw;
    }

    /**
     * @description From getInvoiceConfiguration, getCustomerFieldsNConfiguration() & getInvoiceFields methods.
     * @param sObjectType - From ui (any)
     * @return List<Picklistwrapper>
     */
    @AuraEnabled public static List<Picklistwrapper> getFieldMap(String sObjectType) {
        List<Picklistwrapper> options = new List<Picklistwrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType targetType = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()){
            Schema.SObjectField field = fieldMap.get(fieldName);
            String apiName = fieldMap.get(fieldName).getDescribe().getName();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            string referencedObjectApiName='';
            if(String.isNotBlank(apiName) && field.getDescribe().isUpdateable() || String.ValueOF(fieldMap.get(fieldName).getDescribe().getType()) == 'ADDRESS'){
                String fieldType = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
                //string fieldLabel = String.ValueOF(fieldMap.get(fieldName).getDescribe().getLabel());
                if(fieldType == 'REFERENCE'){
                    Schema.SObjectType referenceObjectType = fieldMap.get(fieldName).getDescribe().getReferenceTo()[0];
            		referencedObjectApiName = referenceObjectType.getDescribe().getName();
                    if(String.ValueOF(fieldDescribe.getReferenceTo()) == '(KTQB__QB_MetaData__c)'){
                        fieldType += fieldDescribe.getReferenceTo();
                    }
                }
                options.add(new Picklistwrapper(String.ValueOF(fieldMap.get(fieldName).getDescribe().getLabel()), apiName, 
                                               fieldType, field.getDescribe().isNillable(), referencedObjectApiName));
            }
        }
        return options;
    }

    /**
     * @description Invoice and Configuration Component : For data from record in Quickbook_Info__c.
     * @param configData - Fields data & Object names to save in custom setting
     * @param invoiceObject - Fields data & Object names to save in custom setting
     * @param lineItemObject - Fields data & Object names to save in custom setting
     * @param lineItemChildObjectName - Fields data & Object names to save in custom setting
     * @param customerItemChildObjectName - Fields data & Object names to save in custom setting
     * @param paymentObject - Fields data & Object names to save in custom setting
     * @param paymentChildObjectName - Fields data & Object names to save in custom setting
     * @return Object Data
     */
    @AuraEnabled public static Boolean updateInvoiceConfig(String configData, string invoiceObject, string lineItemObject, string lineItemChildObjectName,
                                              string customerItemChildObjectName, string paymentObject, string paymentChildObjectName){
        boolean updated = false;
        InvoiceConfigWrapper icWrap = new InvoiceConfigWrapper();
        try {
            if(String.isNotBlank(configData)){
                icWrap = (InvoiceConfigWrapper)JSON.deserialize(configData,InvoiceConfigWrapper.class);
                
                InvoiceConfigurationOptions__c config = new InvoiceConfigurationOptions__c();
                config.Id = icWrap.Id;
                config.Invoice_Save__c = icWrap.Save;
                config.Invoice_Save_and_Send__c = icWrap.Save_And_Send;
                
                config.Invoice_Due_Date__c = icWrap.Invoice_Due_Date;
                config.Invoice_Date__c = icWrap.Invoice_Date;
                
                config.Income_Account__c = icWrap.Income_Account;
                config.Terms__c = icWrap.Terms;
                config.Tax__c = icWrap.Tax;
                config.Create_Update_Qb_Payment_In_Sf__c = icWrap.Create_Update_Qb_Payment_In_Sf;
                config.Enable_Opportunity_Product__c = icWrap.EnableOpportunityProduct;
                config.Create_opportunity_product_as_QB_Item__c = icWrap.CreateOpportunityProduct;
                
                if(invoiceObject != ''){
                    config.Invoice_Object_Name__c = invoiceObject;
                }
            	config.LineItem_Object_Name__c = lineItemObject;
            	config.Payment_Object_Name__c = paymentObject;
                config.LineItem_ChildObject_Name__c =lineItemChildObjectName;
                config.Invoice_Customer_ChildObject_Api_Name__c =customerItemChildObjectName;
                
                update as user config;
                updated = true;
                //Database.SaveResult sR = Database.update(config,AccessLevel.User_mode);
                //updated = sR.isSuccess();
            }
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return updated;
    }

    /**
     * @description Invoice and Configuration Component : For data from record in Quickbook_Info__c.
     * @param setupFields - From ui (any)
     * @param recordId - For id
     * @return Object Data
     */
    @AuraEnabled public static Opportunity getOpportunity(List<String> setupFields, String recordId){
        Opportunity opp = new Opportunity();
        List<String> fieldsList = new List<String>(new Set<String>(setupFields)); 
        if(fieldsList.size() == 0){
            fieldsList.add('Id');
        }else if(fieldsList.size() > 0 && !fieldsList.contains('Id')){
            fieldsList.add('Id');
        }
        
        try{
            Map<String, Object> bindValues = new Map<String, Object>{'recordId1' => recordId};
            String query  = 'SELECT '+String.join( fieldsList, ', ' );
            query += ' FROM Opportunity WHERE Id=: recordId1';
            opp = Database.queryWithBinds(
                String.escapeSingleQuotes(query),
                bindValues,
                AccessLevel.USER_MODE
            );
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return opp;
    }

    /**
     * @description Invoice and Configuration Component : To set picklist by records in QB_MetaData__c.
     * @param type - Invoice/LineItem/Payment/Customer
     * @return Object List
     */
    @AuraEnabled public static List<QB_MetaData__c> getFieldOption(string type){
        List<QB_MetaData__c> options = new List<QB_MetaData__c>();
        try{
            options = [Select Id, Name, Type__c, Active__c,Sales_Tax_Rate__c ,QB_Id__c From QB_MetaData__c where Type__c =:type and Active__c =true WITH USER_MODE order by Name Asc];
        }
        catch(Exception e){
            HandleCustomException.logException(e);
        }
        return options;
    }
	 /**
     * @description Invoice and Configuration Component : To get Site Profile id.
     * @return profile name and profile id of user
     */
    @AuraEnabled public static string getSiteProfileId(){
        string result = '';
        list<Quickbook_Info__c> qi = [ SELECT Id, Name, Client_ID__c , Client_Secret__c, Redirect_URL__c, Access_Token__c, Refresh_Token__c, Sandbox_Url__c
                   ,Progress_Value__c, Completed_Steps__c, Total_Connection_Steps__c,SyncSite__c,Webhook_Key__c FROM Quickbook_Info__c
                   WITH USER_MODE
                   LIMIT 1 ];
        if(qi.size() > 0 && qi[0].SyncSite__c != '' && qi[0].SyncSite__c != null){
            string syncSite = Utils.processDecryption(qi[0].SyncSite__c);
            if(syncSite != '' && syncSite != null){
                List<Site> siteList = [ SELECT Id, Name, Status, SiteType, GuestUserId, MasterLabel, GuestUser.Profile.name,GuestUser.Profile.id 
                         FROM Site 
                         WHERE Id = :syncSite
                         WITH USER_MODE];
                if(siteList.size() > 0){
                    result = 'profileName=' + siteList[0].GuestUser.Profile.name + '&profileId=' + siteList[0].GuestUser.Profile.id;
                }
            }
             
        }
        return result;
    }
    /** @description Invoice and Configuration Component : Wrapper Class. */
    public class InvoiceObjectWrapper{
        /** @description Invoice and Configuration Component : For childObject. */
        @AuraEnabled public list<ObjectInfo> childObject;
        /** @description Invoice and Configuration Component : For Objectfields. */
        @AuraEnabled public list<Picklistwrapper> Objectfields;
        /** @description Invoice and Configuration Component : For invoiceField. */
        @AuraEnabled public list<ObjectInfo> invoiceField;
    }

    /** @description Invoice and Configuration Component : Wrapper Class. */
    public class InvoiceConfigWrapper{
        /** @description Invoice and Configuration Component : For Id. */
        @AuraEnabled public String Id;
        /** @description Invoice and Configuration Component : For Save. */
        @AuraEnabled public boolean Save;
        /** @description Invoice and Configuration Component : For Save_And_Send. */
        @AuraEnabled public boolean Save_And_Send;
        /** @description Invoice and Configuration Component : For Create_Update_Qb_Payment_In_Sf. */
        @AuraEnabled public boolean Create_Update_Qb_Payment_In_Sf;

        //INVOICE FIELDS FROM THE OPPORTUNITY
        /** @description Invoice and Configuration Component : For Invoice_Due_Date. */
        @AuraEnabled public String Invoice_Due_Date;
        /** @description Invoice and Configuration Component : For Invoice_Date. */
        @AuraEnabled public String Invoice_Date;
        /** @description Invoice and Configuration Component : For opportunityFieldMap. */
        @AuraEnabled public List<Picklistwrapper> opportunityFieldMap;
        /** @description Invoice and Configuration Component : For Invoice_Object. */
        @AuraEnabled public String Invoice_Object;
        /** @description Invoice and Configuration Component : For LineItem_Object. */
        @AuraEnabled public String LineItem_Object;
        /** @description Invoice and Configuration Component : For Payment_Object. */
        @AuraEnabled public String Payment_Object;
        /** @description Invoice and Configuration Component : For Customer_Object. */
        @AuraEnabled public String Customer_Object;

        /** @description Invoice and Configuration Component : For oppTerms. */
        @AuraEnabled public List<QB_MetaData__c> oppTerms;
        /** @description Invoice and Configuration Component : For oppAccount. */
        @AuraEnabled public List<QB_MetaData__c> oppAccount;
        /** @description Invoice and Configuration Component : For salesTax. */
        @AuraEnabled public List<QB_MetaData__c> salesTax;

        /** @description Invoice and Configuration Component : For Income_Account. */
        @AuraEnabled public String Income_Account;
        /** @description Invoice and Configuration Component : For Terms. */
        @AuraEnabled public String Terms;
        /** @description Invoice and Configuration Component : For Tax. */
        @AuraEnabled public String Tax;
        /** @description Invoice and Configuration Component : For CreateOpportunityProduct. */
        @AuraEnabled public Boolean CreateOpportunityProduct;
        /** @description Invoice and Configuration Component : For EnableOpportunityProduct. */
        @AuraEnabled public Boolean EnableOpportunityProduct;
    }

    /*public class GetValuesWrapper{
        //INVOICE FIELDS FROM THE OPPORTUNITY
        @AuraEnabled public String Invoice_Due_Date;
        @AuraEnabled public String Invoice_Date;
        @AuraEnabled public Date Final_Invoice_Date;
        @AuraEnabled public Date Final_Invoice_Due_Date;  
    }*/

    /** @description Invoice and Configuration Component : Wrapper Class. */
    public class Picklistwrapper {
        /** @description Invoice and Configuration Component : For label. */
        @AuraEnabled public String label { get; set; }
        /** @description Invoice and Configuration Component : For value. */
        @AuraEnabled public String value { get; set; }
        /** @description Invoice and Configuration Component : For fieldType. */
        @AuraEnabled public String fieldType { get; set; }
        /** @description Invoice and Configuration Component : For required. */
        @AuraEnabled public boolean required { get; set; }
        /** @description Invoice and Configuration Component : For referencedObjectApiName. */
        @AuraEnabled public String  referencedObjectApiName{ get; set; }
        
        /**
         * @description Invoice and Configuration Component : Constructor for direct access.
         * @param label
         * @param value
         * @param fieldType
         * @param required
         * @param referencedObjectApiName
         */
        public Picklistwrapper(String label, String value, String fieldType, boolean required, string referencedObjectApiName) {
            this.label = label;
            this.value = value;
            this.fieldType = fieldType;
            this.required = required;
            this.referencedObjectApiName = referencedObjectApiName;
        }
    }
    
    /** @description Invoice and Configuration Component : Wrapper Class. */
    public class QBConWrapper{
        /** @description Invoice and Configuration Component : For referencedObjectApiName. */
        @AuraEnabled public String Id;
        //Contact Configuration fields
        /** @description Invoice and Configuration Component : For firstName. */
        @AuraEnabled public String firstName;
        /** @description Invoice and Configuration Component : For lastName. */
        @AuraEnabled public String lastName;
        /** @description Invoice and Configuration Component : For email. */
        @AuraEnabled public String email;
        /** @description Invoice and Configuration Component : For phone. */
        @AuraEnabled public String phone;
        /** @description Invoice and Configuration Component : For mobile. */
        @AuraEnabled public String mobile;
        /** @description Invoice and Configuration Component : For fax. */
        @AuraEnabled public String fax;
        /** @description Invoice and Configuration Component : For website. */
        @AuraEnabled public String website;
        /** @description Invoice and Configuration Component : For billingAddress. */
        @AuraEnabled public String billingAddress;
        /** @description Invoice and Configuration Component : For shippingAddress. */
        @AuraEnabled public String shippingAddress;
        /** @description Invoice and Configuration Component : For createCustomerInSF. */
        @AuraEnabled public boolean createCustomerInSF;
        /** @description Invoice and Configuration Component : For createCustomerInQB. */
        @AuraEnabled public boolean createCustomerInQB;
        /** @description Invoice and Configuration Component : For createItemInSF. */
        @AuraEnabled public boolean createItemInSF;
        /** @description Invoice and Configuration Component : For createItemInQB. */
        @AuraEnabled public boolean createItemInQB;
        
    }

    /** @description Invoice and Configuration Component : Wrapper Class. */
    public class ObjectInfo {
        /** @description Invoice and Configuration Component : For name. */
        @AuraEnabled public String name { get; set; }
        /** @description Invoice and Configuration Component : For value. */
        @AuraEnabled public String value { get; set; }
        /** @description Invoice and Configuration Component : For label. */
        @AuraEnabled public String label { get; set; }
        /** @description Invoice and Configuration Component : For helpText. */
        @AuraEnabled public String helpText { get; set; }
        /** @description Invoice and Configuration Component : For type. */
        @AuraEnabled public String type { get; set; }
        /** @description Invoice and Configuration Component : For require. */
        @AuraEnabled public boolean require { get; set; }
        /** @description Invoice and Configuration Component : For readOnly. */
        @AuraEnabled public boolean readOnly { get; set; }
        /** @description Invoice and Configuration Component : For qbFieldName. */
        @AuraEnabled public string qbFieldName { get; set; }
    }
}