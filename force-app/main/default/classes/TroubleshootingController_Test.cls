@isTest
public with sharing class TroubleshootingController_Test {
    
    /**
     * @description createData
     */
    @testSetup
    public static void createData(){
        KTQB__Setup_Configuration__c sc = new KTQB__Setup_Configuration__c();
        sc.KTQB__Delete_Logs__c = 'Daily';
        upsert sc;
        
        List<KTQB__QB_Log__c> log = new List<KTQB__QB_Log__c>{ 
            new KTQB__QB_Log__c( KTQB__Callout_Log__c = true, KTQB__Status__c = 'OK', KTQB__Status_Code__c = '200', KTQB__Request_Endpoint__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365289262850/customer/317?minorversion=69' ),
            new KTQB__QB_Log__c( KTQB__Callout_Log__c = true, KTQB__Status__c = 'OK', KTQB__Status_Code__c = '200', KTQB__Request_Endpoint__c = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer' )    
        };
        insert log;
    }
    
    @isTest
    static void testgetSetupConfigTest() {
        Test.StartTest();
        TroubleshootingController.SetupWrapper tsw = TroubleshootingController.getSetupConfiguration();
        System.assertNotEquals(null, tsw, 'Success');
        Test.StopTest();
    }
    
    @isTest
    static void getLogDataTest() {
        Test.StartTest();
        List<TroubleshootingController.LogDataWrapper> lst =TroubleshootingController.getLogData();
        System.assertNotEquals(null, lst, 'Success');
        Test.StopTest();
    }
    
    @isTest
    static void getScheduleDataTest() {
        String cronexp = '0 0 0 1/1 * ? *';
        Test.startTest();
        String jobId = '';
        jobId = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr'].Id;
        if(String.isNotBlank(jobId)){
            System.abortJob(jobId);
        }
        String schjobId = System.schedule('CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr',cronexp, new CalloutLogDeleteBatchJobscheduled());
        TroubleshootingController.CronWrapper tcw = TroubleshootingController.getScheduleData('CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr');
        System.assertEquals(schjobId,String.valueOf(tcw.id).substring(0, 15),'Success');
        System.abortJob(schjobId);
        Test.StopTest();
    }
    
    @isTest
    static void updateLogConfigTest1() {
        KTQB__Setup_Configuration__c sc = [ SELECT Id, Name, KTQB__Delete_Logs__c
                           			  FROM KTQB__Setup_Configuration__c ];
        TroubleshootingController.SetupWrapper tsw = new TroubleshootingController.SetupWrapper();
        tsw.id = sc.Id;
        tsw.deleteLog = sc.KTQB__Delete_Logs__c;
        String jobId = '';
        jobId = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr'].Id;
        if(String.isNotBlank(jobId)){
            System.abortJob(jobId);
        }
        Test.startTest();
        Boolean flag1 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),null);
        System.assertEquals(flag1,true,'Success');
        
        // For extra coverage and for catch block. [Start]
        tsw.deleteLog =  'Weekly';
        Boolean flag2 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),null);
		System.assertEquals(flag2,true,'Success');
        
        tsw.deleteLog =  'Monthly';
        Boolean flag3 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),null);
		System.assertEquals(flag3,true,'Success');
        
        tsw.deleteLog =  '6 Months';
        Boolean flag4 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),null);
		System.assertEquals(flag4,true,'Success');
        
        tsw.deleteLog =  'Yearly';
        Boolean flag5 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),null);
		System.assertEquals(flag5,true,'Success');
        Test.StopTest();
        // For extra coverage and for catch block. [End]
    }
    
    @isTest
    static void updateLogConfigTest2() {
        KTQB__Setup_Configuration__c sc = [ SELECT Id, Name, KTQB__Delete_Logs__c
                           			  FROM KTQB__Setup_Configuration__c ];
        TroubleshootingController.SetupWrapper tsw = new TroubleshootingController.SetupWrapper();
        tsw.id = sc.Id;
        tsw.deleteLog = sc.KTQB__Delete_Logs__c;
        String jobId = '';
        jobId = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr'].Id;
        if(String.isNotBlank(jobId)){
            System.abortJob(jobId);
        }
        Test.startTest();
        String cronexp = '0 0 0 1/1 * ? *';
        String schjobId = System.schedule('CommIncrementalSitemapJob-00D8Y000001Yzlc-0DM8Y000000LwMr',cronexp, new CalloutLogDeleteBatchJobscheduled());
        tsw.deleteLog = 'Weekly';
        Boolean flag1 = TroubleshootingController.updateLogConfig(JSON.serialize(tsw),schjobId);
        System.assertEquals(flag1,true,'Success');
        
        Test.StopTest();
    }
    
    @isTest
    static void deleteAllLogsTest() {
        List<KTQB__QB_Log__c> logList = [ SELECT Id, Name, Request_Endpoint__c, Request_Method__c, Request__c, Status_Code__c, Response__c, Status__c, CreatedDate
                           	              FROM KTQB__QB_Log__c ];
        List<Id> logIdList = new List<Id>();
        logIdList.add(logList[0].Id);
        
        Test.StartTest();
        Boolean result = TroubleshootingController.deleteAllLogs(logIdList);
        System.assertEquals(result,true,'Success');
        Test.StopTest();
    }
}