@isTest
public class QBProductController_Test{
    @testSetup
    static void setupData(){
        Product2 proData = new Product2(Name ='Test Install New - 02', ProductCode = 'testCode1', Description = 'test product 123', 
                                        IsActive=true, KTQB__Item_QB_Id__c = '    86');
        insert proData;
        
        // Create Quickbook Info rec
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QB-0001';
        qbInfo.KTQB__Client_ID__c  = 'ABdsv32oVJfud61R0SRi8541lXT0DSOQ5uw0dkjTakPH2sFHBt';
        qbInfo.KTQB__Client_Secret__c = '3iUhQPu3DWFxyM5mzxCbeaNRYzlBFAjVkBq1ZOFe';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Redirect_URL__c = 'https://qbktdev-dev-ed.develop.lightning.force.com/apex/QuickBookOAuthRedirectPage';
        qbInfo.KTQB__QB_Company_Id__c = '4620816365289262850';
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        insert qbInfo;
        
        KTQB__InvoiceConfigurationOptions__c iconfig = new KTQB__InvoiceConfigurationOptions__c();
        iconfig.KTQB__Create_Update_Qb_Payment_In_Sf__c = false;
        iconfig.KTQB__Income_Account__c = '79';
        iconfig.KTQB__LineItem_ChildObject_Name__c = 'QB_Invoice__c';
        iconfig.KTQB__Invoice_Customer_ChildObject_Api_Name__c = 'Contact';
        iconfig.KTQB__Invoice_Date__c = '2;Before;CloseDate';
        iconfig.KTQB__Invoice_Due_Date__c = '1;Before;CloseDate';
        iconfig.KTQB__Invoice_Object_Name__c = 'QB_Invoice__c';
        iconfig.KTQB__Invoice_Save__c = true;
        iconfig.KTQB__Invoice_Save_and_Send__c = true;
        iconfig.KTQB__LineItem_Object_Name__c = 'QB_Invoice_Line_Item__c';
        iconfig.KTQB__Payment_Object_Name__c = '';
        iconfig.KTQB__Tax__c = '2';
        iconfig.KTQB__Terms__c = '3';
        insert iconfig;
    }
  
    @isTest
    static void insertProductOnQbTest(){
        Test.setMock(HttpCalloutMock.class, new QBProductControllerItemHttpCalloutMock());
        String opwWrapper = '{"id":"f.h9qhiy5zrk","productId":"","productName":"","expenseAccount":"55","code":"","productDesc":"test","quantity":"100","rate":"100","amount":"10000.00","taxable":true}';
        Test.startTest();
        String str = QBProductController.insertProductOnQb(opwWrapper);
        System.assertNotEquals(null, str, 'Success');
        Test.stopTest();
    }
}