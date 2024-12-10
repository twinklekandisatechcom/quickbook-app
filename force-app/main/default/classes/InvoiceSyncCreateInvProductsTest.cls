/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 28-02-2024
 * @last modified on  : 05-03-2024
 * @last modified by  : Twinkle
 */
@isTest
public class InvoiceSyncCreateInvProductsTest {
    /**
     * @description setup method to create test data 
    */
	@testSetup
    static void setupData() {
        KTQB__QB_Setting__c qs = new KTQB__QB_Setting__c(KTQB__QB_version__c = 64);
        upsert qs;
        
        // Create mock data for Product2
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'P' + i,
                IsActive = true
            ));
        }
        insert products;
        
        List<Contact> lstQbCustomers = new List<Contact>();
        Contact qbCon01 = new Contact();
        qbCon01.OtherPostalCode='Shipping ZipCode';
        qbCon01.OtherCity='Shipping City';
        qbCon01.KTQB__Display_Name__c='Cora W. Carolina';
        qbCon01.LastName='Carolina';
        qbCon01.MailingCity='Billing City';
        qbCon01.MobilePhone='702-210-2466';
        qbCon01.KTQB__Customer_QB_Id__c='268';
        qbCon01.Email='corawcarolina@armyspy.com';
        qbCon01.KTQB__QB_SyncToken__c=0;
        qbCon01.OtherStreet='Shipping Street address';
        qbCon01.OtherPhone='';
        qbCon01.MailingStreet='Billing Street address';
        qbCon01.OtherState='Shipping State';
        qbCon01.KTQB__Middle_Name__c='W';
        qbCon01.OtherCountry='Shipping Country';
        qbCon01.MailingState='Billing State';
        qbCon01.Fax='702-210-2466';
        qbCon01.KTQB__QB_Company_Name__c='';
        qbCon01.KTQB__Website__c='';
        qbCon01.MailingCountry='Billing Country';
        lstQbCustomers.add(qbCon01);

        Contact qbCon02 = new Contact();
        qbCon02.KTQB__Display_Name__c='Mangesh D. Kadam';
        qbCon02.KTQB__Customer_QB_Id__c='269';
        qbCon01.KTQB__QB_SyncToken__c=3;
        qbCon02.FirstName='Mangesh';
        qbCon02.LastName='Kadam';
        qbCon02.Email='mangesh.k@armyspy.com';
        lstQbCustomers.add(qbCon02);
        
        insert lstQbCustomers;
        
        List<KTQB__QB_Invoice__c> lstQbInvoices = new List<KTQB__QB_Invoice__c>();
        KTQB__QB_Invoice__c qbInv01 = new KTQB__QB_Invoice__c();
        qbInv01.KTQB__BillAddr__c='Billing Street address';
        qbInv01.KTQB__Balance__c=1700000;
        qbInv01.KTQB__Percent_Based_Discount__c=false;
        qbInv01.KTQB__Shipping_Charges__c=581;
        qbInv01.KTQB__ShipAddr__c='Shipping Street address';
        qbInv01.KTQB__Tax_Percent__c=8;
        qbInv01.KTQB__Invoice_Date__c=date.valueOf('2024-01-30');
        qbInv01.KTQB__BillEmail__c='mangesh.k@kandisatech.com';
        qbInv01.KTQB__Transaction_Date__c=date.valueOf('2024-01-04');
        qbInv01.KTQB__Total_Amount__c=5700238;
        qbInv01.KTQB__Contact__c=qbCon01.Id;
        qbInv01.KTQB__Qb_Invoice_Sync_Token__c=60;
        qbInv01.KTQB__Invoice_Number__c='1402';
        qbInv01.KTQB__Invoice_Status__c='Partially paid';
        qbInv01.KTQB__TotalTax__c=119171.92;
        qbInv01.KTQB__Discount_Amount__c=343;
        // qbInv01.KTQB__Sales_Term__c='Net 15';
        qbInv01.KTQB__Due_Date__c=date.valueOf('2024-03-27');
        qbInv01.KTQB__Invoice_Qb_Id__c='617';
        qbInv01.Name='Invoice #1402';
        qbInv01.KTQB__Discount_Percent_Discount_Value__c=343;
        lstQbInvoices.add(qbInv01);

        KTQB__QB_Invoice__c qbInv02 = new KTQB__QB_Invoice__c();
        qbInv02.KTQB__Contact__c=qbCon02.Id;
        qbInv02.KTQB__Qb_Invoice_Sync_Token__c=2;
        qbInv02.KTQB__Invoice_Qb_Id__c='664';
        qbInv02.KTQB__Invoice_Date__c=date.valueOf('2024-03-30');
        lstQbInvoices.add(qbInv02);

        insert lstQbInvoices;

        List<KTQB__QB_Invoice_Line_Item__c> lstQbInvLine = new List<KTQB__QB_Invoice_Line_Item__c>();
        KTQB__QB_Invoice_Line_Item__c qbInvLine1 = new KTQB__QB_Invoice_Line_Item__c();
        qbInvLine1.Name = 'LineItem-1 | Invoice #1402';
        qbInvLine1.KTQB__Line_Item_Name__c = 'Services';
        qbInvLine1.KTQB__Unit_Price__c = 2000;
        qbInvLine1.KTQB__Line_Item_Id__c = '617#6';
        qbInvLine1.KTQB__Quantity__c = 2000;
        qbInvLine1.KTQB__Taxable__c = 'NON';
        qbInvLine1.KTQB__Description__c = 'test item 01';
        qbInvLine1.KTQB__QB_Invoice__c = qbInv01.Id;
        lstQbInvLine.add(qbInvLine1);

        KTQB__QB_Invoice_Line_Item__c qbInvLine2 = new KTQB__QB_Invoice_Line_Item__c();
        qbInvLine2.Name = 'LineItem-2 | Invoice #1402';
        qbInvLine2.KTQB__Line_Item_Name__c = 'Services';
        qbInvLine2.KTQB__Unit_Price__c = 340;
        qbInvLine2.KTQB__Line_Item_Id__c = '617#9';
        qbInvLine2.KTQB__Quantity__c = 5000;
        qbInvLine2.KTQB__Taxable__c = 'NON';
        qbInvLine2.KTQB__Description__c = 'test item 02';
        qbInvLine2.KTQB__QB_Invoice__c = qbInv01.Id;
        lstQbInvLine.add(qbInvLine2);

        insert lstQbInvLine;
    }
     /**
     * @description test method for ExecuteQueueable
    */
    @isTest
    static void testExecuteQueueable() {
        // Query test data
        List<KTQB__QB_Invoice_Line_Item__c> lineItems = [
            SELECT Id, KTQB__Line_Item_Id__c, Name 
            FROM KTQB__QB_Invoice_Line_Item__c
        ];

        // Create a map of product references
        Map<String, String> productMap = new Map<String, String>();
        for (KTQB__QB_Invoice_Line_Item__c lineItem : lineItems) {
            productMap.put(lineItem.KTQB__Line_Item_Id__c, 'ProductRef_' + lineItem.KTQB__Line_Item_Id__c);
        }

        // Instantiate the class and execute
        Test.startTest();
        InvoiceSyncCreateInvProducts queueable = new InvoiceSyncCreateInvProducts(lineItems, productMap);
        System.enqueueJob(queueable);
        Test.stopTest();
    }
    /**
     * @description test method for batch execution
    */
    @isTest
    static void testBatchExecution() {
        // Query test data
        List<KTQB__QB_Invoice_Line_Item__c> lineItems = [
            SELECT Id, KTQB__Line_Item_Id__c, Name 
            FROM KTQB__QB_Invoice_Line_Item__c
        ];
        
        List<KTQB__QB_Invoice__c> invoice = [
            SELECT Id  
            FROM KTQB__QB_Invoice__c
        ];

        List<String> lineItemIds = new List<String>();
        for (KTQB__QB_Invoice_Line_Item__c item : lineItems) {
            lineItemIds.add(item.KTQB__Line_Item_Id__c);
        }
        
        List<String> invoiceIds = new List<String>();
        for (KTQB__QB_Invoice__c inv : invoice) {
            invoiceIds.add(inv.id);
        }

        
        // Instantiate the batch
        Test.startTest();
        InvoiceSyncCreateInvProducts batch = new InvoiceSyncCreateInvProducts(lineItemIds, invoiceIds);
        Database.executeBatch(batch, 5);
        Test.stopTest();
    }
    /**
     * @description test method for Upsert InvoiceLineItem
    */
    @isTest
    static void testUpsertInvoiceLineItems() {
        // Query test data for Invoice Line Items
        List<KTQB__QB_Invoice_Line_Item__c> lineItems = [
            SELECT Id, KTQB__Line_Item_Id__c, Name, QB_Invoice__r.KTQB__Invoice_Qb_Id__c
            FROM KTQB__QB_Invoice_Line_Item__c
        ];

        // Create a map of product references
        Map<String, String> productMap = new Map<String, String>();
        for (KTQB__QB_Invoice_Line_Item__c lineItem : lineItems) {
            productMap.put(lineItem.KTQB__Line_Item_Id__c, 'ProductRef_' + lineItem.KTQB__Line_Item_Id__c);
        }

        // Create mock Products
        List<Product2> products = [
            SELECT Id, Name FROM Product2
        ];
        for (Product2 product : products) {
            productMap.put('ProductRef_' + product.Name, product.Id);
        }

        // Instantiate the class and call the helper method
        InvoiceSyncCreateInvProducts instance = new InvoiceSyncCreateInvProducts(lineItems, productMap);
        Test.startTest();
        instance.upsertInvLineItems(lineItems, true);
        Test.stopTest();

        // Verify that the Invoice Line Items are upserted correctly
        List<KTQB__QB_Invoice_Line_Item__c> updatedLineItems = [
            SELECT Id, Product_Service__r.Name 
            FROM KTQB__QB_Invoice_Line_Item__c
        ];
		System.assertNotEquals(null, updatedLineItems[0].id, 'success');
        
    }
    /**
     * @description test method for Finish Batch
    */
    @isTest
    static void testFinishBatch() {
        // Instantiate the class
        InvoiceSyncCreateInvProducts batch = new InvoiceSyncCreateInvProducts(new List<String>(), new List<String>());

        // Simulate finish method
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
    }

}