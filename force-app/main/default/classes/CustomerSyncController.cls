/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Qb Customer Sync Component [qBCustomerSync]
 * @created on        : 2023
 * @last modified on  : 16-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 8/10 by Twinkle
 */ 
public with sharing class CustomerSyncController {

    /**
     * @description Qb Customer Sync Component : For fetching customer object api name from custom setting KTQB__InvoiceConfigurationOptions__c.
     * @param recId - Record id.
     * @return Object api name / 'fail'
     */
	@AuraEnabled public static string getCustomerOjectApiName(string recId){
        string result = '';
        Id recordId = (Id)recId;
        if (recordId != null) {
            SObjectType objectType = recordId.getSObjectType();
    		String objectTypeName = objectType.getDescribe().getName();
            KTQB__InvoiceConfigurationOptions__c config = [ SELECT Id, KTQB__Invoice_Customer_ChildObject_Api_Name__c FROM KTQB__InvoiceConfigurationOptions__c 
                                                      WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH USER_MODE];
            if(objectTypeName != config.KTQB__Invoice_Customer_ChildObject_Api_Name__c){
                result =  'fail';
            }else{
                result = config.KTQB__Invoice_Customer_ChildObject_Api_Name__c;
            }
        }
        return result;
    }

    /**
     * @description Qb Customer Sync Component : For fetching customer using object name.
     * @param recordId - record id.
     * @param objectName - object name.
     * @return SObject
     */
    @AuraEnabled public static SObject getCustomerUsingObjectName(string recordId, string objectName){
        Set<String> objectFields = new Set<String>();
    
        // Filter fields based on accessibility for the current user
        for (Schema.SObjectField field : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()) {
            if (field.getDescribe().isAccessible()) {
                objectFields.add(field.getDescribe().getName());
            }
        }
        Map<String, Object> bindValues = new Map<String, Object>{'recordId1' => recordId};
        String query = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(objectFields), ',')) + 
                    ' FROM ' + String.escapeSingleQuotes(objectName) + 
                    ' WHERE Id = :recordId1 LIMIT 1';
        List<SObject> records = Database.queryWithBinds(
            String.escapeSingleQuotes(query),
            bindValues,
            AccessLevel.USER_MODE
        );
        return records.isEmpty() ? null : records[0];
    }

    /**
     * @description Qb Customer Sync Component : For fetching QB Customer.
     * @param qbId - record id.
     * @return Map<String, Object>
     */
    @AuraEnabled public static Map<String, Object> getQBCustomer(STRING qbId){
        CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
        contact record = new contact();
        string query = 'customer/'+qbId+'?';
        cred = CalloutUtlityController.calloutHelperMethod('GET',query,'',record);
        CalloutUtlityController.createQBLog(cred,'');
        if(CalloutUtlityController.qbLogs.size() > 0 && Schema.sObjectType.KTQB__QB_Log__c.fields.KTQB__Callout_Log__c.isAccessible() &&
            Schema.sObjectType.KTQB__QB_Log__c.fields.KTQB__Error_Message__c.isAccessible() &&
            Schema.sObjectType.KTQB__QB_Log__c.fields.KTQB__Record_Id__c.isAccessible()){
            insert as user CalloutUtlityController.qbLogs;
        }
        string jsonResponse = cred.responsebody.getBody();
		Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        return resultMap;
    }

    /**
     * @description Qb Customer Sync Component : For data from record in Quickbook_Info__c.
     * @param syncToken
     * @param recordID
     * @param objectName
     * @param syncFieldName
     * @return 'success'
     */
    @AuraEnabled public static string updateCustomerInSF(string syncToken, string recordID, string objectName, string syncFieldName){
        SObject customerRecord = Schema.getGlobalDescribe().get(objectName).newSObject();
        customerRecord.put(syncFieldName,Decimal.valueOf(syncToken));
        customerRecord.put('Id',recordID);
        List<SObject> customerRecords = new List<SObject>();
		customerRecords.add(customerRecord);
        if(Schema.getGlobalDescribe().get(objectName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            update as user customerRecord;
        }
        
        return 'success'; 
    }
}