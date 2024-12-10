@isTest
public class CalloutLogDeleteBatchJobscheduled_Test {
	@isTest
    static void testExecuteMethod(){
        
        string cronExp = '0 0 0 1/1 * ? *';
                
        CalloutLogDeleteBatchJobscheduled scheduler = new CalloutLogDeleteBatchJobscheduled();
        String jobId = system.schedule('Test Job', cronExp , scheduler);
                
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, cronTriggers.size(), 'Batch job was not scheduled');
    }
}