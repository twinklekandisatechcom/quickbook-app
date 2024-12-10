/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Callout Response Class
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 08/10/2024 by Twinkle
 */
@isTest
public class InvoiceControllerItemHttpCalloutMock2 implements HttpCalloutMock {
    /**
     * @description Responds to the HTTP request with a mock HTTP response containing sample customer data.
     * 
     * @param req HTTPRequest object, though not used in this mock.
     * @return HTTPResponse with status code 200 and JSON data simulating a customer response from QuickBooks.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Item\":{\"FullyQualifiedName\":\"GardenSupplies\",\"domain\":\"QBO\",\"Id\":\"19\",\"Name\":\"GardenSupplies\",\"TrackQtyOnHand\":true,\"UnitPrice\":0,\"PurchaseCost\":0,\"QtyOnHand\":10,\"IncomeAccountRef\":{\"name\":\"SalesofProductIncome\",\"value\":\"79\"},\"AssetAccountRef\":{\"name\":\"InventoryAsset\",\"value\":\"81\"},\"Taxable\":false,\"sparse\":false,\"Active\":true,\"SyncToken\":\"0\",\"InvStartDate\":\"2015-01-01\",\"Type\":\"Inventory\",\"ExpenseAccountRef\":{\"name\":\"CostofGoodsSold\",\"value\":\"80\"},\"MetaData\":{\"CreateTime\":\"2015-12-09T11:12:39-08:00\",\"LastUpdatedTime\":\"2015-12-09T11:12:41-08:00\"}},\"time\":\"2015-12-09T11:12:39.748-08:00\"}');
        response.setStatus('Unauthorized');
        return response;
    }
}