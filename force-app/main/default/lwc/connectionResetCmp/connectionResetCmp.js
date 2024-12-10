import {LightningElement, track} from "lwc";
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import createAuthProvider from "@salesforce/apex/SetupConfigController.createAuthProvider";
import getSecureSiteURL from "@salesforce/apex/SetupConfigController.getSecureSiteURL";
import getSetupConfiguration from "@salesforce/apex/SetupConfigController.getSetupConfiguration";
import getSites from "@salesforce/apex/SetupConfigController.getSites";
import getSitesConfigURL from "@salesforce/apex/SetupConfigController.getSitesConfigURL";
import saveQbToSf from "@salesforce/apex/SetupConfigController.saveQbToSf";

const ENV_OPTIONS = [
    {
        "label": "Sandbox",
        "value": "https://sandbox-quickbooks.api.intuit.com/v3/company/"
    },
    {
        "label": "Production",
        "value": "https://quickbooks.api.intuit.com/v3/company/"
    }
],
ZERO = 0;

export default class ConnectionResetCmp extends NavigationMixin(LightningElement) {

    disableSaveBtn = true;

    @track showLoading;

    consumerKey;

    consumerSecret;

    environmentValue;

    disableInput;

    disableReset = true;

    disableSave = false;

    @track showQBConnection;

    @track showQBWebhook;

    disableWebhookInput;

    showSiteCreation;

    showWebhookSteps;


    disableWebhookSave;

    siteVal;

    siteSecureURL;

    @track showModal;

    @track showPositiveButton;

    @track showNegativeButton;

    @track positiveButtonLabel;
    
    @track verifierToken;
    disableStepSave = true;

    environmentOptions = ENV_OPTIONS;

    connectedCallback () {
        this.initailization();
        this.getConfiguration();

        if (typeof window !== "undefined") {
        this.redirectUrl = `${window.location.origin}/apex/QuickBookOAuthRedirectPage`;
        }

        this.redirectUrlLabel = `Copy Redirect URL ${this.redirectUrl} into the Redirect URL in Quickbook setting`;
    }

    initailization () {
        this.showQBConnection = false;
        this.showQBWebhook = false;
        this.disableWebhookInput = false;
        this.showSiteCreation = true;
        this.showWebhookSteps = false;
        this.showModal = false;
        this.showLoading = true;
        this.showQBConnection = true;
        this.showQBWebhook = true;
    }

    getConfiguration () {
        this.showLoading = true;
        getSetupConfiguration({}).
        then((result) => {
            if (result) {
            this.setupConfig = result;
            this.consumerKey = result.clientId;
            this.consumerSecret = result.clientSecret;
            this.environmentValue = result.envType;
            this.verifierToken = result.verifierToken;
            this.disableInput = Boolean(this.consumerKey &&
                this.consumerSecret &&
                this.environmentValue);

            if (result.webhookKey) {
                this.disableWebhookInput = true;
                this.webhookKey = result.webhookKey;
            }
            this.showLoading = false;
            }
        }).
        catch((error) => {
            this.catchBlockFunc(error);
        });
    }

    catchBlockFunc (error) {
        this.error = error;
        this.showLoading = false;
        this.showToast(
        `Something Went Wrong in Retrieving Data from Database. Error - ${error}`,
        "dismissable",
        "Error",
        "error"
        );
    }

    showInstruction () {
        this.showModal = true;
        this.showPositiveButton = true;
        this.showNegativeButton = false;
        this.positiveButtonLabel = "Close";
    }

    closeModal () {
        this.showModal = false;
    }

    updateValue (event) {
        const {name, value} = event.target;

        if (name === "Client ID") {
        this.consumerKey = value.trim();
        } else if (name === "Client Secret") {
        this.consumerSecret = value.trim();
        } else if (name === "Environment") {
        this.environmentValue = value;
        }
        this.disableSaveBtn = !(
        this.consumerKey &&
        this.consumerSecret &&
        this.environmentValue
        );
    }
    onchangeVerifierToken(event){        
        this.verifierToken = event.target.value;
        this.disableSyncSave = false;
    }

    handleReset () {
        this.disableReset = false;
        this.disableInput = false;
        this.disableSave = true;
        this.consumerKey = "";
        this.environmentValue = "";
        this.consumerSecret = "";
        this.showLoading = false;
    }

    handleSave () {
        this.showLoading = true;

        if (this.consumerKey && this.consumerSecret && this.environmentValue) {
        this.authProviderCreation();
        } else {
        this.showToast(
            "",
            "dismissable",
            "Enter valid value for Client Id, Client Secret and Environment Type",
            "error"
        );
        }
        this.showLoading = false;
    }

    authProviderCreation () {
        this.showLoading = true;
        createAuthProvider({
        "clientId": this.consumerKey,
        "clientSecret": this.consumerSecret,
        "connectionStep": 4,
        "environmentValue": this.environmentValue,
        "progressValue": 100,
        "redirectUrl": this.redirectUrl,
        "totalConnectionStep": 4
        }).
        then((result) => {
            if (result) {
            const redirectUrlToVFP = `${result}/apex/QuickBookOAuthRedirectPage`;
            if (typeof window !== "undefined") {
                window.close();
                window.open(redirectUrlToVFP);
            }
            }
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
            this.showToast(
            `Something Went Wrong in Retrieving Data from Database. Error - ${error}`,
            "dismissable",
            "Error",
            "error"
            );
        });
    }

    handleWebReset () {
        this.disableStepSave = true;
        this.disableWebhookInput = false;
        this.showWebhookSteps = true;
        this.showWebhook = false;
        this.siteVal = "";
        this.siteSecureURL = "";
        this.showLoading = true;

        getSites({}).
        then((result) => {
            if (result.length > ZERO) {
            this.siteDetails = result;
            this.siteOptions = result.map((element) => ({
                "label": element.masterLabel,
                "value": element.id
            }));
            }
            this.getSitesConfigURL();
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
        });
    }

    getSitesConfigURL () {
        this.showLoading = true;
        getSitesConfigURL({"entity": "Sites"}).
        then((result) => {
            if (result) {
            this.sitesURL = result;
            }
            this.getRedirectURL();
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
            this.showToast(
            `Something Went Wrong in Retrieving Data from Database. Error - ${error}`,
            "dismissable",
            "Error",
            "error"
            );
        });
    }

    getRedirectURL () {
        this.showLoading = true;
        getSitesConfigURL({"entity": "VFURL"}).
        then((result) => {
            if (result) {
            this.redirectURL = result;
            }
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
            this.showToast(
            `Something Went Wrong. Error - ${error}`,
            "dismissable",
            "Error",
            "error"
            );
        });
    }

    openSites () {
        const url = this.sitesURL;
        if (typeof window !== "undefined") {
        window.open(
            url,
            "_blank"
        );
        }
    }

    fetchSecureURL (event) {
        this.showLoading = true;
        this.siteVal = event.target.value;
        
        if (this.siteVal) {
        this.disableStepSave = false;
        }

        this.siteId = this.siteVal;
        const selectedSite = this.siteDetails.find((element) => element.id === event.target.value);
        this.guestUserId = selectedSite?.guestUserId;

        getSecureSiteURL({"siteId": event.target.value}).
        then((result) => {
            if (result) {
            this.siteSecureURL = result;
            this.setupConfig.syncSite = this.siteId;
            this.setupConfig.webhookKey = this.siteSecureURL;
            this.webhookKey = this.siteSecureURL;
            this.disableSyncSave = false;
            } else {
            this.showToast(
                "Something Went Wrong",
                "dismissable",
                "Error",
                "error"
            );
            }
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
            this.showToast(
            `Something Went Wrong. Error - ${error}`,
            "dismissable",
            "Error",
            "error"
            );
        });
    }

    getAllSites () {
        this.showLoading = true;

        getSites({}).
        then((result) => {
            if (result.length > ZERO) {
            this.siteDetails = result;
            this.siteOptions = result.map((element) => ({
                "label": element.masterLabel,
                "value": element.id
            }));
            } else {
            this.showSiteCreation = true;
            }

            this.getSitesConfigURL();
            this.showLoading = false;
        }).
        catch((error) => {
            this.error = error;
            this.showLoading = false;
            this.showToast(
            `Something Went Wrong in Retrieving Data from Database. Error - ${error}`,
            "dismissable",
            "Error",
            "error"
            );
        });
    }

    handleWebhookSave () {
        if(typeof this.siteSecureURL === 'undefined'  || this.siteSecureURL === '' || this.siteSecureURL === null){
            this.showToast('Please Select Site.','dismissable','Sync Quickbook with Salesforce','error');
        }else if(typeof this.verifierToken === 'undefined' || this.verifierToken == '' || this.verifierToken == null){
            this.showToast('Please enter Verifier Token.','dismissable','Sync Quickbook with Salesforce','error');
        }else{

            this.showLoading = true;
            this.setupConfig.verifierToken = this.verifierToken;
            saveQbToSf({
                setupConfig: JSON.stringify(this.setupConfig)
            }).
            then(() => {
                this.showWebhookSteps  = false;
                this.disableWebhookInput = true;
                this.showToast(
                "Webhook Configuration Saved Successfully",
                "dismissable",
                "Success",
                "success"
                );
                this.showLoading = false;
            }).
            catch((error) => {
                this.error = error;
                this.showLoading = false;
                this.showToast(
                `Something Went Wrong. Error - ${error}`,
                "dismissable",
                "Error",
                "error"
                );
            });
        }
    }

    showToast (message, mode, title, variant) {
        if (!import.meta.env.SSR) {
        this.dispatchEvent(new ShowToastEvent({
            message,
            title,
            mode,
            variant
        }));
        }
        
    }
}