/**
 * @description       : serves as a utility for synchronizing invoice records.
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 10-07-2024
 * @last modified on  : 10-07-2024
 * @last modified by  : Piyush V. Ganorkar
*/

public with sharing class TestingInvoiceSyncFlow{
    public static Boolean recursion  = false;
    
    /**
     * @description syncInvoice method fetches a single KTQB__QB_Invoice__c record and
     *  initiates the synchronization process.
     */
    public static void syncInvoice() {
		
        KTQB__QB_Invoice__c qbInv = [ Select Id
                                      FROM KTQB__QB_Invoice__c  
                                      WITH USER_MODE LIMIT 1 ];
        
        List<String> lstRecordIds = new List<String> {qbInv.Id};
          
		InvoiceSyncControllerDynamic.globalCreateQbInv(lstRecordIds);
    }
    
    /**
     * @description : Used In TestingInvoiceSyncFlowTrigger
     * @param invIdList Accepts List of KTQB__QB_Invoice__c records
    */
    public static void syncInvoiceFromTrigger(List<KTQB__QB_Invoice__c> invIdList) { 
		recursion = true;
        if(invIdList.size()>0){
            List<String> lstRecordIds = new List<String> {invIdList[0].Id};
			InvoiceSyncControllerDynamic.globalCreateQbInv(lstRecordIds);
        }
    }
}