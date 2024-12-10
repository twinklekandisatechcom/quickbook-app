/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Invoice product create class
 * @created on        : 2024
 * Modified on 10/10/2024 by Twinkle
 */
public without sharing class InvoiceSyncCreateInvProductsDynamic implements Database.Batchable<Sobject>, Database.AllowsCallouts  {

    List<String> lstInvoiceIds= new List<String>();
    List<String> lstInvoiceLineItemIds= new List<String>();
    List<String> lstInvoiceCustChanged= new List<String>();

    string qbInvoiceId ='';

    String query ='';
    /**
     * @description Initializes an instance of `InvoiceSyncCreateInvProductsDynamic` with a query and a list of invoices with changed customers.
     * This constructor is used when the intention is to sync invoices based on customer changes.
     *
     * @param query A SOQL query string to retrieve specific invoice records for processing.
     * @param lstInvoiceCustChanged A list of invoice IDs where customer information has changed.
     */
    //for deleting payments.
    public InvoiceSyncCreateInvProductsDynamic(String query,List<String> lstInvoiceCustChanged){  
        this.query = query;
        this.lstInvoiceCustChanged = lstInvoiceCustChanged;
    }
    /**
     * @description Initializes an instance of `InvoiceSyncCreateInvProductsDynamic` with a query, a list of invoice IDs, and a list of invoice line item IDs.
     * This constructor is primarily used when deleting specific invoice line items.
     *
     * @param query A SOQL query string to retrieve specific records for deletion.
     * @param lstInvoiceIds A list of invoice IDs associated with the line items to be deleted.
     * @param lstInvoiceLineItemIds A list of line item IDs to delete from the specified invoices.
     */
    //for deleting line items.
    public InvoiceSyncCreateInvProductsDynamic(String query,List<String> lstInvoiceIds,List<String> lstInvoiceLineItemIds){  
        this.lstInvoiceIds = lstInvoiceIds;
        this.lstInvoiceLineItemIds = lstInvoiceLineItemIds;
        this.query = query;
    }
    /**
     * @description Prepares the SOQL query for batch processing by generating a query locator.
     * Retrieves records based on the specified query for batch processing.
     *
     * @param BC The batchable context object.
     * @return A query locator for batch processing, used to select records for the batch job.
     */
    //1. Batch class Method : For Deleting the non-existing Line items/payments records.
    public Database.QueryLocator start(Database.BatchableContext BC){


        // InvoiceSyncControllerDynamic.generateObjectFieldMapping();
        // String lineParentInvName = InvoiceSyncControllerDynamic.invoiceFieldApiNameOnLine;
        // if(lineParentInvName.containsIgnoreCase('__c')){
        //     lineParentInvName = lineParentInvName.replace('__c', '__r');
        // } 

        // String query ='SELECT id FROM '+
        //             String.escapeSingleQuotes(InvoiceSyncControllerDynamic.invoiceLineObjectApiName)+
        //             ' WHERE '+String.escapeSingleQuotes(lineParentInvName)+'.'+String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfInvFieldName.get('Id'))+ ' IN :lstInvoiceIds ';
        // if(lstInvoiceLineItemIds.size()>0){
        //     query += ' AND ' + String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfLineFieldName.get('LineItemId')) + ' NOT IN :lstInvoiceLineItemIds';
        // }    
         
        return Database.getQueryLocator(query);
     }
     /**
     * @description Executes the batch process on the specified scope of records, performing deletion of the records.
     * Exception handling is included to log any errors encountered during deletion.
     *
     * @param BC The batchable context object.
     * @param scope A list of SObject records to process in this batch.
     */
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        try{
            DELETE as user scope;
        }catch(exception exp){
            HandleCustomException.logException(exp);
        }
    }
    /**
     * @description Finalizes the batch process and executes any cleanup or logging tasks after completion.
     *
     * @param BC The batchable context object.
     */
    public void finish(Database.BatchableContext BC){
        boolean a = true;
        a.toString();
    }
}