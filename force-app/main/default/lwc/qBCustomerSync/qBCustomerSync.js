import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import { LightningElement,wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomerFieldsNConfiguration from '@salesforce/apex/InvoiceConfigurationController.getCustomerFieldsNConfiguration';
import getCustomerOjectApiName from '@salesforce/apex/CustomerSyncController.getCustomerOjectApiName';
import getCustomerUsingObjectName from '@salesforce/apex/CustomerSyncController.getCustomerUsingObjectName';
import getQBCustomer from '@salesforce/apex/CustomerSyncController.getQBCustomer';
import getSetupConfiguration from '@salesforce/apex/SetupConfigController.getSetupConfiguration';
import insertCustomer from '@salesforce/apex/InvoiceController.insertCustomer';
import refreshToken from '@salesforce/apex/QuickBooksIntegerationController.refreshToken';
import updateCustomerInSF from '@salesforce/apex/CustomerSyncController.updateCustomerInSF';

const FOUR = 4,
      ONE = 1,
      THREE = 3,
      TWO = 2,
      ZERO = 0;
      
export default class QBCustomerSync extends NavigationMixin(LightningElement) {
    recordId;
    showSpinner =false;
    customerFields;
    customerData = [];
    customerObjectName;
    customerQBId = '';
    syncToken='';
    syncTokenFieldName='';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback(){
        this.showSpinner = true;
        this.getConnection();
    }
    getConnection(){
        getSetupConfiguration({})
        .then(result => {
            if(result && Object.keys(result).length > ZERO){
                if((result.completedSteps === ONE || result.completedSteps === FOUR) && (result.accessToken === '' || result.accessToken === null || typeof result.accessToken ===  'undefined')){
                      this.handleAlert('Unable to establish connection. Please troubleshoot the connection issue on the Setup Page.','QuickBooks - Salesforce Authorization Problem')
              }else if(result.completedSteps === TWO || result.completedSteps === THREE || result.completedSteps === ONE){
                  this.handleAlert('Please go to the Setup Page and complete all connection steps.','Incomplete Connection Setup')
              }else if(result.completedSteps === ZERO && (result.accessToken === '' || result.accessToken === null || typeof result.accessToken === 'undefined')){
                  this.handleAlert('Please go to the Setup Page and establish the connection.','Connection Not Established')
              }
              else{
                  this.getCustomerApiNameFunc();
              }
            }else{
              this.handleAlert('Please go to the Setup Page and establish the connection.','Connection Not Established')
            }
           

        })
        .catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
        })
    }
    getCustomerApiNameFunc(){
        getCustomerOjectApiName({recId : this.recordId}).then(result => {
            if(result === '' || result === null){
                this.handleAlert('Invoice Customer Object and Fields is not mapped. Please navigate to the Setup Page, go to Invoice Configuration, and map the object and fields for the Invoice Customer.','Error');
            }else if(result === 'fail'){
                this.handleAlert('Incorrect object selection for syncing customers. Please choose a valid object.','Error');
            }else{
                this.customerObjectName = result;
                this.getCustomerMapFields(result);
            }
        }).catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
        });
    }
    getCustomerMapFields(){
        getCustomerFieldsNConfiguration({customerObjectName:this.customerObjectName}).then(result => {
            if(result){
                this.customerFields = result.invoiceField.filter(entry => entry.value !== null && typeof entry.value !== 'undefined');
                if (this.customerFields === null || this.customerFields.length === ZERO) {
                    this.handleAlert('Invoice Customer Fields are not mapped. Please navigate to the Setup Page, go to Invoice Configuration, and map fields for the Invoice Customer.','Error');
                }else {
                    this.getCustomerRecord();
                }
            }
           
        }).catch(error => {
            console.log('error getCustomerFieldsNConfiguration = ',error);
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
        });
    }
    getCustomerRecord(){
        getCustomerUsingObjectName({objectName:this.customerObjectName, recordId:this.recordId}).then(result => {
            if(result){
                console.log('OUTPUT result: ',result);
                this.sfCustomerData = result;
                this.customerData = this.customerFields.map(field => {
                    if (field.name === 'QB Customer Id' && (result[field.value] === null || typeof result[field.value] === 'undefined' || result[field.value] === '')) {
                        this.customerQBId = '';
                    }else if(field.name === 'QB Customer Id' && (result[field.value] !== null || typeof result[field.value] !== 'undefined' || result[field.value] !== '')){
                        this.customerQBId = result[field.value];
                    }
                    if (field.name === 'Qb Customer Sync Token' && (result[field.value] === null || typeof result[field.value] === 'undefined' || result[field.value] === '')) {
                        this.syncToken = '';
                    }else if(field.name === 'Qb Customer Sync Token' && (result[field.value] !== null || typeof result[field.value] !== 'undefined' || result[field.value] !== '')){
                        this.syncToken = result[field.value];
                        
                    }
                    let isBoolean = false;
                    if(field.name === 'Is Taxable'){
                        isBoolean = true;
                    }
                    if(field.name !== 'Qb Customer Sync Token' && field.name !== 'QB Customer Id'){
                        return {
                            fields: field.label,
                            qbData: '',
                            qbfieldName: field.qbFieldName,
                            check: isBoolean,
                            sfData: result[field.value] || ''
                        };
                    }
                    return '';
                });
                if (this.customerQBId === '' || this.customerQBId === null) {
                    this.backBtnHandler();
                    this.handleAlert('Customer QB ID is not present. Unable to sync Customer.','Error');
                }else{
                    this.getQBCustomerData();
                }
                
            }
        }).catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
            console.log('error getCustomerUsingObjectName = ',error);
        });
    }
    refreshToken(clsName){
        refreshToken({})
        .then(() => {
            if(clsName === 'insertCustomer'){
                this.updateCustomerInQb();
            }else if(clsName === 'getQBCustomerData'){
               this.getQBCustomerData();
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
        });
    }
    getQBCustomerData(){
        getQBCustomer({ qbId: this.customerQBId })
        .then(result => {
            if (result) {
                if(typeof result.Fault !== 'undefined'){                    
                    if(result.Fault.Error[ZERO].message === 'message=AuthenticationFailed; errorCode=003200; statusCode=401'){
                        this.refreshToken('getQBCustomerData');
                    }else{                        
                        this.showToastMessage('error',result.Fault.Error[ZERO].Detail);
                        //console.log('error getQBCustomer = ',error);
                        this.backBtnHandler(); 
                    }
                    
                }else if(typeof result.Customer === 'undefined'){
                    this.showToastMessage('error','Something Went Wrong');
                }else{
                    this.customerData.forEach((data, index) => {
                        if (typeof this.customerData[index] === 'object') {
                            if(this.customerFields[index].qbFieldName === 'PrimaryEmailAddr'){
                                if(result.Customer.PrimaryEmailAddr && result.Customer.PrimaryEmailAddr.Address){
                                    this.customerData[index].qbData = result.Customer.PrimaryEmailAddr.Address;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'Fax'){
                                if(result.Customer.Fax && result.Customer.Fax.FreeFormNumber){
                                    this.customerData[index].qbData = result.Customer.Fax.FreeFormNumber;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'Mobile'){
                                if(result.Customer.Mobile && result.Customer.Mobile.FreeFormNumber){
                                    this.customerData[index].qbData = result.Customer.Mobile.FreeFormNumber;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'PrimaryPhone'){
                                if(result.Customer.PrimaryPhone && result.Customer.PrimaryPhone.FreeFormNumber){
                                    this.customerData[index].qbData = result.Customer.PrimaryPhone.FreeFormNumber;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'BillAddrLine'){
                                if(result.Customer.BillAddr && result.Customer.BillAddr.Line1){
                                    this.customerData[index].qbData = result.Customer.BillAddr.Line1;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'BillAddrCity'){
                                if(result.Customer.BillAddr && result.Customer.BillAddr.City){
                                    this.customerData[index].qbData = result.Customer.BillAddr.City;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'BillAddrCountrySubDivisionCode'){
                                if(result.Customer.BillAddr && result.Customer.BillAddr.CountrySubDivisionCode){
                                    this.customerData[index].qbData = result.Customer.BillAddr.CountrySubDivisionCode;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'BillAddrPostalCode'){
                                if(result.Customer.BillAddr && result.Customer.BillAddr.PostalCode){
                                    this.customerData[index].qbData = result.Customer.BillAddr.PostalCode;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'BillAddrCountry'){
                                if(result.Customer.BillAddr && result.Customer.BillAddr.Country){
                                    this.customerData[index].qbData = result.Customer.BillAddr.Country;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'ShipAddrLine'){
                                if(result.Customer.ShipAddr && result.Customer.ShipAddr.Line1){
                                    this.customerData[index].qbData = result.Customer.ShipAddr.Line1;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'ShipAddrCity'){
                                if(result.Customer.ShipAddr && result.Customer.ShipAddr.City){
                                    this.customerData[index].qbData = result.Customer.ShipAddr.City;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'ShipAddrCountry'){
                                if(result.Customer.ShipAddr && result.Customer.ShipAddr.Country){
                                    this.customerData[index].qbData = result.Customer.ShipAddr.Country;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'ShipAddrPostalCode'){
                                if(result.Customer.ShipAddr && result.Customer.ShipAddr.PostalCode){
                                    this.customerData[index].qbData = result.Customer.ShipAddr.PostalCode;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'ShipAddrCountrySubDivisionCode'){
                                if(result.Customer.ShipAddr && result.Customer.ShipAddr.CountrySubDivisionCode){
                                    this.customerData[index].qbData = result.Customer.ShipAddr.CountrySubDivisionCode;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'WebAddrURI'){
                                if(result.Customer.WebAddr && result.Customer.WebAddr.URI){
                                    this.customerData[index].qbData = result.Customer.WebAddr.URI;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else if(this.customerFields[index].qbFieldName === 'IsTaxable'){
                                if(result.Customer.Taxable){
                                    this.customerData[index].qbData = result.Customer.Taxable;
                                }else{
                                    this.customerData[index].qbData = '';
                                }
                            }else{
                                this.customerData[index].qbData = result.Customer[this.customerFields[index].qbFieldName];
                            }
                        }
                    });
                }
            } else {
                this.showToastMessage('error','Something Went Wrong');
                this.backBtnHandler(); 
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
            console.log('getQBCustomer error = ',error);
        });
    }
    handleAlert(msg, lbl) {
        LightningAlert.open({
            label: lbl,
            message: msg,
            theme: "error"
        })
        .then((result) => {
            if (result) {
                // Handle the case where result is true (if needed)
            } else if (msg === 'Customer QB ID is not present. Unable to sync Customer.') {
                this.backBtnHandler();
            } else {
                this[NavigationMixin.Navigate]({
                    attributes: {
                        apiName: 'KTQB__QuickBooks_Setup'
                    },
                    type: 'standard__navItemPage'
                });
            }
        })
        .catch((error) => {
            console.error("Error opening alert: ", error);
        });
    }
    
    backBtnHandler(){
        const pageReference = {
            attributes: {
                actionName: 'view',
                objectApiName: this.customerObjectName,
                recordId: this.recordId
            },
            type: 'standard__recordPage',
        };
        this[NavigationMixin.Navigate](pageReference);
    }
    updateCustomerInQb(){
        const billingInfoArry = { 'BillAddrCity': 'billingCity',
                                  'BillAddrCountry': 'billingCountry',
                                  'BillAddrCountrySubDivisionCode': 'billingCountrySubDivisionCode',
                                  'BillAddrLine': 'billingLine',
                                  'BillAddrPostalCode': 'billingPostalCode'
                                },
              customerWrapperData = { billingInfo: {},
                                      personalInfo: {},
                                      shippingInfo: {}
                                    },
              personalInfoArry = { 'CompanyName':'companyName',
                                   'DisplayName': 'displayName',
                                   'FamilyName': 'familyName',
                                   'Fax': 'fax',
                                   'GivenName': 'givenName',
                                   'MiddleName':'middleName',
                                   'Mobile': 'mobile',
                                   'PrimaryEmailAddr': 'email',
                                   'PrimaryPhone': 'phone',
                                   'WebAddrURI': 'website',
                                   'IsTaxable': 'isTaxable',
                                 },
              shippingInfoArry = { 'ShipAddrCity': 'shippingCity',
                                   'ShipAddrCountry': 'shippingCountry',
                                   'ShipAddrCountrySubDivisionCode': 'shippingCountrySubDivisionCode',
                                   'ShipAddrLine': 'shippingLine',
                                   'ShipAddrPostalCode': 'shippingPostalCode',
                                };
        customerWrapperData.id = this.recordId;
        customerWrapperData.qbCustomerSyncToken = this.syncToken;
        customerWrapperData.customerQBId = this.customerQBId;
        customerWrapperData.action = 'update';
        customerWrapperData.personalInfo.currencyCode = this.sfCustomerData.CurrencyIsoCode;
        this.customerData.forEach(item => {
            if (typeof item === 'object') {
                const { qbfieldName, sfData } = item;

                if (Object.hasOwn(personalInfoArry, qbfieldName)) {
                    customerWrapperData.personalInfo[personalInfoArry[qbfieldName]] = sfData;
                }
                if (Object.hasOwn(billingInfoArry, qbfieldName)) {
                    customerWrapperData.billingInfo[billingInfoArry[qbfieldName]] = sfData;
                }
                if (Object.hasOwn(shippingInfoArry, qbfieldName)) {
                    customerWrapperData.shippingInfo[shippingInfoArry[qbfieldName]] = sfData;
                }
            }
        });
        if(customerWrapperData.personalInfo.isTaxable === '' || customerWrapperData.personalInfo.isTaxable === 'false'){
            customerWrapperData.personalInfo.isTaxable = false;
        }else if(customerWrapperData.personalInfo.isTaxable === 'true'){
            customerWrapperData.personalInfo.isTaxable = true;
        }
        if (customerWrapperData || 
            Object.keys(customerWrapperData).length !== ZERO || 
            Object.values(customerWrapperData).every(obj => Object.keys(obj).length !== ZERO)) {
            insertCustomer({
                accid:'',
                contactData : customerWrapperData,
                oppid:''
            }).then(result => {
                const results = result.replace('success ','')
                if(results !== '' || results !== null){
                    this.updateCustomerInSFFunc(results);
                }
                else if(result === '' || result === null){
                    this.showToastMessage('error','Something went wrong');
                    this.backBtnHandler(); 
                }else if(result == 'Check Quickbook Connection to Salesforce'){
                    this.refreshToken('insertCustomer');
                }
                else{
                    this.showToastMessage('error',result);
                    this.backBtnHandler(); 
                }
                  
            }).catch(error => {
                this.showToastMessage('error',error);
                this.backBtnHandler();   
            }); 
        }
    }
    updateCustomerInSFFunc(syncTok){
        const qbCustomerSyncTokenField = this.customerFields.find(field => field.label === 'Qb Customer Sync Token');
        let qbCustomerSyncTokenValue = '';
        if (qbCustomerSyncTokenField) {
            qbCustomerSyncTokenValue = qbCustomerSyncTokenField.value;
        }
        updateCustomerInSF({
                objectName : this.customerObjectName,
                recordID : this.recordId,
                syncFieldName : qbCustomerSyncTokenValue,
                syncToken : syncTok
            }).then(result => {
                if(result){
                    if(result === 'success'){
                        this.showToastMessage('success','Customer synchronization was successful.');
                    }else{
                        this.showToastMessage('error','Something went wrong');
                    }
                }else{
                    this.showToastMessage('error','Something went wrong');
                }
                this.backBtnHandler();
            }).catch(error => {
                this.showSpinner = false;
                this.showToastMessage('error',error.body.message);
                this.backBtnHandler();
            });
    }
    submitBtnHandler(){
        this.showSpinner = true;
        this.updateCustomerInQb();
    }
    showToastMessage(typ,msg){

        if (typeof window !== 'undefined') {

            const event = new ShowToastEvent({
                message : msg,
                title : 'Customer Sync from SF to QB',
                variant : typ
            });
            this.dispatchEvent(event);

        }
        
    }
}