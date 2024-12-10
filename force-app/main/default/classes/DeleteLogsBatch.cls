/**
 * @description A batch class for deleting logs marked for callout from the KTQB__QB_Log__c object.
 */
public with sharing class DeleteLogsBatch implements Database.Batchable<sObject>{

    public Set<Id> allSuccessId = new Set<Id>();
    public Map<Id,String> errorMap = new Map<Id,String>();
    /**
     * @description Constructs the batch query.
     * @param bc The context of the batch job.
     * @return Database.QueryLocator The query locator for the batch job.
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM KTQB__QB_Log__c where KTQB__Callout_Log__c = true WITH USER_MODE';
       
        return Database.getQueryLocator(query);
    }
    /**
     * @description Executes a batch of records.
     * @param bc The context of the batch job.
     * @param scope List of KTQB__QB_Log__c records to be processed.
     */
    public void execute(Database.BatchableContext bc, List<KTQB__QB_Log__c> scope){
        // Delete Logs
        Database.DeleteResult[] drList = Database.delete(scope, false,AccessLevel.User_mode);

        // Iterate through each returned result
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                allSuccessId.add(dr.getId());
            }else {
                // Operation failed, so get all errors
                String error = '';              
                for(Database.Error err : dr.getErrors()) {
                    error += err.getStatusCode() +':'+err.getMessage() +', ';
                }
                errorMap.put(dr.getId(),error);
            }
        }
    }
    /**
     * @description Finalizes the batch job after completion.
     * Logs any errors encountered during the execution.
     * @param bc The context of the batch job.
     */
    public void finish(Database.BatchableContext bc) {
        if(errorMap.keySet().size()>0){
            List<KTQB__QB_Log__c> logList = new List<KTQB__QB_Log__c>();
            for(Id i : errorMap.keySet()){
                KTQB__QB_Log__c exc = new KTQB__QB_Log__c();
                exc.KTQB__Error_Message__c = errorMap.get(i);
                exc.KTQB__StackTrace__c = i;
                exc.KTQB__Helper__c = 'DeleteLogsBatch.execute';
                //exc.ClassName__c = 'DeleteLogsBatch';
                logList.add(exc);
            }

            if(logList.size()>0){
                database.insert(logList, AccessLevel.User_mode);
            }
        }
    }
}