/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Callout Response Class
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 08/10/2024 by Twinkle
 */
@isTest
public class InvoiceCtrlCustomerUnauthHttpCalloutMock implements HttpCalloutMock {
    /**
     * @description Responds to the HTTP request with a mock HTTP response containing sample customer data.
     * 
     * @param req HTTPRequest object, though not used in this mock.
     * @return HTTPResponse with status code 200 and JSON data simulating a customer response from QuickBooks.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Customer\":{\"domain\":\"QBO\",\"PrimaryEmailAddr\":{\"Address\":\"jdrew@myemail.com\"},\"DisplayName\":\"KingGroceries\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"DefaultTaxCodeRef\":{\"value\":\"2\"},\"PreferredDeliveryMethod\":\"Print\",\"GivenName\":\"James\",\"FullyQualifiedName\":\"KingGroceries\",\"BillWithParent\":false,\"Title\":\"Mr\",\"Job\":false,\"BalanceWithJobs\":0,\"PrimaryPhone\":{\"FreeFormNumber\":\"(555)555-5555\"},\"Taxable\":true,\"MetaData\":{\"CreateTime\":\"2015-07-23T10:58:12-07:00\",\"LastUpdatedTime\":\"2015-07-23T10:58:12-07:00\"},\"BillAddr\":{\"City\":\"MountainView\",\"Country\":\"USA\",\"Line1\":\"123MainStreet\",\"PostalCode\":\"94042\",\"CountrySubDivisionCode\":\"CA\",\"Id\":\"112\"},\"MiddleName\":\"B\",\"Notes\":\"Hereareotherdetails.\",\"Active\":true,\"Balance\":0,\"SyncToken\":\"0\",\"Suffix\":\"Jr\",\"CompanyName\":\"KingGroceries\",\"FamilyName\":\"King\",\"PrintOnCheckName\":\"KingGroceries\",\"sparse\":false,\"Id\":\"67\"},\"time\":\"2015-07-23T10:58:12.099-07:00\"}');
        response.setStatus('Unauthorized');
        return response;
    }
}