@isTest
public with sharing class SetupConfigController_Test {
	
    /**
     * @description createData
     */
    @testSetup
    public static void createData(){
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QB-0001';
        qbInfo.KTQB__Client_ID__c  = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        qbInfo.KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        qbInfo.KTQB__Progress_Value__c = 33;
        qbInfo.KTQB__Completed_Steps__c = 1;
        qbInfo.KTQB__Total_Connection_Steps__c = 3;
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        insert qbInfo;
    }

    @isTest
    public static void getSetupConfigurationTest(){
        test.startTest();
        SetupConfigController.SetupConfigWrapper sscw = SetupConfigController.getSetupConfiguration();
        System.assertNotEquals(null, sscw, 'Success');
        test.stopTest();
    }
    
    @isTest
    public static void getSitesTest(){
        test.startTest();
        List<SetupConfigController.SiteWrapper> ssw = SetupConfigController.getSites();
        System.assertNotEquals(null, ssw, 'Success');
        test.stopTest();
    }
    
    @isTest
    public static void getSitesConfigURLTest(){
        String entity = 'Sites';
        test.startTest();
        String result = SetupConfigController.getSitesConfigURL(entity);
        test.stopTest();
        
        System.assertEquals(result, 'https://qbktdev-dev-ed.develop.my.salesforce.com/lightning/setup/CustomDomain/home','Success');
    }
    
    @isTest
    public static void getSecureSiteURLTest(){
        List<Site> siteList = [ SELECT Id, Name, Status, SiteType, GuestUserId, MasterLabel 
                                FROM Site 
                                WHERE Status = 'Active' AND SiteType = 'Visualforce'
                                WITH USER_MODE ];
        test.startTest();
        String result = SetupConfigController.getSecureSiteURL(siteList[0].Id);
        test.stopTest();
        System.assertEquals(result, 'https://qbktdev-dev-ed.develop.my.salesforce-sites.com/services/apexrest/KTQB/quickbookintegration/','Success');
    }
    
    @isTest
    public static void saveQbToSfTest(){
        KTQB__Quickbook_Info__c sc = [ SELECT Id, Name, KTQB__Completed_Steps__c, KTQB__Progress_Value__c, KTQB__Total_Connection_Steps__c
                           			  FROM KTQB__Quickbook_Info__c ];
        SetupConfigController.SetupConfigWrapper wrapper = new SetupConfigController.SetupConfigWrapper();
        wrapper.id = sc.Id;
        wrapper.name = '';
        wrapper.progressValue = 66;
        wrapper.completedSteps = 2;
        test.startTest();
        Boolean result = SetupConfigController.saveQbToSf(JSON.serialize(wrapper));
        test.stopTest();
        
        System.assertEquals(result, True, 'Success');
    }
    
    @isTest
    public static void updateCusSettingndScheduleBatchTest(){
        test.startTest();
        SetupConfigController.updateCusSettingndScheduleBatch();
        test.stopTest();
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'BatchToRefreshAccessTokenInQB'  WITH USER_MODE limit 1 ];
		System.assertNotEquals(null, cronTriggers, 'BatchToRefreshAccessTokenInQB is scheduled');

    }
    
    @isTest
    public static void createAuthProviderTest(){
        String clientId = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        String clientSecret = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe'; 
        String environmentValue = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        String redirectUrl = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        Integer progressValue = 25;
        Integer connectionStep = 1;
        Integer totalConnectionStep = 4;

        test.startTest();
        String result = SetupConfigController.createAuthProvider(clientId, clientSecret, environmentValue, redirectUrl, progressValue, connectionStep, totalConnectionStep);
        test.stopTest();
  
        System.assertEquals(result, 'https://qbktdev-dev-ed.develop.my.salesforce.com','Success');
    }
    
    @isTest
    public static void resetAuthProviderTest(){
     
        test.startTest();
        String result = SetupConfigController.resetAuthProvider();
        test.stopTest();
        
        System.assertEquals(result, 'QuickBook Info Reset','Success');
    }
}