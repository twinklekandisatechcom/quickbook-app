/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Payment handler class
 * @created on        : 2024
 * Modified on 09/10/2024 by Twinkle
 */
public without sharing class InvoicePaymentsHandlerBtchCls implements Database.Batchable<Sobject>{
    // Map to store payment IDs with their related invoice IDs
    map<String,List<String>> mapPayIdInvoiceIds = new  map<String,List<String>>();
    // Map to store payment IDs with their respective sync tokens
    Map<String,Integer> mapPayIdSyncToken = new Map<String,Integer>();
    // List to store payment IDs for processing
    List<String> lstPaymentIds = new List<String>();
    // Name of the parent invoice line item field
    String lineParentInvName = '';
     /**
     * @description Constructor for InvoicePaymentsHandlerBtchCls.
     *
     * @param mapPayIdInvoiceIds Map of payment IDs to corresponding list of invoice IDs.
     * @param mapPayIdSyncToken  Map of payment IDs to their synchronization tokens.
     */
    public InvoicePaymentsHandlerBtchCls(map<String,List<String>> mapPayIdInvoiceIds, Map<String,Integer> mapPayIdSyncToken) {
        this.mapPayIdInvoiceIds = mapPayIdInvoiceIds;
        this.lstPaymentIds = new List<String>(mapPayIdInvoiceIds.KeySet());
        this.mapPayIdSyncToken = mapPayIdSyncToken;
    }

    /**
     * @description Prepares a SOQL query to fetch payments based on their IDs and related invoice data.
     *
     * @param BC Batchable context for tracking the batch process.
     * @return Database.QueryLocator A query locator to retrieve the required payment records.
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        lineParentInvName = setupMappings();

        String query = 'SELECT id';
        if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'))){
            query+=','+String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'));
        }
        if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('SyncToken'))){
            query+=','+String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('SyncToken'));
        }
        if(String.isNotBlank(lineParentInvName)){
            if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfInvFieldName.get('Id'))){
                query+=','+String.escapeSingleQuotes(lineParentInvName)+'.'+String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfInvFieldName.get('Id'));
            }
        }
        if(String.isNotBlank(InvoiceSyncControllerDynamic.paymentObjectApiName)){
            query+=' FROM '+ String.escapeSingleQuotes(InvoiceSyncControllerDynamic.paymentObjectApiName);
        }
        if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'))){
            query+=' WHERE '+String.escapeSingleQuotes(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'))+ ' IN :lstPaymentIds ';
        }

        return Database.getQueryLocator(query);
    }
    /**
     * @description Processes a batch of payment records and deletes those that do not match specified conditions.
     *
     * @param BC     Batchable context for tracking the batch process.
     * @param scope  List of payment records to process in this batch execution.
     */
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        try{
            lineParentInvName = setupMappings();

            List<SObject> lstPaymentToDelete = new List<SObject>();
            for(SObject paymentRec : scope){
                if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'))){
                    List<String> lstRelatedInvoiceIds = mapPayIdInvoiceIds.get((String) paymentRec.get(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id')));

                    if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfInvFieldName.get('Id')) &&  String.isNotBlank(lineParentInvName)){
                        if(!lstRelatedInvoiceIds.contains((String) paymentRec.getSObject(lineParentInvName).get(InvoiceSyncControllerDynamic.mapQbSfInvFieldName.get('Id')))){
                            lstPaymentToDelete.add(paymentRec);
                        }
                    }

                    if(String.isNotBlank(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('SyncToken'))){
                    if( ((Decimal) paymentRec.get(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('SyncToken')))
                        != ( (Decimal) mapPayIdSyncToken.get((String) paymentRec.get(InvoiceSyncControllerDynamic.mapQbSfPaymentFieldName.get('Id'))) )){
                            lstPaymentToDelete.add(paymentRec);
                        } 
                    }
                }
            }

            if(lstPaymentToDelete.size() > 0){
                Delete as user lstPaymentToDelete;
            }
        }catch(exception exp){
            HandleCustomException.logException(exp);
        }
    }
    /**
     * @description Completes the batch process by logging successful deletion of non-existing payments.
     *
     * @param BC Batchable context for tracking the batch process.
     */
    public void finish(Database.BatchableContext BC){
        boolean a = true;
        a.toString();
    }

    /**
     * @description Helper method for setting up mappings for QuickBooks setup mapped data.
     * Initializes the mapping from InvoiceSyncControllerDynamic and sets the parent invoice name.
     *
     * @return String Name of the parent invoice line item field.
     */
    public String setupMappings(){
        InvoiceSyncControllerDynamic.generateObjectFieldMapping();
        if(String.isNotBlank(InvoiceSyncControllerDynamic.invoiceFieldApiNameOnLine)){
            lineParentInvName = InvoiceSyncControllerDynamic.invoiceFieldApiNameOnLine;
            if(lineParentInvName.containsIgnoreCase('__c')){
                lineParentInvName = lineParentInvName.replace('__c', '__r');
            } 
            if(String.isNotBlank(lineParentInvName)){
                return lineParentInvName;
            }
        }
        return '';
    }

}