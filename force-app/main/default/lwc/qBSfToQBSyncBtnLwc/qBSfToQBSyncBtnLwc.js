import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { LightningElement, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUpdateInvSfToQB from '@salesforce/apex/InvoiceSyncControllerDynamic.createUpdateInvSfToQB';
import LightningConfirm from 'lightning/confirm';
/*const THOUSAND = 1000,
      TWOHUNDRED = 200;*/

export default class QBSfToQBSyncBtnLwc extends NavigationMixin(LightningElement) {
    recordId;
    showSpinner = true;
    operation = 'CreateOrUpdate';
    currentPagePathName = '';
  
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.currentPagePathName = currentPageReference.state.backgroundContext;
        }
    }
    connectedCallback(){
        if(this.recordId){
            createUpdateInvSfToQB({ operation : this.operation, qbInvoiceId: this.recordId })
                .then(response => {
                    this.handleCalloutResponse(response,false);
                }).catch(error => {
                    this.handleCalloutResponse(error,true);
            });
        }
    }
    
    handleCalloutResponse(data, isError) {
        if(data){
            if (data.status && data.message) {
                this.showSpinner = false;
                
                if(data.status === 'Success'){
                    this.showToast('Invoiced Sync', data.message, 'success');
                    //setTimeout(() => {
                        if (typeof window !== 'undefined') {
                            window.open(this.currentPagePathName, "_self"); 
                        }
                    //}, THOUSAND);
                }else if(data.status === 'Failed') {
                    if(data.message.includes('####')){
                        const myArray = data.message.split("####");
                        myArray.pop();
                        myArray.forEach(resp => {
                            //setTimeout(() => {
                                this.showToast('Invoice Sync',resp.replace('####','.'),'error','sticky');
                            //},TWOHUNDRED);
                        });
                        this.closeQuickAction();
                    }else if(data.isConnectionError === true){
                        this.handleAlert('Please go to the SetupPage and complete all connection steps.','Incomplete Connection Setup');    
                    }else{
                        this.showToast('Invoice Sync',data.message,'error');
                        this.closeQuickAction();
                    }
                }
            }
        }else if(isError){
            this.showSpinner = false;
            this.showToast('Invoiced Sync', `Invoiced Synced from Quickbooks Failed , [ ${data.message} ]`, 'error');
            this.closeQuickAction();
        }
    }
        
    showToast(toastTitle,toastMessage,toastVariant,toastMode) {

        if (typeof window !== 'undefined') {

            const event = new ShowToastEvent({
                message:toastMessage,
                mode:toastMode,
                title: toastTitle,
                variant:toastVariant
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
}