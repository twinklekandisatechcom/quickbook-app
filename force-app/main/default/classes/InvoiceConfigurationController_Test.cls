/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : [invoiceConfigurationCmp], [generateInvoiceCustomerCreationForm], [generateInvoiceForm] & [qBCustomerSync]
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
@isTest
public with sharing class InvoiceConfigurationController_Test {
	/**
     * @description Test data setup
    */
    @TestSetup
    public static void createData(){
        KTQB__InvoiceConfigurationOptions__c iconfig = new KTQB__InvoiceConfigurationOptions__c();
        iconfig.KTQB__Create_Update_Qb_Payment_In_Sf__c = true;
        iconfig.KTQB__Income_Account__c = '';
        iconfig.KTQB__Invoice_Date__c = '';
        iconfig.KTQB__Invoice_Due_Date__c = '';
        iconfig.KTQB__Invoice_Save__c = true;
        iconfig.KTQB__Invoice_Save_and_Send__c = true;
        iconfig.KTQB__Tax__c = '';
        iconfig.KTQB__Terms__c = '';
        iconfig.KTQB__Invoice_Customer_ChildObject_Api_Name__c = 'Contact';
        insert iconfig;
        
        List<KTQB__Customer_Object_Field_Mapping__c> cObjFM = new List<KTQB__Customer_Object_Field_Mapping__c>();
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'GivenName ', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'FirstName', KTQB__Field_Value__c = 'GivenName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping PostalCode', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'OtherCountry', KTQB__Field_Value__c = 'Shipping PostalCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Country', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'OtherPostalCode', KTQB__Field_Value__c = 'Shipping Country'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping City', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'OtherCity', KTQB__Field_Value__c = 'Shipping City'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Line', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MailingStreet', KTQB__Field_Value__c = 'Billing Line'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing City', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MailingCity', KTQB__Field_Value__c = 'Billing City'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Line', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'OtherStreet', KTQB__Field_Value__c = 'Shipping Line'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Country Sub DivisionCode', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MailingCountry', KTQB__Field_Value__c = 'Billing Country Sub DivisionCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing PostalCode', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MailingPostalCode', KTQB__Field_Value__c = 'Billing PostalCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Country', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MailingState', KTQB__Field_Value__c = 'Billing Country'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Country Sub DivisionCode   ', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'OtherCountry', KTQB__Field_Value__c = 'Shipping Country Sub DivisionCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Company Name', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'QB_Company_Name__c', KTQB__Field_Value__c = 'Company Name'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Fax', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Fax', KTQB__Field_Value__c = 'Fax'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Mobile', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'MobilePhone', KTQB__Field_Value__c = 'Mobile'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Address', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Shipping Address'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Email', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Email', KTQB__Field_Value__c = 'Email'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'MiddleName', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'MiddleName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'FamilyName', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'LastName', KTQB__Field_Value__c = 'FamilyName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Display Name', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Display Name'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Website', KTQB__Data_Type__c = 'Url', KTQB__Field_API_Name__c = 'Website__c', KTQB__Field_Value__c = 'Website'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Phone', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Phone', KTQB__Field_Value__c = 'Phone'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Qb Customer Sync Token', KTQB__Data_Type__c = 'Double', KTQB__Field_API_Name__c = 'QB_SyncToken__c', KTQB__Field_Value__c = 'Qb Customer Sync Token'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Customer QB Id', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Customer_QB_Id__c', KTQB__Field_Value__c = 'Customer QB Id', KTQB__QuickBook_Field_API_Name__c = 'CustomerQBId'));
        insert cObjFM;
        
        // Create common test opportunity
        Opportunity testOpp = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', CloseDate = Date.today().addMonths(1), Amount = 10000.00);
        insert testOpp;
    }
    
    /**
     * @description Test class for getInvoiceConfiguration()
    */
    @isTest
    public static void getInvoiceConfiguration_Test(){
        test.startTest();
        InvoiceConfigurationController.InvoiceConfigWrapper ii = InvoiceConfigurationController.getInvoiceConfiguration();
        test.stopTest();
        system.assertNotEquals(null,ii,'success');
    }
    /**
     * @description Test class for getCustomerFieldsNConfiguration()
    */
	@isTest
    public static void getCustomerFieldsNConfiguration_Test(){
        test.startTest();
        InvoiceConfigurationController.InvoiceObjectWrapper ii = InvoiceConfigurationController.getCustomerFieldsNConfiguration('Opportunity');
        test.stopTest();
        system.assertNotEquals(null,ii,'success');
    }
    /**
     * @description Test class for saveObjectConfiguration()
    */
    @isTest
    public static void saveObjectConfiguration_Test(){
        List<InvoiceConfigurationController.ObjectInfo> objInfoList = new List<InvoiceConfigurationController.ObjectInfo>();
        test.startTest();
        Boolean result = InvoiceConfigurationController.saveObjectConfiguration(objInfoList,'Customer');
        test.stopTest();
        system.assertNotEquals(null,result,'success');
    }
    /**
     * @description Test class for getInvoiceFields()
    */
    @isTest
    public static void getInvoiceFields_Test(){
        //List<InvoiceConfigurationController.ObjectInfo> objInfoList = new List<InvoiceConfigurationController.ObjectInfo>();
        test.startTest();
        InvoiceConfigurationController.InvoiceObjectWrapper ii = InvoiceConfigurationController.getInvoiceFields('Contact','Invoice');
        InvoiceConfigurationController.InvoiceObjectWrapper iii = InvoiceConfigurationController.getInvoiceFields('Contact','Payment');
        InvoiceConfigurationController.InvoiceObjectWrapper iiii = InvoiceConfigurationController.getInvoiceFields('Contact','LineItem');
        InvoiceConfigurationController.InvoiceObjectWrapper iiiii = InvoiceConfigurationController.getInvoiceFields('Contact','Customer');
        test.stopTest();
        system.assertNotEquals(null,ii,'success');
        system.assertNotEquals(null,iii,'success');
        system.assertNotEquals(null,iiii,'success');
        system.assertNotEquals(null,iiiii,'success');
    }
    /**
     * @description Test class for getObjectList()
    */
    @isTest
    public static void getObjectList_Test(){
        test.startTest();
        List<InvoiceConfigurationController.ObjectInfo> objInfoList = InvoiceConfigurationController.getObjectList();
        test.stopTest();
        system.assertNotEquals(null,objInfoList,'success');
    }
    /**
     * @description Test class for getCurrency()
    */
    @isTest
    public static void getCurrency_Test(){
        test.startTest();
        List<String> result = InvoiceConfigurationController.getCurrency();
        test.stopTest();
        system.assertNotEquals(null,result,'success');
    }
    /**
     * @description Test class for updateInvoiceConfig()
    */
    @isTest
    public static void updateInvoiceConfig_Test(){
        test.startTest();
        Boolean result = InvoiceConfigurationController.updateInvoiceConfig('configData', 'invoiceObject', 'lineItemObject', 'lineItemChildObjectName', 'customerItemChildObjectName', 'paymentObject', 'paymentChildObjectName');
        test.stopTest();
        system.assertNotEquals(null,result,'success');
    }
    /**
     * @description Test class for getOpportunity()
    */
    @isTest
    public static void getOpportunity_Test(){
        List<String> strList = new List<String>();
        List<Opportunity> oppList = [ SELECT Id 
                                      FROM Opportunity 
                                   	  Where Name = 'TestOpp'];
        test.startTest();
        Opportunity result = InvoiceConfigurationController.getOpportunity(strList, oppList[0].Id);
        string res = InvoiceConfigurationController.getSiteProfileId();
        test.stopTest();
        system.assertNotEquals(null,res,'success');
        system.assertNotEquals(null,result,'success');
    }
}