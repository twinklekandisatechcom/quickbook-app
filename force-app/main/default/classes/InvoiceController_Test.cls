@isTest
public class InvoiceController_Test {
    
    /**
     * @description setup method to create test data 
    */
    @testSetup
    static void setupData() {
        createQuickbookInfo();
    
        createQBSetting();
    
        createTestAccount();
        
        createTestContacts();
        
		createTestOpportunity();
        
        createTestProduct();
        
        createInvoiceObjectFieldMappings();

        createCustomerObjectFieldMappings();
        
        createInvoiceConfigurationOptions();
    }
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetFieldChecks() {
        // Step 1: Create mock customer field mappings
        Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap = new Map<String, KTQB__Customer_Object_Field_Mapping__c>();

        // Add valid mappings
        customerMap.put('Display Name', new KTQB__Customer_Object_Field_Mapping__c(KTQB__Field_API_Name__c = 'Name'));
        customerMap.put('GivenName', new KTQB__Customer_Object_Field_Mapping__c(KTQB__Field_API_Name__c = 'FirstName'));
        customerMap.put('FamilyName', new KTQB__Customer_Object_Field_Mapping__c(KTQB__Field_API_Name__c = 'LastName'));

        // Add null mapping to check null handling
        customerMap.put('MiddleName', new KTQB__Customer_Object_Field_Mapping__c(KTQB__Field_API_Name__c = null));

        // Step 2: Call the method under test
        List<String> result = InvoiceControllerHelper.getFieldChecks(customerMap);

        // Step 3: Assertions
        System.assertNotEquals(null,result, 'success');
    }
	/**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetFieldChecks_NoMappings() {
        // Step 1: Pass an empty map
        Map<String, KTQB__Customer_Object_Field_Mapping__c> emptyCustomerMap = new Map<String, KTQB__Customer_Object_Field_Mapping__c>();

        // Step 2: Call the method under test
        List<String> result = InvoiceControllerHelper.getFieldChecks(emptyCustomerMap);

        // Step 3: Assertions
        System.assertNotEquals(null,result, 'success');
    }
	/**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetFieldFromCustomerData() {
        // Step 1: Create a sample CustomerConfigWrapper with mock data
        InvoiceController.CustomerConfigWrapper customerData = new InvoiceController.CustomerConfigWrapper();
        customerData.id = 'QB001';
        customerData.qbCustomerSyncToken = 'sync123';

        InvoiceController.PersonalInfo personalInfo = new InvoiceController.PersonalInfo();
        personalInfo.givenName = 'John';
        personalInfo.familyName = 'Doe';
        personalInfo.middleName = 'M';
        personalInfo.displayName = 'John Doe';
        personalInfo.email = 'john.doe@example.com';
        personalInfo.website = 'www.example.com';
        personalInfo.phone = '123-456-7890';
        personalInfo.companyName = 'Example Inc.';
        personalInfo.isTaxable = true;

        InvoiceController.BillingInfo billingInfo = new InvoiceController.BillingInfo();
        billingInfo.billingLine = '123 Billing Street';
        billingInfo.billingCountrySubDivisionCode = 'CA';
        billingInfo.billingPostalCode = '12345';
        billingInfo.billingCountry = 'USA';
        billingInfo.billingCity = 'San Francisco';

        InvoiceController.ShippingInfo shippingInfo = new InvoiceController.ShippingInfo();
        shippingInfo.shippingLine = '456 Shipping';
        shippingInfo.shippingCountrySubDivisionCode = 'NY';
        shippingInfo.shippingPostalCode = '54321';
        shippingInfo.shippingCountry = 'USA';
        shippingInfo.shippingCity = 'New York';

        customerData.personalInfo = personalInfo;
        customerData.billingInfo = billingInfo;
        customerData.shippingInfo = shippingInfo;

        // Step 2: Mock the customerResponseMap
        Map<String, Object> customerResponseMap = new Map<String, Object>();

        // Step 3: Test each field case
        System.assertEquals('John', InvoiceControllerHelper.getFieldFromCustomerData('GivenName', customerData, customerResponseMap), 'GivenName should match');
        System.assertEquals('Doe', InvoiceControllerHelper.getFieldFromCustomerData('FamilyName', customerData, customerResponseMap), 'FamilyName should match');
        System.assertEquals('sync123', InvoiceControllerHelper.getFieldFromCustomerData('Qb Customer Sync Token', customerData, customerResponseMap), 'Qb Customer Sync Token should match');
        System.assertEquals('123 Billing Street', InvoiceControllerHelper.getFieldFromCustomerData('Billing Line', customerData, customerResponseMap), 'Billing Line should match');
        System.assertEquals('USA', InvoiceControllerHelper.getFieldFromCustomerData('Billing Country', customerData, customerResponseMap), 'Billing Country should match');
        System.assertEquals('New York', InvoiceControllerHelper.getFieldFromCustomerData('Shipping City', customerData, customerResponseMap), 'Shipping City should match');
        System.assertEquals('www.example.com', InvoiceControllerHelper.getFieldFromCustomerData('Website', customerData, customerResponseMap), 'Website should match');
        System.assertEquals(true, InvoiceControllerHelper.getFieldFromCustomerData('Is Taxable', customerData, customerResponseMap), 'Is Taxable should match');

        // Step 4: Test for fields not present in the wrapper
        System.assertEquals(null, InvoiceControllerHelper.getFieldFromCustomerData('InvalidField', customerData, customerResponseMap), 'Invalid fields should return null');
    }
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetCustomerMap() {
        // Step 1: Create mock data for CustomerConfigWrapper
        InvoiceController.CustomerConfigWrapper customerData = new InvoiceController.CustomerConfigWrapper();
        customerData.id = 'QB001';
        customerData.qbCustomerSyncToken = 'sync123';
        
        InvoiceController.PersonalInfo personalInfo = new InvoiceController.PersonalInfo();
        personalInfo.givenName = 'John';
        personalInfo.familyName = 'Doe';
        personalInfo.currencyCode = 'USD';
        personalInfo.email = 'john.doe@example.com';
        customerData.personalInfo = personalInfo;
        
        InvoiceController.BillingInfo billingInfo = new InvoiceController.BillingInfo();
        billingInfo.billingLine = '123 Billing St';
        customerData.billingInfo = billingInfo;
        
        InvoiceController.ShippingInfo shippingInfo = new InvoiceController.ShippingInfo();
        shippingInfo.shippingLine = '456 Shipping Ln';
        customerData.shippingInfo = shippingInfo;

        // Step 2: Create a mock customer map with field mappings
        Map<String, SObject> customerMap = new Map<String, SObject>();
        SObject fieldMapping1 = Schema.getGlobalDescribe().get('KTQB__Customer_Object_Field_Mapping__c').newSObject();
        fieldMapping1.put('KTQB__Field_API_Name__c', 'FirstName');
        customerMap.put('GivenName', fieldMapping1);

        SObject fieldMapping2 = Schema.getGlobalDescribe().get('KTQB__Customer_Object_Field_Mapping__c').newSObject();
        fieldMapping2.put('KTQB__Field_API_Name__c', 'LastName');
        customerMap.put('FamilyName', fieldMapping2);

        SObject fieldMapping3 = Schema.getGlobalDescribe().get('KTQB__Customer_Object_Field_Mapping__c').newSObject();
        fieldMapping3.put('KTQB__Field_API_Name__c', 'Email');
        customerMap.put('Email', fieldMapping3);

        // Step 3: Mock customerResponseMap
        Map<String, Object> customerResponseMap = new Map<String, Object>();

        // Step 4: Call the method
        SObject customerRecord = InvoiceControllerHelper.getCustomerMap('Contact', customerMap, customerData, customerResponseMap);

        // Step 5: Assert results
        System.assertNotEquals(null, customerRecord, 'Customer record should not be null');
        System.assertEquals('John', customerRecord.get('FirstName'), 'FirstName should match');
        System.assertEquals('Doe', customerRecord.get('LastName'), 'LastName should match');
        System.assertEquals('john.doe@example.com', customerRecord.get('Email'), 'Email should match');
        System.assertEquals('USD', customerRecord.get('CurrencyIsoCode'), 'CurrencyIsoCode should match');
    }
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testCreateCustomerWrapper() {
        // Step 1: Create a mock SObject (e.g., Account)
        Account testAccount = new Account(
            Name = 'Test Account',
            Fax = '123-456-7890',
            Phone = '987-654-3210',
            BillingStreet = '123 Billing St',
            BillingCity = 'Billing City',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            ShippingStreet = '123 Shipping St',
            ShippingCity = 'Shipping City',
            ShippingState = 'NY',
            ShippingPostalCode = '67890',
            ShippingCountry = 'USA',
            Website = 'http://test.com',
            CurrencyIsoCode = 'USD'
        );
        insert testAccount;

        // Step 2: Create mock customer field mappings
        Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMap = new Map<String, KTQB__Customer_Object_Field_Mapping__c>();
        customerMap.put('GivenName', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Name'));
        customerMap.put('Fax', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Fax'));
        customerMap.put('Mobile', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Phone'));
        customerMap.put('Shipping Line', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'ShippingStreet'));
        customerMap.put('Shipping City', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'ShippingCity'));
        customerMap.put('Shipping Country Sub DivisionCode', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'ShippingState'));
        customerMap.put('Shipping PostalCode', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'ShippingPostalCode'));
        customerMap.put('Shipping Country', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'ShippingCountry'));
        customerMap.put('Email', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Website')); // Assuming Email is mapped to Website for testing
        customerMap.put('Billing Line', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'BillingStreet'));
        customerMap.put('Billing City', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'BillingCity'));
        customerMap.put('Billing Country Sub DivisionCode', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'BillingState'));
        customerMap.put('Billing PostalCode', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'BillingPostalCode'));
        customerMap.put('Billing Country', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'BillingCountry'));
        customerMap.put('MiddleName', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Name'));
        customerMap.put('FamilyName', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Name'));
        customerMap.put('Display Name', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Name'));
        customerMap.put('Website', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Website'));
        customerMap.put('Qb Customer Sync Token', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Id')); // Mocked mapping
        customerMap.put('QB Customer Id', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Id')); // Mocked mapping
        customerMap.put('Company Name', new KTQB__Customer_Object_Field_Mapping__c(Field_API_Name__c = 'Name'));

        // Step 3: Call the method under test
        InvoiceController.CustomerConfigWrapper result = InvoiceControllerHelper.createCustomerWrapper(testAccount, customerMap);

        // Step 4: Assertions
        System.assertNotEquals(null,result, 'success');
       
    }
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testInsertCustomerRecord() {
        // Step 1: Setup test data
        // Create a mock Account object
        Account testAccount = [select id from Account limit 1];

        // Step 2: Create mock CalloutCredentials
        CalloutUtlityController.CalloutCredentials credentials = new CalloutUtlityController.CalloutCredentials();
        credentials.requestbody = new HttpRequest();
        credentials.responsebody = new HttpResponse();

        // Step 3: Call the method under test
        String result = InvoiceControllerHelper.insertCustomerRecord(testAccount, credentials);

        // Step 4: Assertions
        System.assertNotEquals(null, result, 'success');
        
    }
   
    
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetInvoiceShipAddress() {
        // Create a test instance of the wrapper class
        InvoiceController.SingleInvoiceWrapper wrapper = new InvoiceController.SingleInvoiceWrapper();
        wrapper.invoice = new InvoiceController.DataInvoiceWrap();
        wrapper.invoice.shipAddr = new InvoiceController.ClsShipAddr();

        // Test case 1: All shipping address fields are null
        wrapper.invoice.shipAddr.line1 = null;
        wrapper.invoice.shipAddr.line2 = null;
        wrapper.invoice.shipAddr.line3 = null;
        wrapper.invoice.shipAddr.city = null;
        wrapper.invoice.shipAddr.countrySubDivisionCode = null;
        wrapper.invoice.shipAddr.postalCode = null;
        wrapper.invoice.shipAddr.country = null;

        String result = InvoiceControllerHelper.getInvoiceShipAddress(wrapper);
        System.assertNotEquals(null, result, 'success');

        // Test case 2: Some shipping address fields are populated
        wrapper.invoice.shipAddr.line1 = '456 Elm St';
        wrapper.invoice.shipAddr.line2 = null;
        wrapper.invoice.shipAddr.line3 = 'Building 9';
        wrapper.invoice.shipAddr.city = 'San Francisco';
        wrapper.invoice.shipAddr.countrySubDivisionCode = 'CA';
        wrapper.invoice.shipAddr.postalCode = '94103';
        wrapper.invoice.shipAddr.country = 'USA';

        result = InvoiceControllerHelper.getInvoiceShipAddress(wrapper);
        System.assertNotEquals(
            null,
            result,
            'success'
        );

        // Test case 3: All shipping address fields are populated
        wrapper.invoice.shipAddr.line1 = '123 Oak St';
        wrapper.invoice.shipAddr.line2 = 'Suite 300';
        wrapper.invoice.shipAddr.line3 = 'Warehouse';
        wrapper.invoice.shipAddr.city = 'Los Angeles';
        wrapper.invoice.shipAddr.countrySubDivisionCode = 'CA';
        wrapper.invoice.shipAddr.postalCode = '90001';
        wrapper.invoice.shipAddr.country = 'USA';

        result = InvoiceControllerHelper.getInvoiceShipAddress(wrapper);
        System.assertNotEquals(
            null,
            result,
            'success'
        );

        // Test case 4: Shipping address fields contain only empty strings
        wrapper.invoice.shipAddr.line1 = '';
        wrapper.invoice.shipAddr.line2 = '';
        wrapper.invoice.shipAddr.line3 = '';
        wrapper.invoice.shipAddr.city = '';
        wrapper.invoice.shipAddr.countrySubDivisionCode = '';
        wrapper.invoice.shipAddr.postalCode = '';
        wrapper.invoice.shipAddr.country = '';

        result = InvoiceControllerHelper.getInvoiceShipAddress(wrapper);
        System.assertNotEquals(null, result, 'success');
    }
    /**
     * @description setup method to create test data 
    */
    @IsTest
    public static void testGetInvoiceBillAddress() {
        // Create a test instance of the wrapper class
        InvoiceController.SingleInvoiceWrapper wrapper = new InvoiceController.SingleInvoiceWrapper();
        wrapper.invoice = new InvoiceController.DataInvoiceWrap();
        wrapper.invoice.billAddr = new InvoiceController.ClsBillAddr();

        // Test case 1: All address lines are null
        wrapper.invoice.billAddr.line1 = null;
        wrapper.invoice.billAddr.line2 = null;
        wrapper.invoice.billAddr.line3 = null;
        wrapper.invoice.billAddr.line4 = null;

        String result = InvoiceControllerHelper.getInvoiceBillAddress(wrapper);
        System.assertNotEquals(null, result, 'success');

        // Test case 2: Some address lines are populated
        wrapper.invoice.billAddr.line1 = '123 Main St';
        wrapper.invoice.billAddr.line2 = null;
        wrapper.invoice.billAddr.line3 = 'Apt 4B';
        wrapper.invoice.billAddr.line4 = '';

        result = InvoiceControllerHelper.getInvoiceBillAddress(wrapper);
        System.assertNotEquals(null, result, 'success');

        // Test case 3: All address lines are populated
        wrapper.invoice.billAddr.line1 = '123 Main St';
        wrapper.invoice.billAddr.line2 = 'Suite 200';
        wrapper.invoice.billAddr.line3 = 'Apt 4B';
        wrapper.invoice.billAddr.line4 = 'New York, NY 10001';

        result = InvoiceControllerHelper.getInvoiceBillAddress(wrapper);
        System.assertNotEquals(null, result, 'success');

        // Test case 4: Address lines contain only empty strings
        wrapper.invoice.billAddr.line1 = '';
        wrapper.invoice.billAddr.line2 = '';
        wrapper.invoice.billAddr.line3 = '';
        wrapper.invoice.billAddr.line4 = '';

        result = InvoiceControllerHelper.getInvoiceBillAddress(wrapper);
        System.assertNotEquals(null, result, 'success');
    }
    /**
     * @description setup method to create test data 
    */
    static void createQuickbookInfo() {
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c(
            Name = 'QB-0001',
            KTQB__Client_ID__c = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt',
            KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe',
            KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/',
            KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage',
            KTQB__QB_Company_Id__c = '4620816365289262850'
        );
        insert qbInfo;
    }
    /**
     * @description setup method to create test data 
    */
    static void createQBSetting() {
        KTQB__QB_Setting__c qs = new KTQB__QB_Setting__c(KTQB__QB_version__c = 64);
        upsert qs;
    }
    /**
     * @description setup method to create test data 
    */
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
            ShippingStreet = '456 Shipping St',
            AnnualRevenue = 34.344
        );
        insert testAccount;
    }
    /**
     * @description setup method to create test data 
    */
    static void createTestContacts() {
        List<Contact> testCons = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testCons.add(new Contact(
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
        insert testCons;
    }
    /**
     * @description setup method to create test data 
    */
    static void createTestOpportunity() {
        Opportunity testOpp = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Amount = 10000.00
        );
        insert testOpp;
    }
    /**
     * @description setup method to create test data 
    */
    static void createTestProduct() {
        Product2 proData = new Product2(Name ='GenWatt Gasoline 300kW', ProductCode = 'GC5020', Description = 'New Prod', 
                                        IsActive=true, KTQB__Item_QB_Id__c = '');
        insert proData;
    }
    /**
     * @description setup method to create test data 
    */
    static void createInvoiceObjectFieldMappings() {
        List<KTQB__Invoice_Object_Field_Mapping__c> iObjFM = new List<KTQB__Invoice_Object_Field_Mapping__c>();
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Name', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Name', KTQB__Field_Value__c = 'Name', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Billing Address', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'BillingStreet', KTQB__Field_Value__c = 'Billing Address', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Balance Due', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Balance', KTQB__QuickBook_Field_API_Name__c = 'Balance', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Shipping Address', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'KTQB__ShipAddr__c', KTQB__Field_Value__c = 'Shipping Address', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Tax Rate', KTQB__Data_Type__c = 'DOUBLE', KTQB__Field_API_Name__c = 'BillingLatitude', KTQB__Field_Value__c = 'Tax Rate', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Date', KTQB__Data_Type__c = 'Date', KTQB__Field_API_Name__c = 'KTQB__SLAExpirationDate__c', KTQB__Field_Value__c = 'Invoice Date', KTQB__QuickBook_Field_API_Name__c = 'TxnDate', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'BillEmail', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'AccountNumber', KTQB__Field_Value__c = 'BillEmail', KTQB__QuickBook_Field_API_Name__c = 'BillEmail', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Transaction Date', KTQB__Data_Type__c = 'Date', KTQB__Field_API_Name__c = 'KTQB__SLAExpirationDate__c', KTQB__Field_Value__c = 'Transaction Date', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Total Amount', KTQB__Data_Type__c = 'Double', KTQB__Field_API_Name__c = 'KTQB__NumberofLocations__c', KTQB__Field_Value__c = 'Total Amount', KTQB__QuickBook_Field_API_Name__c = 'TotalAmt', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice State', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'AccountNumber', KTQB__Field_Value__c = 'Invoice State', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'QB Customer', KTQB__Data_Type__c = '', KTQB__Field_API_Name__c = 'Contact__c', KTQB__Field_Value__c = 'QB Customer', KTQB__QuickBook_Field_API_Name__c = 'QBCustomerRef', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Qb Invoice Sync Token', KTQB__Data_Type__c = 'Double', KTQB__Field_API_Name__c = 'KTQB__NumberofLocations__c', KTQB__Field_Value__c = 'Qb Invoice Sync Token', KTQB__QuickBook_Field_API_Name__c = 'SyncToken', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Number', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Name', KTQB__Field_Value__c = 'Invoice Number', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Status', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'AccountNumber', KTQB__Field_Value__c = '    Invoice Status', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Total Tax', KTQB__Data_Type__c = 'CURRENCY, DOUBLE', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Total Tax', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Terms', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'AccountNumber', KTQB__Field_Value__c = 'Terms', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Due Date', KTQB__Data_Type__c = 'Date', KTQB__Field_API_Name__c = 'KTQB__SLAExpirationDate__c', KTQB__Field_Value__c = 'Due Date', KTQB__QuickBook_Field_API_Name__c = 'DueDate', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Invoice Qb Id', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'AccountNumber', KTQB__Field_Value__c = 'Invoice Qb Id', KTQB__QuickBook_Field_API_Name__c = 'Id', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Discount Amount', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Discount Amount', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Home Total Amount', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Home Total Amount', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Home Balance', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Home Balance', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Exchange Rate', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Exchange Rate', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Shipping Charges', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Shipping Charges', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Percent Based Discount', KTQB__Data_Type__c = 'BOOLEAN', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Percent Based Discount', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Discount Percent / Discount Value', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'Discount Percent / Discount Value', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'QB Customer Ref ID', KTQB__Data_Type__c = 'CURRENCY,DOUBLE', KTQB__Field_API_Name__c = 'AnnualRevenue', KTQB__Field_Value__c = 'QB Customer Ref ID', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Apply discount after sales tax', KTQB__Data_Type__c = 'BOOLEAN', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Apply discount after sales tax', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
		iObjFM.add(new KTQB__Invoice_Object_Field_Mapping__c(Name = 'Tax Code', KTQB__Data_Type__c = 'REFERENCE(KTQB__QB_MetaData__c)', KTQB__Field_API_Name__c = '', KTQB__Field_Value__c = 'Tax Code', KTQB__QuickBook_Field_API_Name__c = '', KTQB__Required__c = false));
        
        insert iObjFM;
    }
    /**
     * @description setup method to create test data 
    */
    static void createCustomerObjectFieldMappings() {
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
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Email', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Email', KTQB__Field_Value__c = 'Email'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'MiddleName', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'KTQB__Middle_Name__c', KTQB__Field_Value__c = 'MiddleName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'FamilyName', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'LastName', KTQB__Field_Value__c = 'FamilyName'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Display Name', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'KTQB__Display_Name__c', KTQB__Field_Value__c = 'Display Name'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Website', KTQB__Data_Type__c = 'Url', KTQB__Field_API_Name__c = 'Website__c', KTQB__Field_Value__c = 'Website'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Phone', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'Phone', KTQB__Field_Value__c = 'Phone'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Qb Customer Sync Token', KTQB__Data_Type__c = 'Double', KTQB__Field_API_Name__c = 'QB_SyncToken__c', KTQB__Field_Value__c = 'Qb Customer Sync Token'));
        cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Customer QB Id', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'KTQB__Customer_QB_Id__c', KTQB__Field_Value__c = 'Customer QB Id', KTQB__QuickBook_Field_API_Name__c = ''));
	    cObjFM.add(new KTQB__Customer_Object_Field_Mapping__c(Name = 'Customer Currency Reference', KTQB__Data_Type__c = 'String', KTQB__Field_API_Name__c = 'KTQB__Customer_Currecny__c', KTQB__Field_Value__c = 'Customer Currency Reference', KTQB__QuickBook_Field_API_Name__c = ''));
        insert cObjFM;
    }
    /**
     * @description setup method to create test data 
    */
    static void createInvoiceConfigurationOptions() {
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
        iconfig.KTQB__Invoice_Object_Name__c = 'Account';
        insert iconfig;
    }
    /**
     * @description Method to test getAccountWithOpp method 
    */
    @isTest
    static void getAccountWithOppTest(){
        
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        Test.startTest();
        String str = InvoiceController.getAccountWithOpp(opp.Id);
        Test.stopTest();
        System.assertEquals(null, str, 'success');
    }
    /**
     * @description Method to test insertProductOnQb method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void insertProductOnQbTest1(){
         Product2 prod = [ SELECT Id, Name, ProductCode, Description, IsActive, KTQB__Item_QB_Id__c  
                           FROM Product2 
                           Where Name = 'GenWatt Gasoline 300kW'];
        
        String prodStr = JSON.serialize(prod);
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerItemHttpCalloutMock());
        
        Test.startTest();
        String str = InvoiceController.insertProductOnQb(prodStr);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test insertProductOnQb method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void insertProductOnQbTest2(){
         Product2 prod = [ SELECT Id, Name, ProductCode, Description, IsActive, KTQB__Item_QB_Id__c  
                           FROM Product2 
                           Where Name = 'GenWatt Gasoline 300kW'];
        
        String prodStr = JSON.serialize(prod);
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerItemHttpCalloutMock2());
        
        Test.startTest();
        String str = InvoiceController.insertProductOnQb(prodStr);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test insertProductOnQb method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void insertProductOnQbTest3(){
         Product2 prod = [ SELECT Id, Name, ProductCode, Description, IsActive, KTQB__Item_QB_Id__c  
                           FROM Product2 
                           Where Name = 'GenWatt Gasoline 300kW'];
        
        String prodStr = JSON.serialize(prod);
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerItemHttpCalloutMock3());
        
        Test.startTest();
        String str = InvoiceController.insertProductOnQb(prodStr);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test checkCurrencyIsPresentInQB method 
    */
    //GenerateInvoiceCustomerCreationForm Component
    @isTest
    static void checkCurrencyIsPresentInQBTest(){
        
        Test.startTest();
        String str = InvoiceController.checkCurrencyIsPresentInQB('INR');
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test getProductList method 
    */
    //GenerateInvoiceCustomerCreationForm Component
    @isTest
    static void getProductListTest(){
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        
        Test.startTest();
        List<OpportunityLineItem> oli = InvoiceController.getProductList(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, oli, 'success');
    }
    /**
     * @description Method to test getAccountWithId method 
    */
    @isTest
    static void getAccountWithIdTest(){
        Account acc = [ SELECT Id, Name FROM Account Where Name = 'TestAcc' WITH USER_MODE];
        Test.startTest();
        Account accReturn = InvoiceController.getAccountWithId(acc.Id);
        Test.stopTest();
        System.assertNotEquals(null, accReturn, 'success');
    }
    /**
     * @description Method to test checkInvoiceObjectHasParentAccount method 
    */
    @isTest
    static void checkInvoiceObjectHasParentAccountTest(){
       
        Test.startTest();
        Boolean x = InvoiceController.checkInvoiceObjectHasParentAccount('Account');
        Test.stopTest();
        System.assertNotEquals(null, x, 'success');
    }
    /**
     * @description Method to test sendInvoiceEmail method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void sendInvoiceEmailTest1(){
    
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerInvoiceHttpCalloutMock());
        Test.startTest();
        String str = InvoiceController.sendInvoiceEmail('12345');
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test sendInvoiceEmail method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void sendInvoiceEmailTest2(){
       
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerUnauthHttpCalloutMock());
        Test.startTest();
        String str = InvoiceController.sendInvoiceEmail('12345');
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test sendInvoiceEmail method 
    */
    //GenerateInvoiceForm Component
    @isTest
    static void sendInvoiceEmailTest3(){
      
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerInvoiceHttpCalloutMock2());
        Test.startTest();
        String str = InvoiceController.sendInvoiceEmail('12345');
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test generateInvoice method 
    */
    @isTest
    static void generateInvoiceTest(){
        Account acc = [ SELECT id FROM Account WHERE Name = 'TestAcc'];
        List<Contact> conList = [ SELECT Id, Name, Title, FirstName, LastName, Email, Phone, KTQB__Customer_QB_Id__c, KTQB__QB_Company_Name__c, KTQB__QB_SyncToken__c, 
                                  MailingAddress, MailingState, MailingCountry, MailingCity, MailingPostalCode, MailingStreet 
                                  FROM Contact 
                                  WHERE FirstName = 'Test'];
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
      
        //Date myDate = Date.today();
        //String customerWrapper = '{"billinginfo":{"billingline":"dighori","billingcity":"nagpur","billingcountry":"india","billingpostalcode":"440009","billingcountrysubdivisioncode":"maharashtra"},"personalinfo":{"email":"rodni.rieta@infinox.com"},"shippingInfo":{"shippingLine":"Dighori","shippingCity":"Nagpur","shippingCountry":"India","shippingPostalCode":"440009","shippingCountrySubDivisionCode":"Maharashtra"},"invoiceType":"blankProduct"}';
        //String invoiceCustomerWrapper = '{"taxRate":"California 16%","dueDate":"'+myDate+'","invoiceDate":"'+myDate+'","getAccid":null,"discountValue":"34","discountTotal":-34,"terms":"5","discountTypeValue":"value","taxId":"2","getOppid":null,"taxAmount":184.96,"shipping":"344"}';
        //String lineItemDataWrapper = '[{"amount":"1156.00","code":"","expenseAccount":"55","id":"d.kkk8gw5bed","incomeAccount":"86","productDesc":"test","productId":"","productName":"","quantity":"34","rate":"34","taxable":true}]';
        
        // Create test data
        InvoiceController.BillingInfo biwrapper = new InvoiceController.BillingInfo();
        biwrapper.billingLine = 'Test';
        biwrapper.billingCountrySubDivisionCode = 'Test';
        biwrapper.billingPostalCode = '12345';
        biwrapper.billingCountry = 'Test';
        biwrapper.billingCity = 'Test';
        
        InvoiceController.PersonalInfo piwrapper = new InvoiceController.PersonalInfo();
        piwrapper.givenName = '';
        piwrapper.fax = '';
        piwrapper.mobile = '';
        piwrapper.email = '';
        piwrapper.middleName = '';
        piwrapper.familyName = '';
        piwrapper.displayName = '';
        piwrapper.website = '';
        piwrapper.phone = '';
        piwrapper.companyName = '';
        piwrapper.contactSameAsBilling = true;
        piwrapper.currencyCode = '';
        
        InvoiceController.shippingInfo siwrapper = new InvoiceController.shippingInfo();
        siwrapper.shippingLine = 'Test';
        siwrapper.shippingCountrySubDivisionCode = 'Test';
        siwrapper.shippingPostalCode = '12345';
        siwrapper.shippingCountry = 'Test';
        siwrapper.shippingCity = 'Test';
        
        InvoiceController.CustomerConfigWrapper ccwrapper = new InvoiceController.CustomerConfigWrapper();
        ccwrapper.id = conList[0].Id;
        ccwrapper.invoiceType = '';
        ccwrapper.qbCustomerSyncToken = '';
        ccwrapper.customerQBId = '';
        ccwrapper.personalInfo = piwrapper;
        ccwrapper.billingInfo = biwrapper;
        ccwrapper.shippingInfo = siwrapper;
        ccwrapper.accid = acc.Id;
        ccwrapper.oppid = opp.id;
        ccwrapper.action = 'Update';
        
        Date myDate = Date.today();
        InvoiceController.InvoiceCustomeData icwrapper = new InvoiceController.InvoiceCustomeData();
        icwrapper.terms = '';
        icwrapper.dueDate = myDate;
        icwrapper.discountTypeValue = '';
        icwrapper.discountValue = '10';
        icwrapper.discountTotal = '10';
        icwrapper.taxId = '';
        icwrapper.taxRate = '';
        icwrapper.taxAmount = '0';
        icwrapper.invoiceDate = myDate;
        icwrapper.getAccid = '';
        icwrapper.getOppid = '';
        icwrapper.shipping = '673.78';
        icwrapper.discountAfterTax = false;
        
        QBProductController.OppproductWrapper qoWrapper = new QBProductController.OppproductWrapper();
        qoWrapper.productId = '';
        qoWrapper.productName = '';
        qoWrapper.expenseAccount = '';
        qoWrapper.incomeAccount = '';
        qoWrapper.code = '';
        qoWrapper.productDesc = '';
        qoWrapper.quantity = 0.00;
        qoWrapper.rate = 10.0;
        qoWrapper.amount = 1000;
        qoWrapper.taxable = true;
        qoWrapper.qbProductCode = '';
        
        InvoiceController.SalesTermRef str = new InvoiceController.SalesTermRef();
        str.value = '';
        str.name = '';
        
        InvoiceController.ClsTaxRateRef ctrr = new InvoiceController.ClsTaxRateRef();
        ctrr.value = '';
        
        InvoiceController.ClsTaxLineDetail ctld = new InvoiceController.ClsTaxLineDetail();
        ctld.taxPercent = 5;
            
        List<InvoiceController.ClsTaxLine> ctl = new List<InvoiceController.ClsTaxLine>();
        //ctl[0].taxLineDetail = ctld;
            
        InvoiceController.ClsTxnTaxDetail cttd = new InvoiceController.ClsTxnTaxDetail();
        cttd.totalTax = 2;
        cttd.taxRateRef = ctrr;
        cttd.taxLine = ctl;
        
        InvoiceController.ClsBillEmail cbe = new InvoiceController.ClsBillEmail();
        cbe.address = '';
        
        InvoiceController.ClsBillAddr cba = new InvoiceController.ClsBillAddr();
        cba.line1 = '';
        cba.line2 = '';
        cba.line3 = '';
        cba.line4 = '';
        
        InvoiceController.ClsShipAddr csa = new InvoiceController.ClsShipAddr();
        csa.city = '';
        csa.line1 = '';
        csa.line2 = '';
        csa.line3 = '';
        csa.postalCode = '';
        csa.country = '';
        csa.countrySubDivisionCode = '';
        
        InvoiceController.ClsTaxCodeRef ctcr = new InvoiceController.ClsTaxCodeRef();
        ctcr.value = '';
        
        InvoiceController.ClsItemRef cir = new InvoiceController.ClsItemRef();
        cir.value = '';
        cir.name = '';
        
        InvoiceController.ClsSalesItemLineDetail csild = new InvoiceController.ClsSalesItemLineDetail();
        csild.taxCodeRef = ctcr;
        csild.qty = 100;
        csild.unitPrice = 1;
        csild.itemRef = cir;
            
        List<InvoiceController.ClsLine> cl = new List<InvoiceController.ClsLine>();
        //cl[0].description = '';
        //cl[0].salesItemLineDetail = csild;
        //cl[0].amount = 1000;
        //cl[0].id = '';
            
        InvoiceController.DataInvoiceWrap diwarapper = new InvoiceController.DataInvoiceWrap();
        diwarapper.detail = '';
        diwarapper.message = '';
        diwarapper.txnDate = myDate;
        diwarapper.salesTermRef = str;
        diwarapper.totalAmt = 10;
        diwarapper.dueDate = myDate;
        diwarapper.docNumber = '';
        diwarapper.txnTaxDetail = cttd;
        diwarapper.billEmail = cbe;
        diwarapper.billAddr = cba;
        diwarapper.shipAddr = csa;
        diwarapper.line = cl;
        diwarapper.id = '';
        diwarapper.balance = 135.8;
        diwarapper.syncToken = 0;
            
        InvoiceController.SingleInvoiceWrapper sinvwrapper = new InvoiceController.SingleInvoiceWrapper();
        sinvwrapper.invoice = diwarapper;
        sinvwrapper.fault = diwarapper;
        
        String customerWrapper = Json.serialize(ccwrapper);
        String invoiceCustomerWrapper = Json.serialize(icwrapper);
        String lineItemDataWrapper = Json.serialize(qoWrapper);
        String newlineItemDataWrapper = '[' +lineItemDataWrapper+ ']';
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerCustomerHttpCalloutMock());
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerInvoiceHttpCalloutMock());
        Test.startTest();
        String result = InvoiceController.generateInvoice(customerWrapper, newlineItemDataWrapper, invoiceCustomerWrapper);
        Test.stopTest();
        System.assertNotEquals(null, result, 'success');
    }
    /**
     * @description Method to test getCustomerList method 
    */
    @isTest
    static void getCustomerListTest(){
        
        // Create test data
        Test.startTest();
        List<InvoiceController.CustomerConfigWrapper> ccw = InvoiceController.getCustomerList();
        Test.stopTest();
        System.assertNotEquals(null, ccw, 'success');
    }
    /**
     * @description Method to test isNotBlank method 
    */
    @isTest
    static void isNotBlankTest(){
        Test.startTest();
        Boolean result = InvoiceController.isNotBlank('Abc');
        Test.stopTest();
        System.assertNotEquals(null, result, 'success');
    }
    
    //GenerateInvoiceCustomerCreationForm Component
    // For res.getStatusCode()) == '200'
    // ccwrapper.action = 'update'
    /**
     * @description Method to test insertCustomer method 
    */
    @isTest
    static void insertCustomerTest1(){
        Account acc = [ SELECT id FROM Account WHERE Name = 'TestAcc'];
        List<Contact> conList = [ SELECT Id, Name, Title, FirstName, LastName, Email, Phone, KTQB__Customer_QB_Id__c, KTQB__QB_Company_Name__c, KTQB__QB_SyncToken__c, 
                                  MailingAddress, MailingState, MailingCountry, MailingCity, MailingPostalCode, MailingStreet 
                                  FROM Contact 
                                  WHERE FirstName = 'Test'];
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        
        // Create test data
        InvoiceController.BillingInfo biwrapper = new InvoiceController.BillingInfo();
        biwrapper.billingLine = '';
        biwrapper.billingCountrySubDivisionCode = '';
        biwrapper.billingPostalCode = '';
        biwrapper.billingCountry = '';
        biwrapper.billingCity = '';
        
        InvoiceController.PersonalInfo piwrapper = new InvoiceController.PersonalInfo();
        piwrapper.givenName = '';
        piwrapper.fax = '';
        piwrapper.mobile = '';
        piwrapper.email = '';
        piwrapper.middleName = '';
        piwrapper.familyName = '';
        piwrapper.displayName = '';
        piwrapper.website = '';
        piwrapper.phone = '';
        piwrapper.companyName = '';
        piwrapper.contactSameAsBilling = true;
        piwrapper.currencyCode = '';
        
        InvoiceController.shippingInfo siwrapper = new InvoiceController.shippingInfo();
        siwrapper.shippingLine = '';
        siwrapper.shippingCountrySubDivisionCode = '';
        siwrapper.shippingPostalCode = '';
        siwrapper.shippingCountry = '';
        siwrapper.shippingCity = '';
        
        InvoiceController.CustomerConfigWrapper ccwrapper = new InvoiceController.CustomerConfigWrapper();
        ccwrapper.id = conList[0].Id;
        ccwrapper.invoiceType = '';
        ccwrapper.qbCustomerSyncToken = '';
        ccwrapper.customerQBId = '';
        ccwrapper.personalInfo = piwrapper;
        ccwrapper.billingInfo = biwrapper;
        ccwrapper.shippingInfo = siwrapper;
        ccwrapper.accid = acc.Id;
        ccwrapper.oppid = opp.id;
        ccwrapper.action = 'update';
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerCustomerHttpCalloutMock());
        Test.startTest();
        String str = InvoiceController.insertCustomer(ccwrapper, acc.id, opp.id);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    
    //GenerateInvoiceCustomerCreationForm Component
    // For res.getStatusCode()) == '200'
    // insertCustomerInSF() is called from insertCustomer() in else part where ccwrapper.action = '';
    /**
     * @description Method to test insertCustomer method 
    */
    @isTest
    static void insertCustomerTest2(){
        Account acc = [ SELECT id FROM Account WHERE Name = 'TestAcc'];
        List<Contact> conList = [ SELECT Id, Name, Title, FirstName, LastName, Email, Phone, KTQB__Customer_QB_Id__c, KTQB__QB_Company_Name__c, KTQB__QB_SyncToken__c, 
                                  MailingAddress, MailingState, MailingCountry, MailingCity, MailingPostalCode, MailingStreet 
                                  FROM Contact 
                                  WHERE FirstName = 'Test'];
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        
        // Create test data
        InvoiceController.BillingInfo biwrapper = new InvoiceController.BillingInfo();
        biwrapper.billingLine = '';
        biwrapper.billingCountrySubDivisionCode = '';
        biwrapper.billingPostalCode = '';
        biwrapper.billingCountry = '';
        biwrapper.billingCity = '';
        
        InvoiceController.PersonalInfo piwrapper = new InvoiceController.PersonalInfo();
        piwrapper.givenName = '';
        piwrapper.fax = '';
        piwrapper.mobile = '';
        piwrapper.email = '';
        piwrapper.middleName = '';
        piwrapper.familyName = '';
        piwrapper.displayName = '';
        piwrapper.website = '';
        piwrapper.phone = '';
        piwrapper.companyName = '';
        piwrapper.contactSameAsBilling = true;
        piwrapper.currencyCode = '';
        
        InvoiceController.shippingInfo siwrapper = new InvoiceController.shippingInfo();
        siwrapper.shippingLine = '';
        siwrapper.shippingCountrySubDivisionCode = '';
        siwrapper.shippingPostalCode = '';
        siwrapper.shippingCountry = '';
        siwrapper.shippingCity = '';
        
        InvoiceController.CustomerConfigWrapper ccwrapper = new InvoiceController.CustomerConfigWrapper();
        ccwrapper.id = conList[0].Id;
        ccwrapper.invoiceType = '';
        ccwrapper.qbCustomerSyncToken = '';
        ccwrapper.customerQBId = '';
        ccwrapper.personalInfo = piwrapper;
        ccwrapper.billingInfo = biwrapper;
        ccwrapper.shippingInfo = siwrapper;
        ccwrapper.accid = acc.Id;
        ccwrapper.oppid = opp.id;
        ccwrapper.action = '';
        ccwrapper.personalInfo.familyName = 'Test';
        
        Test.setMock(HttpCalloutMock.class, new InvoiceControllerCustomerHttpCalloutMock());
        Test.startTest();
        String str = InvoiceController.insertCustomer(ccwrapper, acc.id, opp.id);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    
    //GenerateInvoiceCustomerCreationForm Component
    // For res.getStatus() == 'Unauthorized'
    /**
     * @description Method to test insertCustomer method 
    */
    @isTest
    static void insertCustomerTest3(){
        Account acc = [ SELECT id FROM Account WHERE Name = 'TestAcc'];
        List<Contact> conList = [ SELECT Id, Name, Title, FirstName, LastName, Email, Phone, KTQB__Customer_QB_Id__c, KTQB__QB_Company_Name__c, KTQB__QB_SyncToken__c, 
                                  MailingAddress, MailingState, MailingCountry, MailingCity, MailingPostalCode, MailingStreet 
                                  FROM Contact 
                                  WHERE FirstName = 'Test'];
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        
        // Create test data
        InvoiceController.BillingInfo biwrapper = new InvoiceController.BillingInfo();
        biwrapper.billingLine = '';
        biwrapper.billingCountrySubDivisionCode = '';
        biwrapper.billingPostalCode = '';
        biwrapper.billingCountry = '';
        biwrapper.billingCity = '';
        
        InvoiceController.PersonalInfo piwrapper = new InvoiceController.PersonalInfo();
        piwrapper.givenName = '';
        piwrapper.fax = '';
        piwrapper.mobile = '';
        piwrapper.email = '';
        piwrapper.middleName = '';
        piwrapper.familyName = '';
        piwrapper.displayName = '';
        piwrapper.website = '';
        piwrapper.phone = '';
        piwrapper.companyName = '';
        piwrapper.contactSameAsBilling = true;
        piwrapper.currencyCode = '';
        
        InvoiceController.shippingInfo siwrapper = new InvoiceController.shippingInfo();
        siwrapper.shippingLine = '';
        siwrapper.shippingCountrySubDivisionCode = '';
        siwrapper.shippingPostalCode = '';
        siwrapper.shippingCountry = '';
        siwrapper.shippingCity = '';
        
        InvoiceController.CustomerConfigWrapper ccwrapper = new InvoiceController.CustomerConfigWrapper();
        ccwrapper.id = conList[0].Id;
        ccwrapper.invoiceType = '';
        ccwrapper.qbCustomerSyncToken = '';
        ccwrapper.customerQBId = '';
        ccwrapper.personalInfo = piwrapper;
        ccwrapper.billingInfo = biwrapper;
        ccwrapper.shippingInfo = siwrapper;
        ccwrapper.accid = acc.Id;
        ccwrapper.oppid = opp.id;
        ccwrapper.action = '';
        
        Test.setMock(HttpCalloutMock.class, new InvoiceCtrlCustomerUnauthHttpCalloutMock());
        Test.startTest();
        String str = InvoiceController.insertCustomer(ccwrapper, acc.id, opp.id);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    
    //GenerateInvoiceCustomerCreationForm Component
    // For else part
    /**
     * @description Method to test insertCustomer method 
    */
    @isTest
    static void insertCustomerTest4(){
        Account acc = [ SELECT id FROM Account WHERE Name = 'TestAcc'];
        List<Contact> conList = [ SELECT Id, Name, Title, FirstName, LastName, Email, Phone, KTQB__Customer_QB_Id__c, KTQB__QB_Company_Name__c, KTQB__QB_SyncToken__c, 
                                  MailingAddress, MailingState, MailingCountry, MailingCity, MailingPostalCode, MailingStreet 
                                  FROM Contact 
                                  WHERE FirstName = 'Test'];
        Opportunity opp = [ SELECT id FROM Opportunity WHERE Name = 'TestOpp'];
        
        // Create test data
        InvoiceController.BillingInfo biwrapper = new InvoiceController.BillingInfo();
        biwrapper.billingLine = '';
        biwrapper.billingCountrySubDivisionCode = '';
        biwrapper.billingPostalCode = '';
        biwrapper.billingCountry = '';
        biwrapper.billingCity = '';
        
        InvoiceController.PersonalInfo piwrapper = new InvoiceController.PersonalInfo();
        piwrapper.givenName = '';
        piwrapper.fax = '';
        piwrapper.mobile = '';
        piwrapper.email = '';
        piwrapper.middleName = '';
        piwrapper.familyName = '';
        piwrapper.displayName = '';
        piwrapper.website = '';
        piwrapper.phone = '';
        piwrapper.companyName = '';
        piwrapper.contactSameAsBilling = true;
        piwrapper.currencyCode = '';
        
        InvoiceController.shippingInfo siwrapper = new InvoiceController.shippingInfo();
        siwrapper.shippingLine = '';
        siwrapper.shippingCountrySubDivisionCode = '';
        siwrapper.shippingPostalCode = '';
        siwrapper.shippingCountry = '';
        siwrapper.shippingCity = '';
        
        InvoiceController.CustomerConfigWrapper ccwrapper = new InvoiceController.CustomerConfigWrapper();
        ccwrapper.id = conList[0].Id;
        ccwrapper.invoiceType = '';
        ccwrapper.qbCustomerSyncToken = '';
        ccwrapper.customerQBId = '';
        ccwrapper.personalInfo = piwrapper;
        ccwrapper.billingInfo = biwrapper;
        ccwrapper.shippingInfo = siwrapper;
        ccwrapper.accid = acc.Id;
        ccwrapper.oppid = opp.id;
        ccwrapper.action = '';
        
        Test.setMock(HttpCalloutMock.class, new InvoiceCtrlCustomerHttpCalloutMock2());
        Test.startTest();
        String str = InvoiceController.insertCustomer(ccwrapper, acc.id, opp.id);
        Test.stopTest();
        System.assertNotEquals(null, str, 'success');
    }
    /**
     * @description Method to test getInvoiceConfiguration method 
    */
    @isTest
    static void getInvoiceConfigurationTest(){
        List<KTQB__QB_MetaData__c> options = new List<KTQB__QB_MetaData__c>();
        InvoiceController.InvoiceConfigWrapper icw = new InvoiceController.InvoiceConfigWrapper();
        icw.Id = '';
        icw.Save = true;
        //icw.Save_And_Send = true;
        icw.oppTerms = options;
        icw.salesTax = options;
        icw.Terms = '';
        icw.Tax = '';
        Test.startTest();
        InvoiceController.InvoiceConfigWrapper icwReturn = InvoiceController.getInvoiceConfiguration();
        Test.stopTest();
        System.assertNotEquals(null, icwReturn, 'success');
    }
    /**
     * @description Method to test orgCurrency method 
    */
    @isTest
    static void orgCurrencyTest(){
        Test.startTest();
        String result = InvoiceController.orgCurrency();
        Test.stopTest();
        System.assertNotEquals(null, result, 'success');
    }
    
        // getFieldOption() is called from getInvoiceConfiguration();
}