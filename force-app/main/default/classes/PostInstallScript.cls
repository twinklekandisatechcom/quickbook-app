/**
     * @description Class is used to update the configurations once after uninstalling package
     * @Author : Kandisa Technologies
     * @CreatedDate : 08 April 2024
     * Modified on 10-10-2024 by Twinkle
*/
public with sharing class PostInstallScript implements InstallHandler {
     /**
     * @description Method is used to update the configurations 
     * @param  context
    */
        public void onInstall(InstallContext context) {
            if(context.previousVersion() == null){
                // Create QB Customer object field mapping Configuration
                //String jsonCustomerString = '[{"Name":"BillingPostalCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherPostalCode","KTQB__Field_Value__c":"BillingZipCode","KTQB__QuickBook_Field_Api_Name__c":"BillAddrPostalCode","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":14},{"Name":"BillingCity","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherCity","KTQB__Field_Value__c":"BillingCity","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCity","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":13},{"Name":"GivenName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"FirstName","KTQB__Field_Value__c":"GivenName","KTQB__QuickBook_Field_Api_Name__c":"GivenName","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":1},{"Name":"FamilyName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"LastName","KTQB__Field_Value__c":"FamilyName","KTQB__QuickBook_Field_Api_Name__c":"FamilyName","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":3},{"Name":"ShippingCity","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingCity","KTQB__Field_Value__c":"ShippingCity","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCity","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":18},{"Name":"Mobile","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"MobilePhone","KTQB__Field_Value__c":"MobileNumber","KTQB__QuickBook_Field_Api_Name__c":"Mobile","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":7},{"Name":"QBCustomerId","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Customer_QB_Id__c","KTQB__Field_Value__c":"QBCustomerId","KTQB__QuickBook_Field_Api_Name__c":"Id","KTQB__Required__c":"true","KTQB__Read_Only__c":"true","KTQB__Sequence_Number__c":10},{"Name":"Email","KTQB__Data_Type__c":"STRING,EMAIL","KTQB__Field_API_Name__c":"Email","KTQB__Field_Value__c":"Email","KTQB__QuickBook_Field_Api_Name__c":"PrimaryEmailAddr","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":5},{"Name":"QbCustomerSyncToken","KTQB__Data_Type__c":"DOUBLE","KTQB__Field_API_Name__c":"KTQB__QB_SyncToken__c","KTQB__Field_Value__c":"QbCustomerSyncToken","KTQB__QuickBook_Field_Api_Name__c":"SyncToken","KTQB__Required__c":"true","KTQB__Read_Only__c":"true","KTQB__Sequence_Number__c":11},{"Name":"ShippingPostalCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingPostalCode","KTQB__Field_Value__c":"ShippingZipCode","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrPostalCode","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":19},{"Name":"BillingLine","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"OtherStreet","KTQB__Field_Value__c":"BillingStreetAddress","KTQB__QuickBook_Field_Api_Name__c":"BillAddrLine","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":12},{"Name":"Phone","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"HomePhone","KTQB__Field_Value__c":"PhoneNumber","KTQB__QuickBook_Field_Api_Name__c":"PrimaryPhone","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":6},{"Name":"ShippingLine","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"MailingStreet","KTQB__Field_Value__c":"ShippingStreetAddress","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrLine","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":17},{"Name":"BillingCountrySubDivisionCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherState","KTQB__Field_Value__c":"BillingState","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCountrySubDivisionCode","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":16},{"Name":"MiddleName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Middle_Name__c","KTQB__Field_Value__c":"MiddleName","KTQB__QuickBook_Field_Api_Name__c":"MiddleName","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":2},{"Name":"BillingCountry","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherCountry","KTQB__Field_Value__c":"BillingCountry","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCountry","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":15},{"Name":"ShippingCountrySubDivisionCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingState","KTQB__Field_Value__c":"ShippingState","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCountrySubDivisionCode","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":21},{"Name":"DisplayName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Display_Name__c","KTQB__Field_Value__c":"Customerdisplayname","KTQB__QuickBook_Field_Api_Name__c":"DisplayName","KTQB__Required__c":"true","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":4},{"Name":"Fax","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"Fax","KTQB__Field_Value__c":"Fax","KTQB__QuickBook_Field_Api_Name__c":"Fax","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":8},{"Name":"CompanyName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__QB_Company_Name__c","KTQB__Field_Value__c":"CompanyName","KTQB__QuickBook_Field_Api_Name__c":"CompanyName","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":9},{"Name":"Website","KTQB__Data_Type__c":"URL","KTQB__Field_API_Name__c":"KTQB__Website__c","KTQB__Field_Value__c":"Website","KTQB__QuickBook_Field_Api_Name__c":"WebAddrURI","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":22},{"Name":"ShippingCountry","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingCountry","KTQB__Field_Value__c":"ShippingCountry","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCountry","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":20},{"Name":"CustomerCurrencyReference","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"KTQB__Customer_Currecny__c","KTQB__Field_Value__c":"CustomerCurrencyReference","KTQB__Required__c":"false","KTQB__Read_Only__c":"true","KTQB__Sequence_Number__c":24},{"Name":"IsTaxable","KTQB__Data_Type__c":"BOOLEAN","KTQB__Field_API_Name__c":"KTQB__Is_Taxable__c","KTQB__Field_Value__c":"IsTaxable","KTQB__QuickBook_Field_Api_Name__c":"IsTaxable","KTQB__Required__c":"false","KTQB__Read_Only__c":"false","KTQB__Sequence_Number__c":23 }';
                String jsonCustomerString = '[{"Name":"BillingPostalCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherPostalCode","KTQB__Field_Value__c":"BillingZipCode","KTQB__QuickBook_Field_Api_Name__c":"BillAddrPostalCode","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":14},{"Name":"BillingCity","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherCity","KTQB__Field_Value__c":"BillingCity","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCity","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":13},{"Name":"GivenName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"FirstName","KTQB__Field_Value__c":"GivenName","KTQB__QuickBook_Field_Api_Name__c":"GivenName","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":1},{"Name":"FamilyName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"LastName","KTQB__Field_Value__c":"FamilyName","KTQB__QuickBook_Field_Api_Name__c":"FamilyName","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":3},{"Name":"ShippingCity","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingCity","KTQB__Field_Value__c":"ShippingCity","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCity","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":18},{"Name":"Mobile","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"MobilePhone","KTQB__Field_Value__c":"MobileNumber","KTQB__QuickBook_Field_Api_Name__c":"Mobile","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":7},{"Name":"QBCustomerId","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Customer_QB_Id__c","KTQB__Field_Value__c":"QBCustomerId","KTQB__QuickBook_Field_Api_Name__c":"Id","KTQB__Required__c":true,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":10},{"Name":"Email","KTQB__Data_Type__c":"STRING,EMAIL","KTQB__Field_API_Name__c":"Email","KTQB__Field_Value__c":"Email","KTQB__QuickBook_Field_Api_Name__c":"PrimaryEmailAddr","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":5},{"Name":"QbCustomerSyncToken","KTQB__Data_Type__c":"DOUBLE","KTQB__Field_API_Name__c":"KTQB__QB_SyncToken__c","KTQB__Field_Value__c":"QbCustomerSyncToken","KTQB__QuickBook_Field_Api_Name__c":"SyncToken","KTQB__Required__c":true,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":11},{"Name":"ShippingPostalCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingPostalCode","KTQB__Field_Value__c":"ShippingZipCode","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrPostalCode","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":19},{"Name":"BillingLine","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"OtherStreet","KTQB__Field_Value__c":"BillingStreetAddress","KTQB__QuickBook_Field_Api_Name__c":"BillAddrLine","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":12},{"Name":"Phone","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"HomePhone","KTQB__Field_Value__c":"PhoneNumber","KTQB__QuickBook_Field_Api_Name__c":"PrimaryPhone","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":6},{"Name":"ShippingLine","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"MailingStreet","KTQB__Field_Value__c":"ShippingStreetAddress","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrLine","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":17},{"Name":"BillingCountrySubDivisionCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherState","KTQB__Field_Value__c":"BillingState","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCountrySubDivisionCode","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":16},{"Name":"MiddleName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Middle_Name__c","KTQB__Field_Value__c":"MiddleName","KTQB__QuickBook_Field_Api_Name__c":"MiddleName","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":2},{"Name":"BillingCountry","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"OtherCountry","KTQB__Field_Value__c":"BillingCountry","KTQB__QuickBook_Field_Api_Name__c":"BillAddrCountry","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":15},{"Name":"ShippingCountrySubDivisionCode","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingState","KTQB__Field_Value__c":"ShippingState","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCountrySubDivisionCode","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":21},{"Name":"DisplayName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Display_Name__c","KTQB__Field_Value__c":"Customerdisplayname","KTQB__QuickBook_Field_Api_Name__c":"DisplayName","KTQB__Required__c":true,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":4},{"Name":"Fax","KTQB__Data_Type__c":"STRING,PHONE","KTQB__Field_API_Name__c":"Fax","KTQB__Field_Value__c":"Fax","KTQB__QuickBook_Field_Api_Name__c":"Fax","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":8},{"Name":"CompanyName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__QB_Company_Name__c","KTQB__Field_Value__c":"CompanyName","KTQB__QuickBook_Field_Api_Name__c":"CompanyName","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":9},{"Name":"Website","KTQB__Data_Type__c":"URL","KTQB__Field_API_Name__c":"KTQB__Website__c","KTQB__Field_Value__c":"Website","KTQB__QuickBook_Field_Api_Name__c":"WebAddrURI","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":22},{"Name":"ShippingCountry","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"MailingCountry","KTQB__Field_Value__c":"ShippingCountry","KTQB__QuickBook_Field_Api_Name__c":"ShipAddrCountry","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":20},{"Name":"CustomerCurrencyReference","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"KTQB__Customer_Currecny__c","KTQB__Field_Value__c":"CustomerCurrencyReference","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":24},{"Name":"IsTaxable","KTQB__Data_Type__c":"BOOLEAN","KTQB__Field_API_Name__c":"KTQB__Is_Taxable__c","KTQB__Field_Value__c":"IsTaxable","KTQB__QuickBook_Field_Api_Name__c":"IsTaxable","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":23 }]';
                fieldMapping(jsonCustomerString,'KTQB__Customer_Object_Field_Mapping__c');
                
                // Create QB Invoice object field mapping Configuration
                String jsonInvoiceString = '[{"Name":"BillingAddress","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"BillingAddress","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__BillAddr__c","KTQB__QuickBook_Field_Api_Name__c":"BillAddr","KTQB__Sequence_Number__c":27},{"Name":"BalanceDue","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"BalanceDue","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Balance__c","KTQB__QuickBook_Field_Api_Name__c":"Balance","KTQB__Sequence_Number__c":14},{"Name":"PercentBasedDiscount","KTQB__Data_Type__c":"BOOLEAN","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"PercentBasedDiscount","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Percent_Based_Discount__c","KTQB__QuickBook_Field_Api_Name__c":"PercentBasedDiscount","KTQB__Sequence_Number__c":18},{"Name":"ShippingCharges","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"ShippingCharges","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Shipping_Charges__c","KTQB__QuickBook_Field_Api_Name__c":"ShippingCharges","KTQB__Sequence_Number__c":24},{"Name":"CurrencyReference","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"CurrencyReference","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Invoice_Currency__c","KTQB__QuickBook_Field_Api_Name__c":"CurrencyRef","KTQB__Sequence_Number__c":25},{"Name":"HomeTotalAmount","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"HomeTotalAmount","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__HomeTotalAmt__c","KTQB__QuickBook_Field_Api_Name__c":"HomeTotalAmt","KTQB__Sequence_Number__c":15},{"Name":"HomeBalance","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"HomeBalance","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__HomeBalance__c","KTQB__QuickBook_Field_Api_Name__c":"HomeBalance","KTQB__Sequence_Number__c":16},{"Name":"ExchangeRate","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"ExchangeRate","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__ExchangeRate__c","KTQB__QuickBook_Field_Api_Name__c":"ExchangeRate","KTQB__Sequence_Number__c":26},{"Name":"ShippingAddress","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"ShippingAddress","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__ShipAddr__c","KTQB__QuickBook_Field_Api_Name__c":"ShipAddr","KTQB__Sequence_Number__c":28},{"Name":"TaxRate","KTQB__Data_Type__c":"DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"TaxRate","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Tax_Percent__c","KTQB__QuickBook_Field_Api_Name__c":"TaxPercent","KTQB__Sequence_Number__c":22},{"Name":"InvoiceDate","KTQB__Data_Type__c":"DATE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"InvoiceDate","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Invoice_Date__c","KTQB__QuickBook_Field_Api_Name__c":"TxnDate","KTQB__Sequence_Number__c":7},{"Name":"BillEmail","KTQB__Data_Type__c":"STRING","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"BillEmail","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__BillEmail__c","KTQB__QuickBook_Field_Api_Name__c":"BillEmail","KTQB__Sequence_Number__c":2},{"Name":"TransactionDate","KTQB__Data_Type__c":"DATE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"TransactionDate","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Transaction_Date__c","KTQB__Sequence_Number__c":6},{"Name":"TotalAmount","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"TotalAmount","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Total_Amount__c","KTQB__QuickBook_Field_Api_Name__c":"TotalAmt","KTQB__Sequence_Number__c":13},{"Name":"QBCustomer","KTQB__Data_Type__c":"REFERENCE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"QBCustomer","KTQB__Required__c":true,"KTQB__Field_API_Name__c":"KTQB__Contact__c","KTQB__QuickBook_Field_Api_Name__c":"QBCustomerRef","KTQB__Sequence_Number__c":3},{"Name":"QbInvoiceSyncToken","KTQB__Data_Type__c":"DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"QbInvoiceSyncToken","KTQB__Required__c":true,"KTQB__Field_API_Name__c":"KTQB__Qb_Invoice_Sync_Token__c","KTQB__QuickBook_Field_Api_Name__c":"SyncToken","KTQB__Sequence_Number__c":11},{"Name":"InvoiceNumber","KTQB__Data_Type__c":"STRING","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"InvoiceNumber","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Invoice_Number__c","KTQB__QuickBook_Field_Api_Name__c":"DocNumber","KTQB__Sequence_Number__c":5},{"Name":"InvoiceStatus","KTQB__Data_Type__c":"STRING,PICKLIST","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"InvoiceStatus","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Invoice_Status__c","KTQB__QuickBook_Field_Api_Name__c":"InvoiceStatus","KTQB__Sequence_Number__c":9},{"Name":"TotalTax","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"TotalTax","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__TotalTax__c","KTQB__QuickBook_Field_Api_Name__c":"TotalTax","KTQB__Sequence_Number__c":23},{"Name":"DiscountAmount","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"DiscountAmount","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Discount_Amount__c","KTQB__QuickBook_Field_Api_Name__c":"DiscountAmount","KTQB__Sequence_Number__c":20},{"Name":"Terms","KTQB__Data_Type__c":"REFERENCE(KTQB__QB_MetaData__c)","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"Terms","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Sales_Term__c","KTQB__QuickBook_Field_Api_Name__c":"SalesTerm","KTQB__Help_Text__c":"Tomapthisfield,pleasecreatealookupfieldonthecurrentobjectwithadatatypeof`KTQB__QB_MetaData__c`.Applythefollowingfiltercriteria:`Type`EQUALS`Term`.","KTQB__Sequence_Number__c":10},{"Name":"DueDate","KTQB__Data_Type__c":"DATE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"DueDate","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Due_Date__c","KTQB__QuickBook_Field_Api_Name__c":"DueDate","KTQB__Sequence_Number__c":8},{"Name":"InvoiceQbId","KTQB__Data_Type__c":"STRING","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"InvoiceQbId","KTQB__Required__c":true,"KTQB__Field_API_Name__c":"KTQB__Invoice_Qb_Id__c","KTQB__QuickBook_Field_Api_Name__c":"Id","KTQB__Sequence_Number__c":12},{"Name":"Name","KTQB__Data_Type__c":"STRING","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"Name","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"Name","KTQB__QuickBook_Field_Api_Name__c":"Name","KTQB__Sequence_Number__c":1},{"Name":"DiscountPercent/DiscountValue","KTQB__Data_Type__c":"INTEGER,DOUBLE","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"DiscountPercent/DiscountValue","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Discount_Percent_Discount_Value__c","KTQB__QuickBook_Field_Api_Name__c":"DiscountPercentOrValue","KTQB__Sequence_Number__c":19},{"Name":"QBCustomerRefID","KTQB__Data_Type__c":"STRING","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"QBCustomerRefID","KTQB__Required__c":true,"KTQB__Field_API_Name__c":"KTQB__Qb_Invoice_Customer_Id__c","KTQB__QuickBook_Field_Api_Name__c":"QBCustomerRefID","KTQB__Sequence_Number__c":4},{"Name":"TaxCode","KTQB__Data_Type__c":"REFERENCE(KTQB__QB_MetaData__c)","KTQB__Read_Only__c":false,"KTQB__Field_Value__c":"TaxCode","KTQB__Required__c":true,"KTQB__Field_API_Name__c":"KTQB__Tax_Code__c","KTQB__QuickBook_Field_Api_Name__c":"TaxCodeRef","KTQB__Help_Text__c":"Tomapthisfield,pleasecreatealookupfieldonthecurrentobjectwithadatatypeof`KTQB__QB_MetaData__c`.Applythefollowingfiltercriteria:`Type`EQUALS`salesTax`.","KTQB__Sequence_Number__c":21},{"Name":"Applydiscountaftersalestax","KTQB__Data_Type__c":"BOOLEAN","KTQB__Read_Only__c":true,"KTQB__Field_Value__c":"Applydiscountaftersalestax","KTQB__Required__c":false,"KTQB__Field_API_Name__c":"KTQB__Apply_discount_after_sales_tax__c","KTQB__QuickBook_Field_Api_Name__c":"ApplyTaxAfterDiscount","KTQB__Sequence_Number__c":17}]';             
                fieldMapping(jsonInvoiceString,'KTQB__Invoice_Object_Field_Mapping__c');
                
                // Create QB LineItem object field mapping Configuration
                String jsonLineString = '[{"Name":"Description","KTQB__Data_Type__c":"STRING,TEXTAREA","KTQB__Field_API_Name__c":"KTQB__Description__c","KTQB__Field_Value__c":"Description","KTQB__QuickBook_Field_Api_Name__c":"Description","KTQB__Read_Only__c":false,"KTQB__Required__c":false,"KTQB__Sequence_Number__c":3},{"Name":"Name","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"Name","KTQB__Field_Value__c":"Name","KTQB__QuickBook_Field_Api_Name__c":"Name","KTQB__Read_Only__c":true,"KTQB__Required__c":false,"KTQB__Sequence_Number__c":1},{"Name":"Product/ServiceRefName","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Line_Item_Name__c","KTQB__Field_Value__c":"Product/ServiceRefName","KTQB__QuickBook_Field_Api_Name__c":"ItemRefName","KTQB__Read_Only__c":true,"KTQB__Required__c":false,"KTQB__Sequence_Number__c":4},{"Name":"UnitPrice","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Field_API_Name__c":"KTQB__Unit_Price__c","KTQB__Field_Value__c":"UnitPrice","KTQB__QuickBook_Field_Api_Name__c":"UnitPrice","KTQB__Read_Only__c":false,"KTQB__Required__c":true,"KTQB__Sequence_Number__c":5},{"Name":"LineItemId","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Line_Item_Id__c","KTQB__Field_Value__c":"LineItemId","KTQB__QuickBook_Field_Api_Name__c":"LineItemId","KTQB__Read_Only__c":true,"KTQB__Required__c":false,"KTQB__Sequence_Number__c":2},{"Name":"Quantity","KTQB__Data_Type__c":"INTEGER,DOUBLE","KTQB__Field_API_Name__c":"KTQB__Quantity__c","KTQB__Field_Value__c":"Quantity","KTQB__QuickBook_Field_Api_Name__c":"Qty","KTQB__Read_Only__c":false,"KTQB__Required__c":true,"KTQB__Sequence_Number__c":6},{"Name":"Taxable","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Taxable__c","KTQB__Field_Value__c":"Taxable","KTQB__QuickBook_Field_Api_Name__c":"TaxCodeRef","KTQB__Read_Only__c":false,"KTQB__Required__c":false,"KTQB__Sequence_Number__c":7}]';               
                fieldMapping(jsonLineString,'KTQB__LineItem_Object_Field_Mapping__c');
                
                // Create QB Payment object field mapping Configuration
				String jsonPaymentString = '[{"Name":"InvoicePaymentQbId","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Payment_Qb_Id__c","KTQB__Field_Value__c":"InvoicePaymentQbId","KTQB__QuickBook_Field_Api_Name__c":"Id","KTQB__Required__c":true,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":3},{"Name":"InvoicePaidAmount","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Field_API_Name__c":"KTQB__Invoice_Paid_Amount__c","KTQB__Field_Value__c":"InvoicePaidAmount","KTQB__QuickBook_Field_Api_Name__c":"InvoiceAmt","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":8},{"Name":"Name","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"Name","KTQB__Field_Value__c":"Name","KTQB__QuickBook_Field_Api_Name__c":"Name","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":1},{"Name":"QbSyncToken","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"DOUBLE","KTQB__Field_API_Name__c":"KTQB__Qb_SyncToken__c","KTQB__Field_Value__c":"QbSyncToken","KTQB__QuickBook_Field_Api_Name__c":"SyncToken","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":4},{"Name":"ExchangeRate","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"DOUBLE","KTQB__Field_API_Name__c":"KTQB__Exchange_Rate__c","KTQB__Field_Value__c":"ExchangeRate","KTQB__QuickBook_Field_Api_Name__c":"ExchangeRate","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":6},{"Name":"TransactionDate","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"DATE","KTQB__Field_API_Name__c":"KTQB__Transaction_Date__c","KTQB__Field_Value__c":"TransactionDate","KTQB__QuickBook_Field_Api_Name__c":"TxnDate","KTQB__Required__c":false,"KTQB__Read_Only__c":false,"KTQB__Sequence_Number__c":5},{"Name":"InvoicePaymentUniqueid","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"STRING","KTQB__Field_API_Name__c":"KTQB__Qb_Payment_Unique_Id__c","KTQB__Field_Value__c":"InvoicePaymentUniqueid","KTQB__QuickBook_Field_Api_Name__c":"payExtId","KTQB__Required__c":true,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":2},{"Name":"TransactionAmount","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Field_API_Name__c":"KTQB__Amount__c","KTQB__Field_Value__c":"TransactionAmount","KTQB__QuickBook_Field_Api_Name__c":"TotalAmt","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":7},{"Name":"UnappliedAmount","CurrencyIsoCode":"INR","KTQB__Data_Type__c":"CURRENCY,DOUBLE","KTQB__Field_API_Name__c":"KTQB__Unapplied_Amount__c","KTQB__Field_Value__c":"UnappliedAmount","KTQB__QuickBook_Field_Api_Name__c":"UnappliedAmt","KTQB__Required__c":false,"KTQB__Read_Only__c":true,"KTQB__Sequence_Number__c":9}]';               
                fieldMapping(jsonPaymentString,'KTQB__Payment_Object_Field_Mapping__c');
                
                // Create QB Encyption Key
                KTQB__Encryption_Configuration__c setting = KTQB__Encryption_Configuration__c.getOrgDefaults();
                Blob cryptoKey = Crypto.generateAesKey(256);
                setting.KTQB__Encryption_Key__c = EncodingUtil.base64Encode(cryptoKey);
                
                // Create QB Invoice Configuration
            	KTQB__InvoiceConfigurationOptions__c qbInv = new KTQB__InvoiceConfigurationOptions__c();
                qbInv.KTQB__Create_opportunity_product_as_QB_Item__c =  false;
                qbInv.KTQB__Create_Update_Qb_Payment_In_Sf__c =  false;
                qbInv.KTQB__Enable_Opportunity_Product__c	= false;
                qbInv.KTQB__Income_Account__c = '';
                qbInv.KTQB__Invoice_Customer_ChildObject_Api_Name__c = 'Contact';
                qbInv.KTQB__Invoice_Date__c='';
                qbInv.KTQB__Invoice_Due_Date__c='';
                qbInv.KTQB__Invoice_Object_Name__c='KTQB__QB_Invoice__c';
                qbInv.KTQB__Invoice_Save__c=true;
                qbInv.KTQB__Invoice_Save_and_Send__c=false;
                qbInv.KTQB__LineItem_ChildObject_Name__c='KTQB__QB_Invoice__c';
                qbInv.KTQB__LineItem_Object_Name__c='KTQB__QB_Invoice_Line_Item__c';
                qbInv.KTQB__Payment_Object_Name__c='KTQB__Qb_Invoice_Payment__c';
                qbInv.KTQB__Tax__c='';
                qbInv.KTQB__Terms__c='';
                insert qbInv;
                
                // Create QB Setting
            	KTQB__QB_Setting__c qbSetting = new KTQB__QB_Setting__c();
                qbSetting.KTQB__QB_version__c = 70;
                qbSetting.KTQB__Access_Token_Endpoint_Url__c = System.label.KTQB_Access_Token_Endpoint_Url_c;
                insert qbSetting;
                
                // Create QB Setup Configuration
                KTQB__Setup_Configuration__c qbSetup = new KTQB__Setup_Configuration__c();
                qbSetup.KTQB__Delete_Logs__c='Daily';
                insert qbSetup;
                
                /* Create QB Connection Record
                KTQB__Quickbook_Info__c qbConnect = new KTQB__Quickbook_Info__c();
                qbConnect.KTQB__Client_ID__c = Utils.processEncryption('');
                qbConnect.KTQB__Client_Secret__c = Utils.processEncryption('');
                qbConnect.KTQB__Access_Token__c = Utils.processEncryption('');
                qbConnect.KTQB__Refresh_Token__c = Utils.processEncryption('');
                qbConnect.KTQB__Completed_Steps__c = 0;
                qbConnect.KTQB__Progress_Value__c = 0;
                qbConnect.KTQB__Completed_Steps__c = 0;
                qbConnect.KTQB__QB_Company_Id__c= Utils.processEncryption('');
                qbConnect.KTQB__Redirect_URL__c='';
                qbConnect.KTQB__Refresh_Token_Life_Days__c=100;
                qbConnect.KTQB__SyncSite__c=Utils.processEncryption('');
                qbConnect.KTQB__Total_Connection_Steps__c=4;
                qbConnect.KTQB__Webhook_Verifier_Token__c=Utils.processEncryption('');
                qbConnect.KTQB__Sandbox_Url__c='';
                insert qbConnect;*/
            }
        }
    /**
     * @description Method is used to insert the Field Mapping
     * @param jsonInput Json Input of data
     * @param objectApiName API name of field mapping
    */   
    public static void fieldMapping(String jsonInput, String objectApiName) {
        
        /*List<Mapping> mappings = (List<Mapping>) JSON.deserialize(jsonInput, List<Mapping>.class);
        List<sObject> settingsToInsert;
    
        // Check the objectApiName and instantiate the list accordingly
        if (objectApiName == 'KTQB__Customer_Object_Field_Mapping__c') {
            settingsToInsert = new List<KTQB__Customer_Object_Field_Mapping__c>();
        } else if (objectApiName == 'KTQB__Invoice_Object_Field_Mapping__c') {
            settingsToInsert = new List<KTQB__Invoice_Object_Field_Mapping__c>();
        }else if (objectApiName == 'KTQB__LineItem_Object_Field_Mapping__c') {
            settingsToInsert = new List<KTQB__LineItem_Object_Field_Mapping__c>();
        }else if (objectApiName == 'KTQB__Payment_Object_Field_Mapping__c') {
            settingsToInsert = new List<KTQB__Payment_Object_Field_Mapping__c>();
        } else {
            // Handle the case when the objectApiName is not recognized
            return;
        }
    
        // Loop through mappings and populate the settingsToInsert list
        for (Mapping m : mappings) {
            sObject setting = (sObject) Type.forName(objectApiName).newInstance();
            setting.put('Name', m.Name);
            setting.put('KTQB__Data_Type__c', m.data_Type);
            setting.put('KTQB__Field_API_Name__c', m.field_API_Name);
            setting.put('KTQB__Field_Value__c', m.field_Value);
            setting.put('KTQB__QuickBook_Field_Api_Name__c', m.quickBook_Field_Api_Name);
            setting.put('KTQB__Required__c', m.required);
            setting.put('KTQB__Help_Text__c', m.helpText);
            setting.put('KTQB__Sequence_Number__c', m.sequenceNo);
            settingsToInsert.add(setting);
        }
    
        // Insert the records
        insert settingsToInsert;*/
        
        // Parse the JSON string into a List of Objects, which will be cast to Map<String, Object>
        List<Object> fieldMappings = (List<Object>) JSON.deserializeUntyped(jsonInput);
        
        // Get the SObject type dynamically using the provided object name
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        
        // Check if the object exists
        if (sObjectType == null) {
            return;
        }

        // Get the SObject describe result for field mappings
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

        // Prepare a list to hold the dynamic SObject records
        List<SObject> sObjectRecords = new List<SObject>();
        
        // Loop through the parsed data and create records
        for (Object obj : fieldMappings) {
            Map<String, Object> fieldMapping = (Map<String, Object>) obj; // Cast each object to a Map
            
            // Create a new instance of the dynamic SObject
            SObject record = sObjectType.newSObject();
            
            // Iterate through the fields in the map and set the values dynamically
            for (String fieldName : fieldMapping.keySet()) {
                if (fieldMap.containsKey(fieldName)) {
                    record.put(fieldName, fieldMapping.get(fieldName));
                }
            }
            
            // Add the record to the list
            sObjectRecords.add(record);
        }
        
        // Insert the records into the database
        try {
            insert sObjectRecords;
        } catch (DmlException e) {
            System.debug('Error inserting records: ' + e.getMessage());
        }
    }
    
}