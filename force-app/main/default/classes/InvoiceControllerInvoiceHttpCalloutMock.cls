/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Callout Response Class
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 08/10/2024 by Twinkle
 */
@isTest
public class InvoiceControllerInvoiceHttpCalloutMock implements HttpCalloutMock {
    /**
     * @description Responds to the HTTP request with a mock HTTP response containing sample customer data.
     * 
     * @param req HTTPRequest object, though not used in this mock.
     * @return HTTPResponse with status code 200 and JSON data simulating a customer response from QuickBooks.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Invoice\":{\"DocNumber\":\"1\",\"shipping\":\"1\",\"SyncToken\":\"0\",\"BillEmail\":{\"Address\":\"Familiystore@intuit.com\"},\"domain\":\"QBO\",\"SalesTermRef\":{\"value\":\"3\"},\"Balance\":100.0,\"BillAddr\":{\"City\":\"Bayshore\",\"Line1\":\"4581FinchSt.\",\"PostalCode\":\"94326\",\"Lat\":\"INVALID\",\"Long\":\"INVALID\",\"CountrySubDivisionCode\":\"CA\",\"Id\":\"2\"},\"TxnDate\":\"2015-07-24\",\"TotalAmt\":100.0,\"CustomerRef\":{\"name\":\"AmyBirdSanctuary\",\"value\":\"1\"},\"ShipAddr\":{\"City\":\"Bayshore\",\"Line1\":\"4581FinchSt.\",\"PostalCode\":\"94326\",\"Lat\":\"INVALID\",\"Long\":\"INVALID\",\"CountrySubDivisionCode\":\"CA\",\"Id\":\"109\"},\"LinkedTxn\":[],\"DueDate\":\"2015-08-23\",\"PrintStatus\":\"NeedToPrint\",\"Deposit\":0,\"sparse\":false,\"EmailStatus\":\"NotSet\",\"Line\":[{\"LineNum\":1,\"Amount\":100.0,\"SalesItemLineDetail\":{\"TaxCodeRef\":{\"value\":\"NON\"},\"ItemRef\":{\"name\":\"Services\",\"value\":\"1\"}},\"Id\":\"1\",\"DetailType\":\"SalesItemLineDetail\"},{\"DetailType\":\"SubTotalLineDetail\",\"Amount\":100.0,\"SubTotalLineDetail\":{}}],\"ApplyTaxAfterDiscount\":false,\"CustomField\":[{\"DefinitionId\":\"1\",\"Type\":\"StringType\",\"Name\":\"Crew#\"}],\"Id\":\"238\",\"TxnTaxDetail\":{\"TotalTax\":0},\"MetaData\":{\"CreateTime\":\"2015-07-24T10:33:39-07:00\",\"LastUpdatedTime\":\"2015-07-24T10:33:39-07:00\"}},\"time\":\"2015-07-24T10:33:39.11-07:00\"}');
        response.setStatusCode(200);
        return response;
    }
}