@isTest
public class CurrencyConfigControllerHttpCalloutMock implements HttpCalloutMock{
    /**
     * @description Responds with a mock HTTP response to simulate a callout to an external API.
     *
     * @param req The incoming HTTPRequest that is being mocked.
     * @return    HttpResponse containing a mock JSON body with account and currency details.
     */
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{\"CompanyCurrency\":{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"GBP\",\"Name\":\"BritishPoundSterling\",\"sparse\":false,\"Active\":true,\"Id\":\"7\",\"MetaData\":{\"CreateTime\":\"2015-07-06T13:34:48-07:00\",\"LastUpdatedTime\":\"2015-07-06T13:34:48-07:00\"}},\"time\":\"2015-07-06T13:34:48.569-07:00\"}');
        response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"Account\":[{\"FullyQualifiedName\":\"CanadianAccountsReceivable\",\"domain\":\"QBO\",\"Name\":\"CanadianAccountsReceivable\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-06-23T09:38:18-07:00\",\"LastUpdatedTime\":\"2015-06-23T09:38:18-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"92\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyClients\",\"domain\":\"QBO\",\"Name\":\"MyClients\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-07-13T12:34:47-07:00\",\"LastUpdatedTime\":\"2015-07-13T12:34:47-07:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"93\",\"SubAccount\":false},{\"FullyQualifiedName\":\"MyJobs\",\"domain\":\"QBO\",\"Name\":\"MyJobs\",\"Classification\":\"Asset\",\"AccountSubType\":\"AccountsReceivable\",\"CurrencyRef\":{\"name\":\"UnitedStatesDollar\",\"value\":\"USD\"},\"CurrentBalanceWithSubAccounts\":0,\"sparse\":false,\"MetaData\":{\"CreateTime\":\"2015-01-13T10:29:27-08:00\",\"LastUpdatedTime\":\"2015-01-13T10:29:27-08:00\"},\"AccountType\":\"AccountsReceivable\",\"CurrentBalance\":0,\"Active\":true,\"SyncToken\":\"0\",\"Id\":\"91\",\"SubAccount\":false}],\"maxResults\":3},\"time\":\"2015-07-13T12:35:57.651-07:00\"}');
        response.setStatusCode(200);
        return response;
    }  
}