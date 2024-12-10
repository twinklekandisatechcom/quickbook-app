trigger TestingInvoiceSyncFlowTrigger on KTQB__QB_Invoice__c (After Insert, After Update) {
    
    if(Trigger.isAfter){
        //if(Trigger.isInsert && Trigger.isUpdate) {
        if(Trigger.isUpdate) {    
            if(TestingInvoiceSyncFlow.recursion == false){
                System.debug('$$$ TestingInvoiceSyncFlowTrigger Trigger.new is: ' + Trigger.new);
                TestingInvoiceSyncFlow.syncInvoiceFromTrigger(Trigger.new);
            }
        }
    }
        
        /*if(Trigger.isUpdate){
            System.debug('$$$ TestingInvoiceSyncFlowTrigger Trigger.old is: ' + Trigger.old);
            TestingInvoiceSyncFlow.syncInvoiceFromTrigger(Trigger.old);
        } */
        
    
}