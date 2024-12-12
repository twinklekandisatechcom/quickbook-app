@isTest
public with sharing class BatchToRefreshAccessTokenInQB_Test {
	
   	@isTest
    static void testBatchClass(){
        // Create test data
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QB-01';
        qbInfo.KTQB__Client_ID__c  = 'TestClientId';
        qbInfo.KTQB__Client_Secret__c = 'TestClientSecret';
        qbInfo.KTQB__Sandbox_Url__c = 'https://test.com';
        qbInfo.KTQB__Redirect_URL__c = 'https://test.com';
        qbInfo.KTQB__Refresh_Token__c = 'TestToken';
        insert as user qbInfo;

        // Start the batch class
        Test.startTest();
        BatchToRefreshAccessTokenInQB b = new BatchToRefreshAccessTokenInQB();
        String jobId = System.schedule('Test Refresh Token Batch', '0 0 23 * * ?', b);
        system.System.debug('jobId = '+jobId);
        Test.stopTest();
		
        KTQB__Quickbook_Info__c updatedInfo = [SELECT KTQB__Refresh_Token__c FROM KTQB__Quickbook_Info__c WHERE Id = :qbInfo.Id LIMIT 1];
        System.assertEquals('TestToken', updatedInfo.KTQB__Refresh_Token__c, 'The refresh token did not update to the expected value.');

    }
}