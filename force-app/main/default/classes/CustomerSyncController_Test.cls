@isTest
public class CustomerSyncController_Test {
	@testSetup
    static void setupData() {
        createQuickbookInfo();
        createQBSetting();
        createTestAccount();
        createTestContacts();
        createTestOpportunity();
        createProduct();
        insertInvoiceConfig();
        
        insertLineItemConfig();
        insertCustomerConfig();
        
        
        KTQB__InvoiceConfigurationOptions__c ico = new KTQB__InvoiceConfigurationOptions__c();
        ico.KTQB__Invoice_Customer_ChildObject_Api_Name__c = 'Contact';
        insert ico;
    }
    static void insertCustomerConfig(){
        List<KTQB__Customer_Object_Field_Mapping__c> cObjFM = new List<KTQB__Customer_Object_Field_Mapping__c>();
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'GivenName ', Data_Type__c = 'String', Field_API_Name__c = 'FirstName', Field_Value__c = 'GivenName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping PostalCode', Data_Type__c = 'String', Field_API_Name__c = 'OtherCountry', Field_Value__c = 'Shipping PostalCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Country', Data_Type__c = 'String', Field_API_Name__c = 'OtherPostalCode', Field_Value__c = 'Shipping Country'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping City', Data_Type__c = 'String', Field_API_Name__c = 'OtherCity', Field_Value__c = 'Shipping City'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Line', Data_Type__c = 'String', Field_API_Name__c = 'MailingStreet', Field_Value__c = 'Billing Line'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing City', Data_Type__c = 'String', Field_API_Name__c = 'MailingCity', Field_Value__c = 'Billing City'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Line', Data_Type__c = 'String', Field_API_Name__c = 'OtherStreet', Field_Value__c = 'Shipping Line'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Country Sub DivisionCode', Data_Type__c = 'String', Field_API_Name__c = 'MailingCountry', Field_Value__c = 'Billing Country Sub DivisionCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing PostalCode', Data_Type__c = 'String', Field_API_Name__c = 'MailingPostalCode', Field_Value__c = 'Billing PostalCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Billing Country', Data_Type__c = 'String', Field_API_Name__c = 'MailingState', Field_Value__c = 'Billing Country'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Country Sub DivisionCode   ', Data_Type__c = 'String', Field_API_Name__c = 'OtherCountry', Field_Value__c = 'Shipping Country Sub DivisionCode'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Company Name', Data_Type__c = 'String', Field_API_Name__c = 'QB_Company_Name__c', Field_Value__c = 'Company Name'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Fax', Data_Type__c = 'String', Field_API_Name__c = 'Fax', Field_Value__c = 'Fax'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Mobile', Data_Type__c = 'String', Field_API_Name__c = 'MobilePhone', Field_Value__c = 'Mobile'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Shipping Address', Data_Type__c = 'String', Field_API_Name__c = '', Field_Value__c = 'Shipping Address'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Email', Data_Type__c = 'String', Field_API_Name__c = 'Email', Field_Value__c = 'Email'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'MiddleName', Data_Type__c = 'String', Field_API_Name__c = '', Field_Value__c = 'MiddleName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'FamilyName', Data_Type__c = 'String', Field_API_Name__c = 'LastName', Field_Value__c = 'FamilyName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Display Name', Data_Type__c = 'String', Field_API_Name__c = '', Field_Value__c = 'Display Name'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Website', Data_Type__c = 'Url', Field_API_Name__c = 'Website__c', Field_Value__c = 'Website'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Phone', Data_Type__c = 'String', Field_API_Name__c = 'Phone', Field_Value__c = 'Phone'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Qb Customer Sync Token', Data_Type__c = 'Double', Field_API_Name__c = 'QB_SyncToken__c', Field_Value__c = 'Qb Customer Sync Token'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Customer QB Id', Data_Type__c = 'String', Field_API_Name__c = 'Customer_QB_Id__c', Field_Value__c = 'Customer QB Id', QuickBook_Field_Api_Name__c = 'CustomerQBId'));
        insert cObjFM;
    }
    static void insertLineItemConfig(){
        List<KTQB__LineItem_Object_Field_Mapping__c> liObjFM = new List<KTQB__LineItem_Object_Field_Mapping__c>();
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Description', Data_Type__c = 'String', Field_API_Name__c = 'Description__c', Field_Value__c = 'Description', QuickBook_Field_Api_Name__c = 'Description'));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Name', Data_Type__c = 'String', Field_API_Name__c = 'Name', Field_Value__c = 'Name', QuickBook_Field_Api_Name__c = ''));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Product/Service Ref Name', Data_Type__c = 'String', Field_API_Name__c = 'Line_Item_Name__c', Field_Value__c = 'Product/Service Ref Name', QuickBook_Field_Api_Name__c = ''));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Unit Price', Data_Type__c = 'String', Field_API_Name__c = 'Unit_Price__c', Field_Value__c = 'Unit Price', QuickBook_Field_Api_Name__c = 'UnitPrice'));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Line Item Id', Data_Type__c = 'String', Field_API_Name__c = 'Line_Item_Id__c', Field_Value__c = 'Line Item Id', QuickBook_Field_Api_Name__c = 'LineItemId'));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Quantity', Data_Type__c = 'Double', Field_API_Name__c = 'Quantity__c', Field_Value__c = 'Quantity', QuickBook_Field_Api_Name__c = 'Qty'));
        liObjFM.add(new KTQB__LineItem_Object_Field_Mapping__c(Name = 'Taxable', Data_Type__c = 'String', Field_API_Name__c = '', Field_Value__c = 'Taxable', QuickBook_Field_Api_Name__c = ''));
        insert liObjFM;
    }
    static void insertInvoiceConfig(){
        List<KTQB__Invoice_Object_Field_Mapping__c> iObjFM = new List<KTQB__Invoice_Object_Field_Mapping__c>();
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Billing Address', Data_Type__c = 'String', Field_API_Name__c = 'BillAddr__c', Field_Value__c = 'Billing Address', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Balance', Data_Type__c = 'String', Field_API_Name__c = 'Balance__c', Field_Value__c = 'Balance', QuickBook_Field_Api_Name__c = 'Balance', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Shipping Address', Data_Type__c = 'String', Field_API_Name__c = 'Tax_Percent__c', Field_Value__c = 'Shipping Address', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Tax Rate', Data_Type__c = 'String', Field_API_Name__c = 'BillAddr__c', Field_Value__c = 'Tax Rate', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Date', Data_Type__c = 'Date', Field_API_Name__c = 'Invoice_Date__c', Field_Value__c = 'Invoice Date', QuickBook_Field_Api_Name__c = 'TxnDate', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'BillEmail', Data_Type__c = 'String', Field_API_Name__c = 'BillEmail__c', Field_Value__c = 'BillEmail', QuickBook_Field_Api_Name__c = 'BillEmail', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Transaction Date', Data_Type__c = 'Date', Field_API_Name__c = 'Invoice_Date__c', Field_Value__c = 'Transaction Date', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Total Amount', Data_Type__c = 'Double', Field_API_Name__c = 'Total_Amount__c', Field_Value__c = 'Total Amount', QuickBook_Field_Api_Name__c = 'TotalAmt', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice State', Data_Type__c = 'String', Field_API_Name__c = 'Invoice_State__c', Field_Value__c = 'Invoice State', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'QB Customer', Data_Type__c = '', Field_API_Name__c = 'Contact__c', Field_Value__c = 'QB Customer', QuickBook_Field_Api_Name__c = 'QBCustomerRef', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Qb Invoice Sync Token', Data_Type__c = 'Double', Field_API_Name__c = 'Qb_Invoice_Sync_Token__c', Field_Value__c = 'Qb Invoice Sync Token', QuickBook_Field_Api_Name__c = 'SyncToken', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Number', Data_Type__c = 'String', Field_API_Name__c = 'Name', Field_Value__c = 'Invoice Number', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Status', Data_Type__c = 'String', Field_API_Name__c = 'Invoice_Status__c', Field_Value__c = '    Invoice Status', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'TotalTax', Data_Type__c = 'Double', Field_API_Name__c = 'TotalTax__c', Field_Value__c = 'TotalTax', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Discount Amount', Data_Type__c = 'Currency', Field_API_Name__c = 'Discount_Amount__c', Field_Value__c = 'Discount Amount', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Terms', Data_Type__c = 'String', Field_API_Name__c = 'Sales_Term__c', Field_Value__c = 'Terms', QuickBook_Field_Api_Name__c = '', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Due Date', Data_Type__c = 'Date', Field_API_Name__c = 'Due_Date__c', Field_Value__c = 'Due Date', QuickBook_Field_Api_Name__c = 'DueDate', Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Qb Id', Data_Type__c = 'String', Field_API_Name__c = 'Invoice_Qb_Id__c', Field_Value__c = 'Invoice Qb Id', QuickBook_Field_Api_Name__c = 'Id', Required__c = false));
        insert iObjFM;
    }
    static KTQB__Quickbook_Info__c createQuickbookInfo() {
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c(
            Name = 'QB-0001',
            KTQB__Client_ID__c = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt',
            KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe',
            KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/',
            KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage',
            KTQB__QB_Company_Id__c = '4620816365289262850'
        );
        insert qbInfo;
        return qbInfo;
    }
    static KTQB__QB_Setting__c createQBSetting() {
        KTQB__QB_Setting__c qs = new KTQB__QB_Setting__c(KTQB__QB_version__c = 64);
        upsert qs;
        return qs;
    }
    static void createTestAccount() {
        Account testAccount = new Account(
            Name = 'TestAcc',
            BillingCity = 'Test City',
            BillingCountry = 'Test Country',
            BillingPostalCode = '12345',
            BillingState = 'TS',
            BillingStreet = '123 Test St',
            ShippingCity = 'Shipping City',
            ShippingCountry = 'Shipping Country',
            ShippingPostalCode = '54321',
            ShippingState = 'SS',
            ShippingStreet = '456 Shipping St'
        );
        insert testAccount;
    }
    static void createTestContacts() {
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Con ' + i,
                Email = 'abc@gmail.com',
                Phone = '1111122222',
                Title = 'Mr',
                MailingCountry = 'India',
                MailingState = 'Maharashtra',
                MailingCity = 'Nagpur',
                MailingPostalCode = '440024',
                MailingStreet = 'Manewada',
                KTQB__Customer_QB_Id__c = '149' + i,
                KTQB__QB_Company_Name__c = 'Genepoint',
                KTQB__QB_SyncToken__c = 11 + i
            ));
        }
        insert testContacts;
    }
    static void createTestOpportunity() {
        Opportunity testOpp = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Amount = 10000.00
        );
        insert testOpp;
    }
    static void createProduct() {
        Product2 product = new Product2(
            Name = 'GenWatt Gasoline 300kW',
            ProductCode = 'GC5020',
            Description = 'New Prod',
            IsActive = true,
            KTQB__Item_QB_Id__c = ''
        );
        insert product;
    }    
    
    //qBCustomerSync Component
    @isTest
    static void getCustomerOjectApiNameTest(){
         List<Contact> conList = [ SELECT Id 
                                   FROM Contact 
                                   Where FirstName = 'Test'];
        
        Test.startTest();
        String result = CustomerSyncController.getCustomerOjectApiName(conList[0].Id);
        Test.stopTest();
        System.assertNotEquals(null,result,'Success');
    }
    
    //qBCustomerSync Component
    @isTest
    static void getCustomerUsingObjectNameTest(){
         List<Contact> conList = [ SELECT Id 
                                   FROM Contact 
                                   Where FirstName = 'Test'];
        
        Test.startTest();
        SObject so = CustomerSyncController.getCustomerUsingObjectName(conList[0].Id, 'Account');
        System.assertEquals(null, so,'Success');
        Test.stopTest();
    }
    
    //qBCustomerSync Component
    @isTest
    static void getQBCustomerTest(){
         List<Contact> conList = [ SELECT Id 
                                   FROM Contact 
                                   Where FirstName = 'Test'];
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerCustomerHttpCalloutMock());
        
        Test.startTest();
        Map<String, Object> result = CustomerSyncController.getQBCustomer(conList[0].Id);
        System.assertNotEquals(null, result,'Success');
        Test.stopTest();
    }
    
    //qBCustomerSync Component
    @isTest
    static void updateCustomerInSFTest(){
         List<Contact> conList = [ SELECT Id 
                                   FROM Contact 
                                   Where FirstName = 'Test'];
        
        Test.startTest();
        String result = CustomerSyncController.updateCustomerInSF('0', conList[0].Id, 'Contact', 'KTQB__QB_SyncToken__c');
        Test.stopTest();
        System.assertNotEquals(null, result,'Success');
    }

}