/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Setup and Configuration Component [SetupConfigCmp] & [setupPageCmp] & [connectionResetCmp] & [generateInvoiceCustomerCreationForm] & [qBCustomerSync]
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 
//@SuppressWarnings('PMD.UnusedLocalVariable') // For 'sR'(deleteQBIRec)
public with sharing class SetupConfigController {
    /** @description Setup and Configuration Component : Wrapper Class. */
    public class SetupConfigWrapper{
        /** @description Setup and Configuration Component : For Record id. */
        @AuraEnabled public String id {get;set;}
        /** @description Setup and Configuration Component : For Name. */
        @AuraEnabled public String name {get;set;}
        /** @description Setup and Configuration Component : For Progress Value. */
        @AuraEnabled public Decimal progressValue {get;set;}
        /** @description Setup and Configuration Component : For Total Connection Steps. */
        @AuraEnabled public Decimal totalConnectionSteps {get;set;}
        /** @description Setup and Configuration Component : For Completed Steps. */
        @AuraEnabled public Decimal completedSteps {get;set;}
        /** @description Setup and Configuration Component : For Client Id. */
        @AuraEnabled public string clientId {get;set;}
        /** @description Setup and Configuration Component : For Client Secret. */
        @AuraEnabled public string clientSecret {get;set;}
        /** @description Setup and Configuration Component : For Environment Type. */
        @AuraEnabled public string envType {get;set;}
        /** @description Setup and Configuration Component : For Access Token. */
        @AuraEnabled public string accessToken {get;set;}
        /** @description Setup and Configuration Component : For Refresh Token. */
        @AuraEnabled public string refreshToken {get;set;}
        /** @description Setup and Configuration Component : For Sync Site. */
        @AuraEnabled public string syncSite {get;set;}
        /** @description Setup and Configuration Component : For Webhook Key. */
        @AuraEnabled public string webhookKey {get;set;}
        /** @description Setup and Configuration Component : For Verifier Token. */
        @AuraEnabled public string verifierToken {get;set;}
    }
    
    /**
     * @description Setup and Configuration Component : For data from record in KTQB__Quickbook_Info__c.
     * @return Record data
     */
    @AuraEnabled
    public static SetupConfigWrapper getSetupConfiguration(){
        SetupConfigWrapper scwrap = new SetupConfigWrapper();
        try{
            list<KTQB__Quickbook_Info__c> qi = [ SELECT Id, Name, KTQB__Webhook_Verifier_Token__c, KTQB__Client_ID__c , KTQB__Client_Secret__c, KTQB__Redirect_URL__c, KTQB__Access_Token__c, KTQB__Refresh_Token__c, Sandbox_Url__c,
                                           KTQB__Progress_Value__c, KTQB__Completed_Steps__c, KTQB__Total_Connection_Steps__c,KTQB__Webhook_Key__c,KTQB__SyncSite__c 
                                           FROM KTQB__Quickbook_Info__c
                                           WITH USER_MODE
                                           LIMIT 1 ];
                if(qi.size()  > 0){
                    scwrap.clientId = Utils.processDecryption(qi[0].KTQB__Client_ID__c);
                    scwrap.clientSecret = Utils.processDecryption(qi[0].KTQB__Client_Secret__c);
                    scwrap.envType = qi[0].Sandbox_Url__c;
                    scwrap.accessToken = Utils.processDecryption(qi[0].KTQB__Access_Token__c);
                    scwrap.refreshToken = Utils.processDecryption(qi[0].KTQB__Refresh_Token__c);
                    scwrap.progressValue = qi[0].KTQB__Progress_Value__c != null ? qi[0].KTQB__Progress_Value__c : 0;
                    scwrap.completedSteps =  qi[0].KTQB__Completed_Steps__c != null ? qi[0].KTQB__Completed_Steps__c : 0;
                    scwrap.totalConnectionSteps =  qi[0].KTQB__Total_Connection_Steps__c != null ? qi[0].KTQB__Total_Connection_Steps__c : 0;
                    scwrap.webhookKey =  qi[0].KTQB__Webhook_Key__c;
                    scwrap.syncSite =  Utils.processDecryption(qi[0].KTQB__SyncSite__c);
                    scwrap.verifierToken = Utils.processDecryption(qi[0].KTQB__Webhook_Verifier_Token__c);
                }  
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return scwrap;
    }

    /**
     * @description Setup and Configuration Component : Wrapper Class.
     */
    public class SiteWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public String guestUserId;
    }

    /**
     * @description Setup and Configuration Component : For all sites data from Site.
     * @return Sites Data
     */
    @AuraEnabled public static List<SiteWrapper> getSites(){
        List<Site> siteList = new List<Site>();
        List<SiteWrapper> siteWrapList = new List<SiteWrapper>();
        try{
            siteList = [ SELECT Id, Name, Status, SiteType, GuestUserId, MasterLabel 
                         FROM Site 
                         WHERE Status = 'Active' AND SiteType = 'Visualforce'
                         WITH USER_MODE];
            if(siteList.size()>0){
                for(Site s : siteList){
                    SiteWrapper sw = new SiteWrapper();
                    sw.id = s.Id;
                    sw.masterLabel = s.MasterLabel;
                    sw.guestUserId = s.GuestUserId;
                    siteWrapList.add(sw);
                }
            }
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return siteWrapList;
    }

    /**
     * @description Setup and Configuration Component : For salesforce base url and adding custom url.
     * @param entity - Sites/VFURL
     * @return Salesforce Base Url + Additional Url
     */
	@AuraEnabled public static string getSitesConfigURL(String entity){
		String sfURL = System.URL.getSalesforceBaseUrl().toExternalForm();
		try {
            if(entity == 'Sites'){
				sfURL +='/lightning/setup/CustomDomain/home';
            }else{
				sfURL = null;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return sfURL;
	}

    /**
     * @description Setup and Configuration Component : For selected site url and adding custom url.
     * @param siteId - Selected Site Id
     * @return Selected Site Url + Additional Url
     */
    @AuraEnabled public static string getSecureSiteURL(String siteId){
        String siteURL = '';
        SiteDetail sd = new SiteDetail();
        try {
            sd = [ SELECT Id, DurableId, SecureUrl 
                   FROM SiteDetail 
                   WHERE DurableId =: siteId 
                   WITH USER_MODE ];
            if(sd != null && String.isNotBlank(sd.SecureUrl)){
                siteURL = sd.SecureUrl;
                siteURL += 'services/apexrest/KTQB/quickbookintegration/';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return siteURL;
    }

    /**
     * @description Setup and Configuration Component : To save fields data from ui to record in KTQB__Quickbook_Info__c.
     * @param setupConfig - Fields data in wrapper
     * @return Boolean
     */
    @AuraEnabled public static Boolean saveQbToSf(String setupConfig){
        Boolean updated = false;
        SetupConfigWrapper scwrap = new SetupConfigWrapper();
        try {
            if(String.isNotBlank(setupConfig)){
                scwrap = (SetupConfigWrapper)JSON.deserialize(setupConfig,SetupConfigWrapper.class);
                list<KTQB__Quickbook_Info__c> qi = [ SELECT Id, Name, KTQB__Client_ID__c , KTQB__Client_Secret__c, KTQB__Redirect_URL__c, KTQB__Access_Token__c, KTQB__Refresh_Token__c, Sandbox_Url__c
                   ,KTQB__Progress_Value__c, KTQB__Completed_Steps__c, KTQB__Total_Connection_Steps__c,KTQB__SyncSite__c,KTQB__Webhook_Key__c FROM KTQB__Quickbook_Info__c
                   WITH USER_MODE
                   LIMIT 1 ];
                if(qi.size() > 0){
                    qi[0].KTQB__Progress_Value__c = scwrap.progressValue;
                    qi[0].KTQB__Completed_Steps__c = scwrap.completedSteps;
                    qi[0].KTQB__Webhook_Key__c = scwrap.webhookKey;
                    qi[0].KTQB__SyncSite__c = Utils.processEncryption(scwrap.syncSite);
                    qi[0].KTQB__Webhook_Verifier_Token__c = Utils.processEncryption(scwrap.verifierToken);
                }
                update as user qi[0];
                updated = true;
                //Database.SaveResult sR = Database.update(qi[0],AccessLevel.User_mode);
                //updated = sR.isSuccess();
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return updated;
    }

    /**
     * @description Setup and Configuration Component : To save fields data from ui to record in KTQB__Quickbook_Info__c.
     */
    @AuraEnabled public static void updateCusSettingndScheduleBatch(){
        try {
                //String hour = String.valueOf(Datetime.now().hour());
                //You can add any no of Minute you want to add to schedule it for next
                String min = String.valueOf(Datetime.now().addMinutes(45).minute());
                String ss = String.valueOf(Datetime.now().second());
                
                //parse to a cron expression
            String nextFireTime = ss + ' ' + min + ' ' + '*' + ' * * ?';
                
                //Create an Instance of your Schedule Class
                //scheduleSuccessApi s = new scheduleSuccessApi(apiType,requestIdList,afterDate);
                if(!Test.isRunningTest()){
                    List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'BatchToRefreshAccessTokenInQB'  WITH USER_MODE limit 1 ];
                    if(cronTriggers.isEmpty()){
                        System.schedule('BatchToRefreshAccessTokenInQB', nextFireTime, new BatchToRefreshAccessTokenInQB());
                    }
                }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
    }

    /**
     * @description Setup and Configuration Component : To create record from ui to KTQB__Quickbook_Info__c with fields data for Authorization.
     * @param clientId - Client ID
     * @param clientSecret - Client Secret
     * @param environmentValue - Sandbox/Production
     * @param redirectUrl - VF Page Url
     * @param progressValue - Setup Configuration Progress
     * @param connectionStep - 1 to 4
     * @param totalConnectionStep - 4 
     * @return String [Salesforce Base Url]
     */
    @AuraEnabled public static String createAuthProvider(String clientId, String clientSecret, String environmentValue, String redirectUrl, Integer progressValue, Integer connectionStep, Integer totalConnectionStep){
        String salesforceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String result = '';
        try{
            list<KTQB__Quickbook_Info__c> qbInfoList = [SELECT Id FROM KTQB__Quickbook_Info__c WITH USER_MODE LIMIT 1 ];
            KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
            if(qbInfoList.size() > 0){
                qbInfo.id = qbInfoList[0].id;
            }
            qbInfo.Name = 'QB-0001';
            qbInfo.KTQB__Client_ID__c  = Utils.processEncryption(clientId);
            qbInfo.KTQB__Client_Secret__c = Utils.processEncryption(clientSecret);
            qbInfo.Sandbox_Url__c = environmentValue;
            qbInfo.KTQB__Redirect_URL__c = redirectUrl;
            qbInfo.KTQB__Refresh_Token__c = '';
            qbInfo.KTQB__Access_Token__c = '';
            qbInfo.KTQB__Progress_Value__c = progressValue;
            qbInfo.KTQB__Total_Connection_Steps__c = totalConnectionStep;
            qbInfo.KTQB__Completed_Steps__c = connectionStep;
            if(KTQB__Quickbook_Info__c.getSObjectType().getDescribe().isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_ID__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_Secret__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.Sandbox_Url__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Redirect_URL__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Refresh_Token__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Access_Token__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Progress_Value__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Total_Connection_Steps__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Completed_Steps__c.isCreateable() == true
            
            && KTQB__Quickbook_Info__c.getSObjectType().getDescribe().isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_ID__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_Secret__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.Sandbox_Url__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Redirect_URL__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Refresh_Token__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Access_Token__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Progress_Value__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Total_Connection_Steps__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Completed_Steps__c.isUpdateable() == true){

                //Database.UpsertResult upsertResult = Database.upsert(qbInfo,AccessLevel.User_mode);
                upsert as user qbInfo;
                result = salesforceUrl;
                /*if (upsertResult.isSuccess()) {
                    result = salesforceUrl;
                }*/
            }
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return result;
    }

    /**
     * @description Setup and Configuration Component : To update record from ui to KTQB__Quickbook_Info__c with fields data for Reset.
     * @return String ['QuickBook Info Reset']
     */
     @AuraEnabled public static String resetAuthProvider(){
        String result = '';
        try{
            List<KTQB__Quickbook_Info__c> qbInfoList = [ SELECT Id, KTQB__Client_ID__c, KTQB__Client_Secret__c, Sandbox_Url__c, KTQB__Access_Token__c, KTQB__Refresh_Token__c 
                                                   FROM KTQB__Quickbook_Info__c 
                                                   WITH USER_MODE LIMIT 1 ];
            KTQB__Quickbook_Info__c qbInfo = new KTQB__Quickbook_Info__c();
            if(qbInfoList.size() > 0){
                qbInfo.id = qbInfoList[0].id;
                qbInfoList[0].KTQB__Client_ID__c = '';
                qbInfoList[0].KTQB__Client_Secret__c = '';
                qbInfoList[0].KTQB__Access_Token__c = '';
                qbInfoList[0].KTQB__Refresh_Token__c = '';
            }
            if(KTQB__Quickbook_Info__c.getSObjectType().getDescribe().isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_ID__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_Secret__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Refresh_Token__c.isCreateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Access_Token__c.isCreateable() == true
            
            && KTQB__Quickbook_Info__c.getSObjectType().getDescribe().isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_ID__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Client_Secret__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Refresh_Token__c.isUpdateable() == true
            && Schema.sObjectType.KTQB__Quickbook_Info__c.fields.KTQB__Access_Token__c.isUpdateable() == true){
                upsert as user qbInfoList[0];
                result = 'QuickBook Info Reset';
                /*Database.UpsertResult upsertResult = Database.upsert(qbInfoList[0],AccessLevel.User_mode);
                if (upsertResult.isSuccess()) {
                    result = 'QuickBook Info Reset';
                }*/
            }
            return result;
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
        return result;
    }
}