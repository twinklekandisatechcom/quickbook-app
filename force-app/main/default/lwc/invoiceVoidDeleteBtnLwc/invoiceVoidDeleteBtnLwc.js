import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import { LightningElement,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUpdateInvSfToQB from '@salesforce/apex/InvoiceSyncControllerDynamic.createUpdateInvSfToQB';
/*const TIMEOUT_NUM_300 = 300,
      TIMEOUT_NUM_1000 = 1000;*/

export default class InvoiceVoidDeleteBtnLwc extends NavigationMixin(LightningElement) {
    @api objectApiName;
    recordId;
    showSpinner = false;
    displayMessageTxt='Do you want to Void or Delete Quickbook Invoice ?';
    calloutOperation = '';
    voidInvoiceBtnName='Void';
    deleteInvoiceBtnName='Delete';
    currentPagePathName = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.currentPagePathName = currentPageReference.state.backgroundContext;
        }
    }

// Method : When Delete Button is clicked.
    invoiceDeleteHandler(){
        this.showToast('Invoice Delete','Cannot Delete Invoice from Salesforce. Delete Invoice directly from Quickbooks.','error');
        this.closeQuickAction();
        this.showSpinner = false;
    }

// Method : When Void Button is clicked.
    processBtnHandler(){
        this.calloutOperation = 'void';
        if(this.recordId && this.calloutOperation){
            this.processDelVoidOperation();
        }
    }

// Helper Method : When Cmp rendered 1st time, returns the Invoice Object as string and for 2nd time i.e. when invoked from button returns the Status and Response of the Api Callout made.
    processDelVoidOperation(){
        this.showSpinner = true;
        createUpdateInvSfToQB({"qbInvoiceId" : this.recordId,"operation" : this.calloutOperation})
            .then(response=>{
                console.log('response = '+response);
                
                let respObj = response;
                if(respObj.status && respObj.message){
                    this.showSpinner = false;
                    if(respObj.status === 'Success'){
                        // this.reloadPage();
                        this.showToast('Invoice Void',respObj.message,'success');
                        //setTimeout(() => {
                            // window.open(`https://qbktdev-dev-ed.develop.lightning.force.com/lightning/r/QB_Invoice__c/${this.recordId}/view`, "_self"); 
                            if (typeof window !== 'undefined') {
                                window.open(this.currentPagePathName, "_self"); 
                            }
                       // }, TIMEOUT_NUM_1000);
                    }else if(respObj.status === 'Failed'){
                        if(respObj.message.includes('####')){
                            const myArray = respObj.message.split("####");
                            myArray.pop();
                            myArray.forEach(resp => {
                                //setTimeout(() => {
                                    this.showToast('Invoice Void',resp.replace('####','.'),'error','sticky');
                                //},TIMEOUT_NUM_300);
                            });
                            this.closeQuickAction();
                        }else if(respObj.isConnectionError === true){
                            this.handleAlert('Please go to the SetupPage and complete all connection steps.','Incomplete Connection Setup');
                        }else{
                            this.showToast('Invoice Void',respObj.message,'error');
                            this.closeQuickAction();
                        }
                    }
                }
            }).catch(error=>{
                this.showSpinner = false;
                this.showToast('Invoice Void',`The Invoice Record Failed to ${this.calloutOperation} in Quickbooks' , [ ${error.message} ]`,'error');
                this.closeQuickAction();
            });
    }

// Helper Method : Show Pop Notfication and Second one closing the Quick Action.
    showToast(toastTitle,toastMessage,toastVariant,toastMode) {

        if (typeof window !== 'undefined') {

            const event = new ShowToastEvent({
                "title": 'Invoice Delete/Void',
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

    handleAlert(msg, lbl) {
        LightningConfirm.open({
            label: lbl,
            message: msg,
            theme: "error"
        }).then(() =>{
            this[NavigationMixin.Navigate]({
                attributes: {
                    apiName:'KTQB__QuickBooks_Setup'
                },
                type: 'standard__navItemPage'
            });
        }).catch(() =>{
            this.closeQuickAction();
        })
    }

    // reloadPage(){
    //     this.showSpinner = true;
    //     setTimeout(() => {
    //         this.showSpinner = false;
    //     }, TIMEOUT_NUM_1000);
    //     const pageReference = {
    //         attributes: {
    //             actionName: 'view',
    //             objectApiName: this.objectApiName,
    //             recordId: this.recordId
    //         },
    //         type: 'standard__recordPage',
    //     };
    //     this[NavigationMixin.Navigate](pageReference);
    // }

}