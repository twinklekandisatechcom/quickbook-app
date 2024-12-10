/**
 * @description BatchToRefreshAccessTokenInQB is a batch and schedulable class that handles the refresh of access tokens for QuickBooks integration.
 */
public with sharing class BatchToRefreshAccessTokenInQB implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{
    /**
     * @description Constructs the query for the batch process. This query is used to fetch QuickBook Info records.
     * @param batchContext The context of the current batch job.
     * @return Database.QueryLocator The QueryLocator object for the batch execution.
    */
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, KTQB__Client_ID__c, KTQB__Client_Secret__c, KTQB__Access_Token__c, KTQB__Refresh_Token__c, Refresh_Token_Life_Days__c, KTQB__Redirect_URL__c, Last_Refresh_Token_Date__c FROM KTQB__Quickbook_Info__c WITH USER_MODE LIMIT 1';
        return Database.getQueryLocator(query);
    }
    /**
     * @description Executes the batch job, processing each QuickBook Info record, refreshing its access token if possible, and updating the record.
     * @param batchContext The context of the current batch job.
     * @param scope The list of KTQB__Quickbook_Info__c records to process.
    */
    public void execute(Database.BatchableContext batchContext, List<KTQB__Quickbook_Info__c> scope){
        KTQB__Quickbook_Info__c qbInfoRecord;
        for(KTQB__Quickbook_Info__c qbInfo : scope){    
            if(qbInfo.KTQB__Refresh_Token__c != null || String.isNotBlank(qbInfo.KTQB__Refresh_Token__c)){
                QuickBooksIntegerationController qb = new QuickBooksIntegerationController();
                qbInfoRecord = qb.fetchAccessTokenUsingRefreshToken(true);
            }
        }
        if(qbInfoRecord!=null){
            if(Schema.sObjectType.KTQB__Quickbook_Info__c.isUpdateable() && String.isNotBlank(qbInfoRecord.KTQB__Access_Token__c) && String.isNotBlank(qbInfoRecord.KTQB__Refresh_Token__c)){
                UPDATE as user qbInfoRecord;
            }
        }
    }
    /**
     * @description Finishes the batch job. This method is called after all batches are processed. It updates custom settings and schedules the next batch.
     * @param batchContext The context of the current batch job.
     */
    public void finish(Database.BatchableContext batchContext){
        SetupConfigController.updateCusSettingndScheduleBatch();
    }
    /**
     * @description Executes the batch class when scheduled.
     * @param sc The schedulable context from which the method can obtain information about the trigger event.
    */
    public void execute(SchedulableContext sc) {
        BatchToRefreshAccessTokenInQB b = new BatchToRefreshAccessTokenInQB(); 
        database.executebatch(b,1);
        
        System.abortJob(sc.getTriggerId());
    }
}