@isTest
public class CalloutUtlityCustomerHttpCalloutMock implements HttpCalloutMock {
    /**
     * @description Responds to HTTP requests with a predefined JSON structure that mimics the response from a QBO API fetching customer data.
     * @param req The HttpRequest being sent. This parameter is required by the HttpCalloutMock interface but not used in this mock.
     * @return HttpResponse A mocked response object that includes JSON data similar to what would be returned by a QBO API call to fetch customer details.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('"{\"Customer\":{\"PrimaryEmailAddr\":{\"Address\":\"Surf@Intuit.com\"},\"SyncToken\":\"0\",\"domain\":\"QBO\",\"GivenName\":\"Bill\",\"DisplayName\":\"BillWindsurfShop\",\"BillWithParent\":false,\"FullyQualifiedName\":\"BillWindsurfShop\",\"CompanyName\":\"BillWindsurfShop\",\"FamilyName\":\"Lucchini\",\"sparse\":false,\"PrimaryPhone\":{\"FreeFormNumber\":\"(415)444-6538\"},\"Active\":true,\"Job\":false,\"BalanceWithJobs\":85.0,\"BillAddr\":{\"City\":\"HalfMoonBay\",\"Line1\":\"12OceanDr.\",\"PostalCode\":\"94213\",\"Lat\":\"37.4307072\",\"Long\":\"-122.4295234\",\"CountrySubDivisionCode\":\"CA\",\"Id\":\"3\"},\"PreferredDeliveryMethod\":\"Print\",\"Taxable\":false,\"PrintOnCheckName\":\"BillWindsurfShop\",\"Balance\":85.0,\"Id\":\"2\",\"MetaData\":{\"CreateTime\":\"2014-09-11T16:49:28-07:00\",\"LastUpdatedTime\":\"2014-09-18T12:56:01-07:00\"}},\"time\":\"2015-07-23T11:04:15.496-07:00\"}"');
        response.setStatusCode(200);
        return response;
    }
}