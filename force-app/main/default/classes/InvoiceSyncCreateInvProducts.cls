/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Payment handler class
 * @created on        : 2024
 * Modified on 10/10/2024 by Twinkle
 */
public with sharing class InvoiceSyncCreateInvProducts implements Queueable,Database.Batchable<Sobject>, Database.AllowsCallouts {
	public Static KTQB__QB_Setting__c setting = KTQB__QB_Setting__c.getInstance();
    map<String,String> mapLineItemProductQueable;
    list<String> lstProductref  = new list<String>();
    List<KTQB__QB_Invoice_Line_Item__c> lstInvoiceLines = new List<KTQB__QB_Invoice_Line_Item__c>();

    List<String> lstInvoiceLineItemIds= new List<String>();
    List<String> lstInvoiceIds= new List<String>();
    string qbInvoiceId ='';
    /**
     * @description Constructor for the InvoiceSyncCreateInvProducts class.
     * Initializes the list of invoice line items, a map of line item product details, and a list of product references.
     *
     * @param lstInvoiceLines List of KTQB__QB_Invoice_Line_Item__c records representing invoice line items.
     * @param mapLineItemProductQueable Map with line item product details, where the key is a string identifier and the value is the product reference.
    */
    public InvoiceSyncCreateInvProducts(List<KTQB__QB_Invoice_Line_Item__c> lstInvoiceLines, map<String,String> mapLineItemProductQueable) {
        this.lstInvoiceLines = lstInvoiceLines;
        this.mapLineItemProductQueable = mapLineItemProductQueable;
        this.lstProductref =  mapLineItemProductQueable.Values();
    }

    /**
     * @description Constructor for the InvoiceSyncCreateInvProducts class.
     *
     * @param lstInvoiceLineItemIds List of String IDs representing invoice line items.
     * @param lstInvoiceIds List of String IDs representing invoices.
     */
    public InvoiceSyncCreateInvProducts(List<String> lstInvoiceLineItemIds,List<String> lstInvoiceIds){  //[UPDATED CODE]
        this.lstInvoiceIds = lstInvoiceIds;
        this.lstInvoiceLineItemIds = lstInvoiceLineItemIds;
    }

   /**
     * @description Queuable to make a callout to get all the Product details and create products into SF.
     * @param context Represents the context in which the queueable job is running.
     *                This parameter provides job-specific information such as job ID.
     */

    public void execute(QueueableContext context) {        
        List<String> queryPaymentIds=new List<String>();
            for(String invPayId : lstProductref){
                queryPaymentIds.add('\''+ EncodingUtil.urlEncode(invPayId, 'UTF-8') + '\'');
            }
    }
    /**
     * @description helpermethod : To Upsert the Invoice line items when the missing products in SF are Inserted.
     * @param lstLineItems A list of `KTQB__QB_Invoice_Line_Item__c` items to be upserted.
     * @param isProductCreated A Boolean flag indicating whether the product associated 
     *                         with the invoice line item has been created in Salesforce.
     */
    public void upsertInvLineItems(List<KTQB__QB_Invoice_Line_Item__c> lstLineItems,Boolean isProductCreated){
        List<KTQB__QB_Invoice_Line_Item__c> lstInvLineItemsToUpsert = new List<KTQB__QB_Invoice_Line_Item__c>();
        for(KTQB__QB_Invoice_Line_Item__c item : lstLineItems){     
            if(isProductCreated == true){      
                item.putSObject(
                    'Product_Service__r',
                    new Product2(KTQB__Item_QB_Id__c = mapLineItemProductQueable.get(item.KTQB__Line_Item_Id__c))
                );
                lstInvLineItemsToUpsert.add(item);
            }else{
                Map<String, Object> itemMap = new Map<String, Object>( item.getPopulatedFieldsAsMap() );
                
                // Step 1. Remove any fields you don't want
                itemMap.remove( 'Product_Service__r' );

                // step 2: for getting the value related field is assigned by Referencing i.e. putSobject().
                Map<String, Object> InvoiceMap = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( itemMap.get('QB_Invoice__r') ) );
                String InvoiceId =(String) JSON.deserialize(Json.serialize(InvoiceMap.get('KTQB__Invoice_Qb_Id__c')),String.class);
                
                // Step 3. Convert the map into sobjecKTQB__QB_Invoice_Line_Item__c, using the old serialize/deserialize trick
                KTQB__QB_Invoice_Line_Item__c lineItemClone = (KTQB__QB_Invoice_Line_Item__c) JSON.deserialize( JSON.serialize( itemMap ), KTQB__QB_Invoice_Line_Item__c.class );
                lineItemClone.putSObject(
                    'QB_Invoice__r',
                    new KTQB__QB_Invoice__c(KTQB__Invoice_Qb_Id__c = InvoiceId)
                );
                lstInvLineItemsToUpsert.add(lineItemClone);

            }
        }
        try{
        	upsert as user lstInvLineItemsToUpsert KTQB__Line_Item_Id__c;
        }catch(exception e){
             HandleCustomException.logException(e);
        }
    }

    /**
     * @description Batch class Method : For Deleting the non-existing Line items records.
     * @param BC The `BatchableContext` instance passed by the batch runtime.
     * @return Database.QueryLocator The query locator for the batch.
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        // string query = 'SELECT id,name FROM KTQB__QB_Invoice_Line_Item__c where QB_Invoice__r.KTQB__Invoice_Qb_Id__c =:qbInvoiceId'; //[OLD CODE]
        string query = 'SELECT id,name FROM KTQB__QB_Invoice_Line_Item__c where QB_Invoice__r.KTQB__Invoice_Qb_Id__c IN :lstInvoiceIds'; //[UPDATED CODE]
        if(lstInvoiceLineItemIds.size()>0){
            query += ' AND KTQB__Line_Item_Id__c NOT IN :lstInvoiceLineItemIds';
        }
        //system.debug(query);
        return Database.getQueryLocator(query);
     }
     /**
     * @description Executes the batch process on the current scope of `KTQB__QB_Invoice_Line_Item__c` records.
     * @param BC The `BatchableContext` instance passed by the batch runtime.
     * @param scope A list of `KTQB__QB_Invoice_Line_Item__c` records retrieved from the `start` method query.
     */
    public void execute(Database.BatchableContext BC, List<KTQB__QB_Invoice_Line_Item__c> scope){
    DELETE as user scope;
    }
    /**
     * @description Called after all batch records have been processed, logging the completion of the deletion process.
     * 
     * @param BC The `BatchableContext` instance passed by the batch runtime.
     */
    public void finish(Database.BatchableContext BC){
        boolean a = true;
        a.toString();
    }

}