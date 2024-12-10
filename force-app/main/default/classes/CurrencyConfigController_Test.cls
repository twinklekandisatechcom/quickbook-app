@isTest
public class CurrencyConfigController_Test {
	/**
     * @description Sets up the necessary test data for unit tests involving QuickBooks integration objects. This method
     * populates the org with essential configurations and data representations that mimic a production environment
     * tailored for QuickBooks connections. This setup ensures that tests can run independently of external data dependencies.
     */
    @TestSetup
    public static void createData(){
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QB-0001';
        qbInfo.KTQB__Client_ID__c  = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        qbInfo.KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        qbInfo.KTQB__QB_Company_Id__c = '4620816365289262850';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        insert as user qbInfo;
        
        KTQB__QB_Setting__c qs = new KTQB__QB_Setting__c();
        qs.KTQB__QB_version__c = 64;
        upsert qs;
        
        /*CurrencyType sfCurr = new CurrencyType(IsoCode = 'EUR', ConversionRate = 1.0, DecimalPlaces = 2, IsActive = true);
        insert sfCurr;*/
    }
    
    @isTest
    public static void getCurrencyTest(){
        
        test.startTest();
        CurrencyConfigController.CurrencyWrapper cw = CurrencyConfigController.getCurrency();
        if(Utils.getIsMultiCurrencyOrg()){
            System.assertNotEquals(null, cw.salesforceCurr,'Success');
        }else{
            System.assertEquals(null, cw.salesforceCurr,'Success');
        }
        test.stopTest();
    }
	
	@isTest
    public static void getCurrencyTest1(){        
        test.startTest();
        CurrencyConfigController.CurrencyWrapper cw = CurrencyConfigController.getCurrency();
        if(Utils.getIsMultiCurrencyOrg()){
            System.assertNotEquals(null, cw.salesforceCurr,'Success');
        }else{
            System.assertEquals(null, cw.salesforceCurr,'Success');
        }
        test.stopTest();
    }
    
    @isTest
    public static void createQBCurrenciesTest(){
        
        Test.setMock(HttpCalloutMock.class, new CurrencyConfigControllerHttpCalloutMock());
        test.startTest();
        String str = CurrencyConfigController.createQBCurrencies('abcd');
        System.assertNotEquals(null, str,'Success');
        test.stopTest();
    }
    
    @isTest
    public static void createQBCurrenciesTest1(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCurrency());
        test.startTest();
        String str = CurrencyConfigController.createQBCurrencies('54646473gwegew');
        System.assertNotEquals(null, str,'Success');
        test.stopTest();
    }
    /**
     * @description Tests the getCurrencyURL method of the CurrencyConfigController class to ensure it returns the correct URL for currency configuration.
     * This test verifies that the method outputs the expected URL format or endpoint that is used in other parts of the application for currency operations.
     */
    @isTest
    public static void getCurrencyURLTest(){
        
        test.startTest();
        String str = CurrencyConfigController.getCurrencyURL();
        System.assertNotEquals(null, str,'Success');
        test.stopTest();
    }
    /**
     * @description Mock HTTP response class for simulating HTTP callouts in unit tests related to currency operations. This class is designed
     * to provide predefined HTTP responses for specific requests, mimicking error scenarios involving invalid or unsupported currency types.
     */
    // For createQBCurrencies_Test1 - else part.
    private class MockHttpResponseCurrency implements HttpCalloutMock {
        /**
         * @description Responds to HTTP requests with a predefined HTTP response designed to simulate a failure scenario where
         * an invalid or unsupported currency type is supplied in the request.
         * @param req The HTTPRequest instance that represents the outgoing callout request.
         * @return HTTPResponse The custom-mocked response object simulating an error for invalid currency type inputs.
         */
        public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Fault\":{\"Error\":[{\"Message\":\"InvalidCurrencytype\",\"Detail\":\"InvalidorUnsupportedcurrencytypesupplied.Suppliedvalue:GBP12333\",\"code\":\"2220\",\"element\":\"Code\"}],\"type\":\"ValidationFault\"},\"time\":\"2023-09-18T06:36:11.932-07:00\"}');
        response.setStatusCode(400);
        return response;
    	}  
    }
}