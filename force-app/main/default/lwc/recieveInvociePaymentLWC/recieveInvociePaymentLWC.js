import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { LightningElement, api, track,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUpdateSFQbPayment from '@salesforce/apex/InvoiceSyncControllerDynamic.createUpdateSFQbPayment';
import FORM_FACTOR from '@salesforce/client/formFactor';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';

const ZERO_NUM = 0,
 //TIMEOUT_NUM_300 = 300,
 TIMEOUT_NUM_500 = 500;
 //TIMEOUT_NUM_1000 = 1000;

export default class RecieveInvociePaymentLWC extends LightningElement {
    
    invoiceName = '' ;
    invoiceCustomerName = '' ;
    invoiceCurrencyCode = '' ;
    invoiceAmount = ZERO_NUM ;
    invoiceBalance = ZERO_NUM;
    @track transactionId;
    @track transactionDate;
    @track transactionAmountPaid;
    paymentMethod='';
    @track paymentMethodOptions=[];
    _recordId;
    hasRendered=false;
    showSpinner=false;
    isAllInputsValid = false;
    displayComponent = true;
    isLargeDeviceType=true;
    currentPagePathName='';

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if(!this.hasRendered){
            let paymentReqObject = {
                "invoiceId" : this._recordId,
                "isPayed" : false
            };
            let textParamReq = JSON.stringify(paymentReqObject);
            
            createUpdateSFQbPayment({"wrapperReqText" : textParamReq})
            .then((response)=>{
                let data = JSON.parse(response);

                if(data.status == 'Failed' && data.message){
                    this.closeQuickAction();
                    this.showToast('Quickbook Payment',data.message,'error');
                }else{

                    if(data.invoiceName){ 
                        this.invoiceName = data.invoiceName;
                    }if(data.invoiceCurrencyCode){ 
                        this.invoiceCurrencyCode = data.invoiceCurrencyCode;
                    }if(data.invoiceBalance){ 
                        this.invoiceBalance = data.invoiceBalance;
                    }if(data.invoiceAmount){ 
                        this.invoiceAmount = data.invoiceAmount;
                    }if(data.invoiceCustomerName){ 
                        this.invoiceCustomerName = data.invoiceCustomerName;
                    }else{
                        this.showToast('Quickbook Payment',`The Customer Name could not be displayed, as there's no customer associated with this invoice`,'warning');
                    }
                    
                    if(data.mapPaymentMethod){ 
                        let paymentMethodArr = [];
                        for (let k in data.mapPaymentMethod) {
                        if(data.mapPaymentMethod[k] && k){
                            paymentMethodArr.push(
                                { "label": data.mapPaymentMethod[k] , "value": k }
                            );
                        }
                        }
                        this.paymentMethodOptions = Array.from(paymentMethodArr);
                    }
                }
            }).catch((error)=>{
                console.log('### error from server ::: '+JSON.stringify(error));
            });
            this.hasRendered = true;
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.currentPagePathName = currentPageReference.state.backgroundContext;
        }
    }

    connectedCallback(){
    if (FORM_FACTOR === "Large") {
            this.isLargeDeviceType=true;
        } else if (FORM_FACTOR === "Medium" || FORM_FACTOR === "Small") {
            this.isLargeDeviceType=false;
        }
    }

    renderedCallback(){
        if(!this.displayComponent){
            this.displayComponent = true;
            if(this.showSpinner){
                this.showSpinner=false;
            }
        }
    }
    
    inputHandler(event){ 
        let dataSetName = event.currentTarget.dataset.inputname;
        let inputValue = event.target.value;
        clearTimeout(this.inputTimeOut);
        this.inputTimeOut =  setTimeout(() => {
            switch(dataSetName) {
                case 'TransactionId':
                    this.transactionId = inputValue.trim();
                    
                    break;
                case 'TransactionDate':
                    this.transactionDate = inputValue;
                    
                    break;
                case 'TransactionAmountPaid':
                    this.transactionAmountPaid = inputValue;
                    
                    break;    
                case 'PaymentMethod':
                    this.paymentMethod = inputValue;
                    
                    break;    
                default:
                    break;
                }

                let targetElement = this.template.querySelector(`[data-inputname=${dataSetName}]`);
                if(targetElement.value) {
                    targetElement.setCustomValidity('');
                }
                targetElement.reportValidity();
        }, TIMEOUT_NUM_500);
    }

    paymentHandler(){
        this.showSpinner = true;
        this.validateAllInputHelper();
        if(this.isAllInputsValid){
            let paymentReqObject = {
                "transactionId" : this.transactionId,
                "transactionAmountPaid" : this.transactionAmountPaid,
                "transactionDate"  : this.transactionDate,
                "paymentMethod" : this.paymentMethod,
                "invoiceId" : this._recordId,
                "isPayed" : true
            }
            let textParamReq = JSON.stringify(paymentReqObject);
            if(this.invoiceBalance >0){
            createUpdateSFQbPayment({"wrapperReqText" : textParamReq})
                .then((response)=>{
                    
                    let respObj = JSON.parse(response);
                    if(respObj.status && respObj.message){
                        this.showSpinner = false;
                        if(respObj.status === 'Success'){
                            this.showToast('Quickbook Payment',respObj.message,'success');
                            //setTimeout(() => { 
                                window.open(this.currentPagePathName, "_self");
                            //}, TIMEOUT_NUM_1000);
                        }else if(respObj.status === 'Failed'){
                            if(respObj.message.includes('####')){
                                const myArray = respObj.message.split("####");
                                myArray.pop();
                                myArray.forEach(resp => {
                                    //setTimeout(() => {
                                        this.showToast('Quickbook Payment',resp.replace('####','.'),'error','sticky');
                                    //},TIMEOUT_NUM_300);
                                });
                                this.closeQuickAction();
                            }else if(respObj.isConnectionError === true){
                                this.handleAlert('Please go to the SetupPage and complete all connection steps.','Incomplete Connection Setup');    
                            }else{
                                this.showToast('Quickbook Payment',respObj.message,'error');
                                this.closeQuickAction();
                            }
                        }
                    }
                }).catch((error)=>{
                    this.showSpinner = false;
                    this.closeQuickAction();
                    this.showToast('Quickbook Payment',`The Payment record failed to be created in Quickbooks' , [ ${error.message} ]`,'error');
                });
            }else{
                this.handleInvoicePaidAlert('The invoice shows a zero balance, confirming that it has already been paid.','Invoice has already been paid!');
            }
        }
    }
    
    clearHandler(){
        this.transactionId='';
        this.transactionDate='';
        this.transactionAmountPaid='';
        this.paymentMethod='';
        this.showSpinner=true;
        //setTimeout(() => {
            this.displayComponent=false;
        //}, TIMEOUT_NUM_300);
    }
    
    validateAllInputHelper(){
        let isAllElementValid = true; 
        [
            ...this.template.querySelectorAll(`[data-inputname]`),
        ].forEach(inputCmp => {
            let validationMsg =`the ${inputCmp.label.toLowerCase()}.`; 
            let inputValue = inputCmp.value.trim();
            if (!inputValue) {
                
                if(inputCmp.dataset.inputname === 'PaymentMethod'){
                    inputCmp.setCustomValidity(`Please select ${validationMsg}`);
                }else{
                    inputCmp.setCustomValidity(`Please enter ${validationMsg}`);
                }
            }else {
                inputCmp.setCustomValidity('');
            }  
            inputCmp.reportValidity();
            isAllElementValid = isAllElementValid && inputCmp.checkValidity()? true : false;
        });

        this.isAllInputsValid = isAllElementValid;
        if(!this.isAllInputsValid){
            this.showSpinner = false;
        }
        
    }

    showToast(toastTitle,toastMessage,toastVariant,toastMode) {

        if (typeof window !== 'undefined') {

            const event = new ShowToastEvent({
                "title": toastTitle,
                "message":toastMessage,
                "variant":toastVariant,
                "mode":toastMode
            });
            this.dispatchEvent(event);

        }

    }

    closeQuickAction() {
        if (typeof window !== 'undefined') {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        
    }

    /*async handleAlert(msg, lbl) {
        const result = await LightningConfirm.open({
                        label: lbl,
                        message: msg,
                        theme: "error"
                    });

        if(result==true){
            this[NavigationMixin.Navigate]({
                attributes: {
                    apiName:'KTQB__QuickBooks_Setup'
                },
                type: 'standard__navItemPage'
            });
        }else{
            this.closeQuickAction();
        }
    }

    async handleInvoicePaidAlert(msg, lbl) {
        await LightningAlert.open({
            message: msg,
            theme: 'error', 
            label: lbl
        });
        this.closeQuickAction();
    }*/

    handleAlert(msg, lbl) {
        LightningConfirm.open({
            label: lbl,
            message: msg,
            theme: "error"
        })
        .then((result) => {
            if (result === true) {
                this[NavigationMixin.Navigate]({
                    attributes: {
                        apiName: 'KTQB__QuickBooks_Setup'
                    },
                    type: 'standard__navItemPage'
                });
            } else {
                this.closeQuickAction();
            }
        })
        .catch((error) => {
            console.error("Error handling alert:", error);
        });
    }
        
    handleInvoicePaidAlert(msg, lbl) {
        LightningAlert.open({
            message: msg,
            theme: 'error', 
            label: lbl
        })
        .then(() => {
            this.closeQuickAction();
        })
        .catch((error) => {
            console.error("Error showing invoice paid alert:", error);
        });
    }
    
}