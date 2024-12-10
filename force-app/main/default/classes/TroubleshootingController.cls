/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Trouble Shooting Log Component [troubleShootingLogCmp]
 * @created on        : 2023
 * @last modified on  : 16-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
public with sharing class TroubleshootingController {

    /**
     * @description Trouble Shooting Log Component : Retrive data from custom setting.
     * @return Record data
     */
    @AuraEnabled public static SetupWrapper getSetupConfiguration(){
        SetupWrapper sw = new SetupWrapper();
        KTQB__Setup_Configuration__c sc = new KTQB__Setup_Configuration__c();
        try {
            sc = [ SELECT Id, Name, KTQB__Delete_Logs__c 
                   FROM KTQB__Setup_Configuration__c 
                   WHERE SetupOwnerId =: UserInfo.getOrganizationId() 
                   WITH USER_MODE];
            sw.id = sc.Id; 
            sw.deleteLog = sc.KTQB__Delete_Logs__c;
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return sw;
    }

    /**
     * @description Trouble Shooting Log Component : Retrive records from KTQB__QB_Log__c.
     * @return List of Logs
     */
    @AuraEnabled public static List<LogDataWrapper> getLogData(){
        List<KTQB__QB_Log__c> logList = new List<KTQB__QB_Log__c>();
        List<LogDataWrapper> logDataWrapList = new List<LogDataWrapper>(); 
        try{
            logList = [ SELECT Id, Name, KTQB__Request_Endpoint__c, KTQB__Request_Method__c, KTQB__Request__c, KTQB__Status_Code__c, KTQB__Response__c, KTQB__Status__c, CreatedDate 
                        FROM KTQB__QB_Log__c 
                        WHERE Callout_Log__c = true 
                        WITH USER_MODE 
                        ORDER BY CreatedDate DESC ];
            if(logList.size()>0){
                for(KTQB__QB_Log__c l : logList){
                    LogDataWrapper ldw = new LogDataWrapper();
                    ldw.id = l.Id;
                    ldw.name = l.Name;
                    ldw.nameUrl = '/'+l.Id;
                    if(!l.KTQB__Request_Endpoint__c.contains('tokens/bearer')){
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('account')) {ldw.requestEndpoint = 'Account';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('customer')) {ldw.requestEndpoint = 'customer';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('invoice')) {ldw.requestEndpoint = 'invoice';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('item')) {ldw.requestEndpoint = 'item';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('payment')) {ldw.requestEndpoint = 'payment';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('taxcode')) {ldw.requestEndpoint = 'TaxCode';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('taxrate')) {ldw.requestEndpoint = 'TaxRate';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('taxservice')) {ldw.requestEndpoint = 'taxservice';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('term')) {ldw.requestEndpoint = 'term';}
                        if(l.KTQB__Request_Endpoint__c.toLowerCase().contains('send')) {ldw.requestEndpoint = 'Invoice Email Send';}
                    }else{
                        ldw.requestEndpoint = 'connections';
                    }
                    //ldw.requestEndpoint = l.KTQB__Request_Endpoint__c;
                    ldw.requestMethod = l.KTQB__Request_Method__c;
                    ldw.requestBody = l.KTQB__Request__c;
                    ldw.responseStatusCode = l.KTQB__Status_Code__c;
                    ldw.responseBody = l.KTQB__Response__c;
                    ldw.responseStatus = l.KTQB__Status__c;
                    Datetime myDate = Datetime.newInstance(l.CreatedDate.year(), l.CreatedDate.month(), l.CreatedDate.day());
                    ldw.createdDate = myDate.format('MMM dd, yyyy');
                    logDataWrapList.add(ldw);
                }
            }
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return logDataWrapList;
    }

    /**
     * @description Trouble Shooting Log Component : Retrive data of Schedule Batches.
     * @param scheduleName - 'LogBatchDeleteSchedule'
     * @return SchedulableBatch Data
     */
    @AuraEnabled public static CronWrapper getScheduleData(String scheduleName){
            CronWrapper cw = new CronWrapper();
        List<CronTrigger> cron = new List<CronTrigger>(); 
        try {
            cron = [ SELECT Id, CronJobDetailId, CronJobDetail.Name, CronJobDetail.JobType, NextFireTime, PreviousFireTime, State, StartTime, EndTime, CronExpression, 
                     CreatedDate, TimesTriggered 
                     FROM CronTrigger 
                     WHERE CronJobDetail.Name =: scheduleName 
                     WITH USER_MODE];
            if(cron.size()>0){
                cw.id = cron[0].Id;
                cw.cronjobdetailId = cron[0].CronJobDetailId;
                cw.cronjobName = cron[0].CronJobDetail.Name;
                cw.cronjobType = cron[0].CronJobDetail.JobType;
                cw.state = cron[0].State;
                cw.cronExpression = cron[0].CronExpression;
                cw.timesTriggered = cron[0].TimesTriggered;
                cw.createdDate = cron[0].CreatedDate;
                cw.nextRunTime = cron[0].NextFireTime.format('dd-MM-yyyy h:mm a');
                cw.previousRunTime = cron[0].PreviousFireTime != null ? cron[0].PreviousFireTime.format('dd-MM-yyyy h:mm a') : '---';
                cw.startTime = cron[0].StartTime.format('dd-MM-yyyy h:mm a');
                cw.endTime = cron[0].EndTime;
            }
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return cw;
    }

    /**
     * @description Trouble Shooting Log Component : Set custom setting.
     * @param configData - Record data from custom setting
     * @param scheduleJobId - Id
     * @return Boolean
     */
    @AuraEnabled public static Boolean updateLogConfig(String configData, String scheduleJobId){
        Boolean updated = false;
        SetupWrapper sw = new SetupWrapper();
        try {
            if(String.isNotBlank(configData)){
                sw = (SetupWrapper)JSON.deserialize(configData,SetupWrapper.class);
                KTQB__Setup_Configuration__c sc = new KTQB__Setup_Configuration__c();
                sc.Id = sw.id;
                sc.KTQB__Delete_Logs__c = sw.deleteLog;
                update as user sc;
                updated = true;
                //Database.SaveResult sR = Database.update(sc,AccessLevel.User_mode);
                //updated = sR.isSuccess();

                if(sc.KTQB__Delete_Logs__c == 'None' && String.isNotBlank(scheduleJobId) && scheduleJobId != null){
                    System.abortJob(scheduleJobId);
                }else{
                    String expression = '';
                    Datetime todayDate = System.now();
                    Integer day = todayDate.day();
                    String dayName = todayDate.formatGMT('EEE').toUpperCase();
                    if(sc.KTQB__Delete_Logs__c == 'Daily'){
                        expression = '0 0 0 1/1 * ? *';
                    }else if(sc.KTQB__Delete_Logs__c == 'Weekly'){
                        expression = '0 0 0 ? * '+dayName+' *';
                    }else if(sc.KTQB__Delete_Logs__c == 'Monthly'){
                        expression = '0 0 0 '+day+' 1/1 ? *';
                    }else if(sc.KTQB__Delete_Logs__c == '6 Months'){
                        expression = '0 0 0 '+day+' 1/6 ? *';
                    }else if(sc.KTQB__Delete_Logs__c == 'Yearly'){
                        expression = '0 0 0 '+day+' 1 ? *';
                    }
                    
                    if(scheduleJobId != null && String.isNotBlank(scheduleJobId)){
                        System.abortJob(scheduleJobId);
                    }
                    system.schedule('LogBatchDeleteSchedule',expression, new CalloutLogDeleteBatchJobscheduled());
                }
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return updated;
    }

    /**
     * @description Trouble Shooting Log Component : Deleting records.
     * @param deleteList - Deleted list ids
     * @return Boolean
     */
    @AuraEnabled public static Boolean deleteAllLogs(List<Id> deleteList){
        Boolean successFlag = false;
        try {
            if(deleteList.size()>0){
                List<KTQB__QB_Log__c> logList = [SELECT Id FROM KTQB__QB_Log__c WHERE Id IN : deleteList WITH USER_MODE];
                if(logList.size() > 0){
                    delete as user logList;
                    successFlag = true;
                }else{
                    successFlag = false;
                }
                /*Database.DeleteResult[] drList = Database.delete(deleteList,AccessLevel.User_mode);
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        successFlag = true;
                        continue;
                    }else {
                        successFlag = false;
                        break;
                    }
                }*/
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return successFlag;
    }

    /** @description Trouble Shooting Log Component : Wrapper Class. */
    public class LogDataWrapper{
        /** @description Trouble Shooting Log Component : For id. */
        @AuraEnabled public String id {get;set;}
        /** @description Trouble Shooting Log Component : For name. */
        @AuraEnabled public String name {get;set;}
        /** @description Trouble Shooting Log Component : For nameUrl. */
        @AuraEnabled public String nameUrl {get;set;}
        /** @description Trouble Shooting Log Component : For requestEndpoint. */
        @AuraEnabled public String requestEndpoint {get;set;}
        /** @description Trouble Shooting Log Component : For requestMethod. */
        @AuraEnabled public String requestMethod {get;set;}
        /** @description Trouble Shooting Log Component : For requestBody. */
        @AuraEnabled public String requestBody {get;set;}
        /** @description Trouble Shooting Log Component : For responseStatusCode. */
        @AuraEnabled public String responseStatusCode {get;set;}
        /** @description Trouble Shooting Log Component : For responseBody. */
        @AuraEnabled public String responseBody {get;set;}
        /** @description Trouble Shooting Log Component : For responseStatus. */
        @AuraEnabled public String responseStatus {get;set;}
        /** @description Trouble Shooting Log Component : For createdDate. */
        @AuraEnabled public String createdDate {get;set;}
    }

    /** @description Trouble Shooting Log Component : Wrapper Class. */
    public class SetupWrapper{
        /** @description Trouble Shooting Log Component : For id. */
        @AuraEnabled public String id {get;set;}
        /** @description Trouble Shooting Log Component : For deleteLog. */
        @AuraEnabled public String deleteLog {get;set;}
    }

    /** @description Trouble Shooting Log Component : Wrapper Class. */
    public class CronWrapper{           
        /** @description Trouble Shooting Log Component : For id. */
        @AuraEnabled public String id {get;set;}
        /** @description Trouble Shooting Log Component : For cronjobdetailId. */
        @AuraEnabled public String cronjobdetailId {get;set;}
        /** @description Trouble Shooting Log Component : For cronjobName. */
        @AuraEnabled public String cronjobName {get;set;}
        /** @description Trouble Shooting Log Component : For cronjobType. */
        @AuraEnabled public String cronjobType {get;set;}
        /** @description Trouble Shooting Log Component : For state. */
        @AuraEnabled public String state {get;set;}
        /** @description Trouble Shooting Log Component : For cronExpression. */
        @AuraEnabled public String cronExpression {get;set;}
        /** @description Trouble Shooting Log Component : For timesTriggered. */
        @AuraEnabled public Integer timesTriggered {get;set;}
        /** @description Trouble Shooting Log Component : For createdDate. */
        @AuraEnabled public DateTime createdDate {get;set;}
        /** @description Trouble Shooting Log Component : For nextRunTime. */
        @AuraEnabled public String nextRunTime {get;set;}
        /** @description Trouble Shooting Log Component : For previousRunTime. */
        @AuraEnabled public String previousRunTime {get;set;}
        /** @description Trouble Shooting Log Component : For startTime. */
        @AuraEnabled public String startTime {get;set;}
        /** @description Trouble Shooting Log Component : For endTime. */
        @AuraEnabled public DateTime endTime {get;set;}
    }
}