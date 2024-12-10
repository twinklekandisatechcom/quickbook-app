/**
 * @description       : Mock class for testing HTTP callouts in the QbMetaDataController. Provides a simulated response for currency and term metadata from QuickBooks API.
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 10-05-2023
 * @last modified on  : 17-05-2023
 * @last modified by  : Mangesh Kadam
 * Modified by Twinkle on 09-10-2024
 **/
@isTest
public class QbMetaDataContrCurrencyHttpCalloutMock implements HttpCalloutMock{
	/**
     * @description Mocks the HTTP response for QuickBooks API metadata requests, including currency and term details.
     *
     * @param req The HTTP request object being mocked.
     * @return An HTTP response object with predefined currency and term data in JSON format.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"totalCount\":5,\"CompanyCurrency\":[{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"JPY\",\"Name\":\"JapaneseYen\",\"sparse\":false,\"Active\":true,\"Id\":\"5\",\"MetaData\":{\"CreateTime\":\"2015-06-19T09:20:44-07:00\",\"LastUpdatedTime\":\"2015-06-19T09:20:44-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"ANG\",\"Name\":\"DutchGuilder\",\"sparse\":false,\"Active\":true,\"Id\":\"4\",\"MetaData\":{\"CreateTime\":\"2015-06-12T14:16:38-07:00\",\"LastUpdatedTime\":\"2015-06-12T14:16:38-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"AUD\",\"Name\":\"AustralianDollar\",\"sparse\":false,\"Active\":true,\"Id\":\"3\",\"MetaData\":{\"CreateTime\":\"2015-06-05T13:59:43-07:00\",\"LastUpdatedTime\":\"2015-06-05T13:59:43-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"EUR\",\"Name\":\"Euro\",\"sparse\":false,\"Active\":true,\"Id\":\"2\",\"MetaData\":{\"CreateTime\":\"2015-06-05T13:59:42-07:00\",\"LastUpdatedTime\":\"2015-06-05T13:59:42-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Code\":\"CAD\",\"Name\":\"CanadianDollar\",\"sparse\":false,\"Active\":true,\"Id\":\"1\",\"MetaData\":{\"CreateTime\":\"2015-06-05T13:59:42-07:00\",\"LastUpdatedTime\":\"2015-06-05T13:59:42-07:00\"}}],\"maxResults\":5},\"time\":\"2015-07-06T13:29:01.560-07:00\"}');
        response.setBody('{\"QueryResponse\":{\"startPosition\":1,\"Term\":[{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Dueonreceipt\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":0,\"Id\":\"1\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net10\",\"DiscountPercent\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":10,\"Id\":\"5\",\"MetaData\":{\"CreateTime\":\"2014-09-16T15:24:26-07:00\",\"LastUpdatedTime\":\"2014-09-16T15:24:26-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net15\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":15,\"Id\":\"2\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net30\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":30,\"Id\":\"3\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"Name\":\"Net60\",\"DiscountPercent\":0,\"DiscountDays\":0,\"Type\":\"STANDARD\",\"sparse\":false,\"Active\":true,\"DueDays\":60,\"Id\":\"4\",\"MetaData\":{\"CreateTime\":\"2014-09-11T14:41:49-07:00\",\"LastUpdatedTime\":\"2014-09-11T14:41:49-07:00\"}},{\"SyncToken\":\"0\",\"domain\":\"QBO\",\"DayOfMonthDue\":1,\"Name\":\"TermForV3Testing-1373590184130\",\"DiscountPercent\":0,\"sparse\":false,\"Active\":true,\"Type\":\"DATE_DRIVEN\",\"Id\":\"6\",\"MetaData\":{\"CreateTime\":\"2015-01-29T08:27:32-08:00\",\"LastUpdatedTime\":\"2015-01-29T08:27:32-08:00\"}}],\"maxResults\":6},\"time\":\"2015-07-28T08:26:23.942-07:00\"}');
        response.setStatusCode(200);
        return response;
    } 
}