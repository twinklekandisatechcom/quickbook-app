@isTest
public with sharing class InvoicePaymentsHandlerBtchCls_Test {
    
    /**
     * @description This method creates mock data for testing purposes.
     *              It sets up a QuickBook Info record with mock values.
     *              This record is used in test scenarios for validation.
     */
    @TestSetup public static void createData(){
        /*InvoiceSyncControllerDynamic.paymentObjectApiName = 'KTQB__Qb_Invoice_Payment__c';
        InvoiceSyncControllerDynamic.invoiceFieldApiNameOnLine = 'KTQB__QB_Invoice__c';*/
        
        KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
        qbInfo.Name = 'QuickBook Info test';
        qbInfo.KTQB__QB_Company_Id__c = '462081636528926285';
        qbInfo.KTQB__Access_Token__c = 'RSdFCCO5ws/YRsuuK1w8Bw8ifYqI5+OC+EaL/JIkZhqZkTB3ynzbtOO3CjYgcSdRIjANHVFUP0kIWpshrKOcgi9eM9dupoKo85BMkepE18uk8XDhxOrtujrlRKX4ZmVPc/aC4GZD0qbXd58n9UfnduPYhExyhAV1XgJdbKAvCypTxL7x1Bk7ku7h+73GIh1YmjlNRw371lfI9CCLBUELirRcQjSUQ/CuNYxAKHenhaX9H+i4DSbmJy1NyFnPHjiHnCvck59ANLzsSbLClkiTHiPWPudfO15mIc5ZmVJJGdmcCzCNftsMhSMfolaO+huWKkxoixsN0HF0IXdpr5FxMql1nnP5vsqEn36TkL6dxpvPsBimCOVo02bLNL2Simf/Kkr2XyNP+COlM0Trb3kHDeEHFyKmj3NGQVsygtcQ5rx+jvOd0NKU9p72yyKKymrbRFrhbooc4PVaGlx6/1v8TwcEuthQhzzJ63ijOR1P/8L5XvG9SRF7PE1d+8zol2Bk7uqUrM/laMZmyYTNp/GvgsBPGM0HWWW6hN6RIssFn8tbRDa1eb+Q0TzoKnw3E+KdZ36GdqAvIJJ1PqHr2wbOsiVnY64mmZ5AtOmUXC9ltMgMfx815wL28pHTwSrJj7B5nHeU+RZjNcx0CUjYsOIKhQaDZ46tMp9hpubz7YSO1JnL5H7I5UUzdHkAxCmzaSNp9hnXV06sPnP4iKuz7Orfo7iedc6xdV8eW6MzT4epaahSs36T6RRU6UDVRtPlRphsSn0Hrl/nWVgVh5QR6CBmox9//COJRBszNbRXz4q6Tb0jU5y1Eqm4mqAsG42CzeNRPuu+LvYt3Wg38hhHfRKltTfEyviI22eOfB8yyYvx76JHPf+lHfdoHn7ZHAP5ITHnKb4UuRPMQQs91GWQVPwmSh1MK2GMzr0M7rRpdunyI6usWHe9GLhbuzG6fkWfJy/NYPe+ES87ul8wp2oo8t3HKpjMVMF5W9sf0qt1F/Vj+jM/ujxllo0aTTYnrzUaYYBZrlrS/IriTXv5EWFrqEHdsI+Hfx529QeROX9sAV2/cTLOhw5Ba8PFPI4D31ffdQKiylUeQ8/yYYCx1gbzTm21s/V6yRmm1Mo9karF7AICE7hffgSKJj1u9MehBLyGxAoJ/JoZqc2nluCuScpSvR1l7A==';
        qbInfo.KTQB__Refresh_Token_Life_Days__c = 100;
        qbInfo.KTQB__Refresh_Token__c = 'pNFDyajWbTBWbk58Qag0onvtPGZnafOXD/6f2Vyh4bITt6ZzUYYQmIK7n8XdDoVjeokEizPGfIIMAWSgRVLM97gGR58zcNIXgM07h/3OWmk=';
        qbInfo.KTQB__Last_Refresh_Token_Date__c = System.now();
        qbInfo.KTQB__Sandbox_Url__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbInfo.KTQB__Completed_Steps__c = 4;

        insert qbInfo;

        List<KTQB__Invoice_Object_Field_Mapping__c> lstInvoiceFldMapping = new List<KTQB__Invoice_Object_Field_Mapping__c>();
        
        KTQB__Invoice_Object_Field_Mapping__c invFldMap1 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap1.KTQB__Data_Type__c = 'STRING, TEXTAREA';
        invFldMap1.KTQB__Field_API_Name__c = 'KTQB__BillAddr__c';
        invFldMap1.Name = 'Billing Address';
        invFldMap1.KTQB__Field_Value__c = 'Billing Address';
        invFldMap1.KTQB__QuickBook_Field_Api_Name__c = 'BillAddr';
        invFldMap1.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap1);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap2 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap2.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invFldMap2.KTQB__Field_API_Name__c = 'KTQB__Balance__c';
        invFldMap2.Name = 'Balance';
        invFldMap2.KTQB__Field_Value__c = 'Balance';
        invFldMap2.KTQB__QuickBook_Field_Api_Name__c = 'Balance';
        invFldMap2.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap2);


        KTQB__Invoice_Object_Field_Mapping__c invFldMap3 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap3.KTQB__Data_Type__c = 'BOOLEAN';
        invFldMap3.KTQB__Field_API_Name__c = 'KTQB__Percent_Based_Discount__c';
        invFldMap3.Name = 'Percent Based Discount';
        invFldMap3.KTQB__Field_Value__c = 'Percent Based Discount';
        invFldMap3.KTQB__QuickBook_Field_Api_Name__c = 'PercentBasedDiscount';
        invFldMap3.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap3);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap4 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap4.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invFldMap4.KTQB__Field_API_Name__c = 'KTQB__Shipping_Charges__c ';
        invFldMap4.Name = 'Shipping Charges';
        invFldMap4.KTQB__Field_Value__c = 'Shipping Charges';
        invFldMap4.KTQB__QuickBook_Field_Api_Name__c = 'ShippingCharges';
        invFldMap4.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap4);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap5 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap5.KTQB__Data_Type__c = 'STRING, TEXTAREA';
        invFldMap5.KTQB__Field_API_Name__c = 'KTQB__ShipAddr__c'; 
        invFldMap5.Name = 'Shipping Address';
        invFldMap5.KTQB__Field_Value__c = 'Shipping Address';
        invFldMap5.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddr';
        invFldMap5.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap5);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap6 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap6.KTQB__Data_Type__c = 'DOUBLE';
        invFldMap6.KTQB__Field_API_Name__c = 'KTQB__Tax_Percent__c';
        invFldMap6.Name = 'Tax Rate';
        invFldMap6.KTQB__Field_Value__c = 'Tax Rate';
        invFldMap6.KTQB__QuickBook_Field_Api_Name__c = 'TaxPercent';
        invFldMap6.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap6);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap7 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap7.KTQB__Data_Type__c = 'DATE';
        invFldMap7.KTQB__Field_API_Name__c = 'KTQB__Invoice_Date__c'; 
        invFldMap7.Name = 'Invoice Date';
        invFldMap7.KTQB__Field_Value__c = 'Invoice Date';
        invFldMap7.KTQB__QuickBook_Field_Api_Name__c = 'TxnDate';
        invFldMap7.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap7);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap8 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap8.KTQB__Data_Type__c = 'STRING';
        invFldMap8.KTQB__Field_API_Name__c = 'KTQB__BillEmail__c';
        invFldMap8.Name = 'BillEmail';
        invFldMap8.KTQB__Field_Value__c = 'BillEmail';
        invFldMap8.KTQB__QuickBook_Field_Api_Name__c = 'BillEmail';
        invFldMap8.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap8);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap9 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap9.KTQB__Data_Type__c = 'DATE';
        invFldMap9.KTQB__Field_API_Name__c = 'KTQB__Transaction_Date__c';
        invFldMap9.Name = 'Transaction Date';
        invFldMap9.KTQB__Field_Value__c = 'Transaction Date';
        invFldMap9.KTQB__QuickBook_Field_Api_Name__c = ''; //PENDING
        invFldMap9.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap9);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap10 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap10.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invFldMap10.KTQB__Field_API_Name__c = 'KTQB__Total_Amount__c';
        invFldMap10.Name = 'Total Amount';
        invFldMap10.KTQB__Field_Value__c = 'Total Amount';
        invFldMap10.KTQB__QuickBook_Field_Api_Name__c = 'TotalAmt';
        invFldMap10.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap10);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap11 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap11.KTQB__Data_Type__c = 'STRING,PICKLIST   ';
        invFldMap11.Name = 'Invoice State';
        invFldMap11.KTQB__Field_Value__c = 'Invoice State';
        invFldMap11.KTQB__QuickBook_Field_Api_Name__c = 'InvoiceState';
        invFldMap11.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap11);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap12 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap12.KTQB__Data_Type__c = 'REFERENCE';
        invFldMap12.KTQB__Field_API_Name__c = 'KTQB__Contact__c';
        invFldMap12.Name = 'QB Customer';
        invFldMap12.KTQB__Field_Value__c = 'QB Customer';
        invFldMap12.KTQB__QuickBook_Field_Api_Name__c = 'QBCustomerRef';
        invFldMap12.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap12);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap13 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap13.KTQB__Data_Type__c = 'DOUBLE';
        invFldMap13.KTQB__Field_API_Name__c = 'KTQB__Qb_Invoice_Sync_Token__c';
        invFldMap13.Name = 'Qb Invoice Sync Token';
        invFldMap13.KTQB__Field_Value__c = 'Qb Invoice Sync Token';
        invFldMap13.KTQB__QuickBook_Field_Api_Name__c = 'SyncToken';
        invFldMap13.KTQB__Required__c = true;
        lstInvoiceFldMapping.add(invFldMap13);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap14 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap14.KTQB__Data_Type__c = 'STRING';
        invFldMap14.KTQB__Field_API_Name__c = 'KTQB__Invoice_Number__c';
        invFldMap14.Name = 'Invoice Number';
        invFldMap14.KTQB__Field_Value__c = 'Invoice Number';
        invFldMap14.KTQB__QuickBook_Field_Api_Name__c = 'DocNumber';
        invFldMap14.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap14);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap15 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap15.KTQB__Data_Type__c = 'STRING,PICKLIST';
        invFldMap15.KTQB__Field_API_Name__c = 'KTQB__Invoice_Status__c';
        invFldMap15.Name = 'Invoice Status';
        invFldMap15.KTQB__Field_Value__c = 'Invoice Status';
        invFldMap15.KTQB__QuickBook_Field_Api_Name__c = 'InvoiceStatus';
        invFldMap15.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap15);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap16 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap16.KTQB__Data_Type__c = 'CURRENCY, DOUBLE';
        invFldMap16.KTQB__Field_API_Name__c = ''; 
        invFldMap16.Name = 'TotalTax';
        invFldMap16.KTQB__Field_Value__c = 'TotalTax';
        invFldMap16.KTQB__QuickBook_Field_Api_Name__c = 'TotalTax';
        invFldMap16.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap16);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap17 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap17.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invFldMap17.KTQB__Field_API_Name__c = 'KTQB__Discount_Amount__c';
        invFldMap17.Name = 'Discount Amount';
        invFldMap17.KTQB__Field_Value__c = 'Discount Amount';
        invFldMap17.KTQB__QuickBook_Field_Api_Name__c = 'DiscountAmount';
        invFldMap17.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap17);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap18 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap18.KTQB__Data_Type__c = 'STRING';
        invFldMap18.KTQB__Field_API_Name__c = 'KTQB__Sales_Term__c';
        invFldMap18.Name = 'Terms';
        invFldMap18.KTQB__Field_Value__c = 'Terms';
        invFldMap18.KTQB__QuickBook_Field_Api_Name__c = ''; //PENDING
        invFldMap18.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap18);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap19 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap19.KTQB__Data_Type__c = 'DATE';
        invFldMap19.KTQB__Field_API_Name__c = 'KTQB__Due_Date__c';
        invFldMap19.Name = 'Due Date';
        invFldMap19.KTQB__Field_Value__c = 'Due Date';
        invFldMap19.KTQB__QuickBook_Field_Api_Name__c = 'DueDate';
        invFldMap19.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap19);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap20 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap20.KTQB__Data_Type__c = 'STRING';
        invFldMap20.KTQB__Field_API_Name__c = 'KTQB__Invoice_Qb_Id__c';
        invFldMap20.Name = 'Invoice Qb Id';
        invFldMap20.KTQB__Field_Value__c = 'Invoice Qb Id';
        invFldMap20.KTQB__QuickBook_Field_Api_Name__c = 'Id';
        invFldMap20.KTQB__Required__c = true;
        lstInvoiceFldMapping.add(invFldMap20);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap21 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap21.KTQB__Data_Type__c = 'STRING';
        invFldMap21.KTQB__Field_API_Name__c = 'Name';
        invFldMap21.Name = 'Name';
        invFldMap21.KTQB__Field_Value__c = 'Name';
        invFldMap21.KTQB__QuickBook_Field_Api_Name__c = 'Name';
        invFldMap21.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap21);

        KTQB__Invoice_Object_Field_Mapping__c invFldMap22 = new KTQB__Invoice_Object_Field_Mapping__c();
        invFldMap22.KTQB__Data_Type__c = 'INTEGER,DOUBLE';
        invFldMap22.KTQB__Field_API_Name__c = 'KTQB__Discount_Percent_Discount_Value__c';
        invFldMap22.Name = 'Discount Percent / Discount Value';
        invFldMap22.KTQB__Field_Value__c = 'Discount Percent / Discount Value';
        invFldMap22.KTQB__QuickBook_Field_Api_Name__c = 'DiscountPercentOrValue';
        invFldMap22.KTQB__Required__c = false;
        lstInvoiceFldMapping.add(invFldMap22);

        insert lstInvoiceFldMapping;  //insert List of Invoice Field Mappings

        List<KTQB__LineItem_Object_Field_Mapping__c> lstInvoiceLineFldMapping = new List<KTQB__LineItem_Object_Field_Mapping__c>();

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap1 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap1.KTQB__Data_Type__c = 'STRING, TEXTAREA';
        invLineFldMap1.KTQB__Field_API_Name__c = 'KTQB__Description__c';
        invLineFldMap1.Name = 'Description';
        invLineFldMap1.KTQB__Field_Value__c = 'Description';
        invLineFldMap1.KTQB__QuickBook_Field_Api_Name__c = 'Description';
        invLineFldMap1.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap1);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap2 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap2.KTQB__Data_Type__c = 'STRING';
        invLineFldMap2.KTQB__Field_API_Name__c = 'Name';
        invLineFldMap2.Name = 'Name';
        invLineFldMap2.KTQB__Field_Value__c = 'Name';
        invLineFldMap2.KTQB__QuickBook_Field_Api_Name__c = 'Name';
        invLineFldMap2.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap2);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap3 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap3.KTQB__Data_Type__c = 'STRING';
        invLineFldMap3.KTQB__Field_API_Name__c = 'KTQB__Line_Item_Name__c';
        invLineFldMap3.Name = 'Product/Service Ref Name';
        invLineFldMap3.KTQB__Field_Value__c = 'Product/Service Ref Name';
        invLineFldMap3.KTQB__QuickBook_Field_Api_Name__c = 'ItemRefName';
        invLineFldMap3.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap3);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap4 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap4.KTQB__Data_Type__c = 'CURRENCY, DOUBLE';
        invLineFldMap4.KTQB__Field_API_Name__c = 'KTQB__Unit_Price__c';
        invLineFldMap4.Name = 'Unit Price';
        invLineFldMap4.KTQB__Field_Value__c = 'Unit Price';
        invLineFldMap4.KTQB__QuickBook_Field_Api_Name__c = 'UnitPrice';
        invLineFldMap4.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap4);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap5 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap5.KTQB__Data_Type__c = 'STRING';
        invLineFldMap5.KTQB__Field_API_Name__c = 'KTQB__Line_Item_Id__c';
        invLineFldMap5.Name = 'Line Item Id';
        invLineFldMap5.KTQB__Field_Value__c = 'Line Item Id';
        invLineFldMap5.KTQB__QuickBook_Field_Api_Name__c = 'LineItemId';
        invLineFldMap5.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap5);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap6 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap6.KTQB__Data_Type__c = 'INTEGER,DOUBLE';
        invLineFldMap6.KTQB__Field_API_Name__c = 'KTQB__Quantity__c';
        invLineFldMap6.Name = 'Quantity';
        invLineFldMap6.KTQB__Field_Value__c = 'Quantity';
        invLineFldMap6.KTQB__QuickBook_Field_Api_Name__c = 'Qty';
        invLineFldMap6.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap6);

        KTQB__LineItem_Object_Field_Mapping__c invLineFldMap7 = new KTQB__LineItem_Object_Field_Mapping__c();
        invLineFldMap7.KTQB__Data_Type__c = 'STRING';
        invLineFldMap7.KTQB__Field_API_Name__c = 'KTQB__Taxable__c';
        invLineFldMap7.Name = 'Taxable';
        invLineFldMap7.KTQB__Field_Value__c = 'Taxable';
        invLineFldMap7.KTQB__QuickBook_Field_Api_Name__c = 'TaxCodeRef';
        invLineFldMap7.KTQB__Required__c = false;
        lstInvoiceLineFldMapping.add(invLineFldMap7);

        insert lstInvoiceLineFldMapping; //insert List of Invoice Line Field Mappings

        List<KTQB__Payment_Object_Field_Mapping__c> lstPaymentFldMapping = new List<KTQB__Payment_Object_Field_Mapping__c>();

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap1 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap1.KTQB__Data_Type__c = 'STRING';
        invPayFldMap1.KTQB__Field_API_Name__c = 'KTQB__Payment_Qb_Id__c';
        invPayFldMap1.Name = 'Invoice Payment Qb Id';
        invPayFldMap1.KTQB__Field_Value__c = 'Invoice Payment Qb Id';
        invPayFldMap1.KTQB__QuickBook_Field_Api_Name__c = 'Id';
        invPayFldMap1.KTQB__Required__c = true;
        lstPaymentFldMapping.add(invPayFldMap1);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap2 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap2.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invPayFldMap2.KTQB__Field_API_Name__c = 'KTQB__Invoice_Paid_Amount__c';
        invPayFldMap2.Name = 'Invoice Paid Amount';
        invPayFldMap2.KTQB__Field_Value__c = 'Invoice Paid Amount';
        invPayFldMap2.KTQB__QuickBook_Field_Api_Name__c = 'InvoiceAmt';
        invPayFldMap2.KTQB__Required__c = false;
        lstPaymentFldMapping.add(invPayFldMap2);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap3 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap3.KTQB__Data_Type__c = 'STRING';
        invPayFldMap3.KTQB__Field_API_Name__c = 'Name';
        invPayFldMap3.Name = 'Name';
        invPayFldMap3.KTQB__Field_Value__c = 'Name';
        invPayFldMap3.KTQB__QuickBook_Field_Api_Name__c = 'Name';
        invPayFldMap3.KTQB__Required__c = false;
        lstPaymentFldMapping.add(invPayFldMap3);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap4 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap4.KTQB__Data_Type__c = 'DOUBLE';
        invPayFldMap4.KTQB__Field_API_Name__c = 'KTQB__Qb_SyncToken__c';
        invPayFldMap4.Name = 'Qb Sync Token';
        invPayFldMap4.KTQB__Field_Value__c = 'Qb Sync Token';
        invPayFldMap4.KTQB__QuickBook_Field_Api_Name__c = 'SyncToken';
        invPayFldMap4.KTQB__Required__c = true;
        lstPaymentFldMapping.add(invPayFldMap4);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap5 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap5.KTQB__Data_Type__c = 'DATE';
        invPayFldMap5.KTQB__Field_API_Name__c = 'KTQB__Transaction_Date__c';
        invPayFldMap5.Name = 'Transaction Date';
        invPayFldMap5.KTQB__Field_Value__c = 'Transaction Date';
        invPayFldMap5.KTQB__QuickBook_Field_Api_Name__c = 'TxnDate';
        invPayFldMap5.KTQB__Required__c = false;
        lstPaymentFldMapping.add(invPayFldMap5);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap6 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap6.KTQB__Data_Type__c = 'STRING';
        invPayFldMap6.KTQB__Field_API_Name__c = 'KTQB__Qb_Payment_Unique_Id__c';
        invPayFldMap6.Name = 'Invoice Payment Unique id';
        invPayFldMap6.KTQB__Field_Value__c = 'Invoice Payment Unique id';
        invPayFldMap6.KTQB__QuickBook_Field_Api_Name__c = 'payExtId';
        invPayFldMap6.KTQB__Required__c = true;
        lstPaymentFldMapping.add(invPayFldMap6);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap7 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap7.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invPayFldMap7.KTQB__Field_API_Name__c = 'KTQB__Amount__c';
        invPayFldMap7.Name = 'Transaction Amount';
        invPayFldMap7.KTQB__Field_Value__c = 'Transaction Amount';
        invPayFldMap7.KTQB__QuickBook_Field_Api_Name__c = 'TotalAmt';
        invPayFldMap7.KTQB__Required__c = false;
        lstPaymentFldMapping.add(invPayFldMap7);

        KTQB__Payment_Object_Field_Mapping__c invPayFldMap8 = new KTQB__Payment_Object_Field_Mapping__c();
        invPayFldMap8.KTQB__Data_Type__c = 'CURRENCY,DOUBLE';
        invPayFldMap8.KTQB__Field_API_Name__c = 'KTQB__Unapplied_Amount__c';
        invPayFldMap8.Name = 'Unapplied Amount';
        invPayFldMap8.KTQB__Field_Value__c = 'Unapplied Amount';
        invPayFldMap8.KTQB__QuickBook_Field_Api_Name__c = 'UnappliedAmt';
        invPayFldMap8.KTQB__Required__c = false;
        lstPaymentFldMapping.add(invPayFldMap8);

        insert lstPaymentFldMapping; //insert List of Payment Field Mappings

        List<KTQB__Customer_Object_Field_Mapping__c> lstCustomerFldMapping = new List<KTQB__Customer_Object_Field_Mapping__c>();
    
        KTQB__Customer_Object_Field_Mapping__c custFldMap1 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap1.KTQB__Data_Type__c = 'STRING';
        custFldMap1.KTQB__Field_API_Name__c = 'OtherPostalCode';
        custFldMap1.Name = 'Billing PostalCode';
        custFldMap1.KTQB__Field_Value__c = 'Billing Zip Code';
        custFldMap1.KTQB__QuickBook_Field_Api_Name__c = 'BillAddrPostalCode';
        custFldMap1.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap1);

        KTQB__Customer_Object_Field_Mapping__c custFldMap2 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap2.KTQB__Data_Type__c = 'STRING';
        custFldMap2.KTQB__Field_API_Name__c = 'OtherCity';
        custFldMap2.Name = 'Billing City';
        custFldMap2.KTQB__Field_Value__c = 'Billing City';
        custFldMap2.KTQB__QuickBook_Field_Api_Name__c = 'BillAddrCity';
        custFldMap2.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap2);


        KTQB__Customer_Object_Field_Mapping__c custFldMap3 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap3.KTQB__Data_Type__c = 'STRING';
        custFldMap3.KTQB__Field_API_Name__c = ''; //PENDING
        custFldMap3.Name = 'GivenName';
        custFldMap3.KTQB__Field_Value__c = 'GivenName';
        custFldMap3.KTQB__QuickBook_Field_Api_Name__c = 'GivenName';
        custFldMap3.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap3);

        KTQB__Customer_Object_Field_Mapping__c custFldMap4 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap4.KTQB__Data_Type__c = 'STRING';
        custFldMap4.KTQB__Field_API_Name__c = 'LastName';
        custFldMap4.Name = 'FamilyName';
        custFldMap4.KTQB__Field_Value__c = 'FamilyName';
        custFldMap4.KTQB__QuickBook_Field_Api_Name__c = 'FamilyName';
        custFldMap4.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap4);

        KTQB__Customer_Object_Field_Mapping__c custFldMap5 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap5.KTQB__Data_Type__c = 'STRING';
        custFldMap5.KTQB__Field_API_Name__c = 'MailingCity';
        custFldMap5.Name = 'Shipping City';
        custFldMap5.KTQB__Field_Value__c = 'Shipping City';
        custFldMap5.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddrCity';
        custFldMap5.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap5);

        KTQB__Customer_Object_Field_Mapping__c custFldMap6 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap6.KTQB__Data_Type__c = 'STRING,PHONE';
        custFldMap6.KTQB__Field_API_Name__c = 'MobilePhone';
        custFldMap6.Name = 'Mobile';
        custFldMap6.KTQB__Field_Value__c = 'Mobile Number';
        custFldMap6.KTQB__QuickBook_Field_Api_Name__c = 'Mobile';
        custFldMap6.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap6);

        KTQB__Customer_Object_Field_Mapping__c custFldMap7 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap7.KTQB__Data_Type__c = 'STRING';
        custFldMap7.KTQB__Field_API_Name__c = 'KTQB__Customer_QB_Id__c'; 
        custFldMap7.Name = 'Customer QB Id';
        custFldMap7.KTQB__Field_Value__c = 'Customer QB Id';
        custFldMap7.KTQB__QuickBook_Field_Api_Name__c = 'Id';
        custFldMap7.KTQB__Required__c = true;
        lstCustomerFldMapping.add(custFldMap7);

        KTQB__Customer_Object_Field_Mapping__c custFldMap8 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap8.KTQB__Data_Type__c = 'STRING,EMAIL';
        custFldMap8.KTQB__Field_API_Name__c = 'Email';
        custFldMap8.Name = 'Email';
        custFldMap8.KTQB__Field_Value__c = 'Email';
        custFldMap8.KTQB__QuickBook_Field_Api_Name__c = 'PrimaryEmailAddr';
        custFldMap8.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap8);

        KTQB__Customer_Object_Field_Mapping__c custFldMap9 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap9.KTQB__Data_Type__c = 'DOUBLE';
        custFldMap9.KTQB__Field_API_Name__c = 'KTQB__QB_SyncToken__c';
        custFldMap9.Name = 'Qb Customer Sync Token';
        custFldMap9.KTQB__Field_Value__c = 'Qb Customer Sync Token';
        custFldMap9.KTQB__QuickBook_Field_Api_Name__c = 'SyncToken';
        custFldMap9.KTQB__Required__c = true;
        lstCustomerFldMapping.add(custFldMap9);

        KTQB__Customer_Object_Field_Mapping__c custFldMap10 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap10.KTQB__Data_Type__c = 'STRING';
        custFldMap10.KTQB__Field_API_Name__c = ''; //PENDING
        custFldMap10.Name = 'Shipping PostalCode';
        custFldMap10.KTQB__Field_Value__c = 'Shipping Zip Code';
        custFldMap10.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddrPostalCode';
        custFldMap10.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap10);

        KTQB__Customer_Object_Field_Mapping__c custFldMap11 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap11.KTQB__Data_Type__c = 'STRING, TEXTAREA';
        custFldMap11.KTQB__Field_API_Name__c = 'OtherStreet';
        custFldMap11.Name = 'Billing Line';
        custFldMap11.KTQB__Field_Value__c = 'Billing Street Address';
        custFldMap11.KTQB__QuickBook_Field_Api_Name__c = 'BillAddrLine';
        custFldMap11.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap11);

        KTQB__Customer_Object_Field_Mapping__c custFldMap12 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap12.KTQB__Data_Type__c = 'STRING,PHONE';
        custFldMap12.KTQB__Field_API_Name__c = 'OtherPhone';
        custFldMap12.Name = 'Phone';
        custFldMap12.KTQB__Field_Value__c = 'Phone Number';
        custFldMap12.KTQB__QuickBook_Field_Api_Name__c = 'PrimaryPhone';
        custFldMap12.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap12);

        KTQB__Customer_Object_Field_Mapping__c custFldMap13 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap13.KTQB__Data_Type__c = 'STRING, TEXTAREA';
        custFldMap13.KTQB__Field_API_Name__c = 'MailingStreet';
        custFldMap13.Name = 'Shipping Line';
        custFldMap13.KTQB__Field_Value__c = 'Shipping Street Address';
        custFldMap13.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddrLine';
        custFldMap13.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap13);

        KTQB__Customer_Object_Field_Mapping__c custFldMap14 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap14.KTQB__Data_Type__c = 'STRING';
        custFldMap14.KTQB__Field_API_Name__c = 'OtherState';
        custFldMap14.Name = 'Billing Country Sub DivisionCode';
        custFldMap14.KTQB__Field_Value__c = 'Billing State';
        custFldMap14.KTQB__QuickBook_Field_Api_Name__c = 'BillAddrCountrySubDivisionCode';
        custFldMap14.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap14);

        KTQB__Customer_Object_Field_Mapping__c custFldMap15 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap15.KTQB__Data_Type__c = 'STRING';
        custFldMap15.KTQB__Field_API_Name__c = 'KTQB__Middle_Name__c';
        custFldMap15.Name = 'MiddleName';
        custFldMap15.KTQB__Field_Value__c = 'MiddleName';
        custFldMap15.KTQB__QuickBook_Field_Api_Name__c = 'MiddleName';
        custFldMap15.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap15);

        KTQB__Customer_Object_Field_Mapping__c custFldMap16 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap16.KTQB__Data_Type__c = 'STRING';
        custFldMap16.KTQB__Field_API_Name__c = 'OtherCountry'; 
        custFldMap16.Name = 'Billing Country';
        custFldMap16.KTQB__Field_Value__c = 'Billing Country';
        custFldMap16.KTQB__QuickBook_Field_Api_Name__c = 'BillAddrCountry';
        custFldMap16.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap16);

        KTQB__Customer_Object_Field_Mapping__c custFldMap17 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap17.KTQB__Data_Type__c = 'STRING';
        custFldMap17.KTQB__Field_API_Name__c = 'MailingState';
        custFldMap17.Name = 'Shipping Country Sub DivisionCode';
        custFldMap17.KTQB__Field_Value__c = 'Shipping State';
        custFldMap17.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddrCountrySubDivisionCode';
        custFldMap17.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap17);

        KTQB__Customer_Object_Field_Mapping__c custFldMap18 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap18.KTQB__Data_Type__c = 'STRING';
        custFldMap18.KTQB__Field_API_Name__c = 'KTQB__Display_Name__c'; 
        custFldMap18.Name = 'Display Name';
        custFldMap18.KTQB__Field_Value__c = 'Customer display name';
        custFldMap18.KTQB__QuickBook_Field_Api_Name__c = 'DisplayName'; 
        custFldMap18.KTQB__Required__c = true;
        lstCustomerFldMapping.add(custFldMap18);

        KTQB__Customer_Object_Field_Mapping__c custFldMap19 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap19.KTQB__Data_Type__c = 'STRING,PHONE';
        custFldMap19.KTQB__Field_API_Name__c = 'Fax';
        custFldMap19.Name = 'Fax';
        custFldMap19.KTQB__Field_Value__c = 'Fax';
        custFldMap19.KTQB__QuickBook_Field_Api_Name__c = 'Fax';
        custFldMap19.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap19);

        KTQB__Customer_Object_Field_Mapping__c custFldMap20 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap20.KTQB__Data_Type__c = 'STRING';
        custFldMap20.KTQB__Field_API_Name__c = 'KTQB__QB_Company_Name__c';
        custFldMap20.Name = 'Company Name';
        custFldMap20.KTQB__Field_Value__c = 'Company Name';
        custFldMap20.KTQB__QuickBook_Field_Api_Name__c = 'CompanyName';
        custFldMap20.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap20);

        KTQB__Customer_Object_Field_Mapping__c custFldMap21 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap21.KTQB__Data_Type__c = 'URL';
        custFldMap21.KTQB__Field_API_Name__c = 'KTQB__Website__c';
        custFldMap21.Name = 'Website';
        custFldMap21.KTQB__Field_Value__c = 'Website';
        custFldMap21.KTQB__QuickBook_Field_Api_Name__c = 'WebAddrURI';
        custFldMap21.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap21);

        KTQB__Customer_Object_Field_Mapping__c custFldMap22 = new KTQB__Customer_Object_Field_Mapping__c();
        custFldMap22.KTQB__Data_Type__c = 'STRING';
        custFldMap22.KTQB__Field_API_Name__c = 'MailingCountry'; 
        custFldMap22.Name = 'Shipping Country';
        custFldMap22.KTQB__Field_Value__c = 'Shipping Country';
        custFldMap22.KTQB__QuickBook_Field_Api_Name__c = 'ShipAddrCountry';
        custFldMap22.KTQB__Required__c = false;
        lstCustomerFldMapping.add(custFldMap22);

        insert lstCustomerFldMapping;  //insert List of Customer Field Mappings

        KTQB__InvoiceConfigurationOptions__c invoiceConfigCs = new KTQB__InvoiceConfigurationOptions__c();
        invoiceConfigCs.SetupOwnerId=UserInfo.getOrganizationId();
        invoiceConfigCs.KTQB__Invoice_Object_Name__c ='KTQB__QB_Invoice__c';
        invoiceConfigCs.KTQB__LineItem_Object_Name__c ='KTQB__QB_Invoice_Line_Item__c';
        invoiceConfigCs.KTQB__Invoice_Customer_ChildObject_Api_Name__c ='Contact';
        invoiceConfigCs.KTQB__Payment_Object_Name__c ='KTQB__Qb_Invoice_Payment__c';
        invoiceConfigCs.KTQB__LineItem_ChildObject_Name__c  ='KTQB__QB_Invoice__c';
        invoiceConfigCs.KTQB__Create_Update_Qb_Payment_In_Sf__c  =true;

        insert invoiceConfigCs;
        
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

        KTQB__Qb_Invoice_Payment__c qbInvPay = new KTQB__Qb_Invoice_Payment__c();
        qbInvPay.KTQB__Payment_Qb_Id__c = '680';
        qbInvPay.KTQB__Qb_SyncToken__c = 2;
        qbInvPay.KTQB__Qb_Payment_Unique_Id__c = '680-617';
        qbInvPay.KTQB__Amount__c = 2709;
        qbInvPay.KTQB__Invoice_Paid_Amount__c = 2709;
        qbInvPay.KTQB__Unapplied_Amount__c   = 0;
        qbInvPay.KTQB__QB_Invoice__c = qbInv01.Id;

        insert qbInvPay;
        
        KTQB__Qb_Invoice_Payment__c qbInvPay2 = new KTQB__Qb_Invoice_Payment__c();
        qbInvPay2.KTQB__Payment_Qb_Id__c = '500';
        qbInvPay2.KTQB__Qb_SyncToken__c = 2;
        qbInvPay2.KTQB__Qb_Payment_Unique_Id__c = '580-517';
        qbInvPay2.KTQB__Amount__c = 2709;
        qbInvPay2.KTQB__Invoice_Paid_Amount__c = 2709;
        qbInvPay2.KTQB__Unapplied_Amount__c   = 0;
        qbInvPay2.KTQB__QB_Invoice__c = qbInv02.Id;

        insert qbInvPay2;   
    }
    
    @isTest
    static void testBatchClass(){
        List<KTQB__QB_Invoice__c> invoiceList = [SELECT Id FROM KTQB__QB_Invoice__c];
        List<KTQB__Qb_Invoice_Payment__c> paymentList = [SELECT Id, KTQB__QB_Invoice__c, KTQB__Qb_SyncToken__c FROM KTQB__Qb_Invoice_Payment__c];
        Map<String, List<String>> mapPayIdInvoiceIds = new Map<String, List<String>>();
        Map<String, Integer> mapPayIdSyncToken = new Map<String, Integer>();
        if(invoiceList.size() > 0 && paymentList.size() > 0) {
            for (Integer i = 0; i < paymentList.size(); i++) {
                mapPayIdInvoiceIds.put(paymentList[i].Id, new List<String>{(String) invoiceList[i].get('Id')});
                mapPayIdSyncToken.put(paymentList[i].Id, Integer.valueOf(paymentList[i].KTQB__Qb_SyncToken__c));
            }
        }
		InvoicePaymentsHandlerBtchCls iphbc = new InvoicePaymentsHandlerBtchCls(mapPayIdInvoiceIds, mapPayIdSyncToken);
        
        Test.startTest();
        	Database.executeBatch(iphbc,1);
        Test.stopTest();

        System.assertEquals(2, mapPayIdInvoiceIds.size(), 'Map of Payment IDs to Invoice IDs should contain 2 entries.');
        System.assertEquals(2, mapPayIdSyncToken.size(), 'Map of Payment IDs to Sync Tokens should contain 2 entries.');
    }
    
}