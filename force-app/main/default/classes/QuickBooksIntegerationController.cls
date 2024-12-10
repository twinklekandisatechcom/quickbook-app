/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Generate Invoice Customer Creation Form [generateInvoiceCustomerCreationForm], [currencyConfigCmp], [generateInvoiceForm], [invoiceConfigurationCmp] & [qBCustomerSync]
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 

//@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.ApexXSSFromURLParam, PMD.UnusedLocalVariable')
public without sharing class QuickBooksIntegerationController {
    public static KTQB__Quickbook_Info__c  qbInfo = [SELECT Id,KTQB__Client_ID__c,KTQB__Redirect_URL__c,KTQB__Client_Secret__c,KTQB__Refresh_Token__c,KTQB__QB_Company_Id__c,KTQB__Access_Token__c,KTQB__Sandbox_Url__c FROM KTQB__Quickbook_Info__c WITH USER_MODE 
                                               LIMIT 1];
    public AuthorizationCredentialsWrapper wrpAuthCredentials;
    public string salesforceUrl;
   
    /**
     * @description Multiple Components.
     * @param stdController
     */
    public QuickBooksIntegerationController(ApexPages.StandardController stdController) {
        pageLoad();
    }
    /**
     * @description Multiple Components - Constructor.
     */
    public QuickBooksIntegerationController() {
        boolean tempBoolean = false; // For pmd scanning
        tempBoolean.toString();
    }

    /**
     * @description Multiple Components - For authorization.
     */
    public void pageLoad(){
        salesforceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        KTQB__QB_Setting__c qbSetting = KTQB__QB_Setting__c.getOrgDefaults();
        wrpAuthCredentials = new AuthorizationCredentialsWrapper();
        wrpAuthCredentials.QbRecordId=qbInfo.Id;
        //wrpAuthCredentials.accessTokenEndpointUrl='https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
        wrpAuthCredentials.accessTokenEndpointUrl= qbSetting.KTQB__Access_Token_Endpoint_Url__c;
        wrpAuthCredentials.client_id = Utils.processDecryption(qbInfo.KTQB__Client_ID__c);
        wrpAuthCredentials.client_secret = Utils.processDecryption(qbInfo.KTQB__Client_Secret__c);
        wrpAuthCredentials.redirect_uri = qbInfo.KTQB__Redirect_URL__c;
        wrpAuthCredentials.response_type= 'code';
        wrpAuthCredentials.state='PlaygroundAuth';
        wrpAuthCredentials.scope='com.intuit.quickbooks.accounting';
        wrpAuthCredentials.refresh_token = String.isNotBlank(qbInfo.KTQB__Refresh_Token__c) ? Utils.processDecryption(qbInfo.KTQB__Refresh_Token__c) : '';
    }

    /**
     * @description Multiple Components - For fetching access token.
     * @return Pagereference
     */
    public Pagereference fetchAccessToken(){
        try{
            if(Apexpages.currentPage() != Null){
                wrpAuthCredentials.authoziationCode = Apexpages.currentPage().getParameters().get('code');  
                wrpAuthCredentials.realmId = Apexpages.currentPage().getParameters().get('realmId');
            }  
            
            if(String.isNotBlank(wrpAuthCredentials.authoziationCode) || wrpAuthCredentials.authoziationCode != null){
                if(wrpAuthCredentials.authoziationCode != null || String.isNotBlank(wrpAuthCredentials.authoziationCode)){
                    String Body = 'grant_type=authorization_code&code='+wrpAuthCredentials.authoziationCode.escapeHtml4()+'&redirect_uri='+wrpAuthCredentials.redirect_uri;
                    AuthorizationWrapper authData = accessTokenHelperMethod(body,true);  
                    wrpAuthCredentials.access_token = authData.access_token;
                    wrpAuthCredentials.refresh_token = authData.refresh_token;
                    KTQB__Quickbook_Info__c qb = new KTQB__Quickbook_Info__c(Id=wrpAuthCredentials.QbRecordId);
                    qb.KTQB__Access_Token__c = Utils.processEncryption(wrpAuthCredentials.access_token);
                    qb.KTQB__Refresh_Token__c = Utils.processEncryption(authData.refresh_token);
                    qb.Refresh_Token_Life_Days__c =100;
                    qb.Last_Refresh_Token_Date__c = System.now();
                    qb.KTQB__QB_Company_Id__c = Utils.processEncryption(wrpAuthCredentials.realmId.escapeHtml4());
                    if(Schema.sObjectType.KTQB__Quickbook_Info__c.isUpdateable()){
                    	Database.update(qb,AccessLevel.User_mode);
                    }
                    SetupConfigController.updateCusSettingndScheduleBatch();
                }
                if(String.isNotBlank(salesforceUrl)){
                    String url = salesforceUrl+'/lightning/n/KTQB__QuickBooks_Setup';
                    PageReference pg = new PageReference(url);
                    return pg.setRedirect(true);
                }
            }
            PageReference pg2 =  fetchAuthorizationCode();
            return pg2.setRedirect(true);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Multiple Components - For fetching authorization code.
     * @return Pagereference
     */
    public  Pagereference fetchAuthorizationCode(){
        String body='?client_id='+wrpAuthCredentials.client_id+'&redirect_uri='+wrpAuthCredentials.redirect_uri+'&state='+wrpAuthCredentials.state+'&scope='+wrpAuthCredentials.scope+'&response_type='+wrpAuthCredentials.response_type;
        String url = 'https://appcenter.intuit.com/app/connect/oauth2'+body;
        Pagereference p = new Pagereference(url);
        return p;
    }

    /**
     * @description Multiple Components - For refresh token.
     */
    @AuraEnabled public static void refreshToken(){
        try{
            QuickBooksIntegerationController qb = new QuickBooksIntegerationController();
            KTQB__Quickbook_Info__c qbInfoRecord = qb.fetchAccessTokenUsingRefreshToken(true);
            if(Schema.sObjectType.KTQB__Quickbook_Info__c.isUpdateable() && String.isNotBlank(qbInfoRecord.KTQB__Access_Token__c) && String.isNotBlank(qbInfoRecord.KTQB__Refresh_Token__c)){
                UPDATE as user qbInfoRecord;
            }
        }catch(Exception e){
            HandleCustomException.logException(e);
        }
	}
    
    /**
     * @description Multiple Components - For fetching access token using refresh token.
     * @param doGenerateLog Boolean
     * @return KTQB__Quickbook_Info__c Record Data.
     */
    public KTQB__Quickbook_Info__c fetchAccessTokenUsingRefreshToken(Boolean doGenerateLog){
        try{
            pageLoad();
            if(wrpAuthCredentials.refresh_token != null || String.isNotBlank(wrpAuthCredentials.refresh_token)){
                String body = 'grant_type=refresh_token&refresh_token='+wrpAuthCredentials.refresh_token;
                AuthorizationWrapper authData = accessTokenHelperMethod(body,doGenerateLog);
                wrpAuthCredentials.access_token = authData.access_token;
                wrpAuthCredentials.refresh_token = authData.refresh_token;
                KTQB__Quickbook_Info__c qb = new KTQB__Quickbook_Info__c(Id=wrpAuthCredentials.QbRecordId);
                qb.Last_Refresh_Token_Date__c = System.now();
                qb.KTQB__Access_Token__c = Utils.processEncryption(authData.access_token);
                qb.KTQB__Refresh_Token__c = Utils.processEncryption(authData.refresh_token);
                return qb;
            }
            return new KTQB__Quickbook_Info__c();
        }catch(Exception e){
            HandleCustomException.logException(e);
            return new KTQB__Quickbook_Info__c();
        }
    }

    /**
     * @description Multiple Components - Helper method.
     * @param body - Body data
     * @param doGenerateLog
     * @return Access and refresh token.
     */
    public AuthorizationWrapper accessTokenHelperMethod(String body,Boolean doGenerateLog){
        try{
            Http hp = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(wrpAuthCredentials.accessTokenEndpointUrl);
            req.setBody(body);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(wrpAuthCredentials.client_id+':'+wrpAuthCredentials.client_secret)));
            
            HttpResponse response = hp.send(req);
            CalloutUtlityController.CalloutCredentials cred = new CalloutUtlityController.CalloutCredentials();
            cred.requestbody = req;
            cred.responsebody = response;
            CalloutUtlityController.createQBLog(cred,qbInfo.id);
            if(CalloutUtlityController.qbLogs.size() > 0 && doGenerateLog == true){
                insert as user CalloutUtlityController.qbLogs;
            }
            AuthorizationWrapper authData = (AuthorizationWrapper) JSON.deserialize(response.getBody(), AuthorizationWrapper.class);    
            return authData;
        }catch(Exception e){
            HandleCustomException.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** @description Multiple Components : Wrapper Class. */
    Public Class AuthorizationWrapper {
        public String access_token;
        public String refresh_token;
    }

    /** @description Multiple Components : Wrapper Class. */
    Public Class AuthorizationCredentialsWrapper {
        Public String QbRecordId;
        Public String accessTokenEndpointUrl;
        Public String client_id;
        Public String client_secret;
        Public String scope;
        Public String redirect_uri;
        Public String response_type;
        Public String state;
    
        Public String authoziationCode;
        Public String realmId;
        Public String access_token;
        Public String refresh_token;

        /** @description Multiple Components : Wrapper Class. */
        public AuthorizationCredentialsWrapper(){
            QbRecordId = '';
            accessTokenEndpointUrl = '';
            client_id = '';
            client_secret = '';
            scope = '';
            redirect_uri = '';
            response_type = '';
            state = '';
            
            authoziationCode = '';
            realmId = '';
            access_token = '';
            refresh_token = '';
        }
    }

}