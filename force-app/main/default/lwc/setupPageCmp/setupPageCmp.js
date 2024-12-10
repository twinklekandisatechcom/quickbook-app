import {LightningElement, track} from "lwc";
import FORM_FACTOR from "@salesforce/client/formFactor";
import HideLightningHeader from "@salesforce/resourceUrl/noHeader";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getSetupConfiguration from "@salesforce/apex/SetupConfigController.getSetupConfiguration";
import {loadStyle} from "lightning/platformResourceLoader";
import qbLogo from "@salesforce/resourceUrl/qbLogo";

const FOURCOMPLETEDSTEPS = 4;

export default class SetupPageCmp extends LightningElement {

    qbLogo = qbLogo;

    @track showLoading = false; 

    @track setup_config_cmp = true;

    @track invoice_configuration_cmp = false;

    @track currency_configuration_cmp = false;

    @track contact_configuration_cmp = false;

    @track product_config_cmp = false;

    @track permission_set_cmp = false;

    @track troubleshooting_cmp = false;

    @track help_support_cmp = false;

    @track disableTab = true;

    get isDesktop () {

        return FORM_FACTOR === "Large";

    }

    get isMobile () {

        return FORM_FACTOR === "Small";

    }

    get isTablet () {

        return FORM_FACTOR === "Medium";

    }

    connectedCallback () {

        this.showLoading = false;
        if (typeof window !== 'undefined') {
            document.title = "Quickbook Setup | Salesforce";
        }
        this.getConfiguration();

    }

    getConfiguration () {

        getSetupConfiguration({}).
            then((result) => {

                if (result) {

                    if (result.completedSteps === FOURCOMPLETEDSTEPS) {

                        this.disableTab = false;

                    }

                }

            }).
            catch((error) => {

                this.showToast(
                    "Something Went Wrong",
                    error,
                    "error",
                    "dismissable"
                );

            });

    }

    setDefault () {

        this.setup_config_cmp = false;
        this.invoice_configuration_cmp = false;
        this.currency_configuration_cmp = false;
        this.contact_configuration_cmp = false;
        this.product_config_cmp = false;
        this.permission_set_cmp = false;
        this.troubleshooting_cmp = false;
        this.help_support_cmp = false;
        this.organization_setail_cmp = false;

    }

    handleSelect (event) {

        this.getConfiguration();
        this.setDefault();
    
                if (event.detail.name === "setup_config_cmp") {

                    this.setup_config_cmp = true;

                } else if (event.detail.name === "invoice_configuration_cmp") {

                    if (this.disableTab === false) {

                        this.invoice_configuration_cmp = true;

                    } else {

                        this.showErrorMessage("Invoice Configuration is disable");

                    }

                } else if (event.detail.name === "currency_configuration_cmp") {

                    if (this.disableTab === false) {

                        this.currency_configuration_cmp = true;

                    } else {

                        this.showErrorMessage("Currency Configuration is disable");

                    }

                } else if (event.detail.name === "contact_configuration_cmp") {

                    if (this.disableTab === false) {

                        this.contact_configuration_cmp = true;

                    } else {

                        this.showErrorMessage("Contact Configuration is disable");

                    }

                } else if (event.detail.name === "product_config_cmp") {

                    if (this.disableTab === false) {

                        this.product_config_cmp = true;

                    } else {

                        this.showErrorMessage("Product Configuration is disable");

                    }

                } else if (event.detail.name === "permission_set_cmp") {

                    if (this.disableTab === false) {

                        this.permission_set_cmp = true;

                    } else {

                        this.showErrorMessage("Permission Set is disable");

                    }

                } else if (event.detail.name === "troubleshooting_cmp") {

                    if (this.disableTab === false) {

                        this.troubleshooting_cmp = true;

                    } else {

                        this.showErrorMessage("Troubleshooting is disable");

                    }

                } else if (event.detail.name === "help_support_cmp") {

                    this.help_support_cmp = true;

                }

    }

    handleEnabledTabs (event) {

        this.disableTab = event.detail;

    }

    handleConnectionTab (event) {

        if (event.detail) {

            this.setup_config_cmp = false;
            this.troubleshooting_cmp = true;

        }

    }

    handlePermissionTab (event) {

        if (event.detail) {

            this.setup_config_cmp = false;
            this.permission_set_cmp = true;

        }

    }

    renderedCallback () {

        Promise.all([
            loadStyle(
                this,
                HideLightningHeader
            )
        ]).then(() => {
            /* Empty */
        }).catch((error) => {

            this.error = error;
            this.showLoading = false;
            this.showToast(
                "Something Went Wrong in Loading 'noHeader' .",
                error,
                "error",
                "dismissable"
            );

        });

    }

    showErrorMessage (title) {

        const message = "Please complete all 'Setup And Configuration' steps first.",
            mode = "dismissable",
            variant = "error";
        this.dispatchEvent(new ShowToastEvent({message,
            mode,
            title,
            variant}));

    }

    showToast (msg, mod, tle, vrt) {

        if (typeof window !== 'undefined') {

            const evt = new ShowToastEvent({
                "message": msg,
                "mode": mod,
                "title": tle,
                "variant": vrt
            });
            this.dispatchEvent(evt);

        }

    }

}