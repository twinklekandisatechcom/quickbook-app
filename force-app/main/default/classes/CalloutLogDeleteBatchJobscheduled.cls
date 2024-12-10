/**
 * @description This class implements Schedulable and is designed to delete logs periodically through batch processing.
 */
public with sharing class CalloutLogDeleteBatchJobscheduled implements Schedulable {
    /**
     * @description Scheduled execution method that instantiates and executes a batch job to delete logs.
     * @param sc Context of the scheduled job, providing methods to control the job's execution.
     */
    public void execute(SchedulableContext sc) {
        DeleteLogsBatch b = new DeleteLogsBatch(); 
        database.executebatch(b,200);
    }
}