/**
     * @description Class is used to update the configurations once after uninstalling package
     * @Author : Kandisa Technologies
     * @CreatedDate : 08 April 2024
     * Modified on 10-10-2024 by Twinkle
*/
@isTest
public with sharing class PostInstallScriptTest {
    /**
     * @description Test setup method that creates test data required for executing test methods.
     */
    @isTest
    static void testInstallScript() {
        PostInstallScript postinstall = new PostInstallScript();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        List<KTQB__Quickbook_Info__c> con = [SELECT Id,Name FROM KTQB__Quickbook_Info__c LIMIT 1];
        System.assertnotequals(null,con,'success');
    }
}