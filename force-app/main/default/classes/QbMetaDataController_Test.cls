@isTest
public with sharing class QbMetaDataController_Test {
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
        qs.KTQB__QB_version__c = 64;
        upsert qs;
        
		KTQB__QB_MetaData__c qbMD = new KTQB__QB_MetaData__c();
        qbMD.Name = 'Due on receipt';
        qbMD.KTQB__Active__c = true;
        qbMD.KTQB__Type__c = 'Term';
        qbMD.KTQB__QB_Id__c = '5';
        insert qbMD;
    }
    
   	@isTest
    static void syncQbInvoiceObjectTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTerm());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('Term');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
    @isTest
    static void syncQbInvoiceObjectTest1(){
   
        KTQB__QB_MetaData__c qbMD1 = new KTQB__QB_MetaData__c();
        qbMD1.Name = 'Tucson';
        qbMD1.KTQB__Active__c = true;
        qbMD1.KTQB__Type__c = 'salesTax';
        qbMD1.KTQB__QB_Id__c = '3';
        qbMD1.KTQB__Sales_Tax_Rate__c = 9.1;
        insert qbMD1;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTaxrate());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTaxcode());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('salesTax');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
    @isTest
    static void syncQbInvoiceObjectTest2(){
   
        KTQB__QB_MetaData__c qbMD1 = new KTQB__QB_MetaData__c();
        qbMD1.Name = 'Tucson';
        qbMD1.KTQB__Active__c = true;
        qbMD1.KTQB__Type__c = 'Account';
        qbMD1.KTQB__QB_Id__c = '3';
        qbMD1.KTQB__Sales_Tax_Rate__c = 9.1;
        insert qbMD1;
	
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAccount());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('Account');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
    @isTest
    static void syncQbInvoiceObjectTest3(){
   
        KTQB__QB_MetaData__c qbMD1 = new KTQB__QB_MetaData__c();
        qbMD1.Name = 'Tucson';
        qbMD1.KTQB__Active__c = true;
        qbMD1.KTQB__Type__c = 'CompanyCurrency';
        qbMD1.KTQB__QB_Id__c = '3';
        qbMD1.KTQB__Sales_Tax_Rate__c = 9.1;
        insert qbMD1;
	
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCompanyCurrency());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('CompanyCurrency');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
    @isTest
    static void syncQbInvoiceObjectTest4(){
   
        KTQB__QB_MetaData__c qbMD1 = new KTQB__QB_MetaData__c();
        qbMD1.Name = 'Tucson';
        qbMD1.KTQB__Active__c = true;
        qbMD1.KTQB__Type__c = 'Tax';
        qbMD1.KTQB__QB_Id__c = '3';
        qbMD1.KTQB__Sales_Tax_Rate__c = 9.1;
        insert qbMD1;
	
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseUnauthError());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('Tax');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
     @isTest
    static void syncQbInvoiceObjectTest5(){
   
        KTQB__QB_MetaData__c qbMD1 = new KTQB__QB_MetaData__c();
        qbMD1.Name = 'Tucson';
        qbMD1.KTQB__Active__c = true;
        qbMD1.KTQB__Type__c = 'Tax';
        qbMD1.KTQB__QB_Id__c = '3';
        qbMD1.KTQB__Sales_Tax_Rate__c = 9.1;
        insert qbMD1;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseUnauthWarning());
   		Test.startTest();
        String str = QbMetaDataController.syncQbInvoiceObject('Tax');
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
    
    private class MockHttpResponseTerm implements HttpCalloutMock {
       
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param request the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"Term\":[{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Dueonreceipt\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":0,\"Id\":\"1\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net10\",\"DiscountPercent\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":10,\"Id\":\"5\",\"MetaData\":{\"CreateTime\":\"2014-09-16T15:24:26-07:00\",\"LastUpdatedTime\":\"2014-09-16T15:24:26-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net15\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":15,\"Id\":\"2\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net30\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":30,\"Id\":\"3\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net60\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":60,\"Id\":\"4\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"DayOfMonthDue\":1,\"Name\":\"TermForV3Testing-1373590184130\",\"DiscountPercent\":0,\"sparse\":false,\"Active\":true,\"Type\":\"DATE_DRIVEN\",\"Id\":\"6\",\"MetaData\":{\"CreateTime\":\"2015-01-29T08:27:32-08:00\",\"LastUpdatedTime\":\"2015-01-29T08:27:32-08:00\"}}],\"maxResults\":6},\"time\":\"2015-07-28T08:26:23.942-07:00\"}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class MockHttpResponseTaxrate implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param request the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"QueryResponse":{"TaxRate":[{"Name":"AZ State tax","Description":"Sales Tax","Active":true,"RateValue":7.1,"AgencyRef":{"value":"1"},"SpecialTaxType":"NONE","DisplayType":"ReadOnly","domain":"QBO","sparse":false,"Id":"1","SyncToken":"0","MetaData":{"CreateTime":"2023-02-21T12:17:04-08:00","LastUpdatedTime":"2023-02-21T12:17:04-08:00"}},{"Name":"California","Description":"Sales Tax","Active":true,"RateValue":8,"AgencyRef":{"value":"2"},"SpecialTaxType":"NONE","DisplayType":"ReadOnly","domain":"QBO","sparse":false,"Id":"3","SyncToken":"0","MetaData":{"CreateTime":"2023-02-21T12:17:04-08:00","LastUpdatedTime":"2023-02-21T12:17:04-08:00"}},{"Name":"myNewTaxRateName","Description":"Sales Tax","Active":true,"RateValue":8,"AgencyRef":{"value":"1"},"TaxReturnLineRef":{"value":"1"},"SpecialTaxType":"NONE","DisplayType":"ReadOnly","domain":"QBO","sparse":false,"Id":"7","SyncToken":"0","MetaData":{"CreateTime":"2023-06-01T05:45:54-07:00","LastUpdatedTime":"2023-06-01T05:45:54-07:00"}},{"Name":"test","Description":"Sales Tax","Active":true,"RateValue":25,"AgencyRef":{"value":"3"},"SpecialTaxType":"NONE","DisplayType":"ReadOnly","domain":"QBO","sparse":false,"Id":"6","SyncToken":"0","MetaData":{"CreateTime":"2023-06-01T05:26:15-07:00","LastUpdatedTime":"2023-06-01T05:26:15-07:00"}},{"Name":"Tucson City","Description":"Sales Tax","Active":true,"RateValue":2,"AgencyRef":{"value":"1"},"SpecialTaxType":"NONE","DisplayType":"ReadOnly","domain":"QBO","sparse":false,"Id":"2","SyncToken":"0","MetaData":{"CreateTime":"2023-02-21T12:17:04-08:00","LastUpdatedTime":"2023-02-21T12:17:04-08:00"}}],"startPosition":1,"maxResults":5,"totalCount":5},"time":"2023-09-14T06:33:31.010-07:00"}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class MockHttpResponseTaxcode implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param request the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"QueryResponse":{"TaxCode":[{"Name":"California","Description":"California","Active":true,"Taxable":true,"TaxGroup":true,"SalesTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"3","name":"California"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"PurchaseTaxRateList":{"TaxRateDetail":[]},"domain":"QBO","sparse":false,"Id":"2","SyncToken":"0","MetaData":{"CreateTime":"2023-02-21T12:17:04-08:00","LastUpdatedTime":"2023-02-21T12:17:04-08:00"}},{"Name":"MyTaxCodeName","Description":"MyTaxCodeName","Active":true,"Taxable":true,"TaxGroup":true,"SalesTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"7","name":"myNewTaxRateName"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"PurchaseTaxRateList":{"TaxRateDetail":[]},"domain":"QBO","sparse":false,"Id":"5","SyncToken":"0","MetaData":{"CreateTime":"2023-06-01T05:45:54-07:00","LastUpdatedTime":"2023-06-01T05:45:54-07:00"}},{"Name":"test","Description":"test","Active":true,"Taxable":true,"TaxGroup":true,"SalesTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"6","name":"test"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"PurchaseTaxRateList":{"TaxRateDetail":[]},"domain":"QBO","sparse":false,"Id":"4","SyncToken":"0","MetaData":{"CreateTime":"2023-06-01T05:26:15-07:00","LastUpdatedTime":"2023-06-01T05:26:15-07:00"}},{"Name":"Tucson","Description":"Tucson","Active":true,"Taxable":true,"TaxGroup":true,"SalesTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"1","name":"AZ State tax"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"2","name":"Tucson City"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"PurchaseTaxRateList":{"TaxRateDetail":[]},"domain":"QBO","sparse":false,"Id":"3","SyncToken":"0","MetaData":{"CreateTime":"2023-02-21T12:17:04-08:00","LastUpdatedTime":"2023-02-21T12:17:04-08:00"}}],"startPosition":1,"maxResults":4,"totalCount":4},"time":"2023-09-14T06:29:55.033-07:00"}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class MockHttpResponseAccount implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param req the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"Account\":[{\"FullyQualifiedName\":\"CanadianAccountsReceivable\",\"domain\":\"QBO\",\"Name\":\"CanadianAccountsReceivable\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-06-23T09:38:18-07:00\",\"LastUpdatedTime\":\"2015-06-23T09:38:18-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"92\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyClients\",\"domain\":\"QBO\",\"Name\":\"MyClients\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-07-13T12:34:47-07:00\",\"LastUpdatedTime\":\"2015-07-13T12:34:47-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"93\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyJobs\",\"domain\":\"QBO\",\"Name\":\"MyJobs\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-01-13T10:29:27-08:00\",\"LastUpdatedTime\":\"2015-01-13T10:29:27-08:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"91\",\"SubAccount\":false}],\"maxResults\":3},\"time\":\"2015-07-13T12:35:57.651-07:00\"}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class MockHttpResponseCompanyCurrency implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param req the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            //response.setBody('{\"CompanyCurrency\":{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"GBP\",\"Name\":\"BritishPoundSterling\",\"sparse\":false,\"Active\":true,\"Id\":\"7\",\"MetaData\":{\"CreateTime\":\"2015-07-06T13:34:48-07:00\",\"LastUpdatedTime\":\"2015-07-06T13:34:48-07:00\"}},\"time\":\"2015-07-06T13:34:48.569-07:00\"}');
            response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"Account\":[{\"FullyQualifiedName\":\"CanadianAccountsReceivable\",\"domain\":\"QBO\",\"Name\":\"CanadianAccountsReceivable\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-06-23T09:38:18-07:00\",\"LastUpdatedTime\":\"2015-06-23T09:38:18-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"92\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyClients\",\"domain\":\"QBO\",\"Name\":\"MyClients\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-07-13T12:34:47-07:00\",\"LastUpdatedTime\":\"2015-07-13T12:34:47-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"93\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyJobs\",\"domain\":\"QBO\",\"Name\":\"MyJobs\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-01-13T10:29:27-08:00\",\"LastUpdatedTime\":\"2015-01-13T10:29:27-08:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"91\",\"SubAccount\":false}],\"maxResults\":3},\"time\":\"2015-07-13T12:35:57.651-07:00\"}');
            response.setStatusCode(200);
            return response;
        }
    } 
    
    private class MockHttpResponseUnauthError implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param req the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Fault":{"Error":[{"Message":"Invalid Email Address format","Detail":"Email Address does not conform to the syntax rules of RFC 822. Supplied value:test@test.com.test","code":"2210","element":"BillEmail"}],"type":"ValidationFault"},"time":"2023-09-12T22:33:45.419-07:00"}');
            response.setStatusCode(404);
            response.setStatus('Unauthorized');
            return response;
        }
    }
    
    private class MockHttpResponseUnauthWarning implements HttpCalloutMock {
        
        /**
     	* @description respond method is responsible for generating a simulated HTTP response when an HTTP request is received.
	    * @param req the incoming HTTP request 	
		* @return HttpResponse object, containing all the specified headers and body.
     	*/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{\"warnings\":null,\"intuitObject\":null,\"fault\":{\"error\":[{\"message\":\"message=AuthenticationFailed;errorCode=003200;statusCode=401\",\"detail\":\"Malformedbearertoken:tooshortortoolong\",\"code\":\"3200\",\"element\":null}],\"type\":\"AUTHENTICATION\"},\"report\":null,\"queryResponse\":null,\"batchItemResponse\":[],\"attachableResponse\":[],\"syncErrorResponse\":null,\"requestId\":null,\"time\":1694582987520,\"status\":null,\"cdcresponse\":[]}');
            response.setStatusCode(201);
            return response;
        }
    }
}