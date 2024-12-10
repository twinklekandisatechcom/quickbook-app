/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Permission Set Component [PermissionSetCmp] & Setup and Configuration Component [SetupConfigCmp]
 * @created on        : 2023
 * @last modified on  : 16-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
public with sharing class PermissionSetController {
    
    /** @description Permission Set Component : Wrapper Class. */
    public class PermissionWrapper{
        /** @description Permission Set Component : For Id. */
        @AuraEnabled public String id {get;set;}
        /** @description Permission Set Component : For Name. */
        @AuraEnabled public String name {get;set;}
        /** @description Permission Set Component : For Setup Url. */
        @AuraEnabled public String setupUrl {get;set;}
    }
    
    /**
     * @description Permission Set Component : For list of permission sets from PermissionSet.
     * @return List of Permission Sets.
     */
    @AuraEnabled public static List<PermissionWrapper> fetchPermission(){
        List<PermissionWrapper> permissionWrapList = new List<PermissionWrapper>();
        List<PermissionSet> permissionList = new List<PermissionSet>();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        try{
            permissionList =[ SELECT Id, Name, Label, Type, Description, CreatedDate 
                              FROM PermissionSet 
                              WHERE Name IN ('Quickbook_Integration_User_Read_Only','Quickbook_Integration_Operational','Quickbook_Integration_Admin')
                              WITH USER_MODE];
            if(permissionList.size()>0){
                for(PermissionSet p : permissionList){
                    PermissionWrapper pw = new PermissionWrapper();
                    pw.id = p.Id;
                    pw.name = p.Name;
                    pw.setupUrl = baseUrl + '/lightning/setup/PermSets/'+p.Id+'/PermissionSetAssignment/home';
                    permissionWrapList.add(pw);
                }
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return permissionWrapList;
    }    
    
    /** @description Permission Set Component : Wrapper Class. */
    public class PermissionSetsWrapper{
        /** @description Permission Set Component : For User Id. */
        @AuraEnabled public String userId {get;set;}
        /** @description Permission Set Component : For Name. */
        @AuraEnabled public String name {get;set;}
        /** @description Permission Set Component : For User Name. */
        @AuraEnabled public String userName {get;set;}
        /** @description Permission Set Component : For Email. */
        @AuraEnabled public String email {get;set;}
        /** @description Permission Set Component : For isActive. */
        @AuraEnabled public Boolean isActive {get;set;}
        /** @description Permission Set Component : For Permission Set Name. */
        @AuraEnabled public String permissionSetName {get;set;}
        /** @description Permission Set Component : For Permission Set Label. */
        @AuraEnabled public String permissionSetLabel {get;set;}
        /** @description Permission Set Component : For Profile. */
        @AuraEnabled public String profile {get;set;}
    }
    
    /**
     * @description Permission Set Component : For list of permission sets from PermissionSet.
     * @return List of Permission Sets.
     */
    @AuraEnabled public static List<PermissionSetsWrapper> fetchPermissionSets(){
        List<PermissionSetsWrapper> permissionWrapList = new List<PermissionSetsWrapper>(); 
        try{
            List<PermissionSetAssignment> perassign =[ SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Label, 
                                                        PermissionSet.Profile.Name, AssigneeId, Assignee.Name, Assignee.IsActive, Assignee.userName,
                                                        Assignee.email
                                                       FROM PermissionSetAssignment 
                                                       WHERE PermissionSet.Name IN ('Quickbook_Integration_User_Read_Only','Quickbook_Integration_Operational','Quickbook_Integration_Admin')
                                                       WITH USER_MODE ];
            Set<Id> userIdSet = new Set<Id>();
            Map<Id,user> userMap = new Map<Id,User>(); 
            for(PermissionSetAssignment obj : perassign){
                userIdSet.add(obj.AssigneeId);
                PermissionSetsWrapper wrapObj = new PermissionSetsWrapper();
                wrapObj.userId = obj.AssigneeId;
                wrapObj.name = obj.Assignee.Name;
                wrapObj.username = obj.Assignee.username;
                wrapObj.email = obj.Assignee.email;
                wrapObj.IsActive = obj.Assignee.IsActive;
                wrapObj.permissionSetName = obj.PermissionSet.Name;
                wrapObj.permissionSetLabel= obj.PermissionSet.Label;
                permissionWrapList.add(wrapObj);
            }
            if(userIdSet.size() > 0){
                userMap = new Map<Id,User>([ SELECT Id, Name, Username, Email, ProfileId, profile.Name, IsActive 
                                             FROM User 
                                             WHERE Id IN: userIdSet 
                                             WITH USER_MODE ]);
                for(PermissionSetsWrapper obj : permissionWrapList){
                    if(userMap.containsKey(obj.userId)){
                        obj.profile = userMap.get(obj.userId).profile.Name;
                    }
                }
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return permissionWrapList;
    }
}