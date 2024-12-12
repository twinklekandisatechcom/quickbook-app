/**
    * @description This class serves as a utility controller for handling QuickBooks callouts.
*/
public with sharing class CalloutUtlityController {
    /**
     * @description Static variable holding QuickBook Info record used across methods to avoid multiple queries and maintain state.
     */
    public static KTQB__Quickbook_Info__c  qbInfo = [SELECT Id,KTQB__QB_Company_Id__c,KTQB__Access_Token__c,KTQB__Sandbox_Url__c,KTQB__Last_Refresh_Token_Date__c FROM KTQB__Quickbook_Info__c WITH USER_MODE 
                                               LIMIT 1];
    public Static List<KTQB__QB_Log__c> qbLogs = new List<KTQB__QB_Log__c>();
    /**
     * @description Creates or updates an item in QuickBooks based on the provided product and action.
     * @param product The SObject that represents the product to be created or updated in QuickBooks.
     * @param action The action to perform, such as 'Insert' or 'Update'.
     * @return CalloutCredentials object containing request and response details.
     */
    public static CalloutCredentials calloutToCreateUpdateItemInQb(Sobject product, string action){
        CalloutCredentials cred = new CalloutCredentials();
        cred = calloutHelperMethod('POST', 'item?',action,product);
        return cred;
    }
    /**
     * @description  Helper method to make HTTP callouts to QuickBooks. It prepares the request, sends it, and processes the response.
     * @param method HTTP method to use, e.g., 'POST'.
     * @param endpoints Specific endpoint URL for the callout.
     * @param actionName Name of the action to dictate processing logic, like 'EmailSent'.
     * @param customer The customer SObject used to populate the request data.
     * @return CalloutCredentials object encapsulating the details of the HTTP request and response.
     */
    public static CalloutCredentials calloutHelperMethod(string method, string endpoints, string actionName, SObject customer){
        CalloutCredentials cred = new CalloutCredentials();
        try{
            KTQB__QB_Setting__c setting = KTQB__QB_Setting__c.getInstance();
            string endpoint;
            //Blob authHeader = Blob.valueOf(Utils.processDecryption(qbInfo.KTQB__Access_Token__c));
            //string authorizationHeader = 'Bearer '+EncodingUtil.base64Encode(authHeader);
            string body;
            endpoint =  qbInfo.KTQB__Sandbox_Url__c+Utils.processDecryption(qbInfo.KTQB__QB_Company_Id__c)+'/'+endPoints+'minorversion=';
            if(endPoints.contains('Item') || endPoints.contains('item')){
                endpoint += '4';
            }
            else{
                endpoint += setting.KTQB__QB_version__c.intValue();
            }
            Http hp =new Http();
            HttpRequest req = new HttpRequest();

            req.setEndpoint(EncodingUtil.urlEncode(endpoint, 'UTF-8'));
            req.setMethod(method);
            string authorizationHeader = 'Bearer '+Utils.processDecryption(qbInfo.KTQB__Access_Token__c);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            if(actionName == 'EmailSent'){
                 req.setHeader('Content-type', 'application/octet-stream');
            }
            else{ 
                req.setHeader('Content-type', 'application/json');
            }
            if(actionName == 'Insert' || actionName == 'Update'){
                body = '';
                req.setBody(body);
            }
            else if(actionName == 'EmailSent' || method == 'GET' || actionName == 'salesTax'){
                body='';
            }
            else{
                body = actionName;
                req.setBody(body);
            }
            HttpResponse res = hp.send(req);
            cred.requestBody = req;
            cred.responsebody =  res;
        }catch(exception e){
            HandleCustomException.LogException(e);
            //throw new AuraHandledException(e.getMessage());
        }
        return cred;
    }
    /**
     * @description Logs callout request and response details to a custom QuickBooks log object.
     * @param cred CalloutCredentials object holding the request and response details.
     * @param recordId The Salesforce record ID associated with this log entry.
     */
    public static void createQBLog(CalloutCredentials cred, string recordId){
        try{
            KTQB__QB_Log__c exc = new KTQB__QB_Log__c();
            exc.KTQB__Callout_Log__c = true;
            // HttpRequest request info
            exc.KTQB__Request_Endpoint__c = cred.requestbody.getEndpoint();
            exc.KTQB__Request__c =  cred.requestbody.getBody();
            exc.KTQB__Request_Method__c =  cred.requestbody.getMethod();
            exc.KTQB__Record_Id__c = recordId;
            //HttpResponse response info
            exc.KTQB__Response__c =  cred.responsebody.getBody();
            exc.KTQB__Status_Code__c = String.valueOf( cred.responsebody.getStatusCode());
            exc.KTQB__Status__c =  cred.responsebody.getStatus();
            if( cred.responsebody.getStatusCode() == 200){
                exc.KTQB__Error_Message__c = 'Success';
            }else{ 
                exc.KTQB__Error_Message__c = 'Error';
            }
            qbLogs.add(exc);
            
         }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Represents the credentials for a callout, encapsulating the HTTP request and response details.
     */
    public Class CalloutCredentials{
        public HttpRequest requestbody;
        public HttpResponse responsebody;
    }
    
}