/**
 * @description : QBProductController class designed to handle the insertion and updating of product records
 *  in QuickBooks via a web service call.
 */
public with sharing class QBProductController {
    
     /**
     * @description accepts a JSON string to insertion into QuickBooks
     * @param lineItemData String
     * @return string
     */
    @AuraEnabled
    public static string insertProductOnQb(string lineItemData){
         try {
             Map<String, String> oppProdMap = new Map<String, String>();
             OpportunityLineItem product = new OpportunityLineItem();
             OppproductWrapper oppProducts =  new OppproductWrapper();
             list<product2> proListToUpdate = new list<product2>();
             oppProducts = (OppproductWrapper)JSON.deserialize(lineItemData,OppproductWrapper.class);
             string productName = (oppProducts.productName == '') ? 'test' : oppProducts.productName; 
             String itemsJSON;
                itemsJSON = '{' +
                + ' "Name":"'+productName+'",'
                + ' "Description":"'+oppProducts.productDesc+'",'
                + ' "Sku":"'+oppProducts.code+'",'
                + ' "Taxable":"'+oppProducts.taxable+'",'
                + ' "Active":true,'
                + ' "UnitPrice":"'+oppProducts.rate+'",'
                + ' "Type":"Service",'
                + ' "ExpenseAccountRef": { "value":'+ oppProducts.expenseAccount +'},'
                    + ' "IncomeAccountRef": { "value":'+ oppProducts.incomeAccount + '}}';
                CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
                cred = CalloutUtlityController.calloutToCreateUpdateItemInQb(product,itemsJSON);
               
                if(String.isNotBlank(cred.responseBody.getBody()) &&  String.valueOf(cred.responsebody.getStatusCode()) == '200'){
                    SingleProductWrapper wrapProduct = new SingleProductWrapper();
                    wrapProduct = (SingleProductWrapper) JSON.deserialize(cred.responseBody.getBody(), SingleProductWrapper.class);
                    oppProdMap.put(oppProducts.productId,wrapProduct.Item.id);
                    if(oppProdMap.size() > 0){
                        for(product2 pro : [select id,KTQB__Item_QB_Id__c from Product2 where id in :oppProdMap.keySet() WITH USER_MODE]){
                            pro.KTQB__Item_QB_Id__c = oppProdMap.get(pro.id);
                            CalloutUtlityController.createQBLog(cred,pro.id);
                            proListToUpdate.add(pro);
                        }
                    }
                    if(proListToUpdate.size() > 0){
                        if(Schema.sObjectType.product2.isUpdateable()){
                            update as user proListToUpdate;
                        }
                        if(CalloutUtlityController.qbLogs.size() > 0)
                        {
                            insert as user CalloutUtlityController.qbLogs;
                        }
                        return 'success';
                    }
                }if(cred.responsebody.getStatus() == 'Unauthorized'){
                    return 'Check Quickbook Connection to Salesforce';
                }else{
                    calloutUtlityController.createQBLog(cred,'');
                    if(CalloutUtlityController.qbLogs.size() > 0){
                        insert as user CalloutUtlityController.qbLogs;
                    }
                    ProductFaultQueryResponseMain wrapProduct1 = (ProductFaultQueryResponseMain) JSON.deserialize(cred.responseBody.getBody(), ProductFaultQueryResponseMain.class);
                    return wrapProduct1.Fault.Error[0].Message;
                }              
         }catch(exception e){
             HandleCustomException.logException(e);
         }
         return 'Something Went Wrong';
    }

     /**
     * @description ProductDataWrapper wrapper class
     */
    public class ProductDataWrapper{
        @AuraEnabled public String Id; 
        @AuraEnabled public String SyncToken;
        @AuraEnabled public string Name;
        @AuraEnabled public string Sku;
        @AuraEnabled public string Message;
        @AuraEnabled public string Description;
        @AuraEnabled public boolean Active;
    }
    
     /**
     * @description ProductFaultQueryResponseMain class is used in conjunction with API calls to QuickBooks
     */
    public class ProductFaultQueryResponseMain{
        @AuraEnabled public ProductFaultQueryWrapper Fault;
    }

    /**
     * @description : The ProductFaultQueryWrapper class is a data structure designed to
     *  encapsulate error information returned by the QuickBooks API
     */
    public class ProductFaultQueryWrapper{
        public List<ProductDataWrapper> Error; 
    }

    /**
    * @description : Wrapper For the Create or Update  QB Record Response.
    */
    public class SingleProductWrapper{
        public ProductDataWrapper Item;
        public ProductDataWrapper Fault; 
    }

    /**
     * @description OppproductWrapper wrapper class
     */
    public class OppproductWrapper{
       
        /**
        * @description productId
        */
        @AuraEnabled public String productId {get;set;}

        /**
        * @description productName
        */
        @AuraEnabled public String productName {get;set;}

        /**
        * @description expenseAccount
        */
        @AuraEnabled public String expenseAccount {get;set;}

        /**
        * @description incomeAccount
        */
        @AuraEnabled public String incomeAccount {get;set;}
        
        /**
        * @description code
        */
        @AuraEnabled public String code {get;set;}
        
        /**
        * @description productDesc
        */
        @AuraEnabled public String productDesc {get;set;}
        
        /**
        * @description quantity
        */
        @AuraEnabled public Double quantity {get;set;}
        
        /**
        * @description rate
        */
        @AuraEnabled public Double rate {get;set;}
        
        /**
        * @description amount
        */
        @AuraEnabled public Double amount {get;set;}
        
        /**
        * @description taxable
        */
        @AuraEnabled public boolean taxable{get;set;}
        
        /**
        * @description qbProductCode
        */
        @AuraEnabled public string qbProductCode{get;set;}
    }
}