/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Currency Configuration Component [currencyConfigCmp]
 * @created on        : 2023
 * @last modified on  : 16-10-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
//PMD.ApexSuggestUsingNamedCred - For avoiding authoziaztion credetials pmd error : as we used Custom Object for Authorization.
//@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class CurrencyConfigController {
    /** @description Currency Configuration Component : Wrapper Class. */
    public class CurrencyWrapper{
        /** @description Currency Configuration Component : For salesforceCurr. */
        @AuraEnabled public list<String> salesforceCurr {get;set;}
        /** @description Currency Configuration Component : For qBCurr. */
        @AuraEnabled public list<String> qBCurr {get;set;}
    }
    
    /**
     * @description Currency Configuration Component : To fetch salesforce and quickbook currencies.
     * @return List of Currencies
     */
    @AuraEnabled public static CurrencyWrapper getCurrency(){
        CurrencyWrapper currWrap = new CurrencyWrapper();
        try {
            //Fetching Salesforce Currencies
            if(Utils.getIsMultiCurrencyOrg()){
                String query = 'SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate, CreatedDate FROM CurrencyType WHERE IsActive = true ORDER BY CreatedDate DESC';
                Map<String, Object> bindValues = new Map<String, Object> {'isActive' => true};
                List<SObject> salesforceCurrList = Database.queryWithBinds(
                    String.escapeSingleQuotes(query),
                    bindValues,
                    AccessLevel.USER_MODE
                );
                List<String> salesforceCurr = new list<String>();
                for(SObject obj : salesforceCurrList){
                    salesforceCurr.add((String)obj.get('IsoCode'));
                }
                currWrap.salesforceCurr = salesforceCurr;
                
            }else{
                String curr = UserInfo.getDefaultCurrency();
                List<String> salesforceCurr = new list<String>();
                salesforceCurr.add(curr);
                currWrap.salesforceCurr = salesforceCurr;
            }
         
            //Fetching Quickbook Currencies
            QbMetaDataController.syncQbInvoiceObject('companycurrency');
            List<KTQB__QB_MetaData__c> qbCurrList = new List<KTQB__QB_MetaData__c>([ SELECT Id, Name, CurrencyIsoCode, KTQB__Type__c, KTQB__Active__c, 
                                                                                    KTQB__QB_Id__c, KTQB__Sales_Tax_Rate__c, KTQB__Currency_Code__c 
                                                                             FROM KTQB__QB_MetaData__c 
                                                                             WHERE (KTQB__Active__c = true AND KTQB__Type__c = 'companycurrency')
                                                                             ORDER BY CreatedDate DESC ]);
            List<String> qbCurrency = new List<string>();
            for(KTQB__QB_MetaData__c obj : qbCurrList){
                qbCurrency.add(obj.KTQB__Currency_Code__c);
            }
            currWrap.QBCurr = qbCurrency;
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return currWrap;
    }
    
    /**
     * @description Currency Configuration Component : To create currency in salesforce.
     * @param qBCurrTobeCreated - Currency
     * @return Response 
     */
    @AuraEnabled public static string createQBCurrencies(String qBCurrTobeCreated){

        String responseString = '';
        String qBCurrency = qBCurrTobeCreated.removeEnd('-');
        try {
            KTQB__QB_Setting__c setting = KTQB__QB_Setting__c.getInstance();
            string authorizationHeader = 'Bearer '+Utils.processDecryption(CalloutUtlityController.qbInfo.KTQB__Access_Token__c);
            string endpoint =  CalloutUtlityController.qbInfo.KTQB__Sandbox_Url__c+Utils.processDecryption(CalloutUtlityController.qbInfo.KTQB__QB_Company_Id__c)+'/companycurrency?minorversion='+setting.KTQB__QB_version__c;
            Http hp =new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            string body = '{' +
                 + ' "Code": "'+qBCurrency+'"'
             +'}';
            req.setBody(body);
            CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
            HttpResponse res = hp.send(req);
            cred.responsebody = res;
            cred.requestbody = req;
            CalloutUtlityController.createQBLog(cred,'');
            if(CalloutUtlityController.qbLogs.size() > 0){
                insert as user CalloutUtlityController.qbLogs;
            }
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(String.valueOf(res.getStatusCode()) == '200' && !responseMap.containsKey('Fault')){
                responseString = 'QuickBook currency created succesfully.';
            }else{
                Map<String, Object> errorMap = (Map<String, Object>) responseMap.get('Fault');
                List<Object> errorList = (List<Object>) errorMap.get('Error');
                Map<String, Object> errorDetails = (Map<String, Object>) errorList[0];
                responseString = (String) errorDetails.get('Message');
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return responseString;
    }
    
    /**
     * @description Currency Configuration Component : To create currency in salesforce.
     * @return Salesforce Base Url + Additional Url
     */
    @AuraEnabled public static string getCurrencyURL(){
        return URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/setup/CompanyCurrency/page?address=%2Fsetup%2Fcur%2Fcurrencylist.jsp';
    }
}