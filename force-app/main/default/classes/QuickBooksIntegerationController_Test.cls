/**
 * @description       : Test class for QuickBooksIntegerationController class
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 
 * @last modified on  : 08-10-2024(pmd scanning)
 * @last modified by  : vaibhav
 * modified on 09-10-2024 by Twinkle
 */ 

@isTest
public with sharing class QuickBooksIntegerationController_Test {
    /**
     * @description : testData
     */
    @testSetup
    public static void testData() {
        
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.KTQB__Client_ID__c  = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        qbInfo.KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        insert qbInfo;
        
        KTQB__QB_Setting__c qbSetting = new KTQB__QB_Setting__c();
                qbSetting.KTQB__QB_version__c = 70;
                qbSetting.KTQB__Access_Token_Endpoint_Url__c = System.label.KTQB_Access_Token_Endpoint_Url_c;
                insert qbSetting;
    }
    /**
    * @description : fetchAccessToken 
    */
    @isTest
    public static void fetchTokensTest() {
        KTQB__Quickbook_Info__c qb = new KTQB__Quickbook_Info__c();
        PageReference tpageRef = Page.QuickBookOAuthRedirectPage;
        Test.setCurrentPage(tpageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qb);
        QuickBooksIntegerationController ext = new QuickBooksIntegerationController(sc);
        ext.pageLoad();
        ext.fetchAuthorizationCode();
        
        Apexpages.currentPage().getParameters().put('code', 'testCode');
        Apexpages.currentPage().getParameters().put('realmId', 'testRealmId');
        Test.setMock(HttpCalloutMock.class, new FetchAccessTokenMock());
        
        PageReference ob = ext.fetchAccessToken();
        System.assertNotEquals(null, ob, 'Success');
        
        Test.stopTest();
    }
    
    /**
    * @description : fetchAccessTokenUsingRefreshTokenTest 
    */
    @isTest
    public static void fetchAccessTokenUsingRefreshTokenTest() {
        KTQB__Quickbook_Info__c qb = [
            SELECT id, KTQB__Refresh_Token__c
            FROM KTQB__Quickbook_Info__c
            LIMIT 1
        ];
        System.assertNotEquals(null, qb, 'Success');
        qb.KTQB__Refresh_Token__c = 'test token';
        update as user qb;
        
        PageReference tpageRef = Page.QuickBookOAuthRedirectPage;
        Test.setCurrentPage(tpageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qb);
        QuickBooksIntegerationController qic = new QuickBooksIntegerationController(sc);
        
        QuickBooksIntegerationController.AuthorizationCredentialsWrapper acwrapper = new QuickBooksIntegerationController.AuthorizationCredentialsWrapper();
        qic.wrpAuthCredentials = acwrapper;
        acwrapper.redirect_uri = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        acwrapper.client_id = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        acwrapper.client_secret = '8JyuVyO2Y30NXFn8A84Mry9NCpNVQBx9vhnw4LFY';
        QuickBooksIntegerationController.AuthorizationWrapper authWrapper = new QuickBooksIntegerationController.AuthorizationWrapper();
        authWrapper.access_token = '';
        authWrapper.refresh_token = '';
        
        Apexpages.currentPage().getParameters().put('code', 'testCode');
        Test.setMock(HttpCalloutMock.class, new FetchAccessTokenMock());
        
        Test.stopTest();
    }
    
    /**
     * @description : FetchAccessTokenMock  
     */
    public class FetchAccessTokenMock implements HttpCalloutMock {
        
        /**
        * @description : respond
        * @param req HTTPRequest object
        * @return HTTPResponse object
        */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token_type":"bearer","access_token":"eyJlbmMiOiJBMTI4Q0JDLUhTMjU2IiwiYWxnIjoiZGlyIn0..7P63YShYqw--G5of65xepg.t0X6JdDHJLReOTYwsISyKReRbSSOzCaApcWzbbC65HqwP8CDjTcmr650-oYOzTHF_Avoz-B5T6vSmgyhqBsE4cqLfjBc1gUeHfWLQhMoTWNZCR9LGMGoCZ01AbYphtOGwkZw7mlXeWJH_Rxhp5BVbIgqT93FnVAzRl8UCcSRsIhU17kIXdfBCL7r2BQrsQCvrPIS8ba8G2JhjKr4shB_lMpd4BTNBCNkq4gIYnVrU-v06FUlfWG_IEmn1nZ95BINHgyOv7skSZN0htitIAPw5JdiU6OnZ9kxZK74Efl-GgrgDHAEdDl_Zbo0_86cZuvf0md80H2URUkVqWL9OITLLwuf_QAcFsyXZr8-vwfoVHfELhpClQw0KB1w3i0Uvw-Yqewf9NWZtPlI4i3tJvsWZXbXjOYUZPMcISjGx_c0kgY9jH9RjsoIqx11fIkgcyOGHhq-zWHu4Z3WKDnXm3o9Vu1WkH5Y4H4dvyE6mA7boyoCh_PFCrQsAcKdHM8Zf4mzmMxcOWBGI-8EchRP0JvXEcfy3Q6jG2xGb5ELcLLPZyDljNlmtJhmX1gJcD556M_gwwzeJM6xCyM2XKJe_asO4SyQMkGSRqv0Yy5izzSYm25qZsJLw59WZ9gwJUQOpbNvIP5Ck6q0YutAKfe5V-pUcKiw5-NzN-zFZnBukyJ8h8XtnJWVPS1pXwCOyLBl6-tA-3e_14jJ7UDAc1PL7u__OSDh4Cdwhoc3_QS8QGvg6gjyqwu3rc9FzcQdCM4RR6YB.CTrjCTIG0SoZXg2d3d0ryQ","x_refresh_token_expires_in":8726400,"refresh_token":"AB11715949788E4CPA1ysYHYPdVArltVUMa5CP7gpNBlC6KRt3","expires_in":3600}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
     * @description : refreshTokenTest 
     */
    @isTest
    static void refreshTokenTest(){
        KTQB__Quickbook_Info__c qb = [
            SELECT id, KTQB__Refresh_Token__c
            FROM KTQB__Quickbook_Info__c
            LIMIT 1
        ];
        Test.startTest();
        QuickBooksIntegerationController.refreshToken();
        Test.stopTest();
        system.assertNotEquals(null,qb,'success');
    }
    
}