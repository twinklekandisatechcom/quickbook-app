import { LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createAuthProvider from '@salesforce/apex/SetupConfigController.createAuthProvider';
import fetchPermission from '@salesforce/apex/PermissionSetController.fetchPermission';
import getSecureSiteURL from '@salesforce/apex/SetupConfigController.getSecureSiteURL';
import getSetupConfiguration from '@salesforce/apex/SetupConfigController.getSetupConfiguration';
import getSites from '@salesforce/apex/SetupConfigController.getSites';
import getSitesConfigURL from '@salesforce/apex/SetupConfigController.getSitesConfigURL';
import saveQbToSf from '@salesforce/apex/SetupConfigController.saveQbToSf';
import syncQbInvoiceObject from '@salesforce/apex/QbMetaDataController.syncQbInvoiceObject';
const EVNOPTIONS=[
            {label: 'Sandbox', value: 'https://sandbox-quickbooks.api.intuit.com/v3/company/'},
            {label: 'Production', value: 'https://quickbooks.api.intuit.com/v3/company/'}
        ],
      FOURCOMPLETEDSTEPS = 4,
      ONECOMPLETEDSTEPS = 1,
      THREECOMPLETEDSTEPS = 3,
      TWOCOMPLETEDSTEPS = 2,
      ZERO = 0;

export default class SetupConfigCmp extends LightningElement {
    @track showLoading = false;
    @track completedSteps = ZERO;
    @track progressValue = ZERO;
    @track progressPercent = ZERO;
    @track progressWebhook = ZERO;
    @track progressPermission = ZERO;
    @track progressLayout = ZERO;
    @track showQBConnection = false;
    @track showQBWebhook = false;
    @track showQBPermission = false;
    @track showOpportunity = false;
    @track xciconName = "utility:chevronright";
    @track firstStep ;
    @track secondStep ;
    @track thirdStep ;
    @track fourthStep ;
    @track verifierToken='';
    showModal = false;
    consumerSecret;
    consumerKey;
    environmentValue;
    redirectUrl = '';
    redirectUrlLabel = '';
    disableSave = true;
    disableRedirectUrlInput = true;
    disableWebhookInput = false;
    disableSyncSave = true;
    showSiteCreation = false;
    disablePS = false;
    disableLayoutSave = false;
    disableInput = false;
    isAuthenticated  = false ;
    environmentOptions = EVNOPTIONS;

    get progressRingStyleStep1() {
        return this.progressPercent === 1 ? 'background:green;' : '';
    }
    get progressRingStyleStep2() {
        return this.progressWebhook === 1 ? 'background:green;' : '';
    }
    get progressRingStyleStep3() {
        return this.progressPermission === 1 ? 'background:green;' : '';
    }
    get progressRingStyleStep4() {
        return this.progressLayout === 1 ? 'background:green;' : '';
    }
    connectedCallback(){
        this.showLoading = true;
        this.getConfiguration();
        this.getAllSites();
        this.getPermissionSets();

        if (typeof window !== 'undefined') {

            this.redirectUrl = `${window.location.origin}/apex/QuickBookOAuthRedirectPage`;
            
        }

        this.redirectUrlLabel = `Copy Redirect URL '${  this.redirectUrl }' into the Redirect Url in Quickbook setting.`;
    }
    syncRelatedObject(option){
        syncQbInvoiceObject({type:option})
            .then((result) => {
                this.showLoading = false;
                return result;
            })
            .catch(error => {
                this.error = error;
                this.showLoading = false;
        })
    }
    get progressStyle() {
        return `width: ${this.progressValue}%`;
    }
    getConfiguration(){
        this.showLoading = true;
        getSetupConfiguration({})
        .then(result => {
            if(result){
                this.setupConfig = result;
                this.customSettingId = this.setupConfig.id;
                if(typeof this.setupConfig.progressValue === 'undefined'){
                    this.progressValue = 0;
                    this.completedSteps = 0;
                }else{
                    this.progressValue = this.setupConfig.progressValue;
                    this.completedSteps = this.setupConfig.completedSteps;
                }
                const preAuthFields = ['clientId', 'clientSecret', 'accessToken', 'refreshToken', 'envType'];
                if (preAuthFields.every(field => result[field] !== null && typeof result[field] !== 'undefined')) {
                    this.consumerKey = result.clientId;
                    this.consumerSecret = result.clientSecret;
                    this.environmentValue = result.envType;
                    this.verifierToken = result.verifierToken;
                    this.disableInput = true;
                }
                if(this.completedSteps === ONECOMPLETEDSTEPS){
                    if(this.disableInput === true){
                            const options = ['Term' ,'Account','salesTax','PaymentMethod'];
                            options.forEach(option => {
                                this.syncRelatedObject(option);
                            });
                        this.showToast('Please proceed to second step.', 'dismissable', 'Quickbook - Salesforce Authorization Completed Succesfully', 'success');
                    }else if(this.disableInput === false){
                            this.completedSteps = 0;
                            this.setupConfig.completedSteps = 0;
                            this.progressValue = 0;
                            this.setupConfig.progressValue = 0;
                            this.showToast('Please review first step.', 'dismissable', 'Quickbook - Salesforce Authorization Failed', 'error');
                    }
                }if(this.completedSteps === TWOCOMPLETEDSTEPS){
                     this.showToast('Please proceed to third step.', 'dismissable', 'Quickbook - Salesforce Sync Completed Succesfully', 'success');
                }if(this.completedSteps === THREECOMPLETEDSTEPS){
                     this.showToast('Please proceed to fourth step.','dismissable','Permission Sets Assigned Succesfully','success');
                }if(this.completedSteps === FOURCOMPLETEDSTEPS && this.disableInput === false){
                    this.disableInput = true;
                    this.showToast('Please troubleshoot the connection issue.','dismissable','Quickbook - Salesforce Authorization Failed','error');
                }
                if(this.setupConfig.syncSite && this.setupConfig.webhookKey){
                    this.siteVal = this.setupConfig.syncSite;
                    this.siteSecureURL = this.setupConfig.webhookKey;
                    this.disableWebhookInput = true;
                }
                if(this.completedSteps === FOURCOMPLETEDSTEPS && (this.setupConfig.webhookKey === null || this.setupConfig.webhookKey === '' || typeof this.setupConfig.webhookKey === 'undefined') && (this.setupConfig.syncSite === null || this.setupConfig.syncSite === '' || typeof this.setupConfig.syncSite === 'undefined')){
                    this.disableWebhookInput = true;
                     this.showToast('Please troubleshoot the connection issue.','dismissable','Quickbook - Salesforce Sync Failed','error');
                }
                const stepConfigurations = [
                    { firstStep: false, secondStep: true, thirdStep: true, fourthStep: true, showQBConnection:true, showQBWebhook:false, showQBPermission:false, showOpportunity:false},
                    { progressPercent: 1, firstStep: false, secondStep: false, thirdStep: true, fourthStep: true, showQBConnection:false, showQBWebhook:true, showQBPermission:false, showOpportunity:false },
                    { progressPercent: 1, progressWebhook: 1, firstStep: false, secondStep: false, thirdStep: false, fourthStep: true, showQBConnection:false, showQBWebhook:false, showQBPermission:true, showOpportunity:false },
                    { progressPercent: 1,  progressWebhook: 1, progressPermission: 1, firstStep: false, secondStep: false, thirdStep: false , fourthStep: false, showQBConnection:false, showQBWebhook:false, showQBPermission:false, showOpportunity:true, disablePS:true},
                    { progressPercent: 1, progressWebhook: 1, progressPermission: 1, progressLayout: 1, firstStep: false, secondStep: false, thirdStep: false ,fourthStep: false, showQBConnection:false, showQBWebhook:false, showQBPermission:false, showOpportunity:false, disablePS: true, disableLayoutSave: true},
                ],
                    config = stepConfigurations[this.completedSteps];
                if (config) {
                    Object.assign(this, config);
                } else if(result.completedSteps === FOURCOMPLETEDSTEPS){
                    this.showLoading = false;
                    this.showToast('Success', 'dismissable', 'All Steps Completed Successfully','success');
                }
                if(result.completedSteps >= ONECOMPLETEDSTEPS){
                    this.isAuthenticated = true;
                } else if(result.completedSteps === ZERO){
                    this.isAuthenticated = false;
                }
                this.consumerKey = result.clientId;
                this.consumerSecret = result.clientSecret;
                this.environmentValue = result.envType;
                this.showLoading = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error, 'dismissable', 'Something Went Wrong in getSetupConfiguration','error');
        })
    }
    getAllSites(){
        this.showLoading = true;
        getSites({})
        .then(result => {
            if(result.length > ZERO){
                this.siteDetails = result;
                const siteOptions = [];
                result.forEach(element => {
                    siteOptions.push({ label: element.masterLabel, value: element.id})
                });
                this.siteOptions = siteOptions;
            }else{
                this.showSiteCreation = true;
            }
            this.getSitesConfigURL();
            this.showLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong','error');
        })
    }
    getSitesConfigURL(){
        this.showLoading = true;
        getSitesConfigURL({
            entity : 'Sites'
        })
        .then(result => {
            if(result){
                this.sitesURL = result;
            }
            this.getRedirectURL();
            this.showLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong','error');
        })
    }
    getRedirectURL(){
        this.showLoading = true;
        getSitesConfigURL({
            entity : 'VFURL'
        })
        .then(result => {
            if(result){
                this.redirectURL = result;
            }
            this.showLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong','error');
        })
    }
    getPermissionSets(){
        fetchPermission({})
        .then(result => {
            if(result.length > ZERO){
                const pMap = new Map();
                result.forEach(ele => {
                    pMap.set(ele.name, ele.setupUrl);
                });
                this.permissionSets = pMap;
            }
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong','error');
        })
    }
    openSites(){
        const url = this.sitesURL;
        window.open(url, "_blank");
    }
    onchangeVerifierToken(event){        
        this.verifierToken = event.target.value;
        this.disableSyncSave = false;
    }
    fetchSecureURL(event){
        this.showLoading = true;
        this.siteVal = event.target.value;
        this.siteId = this.siteVal;
        this.guestUserId = this.siteDetails.find(element => element.id === event.target.value).guestUserId;
        getSecureSiteURL({
            siteId : event.target.value
        })
        .then(result => {
            if(result){
                this.siteSecureURL = result;
                this.setupConfig.syncSite = this.siteId;
                this.setupConfig.webhookKey = this.siteSecureURL;
                this.disableSyncSave = false;
            }else{
                this.showToast('Error','dismissable','Something Went Wrong','error');
            }
            this.showLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong','error');
        })
    }
    webhookStepSave(){
        if(typeof this.siteSecureURL === 'undefined'  || this.siteSecureURL === '' || this.siteSecureURL === null){
            this.showToast('Please Select Site.','dismissable','Sync Quickbook with Salesforce','error');
        }else if(typeof this.verifierToken === 'undefined' || this.verifierToken == '' || this.verifierToken == null){
            this.showToast('Please enter Verifier Token.','dismissable','Sync Quickbook with Salesforce','error');
        }else{
            this.showLoading = true;
            this.disableSyncSave = true;
            this.setupConfig.progressValue = 50;
            this.setupConfig.completedSteps = 2;
            this.setupConfig.verifierToken = this.verifierToken;
            saveQbToSf({
                setupConfig: JSON.stringify(this.setupConfig)
            })
            .then(result => {
                if(result === true){
                    this.disableWebhookInput = true;
                    this.getConfiguration();
                }
            })
            .catch(error => {
                this.error = error;
                this.showLoading = false;
                this.showToast(error,'dismissable','Something Went Wrong in saveQbToSf','error');
            })
        }
        
    }
    renderedCallback(){
        if(this.showQBConnection){
            const ele = this.template.querySelector('[data-id="qbConnection"]');
             if(ele !== null) {
                             ele.iconName = "utility:chevrondown";
             }
        }
        if(this.showQBWebhook){
            const ele = this.template.querySelector('[data-id="webhookBtn"]');
            if(ele !== null) {
                ele.iconName = "utility:chevrondown";
            }
        }
        if(this.showQBPermission){
            const ele = this.template.querySelector('[data-id="permissionBtn"]');
            if(ele !== null) {
                ele.iconName = "utility:chevrondown";
            }
        }
        if(this.showOpportunity){
            const ele = this.template.querySelector('[data-id="opportunityBtn"]');
            if(ele !== null) {
                ele.iconName = "utility:chevrondown";
            }
        }
    }  
    changeView(event){
        const btName = event.target.dataset.id,
              ele = this.template.querySelector(`[data-id="${btName}"]`),
        {iconName} = ele,
        property = {
            opportunityBtn: { showProperty: 'showOpportunity' },
            permissionBtn: { showProperty: 'showQBPermission' },
            qbConnection: { showProperty: 'showQBConnection' },
            webhookBtn: { showProperty: 'showQBWebhook' },
        }[btName]?.showProperty;
        if(!ele){
           return '';
        };
        if (iconName === 'utility:chevronright') {
            ele.iconName = 'utility:chevrondown';
            this[property] = true;
        } else {
            ele.iconName = 'utility:chevronright';
            this[property] = false;
        }
    }
    updateValue(event){
        if(event.target.name === 'Client ID'){
            this.consumerKey = event.target.value.trim();
        }else if(event.target.name === 'Client Secret'){
            this.consumerSecret = event.target.value.trim();
        }else if(event.target.name === 'Environment'){
            this.environmentValue = event.target.value;
        }
        if(this.consumerKey !== null && this.consumerKey !== '' && typeof this.consumerKey !== 'undefined' &&
            this.consumerSecret !== null && this.consumerSecret !== '' &&  typeof this.consumerSecret !== 'undefined' &&
            this.environmentValue !== null && this.environmentValue !== '' &&  typeof this.environmentValue !== 'undefined'){
            this.disableSave = false;
            this.disableReset = true;
        }else{
            this.disableSave = true;
            this.disableReset = false;
        }
    }
    showInstruction(){
        this.showModal = true;
        this.showPositiveButton = true;
        this.showNegativeButton = false;
        this.positiveButtonLabel = 'Close';
    }
    closeModal() {
        this.showModal = false;
    }
    saveConnect(){
        if(this.consumerKey !== null && this.consumerSecret !== null && this.environmentValue !== null){
            this.authProviderCreation();
        }else if(this.consumerKey === null || this.consumerSecret === null){
            this.showToast('','dismissable','Enter valid value for Client Id and Client Secret','error');
        }
        this.disableInput = true;
        this.disableSave = true;
        this.disableReset = false;
    }
    authProviderCreation(){
        this.showLoading = true;
        createAuthProvider({
            clientId: this.consumerKey,
            clientSecret: this.consumerSecret,
            connectionStep :1,
            environmentValue : this.environmentValue,
            progressValue : 25,
            redirectUrl: this.redirectUrl,
            totalConnectionStep:4
        })
        .then(result => {
            if(result){
                const redirectUrlToVFP = `${result}/apex/QuickBookOAuthRedirectPage`;
                if (typeof window !== "undefined") {
                    window.close();
                    window.open(redirectUrlToVFP);
                }
            }
            this.showLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong in createAuthProvider','error');
        })
    }
     handleConnectionLink () {
        this.dispatchEvent(new CustomEvent(
            "connectiontab",
            {
                "detail": true
            }
        ));
    }
    saveValuesInSf(){
        this.showLoading = true;
        saveQbToSf({
            setupConfig: JSON.stringify(this.setupConfig)
        })
        .then(result => {
            if(result === true){
                this.getConfiguration();
            }
        })
        .catch(error => {
            this.error = error;
            this.showLoading = false;
            this.showToast(error,'dismissable','Something Went Wrong in saveQbToSf','error',);
        })
    }
    handlePermission(event){
        const permission = event.target.value,
            url = this.permissionSets.get(permission);
        window.open(url, "_blank");  
    }
    handlePermissionLink () {
        this.dispatchEvent(new CustomEvent(
            "permissiontab", { "detail": true }
        ));
    }
    handleSavePermission(){
        this.setupConfig.progressValue = 75;
        this.setupConfig.completedSteps = 3;
        this.saveValuesInSf();
        this.showToast('Please proceed to fourth step.','dismissable','Permission Sets Assigned Succesfully','success');
        this.disablePS = true;
    }
    get selectedValues() {
        return this.value.join(",");
    }
    handleChange(evt) {
        this.value = evt.detail.value;
    }
    layoutUpdated(){
        this.showLoading = true;
        this.setupConfig.progressValue = 100;
        this.setupConfig.completedSteps = 4;
        this.saveValuesInSf();
        this.dispatchEvent(new CustomEvent(
            "enabletabs", { "detail": false }
        ));
        this.showToast('Please proceed to other section.','dismissable','Opportunity Page-Layout Setup Completed Successfully','success');
        this.showLoading = false;
        this.disableLayoutSave = true;
    }
    showToast(msg, mod, tle, vrt) {

        if (typeof window !== 'undefined') {

            const evt = new ShowToastEvent({
                message: msg,
                mode: mod,
                title: tle,
                variant: vrt
            });
            this.dispatchEvent(evt);

        }

    }
}