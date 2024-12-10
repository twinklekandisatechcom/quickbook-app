/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Setup and Configuration Component [SetupConfigCmp] & [invoiceConfigurationCmp] & [currencyConfigCmp]
 * @created on        : 2023
 * @last modified on  : 16-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
public with sharing class QbMetaDataController {
    /** 
     * @description Multiple Components - To Qb to Sf objects for Invoice
     * @param type - 'salesTax'/'companycurrency'/'account'/'term'/'companycurrency'/'paymentMethod'/
     * @return String - 'success'/'Check Quickbook Connection to Salesforce'/wrapMetaDataFault.Fault.Error[0].Message/''
     */
    @AuraEnabled public static string syncQbInvoiceObject(string type){
        try{
            Boolean successFlag = false;
            List<QB_MetaData__c> objectSFList = new List<QB_MetaData__c>();
            Map<String, QB_MetaData__c> metadataMap = new Map<String, QB_MetaData__c>();
            List<QB_MetaData__c> qbUpdateList = new List<QB_MetaData__c>();
            // get from sf
            objectSFList = [SELECT Id, Name, KTQB__Type__c, KTQB__QB_Id__c, KTQB__Sales_Tax_Rate__c FROM QB_MetaData__c WHERE KTQB__Type__c = :type WITH USER_MODE];
            if(objectSFList.size()>0){
                for(QB_MetaData__c entity : objectSFList){
                   metadataMap.put(entity.KTQB__QB_Id__c,entity);
                }
            }
            // fetch from QB
            contact customer = new contact();
            //customer.id=type;
            CalloutUtlityController.calloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
            string endpoints = '';
            if(type == 'salesTax'){
            	endpoints = 'query?query=select+*+from+Taxcode+where+Active=true&';
            }else if(type == 'companycurrency'){
            	endpoints = 'query?query=select+*+from+companycurrency+where+Active=true&';
            }else if(type == 'account'){
                endpoints = 'query?query=select+*+from+account+where+AccountType=\'Income\'+AND+SubAccount=false&';
            }else{
                endpoints = 'query?query=select+*+from+'+type+'&';
            }
            cred = CalloutUtlityController.calloutHelperMethod('GET', endpoints,type,customer);
            if(String.isNotBlank(cred.responsebody.getBody()) && String.valueOf(cred.responsebody.getStatusCode()) == '200'){
                MetaDataQueryResponseMain wrpData = (MetaDataQueryResponseMain) JSON.deserialize(cred.responsebody.getBody(), MetaDataQueryResponseMain.class);
                if(wrpData.queryResponse != null){
                    List<ClsObject> lstData = new List<ClsObject>();
                    if(type=='Term'){
                        lstData = wrpData.queryResponse.term;
                    }else if(type == 'Account'){
                        lstData = wrpData.queryResponse.account;
                    }else if(type == 'CompanyCurrency'){
                        lstData = wrpData.queryResponse.companyCurrency;
                    }else if(type == 'PaymentMethod'){
                        lstData = wrpData.queryResponse.paymentMethod;
                    }
                    
                    if(type == 'salesTax') {
                       Set<String> uniqueTaxRateIds = new Set<String>();
                       String result = '(';
                       lstData = wrpData.queryResponse.taxCode;
                        for(integer i=0;i<(lstData.size());i++){
                            for(integer j=0;j<(lstData[i].salesTaxRateList.taxRateDetail.size());j++){
                                String taxRateValue = lstData[i].salesTaxRateList.taxRateDetail[j].taxRateRef.value;
        						uniqueTaxRateIds.add('\'' + taxRateValue + '\'');
                            }
                        }
                        result += String.join(new List<String>(uniqueTaxRateIds), ',');
						result += ')';
                        string taxRateEndpoints = 'query?query=select+*+from+Taxrate+where+id+In+'+result+'&';
                        CalloutUtlityController.calloutCredentials cred1 = new CalloutUtlityController.CalloutCredentials();
                        cred1 = CalloutUtlityController.calloutHelperMethod('GET', taxRateEndpoints,type,customer);
                        if(String.isNotBlank(cred1.responsebody.getBody()) && String.valueOf(cred1.responsebody.getStatusCode()) == '200'){
                      	MetaDataQueryResponseMain wrpData1 = (MetaDataQueryResponseMain) JSON.deserialize(cred1.responsebody.getBody(), MetaDataQueryResponseMain.class);
                            if(wrpData1.queryResponse != null){
                                List<ClsObject> lstData1 = wrpData1.queryResponse.TaxRate;
                                Set<String> uniqueTaxRateSet = new Set<String>();
            					List<ClsObject> uniqueLstData1 = new List<ClsObject>();
                                for (ClsObject taxRate : lstData1) {
                                    if (!uniqueTaxRateSet.contains(taxRate.id)) {
                                        uniqueTaxRateSet.add(taxRate.id);
                                        uniqueLstData1.add(taxRate);
                                    }
                                }
                                if(uniqueLstData1.size() > 0 && lstData.size() > 0){
                                    for(integer i=0;i<(lstData.size());i++){
                                        QB_MetaData__c qb = new QB_MetaData__c();
                                        if(metadataMap.containsKey(lstData[i].id)){
                                            qb.Id = metadataMap.get(lstData[i].id).id;
                                            metadataMap.remove(lstData[i].id);
                                        }
                                        qb.Name = lstData[i].name;
                                        qb.KTQB__Type__c = 'salesTax';
                                        qb.KTQB__QB_Id__c = lstData[i].id;
                                        qb.KTQB__Active__c = true;
                                        decimal taxpercent = 0;
                                        for(integer j=0;j<(lstData[i].salesTaxRateList.taxRateDetail.size());j++){
                                            for(ClsObject taxrate : uniqueLstData1){
                                                if(lstData[i].salesTaxRateList.taxRateDetail[j].taxRateRef.value == taxrate.id){
                                                    taxpercent += Decimal.valueOf(taxrate.RateValue);   
                                                }
                                            }
                                        }
                                        qb.KTQB__Sales_Tax_Rate__c = taxpercent;
                                       
                                        qbUpdateList.add(qb);
                                    }
                                }
                            }
                        }
                    }
                    else{
                        for(integer i=0;i<(lstData.size());i++){
                            //if(wrpData.queryResponse.term[i].Id != '7'){
                            QB_MetaData__c qb = new QB_MetaData__c();
                            if(metadataMap.containsKey(lstData[i].id)){
                                qb.Id = metadataMap.get(lstData[i].id).id;
                                metadataMap.remove(lstData[i].id);
                            }
                            if((type == 'Account' || type == 'Term' || type == 'companycurrency' || type == 'PaymentMethod') && lstData[i].AccountType != 'Expense'){
                                qb.Name =lstData[i].name;
                                qb.KTQB__QB_Id__c = lstData[i].id;
                                qb.KTQB__Type__c = type;
                                qb.KTQB__Active__c = lstData[i].active;
                                qb.KTQB__Currency_Code__c = lstData[i].code;
                                qbUpdateList.add(qb);	
                            }
                        }
                    }
                    // Upsert
                    upsert as user qbUpdateList;
                    successFlag = true;
                    //Database.UpsertResult[] srLI = Database.upsert(qbUpdateList,AccessLevel.User_mode);
                    /*for (Database.UpsertResult result : srLI) {
                        if (result.isSuccess()) {
                            successFlag = true;
                            continue;
                        }else {
                            successFlag = false;
                            break;
                        }
                    }*/
                       
                    
                    // Delete Records if not identified in QB and still present in Salesforce
                    if(metadataMap.keySet().size()>0){
                        List<QB_MetaData__c> deleteList = new List<QB_MetaData__c>(); 
                        for(String s : metadataMap.keySet()){
                            QB_MetaData__c qb = new QB_MetaData__c();
                            qb.Id = metadataMap.get(s).id;
                            if (qb.Id != null) {
                             	deleteList.add(qb);
                            }
                        }
                        Database.DeleteResult[] drList = Database.delete(deleteList,AccessLevel.User_mode);
                        for(Database.DeleteResult dr : drList) {
                            if (dr.isSuccess()) {
                                successFlag = true;
                                continue;
                            }else {
                                successFlag = false;
                                break;
                            }
                        }
                    }
                }
                if(successFlag && qbUpdateList.size()>0){
                    return 'success';
                }
            }else if(cred.responsebody.getStatus() == 'Unauthorized'){
                return 'Check Quickbook Connection to Salesforce';
            }else{
            	FaultMetaDataQueryResponseMain wrapMetaDataFault = (FaultMetaDataQueryResponseMain) JSON.deserialize(cred.responsebody.getbody(), FaultMetaDataQueryResponseMain.class);
                return wrapMetaDataFault.fault.error[0].Message;
            }
        }catch(exception e){
            HandleCustomException.logException(e);
        }
        return '';
    }

    /** @description Multiple Component : Wrapper Class. */
    public class MetaDataQueryResponseMain{
        /** @description Multiple Component : For queryResponse. */
        @AuraEnabled public ClsQueryResponse queryResponse;
    }
    
    /** @description Multiple Component : Wrapper Class. */
    public class ClsQueryResponse{
        /** @description Multiple Component : For Term. */
        @AuraEnabled public List<ClsObject> term;
        /** @description Multiple Component : For Account. */
        @AuraEnabled public List<ClsObject> account;
        /** @description Multiple Component : For TaxCode. */
        @AuraEnabled public List<ClsObject> taxCode;
        /** @description Multiple Component : For TaxRate. */
        @AuraEnabled public List<ClsObject> taxRate;
        /** @description Multiple Component : For CompanyCurrency. */
        @AuraEnabled public List<ClsObject> companyCurrency;
        /** @description Multiple Component : For PaymentMethod. */
        @AuraEnabled public List<ClsObject> paymentMethod;
    }

    /** @description Multiple Component : Wrapper Class. */
    public class ClsObject{
        /** @description Multiple Component : For Name. */
        @AuraEnabled public string name;
        /** @description Multiple Component : For Code. */
        @AuraEnabled public string code;
        /** @description Multiple Component : For Id. */
        @AuraEnabled public string id;
        /** @description Multiple Component : For Active. */
        @AuraEnabled public boolean active;
        /** @description Multiple Component : For Message. */
        @AuraEnabled public string message;
        /** @description Multiple Component : For RateValue. */
        @AuraEnabled public string rateValue;
        /** @description Multiple Component : For AccountType. */
        @AuraEnabled public string accountType;
        /** @description Multiple Component : For salesTaxRateList. */
        @AuraEnabled public SalesTaxRateList salesTaxRateList{get;set;}
    }

    /** @description Multiple Component : Wrapper Class. */
    public class SalesTaxRateList{
        /** @description Multiple Component : For taxRateDetail. */
		@AuraEnabled public list<TaxRateDetail> taxRateDetail{get;set;}
	}

    /** @description Multiple Component : Wrapper Class. */
    public class TaxRateDetail{
        /** @description Multiple Component : For taxRateRef. */
		@AuraEnabled public TaxRateRef taxRateRef{get;set;}
	}

    /** @description Multiple Component : Wrapper Class. */
    public class TaxRateRef{
        /** @description Multiple Component : For name. */
		@AuraEnabled public String name{get;set;}
        /** @description Multiple Component : For value. */
		@AuraEnabled public String value{get;set;}
	}

    /** @description Multiple Component : Wrapper Class. */
    public class FaultMetaDataQueryResponseMain{
        /** @description Multiple Component : For Fault. */
        @AuraEnabled public MetaDataFaultQueryWrapper fault;
    }

    /** @description Multiple Component : Wrapper Class. */
    public class MetaDataFaultQueryWrapper{
        /** @description Multiple Component : For Error. */
        @AuraEnabled public List<ClsObject> error; 
    }
}