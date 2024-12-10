@isTest
public class HandleCustomExceptionTest {
	@isTest
    static void testLogException(){
        CalloutException e = new CalloutException();
    	e.setMessage('This is a constructed exception!');
        
        Test.startTest();
        HandleCustomException.logException(e);

        KTQB__QB_Log__c log = [SELECT Id, Name, KTQB__Callout_Log__c FROM KTQB__QB_Log__c LIMIT 1 ];
        System.assertEquals(false, log.KTQB__Callout_Log__c,'Calllout log value should be false.');
        Test.stopTest();
    }
}