@isTest
public class DeleteLogsBatch_Test {
	@testSetup
    static void setupData() {
		// Create test data
        List<KTQB__QB_Log__c> qbLog = new List<KTQB__QB_Log__c>();
        for (Integer i = 0; i < 15; i++) {
            KTQB__QB_Log__c l = new KTQB__QB_Log__c();
            l.KTQB__Callout_Log__c = true;
            l.KTQB__Error_Message__c = 'Error';
            l.KTQB__Request__c = 'grant_type=refresh_token&refresh_token=AB11699869223EZanqsYWWx2ZLmgm7IdIgdTFgd33RJJtLi6cj';
            l.KTQB__Response__c = '{"error":"invalid_grant"}';
            l.KTQB__Record_Id__c = 'TESTRECORDID';
            l.KTQB__Status_Code__c = '400';
            l.KTQB__Status__c = 'Bad Request';
            l.KTQB__Status__c = 'Bad Request';
            l.KTQB__Request_Endpoint__c = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
            l.KTQB__Request_Method__c = 'POST';
            l.KTQB__Callout_Log__c = true;
            qbLog.add(l);
        }
        insert qbLog;    
    }
    
   	@isTest
    static void testBatchClass(){
		
        List<KTQB__QB_Log__c> qbLog = [ SELECT Id FROM KTQB__QB_Log__c ];
        
        // Test the batch class
        Test.startTest();
        Database.executeBatch(new DeleteLogsBatch()); // 10 is the batch size
        Test.stopTest();
		
        List<KTQB__QB_Log__c> remainingLogs = [SELECT Id FROM KTQB__QB_Log__c WHERE Id IN :qbLog];
        System.assertEquals(0, remainingLogs.size(), 'Not all logs were successfully deleted');
    }
    
    @isTest
    static void testBatchClass1(){
		
        List<KTQB__QB_Log__c> qbLog = [ SELECT Id FROM KTQB__QB_Log__c ];
        
        // Create an instance of the batch class
        DeleteLogsBatch batch = new DeleteLogsBatch();
        
        batch.errorMap.put(qbLog[1].Id, 'This is a sample error message');
        batch.errorMap.put(qbLog[2].Id, 'This is a sample error message');
                
        Database.executeBatch(batch);
        
        System.assertEquals(2, batch.errorMap.size(), 'Errors occurred during batch execution');
        List<KTQB__QB_Log__c> newList = [SELECT Id FROM KTQB__QB_Log__c WHERE Id IN :batch.errorMap.keyset()];
        System.assertEquals(2, newList.size(), 'ErrorLogs inserted successfully');

    }
    
}