/**
 * @description Custom exception handler class designed to log exceptions within Salesforce. This class captures exception details and system limits consumed at the time of the exception, and logs them to a custom object for auditing and debugging purposes.
 */
public with sharing class HandleCustomException extends Exception{
     /**
     * @description Logs an exception by creating a record in the KTQB__QB_Log__c object. This log includes details about the exception, the system governor limits at the time, and the location within the code where the exception occurred.
     * @param e The exception to log.
     */
    public static void logException(Exception e){
        try{
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.'); 
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            Set<String> stringHelper = new Set<String>{className,methodName};
            String joinedString = String.join(new List<String>(stringHelper), '.');
            //Governer Limit of executingQuery 
            String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String dmLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String dmlStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String cPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            
            //Log information in object
            KTQB__QB_Log__c exc = new KTQB__QB_Log__c();
            exc.KTQB__Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{queryLimit, dmLimit,dmlStat,cPUT});
            exc.KTQB__Error_Message__c = e.getMessage();
            exc.KTQB__Exception_Type__c = e.getTypeName();
            exc.KTQB__Line_Number__c = String.valueOf(e.getLineNumber());
            exc.KTQB__StackTrace__c = e.getStackTraceString();
            if(joinedString != null){
                exc.KTQB__Helper__c=joinedString;
            }
            //exc.ClassName__c=className;
            if(Schema.sObjectType.KTQB__QB_Log__c.isCreateable()){
                database.insert(exc,AccessLevel.User_mode); 
            }
        }catch(Exception ex){
            throw e;
        }            
    }
}