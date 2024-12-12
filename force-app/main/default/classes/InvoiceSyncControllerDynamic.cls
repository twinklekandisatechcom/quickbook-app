/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 13-09-2023
 * @last modified on  : 09-10-2024
 * @last modified by  : Mangesh D Kadam
 */ 
/*
NOTE ::: 
	1. commented Product_Configuration_Options__c custom setting by twinkle on 25th-01 as we are not using this.
	2. commented KTQB__InvoiceConfigurationOptions__c.Payment_Item_Object_Name__c custom setting by twinkle on 25th-01 as we are not using this.
*/
//PMD.ApexSuggestUsingNamedCred - For avoiding authoziaztion credetials pmd error : as we used Custom Object for Authorization.
//PMD.UnusedLocalVariable - For avoiding variable defined but not used pmd error : 'invoiceCustomerRecordId'(genericCreateUpadteQbInv) & 'qbInvId'(createUpdateSFQbPayment) 
//Modified by Twinkle on 15-10-2024
//@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.UnusedLocalVariable')
//Modified by Twinkle on 05-12-2024
// AccessLevel.System_mode); //AccessLevel.User_mode need to change this to System_Mode, as the Guest does not have access to the SF records.
@RestResource(urlMapping='/quickbookintegration/*')
global without sharing class InvoiceSyncControllerDynamic {
    //public static KTQB__Quickbook_Info__c  qbInfo = [SELECT Id,KTQB__QB_Company_Id__c,KTQB__Access_Token__c,KTQB__Refresh_Token_Life_Days__c,KTQB__Refresh_Token__c,KTQB__Last_Refresh_Token_Date__c,KTQB__Sandbox_Url__c ,KTQB__Completed_Steps__c,KTQB__Webhook_Verifier_Token__c FROM KTQB__Quickbook_Info__c WITH USER_MODE LIMIT 1] ?? null;
    public static KTQB__Quickbook_Info__c qbInfo = [SELECT Id, KTQB__QB_Company_Id__c, KTQB__Access_Token__c, KTQB__Refresh_Token_Life_Days__c, KTQB__Refresh_Token__c, KTQB__Last_Refresh_Token_Date__c, KTQB__Sandbox_Url__c, KTQB__Completed_Steps__c, KTQB__Webhook_Verifier_Token__c 
    FROM KTQB__Quickbook_Info__c WITH USER_MODE LIMIT 1];
   
    public Static List<KTQB__QB_Log__c> qbLogs = new List<KTQB__QB_Log__c>();
	public Static KTQB__QB_Setting__c setting = KTQB__QB_Setting__c.getInstance();
    public static Map<String,String> mapQbSfInvFieldName = new Map<String,String>();
    public static Map<String,String> mapQbSfLineFieldName = new Map<String,String>();
    public static Map<String,String> mapQbSfCustFieldName = new Map<String,String>();
    public static Map<String,String> mapQbSfPaymentFieldName = new Map<String,String>();
    public static Map<String,String> mapQbSfPaymentItemFieldName = new Map<String,String>();

    public static Map<String,String> mapQbSfInvQbFldNameDataType = new Map<String,String>();
    public static Map<String,String> mapQbSfLineQbFldNameDataType = new Map<String,String>();
    public static Map<String,String> mapQbSfCustQbFldNameDataType = new Map<String,String>();
    public static Map<String,String> mapQbSfPaymentQbFldNameDataType = new Map<String,String>();
    public static Map<String,String> mapQbSfPaymentItemQbFldNameDataType = new Map<String,String>();

    public static String invoiceObjectApiName;
    public static String invoiceLineObjectApiName;
    public static String customerObjectApiName;
    public static String paymentObjectApiName;
    public static String paymentItemObjectApiName;

    public static String invoiceFieldApiNameOnLine;

    public static SObject contactSOBject;
    public static SObject invoiceSOBject;
    public static SObject lineItemSOBject;
    public static SObject paymentSOBject;
    public static SObject paymentItemSOBject;

    public static Boolean isCalloutReAuthenticated = false;

    public static List<String> activeCurrenciesIsoCode = new List<String>();

    public static List<String> invoiceAccessFlds = new List<String>();
    public static List<String> lineItemsAccessFlds = new List<String>();
    public static List<String> customerAccessFlds = new List<String>();
    
    public static List<String> invoiceCreatableFlds = new List<String>();
    public static List<String> lineItemsCreatableFlds = new List<String>();
    public static List<String> customerCreateableFlds = new List<String>();

    public static Schema.sObjectField invoiceExternalId; 
    public static Schema.sObjectField lineItemsExternalId; 
    public static Schema.sObjectField customerExternalId;

    /**
     * @description Constructor
     */ 
    public InvoiceSyncControllerDynamic() {
        generateObjectFieldMapping();
    }

    /**
     * @description 1. Generic Method : To fetch all the Object and Field Name based on the Customer Mappings.
     */ 
    public static void generateObjectFieldMapping(){
        try{
            //1. fetched all Invoice Mapped fields.
            Map<String, KTQB__Invoice_Object_Field_Mapping__c> invoiceMappedfields = KTQB__Invoice_Object_Field_Mapping__c.getAll();
            for(String dataset : invoiceMappedfields.keySet()){
                if(String.isNotBlank(invoiceMappedfields.get(dataset).KTQB__Field_API_Name__c) && String.isNotBlank(invoiceMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c)){   
                    mapQbSfInvFieldName.put(invoiceMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,invoiceMappedfields.get(dataset).KTQB__Field_API_Name__c);
                    if(String.isNotBlank(invoiceMappedfields.get(dataset).Data_Type__c)){
                        mapQbSfInvQbFldNameDataType.put(invoiceMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,invoiceMappedfields.get(dataset).KTQB__Data_Type__c);
                    }
                }
            }  

            //2. fetched all Invoice Line Item Mapped fields.
            Map<String, KTQB__LineItem_Object_Field_Mapping__c> invoiceLineMappedfields = KTQB__LineItem_Object_Field_Mapping__c.getAll();
            for(String dataset : invoiceLineMappedfields.keySet()){
                if(String.isNotBlank(invoiceLineMappedfields.get(dataset).KTQB__Field_API_Name__c) && String.isNotBlank(invoiceLineMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c) ){ 
                    mapQbSfLineFieldName.put(invoiceLineMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,invoiceLineMappedfields.get(dataset).KTQB__Field_API_Name__c);
                    if(String.isNotBlank(invoiceLineMappedfields.get(dataset).Data_Type__c)){
                        mapQbSfLineQbFldNameDataType.put(invoiceLineMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,invoiceLineMappedfields.get(dataset).KTQB__Data_Type__c);
                    }
                }
            }

            //3. fetched all Customer Mapped fields.
            Map<String, KTQB__Customer_Object_Field_Mapping__c> customerMappedfields = KTQB__Customer_Object_Field_Mapping__c.getAll();
            for(String dataset : customerMappedfields.keySet()){
                if(String.isNotBlank(customerMappedfields.get(dataset).KTQB__Field_API_Name__c) && String.isNotBlank(customerMappedfields.get(dataset).QuickBook_Field_Api_Name__c) ){
                    mapQbSfCustFieldName.put(customerMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,customerMappedfields.get(dataset).KTQB__Field_API_Name__c);
                    if(String.isNotBlank(customerMappedfields.get(dataset).KTQB__Data_Type__c)){
                        mapQbSfCustQbFldNameDataType.put(customerMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,customerMappedfields.get(dataset).KTQB__Data_Type__c);
                    }
                }
            }

            //4. fetched all Payment Mapped fields.
            Map<String, KTQB__Payment_Object_Field_Mapping__c> paymentMappedfields = KTQB__Payment_Object_Field_Mapping__c.getAll();
            for(String dataset : paymentMappedfields.keySet()){
                if(String.isNotBlank(paymentMappedfields.get(dataset).KTQB__Field_API_Name__c) && String.isNotBlank(paymentMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c)){   
                    mapQbSfPaymentFieldName.put(paymentMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,paymentMappedfields.get(dataset).KTQB__Field_API_Name__c);
                    if(String.isNotBlank(paymentMappedfields.get(dataset).Data_Type__c)){
                        mapQbSfPaymentQbFldNameDataType.put(paymentMappedfields.get(dataset).KTQB__QuickBook_Field_Api_Name__c,paymentMappedfields.get(dataset).KTQB__Data_Type__c);
                    }
                }
            } 

            //5. fetched all Payment Mapped fields.
            //deleting Payment_Item_Object_Field_Mapping__c by Twinkle
            /*Map<String, Payment_Item_Object_Field_Mapping__c> paymentItemMappedfields = Payment_Item_Object_Field_Mapping__c.getAll();
            for(String dataset : paymentItemMappedfields.keySet()){
                if(String.isNotBlank(paymentItemMappedfields.get(dataset).Field_API_Name__c) && String.isNotBlank(paymentItemMappedfields.get(dataset).QuickBook_Field_Api_Name__c)){   
                    mapQbSfPaymentItemFieldName.put(paymentItemMappedfields.get(dataset).QuickBook_Field_Api_Name__c,paymentItemMappedfields.get(dataset).Field_API_Name__c);
                    if(String.isNotBlank(paymentItemMappedfields.get(dataset).Data_Type__c)){
                        mapQbSfPaymentItemQbFldNameDataType.put(paymentItemMappedfields.get(dataset).QuickBook_Field_Api_Name__c,paymentItemMappedfields.get(dataset).Data_Type__c);
                    }
                }
            } */

            //6. fetched the invoice,line item and customer mapped Object Api Name.
            KTQB__InvoiceConfigurationOptions__c invoiceConfigCs = KTQB__InvoiceConfigurationOptions__c.getOrgDefaults();
            invoiceObjectApiName = invoiceConfigCs.KTQB__Invoice_Object_Name__c;
            invoiceLineObjectApiName = invoiceConfigCs.KTQB__LineItem_Object_Name__c;
            customerObjectApiName = invoiceConfigCs.KTQB__Invoice_Customer_ChildObject_Api_Name__c;
            paymentObjectApiName = invoiceConfigCs.KTQB__Payment_Object_Name__c;
            //paymentItemObjectApiName =invoiceConfigCs.Payment_Item_Object_Name__c;
            invoiceFieldApiNameOnLine = invoiceConfigCs.KTQB__LineItem_ChildObject_Name__c;

            //7. Getting All the Sobjects.
            //To get the SObject of Type Invoice .
            if(invoiceSOBject == null){
                if(String.isNotBlank(invoiceObjectApiName)){
                    //invoiceSOBject = Schema.getGlobalDescribe().get(invoiceObjectApiName).newSObject();
                    List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{invoiceObjectApiName});
                    Schema.DescribeSObjectResult describeResult = describeResults[0]; 
                    invoiceSObject = describeResult.getSObjectType().newSObject(); 

                }
            }

            //To get the SObject of Type Line Item .
            if(lineItemSOBject == null){
                if(String.isNotBlank(invoiceLineObjectApiName)){
                    //lineItemSOBject = Schema.getGlobalDescribe().get(invoiceLineObjectApiName).newSObject();
                    List<Schema.DescribeSObjectResult> describeResultsLine = Schema.describeSObjects(new String[]{invoiceLineObjectApiName});
                    Schema.DescribeSObjectResult describeResultLine = describeResultsLine[0]; 
                    lineItemSOBject = describeResultLine.getSObjectType().newSObject(); 
                }
            }
        
            //To get the SObject of Type Customer .
            if(contactSOBject == null){
                if(String.isNotBlank(customerObjectApiName)){
                    //contactSOBject = Schema.getGlobalDescribe().get(customerObjectApiName).newSObject();
                    List<Schema.DescribeSObjectResult> describeResultsCustomer = Schema.describeSObjects(new String[]{customerObjectApiName});
                    Schema.DescribeSObjectResult describeResultCustomer = describeResultsCustomer[0]; 
                    contactSOBject = describeResultCustomer.getSObjectType().newSObject(); 
                }
            }

            //To get the SObject of Type Payment .
            if(paymentSOBject == null){
                if(String.isNotBlank(paymentObjectApiName)){
                    //paymentSOBject = Schema.getGlobalDescribe().get(paymentObjectApiName).newSObject();
                    List<Schema.DescribeSObjectResult> describeResultsPayment = Schema.describeSObjects(new String[]{paymentObjectApiName});
                    Schema.DescribeSObjectResult describeResultPayment = describeResultsPayment[0]; 
                    paymentSOBject = describeResultPayment.getSObjectType().newSObject(); 
                }
            }

            //To get all the active currencies of the org.
            if(Utils.getIsMultiCurrencyOrg() == true){
                for(CurrencyType curr : [ SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = true WITH USER_MODE]){
                    activeCurrenciesIsoCode.add(curr.IsoCode);
                }
            }

            //To get the SObject of Type Payment Item .  //NOT IN USE NOW
            // if(paymentItemSOBject == null){
            //     if(String.isNotBlank(paymentItemObjectApiName)){
            //         paymentItemSOBject = Schema.getGlobalDescribe().get(paymentItemObjectApiName).newSObject();
            //     }
            // }

        //to get all the accessible fields for all the Mapped Objects.
        checkForAccesibleFields();
        }catch(Exception exp){
            HandleCustomException.logException(exp);
        }
    }
    /**
     * @description : This method checks and retrieves the accessible, creatable, and external ID fields
     */
    public static void checkForAccesibleFields(){
        //to get all the Invoice Accessible fields for the running users.
        try{
            if(String.isNotBlank(invoiceObjectApiName) && mapQbSfInvFieldName.keySet().size()>0){
                //Map<String, Schema.SObjectField> invoicefieldMap = Schema.getGlobalDescribe().get(invoiceObjectApiName).getDescribe().fields.getMap();
                List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{invoiceObjectApiName});
                Schema.DescribeSObjectResult describeResult = describeResults[0]; 
                
                Map<String, Schema.SObjectField> invoiceFieldMap = describeResult.fields.getMap(); 

                for (String fieldName : mapQbSfInvFieldName.Values()) {
                    if (invoicefieldMap.get(fieldName).getDescribe().isAccessible()) {
                        invoiceAccessFlds.add(fieldName);
                    }
                    if (invoicefieldMap.get(fieldName).getDescribe().isCreateable()) {
                        invoiceCreatableFlds.add(fieldName);
                    }
                    if (invoicefieldMap.get(fieldName).getDescribe().isExternalID()) {
                        if(fieldName == mapQbSfInvFieldName.get('Id')){
                            invoiceExternalId = invoicefieldMap.get(fieldName);
                        }
                    }
                }
            }

            //to get all the Invoice Line Items Accessible fields for the running users.
            if(String.isNotBlank(invoiceLineObjectApiName) && mapQbSfLineFieldName.keySet().size()>0){
                //Map<String, Schema.SObjectField> lineItemfieldMap = Schema.getGlobalDescribe().get(invoiceLineObjectApiName).getDescribe().fields.getMap();
                List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{invoiceLineObjectApiName});
                Schema.DescribeSObjectResult describeResult = describeResults[0]; 
                
                Map<String, Schema.SObjectField> lineItemFieldMap = describeResult.fields.getMap();

                for (String fieldName : mapQbSfLineFieldName.Values()) {
                    if (lineItemfieldMap.get(fieldName).getDescribe().isAccessible()) {
                        lineItemsAccessFlds.add(fieldName);
                    }
                    if (lineItemfieldMap.get(fieldName).getDescribe().isCreateable()) {
                        lineItemsCreatableFlds.add(fieldName);
                    }
                    if (lineItemfieldMap.get(fieldName).getDescribe().isExternalID()) {
                        if(fieldName == mapQbSfLineFieldName.get('LineItemId')){
                            lineItemsExternalId = lineItemfieldMap.get(fieldName);
                        }
                    } 
                }
            }

            //to get all the customer Accessible fields for the running users.
            if(String.isNotBlank(customerObjectApiName) && mapQbSfCustFieldName.keySet().size()>0){
                //Map<String, Schema.SObjectField> customerfieldMap = Schema.getGlobalDescribe().get(customerObjectApiName).getDescribe().fields.getMap();
                List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{customerObjectApiName});
                Schema.DescribeSObjectResult describeResult = describeResults[0]; 
                
                Map<String, Schema.SObjectField> customerFieldMap = describeResult.fields.getMap(); 

                for (String fieldName : mapQbSfCustFieldName.Values()) {
                    if (customerfieldMap.get(fieldName).getDescribe().isAccessible()) {
                        customerAccessFlds.add(fieldName);
                    }
                    if (customerfieldMap.get(fieldName).getDescribe().isCreateable()) {
                        customerCreateableFlds.add(fieldName);
                    }
                    if (customerfieldMap.get(fieldName).getDescribe().isExternalID()) {
                        if(fieldName == mapQbSfCustFieldName.get('Id')){
                            customerExternalId = customerfieldMap.get(fieldName);
                        }
                    } 
                }
            }

            /*System.debug('@@@ invoiceCreatableFlds ::: '+invoiceCreatableFlds.toString());
            System.debug('@@@ invoiceAccessFlds ::: '+invoiceAccessFlds.toString());

            System.debug('@@@ lineItemsCreatableFlds ::: '+lineItemsCreatableFlds.toString());
            System.debug('@@@ lineItemsAccessFlds ::: '+lineItemsAccessFlds.toString());

            System.debug('@@@ customerCreateableFlds ::: '+customerCreateableFlds.toString());
            System.debug('@@@ customerAccessFlds ::: '+customerAccessFlds.toString());*/
        }catch(Exception ex){
             HandleCustomException.logException(ex);
        }
    }

// ======================================================================   Callout Methods ======================================================================

    /**
     * @description Callout Method : for making a Query callout.
     * @param qbQuery
     * @param qbObjectName
     * @param cred
     * @return HTTPModel warapper
     */ 
    public static HTTPModel findQueryDetailInQBByFilter(String qbQuery, String qbObjectName,CalloutDetails cred) {
        if(qbObjectName.toLowerCase() == 'invoice'){
            qbQuery += '&include=invoiceLink';
        }
        return doHTTPCallout(
            'GET',
            'application/json',            
            '/query?query=' + qbQuery,
            null,
            cred
        );
    }
  
    /**
     * @description 
     * Callout Method : for delete/void Quickbook invoice.
     * @param operation
     * @param requestBody
     * @param cred
     * @return HTTPModel warapper
     */   
    public static HTTPModel deleteVoidQBrecordCallout(String operation,String requestBody,CalloutDetails cred) {    
        return doHTTPCallout(
        'POST',
        'application/json',            
        '/invoice?operation=' + operation+'&minorversion='+setting.KTQB__QB_version__c.intValue(),
        requestBody,
        cred
        );
    }

    /**
     * @description Callout Method : for creating/Updating invoice and line item in QuickBook.
     * @param requestBody
     * @param cred
     * @return HTTPModel warapper
     */        
    public static HTTPModel createUpdateQBInvAndLine(String requestBody,CalloutDetails cred) {    
        //system.debug('setting.KTQB__QB_version__c.intValue() ='+setting.KTQB__QB_version__c.intValue());
        return doHTTPCallout(
        'POST',
        'application/json',            
        '/invoice?&minorversion='+setting.KTQB__QB_version__c.intValue(),
        requestBody,
        cred
        );
    }

    /**
     * @description Callout Method : for creating/Updating Payment and line item in QuickBook.
     * @param requestBody
     * @param cred
     * @return HTTPModel warapper
     */   
    public static HTTPModel createUpdateQBPayment(String requestBody,CalloutDetails cred) {    
        return doHTTPCallout(
        'POST',
        'application/json',            
        '/payment?minorversion='+setting.KTQB__QB_version__c.intValue(),
        requestBody,
        cred
        );
    }

    /**
     * @description Main Method : Actual Method used for the callout.
     * @param method
     * @param contentType
     * @param apiPath
     * @param dataBody
     * @param credObj
     * @return HTTPModel warapper
     */
    public static HTTPModel doHTTPCallout(String method,String contentType,String apiPath,String dataBody,CalloutDetails credObj){
        boolean tempBoolean = false; //For scanning
        HTTPModel model = new HTTPModel();
        CalloutDetails cred = (CalloutDetails)JSON.deserialize(JSON.serialize(credObj), CalloutDetails.class);
        try {
            if(qbInfo!=null){
                string endpoint = qbInfo.KTQB__Sandbox_Url__c+Utils.processDecryption(qbInfo.KTQB__QB_Company_Id__c);
                HttpRequest req = new HttpRequest();
                req.setMethod(method);
                req.setHeader('Content-Type', contentType);
                req.setEndpoint(endpoint + apiPath);
                req.setHeader('Authorization', 'Bearer ' +  Utils.processDecryption(qbInfo.KTQB__Access_Token__c));
                req.setHeader('Accept', 'application/json'); 
            
                if (dataBody != null){
                    req.setBody(dataBody);
                }                
                req.setTimeout(12 * 10000);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                model.isCalloutException = false;
                model.response = res.getBody();
            
                if(res.getStatusCode() >= 300){
                    model.isCalloutException = true;  
                    //To do Re-Authentication after Authentiction Failure and resuming the callout opertion unintereptedly.
                    Boolean isAuthenticationError = false;
                    QBErrorResponse.errorCls errorObj =  QBErrorResponse.parseJSON(model.response);
                    if(errorObj.Fault.type.equalsIgnoreCase('AUTHENTICATION') || errorObj.Fault.type.equalsIgnoreCase('VALIDATION')){
                        for(QBErrorResponse.cls_Error er: errorObj.Fault.Error){
                            //System.debug('@@@ Qb error Message :: '+er.Message+' Status code :: '+res.getStatusCode());
                            //TODO : we will add these error codes to custom label or custom setting after discussion.
                            if((er.code.equalsIgnoreCase('3200') || er.code.equalsIgnoreCase('3202')) && res.getStatusCode() >= 400){
                            // if(er.Message.containsIgnoreCase('message=AuthenticationFailed') && res.getStatusCode() == 401){
                                isAuthenticationError = true;
                                break;
                            }
                        }
                        if(isAuthenticationError == true){
                            if(qbInfo.KTQB__Refresh_Token_Life_Days__c >0 && String.isNotBlank(qbInfo.KTQB__Refresh_Token__c)){
                                QuickBooksIntegerationController qb = new QuickBooksIntegerationController();
                                KTQB__Quickbook_Info__c qbInfoRecord = qb.fetchAccessTokenUsingRefreshToken(false);
                                if(String.isNotBlank(qbInfoRecord.KTQB__Access_Token__c) && String.isNotBlank(qbInfoRecord.KTQB__Refresh_Token__c)){
                                    if(isCalloutReAuthenticated == false){
                                        qbinfo.KTQB__Access_Token__c = qbInfoRecord.KTQB__Access_Token__c;
                                        qbinfo.KTQB__Refresh_Token__c = qbInfoRecord.KTQB__Refresh_Token__c;
                                        qbinfo.KTQB__Last_Refresh_Token_Date__c = qbInfoRecord.KTQB__Last_Refresh_Token_Date__c;
                                        isCalloutReAuthenticated = true;
                                        HTTPModel httpDetails = doHTTPCallout(method,contentType,apiPath,dataBody,credObj);
                                        if(Schema.sObjectType.KTQB__Quickbook_Info__c.isUpdateable() && httpDetails.isCalloutException == false){
                                            UPDATE as user qbInfoRecord;
                                        }
                                        model = httpDetails;
                                    }else{
                                        //TODO NOW: log error if the Re-Authentication is failed more than once .
                                        tempBoolean = true; 
                                        throw new QBSfSyncCustomException('Salesforce Re-Authentiction failed , please check the setup configurations settings and if needed re-authenticate again from setup page.');
                                    }
                                }
                            }
                        }
                    }
                }

                //For Logging :
                if(cred!=null){
                    cred.requestBody = '{endpoint:'+endpoint + apiPath+',method:'+method+',body:'+dataBody+',authorizationHeader:'+'Bearer ' + Utils.processDecryption(qbInfo.KTQB__Access_Token__c)+
                    ',contentTypeHeader:'+contentType+'}';
                    // cred.requestBody = dataBody;
                    cred.requestEndpoint =  endpoint;
                    cred.requestMethod=  method;
                    cred.responsebody =  res.getBody();
                    cred.status =  res.getStatus();
                    cred.statusCode =   String.valueOf(res.getStatusCode());
                    cred.errorMsg = model.isCalloutException == true ? 'Failed':'Success';
                    createQBLog(cred);
                }   
            }
            // else{
            //     tempBoolean = true; //For scanning
            //     //TODO NOW: here we have to throw error or Log if the Access token or QuickBookInfo record is null.
            //     throw new QBSfSyncCustomException('Salesforce Quickbook Authentication failure, check if access token not null or check if Authentication done from Setup page.');
            // }
        }
        catch (Exception ex) {
            HandleCustomException.logException(ex);
            model.isCalloutException = true;
            model.response = ex.getLineNumber() + ' ' + ex.getMessage();
        }
        return model;
    }

    /**
     * @description For creating QB log.
     * @param cred
     */
    public static void createQBLog(CalloutDetails cred){ 
        if(cred != null){
            KTQB__QB_Log__c qb = new KTQB__QB_Log__c();
            qb.KTQB__Callout_Log__c = true;
            qb.KTQB__Request__c = cred.requestBody;
            qb.KTQB__Request_Endpoint__c = cred.requestEndpoint;
            qb.KTQB__Request_Method__c =  cred.requestMethod;
            qb.KTQB__Response__c = cred.responseBody;
            qb.KTQB__Status__c = cred.status;
            qb.KTQB__Status_Code__c = cred.statusCode;
            qb.KTQB__Error_Message__c = cred.errorMsg;
            qb.KTQB__Helper__c = cred.helper;
            qb.KTQB__Record_Id__c = cred.recordId;
            
            qbLogs.add(qb);
        }
    }


    /** @description : Wrapper Class */
    public class HTTPModel {
        public String response = '';
        public Boolean isCalloutException = false;
        public Boolean isLogException = false;
    }

    /** @description : Wrapper Class */
    public Class CalloutDetails{
        public string requestbody;
        public string requestEndpoint;
        public string requestMethod;
        public string responsebody;
        public string status;
        public string statusCode;
        public string errorMsg;
        public string helper;
        public string recordId;
    }

    /** @description : Wrapper Class */
    public class ComponentResponse{
        /**
         * @description Reference to the response status.
         */
        @AuraEnabled public string status;
        /**
         * @description Reference to the response message.
         */
        @AuraEnabled public string message;
        /**
         * @description Reference to the response isConnectionError.
         */
        @AuraEnabled public boolean isConnectionError;

        /**
         * @description ComponentResponse - constructor.
         */
        public ComponentResponse(){
            status= '';
            message= '';
            isConnectionError=false;
        }
    }

//===================================================================================== QB-TO-SF AUTOMATIC SYNC ===================================================================================================//

    /** @description Wrapper Class : For capturing the Changes Made in QB. */
    public class WebHookrep {
        public List<EventNotifications> eventNotifications;
    }

    /** @description Wrapper Class : For capturing the Changes Made in QB. */
    public class EventNotifications {
        public String realmId;
        public DataChangeEvent dataChangeEvent;
    }

    /** @description Wrapper Class : For capturing the Changes Made in QB. */
    public class Entities {
        public String name;
        public String id;
        public String operation;
        public String lastUpdated;
    }

    /** @description Wrapper Class : For capturing the Changes Made in QB. */
    public class DataChangeEvent {
        public List<Entities> entities;
    }

    /**
     * @description 
     */
    public class QBSfSyncCustomException extends Exception {}

    /**
     * @description REST POST METHOD: Qb-Sf Automatic Sync for CUSTOMER, INVOICE and PAYMENTS.
     */
    @HttpPost global static void checkWebhookConnection() {
        generateObjectFieldMapping();

        RestRequest restReq = RestContext.request;
        String jsonData = restReq.requestBody.toString();

        //TEST FOR VERIFICATION ::: 
        String webhookKey = Utils.processDecryption(qbInfo.KTQB__Webhook_Verifier_Token__c);

        String qbSignature = RestContext.request.headers.get('intuit-signature');
        Blob signedPayload = Crypto.generateMac('hmacSHA256',
            Blob.valueOf(jsonData),
            Blob.valueOf(webhookKey)
        );
        String encodedPayload = EncodingUtil.base64Encode(signedPayload);
        RestContext.response.statusCode = encodedPayload == qbSignature ? 200 : 401;

        /*System.debug('@@@ encodedPayload ::: '+encodedPayload);
        System.debug('@@@ qbSignature ::: '+qbSignature);
        System.debug('@@@ RestContext.response.statusCode ::: '+RestContext.response.statusCode);*/

        if(encodedPayload == qbSignature){
            processWebhookData(jsonData);
        }
    }

    /**
     * @description REST POST METHOD: Qb-Sf Automatic Sync for CUSTOMER, INVOICE and PAYMENTS.
     * @param jsonData - WebHookrep.
     */
    public static void processWebhookData(String jsonData) {
        WebHookrep re = (WebHookrep) JSON.deserialize(jsonData, WebHookrep.class);

        Map<String, Set<String>> mapObjectvsIds = new Map<String, Set<String>>();
        Map<String, String> mapObjIdvsOperation = new Map<String, String>(); 
        
        Map<String, Set<String>> mapDeletedObjvsIds = new Map<String, Set<String>>();

        List<String> customerQbIds = new List<String>();
        List<String> lstCustomerIdsToQuery = new List<String>();
        Map<String,SObject> mapQbIdQbCustomer = new Map<String,SObject>();

        List<String> invoiceQbIds = new List<String>();
        List<String> lstInvoiceIdsToQuery = new List<String>();
        Map<String,SObject> mapQbIdQbInvoice = new Map<String,SObject>();

        List<String> paymentQbIds=new List<String>();
        List<String> lstPaymentIdsToQuery = new List<String>();
        Map<String,SObject> mapQbIdQbPayment = new Map<String,SObject>();

        /*
		Commented by twinkle 25th-01
		Contact_Configuration_Options__c qbCustomSet = Contact_Configuration_Options__c.getOrgDefaults();*/

        List<QBCustomerResponse.XCustomer> lstQbCustomer = new List<QBCustomerResponse.XCustomer>();
        Map<String, QBInvoiceResponse.XInvoice> mapQBInvoice = new Map<String, QBInvoiceResponse.XInvoice>();

        List<SObject> lstinvpayment = new List<SObject>();
        map<String,List<SObject>> mapInvoiceIdPaymentSObj = new  map<String,List<SObject>>();
        map<String,List<String>> mapPayIdInvoiceIds = new  map<String,List<String>>();
        map<String,Integer> mapPayIdSyncToken = new  map<String,Integer>();

        Boolean doProcessInvItems = true;
        try{
            for (EventNotifications en : re.eventNotifications) {
                if (
                    en.dataChangeEvent != null &&
                    en.dataChangeEvent.entities != null &&
                    en.dataChangeEvent.entities.size() > 0
                ) {
                    for (Entities e : en.dataChangeEvent.entities) {
                        if (mapObjectvsIds.containsKey(e.name)) {
                            mapObjectvsIds.get(e.name).add(e.id);
                        } else {
                            mapObjectvsIds.put(e.name, new Set<String>{ e.id });
                        }
                        mapObjIdvsOperation.put(e.id,e.operation);
                    }
                }
            }

            for (String strKey : mapObjectvsIds.keySet()) {
               
                List<String> lstIds = new List<String>(mapObjectvsIds.get(strKey));
                    
                for(String cusnm : lstIds){
                    if(mapObjIdvsOperation.get(cusnm).toLowerCase() == 'delete'){
                        if (mapDeletedObjvsIds.containsKey(strKey.toLowerCase())) {
                            mapDeletedObjvsIds.get(strKey.toLowerCase()).add(cusnm);
                        } else {
                            mapDeletedObjvsIds.put(strKey.toLowerCase(), new Set<String>{ cusnm });
                        }
                    }else{
                        //NOTE : Do nothing when the operation is Void.
                        if (strKey.toLowerCase() == 'customer') {
                            customerQbIds.add('\''+ EncodingUtil.urlEncode(cusnm, 'UTF-8') + '\'');
                            lstCustomerIdsToQuery.add(cusnm);
                        }else if (strKey.toLowerCase() == 'invoice'){
                            invoiceQbIds.add('\''+ EncodingUtil.urlEncode(cusnm, 'UTF-8') + '\'');
                            lstInvoiceIdsToQuery.add(cusnm);
                        } else if (strKey.toLowerCase() == 'payment'){
                            paymentQbIds.add('\''+ EncodingUtil.urlEncode(cusnm, 'UTF-8') + '\'');   
                            lstPaymentIdsToQuery.add(cusnm);
                        }
                    }
                }
            }

            if(lstCustomerIdsToQuery.size()>0){
                //Customer query checks
                if(String.isNotBlank(mapQbSfCustFieldName.get('Id')) && String.isNotBlank(mapQbSfCustFieldName.get('SyncToken')) && String.isNotBlank(customerObjectApiName)){
                    String query = 'SELECT Id,'+String.escapeSingleQuotes(mapQbSfCustFieldName.get('Id'))+','+String.escapeSingleQuotes(mapQbSfCustFieldName.get('SyncToken'))+' FROM '+String.escapeSingleQuotes(customerObjectApiName) + ' WHERE '+ String.escapeSingleQuotes(mapQbSfCustFieldName.get('Id')) +' IN: lstCustomerIdsToQuery WITH USER_MODE';
                    for(SObject con: Database.query(query)){
                        mapQbIdQbCustomer.put((String) con.get(mapQbSfCustFieldName.get('Id')),con);
                    }   
                }
            }
            if(lstinvoiceIdsToQuery.size()>0){
                //Invoice query checks
                if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && String.isNotBlank(mapQbSfInvFieldName.get('SyncToken')) && String.isNotBlank(invoiceObjectApiName)){
                    String query = 'SELECT Id,'+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'))+','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('SyncToken'))+' FROM '+String.escapeSingleQuotes(invoiceObjectApiName) + ' WHERE '+ String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id')) +' IN: lstinvoiceIdsToQuery WITH USER_MODE';
                    for(SObject qbInv: Database.query(query)){
                        mapQbIdQbInvoice.put((String) qbInv.get(mapQbSfInvFieldName.get('Id')),qbInv);
                    }
                }
            }
            if(lstPaymentIdsToQuery.size()>0){
                //Payment query checks
                if(String.isNotBlank(mapQbSfPaymentFieldName.get('Id')) && String.isNotBlank(mapQbSfPaymentFieldName.get('SyncToken')) && String.isNotBlank(paymentObjectApiName)){
                    String query = 'SELECT Id,'+String.escapeSingleQuotes(mapQbSfPaymentFieldName.get('Id'))+','+String.escapeSingleQuotes(mapQbSfPaymentFieldName.get('SyncToken'))+' FROM '+String.escapeSingleQuotes(paymentObjectApiName) + ' WHERE '+ String.escapeSingleQuotes(mapQbSfPaymentFieldName.get('Id')) +' IN: lstPaymentIdsToQuery WITH USER_MODE';
                   
                    for(SObject pay: Database.query(query)){
                        mapQbIdQbPayment.put((String) pay.get(mapQbSfPaymentFieldName.get('Id')),pay);
                    }
                }
            }
        }catch(Exception exp){
            HandleCustomException.logException(exp);  
        }

        //Capturing the changes in Customer, Invoice or Payment based on the change made Qb.
        for (String strKey : mapObjectvsIds.keySet()) {
           
            if (strKey.toLowerCase() == 'customer') {
                String qbQuery = EncodingUtil.urlEncode('select ', 'UTF-8')+'*'+EncodingUtil.urlEncode(' from customer where id IN ', 'UTF-8')+'('+String.join(customerQbIds,',')+')'+'&minorversion='+setting.KTQB__QB_version__c.intValue();
                   
                    CalloutDetails cred = new CalloutDetails();
                    cred.helper = 'InvoiceSyncController.processWebhookData Customer';
                    HTTPModel objHTTP = findQueryDetailInQBByFilter(
                        qbQuery,
                        'Customer',
                        cred);

                /* commented by twinkle 25th-01
                 old ver : if (!objHTTP.isCalloutException && qbCustomSet.Create_Update_Qb_Customer_In_Sf__c == true) {
                    QBCustomerResponse.CustomerRes objQBCustomer = QBCustomerResponse.parseJSON(
                    objHTTP.response
                    );*/
					if (!objHTTP.isCalloutException) {
                    QBCustomerResponse.CustomerRes objQBCustomer = QBCustomerResponse.parseJSON(
                    objHTTP.response
                    );
                    if (
                    objQBCustomer.QueryResponse != null &&
                    objQBCustomer.QueryResponse.Customer != null
                    ) {
                        for (
                            QBCustomerResponse.XCustomer objcus : objQBCustomer.QueryResponse.Customer
                        ) {
                            if(String.isNotBlank(mapQbSfCustFieldName.get('SyncToken'))){
                                if((mapQbIdQbCustomer.get(objcus.Id) == null) 
                                    || (mapQbIdQbCustomer.containsKey(objcus.Id) 
                                    && Integer.valueOf(objcus.SyncToken) >= Integer.valueOf( mapQbIdQbCustomer.get(objcus.Id).get(mapQbSfCustFieldName.get('SyncToken'))))) {
                                        lstQbCustomer.add(objcus);
                                }
                                else if(mapQbIdQbCustomer.containsKey(objcus.Id) && 
                                        (Integer.valueOf(objcus.SyncToken) < Integer.valueOf( mapQbIdQbCustomer.get(objcus.Id).get(mapQbSfCustFieldName.get('SyncToken'))))) {
                                           
                                            try{
                                                throw new QBSfSyncCustomException('Salesforce Customer Sync Token is greater than the Qb.');
                                            }catch(Exception exp){
                                                HandleCustomException.logException(exp);
                                            }
                                        //*** RARE CASE *** (This might happen when Twinkle's class might fail or Connection Failure/System failure during SF TO QB Sync.)
                                }
                            }
                        }
                    }
                }
            }else if (strKey.toLowerCase() == 'invoice') {
                if(invoiceQbIds.size() > 0){
                    String qbQuery = EncodingUtil.urlEncode('select ', 'UTF-8')+'*'+EncodingUtil.urlEncode(' from invoice where id IN ', 'UTF-8')+'('+String.join(invoiceQbIds,',')+')'+'&minorversion='+setting.KTQB__QB_version__c.intValue();
                   
                    CalloutDetails cred = new CalloutDetails();
                    cred.helper = 'InvoiceSyncController.processWebhookData Invoice';
                    // cred.recordId = qbInv.Id;
                    HTTPModel objHTTP = findQueryDetailInQBByFilter(
                        qbQuery,
                        'invoice',
                        cred);
                    if (!objHTTP.isCalloutException) {
                        QBInvoiceResponse.InvoiceRes objQBInvoice = QBInvoiceResponse.parseJSON(
                            objHTTP.response
                        );
                        if (
                            objQBInvoice.QueryResponse != null &&
                            objQBInvoice.QueryResponse.Invoice != null
                        ) {
                            for (
                                QBInvoiceResponse.XInvoice objinv : objQBInvoice.QueryResponse.Invoice
                            ) {
                                if(String.isNotBlank(mapQbSfInvFieldName.get('SyncToken'))){
                                    if((mapQbIdQbInvoice.get(objinv.Id) == null) 
                                            || (mapQbIdQbInvoice.containsKey(objinv.Id) 
                                            && Integer.valueOf(objinv.SyncToken) >= Integer.valueOf(mapQbIdQbInvoice.get(objinv.Id).get(mapQbSfInvFieldName.get('SyncToken'))))){
                                                mapQBInvoice.put(objinv.Id, objinv);
                                                doProcessInvItems = true;
                                    }
                                    else if(mapQbIdQbInvoice.containsKey(objinv.Id) && 
                                            (Integer.valueOf(objinv.SyncToken) < Integer.valueOf(mapQbIdQbInvoice.get(objinv.Id).get(mapQbSfInvFieldName.get('SyncToken'))))){
                                           
                                            try{
                                                throw new QBSfSyncCustomException('Salesforce Invoice Sync Token is greater than the Qb.');
                                            }catch(Exception exp){
                                                HandleCustomException.logException(exp);
                                            }
                                        //*** RARE CASE *** (This might happen when Twinkle's class might fail or Connection Failure/System failure during SF TO QB Sync.)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else if (strKey.toLowerCase() == 'payment') {
                if(KTQB__InvoiceConfigurationOptions__c.getOrgDefaults().KTQB__Create_Update_Qb_Payment_In_Sf__c){ 
                    CalloutDetails cred = new CalloutDetails();
                    cred.helper = 'InvoiceSyncController.processWebhookData Payment';
                    String qbQuery = EncodingUtil.urlEncode('select ', 'UTF-8')+'*'+EncodingUtil.urlEncode(' from Payment where id IN ', 'UTF-8')+'('+String.join(paymentQbIds,',')+')'+'&minorversion='+setting.KTQB__QB_version__c.intValue();
                    HTTPModel objHTTP = findQueryDetailInQBByFilter(
                        qbQuery,
                        'Payment',
                        cred
                    );
                    if (!objHTTP.isCalloutException) {
                        QBPaymentResponse.PaymentRes objQBPayment = QBPaymentResponse.parseJSON(
                        objHTTP.response
                        );
                        //Prepare set of invoice ids
                        List<String> lstPaymentInvoiceIds = new List<String>();
                        if (
                            objQBPayment.QueryResponse != null &&
                            objQBPayment.QueryResponse.Payment != null
                        ) {
                            for (
                                QBPaymentResponse.xPayment objpaymentJSON : objQBPayment.QueryResponse.Payment
                            ) {
                                if(String.isNotBlank(mapQbSfPaymentFieldName.get('SyncToken'))){
                                    if((mapQbIdQbPayment.get(objpaymentJSON.Id) == null) 
                                        || (mapQbIdQbPayment.containsKey(objpaymentJSON.Id) 
                                        && Integer.valueOf(objpaymentJSON.SyncToken) >= Integer.valueOf( mapQbIdQbPayment.get(objpaymentJSON.Id).get(mapQbSfPaymentFieldName.get('SyncToken'))) )){
                          

                                        if (
                                        objpaymentJSON.Line != null &&
                                        objpaymentJSON.Line.size() > 0
                                        ) {    
                                            for (
                                                QBPaymentResponse.xLine objPaymentLineJSON : objpaymentJSON.Line
                                            ) {
                                                if (
                                                objPaymentLineJSON.LinkedTxn != null &&
                                                objPaymentLineJSON.LinkedTxn.size() > 0
                                                ) {
                                                    for (
                                                        QBPaymentResponse.xLinkedTxn objPaymentLinkedTxnJSON : objPaymentLineJSON.LinkedTxn
                                                    ) {

                                                        Sobject objinvpay = paymentSOBject.clone(false, true, false, false);
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('Id'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('Id'),  objpaymentJSON.Id);
                                                        }
                                                        objinvpay.put(mapQbSfPaymentFieldName.get('SyncToken'),Integer.valueOf(objpaymentJSON.SyncToken));
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('Name'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('Name'),  ('QbPay-'+objpaymentJSON.Id+objPaymentLinkedTxnJSON.TxnId)); //TODO here for Name.
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('TotalAmt'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('TotalAmt'),objpaymentJSON.TotalAmt);
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('ExchangeRate'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('ExchangeRate'),objpaymentJSON.ExchangeRate);
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('UnappliedAmt'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('UnappliedAmt'),objpaymentJSON.UnappliedAmt);
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('TxnDate'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('TxnDate'),date.valueOf(objpaymentJSON.TxnDate));
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('InvoiceAmt'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('InvoiceAmt'),objPaymentLineJSON.Amount);
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('CurrencyRef')) && objpaymentJSON.CurrencyRef != null){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('CurrencyRef'),(objpaymentJSON.CurrencyRef.value));
                                                        }
                                                        if(Utils.getIsMultiCurrencyOrg() == true && activeCurrenciesIsoCode.contains(objpaymentJSON.CurrencyRef?.value)){
														    objinvpay.put('CurrencyIsoCode',(objpaymentJSON.CurrencyRef?.value));
                                                        }
                                                        if(String.isNotBlank(mapQbSfPaymentFieldName.get('payExtId'))){
                                                            objinvpay.put(mapQbSfPaymentFieldName.get('payExtId'),  (objpaymentJSON.Id+'-'+objPaymentLinkedTxnJSON.TxnId));
                                                        }
                                                       
                                                        lstPaymentInvoiceIds.add(objPaymentLinkedTxnJSON.TxnId);
                                                        if(mapInvoiceIdPaymentSObj.containsKey(objPaymentLinkedTxnJSON.TxnId)){
                                                            mapInvoiceIdPaymentSObj.get(objPaymentLinkedTxnJSON.TxnId).add(objinvpay);
                                                        }else{
                                                            mapInvoiceIdPaymentSObj.put(objPaymentLinkedTxnJSON.TxnId,new List<SObject>{objinvpay});
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        mapPayIdInvoiceIds.put(objpaymentJSON.Id,lstPaymentInvoiceIds);
                                        mapPayIdSyncToken.put(objpaymentJSON.Id,Integer.valueOf(objpaymentJSON.SyncToken));
                                    }
                                    else if(mapQbIdQbPayment.containsKey(objpaymentJSON.Id) && 
                                            (Integer.valueOf(objpaymentJSON.SyncToken) <  Integer.valueOf( mapQbIdQbPayment.get(objpaymentJSON.Id).get(mapQbSfPaymentFieldName.get('SyncToken'))) )){
                                           
                                            try{
                                                throw new QBSfSyncCustomException('Salesforce Payment Sync Token is greater than the Qb.');
                                            }catch(Exception exp){
                                                HandleCustomException.logException(exp);
                                            }
                                        //*** RARE CASE *** (This might happen when Twinkle's class might fail or Connection Failure/System failure during SF TO QB Sync.)
                                    }
                                }
                            }
                        }
            
                        if (lstPaymentInvoiceIds.size() > 0) {
                            List<String> invoicePayQbIds = new List<String>();
                            for(String cusnm : lstPaymentInvoiceIds){
                                invoicePayQbIds.add('\''+ EncodingUtil.urlEncode(cusnm, 'UTF-8') + '\'');
                            }
                            String qbinvQuery = EncodingUtil.urlEncode('select ', 'UTF-8')+'*'+EncodingUtil.urlEncode(' from invoice where id IN ', 'UTF-8')+'('+String.join(invoicePayQbIds,',')+')'+'&minorversion='+setting.KTQB__QB_version__c.intValue();
                           
                            CalloutDetails cred2 = new CalloutDetails();
                            cred2.helper = 'InvoiceSyncController.processWebhookData Payments-Invoice';
                            HTTPModel objHTTPInvoice = findQueryDetailInQBByFilter(
                                                qbinvQuery,
                                                'invoice',
                                                cred2);
                            if (!objHTTPInvoice.isCalloutException) {
                                QBInvoiceResponse.InvoiceRes objQBInvoice = (QBInvoiceResponse.InvoiceRes) JSON.deserialize(
                                    objHTTPInvoice.response,
                                    QBInvoiceResponse.InvoiceRes.class
                                );
                                if (
                                    objQBInvoice.QueryResponse != null &&
                                    objQBInvoice.QueryResponse.Invoice != null
                                ) {
                                    for ( QBInvoiceResponse.XInvoice objinv : objQBInvoice.QueryResponse.Invoice) {
                                        mapQBInvoice.put(objinv.Id, objinv);
                                        doProcessInvItems = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }   

    //Processing Customer, Invoice or Payment based on the captured change. 
        try{
            //check if customer found
            if (lstQbCustomer.size() > 0) {
                customerProcess(lstQbCustomer);
            }

            //check if invoices found
            if (mapQBInvoice.size() > 0) {
                invoiceProcess(mapQBInvoice,'CreateOrUpdate',doProcessInvItems);
            }
            
        //check if payments found.
        //for getting the related invoice details and associating it to the payment record.
            if(mapInvoiceIdPaymentSObj.keySet().size()>0 && String.isNotBlank(invoiceFieldApiNameOnLine)){
                //Invoice query checks
                if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && String.isNotBlank(mapQbSfInvFieldName.get('SyncToken')) && String.isNotBlank(invoiceObjectApiName)){
                    Set<String> payInvQBIdSet = mapInvoiceIdPaymentSObj.keySet();
                    String query = 'SELECT Id,'+String.escapeSingleQuotes(mapQbSfInvFieldName.get('DocNumber'))+','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'))+' FROM '+String.escapeSingleQuotes(invoiceObjectApiName) + ' WHERE '+ String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id')) +' IN: payInvQBIdSet WITH USER_MODE';
                    for(SObject qbInv: Database.query(query)){
                        if(mapInvoiceIdPaymentSObj.containsKey((String) qbInv.get(mapQbSfInvFieldName.get('Id')))){
                            for(SObject QBPayment : mapInvoiceIdPaymentSObj.get((String) qbInv.get(mapQbSfInvFieldName.get('Id')))){
                                QBPayment.put(invoiceFieldApiNameOnLine,(String) qbInv.get('Id'));
                                if(String.isNotBlank(mapQbSfPaymentFieldName.get('Name'))){
                                    QBPayment.put(mapQbSfPaymentFieldName.get('Name'),('QbPay-'+(String) QBPayment.get(mapQbSfPaymentFieldName.get('Id'))+' | Invoice #'+(String) qbInv.get(mapQbSfInvFieldName.get('DocNumber'))));
                                }
                            }
                        }
                    }
                }
                for(List<SObject> QbPaymentLst : mapInvoiceIdPaymentSObj.values()){
                    for(Sobject QBPayment : QbPaymentLst){
                        lstinvpayment.add(QBPayment);
                    }
                }
            }
			List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{paymentObjectApiName});
			Schema.DescribeSObjectResult describeResult = describeResults[0]; // Access the first result
        //Doing the Dml ops on Payments if found and correctly mapped on QuickBook Setup Tab.
            if (lstinvpayment.size() > 0 && mapPayIdInvoiceIds.keySet().size() > 0 && mapPayIdSyncToken.keySet().size() > 0 && String.isNotBlank(mapQbSfPaymentFieldName.get('payExtId')) && String.isNotBlank(paymentObjectApiName)){
                //if(Schema.getGlobalDescribe().get(paymentObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()
                 //   || Schema.getGlobalDescribe().get(paymentObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() ){
                if (describeResult.isCreateable() || describeResult.isUpdateable()) {   
                	//Schema.sObjectField paymentExternalId = Schema.getGlobalDescribe().get(paymentObjectApiName).getDescribe().fields.getMap().get(mapQbSfPaymentFieldName.get('payExtId'));
					Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
    				Schema.SObjectField paymentExternalId = fieldsMap.get(mapQbSfPaymentFieldName.get('payExtId'));
                    Database.UpsertResult[] payUpsertResult  = Database.upsert(lstinvpayment,paymentExternalId,true, AccessLevel.System_mode); //System_Mode : the Guest does not have access to the SF records.
                    Boolean allPaymentUpserted = false;
                    for(Database.upsertResult result : payUpsertResult){
                        if(result.isSuccess()){
                            allPaymentUpserted = true;
                        }else{
                            allPaymentUpserted = false;
                        }
                    }
                    if(allPaymentUpserted == true){
                        Database.executeBatch(new InvoicePaymentsHandlerBtchCls(mapPayIdInvoiceIds,mapPayIdSyncToken)); //Batch to Delete payments when deleted/Altered in Quickbooks for invoices.
                    }
                }
            }

            if(mapDeletedObjvsIds.size() > 0){
                List<Sobject> lstDelQbInvoices = new List<Sobject>();
                for(String objectType : mapDeletedObjvsIds.keySet()){
                    if(objectType == 'invoice'){
                        for(String qbId : mapDeletedObjvsIds.get(objectType)){
                            if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && String.isNotBlank(mapQbSfInvFieldName.get('InvoiceStatus'))){
                                SObject objinv  = invoiceSOBject.clone(false, true, false, false);
                                objinv.put(mapQbSfInvFieldName.get('Id'), qbId);
                                objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'), 'Deleted');

                                lstDelQbInvoices.add(objinv);
                            }
                        }       
                    }
                }
                List<Schema.DescribeSObjectResult> describeResultsInvoice = Schema.describeSObjects(new String[]{invoiceObjectApiName});
				Schema.DescribeSObjectResult describeResultInvoice = describeResultsInvoice[0]; // Access the first result
                if((describeResultInvoice.isCreateable() || describeResultInvoice.isUpdateable())
                    && lstDelQbInvoices.size() > 0){
                    if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && String.isNotBlank(invoiceObjectApiName)){
                        //Schema.sObjectField invoiceExternalId = Schema.getGlobalDescribe().get(invoiceObjectApiName).getDescribe().fields.getMap().get(mapQbSfInvFieldName.get('Id'));
                        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        				Schema.sObjectField invoiceExternalId = fieldsMap.get(mapQbSfInvFieldName.get('Id'));
                        Database.upsert(lstDelQbInvoices,invoiceExternalId,true,AccessLevel.System_mode);
                        
                    }
                }
            }
        }catch(Exception exp){
            HandleCustomException.logException(exp); 
        }
        if(KTQB__QB_Log__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
            insert as user qbLogs;
        }
    }


//======================================================================== ***** HELPER METHODS ***** =========================================================================== //

    /**
     * @description Helper Method 01 : this helper method is used to Upsert Contact when there's changes in Customer in QuickBooks i.e. its QB-to-SF Customer Sync.
     * @param lstQbCustomer
     */
    public static void customerProcess(list<QBCustomerResponse.XCustomer> lstQbCustomer) {
        try{
            List<SObject> lstContact = new List<SObject>();
            Map<String,List<SObject>> mapCustCompany = new Map<String,List<SObject>>();

            for(QBCustomerResponse.XCustomer objJSONCustomer : lstQbCustomer){
                if (
                    objJSONCustomer.Id != null ||
                    String.isNotBlank(objJSONCustomer.Id) ||
                    objJSONCustomer != null
                ) {
                    SObject con  = contactSOBject.clone(false, true, false, false);
                    if(String.isNotBlank(mapQbSfCustFieldName.get('Id'))){
                        con.put(mapQbSfCustFieldName.get('Id'), objJSONCustomer.Id);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('SyncToken'))){
                        con.put(mapQbSfCustFieldName.get('SyncToken'),Integer.valueOf(objJSONCustomer.SyncToken));
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('PrimaryPhone'))){
                        con.put(mapQbSfCustFieldName.get('PrimaryPhone'),objJSONCustomer.PrimaryPhone?.FreeFormNumber);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('Mobile'))){
                        con.put(mapQbSfCustFieldName.get('Mobile'),objJSONCustomer.Mobile?.FreeFormNumber);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('PrimaryEmailAddr'))){
                        con.put(mapQbSfCustFieldName.get('PrimaryEmailAddr'),objJSONCustomer.PrimaryEmailAddr?.Address);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('Fax'))){
                        con.put(mapQbSfCustFieldName.get('Fax'),objJSONCustomer.Fax?.FreeFormNumber);
                    }
                    if(Utils.getIsMultiCurrencyOrg() == true && activeCurrenciesIsoCode.contains(objJSONCustomer.CurrencyRef?.value)){
                        con.put('CurrencyIsoCode',(objJSONCustomer.CurrencyRef?.value));
                    }
            
                    //Customer Billing Address. 
                    string streetBillAddress = '';
                    if(String.isNotBlank(objJSONCustomer.BillAddr.Line1) && String.isNotBlank(objJSONCustomer.BillAddr.Line2)){
                        streetBillAddress = objJSONCustomer.BillAddr?.Line1?.trim() +' '+objJSONCustomer.BillAddr?.Line2?.trim();
                        if(String.isNotBlank(objJSONCustomer.BillAddr.Line3)){
                            streetBillAddress += ' '+objJSONCustomer.BillAddr.Line3.trim();
                        }
                        if(String.isNotBlank(objJSONCustomer.BillAddr.Line4)){
                            streetBillAddress += ' '+objJSONCustomer.BillAddr.Line4.trim();
                        }
                        if(String.isNotBlank(objJSONCustomer.BillAddr.Line5)){
                            streetBillAddress += ' '+objJSONCustomer.BillAddr.Line5.trim();
                        }
                    }
                    
                    if(String.isNotBlank(mapQbSfCustFieldName.get('BillAddrLine'))){
                        if(streetBillAddress.length() < 255 && String.isNotBlank(streetBillAddress)){
                            con.put(mapQbSfCustFieldName.get('BillAddrLine'),streetBillAddress);
                        }else{
                            con.put(mapQbSfCustFieldName.get('BillAddrLine'),objJSONCustomer.BillAddr?.Line1?.trim());
                        }
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('BillAddrCity'))){
                        con.put(mapQbSfCustFieldName.get('BillAddrCity'),objJSONCustomer.BillAddr?.City);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('BillAddrCountrySubDivisionCode'))){
                        con.put(mapQbSfCustFieldName.get('BillAddrCountrySubDivisionCode'),objJSONCustomer.BillAddr?.CountrySubDivisionCode);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('BillAddrCountry'))){
                        con.put(mapQbSfCustFieldName.get('BillAddrCountry'),objJSONCustomer.BillAddr?.Country);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('BillAddrPostalCode'))){
                        con.put(mapQbSfCustFieldName.get('BillAddrPostalCode'),objJSONCustomer.BillAddr?.PostalCode);
                    }

                    //Customer Shipping Address.
                    //When Shipping same as Billing is checked on Qb Customer UI.
                    if(objJSONCustomer.ShipAddr.Id == objJSONCustomer.BillAddr.Id){ 
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrLine')) && String.isNotBlank((String) con.get(mapQbSfCustFieldName.get('BillAddrLine'))) ){
                            con.put(mapQbSfCustFieldName.get('ShipAddrLine'),con.get(mapQbSfCustFieldName.get('BillAddrLine')));
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCity')) && String.isNotBlank((String) con.get(mapQbSfCustFieldName.get('BillAddrCity'))) ){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCity'),con.get(mapQbSfCustFieldName.get('BillAddrCity')));
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCountrySubDivisionCode')) && String.isNotBlank((String) con.get(mapQbSfCustFieldName.get('BillAddrCountrySubDivisionCode'))) ){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCountrySubDivisionCode'),con.get(mapQbSfCustFieldName.get('BillAddrCountrySubDivisionCode')));
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCountry')) && String.isNotBlank((String) con.get(mapQbSfCustFieldName.get('BillAddrCountry'))) ){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCountry'),con.get(mapQbSfCustFieldName.get('BillAddrCountry')));
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrPostalCode')) && String.isNotBlank((String) con.get(mapQbSfCustFieldName.get('BillAddrPostalCode'))) ){
                            con.put(mapQbSfCustFieldName.get('ShipAddrPostalCode'),con.get(mapQbSfCustFieldName.get('BillAddrPostalCode')));
                        }
                    }else{
                        string streetShippAddress = '';
                        if(String.isNotBlank(objJSONCustomer.ShipAddr.Line1) && String.isNotBlank(objJSONCustomer.ShipAddr.Line2)){
                            streetShippAddress = objJSONCustomer.ShipAddr?.Line1?.trim() +' '+objJSONCustomer.ShipAddr?.Line2?.trim();
                            if(String.isNotBlank(objJSONCustomer.ShipAddr.Line3)){
                                streetShippAddress += ' '+objJSONCustomer.ShipAddr.Line3.trim();
                            }
                            if(String.isNotBlank(objJSONCustomer.ShipAddr.Line4)){
                                streetShippAddress += ' '+objJSONCustomer.ShipAddr.Line4.trim();
                            }
                            if(String.isNotBlank(objJSONCustomer.ShipAddr.Line5)){
                                streetShippAddress += ' '+objJSONCustomer.ShipAddr.Line5.trim();
                            }
                        }

                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrLine')) ){
                            if(streetShippAddress.length() < 255 && String.isNotBlank(streetShippAddress)){
                                con.put(mapQbSfCustFieldName.get('ShipAddrLine'),streetShippAddress);
                            }else{
                                con.put(mapQbSfCustFieldName.get('ShipAddrLine'),objJSONCustomer.ShipAddr?.Line1?.trim());
                            }
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCity'))){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCity'),objJSONCustomer.ShipAddr?.City);
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCountrySubDivisionCode'))){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCountrySubDivisionCode'),objJSONCustomer.ShipAddr?.CountrySubDivisionCode);
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrCountry'))){
                            con.put(mapQbSfCustFieldName.get('ShipAddrCountry'),objJSONCustomer.ShipAddr?.Country);
                        }
                        if(String.isNotBlank(mapQbSfCustFieldName.get('ShipAddrPostalCode'))){
                            con.put(mapQbSfCustFieldName.get('ShipAddrPostalCode'),objJSONCustomer.ShipAddr?.PostalCode);
                        }
                    }


                    if(String.isNotBlank(mapQbSfCustFieldName.get('WebAddrURI'))){
                        con.put(mapQbSfCustFieldName.get('WebAddrURI'),objJSONCustomer.WebAddr?.URI);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('CompanyName'))){
                        con.put(mapQbSfCustFieldName.get('CompanyName'),objJSONCustomer.CompanyName);
                    }

                    if(String.isNotBlank(objJSONCustomer.GivenName) && String.isNotBlank(mapQbSfCustFieldName.get('GivenName'))){
                        con.put(mapQbSfCustFieldName.get('GivenName'),objJSONCustomer.GivenName);
                    }
                    if(String.isNotBlank(objJSONCustomer.MiddleName)){
                        con.put(mapQbSfCustFieldName.get('MiddleName'),objJSONCustomer.MiddleName);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('FamilyName')) && String.isNotBlank(objJSONCustomer.FamilyName)){
                            con.put(mapQbSfCustFieldName.get('FamilyName'),objJSONCustomer.FamilyName);
                    }
                    if(String.isNotBlank(mapQbSfCustFieldName.get('DisplayName')) && String.isNotBlank(objJSONCustomer.DisplayName)){
                        con.put(mapQbSfCustFieldName.get('DisplayName'),objJSONCustomer.DisplayName);
                    }

                    if(String.isNotBlank(objJSONCustomer.CompanyName)){
                        if(mapCustCompany.containsKey(objJSONCustomer.CompanyName)){
                            mapCustCompany.get(objJSONCustomer.CompanyName).add(con);
                        }else{
                            mapCustCompany.put(objJSONCustomer.CompanyName.toLowerCase(),new list<SObject>{con});
                        }
                    }
                    lstContact.add(con);
                } 
            }
            if (lstContact.size() > 0) {
                List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new String[]{customerObjectApiName});
				Schema.DescribeSObjectResult describeResult = describeResults[0]; // Access the first result
                if(describeResult.isCreateable() || describeResult.isUpdateable()){
                    if(String.isNotBlank(mapQbSfCustFieldName.get('Id')) &&  String.isNotBlank(customerObjectApiName)){
                        //Schema.sObjectField custExternalId = Schema.getGlobalDescribe().get(customerObjectApiName).getDescribe().fields.getMap().get(mapQbSfCustFieldName.get('Id'));
                        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        				Schema.sObjectField custExternalId = fieldsMap.get(mapQbSfCustFieldName.get('Id'));
                        Database.upsert(lstContact,custExternalId,true,AccessLevel.System_mode);
                    }
                }
            }
        }catch(Exception exp){
            HandleCustomException.logException(exp);
        }
    }

    /**
     * @description
     * @param isKayAsName
     * @return Map<String, string> mapCustomerTypes
     */
    public static Map<string, String> findcustomerType(Boolean isKayAsName) {
        Map<String, string> mapCustomerTypes = new Map<String, String>();
        try{
            String qbCustTyQuery =EncodingUtil.urlEncode('select ', 'UTF-8')+'*'+EncodingUtil.urlEncode(' from CustomerType', 'UTF-8')+'&minorversion='+setting.KTQB__QB_version__c.intValue();
            
                CalloutDetails cred = new CalloutDetails();
                cred.helper = 'InvoiceSyncController.processWebhookData CustomerType';
                HTTPModel objHTTP = findQueryDetailInQBByFilter(
                    qbCustTyQuery,
                    'CustomerType',
                    cred);
            if (!objHTTP.isCalloutException) {
            QBCustomerTypeResponse.CustomerTypeRes objQBCustomerTypes = QBCustomerTypeResponse.parseJSON(
                objHTTP.response
            );
                if (objQBCustomerTypes.QueryResponse != null && objQBCustomerTypes.QueryResponse.CustomerType != null) {
                    for (QBCustomerTypeResponse.XCustomerType objcustType : objQBCustomerTypes.QueryResponse.CustomerType) {
                        if (isKayAsName) {
                            mapCustomerTypes.put(objcustType.Name, objcustType.Id);
                        } else {
                            mapCustomerTypes.put(objcustType.Id, objcustType.Name);
                        }
                    }
                }
            }
            return mapCustomerTypes;
        }catch(Exception exp){
            HandleCustomException.logException(exp);
            return mapCustomerTypes;
        }
    }

    /**
     * @description Helper method : for processing the QB Invoices.
     * @param mapQBInvoice
     * @param operation
     * @param doProcessInvItems
     * @return component response
     */
    public static ComponentResponse invoiceProcess(
        Map<String, QBInvoiceResponse.XInvoice> mapQBInvoice,
        String operation,
        Boolean doProcessInvItems
    ) {
        List<SObject> lstInvoice = new List<SObject>();
        List<SObject> lstInvoiceLines = new List<SObject>();
        
        map<String,String> mapLineItemProd = new map<String,String>();
        map<String,String> mapInvIDCustID = new map<String,String>();
        
        List<String> lstInvoiceLineItemIds = new List<String>();
        List<String> lstInvoiceIds = new List<String>();


        ComponentResponse cmpResp = new ComponentResponse();        
        try{    
            List<String> lstCustomerIdsToQuery = new List<String>();
            Map<String,SObject> mapQbIdQbCustomer = new Map<String,SObject>();

            List<String> lstQbMetaDataQbIds = new List<String>();
            Map<String,String> mapTaxQbIdSfId = new Map<String,String>();
            Map<String,String> mapSalesTermQbIdSfId = new Map<String,String>();

            for (QBInvoiceResponse.XInvoice objJSONInv : mapQBInvoice.values()) {
                //for processing customer.
                lstCustomerIdsToQuery.add(objJSONInv.CustomerRef.value);
                mapInvIDCustID.put(objJSONInv.Id,objJSONInv.CustomerRef.value);

                //for adding tax and salesTerm value.
                lstQbMetaDataQbIds.add(objJSONInv.TxnTaxDetail?.TxnTaxCodeRef?.value);
                lstQbMetaDataQbIds.add(objJSONInv.SalesTermRef?.value);

            }

            //1. checking if the invoice customer present in Sf.
            if(lstCustomerIdsToQuery.size()>0){
                String query = 'SELECT Id,'+String.escapeSingleQuotes(mapQbSfCustFieldName.get('Id'))+','+String.escapeSingleQuotes(mapQbSfCustFieldName.get('SyncToken'))+' FROM '+String.escapeSingleQuotes(customerObjectApiName) + ' WHERE '+ String.escapeSingleQuotes(mapQbSfCustFieldName.get('Id')) +' IN: lstCustomerIdsToQuery WITH USER_MODE';
                for(SObject con: Database.query(query)){
                    mapQbIdQbCustomer.put((String) con.get(mapQbSfCustFieldName.get('Id')),con);
                } 
            }
            //2. checking if the customer is changed on invoice and check if invoice has payment : if yes then delete all payments of that invoice.
            if(mapInvIDCustID.keySet().size()>0){
                List<String> lstInvoiceCustChanged = new List<String>();
                lstInvoiceIds = new list<String>(mapInvIDCustID.keySet());
                String query = 'Select id,'+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'))+','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('QBCustomerRefID'))+' FROM '+String.escapeSingleQuotes(invoiceObjectApiName) +' where '+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'))+' IN: lstInvoiceIds WITH USER_MODE ';
                for(SObject inv : Database.query(query)){
                    if((string)inv.get(mapQbSfInvFieldName.get('QBCustomerRefID')) != mapInvIDCustID.get((string) inv.get(mapQbSfInvFieldName.get('Id')))){
                        //store the invoice ids whose customer has changed.
                        lstInvoiceCustChanged.add((string) inv.get(mapQbSfInvFieldName.get('Id')));
                    }
                }
                string invoiceFieldRlnName = '';
                string whereclause;
                if(invoiceFieldApiNameOnLine.containsIgnoreCase('__c')){
                    invoiceFieldRlnName = invoiceFieldApiNameOnLine.replace('__c', '__r');
                }    
                if(String.isNotBlank(invoiceFieldRlnName)){
                    if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                        whereclause =  String.escapeSingleQuotes(invoiceFieldRlnName)+'.'+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'));
                    }
                }

                String payQuery = 'Select id From '+String.escapeSingleQuotes(paymentObjectApiName) +' where '+whereclause+' IN: lstInvoiceCustChanged WITH USER_MODE ';
                if(String.isNotBlank(payQuery)){
                    Database.executeBatch(new InvoiceSyncCreateInvProductsDynamic(payQuery,lstInvoiceCustChanged)); 
                }
            }

            //Checking if the TaxCodes is present in SF.
            if(lstQbMetaDataQbIds.size()>0){
                for(KTQB__QB_MetaData__c qbMetaData :[Select Id, KTQB__QB_Id__c, KTQB__Type__c from KTQB__QB_MetaData__c where KTQB__Type__c IN('salesTax','Term') and KTQB__QB_Id__c IN: lstQbMetaDataQbIds WITH USER_MODE]){
                    if(qbMetaData.KTQB__Type__c == 'salesTax'){
                        mapTaxQbIdSfId.put(qbMetaData.KTQB__QB_Id__c,qbMetaData.Id);
                    }else if(qbMetaData.KTQB__Type__c == 'Term'){
                        mapSalesTermQbIdSfId.put(qbMetaData.KTQB__QB_Id__c,qbMetaData.Id);
                    }
                }
                /*System.debug('@@@ mapTaxQbIdSfId ::: '+mapTaxQbIdSfId);
                System.debug('@@@ mapSalesTermQbIdSfId ::: '+mapSalesTermQbIdSfId);*/
            }
            

            //2. Processing of invoice.
            for (QBInvoiceResponse.XInvoice objJSONInv : mapQBInvoice.values()) {
                SObject objinv  = invoiceSOBject.clone(false, true, false, false);
                if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('Id'))){
                    objinv.put(mapQbSfInvFieldName.get('Id'), objJSONInv.Id);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('SyncToken')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('SyncToken')) ){
                    objinv.put(mapQbSfInvFieldName.get('SyncToken'),Integer.valueOf(objJSONInv.SyncToken));
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('QBCustomerRefID')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('QBCustomerRefID')) ){
                    objinv.put(mapQbSfInvFieldName.get('QBCustomerRefID'),objJSONInv.CustomerRef.value);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('DocNumber')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DocNumber')) ){
                    objinv.put(mapQbSfInvFieldName.get('DocNumber'),objJSONInv.DocNumber);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('Name')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('Name')) ){
                    if(String.isNotBlank(objJSONInv.DocNumber)){
                        objinv.put(mapQbSfInvFieldName.get('Name'), 'Invoice #' + (objJSONInv.DocNumber != null ? objJSONInv.DocNumber : ''));
                    }else{
                        objinv.put(mapQbSfInvFieldName.get('Name'),('Invoice'));
                    }
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('CurrencyRef')) && objJSONInv.CurrencyRef != null && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('CurrencyRef')) ){
                    objinv.put(mapQbSfInvFieldName.get('CurrencyRef'),objJSONInv.CurrencyRef?.value);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('SalesTerm')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('SalesTerm')) ){
                    if(mapSalesTermQbIdSfId.containsKey(objJSONInv.SalesTermRef?.value)){
                        objinv.put(mapQbSfInvFieldName.get('SalesTerm'),mapSalesTermQbIdSfId.get(objJSONInv.SalesTermRef?.value)); //for Capturing TaxCode
                    }
                }

                if(String.isNotBlank(mapQbSfInvFieldName.get('TaxCodeRef')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('TaxCodeRef')) ){
                    if(mapTaxQbIdSfId.containsKey(objJSONInv.TxnTaxDetail?.TxnTaxCodeRef?.value)){
                        objinv.put(mapQbSfInvFieldName.get('TaxCodeRef'),mapTaxQbIdSfId.get(objJSONInv.TxnTaxDetail?.TxnTaxCodeRef?.value)); //for Capturing TaxCode
                    }
                }

                if(operation.equalsIgnoreCase('Void') && String.isNotBlank(mapQbSfInvFieldName.get('InvoiceStatus')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('InvoiceStatus')) ){
                    objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'), 'Voided');
                }

                //Even if the customer is not there in Sf Still save it related invoice in Sf , Qb-To-Sf.
                if(String.isNotBlank(mapQbSfCustFieldName.get('Id')) && String.isNotBlank(mapQbSfInvFieldName.get('QBCustomerRef'))
                    && customerAccessFlds.contains(mapQbSfCustFieldName.get('Id')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('QBCustomerRef')) ){
                    SObject con  = contactSOBject.clone(false, true, false, false);
                    if(mapQbIdQbCustomer.get(objJSONInv.CustomerRef.value)!=null){
                        con.put(mapQbSfCustFieldName.get('Id'), objJSONInv.CustomerRef.value);
                    
                        String invParentCustName =mapQbSfInvFieldName.get('QBCustomerRef');
                        if(invParentCustName.containsIgnoreCase('__c')){
                            invParentCustName = invParentCustName.replace('__c', '__r');
                        }
                        objinv.putSObject(
                            invParentCustName,
                            con
                        );
                    }  
                }

                if(String.isNotBlank(mapQbSfInvFieldName.get('TxnDate')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('TxnDate')) ){
                    objinv.put(mapQbSfInvFieldName.get('TxnDate'),date.valueOf(objJSONInv.TxnDate));
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('TotalAmt')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('TotalAmt')) ){
                    objinv.put(mapQbSfInvFieldName.get('TotalAmt'),objJSONInv.TotalAmt);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('DueDate')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DueDate')) ){
                    objinv.put(mapQbSfInvFieldName.get('DueDate'),date.valueOf(objJSONInv.DueDate));
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('Balance')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('Balance')) ){
                    objinv.put(mapQbSfInvFieldName.get('Balance'),objJSONInv.Balance);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('BillEmail')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('BillEmail')) ){
                    objinv.put(mapQbSfInvFieldName.get('BillEmail'),objJSONInv.BillEmail?.Address);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('ApplyTaxAfterDiscount')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('ApplyTaxAfterDiscount')) ){
                    objinv.put(mapQbSfInvFieldName.get('ApplyTaxAfterDiscount'),objJSONInv.ApplyTaxAfterDiscount == true?false:true );
                }

                //for capturing the orginial converted Currencies data.
                if(String.isNotBlank(mapQbSfInvFieldName.get('HomeTotalAmt')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('HomeTotalAmt')) ){
                    objinv.put(mapQbSfInvFieldName.get('HomeTotalAmt'),objJSONInv.HomeTotalAmt);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('HomeBalance')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('HomeBalance')) ){
                    objinv.put(mapQbSfInvFieldName.get('HomeBalance'),objJSONInv.HomeBalance);
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('ExchangeRate')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('ExchangeRate')) ){
                    objinv.put(mapQbSfInvFieldName.get('ExchangeRate'),objJSONInv.ExchangeRate);
                }
                if(Utils.getIsMultiCurrencyOrg() == true && activeCurrenciesIsoCode.contains(objJSONInv.CurrencyRef?.value)){
                    objinv.put('CurrencyIsoCode',objJSONInv.CurrencyRef?.value);
                }

                //ADDED :: To make changes to capture the status , the Order is DELETE > VOIDED > PAID > PARTIALLY PAID > SENT > OPEN
                if( String.isNotBlank(mapQbSfInvFieldName.get('InvoiceStatus')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('InvoiceStatus')) ){
                    if( String.isNotBlank(objJSONInv.PrivateNote) ){
                        if(objJSONInv.PrivateNote == 'Voided'){
                            objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'),objJSONInv.PrivateNote);
                        }
                    }else if( objJSONInv.TotalAmt != objJSONInv.Balance ){
                        if(objJSONInv.Balance == 0){
                            objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'),'Paid');
                        }else{
                            objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'),'Partially paid');
                        }
                    }else if(objJSONInv.EmailStatus == 'EmailSent'){
                        objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'),'Sent');
                    }else{
                        objinv.put(mapQbSfInvFieldName.get('InvoiceStatus'),'Open');
                    }
                }

                // Billing Address ::
                if(objJSONInv.BillAddr != null){
                    String billAddrStr ='';
                    if(String.isNotBlank(objJSONInv.BillAddr.Line1)){
                        billAddrStr += objJSONInv.BillAddr?.Line1;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.Line2)){
                        billAddrStr += '\n'+ objJSONInv.BillAddr.Line2 ;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.Line3)){
                        billAddrStr += '\n'+ objJSONInv.BillAddr.Line3 ;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.Line4)){
                        billAddrStr += '\n'+ objJSONInv.BillAddr.Line4 ;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.Line5)){
                        billAddrStr += '\n'+ objJSONInv.BillAddr.Line5;
                    }

                    if(String.isNotBlank(objJSONInv.BillAddr.City)){
                        billAddrStr += '\n'+ objJSONInv.BillAddr.City ;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.CountrySubDivisionCode)){
                        billAddrStr += ' '+ objJSONInv.BillAddr.CountrySubDivisionCode ;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.PostalCode)){
                        billAddrStr += ' '+ objJSONInv.BillAddr.PostalCode;
                    }
                    if(String.isNotBlank(objJSONInv.BillAddr.Country)){
                        billAddrStr += ' '+ objJSONInv.BillAddr.Country ;
                    }
                    if(String.isNotBlank(billAddrStr) && String.isNotBlank(mapQbSfInvFieldName.get('BillAddr')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('BillAddr')) ){
                        objinv.put(mapQbSfInvFieldName.get('BillAddr'),billAddrStr);
                    }
                }
                //Shipping Address ::
                if(objJSONInv.ShipAddr != null){
                    String shipAddrStr ='';
                    if(String.isNotBlank(objJSONInv.ShipAddr.Line1)){
                        shipAddrStr += objJSONInv.ShipAddr?.Line1;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.Line2)){
                        shipAddrStr += '\n'+ objJSONInv.ShipAddr.Line2 ;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.Line3)){
                        shipAddrStr += '\n'+ objJSONInv.ShipAddr.Line3 ;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.Line4)){
                        shipAddrStr += '\n'+ objJSONInv.ShipAddr.Line4 ;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.Line5)){
                        shipAddrStr += '\n'+ objJSONInv.ShipAddr.Line5;
                    }

                    if(String.isNotBlank(objJSONInv.ShipAddr.City)){
                        shipAddrStr += '\n'+ objJSONInv.ShipAddr.City ;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.CountrySubDivisionCode)){
                        shipAddrStr += ' '+ objJSONInv.ShipAddr.CountrySubDivisionCode ;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.PostalCode)){
                        shipAddrStr += ' '+ objJSONInv.ShipAddr.PostalCode;
                    }
                    if(String.isNotBlank(objJSONInv.ShipAddr.Country)){
                        shipAddrStr += ' '+ objJSONInv.ShipAddr.Country ;
                    }
                    if(String.isNotBlank(shipAddrStr) && String.isNotBlank(mapQbSfInvFieldName.get('ShipAddr')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('ShipAddr')) ){
                        objinv.put(mapQbSfInvFieldName.get('ShipAddr'),shipAddrStr);
                    }
                }
                //Populating Tax fields on QbInvoice
                if(objJSONInv.TxnTaxDetail !=null){
                    Double totalTaxPercent = 0;
                    if(objJSONInv.TxnTaxDetail.TaxLine != null){
                        for(QBInvoiceResponse.TaxLine taxPercent : objJSONInv.TxnTaxDetail.TaxLine){
                            totalTaxPercent += taxPercent.TaxLineDetail?.TaxPercent;
                        }
                    }
                    if(String.isNotBlank(mapQbSfInvFieldName.get('TaxPercent')) && totalTaxPercent != null && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('TaxPercent')) ){
                        objinv.put(mapQbSfInvFieldName.get('TaxPercent'),totalTaxPercent);  
                    }
                    if(String.isNotBlank(mapQbSfInvFieldName.get('TotalTax')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('TotalTax')) ){
                        objinv.put(mapQbSfInvFieldName.get('TotalTax'),objJSONInv.TxnTaxDetail?.TotalTax);
                    }
                }

                Boolean isDiscountAdded = false;
                //Upserting Line Items
                if(doProcessInvItems == true && lineItemSOBject != null){
                    for (QBInvoiceResponse.Line objJSONLine : objJSONInv.Line) {
                        //For capturing the Discount Related data of Invoice.
                        if (objJSONLine.Id == null){
                            if(objJSONLine.DetailType == 'DiscountLineDetail'){
                                isDiscountAdded = true;
                                if(String.isNotBlank(mapQbSfInvFieldName.get('DiscountAmount')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DiscountAmount')) ){
                                    objinv.put(mapQbSfInvFieldName.get('DiscountAmount'),objJSONLine.Amount);
                                }
                                if( (String.isNotBlank(mapQbSfInvFieldName.get('DiscountPercentOrValue')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DiscountPercentOrValue')))
                                  && (String.isNotBlank(mapQbSfInvFieldName.get('PercentBasedDiscount')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('PercentBasedDiscount'))) ){
                                    if(objJSONLine.DiscountLineDetail.PercentBased == true){
                                        objinv.put(mapQbSfInvFieldName.get('PercentBasedDiscount'),objJSONLine.DiscountLineDetail?.PercentBased);
                                        objinv.put(mapQbSfInvFieldName.get('DiscountPercentOrValue'),objJSONLine.DiscountLineDetail?.DiscountPercent);
                                    }else{
                                        objinv.put(mapQbSfInvFieldName.get('PercentBasedDiscount'),false);
                                        objinv.put(mapQbSfInvFieldName.get('DiscountPercentOrValue'),objJSONLine.Amount);
                                    }
                                }
                            }else if(isDiscountAdded == false){
                                //When discount is removed from the existing invoice.
                                if(String.isNotBlank(mapQbSfInvFieldName.get('PercentBasedDiscount')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('PercentBasedDiscount')) ){
                                    if(objinv.get(mapQbSfInvFieldName.get('PercentBasedDiscount')) == null){
                                        objinv.put(mapQbSfInvFieldName.get('PercentBasedDiscount'),false);
                                    }
                                }
                                if(String.isNotBlank(mapQbSfInvFieldName.get('DiscountAmount')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DiscountAmount')) ){
                                    if(objinv.get(mapQbSfInvFieldName.get('DiscountAmount')) == null){
                                        objinv.put(mapQbSfInvFieldName.get('DiscountAmount'),0);
                                    }
                                }
                                if(String.isNotBlank(mapQbSfInvFieldName.get('DiscountPercentOrValue')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('DiscountPercentOrValue')) ){
                                    if(objinv.get(mapQbSfInvFieldName.get('DiscountPercentOrValue')) == null){
                                        objinv.put(mapQbSfInvFieldName.get('DiscountPercentOrValue'),0);
                                    }
                                }
                            }
                            
                            if((objJSONLine.DetailType == 'SalesItemLineDetail') && (objJSONLine.SalesItemLineDetail?.ItemRef?.value == 'SHIPPING_ITEM_ID') 
                                && String.isNotBlank(mapQbSfInvFieldName.get('ShippingCharges')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('ShippingCharges')) ){
                                    objinv.put(mapQbSfInvFieldName.get('ShippingCharges'),objJSONLine.Amount);
                            }else{
                                if(String.isNotBlank(mapQbSfInvFieldName.get('ShippingCharges')) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('ShippingCharges')) ){
                                    if(objinv.get(mapQbSfInvFieldName.get('ShippingCharges')) == null){
                                        objinv.put(mapQbSfInvFieldName.get('ShippingCharges'),0);
                                    }
                                }
                            }
                            continue;
                        }

                        SObject objInvLine  = lineItemSOBject.clone(false, true, false, false);                        
                        // objInvLine.Name = 'LineItem-'+objJSONLine.LineNum +' |  Invoice #'+ objJSONInv.DocNumber;
                        if(Utils.getIsMultiCurrencyOrg() == true && activeCurrenciesIsoCode.contains(objJSONInv.CurrencyRef?.value)){
                            objInvLine.put('CurrencyIsoCode',objJSONInv.CurrencyRef?.value);
                        }
                        if(String.isNotBlank(mapQbSfLineFieldName.get('UnitPrice')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('UnitPrice')) ){
                            objInvLine.put(mapQbSfLineFieldName.get('UnitPrice'),objJSONLine.SalesItemLineDetail?.UnitPrice);
                        }
                        if (objJSONLine.SalesItemLineDetail != null) {
                            if (objJSONLine.SalesItemLineDetail.Qty != null) {
                                if(String.isNotBlank(mapQbSfLineFieldName.get('Qty')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('Qty')) ){
                                    objInvLine.put(mapQbSfLineFieldName.get('Qty'),objJSONLine.SalesItemLineDetail.Qty);
                                }
                            }
                            if(String.isNotBlank(mapQbSfLineFieldName.get('ItemRefName')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('ItemRefName')) ){
                                objInvLine.put(mapQbSfLineFieldName.get('ItemRefName'),objJSONLine.SalesItemLineDetail?.ItemRef?.name);
                            }

                            if(objJSONLine.SalesItemLineDetail.TaxCodeRef != null){
                                if(String.isNotBlank(mapQbSfLineFieldName.get('TaxCodeRef')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('TaxCodeRef')) ){
                                    objInvLine.put(mapQbSfLineFieldName.get('TaxCodeRef'),objJSONLine.SalesItemLineDetail.TaxCodeRef.value);
                                }
                            }
                        }
                        if(String.isNotBlank(mapQbSfLineFieldName.get('LineItemId')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('LineItemId')) ){
                            objInvLine.put(mapQbSfLineFieldName.get('LineItemId'),objJSONInv.Id + '#' + objJSONLine.Id);
                        }
                        if(String.isNotBlank(mapQbSfLineFieldName.get('Description')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('Description')) ){
                            objInvLine.put(mapQbSfLineFieldName.get('Description'),objJSONLine.Description);
                        }
                        if(String.isNotBlank(mapQbSfLineFieldName.get('Name')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('Name')) ){
                            if(String.isNotBlank(objJSONInv.DocNumber)){
                                objInvLine.put(mapQbSfLineFieldName.get('Name'),('LineItem-'+objJSONLine.LineNum +' | Invoice #'+objJSONInv.DocNumber));
                            }else{
                                objInvLine.put(mapQbSfLineFieldName.get('Name'),('LineItem-'+objJSONLine.LineNum +' | Invoice'));
                            }
                        }

                        if(String.isNotBlank(mapQbSfInvFieldName.get('Id')) && String.isNotBlank(invoiceFieldApiNameOnLine) && invoiceCreatableFlds.contains(mapQbSfInvFieldName.get('Id')) ){
                            SObject relatedLineInv  = invoiceSOBject.clone(false, true, false, false);
                            relatedLineInv.put(mapQbSfInvFieldName.get('Id'), objJSONInv.Id);
                            String lineParentInvName = invoiceFieldApiNameOnLine; 
                            if(lineParentInvName.containsIgnoreCase('__c')){
                                lineParentInvName = lineParentInvName.replace('__c', '__r');
                            }
                            objInvLine.putSObject(
                                lineParentInvName,
                                relatedLineInv
                            );
                        }

                        if(String.isNotBlank(mapQbSfLineFieldName.get('LineItemId')) && lineItemsCreatableFlds.contains(mapQbSfLineFieldName.get('LineItemId')) ){
                            lstInvoiceLineItemIds.add((String) objInvLine.get(mapQbSfLineFieldName.get('LineItemId')));
                            mapLineItemProd.put((String) objInvLine.get(mapQbSfLineFieldName.get('LineItemId')),objJSONLine.SalesItemLineDetail.ItemRef?.value);
                        }
                        lstInvoiceLines.add(objInvLine);
                    }
                }
                // if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                //     lstInvoiceIds.add((String) objinv.get(mapQbSfInvFieldName.get('Id')));
                // }
                lstInvoice.add(objinv);
            }

            //Batch to delete the Existing SF line items that is not there in QB. [UPDATED CODE]
            if(lstInvoiceLineItemIds.size()>0 && lstInvoiceIds.size()>0){
                String lineParentInvName = invoiceFieldApiNameOnLine;
                if(lineParentInvName.containsIgnoreCase('__c')){
                    lineParentInvName = lineParentInvName.replace('__c', '__r');
                } 

                String query='';
                if(String.isNotBlank(invoiceLineObjectApiName) && String.isNotBlank(lineParentInvName) && invoiceAccessFlds.contains(mapQbSfInvFieldName.get('Id'))){
                    query ='SELECT id FROM '+
                            String.escapeSingleQuotes(invoiceLineObjectApiName)+
                            ' WHERE '+String.escapeSingleQuotes(lineParentInvName)+'.'+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'))+ ' IN :lstInvoiceIds ';
                }

                if(lstInvoiceLineItemIds.size()>0 && lineItemsAccessFlds.contains(mapQbSfLineFieldName.get('LineItemId')) && String.isNotBlank(query)){
                    query += ' AND ' + String.escapeSingleQuotes(mapQbSfLineFieldName.get('LineItemId')) + ' NOT IN :lstInvoiceLineItemIds';
                } 
                if(String.isNotBlank(query)){
                    Database.executeBatch(new InvoiceSyncCreateInvProductsDynamic(query,lstInvoiceIds,lstInvoiceLineItemIds)); 
                }
            }

            //Upserting the invoices and ts line items.
            if (lstInvoice.size() > 0) {
                List<Schema.DescribeSObjectResult> describeInvoiceResults = Schema.describeSObjects(new String[]{invoiceObjectApiName});
				List<Schema.DescribeSObjectResult> describeInvoiceLineResults = Schema.describeSObjects(new String[]{invoiceLineObjectApiName});
                
                Schema.DescribeSObjectResult describeInvoiceResult = describeInvoiceResults[0]; 
				Schema.DescribeSObjectResult describeInvoiceLineResult = describeInvoiceLineResults[0]; 
                
                //if(Schema.getGlobalDescribe().get(invoiceObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()
                //    || Schema.getGlobalDescribe().get(invoiceObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                if (describeInvoiceResult.isCreateable() || describeInvoiceResult.isUpdateable()) {       
                		//Test : To check inaccesible Fields.
                        // System.debug(lstInvoice[0].get(mapQbSfInvFieldName.get('Id')));
                        // System.debug(invoiceExternalId.getDescribe().getLabel());

                        // FLSChecker.FLSCheckWrapper flsWrap = new FLSChecker.FLSCheckWrapper();
                        //     flsWrap = FLSChecker.dmlUpsertWithParameter(lstInvoice,invoiceExternalId,true);
                        //     if(!flsWrap.isSuccess){
                        //         throw new QBSfSyncCustomException(flsWrap.message);
                        //     }
                        //....
                        if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                            if( invoiceExternalId != null && invoiceAccessFlds.contains(mapQbSfInvFieldName.get('Id'))){
                                Database.upsert(lstInvoice,invoiceExternalId,true, AccessLevel.System_mode);
                            }
                        }
                }
                if (lstInvoiceLines.size() > 0) {
                   // if(Schema.getGlobalDescribe().get(invoiceLineObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()
                    //    || Schema.getGlobalDescribe().get(invoiceLineObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    if (describeInvoiceLineResult.isCreateable() || describeInvoiceLineResult.isUpdateable()) {    
                    	if(lineItemsExternalId != null && lineItemsAccessFlds.contains(mapQbSfLineFieldName.get('LineItemId'))){
                            Database.upsert(lstInvoiceLines,lineItemsExternalId,false, AccessLevel.System_mode);
                        }
                    }
                    cmpResp.status = 'Success';
                    cmpResp.message = 'The Invoice and its Related Line items successfully Synced from Quickbook';
                }  
            }
            return cmpResp;
        }catch(exception exp){
            HandleCustomException.logException(exp);
            cmpResp.status = 'Failed';
            cmpResp.message = 'The Invoice and its Related Line items failed to Sync from Quickbook, Error : '+exp.getMessage();
            return cmpResp;
        }
    }

    /**
     * @description Helper Method  : This method will check if all the Authorization and Authentication Steps are completed.
     * @return ComponentResponse wrapper
     */
    public static ComponentResponse checkAuthorizationSteps(){
        ComponentResponse cmpRes = new ComponentResponse();
        if(qbInfo !=null){
            if(qbInfo.KTQB__Completed_Steps__c == 4){
                cmpRes.status = 'Success';
            }else{
                cmpRes.status = 'Failed';
                cmpRes.isConnectionError = true;
                cmpRes.message = 'Please complete all the Connection Steps on QuickBooks Setup page.'; 
            }
        }else{
            cmpRes.status = 'Failed';
            cmpRes.isConnectionError = true;
            cmpRes.message = 'Please complete all the connection steps on QuickBooks Setup page or contact your system administrator.'; 
        }
        return cmpRes;
    }

//Helper Method -DELETED :: [paymentProcessQbToSf(), Backup - QbAppProject01Nov2023 Branch on github ] : this helper method is used to Upsert payment when there's changes in Payments in QuickBooks i.e. its QB-to-SF Payment Sync.

//==================================================================== ***** GLOBAL FUNCTION FOR CREATING QB INVOICES FROM SF TO QB ***** =========================================================================== //

    /**
     * @description
     * @param lstRecordIds
     */
    @InvocableMethod(iconName='slds:standard:expense' label='Global Create Quickbook Invoice Action' description='Use this action to create Quickbbok Invoice')
    public static void globalCreateQbInv(List<String> lstRecordIds){
        String recordId = lstRecordIds[0];
        if(String.isNotBlank(recordId)){
            genericCreateUpadteQbInv(recordId,'CreateOrUpdate');
        }
    }

    /**
     * @description Main Method : called by flow via invocable method or by our custom lwc component apex method.
     * @param recordId - record id
     * @param operation
     * @return HTTPModel wrapper
     */
    public static HTTPModel genericCreateUpadteQbInv(String recordId,String operation){
        HTTPModel objHttp = new  HTTPModel();
        generateObjectFieldMapping();
        try{
        //1. For Invoice
            //a. Map for QbFieldApiName,SfRecordFieldValue.
            Map<String,Object> mapQbFldNameSfValue = new Map<String,Object>();
            //b.  Creating Query to get invoice record details.
            String invoiceQuery = '';
            if(String.isNotBlank(invoiceObjectApiName) && String.isNotBlank(recordId) && invoiceAccessFlds.size()>0){
                invoiceQuery = 'SELECT id,'+String.escapeSingleQuotes(String.join(invoiceAccessFlds,','))+' FROM '+String.escapeSingleQuotes(invoiceObjectApiName)+' WHERE Id=:recordId WITH USER_MODE LIMIT 1';
            }
            SObject invoiceRecordRetrived; 
            if(String.isNotBlank(invoiceQuery)){
                invoiceRecordRetrived = Database.query(invoiceQuery); 
            }
            if(invoiceRecordRetrived != null){
                for(String qbFieldApiName : mapQbSfInvFieldName.keyset()){
                    if(String.isNotBlank(qbFieldApiName) && invoiceAccessFlds.contains(mapQbSfInvFieldName.get(qbFieldApiName))){
                        mapQbFldNameSfValue.put(qbFieldApiName,invoiceRecordRetrived.get(mapQbSfInvFieldName.get(qbFieldApiName)));
                    }
                }
            }
        //2. For Line Items
            //a. List of Map of QbFieldApiName,SfRecordFieldValue for Line Items.
            List<Map<String,Object>> lstQbLineFldNameSfValueMap = new List<Map<String,Object>>();
            Map<String,Integer> mapLineNumSfRecId = new Map<String,Integer>();  // map of Integer,Sf Line Item Record Id. 
            //b. Quering to get all invoice related Line records.
            String linequery = '';
            if(String.isNotBlank(invoiceObjectApiName) && String.isNotBlank(invoiceLineObjectApiName) && String.isNotBlank(recordId) && lineItemsAccessFlds.size()>0 ){
                linequery = 'SELECT id,'+String.escapeSingleQuotes(String.join(lineItemsAccessFlds, ','))+' FROM '+String.escapeSingleQuotes(invoiceLineObjectApiName)+' WHERE '+String.escapeSingleQuotes(invoiceObjectApiName)+'=:recordId WITH USER_MODE ';  
            }
            List<SObject> lstLineItemRecords = new List<SObject>();
            if(String.isNotBlank(linequery)){
                lstLineItemRecords = Database.query(linequery);
            }
            Integer lineNumCounter = 0;
            for(SObject lineRec : lstLineItemRecords){
                Map<String,Object> mapLineQbNameSfVal = new Map<String,Object>();
                lineNumCounter +=1;
                for(String qbFieldApiName : mapQbSfLineFieldName.keyset()){
                    if(String.isNotBlank(qbFieldApiName) && lineItemsAccessFlds.contains(mapQbSfLineFieldName.get(qbFieldApiName))){
                        if(qbFieldApiName == 'LineNum'){
                            mapLineQbNameSfVal.put(qbFieldApiName,lineNumCounter);
                            continue;
                        }
                        mapLineQbNameSfVal.put(qbFieldApiName,lineRec.get(mapQbSfLineFieldName.get(qbFieldApiName)));
                    }
                }
                if(!mapLineQbNameSfVal.containsKey('LineNum')){
                    mapLineQbNameSfVal.put('LineNum',lineNumCounter); //adding lineNum in the Map when the "LineNum" is not mapped.
                }
                lstQbLineFldNameSfValueMap.add(mapLineQbNameSfVal);
                mapLineNumSfRecId.put((String) lineRec.get('Id'),lineNumCounter); //map Sf Line RecordId , LineNum :: For Unique identification of the Line when the Invoice is created in Qb.
            }
        //3. For Customer :: 
            //a. Map for QbFieldApiName,SfRecordFieldValue.
            Map<String,Object> mapQbCustFldNameSfValue = new Map<String,Object>();

            //b. getting the Customer Sf Record Id , associated with the Invoice Sf record. 
            String invoiceCustomerRecordId =(String) mapQbFldNameSfValue.get('QBCustomerRef');
            //d.  Creating Query to get invoice record details.
            String custQuery = '';
            if(String.isNotBlank(customerObjectApiName) && customerAccessFlds.size()>0 && String.isNotBlank(invoiceCustomerRecordId)){
                custQuery = 'SELECT id,'+String.escapeSingleQuotes(String.join(customerAccessFlds, ','))+' FROM '+String.escapeSingleQuotes(customerObjectApiName)+' WHERE Id=:invoiceCustomerRecordId WITH USER_MODE LIMIT 1';
            }

            SObject customerRecordRetrived;
            if(String.isNotBlank(custQuery)){
                customerRecordRetrived = Database.query(custQuery); 
            }
            if(customerRecordRetrived != null){
                for(String qbFieldApiName : mapQbSfCustFieldName.keyset()){
                    if(String.isNotBlank(qbFieldApiName) && customerAccessFlds.contains(mapQbSfCustFieldName.get(qbFieldApiName))){
                        mapQbCustFldNameSfValue.put(qbFieldApiName,customerRecordRetrived.get(mapQbSfCustFieldName.get(qbFieldApiName)));
                    }
                }
            }else{
                //Throw error :: The Customer field must not be blank on the invoice. Please assign a customer or check the Customer Quickbook ID field before syncing.
                throw new QBSfSyncCustomException('The Customer field must not be blank on the invoice. Please assign a customer or check the Customer Quickbook ID field before syncing.');
            }
            if(operation.equalsIgnoreCase('CreateOrUpdate')){    
                //4. calling helper class to create the Qb invoice body
                String strBody;
                if(mapQbFldNameSfValue.keySet().size()>0 && lstQbLineFldNameSfValueMap.size()>0 && mapQbCustFldNameSfValue.keySet().size()>0){
                    strBody = globalCreateInvoiceBody(mapQbFldNameSfValue,lstQbLineFldNameSfValueMap,mapQbCustFldNameSfValue);
                }
                //5. making callout to qb to create Invoice in Quickbooks.
                if(String.isNotBlank(strBody)){
                    objHttp =  globalCreateQbInvCalloutHandler(strBody,invoiceRecordRetrived,lstLineItemRecords,mapLineNumSfRecId);
                }else{
                    if(lstQbLineFldNameSfValueMap.size()==0){
                        throw new QBSfSyncCustomException('Please re-check the Qb Invoice Line Items or contact your System Administrator to check the Qb Invoice Line Items mappings on QB Setup Page');
                    }else if(mapQbFldNameSfValue.keySet().size()==0){
                        throw new QBSfSyncCustomException('Please re-check the invoice or contact your System Administrator to check the QB Invoice mappings on QB Setup Page.');
                    }
                }
            }else if(operation.equalsIgnoreCase('Void')){
                //6. Creating body for voiding the Invoice in Qb.
                QBInvoiceResponse.XInvoice qbInvRec = new QBInvoiceResponse.XInvoice();
                if(mapQbFldNameSfValue.containsKey('Id') && String.isNotBlank((String) mapQbFldNameSfValue.get('Id'))){
                    qbInvRec.Id = (String) mapQbFldNameSfValue.get('Id');
                }
                if(mapQbFldNameSfValue.containsKey('SyncToken') && ((Decimal) mapQbFldNameSfValue.get('SyncToken') != null) ){
                   qbInvRec.SyncToken = ((Decimal) mapQbFldNameSfValue.get('SyncToken')).toPlainString();  //Todo : Change the Field Type/Datatype of Synctoken from Double to integer/String.
                }
                String strBody = Json.serialize(qbInvRec,true);
                //7. making callout to qb to void Invoice in Quickbooks.
                if(String.isNotBlank(strBody)){
                    objHttp = globalVoidQbInvCalloutHandler(strBody,invoiceRecordRetrived,operation);
                }
            }
            return objHttp;
        }catch(Exception exp){
            //Handle exception
            objHTTP.isLogException = true;
            /*System.debug('@@@ Exception ::: '+exp.getTypeName());*/
            if(exp.getTypeName().contains('System')){
                objHTTP.response = exp.getMessage()+'. Please contact your System Administrator to check QB Exception logs.';
            }else{
                objHTTP.response = exp.getMessage();
            }
            HandleCustomException.logException(exp);
            return objHttp;
        }
    }

    /**
     * @description Global Method : used to create body for Creating Invoice body.
     * @param mapQbFldNameSfValue
     * @param lstQbLineFldNameSfValueMap
     * @param mapQbCustFldNameSfValue
     * @return string
     */
    public static String globalCreateInvoiceBody( Map<String,Object> mapQbFldNameSfValue,List<Map<String,Object>> lstQbLineFldNameSfValueMap,Map<String,Object> mapQbCustFldNameSfValue){
        /*Product_Configuration_Options__c qbCustomSet = Product_Configuration_Options__c.getOrgDefaults();*/
        QBInvoiceResponse.XInvoice qbInvRec = new QBInvoiceResponse.XInvoice();
        if(mapQbFldNameSfValue.containsKey('Id') && String.isNotBlank((String) mapQbFldNameSfValue.get('Id'))){
            qbInvRec.Id = (String) mapQbFldNameSfValue.get('Id');
        }
        if(mapQbFldNameSfValue.containsKey('SyncToken') && ((Decimal) mapQbFldNameSfValue.get('SyncToken') != null) ){
        qbInvRec.SyncToken = ((Decimal) mapQbFldNameSfValue.get('SyncToken')).toPlainString();  //Todo : Change the Field Type/Datatype of Synctoken from Double to integer/String.
        }
        qbInvRec.TxnDate =String.valueOf((Date) mapQbFldNameSfValue.get('TxnDate'));
        qbInvRec.DueDate =String.valueOf((Date) mapQbFldNameSfValue.get('DueDate'));
        qbInvRec.TotalAmt =(Double) mapQbFldNameSfValue.get('TotalAmt');
        qbInvRec.Balance =(Double) mapQbFldNameSfValue.get('Balance');
        //Refrencing Customer ::
        QBInvoiceResponse.CurrencyRef custRef = new QBInvoiceResponse.CurrencyRef();
        custRef.value = (String) mapQbCustFldNameSfValue.get('Id');
        qbInvRec.CustomerRef = custRef;
        //adding bill email address
        QBInvoiceResponse.BillEmail invBillEmail= new QBInvoiceResponse.BillEmail();
        invBillEmail.Address = (String) mapQbFldNameSfValue.get('BillEmail');
        qbInvRec.BillEmail = invBillEmail;

        //Fetching the Tax and SalesTerm from QbMetadata
        List<String> qbMetaDataIds = new List<String>{(String) mapQbFldNameSfValue.get('TaxCodeRef'),(String) mapQbFldNameSfValue.get('SalesTerm')};
        KTQB__QB_MetaData__c qbTaxMetaData;
        KTQB__QB_MetaData__c qbSalesTermMetaData;
        if(qbMetaDataIds.size()>0){
            for (KTQB__QB_MetaData__c qbMeta:[Select id, KTQB__QB_Id__c, KTQB__Type__c,KTQB__Sales_Tax_Rate__c from KTQB__QB_MetaData__c where Id IN:qbMetaDataIds WITH USER_MODE LIMIT 2]){
                if(qbMeta.KTQB__Type__c == 'Term'){
                    qbSalesTermMetaData = qbMeta;
                }else if(qbMeta.KTQB__Type__c == 'salesTax'){
                    qbTaxMetaData = qbMeta;
                }
            }
        }

        //Adding Tax related details.
        QBInvoiceResponse.TxnTaxDetail invTaxDetails = new QBInvoiceResponse.TxnTaxDetail();
        QBInvoiceResponse.TxnTaxCodeRef invTaxCode= new QBInvoiceResponse.TxnTaxCodeRef(); 
        invTaxCode.value= qbTaxMetaData?.KTQB__QB_Id__c;
        invTaxDetails.TxnTaxCodeRef=invTaxCode;
        qbInvRec.TxnTaxDetail = invTaxDetails;

        //Adding salesTerm 
        QBInvoiceResponse.CurrencyRef salesTermDetails = new QBInvoiceResponse.CurrencyRef();
        salesTermDetails.value = qbSalesTermMetaData?.KTQB__QB_Id__c;
        qbInvRec.SalesTermRef = salesTermDetails;

        //adding shipping and billing address
        QBInvoiceResponse.ShipAddr shipAddrStr = new QBInvoiceResponse.ShipAddr();
        List<String> lstShipAddr = ((String) mapQbFldNameSfValue.get('ShipAddr'))?.split('\n',5);

        integer currentShipIndex = 0;
        if(lstShipAddr!=null){
            for(String shipAd : lstShipAddr){
                currentShipIndex +=1;
                if(currentShipIndex == 1){
                    shipAddrStr.Line1 = lstShipAddr[0];
                }
                else if(currentShipIndex == 2){
                    shipAddrStr.Line2 = lstShipAddr[1];
                }
                else if(currentShipIndex == 3){
                    shipAddrStr.Line3 = lstShipAddr[2];
                }
                else if(currentShipIndex == 4){
                    shipAddrStr.Line4 = lstShipAddr[3];
                }
                else if(currentShipIndex == 5){
                    shipAddrStr.Line5 = lstShipAddr[4];
                }
            }
        }
        qbInvRec.ShipAddr = shipAddrStr;

        QBInvoiceResponse.BillAddr billAddrStr = new QBInvoiceResponse.BillAddr();
        List<String> lstBillAddr = ((String) mapQbFldNameSfValue.get('BillAddr'))?.split('\n',5);
        integer currentBillIndex = 0;
        if(lstBillAddr!=null){
            for(String shipAd : lstBillAddr){
                currentBillIndex +=1;
                if(currentBillIndex == 1){
                    billAddrStr.Line1 = lstBillAddr[0];
                }
                else if(currentBillIndex == 2){
                    billAddrStr.Line2 = lstBillAddr[1];
                }
                else if(currentBillIndex == 3){
                    billAddrStr.Line3 = lstBillAddr[2];
                }
                else if(currentBillIndex == 4){
                    billAddrStr.Line4 = lstBillAddr[3];
                }
                else if(currentBillIndex == 5){
                    billAddrStr.Line5 = lstBillAddr[4];
                }
            }
        }
        qbInvRec.BillAddr = billAddrStr;


        //adding LineItems to Invoice.
        List<QBInvoiceResponse.Line> lstInvLine = new List<QBInvoiceResponse.Line>();
        //if(qbCustomSet.Create_Item_in_Quickbooks__c == true){
            for(Map<String,Object> mapQbLineFldnameSfVal : lstQbLineFldNameSfValueMap){
                QBInvoiceResponse.Line invLine = new QBInvoiceResponse.Line();
                String lineItemId = (String) mapQbLineFldnameSfVal.get('LineItemId');
                if(String.isNotBlank(lineItemId)){
                    invLine.Id = lineItemId.containsIgnoreCase('#') ? lineItemId.split('#')[1].trim() : '';  //to get Line Qb id.
                }
                if( ((Double) mapQbLineFldnameSfVal.get('UnitPrice'))!=null && ((Decimal) mapQbLineFldnameSfVal.get('Qty'))!=null){
                    invLine.Amount = ((Double) mapQbLineFldnameSfVal.get('UnitPrice')) * ((Decimal) mapQbLineFldnameSfVal.get('Qty'));  //Temporary
                }
                if(String.isNotBlank((String) mapQbLineFldnameSfVal.get('Description'))){
                    invLine.Description = (String) mapQbLineFldnameSfVal.get('Description');
                }
                invLine.DetailType = 'SalesItemLineDetail';
                if(((Integer) mapQbLineFldnameSfVal.get('LineNum')) !=null){
                    invLine.LineNum = (Integer) mapQbLineFldnameSfVal.get('LineNum'); // (Used this to identify the Line Item uniquely)
                }
               
                QBInvoiceResponse.SalesItemLineDetail salesDetail = new QBInvoiceResponse.SalesItemLineDetail();
                if(((Double) mapQbLineFldnameSfVal.get('UnitPrice')) !=null){ 
                    salesDetail.UnitPrice = (Double) mapQbLineFldnameSfVal.get('UnitPrice');
                }
                if(((Decimal) mapQbLineFldnameSfVal.get('Qty')) !=null){
                    salesDetail.Qty = (Decimal) mapQbLineFldnameSfVal.get('Qty');
                }

                QBInvoiceResponse.TaxCodeRef lineTaxCodeRef = new QBInvoiceResponse.TaxCodeRef();
                if(String.isNotBlank((String) mapQbLineFldnameSfVal.get('TaxCodeRef'))){
                    lineTaxCodeRef.value = (String) mapQbLineFldnameSfVal.get('TaxCodeRef');
                    salesDetail.TaxCodeRef =  lineTaxCodeRef;
                }

                QBInvoiceResponse.CurrencyRef itemRefObj = new QBInvoiceResponse.CurrencyRef();
                itemRefObj.value = '1';
                salesDetail.ItemRef =  itemRefObj;
                invLine.SalesItemLineDetail =  salesDetail;

                lstInvLine.add(invLine);
            }
            // Adding Discount Amount, i.e. To Sync Discounts from Sf to Qb Sync.
            QBInvoiceResponse.Line invDiscountLine = new QBInvoiceResponse.Line();
            invDiscountLine.DetailType = 'DiscountLineDetail';
            invDiscountLine.Amount = (Double) mapQbFldNameSfValue.get('DiscountAmount');
            QBInvoiceResponse.DiscountLineDetail discountDetail = new QBInvoiceResponse.DiscountLineDetail();
            Boolean isPercentageBased =(Boolean) mapQbFldNameSfValue.get('PercentBasedDiscount');
            discountDetail.PercentBased = isPercentageBased;
            if(isPercentageBased){
                discountDetail.DiscountPercent = (Double) mapQbFldNameSfValue.get('DiscountPercentOrValue');
            }else{
                invDiscountLine.Amount = (Double) mapQbFldNameSfValue.get('DiscountPercentOrValue');
            }
            invDiscountLine.DiscountLineDetail =  discountDetail;
            if(invDiscountLine.Amount != null){
                lstInvLine.add(invDiscountLine);
            }
            
            //Adding Shipping Charges, i.e. To Sync Shipping Charges from Sf to Qb Sync.
            QBInvoiceResponse.Line invShipLine = new QBInvoiceResponse.Line();
            invShipLine.DetailType = 'SalesItemLineDetail';
            invShipLine.Amount = (Double) mapQbFldNameSfValue.get('ShippingCharges');
            QBInvoiceResponse.SalesItemLineDetail salesShipDetail = new QBInvoiceResponse.SalesItemLineDetail();
            QBInvoiceResponse.CurrencyRef itemRefShipObj = new QBInvoiceResponse.CurrencyRef();
            itemRefShipObj.value = 'SHIPPING_ITEM_ID';
            salesShipDetail.ItemRef =  itemRefShipObj;
            invShipLine.SalesItemLineDetail =  salesShipDetail;
            if(invShipLine.Amount != null){
                lstInvLine.add(invShipLine);
            }
       //}
        qbInvRec.Line = lstInvLine;
        return Json.serialize(qbInvRec,true);
    }

    /**
     * @description Global Method : used to make callout and handle Qb response and Update the Sf Invoice record and its related Line Item records.
     * Dynmaic Method which can be called from any flow , proceess builder or any other apex class.
     * @param strBody - body.
     * @param invRecord - record
     * @param lstLineItemRecords -list of record
     * @param mapLineNumSfRecId
     * @return HTTPModel wrapper
     */
    public static HTTPModel globalCreateQbInvCalloutHandler(String strBody,SObject invRecord,List<SObject> lstLineItemRecords,Map<String,Integer> mapLineNumSfRecId) {
        HTTPModel objHTTP = new HTTPModel();
        try{
            ComponentResponse cmpRes = new ComponentResponse();
            CalloutDetails cred = new CalloutDetails();
            cred.helper = 'InvoiceSyncController.globalCreateQbInv';
            cred.recordId = (String) invRecord.get('Id');
            List<SObject> lineItemRecordsToUpdate = new List<SObject>();
            Map<Integer,String> qbLineNumIdMap = new Map<Integer,String>();
            if(String.isNotBlank(strBody)){
                objHTTP =  createUpdateQBInvAndLine(strBody,cred);
                if(KTQB__QB_Log__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    insert as user qbLogs;
                }
                if (!objHTTP.isCalloutException) {
                    QBInvoiceResponse.InvoiceSingleRes objQBInvoice = (QBInvoiceResponse.InvoiceSingleRes) System.JSON.deserialize(
                        objHTTP.response,
                        QBInvoiceResponse.InvoiceSingleRes.class
                    );
                    if (objQBInvoice.Invoice != null) {
                        SObject qbInv = invRecord.getSObjectType().newSObject((String) invRecord.get('Id'));
                        if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                            qbInv.put(mapQbSfInvFieldName.get('Id'), objQBInvoice.Invoice.Id);
                        }
                        if(String.isNotBlank(mapQbSfInvFieldName.get('SyncToken'))){
                            qbInv.put(mapQbSfInvFieldName.get('SyncToken'), Integer.valueOf(objQBInvoice.Invoice.SyncToken));
                        }
                        for(QBInvoiceResponse.Line respItem : objQBInvoice.Invoice.Line){
                            if (respItem.Id == null){
                                continue;
                            }

                            qbLineNumIdMap.put(respItem.LineNum,respItem.Id);
                        }
                        for(Sobject lineItemRecord: lstLineItemRecords){
                            
                            Integer lineItemNumber = mapLineNumSfRecId.get((String) lineItemRecord.get('Id'));
                            if (lineItemNumber !=null){
                                SObject qbLine = lineItemRecord.getSObjectType().newSObject((String) lineItemRecord.get('Id'));
                                if(String.isNotBlank(mapQbSfLineFieldName.get('LineItemId'))){
                                    qbLine.put(mapQbSfLineFieldName.get('LineItemId'), objQBInvoice.Invoice.Id+'#'+qbLineNumIdMap.get(lineItemNumber));
                                }
                                
                                lineItemRecordsToUpdate.add(qbLine);
                            }
                        }
                        cmpRes.status = 'Success';
                        cmpRes.message = 'The Invoice Record Synced Successfully with Quickbooks.';
                        if(lineItemRecordsToUpdate.size()>0 && String.isNotBlank(invoiceLineObjectApiName)){
                            List<Schema.DescribeSObjectResult> describeInvoiceLineResults = Schema.describeSObjects(new String[]{invoiceLineObjectApiName});
							Schema.DescribeSObjectResult describeInvoiceLineResult = describeInvoiceLineResults[0];
                            //if(Schema.getGlobalDescribe().get(invoiceLineObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                            if (describeInvoiceLineResult.isUpdateable()) {  
                            	update as user lineItemRecordsToUpdate;
                            }
                        } 
                        List<SObject> qbInvList = new List<SObject>();
                        qbInvList.add(qbInv);
                        if(String.isNotBlank(invoiceObjectApiName)){
                            List<Schema.DescribeSObjectResult> describeInvoiceResults = Schema.describeSObjects(new String[]{invoiceObjectApiName});
							Schema.DescribeSObjectResult describeInvoiceResult = describeInvoiceResults[0]; 
                            //if(Schema.getGlobalDescribe().get(invoiceObjectApiName).getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                            if (describeInvoiceResult.isUpdateable()) {
                            	update as user qbInv;
                            }
                            
                        }
                    }
                    
                }
            }
            return objHTTP;
        }catch(Exception exp){
            objHTTP.isLogException = true;
            objHTTP.response = exp.getMessage();
            HandleCustomException.logException(exp);
            return objHTTP;
        }
    }

    /**
     * @description Global Method : used to delete the Invoice in Quickbooks.
     * Dynmaic Method which can be called from any flow , proceess builder or any other apex class.
     * @param strBody - Body.
     * @param invRecord - 
     * @param operation - 'CreateOrUpdate'
     * @return HTTPModel wrapper
     */
    public static HTTPModel globalVoidQbInvCalloutHandler(String strBody,SObject invRecord,String operation){
    
        HTTPModel objHTTP = new HTTPModel();
        Map<String, QBInvoiceResponse.XInvoice> mapQBInvoice = new Map<String, QBInvoiceResponse.XInvoice>();
        CalloutDetails cred = new CalloutDetails();
        cred.helper = 'InvoiceSyncController.deleteVoidQbInvoice';
        cred.recordId = (String) invRecord.get('Id');
        try{
            String InvoiceStatus='';
            if(String.isNotBlank(mapQbSfInvFieldName.get('InvoiceStatus'))){
                InvoiceStatus = (String) invRecord.get(mapQbSfInvFieldName.get('InvoiceStatus'));
            } 
            if(String.isNotBlank(InvoiceStatus)){
                if(InvoiceStatus.equalsIgnoreCase('Voided')){
                    objHTTP.isLogException = true;
                    objHTTP.response = 'The Invoice record has been already voided in Quickbooks';
                    return objHTTP;
                }
            }
            if(String.isNotBlank(strBody)){
                objHTTP =  deleteVoidQBrecordCallout(operation,strBody,cred);
                if(KTQB__QB_Log__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    insert as user qbLogs;
                }
                if (!objHTTP.isCalloutException){
                    QBInvoiceResponse.InvoiceSingleRes objinv = (QBInvoiceResponse.InvoiceSingleRes) System.JSON.deserialize(
                                                            objHTTP.response,
                                                            QBInvoiceResponse.InvoiceSingleRes.class
                                                        );
                         
                    if(String.isNotBlank(objinv.Invoice.Id)){
                        mapQBInvoice.put(objinv.Invoice.Id, objinv.Invoice);
                    }
                    if (mapQBInvoice.size() > 0) {
                        invoiceProcess(mapQBInvoice,operation,true);     
                    }
                }
            }
            return objHTTP;
        }catch(Exception exp){
            objHTTP.isLogException = true;
            objHTTP.response = exp.getMessage();
            HandleCustomException.logException(exp);
            return objHTTP;
        }
    }

// ======================================================================== ***** AURA ENABLED METHODS ***** =========================================================================== //

    /**
     * @description AuraMethod : To Create/Update the Qb Invoice from SF to QB.
     * @param qbInvoiceId - invoice record id.
     * @param operation - 'CreateOrUpdate'
     * @return component response
     */
    @AuraEnabled
    public static ComponentResponse createUpdateInvSfToQB(String qbInvoiceId,String operation){
        ComponentResponse cmpRes = new ComponentResponse();
        String successMsg = '';
        String failMsg = '';
        try{
            //check if all Authourization steps are completed.
            cmpRes = checkAuthorizationSteps();
            if(cmpRes.status.equalsIgnoreCase('Failed')){
                throw new QBSfSyncCustomException('Quickbook Setup, Authorization/Authentication Connection Steps are pending.');
            }

            if(operation.equalsIgnoreCase('CreateOrUpdate')){
                successMsg = 'The invoice record synced successfully with Quickbooks.';
                failMsg = 'The invoice record failed to sync in Quickbooks';
            }else if(operation.equalsIgnoreCase('Void')){
                successMsg = 'The invoice record successfully voided from Quickbooks.';
                failMsg = 'The invoice record failed to void in Quickbooks';
            }

            if(String.isNotBlank(qbInvoiceId)){
                //1. Main generic method for Create/Update Qb invoices.
                HTTPModel objHTTP = genericCreateUpadteQbInv(qbInvoiceId,operation);
                //2. Creating response i.e. handled in Lwc as Toast message.
                if (!objHTTP.isCalloutException && !objHTTP.isLogException) {
                    cmpRes.status = 'Success';
                    cmpRes.message = successMsg;
                }else if(objHTTP.isLogException){
                    cmpRes.status = 'Failed';
                    cmpRes.message = objHTTP.response;
                }else{
                    cmpRes.status = 'Failed';
                    if(objHTTP.isCalloutException && objHTTP.response.contains('"Error"')){
                        QBErrorResponse.errorCls errorObj = QBErrorResponse.parseJSON(objHTTP.response);
                        String errorMsg = '';
                        for(QBErrorResponse.cls_Error error: errorObj.Fault.Error){
                            errorMsg+='Message : '+error.Message;
                            errorMsg+=' | Detail : '+error.Detail;
                            errorMsg+=' | Error code : '+error.code;
                            if(String.isNotBlank(error.element)){
                                errorMsg+=' | Error in  : '+error.element;
                            }
                            errorMsg+=' #### ';
                        }
                        if(String.isNotBlank(errorMsg)){
                            cmpRes.message = errorMsg;
                        }
                    }else{
                        cmpRes.message = failMsg+'.';
                    }   
                }
            }
            return cmpRes;
        }catch(Exception exp){
            HandleCustomException.logException(exp);
            return cmpRes;
        }
    }

    /**
     * @description AuraMethod : To create a Invoice Payment in the QuickBooks.
     * @param wrapperReqText - CreatePaymentWrapper.
     * @return component response / create payment wrapper
     */
    @AuraEnabled public static string createUpdateSFQbPayment(String wrapperReqText){
        CreatePaymentWrapper payReqBody = (CreatePaymentWrapper)JSON.deserialize(wrapperReqText,CreatePaymentWrapper.class);
        ComponentResponse cmpRes = new ComponentResponse();
        try{

            generateObjectFieldMapping();
            String invParentCustName='';
            if(String.isNotBlank(mapQbSfInvFieldName.get('QBCustomerRef'))){
                invParentCustName = mapQbSfInvFieldName.get('QBCustomerRef');
            }
            if(invParentCustName.containsIgnoreCase('__c')){
                invParentCustName = invParentCustName.replace('__c', '__r');
            }
            String qbInvId = payReqBody.invoiceId;
            String invQuery = 'Select id';
            if(String.isNotBlank(mapQbSfInvFieldName.get('Name'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Name'));
            }
            if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Id'));
            }
            if(String.isNotBlank(mapQbSfInvFieldName.get('TotalAmt'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('TotalAmt'));
            }
            if(String.isNotBlank(mapQbSfInvFieldName.get('Balance'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('Balance'));
            }
            if(String.isNotBlank(mapQbSfInvFieldName.get('CurrencyRef'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('CurrencyRef'));
            }
            if(String.isNotBlank(mapQbSfInvFieldName.get('QBCustomerRefID'))){
                invQuery +=','+String.escapeSingleQuotes(mapQbSfInvFieldName.get('QBCustomerRefID'));
            }
            if(String.isNotBlank(invParentCustName)){
                if(String.isNotBlank(mapQbSfCustFieldName.get('Id'))){
                    invQuery += ','+ String.escapeSingleQuotes(invParentCustName)+'.'+String.escapeSingleQuotes(mapQbSfCustFieldName.get('Id'));
                }
                if(String.isNotBlank(mapQbSfCustFieldName.get('GivenName'))){
                    invQuery += ','+ String.escapeSingleQuotes(invParentCustName)+'.'+String.escapeSingleQuotes(mapQbSfCustFieldName.get('GivenName'));
                }
                if(String.isNotBlank(mapQbSfCustFieldName.get('FamilyName'))){
                    invQuery += ','+ String.escapeSingleQuotes(invParentCustName)+'.'+String.escapeSingleQuotes(mapQbSfCustFieldName.get('FamilyName'));
                }
            }
            if(String.isNotBlank(invoiceObjectApiName)){
                invQuery += ' FROM '+String.escapeSingleQuotes(invoiceObjectApiName) +
                        ' where Id=:qbInvId WITH USER_MODE ';
            }
            // if(QB_Invoice__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){  
            SObject qbInv = Database.query(invQuery);
            SObject qbInvCust =qbInv.getSobject(invParentCustName);
            // }
            if(payReqBody.isPayed == true){
                //check if all Authourization steps are completed.
                cmpRes = checkAuthorizationSteps();
                if(cmpRes.status.equalsIgnoreCase('Failed')){
                    throw new QBSfSyncCustomException('Quickbook Setup, Authorization/Authentication Connection Steps are pending.');
                }

                QBPaymentResponse.xPayment paymentObj = new QBPaymentResponse.xPayment();
                paymentObj.TotalAmt = payReqBody.transactionAmountPaid;
                paymentObj.TxnDate = payReqBody.transactionDate;
                paymentObj.PaymentRefNum = payReqBody.transactionId;

                QBPaymentResponse.xPaymentMethodRef customerRefObj = new QBPaymentResponse.xPaymentMethodRef();
                if(String.isNotBlank(mapQbSfCustFieldName.get('Id')) && qbInvCust!=null){
                    if(String.isNotBlank((String) qbInvCust.get(mapQbSfCustFieldName.get('Id')))){
                        customerRefObj.value =(String) qbInvCust.get(mapQbSfCustFieldName.get('Id'));
                    }
                }else if(String.isBlank(customerRefObj.value) && String.isNotBlank(mapQbSfInvFieldName.get('QBCustomerRefID')) && String.isNotBlank((String) qbInv.get(mapQbSfInvFieldName.get('QBCustomerRefID'))) ){
                    customerRefObj.value = (String) qbInv.get(mapQbSfInvFieldName.get('QBCustomerRefID'));
                }
                paymentObj.CustomerRef = customerRefObj;
                QBPaymentResponse.xPaymentMethodRef paymentMethodObj = new QBPaymentResponse.xPaymentMethodRef();
                paymentMethodObj.value = payReqBody.paymentMethod;
                paymentObj.PaymentMethodRef = paymentMethodObj;
                QBPaymentResponse.xLine paymentlineObj = new QBPaymentResponse.xLine();
                paymentlineObj.Amount = payReqBody.transactionAmountPaid;
                QBPaymentResponse.xLinkedTxn paymentLinkedTxn  = new QBPaymentResponse.xLinkedTxn();
                if(String.isNotBlank(mapQbSfInvFieldName.get('Id'))){
                    paymentLinkedTxn.TxnId = (String) qbInv.get(mapQbSfInvFieldName.get('Id'));
                }
                paymentLinkedTxn.TxnType = 'Invoice';
                paymentlineObj.LinkedTxn = new List<QBPaymentResponse.xLinkedTxn>{paymentLinkedTxn};
                paymentObj.Line = new List<QBPaymentResponse.xLine>{paymentlineObj};
                String respBody = Json.serialize(paymentObj,true);
                CalloutDetails cred = new CalloutDetails();
                cred.helper = 'InvoiceSyncController.createUpdateSFQbPayment';
                cred.recordId = (String) qbInv.get('Id');
                HTTPModel objHTTP = createUpdateQBPayment(respBody,cred);
                if (!objHTTP.isCalloutException) {
                    cmpRes.status = 'Success';
                    cmpRes.message = 'The Payment created Successfully with Quickbooks.';
                }else{
                    String failMsg = 'The  Payment creation in Quickbooks Failed';
                    cmpRes.status = 'Failed';
                    if(objHTTP.isCalloutException && objHTTP.response.contains('"Error"')){
                        QBErrorResponse.errorCls errorObj = QBErrorResponse.parseJSON(objHTTP.response);
                        String errorMsg = '';
                        for(QBErrorResponse.cls_Error error: errorObj.Fault.Error){
                            errorMsg+='Message : '+error.Message;
                            errorMsg+=' | Detail : '+error.Detail;
                            errorMsg+=' | Error code : '+error.code;
                            if(String.isNotBlank(error.element)){
                                errorMsg+=' | Error in  : '+error.element;
                            }
                            errorMsg+=' #### ';
                        }
                        if(String.isNotBlank(errorMsg)){
                            cmpRes.message = errorMsg;
                        }
                    }else{
                        cmpRes.message = failMsg+'.';
                    }
                }
                if(KTQB__QB_Log__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()){
                    insert as user qbLogs;
                }
                return Json.serialize(cmpRes);
            }else{
                CreatePaymentWrapper payWrp = new CreatePaymentWrapper();
                if(String.isNotBlank(mapQbSfInvFieldName.get('Name'))){
                    payWrp.invoiceName =(String) qbInv.get(mapQbSfInvFieldName.get('Name'));
                }
                if(String.isNotBlank(mapQbSfCustFieldName.get('GivenName')) && String.isNotBlank(mapQbSfCustFieldName.get('FamilyName')) && qbInvCust!=null){
                    if((String.isNotBlank((String) qbInvCust.get(mapQbSfCustFieldName.get('GivenName')))) && (String.isNotBlank((String) qbInvCust.get(mapQbSfCustFieldName.get('FamilyName'))))){
                        payWrp.invoiceCustomerName = ( (String) qbInvCust.get(mapQbSfCustFieldName.get('GivenName')) )+' '+( (String) qbInvCust.get(mapQbSfCustFieldName.get('FamilyName')) );
                    }
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('CurrencyRef'))){
                    payWrp.invoiceCurrencyCode =(String) qbInv.get(mapQbSfInvFieldName.get('CurrencyRef'));
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('TotalAmt'))){
                    payWrp.invoiceAmount =  String.valueOf(qbInv.get(mapQbSfInvFieldName.get('TotalAmt')));
                }
                if(String.isNotBlank(mapQbSfInvFieldName.get('Balance'))){
                    payWrp.invoiceBalance = String.valueOf(qbInv.get(mapQbSfInvFieldName.get('Balance')));
                }
                payWrp.mapPaymentMethod = new Map<String,String>();
                // if(QB_MetaData__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                    for(KTQB__QB_MetaData__c payMethod : [Select id, Name, KTQB__QB_Id__c from KTQB__QB_MetaData__c  
                                                        Where KTQB__Active__c =true AND KTQB__Type__c ='PaymentMethod'  WITH USER_MODE])
                        {
                            payWrp.mapPaymentMethod.put(payMethod.KTQB__QB_Id__c, payMethod.Name); 
                        }
                // }
                return Json.serialize(payWrp);
            }
        }catch(Exception exp){
            HandleCustomException.logException(exp);
            return Json.serialize(cmpRes);
        }
    }


    /** @description : Wrapper Class. */
    public class CreatePaymentWrapper {
        public Map<String,String> mapPaymentMethod;
        public String invoiceName;
        public String invoiceCurrencyCode;
        public String invoiceAmount;
        public String invoiceBalance;
        public String invoiceCustomerName;
        /** @description : For transactionId id. */
        @AuraEnabled public String transactionId {get;set;}
        /** @description : For transactionId date. */
        @AuraEnabled public String transactionDate {get;set;}
        /** @description : For transactionId amount paid. */
        @AuraEnabled public Decimal transactionAmountPaid {get;set;}
        /** @description : For payment method. */
        @AuraEnabled public String paymentMethod {get;set;}
        /** @description : For is payed boolean. */
        @AuraEnabled public Boolean isPayed {get;set;}
        /** @description : For invoice id. */
        @AuraEnabled public String invoiceId {get;set;}
    }
}