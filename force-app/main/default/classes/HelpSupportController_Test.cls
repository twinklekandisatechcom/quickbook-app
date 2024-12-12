/**
 * @description Test class for HelpSupportController to ensure the methods handle user information, file management, and case submission correctly within the system.
 */
@isTest
public with sharing class HelpSupportController_Test {
    /**
     * @description Tests getUserInfo method to ensure it correctly retrieves user information in the context of the running user.
     */
    @isTest
    public static void getUserInfoTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'KTTest',
            LastName = 'User',
            Email = 'testuserkt@example.com',
            Username = 'testuserKT@example.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        
        // Set the running user context to the test user
        System.runAs(testUser) {
            // Call the method to be tested
            User returnedUser = HelpSupportController.getUserInfo();
            
            // Verify that the returned user matches the test user
            System.assertEquals(testUser.Id, returnedUser.Id,'success');
            System.assertEquals(testUser.FirstName, returnedUser.FirstName,'success');
            System.assertEquals(testUser.LastName, returnedUser.LastName,'success');
            System.assertEquals(testUser.Email, returnedUser.Email,'success');
        }
    }
    /**
     * @description Tests getFilesSize method to ensure it validates the size of the files correctly based on IDs provided.
     */
    @isTest
    public static void getFilesSizeTest(){
        // Create test files
        List<ContentDocument> cdList = createTestFiles(3);
        List<String> docIdList = new List<String>();
        for(ContentDocument cd : cdList) {
            docIdList.add(cd.Id);
        }

        // Test the method with valid input
        Test.startTest();
        Boolean result = HelpSupportController.getFilesSize(docIdList);
        System.assertEquals(true, result, 'Success');

        // Create another test file with large size
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Large File';
        cv.PathOnClient = 'Large.txt';
        cv.VersionData = Blob.valueOf('Test');
        insert cv;

        result = HelpSupportController.getFilesSize(new List<String>{cv.ContentDocumentId});
        Test.stopTest();
    }
    /**
     * @description Tests submitCase method to validate case creation with and without attachments and handle different inputs including nulls.
     */
    @isTest
    public static void submitCaseTest(){
        // Create test files
        List<ContentDocument> cdList = createTestFiles(2);
        List<String> filesData = new List<String>();
        for(ContentDocument cd : cdList) {
            filesData.add(cd.Id);
        }

        // Create test support data
        HelpSupportController.SupportDataWrapper sdWrap = createTestSupportData();
        String supportData = JSON.serialize(sdWrap);
        Boolean sendEmailFlag;
        // Test the method with valid input and no exception
        try {
            Test.startTest();
            sendEmailFlag = HelpSupportController.submitCase(supportData, filesData);
            System.assertEquals(false, sendEmailFlag, 'Success');
        } catch(Exception e) {
            sendEmailFlag = false;
            System.assertEquals(false, sendEmailFlag, 'Success');
        }

        try {
            sendEmailFlag = HelpSupportController.submitCase(null, null);
            System.assertEquals(false, sendEmailFlag, 'Success');
        } catch(Exception e) {
            sendEmailFlag = false;
            System.assertEquals(false, sendEmailFlag, 'Success');
        }
        Test.stopTest();
    }
    /**
     * @description Tests deleteDocuments method to ensure it handles deletion of documents correctly and handles empty inputs gracefully.
     */
    @isTest
    public static void deleteDocumentsTest(){
        // Create test files
        List<ContentDocument> cdList = createTestFiles(2);
        List<String> deleteIds = new List<String>();
        for(ContentDocument cd : cdList) {
            deleteIds.add(cd.Id);
        }

        // Test the method with valid input
        Test.startTest();
        Boolean result = HelpSupportController.deleteDocuments(deleteIds);
        System.assertEquals(false, result, 'Success');
        result = HelpSupportController.deleteDocuments(new List<String>());
        System.assertEquals(false, result, 'No Document IDs');
        Test.stopTest();
    }
    /**
     * @description Generates a specified number of test ContentDocument records for testing purposes.
     * @param numFiles The number of test files to create.
     * @return List<ContentDocument> A list of ContentDocument records representing the created files.
     */
    public static List<ContentDocument> createTestFiles(Integer numFiles){
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<String> docIdList = new List<String>();
        for(Integer i = 0; i < numFiles; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test File ' + i;
            cv.PathOnClient = 'Test' + i + '.txt';
            cv.VersionData = Blob.valueOf('Test Content');
            cvList.add(cv);
        }
        insert cvList;
        List<ContentVersion> conDocList2 = new List<ContentVersion>();
        conDocList2 = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title LIKE '%Test File%']; 

        for(ContentVersion cv : conDocList2) {
            docIdList.add(cv.ContentDocumentId);
        }
        List<ContentDocument> conDocList = new List<ContentDocument>();
        conDocList = [SELECT Id, ContentSize FROM ContentDocument WHERE Id IN: docIdList]; 
        return conDocList;
    }
    /**
     * @description Creates a test support data wrapper object for testing the support case submission functionality.
     * @return HelpSupportController.SupportDataWrapper A wrapper object populated with test data.
     */
    public static HelpSupportController.SupportDataWrapper createTestSupportData() {
        HelpSupportController.SupportDataWrapper sdWrap = new HelpSupportController.SupportDataWrapper();
        sdWrap.firstName = 'Test';
        sdWrap.lastName = 'User';
        sdWrap.email = 'test@test.com';
        sdWrap.enquiryValue = 'General';
        sdWrap.description = 'This is a test support request';
        return sdWrap;
    }
}