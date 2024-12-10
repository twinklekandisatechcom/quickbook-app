/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Permission setup class class
 * @created on        : 2024
 * Modified on 10/10/2024 by Twinkle
 */
@isTest
public class PermissionSetController_Test {
    /**
     * @description Test setup method that creates test data required for executing test methods.
     * This method inserts a `PermissionSet` record to simulate a Quickbook Integration User.
     */
    @TestSetup
    public static void createData(){
        
        PermissionSet ps = new PermissionSet(Label = 'Quickbook Integration User Read Onlyyy', Name = 'Quickbook_Integration_User_Read_Onlyyy');
		insert ps;
    }
    /**
     * @description Test method to validate the `fetchPermission` method in `PermissionSetController`.
     * It initiates the test, calls the method, and stops the test to verify it runs without exceptions.
     */
    @isTest
    public static void fetchPermission_Test(){
        test.startTest();
        List<PermissionSetController.PermissionWrapper> ppw = PermissionSetController.fetchPermission();
        test.stopTest();
        system.assertNotEquals(null,ppw,'success');
    }
    /**
     * @description Test method to validate the `fetchPermissionSets` method in `PermissionSetController`.
     * Starts the test, fetches permission set details, and stops the test to verify successful execution.
     */
    @isTest
    public static void fetchPermissionSets_Test(){
        test.startTest();
        List<PermissionSetController.PermissionSetsWrapper> ppsw = PermissionSetController.fetchPermissionSets();
        test.stopTest();
        system.assertNotEquals(null,ppsw,'success');
    }
}