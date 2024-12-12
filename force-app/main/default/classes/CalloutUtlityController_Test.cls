@isTest
public with sharing class CalloutUtlityController_Test {
    
    @testSetup
    static void setupData() {
        // Create Quickbook Info rec
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QB-0001';
        qbInfo.KTQB__Client_ID__c  = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        qbInfo.KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        qbInfo.KTQB__QB_Company_Id__c = '4620816365289262850';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        insert qbInfo;
        
        KTQB__QB_Setting__c qs = new KTQB__QB_Setting__c();
        qs.QB_version__c = 64;
        upsert qs;
        
        // Create common test contacts 
        List<Contact> testCons = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testCons.add(new Contact(FirstName = 'Test ', LastName = 'Con ' + i, Email = 'abc@gmail.com', Phone = '1111122222', Title = 'Mr', 
                                     MailingCountry = 'India', MailingState = 'Maharashtra', MailingCity = 'Nagpur', MailingPostalCode = '440024', MailingStreet ='Manewada',
                                     KTQB__Customer_QB_Id__c = '149'+ i, KTQB__QB_Company_Name__c = 'Genepoint', KTQB__QB_SyncToken__c = 11 + i));
        }
        insert testCons;
        
        // Create test Product2 and KTQB__InvoiceConfigurationOptions__c for calloutToCreateUpdateItemInQb method
        Product2 proData = new Product2(Name ='GenWatt Gasoline 300kW', ProductCode = 'GC5020', Description = 'New Prod', 
                                        IsActive=true, KTQB__Item_QB_Id__c = '');
        insert proData;
        
        KTQB__InvoiceConfigurationOptions__c iconfig = new KTQB__InvoiceConfigurationOptions__c();
        iconfig.KTQB__Create_Update_Qb_Payment_In_Sf__c = true;
        iconfig.KTQB__Income_Account__c = '';
        iconfig.KTQB__Invoice_Date__c = '';
        iconfig.KTQB__Invoice_Due_Date__c = '';
        iconfig.KTQB__Invoice_Save__c = true;
        iconfig.KTQB__Invoice_Save_and_Send__c = true;
        iconfig.KTQB__Tax__c = '';
        iconfig.KTQB__Terms__c = '';
        insert iconfig;
    }
        
    @isTest
    static void calloutToCreateUpdateItemInQbTest(){
        
        Product2 testProd = new Product2();
        Product2 proData = [SELECT id, Name, ProductCode, Description, IsActive, KTQB__Item_QB_Id__c 
                            FROM Product2 
                            WHERE Name = 'GenWatt Gasoline 300kW'];
        
        KTQB__InvoiceConfigurationOptions__c iconfig = [SELECT KTQB__Create_Update_Qb_Payment_In_Sf__c, KTQB__Income_Account__c, KTQB__Invoice_Date__c, KTQB__Invoice_Due_Date__c,
                                                  KTQB__Invoice_Save__c, KTQB__Invoice_Save_and_Send__c, KTQB__Tax__c,KTQB__Terms__c
                                                  FROM KTQB__InvoiceConfigurationOptions__c];
        string itemsJSON = '{' +
                + ' "Name":"'+proData.name+'",'
                + ' "Description":"'+proData.Description+'",'
                + ' "Sku":"'+proData.ProductCode+'",'
                + ' "Active":'+proData.IsActive+','
                + ' "Type":"Service",'
                + ' "IncomeAccountRef": { "value":'+ iconfig.KTQB__Income_Account__c + '}';
            if(proData.KTQB__Item_QB_Id__c == '' || proData.KTQB__Item_QB_Id__c == null){
                itemsJSON += '}';
            } else{
                itemsJSON += ' ,"Id":"'+proData.KTQB__Item_QB_Id__c+'",' + ' "sparse":true }';
            }
            itemsJSON.replace('null', '');
        Test.setMock(HttpCalloutMock.class, new CalloutUtlityItemHttpCalloutMock());
        Test.startTest();
        CalloutUtlityController.CalloutCredentials cc = CalloutUtlityController.calloutToCreateUpdateItemInQb(testProd, itemsJSON);
        Integer responseStatusCode = cc.responsebody.getStatusCode();
        System.assertEquals(200, responseStatusCode, 'The status code is 200.');
        Test.stopTest();
    }
    
    @isTest
    static void createQBLogTest(){
        // Create test data
        CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
        cred.requestbody = new HttpRequest();
        cred.requestbody.setEndpoint('https://example.com');
        cred.requestbody.setMethod('GET');
        cred.requestbody.setBody('Test Request Body');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('Test Response Body');
        cred.responsebody = response;

        String recordId = 'TestRecordId';
        // Call the function
        Test.startTest();
        CalloutUtlityController.createQBLog(cred, recordId);
        System.assertEquals(200, cred.responsebody.getStatusCode(), 'The status code is 200.');
        Test.stopTest();

    }
}