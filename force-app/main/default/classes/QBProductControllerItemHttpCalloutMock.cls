/**
 * @description : class is a test utility designed for mocking HTTP callouts.
 */
@isTest
public class QBProductControllerItemHttpCalloutMock implements HttpCalloutMock {
    /**
     * @description Mocks the HTTP response for a product item request to simulate QuickBooks API response.
     *
     * @param req The HTTP request object being mocked.
     * @return An HTTP response object with predefined product item data in JSON format.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"Item\":{\"FullyQualifiedName\":\"GardenSupplies\",\"domain\":\"QBO\",\"Id\":\"19\",\"Name\":\"GardenSupplies\",\"TrackQtyOnHand\":true,\"UnitPrice\":0,\"PurchaseCost\":0,\"QtyOnHand\":10,\"IncomeAccountRef\":{\"name\":\"SalesofProductIncome\",\"value\":\"79\"},\"AssetAccountRef\":{\"name\":\"InventoryAsset\",\"value\":\"81\"},\"Taxable\":false,\"sparse\":false,\"Active\":true,\"SyncToken\":\"0\",\"InvStartDate\":\"2015-01-01\",\"Type\":\"Inventory\",\"ExpenseAccountRef\":{\"name\":\"CostofGoodsSold\",\"value\":\"80\"},\"MetaData\":{\"CreateTime\":\"2015-12-09T11:12:39-08:00\",\"LastUpdatedTime\":\"2015-12-09T11:12:41-08:00\"}},\"time\":\"2015-12-09T11:12:39.748-08:00\"}');
        response.setStatusCode(200);
        return response;
    }
}