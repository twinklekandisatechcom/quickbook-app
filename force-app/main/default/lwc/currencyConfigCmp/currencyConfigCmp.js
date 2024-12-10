import {LightningElement, track} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import createQBCurrencies from "@salesforce/apex/CurrencyConfigController.createQBCurrencies";
import getCurrency from "@salesforce/apex/CurrencyConfigController.getCurrency";
import getCurrencyURL from "@salesforce/apex/CurrencyConfigController.getCurrencyURL";
import getIsMultiCurrencyOrg from "@salesforce/apex/Utils.getIsMultiCurrencyOrg";
import refreshToken from "@salesforce/apex/QuickBooksIntegerationController.refreshToken";
import syncQbInvoiceObject from "@salesforce/apex/QbMetaDataController.syncQbInvoiceObject";
const THREE = 3,
    ZERO = 0;

export default class CurrencyConfigCmp extends LightningElement {

    @track isMultiCurrencyOrg;

    @track QBCurr = [];

    @track salesforceCurr = [];

    @track currencyURL = "";

    @track currencyObj = [];

    @track showPositiveButton = true;

    @track showNegativeButton = false;

    @track positiveButtonLabel = "";

    @track showModal = false;

    @track showLoading = false;

    @track showCurr = false;

    btnValueRef;

    newBtnValueRef;

    positionRef;

    connectedCallback () {

        this.getIsMultiCurrencyOrg();

    }

    getIsMultiCurrencyOrg () {
      
        this.showLoading = true;
        getIsMultiCurrencyOrg({}).then((result) => {
          
            this.isMultiCurrencyOrg = result;
            this.showLoading = false;
            this.getCurrency();
          
        }).catch((error) => {
          
            this.error = error;
            this.showLoading = false;
            this.showToast(error,
                "dismissable",
                "Something Went Wrong",
                "error");
          
        });
      
    }

    getCurrency () {
      
        this.showLoading = true;
        this.currencyObj = [];
        getCurrency({}).then((result) => {
          
            if (result) {
              
                this.salesforceCurr = result.salesforceCurr;
                console.log('this.salesforceCurr = ',this.salesforceCurr);
                this.QBCurr = result.qBCurr;
                this.salesforceCurr.forEach((element) => {
                  
                    if (this.QBCurr.includes(element)) {
                      
                        this.currencyObj.push({"QBCurr": element,
                            "btnValue": `${element}-${element}`,
                            "salesCurr": element,
                            "syncBtn": true});
                      
                    } else {
                      
                        this.currencyObj.push({"QBCurr": "-",
                            "btnValue": `${element}-`,
                            "salesCurr": element,
                            "syncBtn": false});
                      
                    }
                  
                });
                this.QBCurr.forEach((element) => {
                  
                    if (!this.salesforceCurr.includes(element)) {
                      
                        this.currencyObj.push({"QBCurr": element,
                            "btnValue": `-${element}`,
                            "salesCurr": "-",
                            "syncBtn": false});
                      
                    }
                  
                });
                if (this.currencyObj.length > ZERO) {
                  
                    this.showCurr = true;
                  
                } else {
                  
                    this.showCurr = false;
                  
                }
                this.showLoading = false;
                this.getCurrencyURL();
              
            }
          
        }).catch((error) => {
            console.log('error = ',error);
            this.error = error;
            this.showLoading = false;
            this.showToast(error,
                "dismissable",
                "Something Went Wrong",
                "error");
          
        });
      
    }

    getCurrencyURL () {
      
        this.showLoading = true;
        getCurrencyURL({}).then((result) => {
          
            if (result.length > ZERO) {
              
                this.currencyURL = result;
                this.showLoading = false;
              
            }
          
        }).catch((error) => {
          
            this.showToast(error,
                "dismissable",
                "Something Went Wrong",
                "error");
            this.showLoading = false;
          
        });
      
    }

    refreshToken (clsName) {
      
        refreshToken({}).then(() => {
          
            if (clsName === "syncQbInvoiceObject") {
              
                this.syncQbInvoiceObject();
              
            } else if (clsName === "handleSync") {
              
                this.handleSync();
              
            }
          
        }).catch((error) => {
          
            this.showSpinner = false;
            this.showToastMessage("error",
                error.body.message);
          
        });
      
    }

    syncQbInvoiceObject () {
      
        this.showLoading = true;
        syncQbInvoiceObject({"type": "CompanyCurrency"}).then((result) => {
          
            if (result === "success") {
              
                this.getCurrency();
                this.showLoading = false;
              
            } else if (result === "Check Quickbook Connection to Salesforce") {
              
                this.refreshToken("syncQbInvoiceObject");
              
            }
          
        }).catch((error) => {
          
            this.showToast(error,
                "dismissable",
                "Something Went Wrong",
                "error");
            this.showLoading = false;
          
        });
      
    }

    OpenCurrencyLayout () {
      
        const url = this.currencyURL;
        window.open(url,
            "_blank");
      
    }

    handleSync (event) {
        this.showLoading = true;
        let btnValue = "",
            newBtnValue = "",
            position = "";
        if (typeof event === "undefined") {
          
            btnValue = this.btnValueRef;
            newBtnValue = this.newBtnValueRef;
            position = this.positionRef;
          
        } else {
          
            btnValue = event.target.value;
            newBtnValue = btnValue.replace("-",
                "");
            position = btnValue.indexOf("-");
          
        }
        if (position === THREE) {
          
            createQBCurrencies({"qBCurrTobeCreated": newBtnValue}).then((result) => {
              
                if (result === "QuickBook currency created succesfully.") {
                  
                    this.getCurrency();
                    this.showToast("Currency added in Quickbook.",
                        "dismissable",
                        "Success",
                        "success");
                  
                } else if (result === "") {
                  
                    this.showToast(result,
                        "dismissable",
                        "Error",
                        "error");
                  
                } else if (result === "Check Quickbook Connection to Salesforce") {
                  
                    this.btnValueRef = btnValue;
                    this.newBtnValueRef = newBtnValue;
                    this.positionRef = position;
                    this.refreshToken("createQBCurrencies");
                  
                } else {
                  
                    this.showToast("Error while adding currency in Quickbook.",
                        "dismissable",
                        "Error",
                        "error");
                  
                }
                this.showCurr = true;
                this.showLoading = false;
              
            }).catch((error) => {
              
                this.showToast(error,
                    "dismissable",
                    "Error while creating currency in Quickbook.",
                    "error");
                this.showLoading = false;
                this.showCurr = false;
              
            });
          
        } else if (position === ZERO) {
          
            this.showInstruction();
            this.showLoading = false;
          
        }
      
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