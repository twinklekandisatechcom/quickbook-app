@isTest
public class CalloutUtlityItemHttpCalloutMock implements HttpCalloutMock{
    /**
     * @description Responds to HTTP requests with a predefined JSON structure that mimics the response from a QBO API fetching customer data.
     * @param req The HttpRequest being sent. This parameter is required by the HttpCalloutMock interface but not used in this mock.
     * @return HttpResponse A mocked response object that includes JSON data similar to what would be returned by a QBO API call to fetch customer details.
     */
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Item\":{\"FullyQualifiedName\":\"Trees\",\"domain\":\"QBO\",\"Name\":\"Trees\",\"SyncToken\":\"0\",\"sparse\":false,\"Active\":true,\"Type\":\"Category\",\"Id\":\"29\",\"MetaData\":{\"CreateTime\":\"2015-10-06T08:50:34-07:00\",\"LastUpdatedTime\":\"2015-10-06T08:50:34-07:00\"}},\"time\":\"2015-10-06T08:50:34.863-07:00\"}');
        response.setStatusCode(200);
        return response;
    } 
}