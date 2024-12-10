import { LightningElement, api, track } from 'lwc';
    import HideLightningHeader from '@salesforce/resourceUrl/noHeader';
    import LightningAlert from 'lightning/alert';
    import LightningConfirm from 'lightning/confirm';
    import { NavigationMixin } from 'lightning/navigation';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import checkCurrencyIsPresentInQB from '@salesforce/apex/InvoiceController.checkCurrencyIsPresentInQB';
    import checkInvoiceObjectHasParentAccount from '@salesforce/apex/InvoiceController.checkInvoiceObjectHasParentAccount';
    import getAccountWithId from '@salesforce/apex/InvoiceController.getAccountWithId';
    import getCurrency from '@salesforce/apex/InvoiceConfigurationController.getCurrency';
    import getCustomerList from '@salesforce/apex/InvoiceController.getCustomerList';
    import getInvoiceConfiguration from '@salesforce/apex/InvoiceConfigurationController.getInvoiceConfiguration';
    import getProductList from '@salesforce/apex/InvoiceController.getProductList';
    import getSetupConfiguration from '@salesforce/apex/SetupConfigController.getSetupConfiguration';
    import insertCustomer from '@salesforce/apex/InvoiceController.insertCustomer';
    import refreshToken from '@salesforce/apex/QuickBooksIntegerationController.refreshToken';
    import getInvoiceFields from "@salesforce/apex/InvoiceConfigurationController.getInvoiceFields";
    import orgCurrency from "@salesforce/apex/InvoiceController.orgCurrency";
    import getAccountWithOpp from '@salesforce/apex/InvoiceController.getAccountWithOpp';
    import { loadStyle } from 'lightning/platformResourceLoader';
    const EIGHTEEN = 18,
        FIFTEEN = 15,
        FOUR = 4,
        ONE = 1,
        PICKLISTORDERED = [{'label':'No Data Found', 'value':''}],
        THREE = 3,
        TWO = 2,
        ZERO = 0;

    export default class GenerateInvoiceCustomerCreationForm extends NavigationMixin(LightningElement) {
    @track flagForCustomerList = false;
    @track selectedCustomer='';
    @api recordId;
    @track picklistOrdered = PICKLISTORDERED;
    isShowModal = false;
    @track sameAsBillingAddress = false;
    @track customerData = {
        billingInfo: {},
        personalInfo: {},
        shippingInfo: {}
    };
    @track customerInvoiceData = {};
    isLoading = true;
    hideDropdown = false;
    showInvoiceForm = false;
    @track contactList;
    @track invoiceProductValue = 'blankProduct';
    @track sameAsBillingAddressContact = true;
    currencyOptions;
    invoiceConfig;                      
    CurrencyCode = '';
    invoiceProductOption = [{label: 'Create Blank Invoice', value: 'blankProduct'}];
    invoiceAddressOption=[{label: 'Contact Address', value: 'contactAddress'}];
    @track contactConfiguration = {};
    @track accid;
    @track oppid;
    @track invoiceAddressValue = 'contactAddress';
    @track relatedObjectAddress = [];
    @track isTaxable = true;
    qbCustomerSyncToken=0;                     
    connectedCallback() {
            //this.customerData.personalInfo['isTaxable'] = true;
        this.getConnection();
    }
    actionClearInvoiceCustomer(){
        this.isLoading = true;
        this.selectedCustomer = '';
        this.customerInvoiceData = {};
        this.sameAsBillingAddress=false;
        this.CurrencyCode = '';
        this.sameAsBillingAddressContact=false;
        this.invoiceAddressValue = 'contactAddress';
        this.invoiceProductOption = [{label: 'Create Blank Invoice', value: 'blankProduct'}];
        this.invoiceAddressOption=[{label: 'Contact Address', value: 'contactAddress'}];
        this.contactConfiguration = {}
        this.accid = '';
        this.oppid = '';
        this.template.querySelector('c-multi-select-pick-list').initializeComponent();
        this.funcOnLoad();
    }
    getConnection(){
        getSetupConfiguration({}).
        then((result) => {
            if(result && Object.keys(result).length > ZERO){
                if((result.completedSteps === ONE || result.completedSteps === FOUR) && (result.accessToken === '' || result.accessToken === null || typeof result.accessToken === 'undefined')){
                    this.handleAlert(
                        'Unable to establish connection. Please troubleshoot the connection issue on the Setup Page.',
                        'QuickBooks - Salesforce Authorization Problem'
                    );
                }else if(result.completedSteps === TWO || result.completedSteps === THREE || result.completedSteps === ONE){
                    this.handleAlert(
                        'Please go to the Setup Page and complete all connection steps.',
                        'Incomplete Connection Setup'
                    );
                }else if(result.completedSteps === ZERO && (result.accessToken === '' || result.accessToken === null || typeof result.accessToken === 'undefined')){
                    this.handleAlert(
                        'Please go to the Setup Page and establish the connection.',
                        'Connection Not Established'
                    );
                }else{
                    this.funcOnLoad();
                }
            }else{
                    this.handleAlert(
                        'Please go to the Setup Page and establish the connection.',
                        'Connection Not Established'
                    );
            }
        }).
        catch((error) => {
                this.showNotification(
                    error.body.message,
                    'error'
                );
        })
        
    }
    handleAlert(msg, labl) {
        LightningAlert.open({
            label: labl,
            message: msg,
            // Headerless
            theme: 'error'
        }).then(() => {
            this[NavigationMixin.Navigate]({
                attributes: {
                    apiName:'KTQB__QuickBooks_Setup'
                },
                type: 'standard__navItemPage'
                });
        }).catch(() => {
            
        })
    }
    checkInvoiceObjectHasParentAccountFunc(objName){  
        checkInvoiceObjectHasParentAccount({type:objName}).
            then((result) => {
            if(result === false){
                this.handleConfirmClick(objName);
            }
        }).catch((error) => {
                this.showNotification(
                error.body.message,
                'error'
            );
        });         
    }
    getCurrencyOption(){
        const currecyArr = [];
        getCurrency({}).
        then((result) => {
            result.forEach((element) => {
                currecyArr.push({label : element, value : element});
            });
            this.currencyOptions = currecyArr;
            this.getOrgCurrency();
        }).
        catch((error) => {
            this.showNotification(
                error.body.message,
                'error'
            );
        })
    }
    getOrgCurrency(){
        orgCurrency({}).
        then((result) => {
            this.CurrencyCode = result;
            this.customerData.personalInfo['currencyCode'] = result;
        }).
        catch((error) => {
            this.showNotification(
                error.body.message,
                'error'
            );
        })
    }
    handleConfirmClick(objName) {
        let recordid = '';

        LightningConfirm.open({
            label: "Generate QB Invoice",
            message: `It appears that your Custom Invoice Object does not have an '${objName}' field. Do you still want to proceed with the generation of the invoice?`,
            theme: "warning"
        }).
        then((result) => {
            if (result) {
                this.accid = '';
                this.oppid = '';
            } else {
                if (objName === 'Account') {
                    recordid = this.accid;
                } else if (objName === 'Opportunity') {
                    recordid = this.oppid;
                } else {
                    recordid = '';
                }

                // Correct check for valid recordId
                if (recordid !== '' && recordid !== null) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            recordId: recordid
                        }
                    });
                }
            }
        });
    }

    get setAddressToggleVisibility(){
        return (this.accid || this.oppid) ? true : false;
    }
    funcOnLoad(){
        //alert('enter');
        this.getInvoiceConfiguration();
        //alert(URLSTR);
        let searchParams = "";
        if (typeof window !== 'undefined') {
            searchParams = new URLSearchParams(window.location.href);
        }
        this.accid = searchParams.get('accid');
        console.log('this.accid ='+this.accid);
        
        this.oppid = searchParams.get('oppid');
        let getAddressByAccId = '';
        if (this.accid !== '' && this.accid !== null) {
            getAddressByAccId = this.accid;
            if (!this.invoiceAddressOption.some((option) => option.value === 'accountAddress')) {
                this.invoiceAddressOption.push({ label: 'Account Address', value: 'accountAddress' });
            }
            this.invoiceAddressValue = 'accountAddress';
            this.getAddressById(getAddressByAccId);
        } else if (this.oppid !== '' && this.oppid !== null) {
            try {
                getAccountWithOpp({ oppId: this.oppid })
                .then((result) => {
                    getAddressByAccId = result;
                    console.log('a = '+getAddressByAccId);
                    
                    if (!this.invoiceAddressOption.some((option) => option.value === 'opportunityAddress')) {
                        this.invoiceAddressOption.push({ label: 'Opportunity Address', value: 'opportunityAddress' });
                    }
                    this.invoiceAddressValue = 'opportunityAddress';
                    this.getAddressById(getAddressByAccId);
            })
            .catch((error) => {
                console.error('Error fetching account ID:', error);
            });
        } catch (error) {
            console.error(
                'Error fetching account ID:',
                error
            );
        }
        }
        console.log('getAddressByAccId = '+getAddressByAccId);
        Promise.all(
            [loadStyle(
                this,
                HideLightningHeader
            )]
            ).
                then(() => {
                    // CSS loaded
                }).catch((error) => {
                    this.error = error;
                    this.showLoading = false;
                    this.showNotification(
                        "Something Went Wrong in Loading 'noHeader'.",
                        'error'
                    );
                });
                this.getCustomerList();
                
    }
    getAddressById(getAddressByAccId){
        if (getAddressByAccId !== '' && getAddressByAccId !== null) {
            try {
                //const result = await getAccountWithId({ accid: getAddressByAccId });
                getAccountWithId({ accid: getAddressByAccId })
                .then((result) => {
                    if (result) {
                        this.relatedObjectAddress = result;
                        this.customerInvoiceData.BillingCity = result.BillingCity;
                        this.customerInvoiceData.BillingCountry = result.BillingState;
                        this.customerInvoiceData.BillingPostalCode = result.BillingPostalCode;
                        this.customerInvoiceData.BillingCountrySubDivisionCode = result.BillingCountry;
                        this.customerInvoiceData.BillingLine = result.BillingStreet;
                        this.customerInvoiceData.ShippingCity = result.ShippingCity;
                        this.customerInvoiceData.ShippingCountry = result.ShippingState;
                        this.customerInvoiceData.ShippingPostalCode = result.ShippingPostalCode;
                        this.customerInvoiceData.ShippingCountrySubDivisionCode = result.ShippingCountry;
                        this.customerInvoiceData.ShippingLine = result.ShippingStreet;
                    }
    
                    if (this.accid !== '' && this.accid !== null) {
                        this.checkInvoiceObjectHasParentAccountFunc('Account');
                    } else if (this.oppid !== '' && this.oppid !== null) {
                        this.checkInvoiceObjectHasParentAccountFunc('Opportunity');
                        this.customerInvoiceData.invoiceType = 'blankProduct';
                        this.invoiceProductValue = 'blankProduct';
                    }
                })
        .catch((error) => {
        this.showNotification(error.body.message, 'error');
        });
                } catch (error) {
                    this.showNotification(
                        error.body.message,
                        'error'
                    );
                }
            }
        
    }
    customerObjectApiName='';
    getInvoiceConfiguration(){
        getInvoiceConfiguration({}).
        then((result) => {
        this.invoiceConfig=result;
        this.customerInvoiceData.Invoice_Date = this.invoiceConfig.Invoice_Date;
        this.customerInvoiceData.Invoice_Due_Date = this.invoiceConfig.Invoice_Due_Date;
        this.customerObjectApiName =  this.invoiceConfig.Customer_Object;
        if(this.invoiceConfig.EnableOpportunityProduct === true) {
            this.getOpportunityProduct();
        }
        }).catch((error) => {
            this.showNotification(
                error.body.message,
                'error'
            );
        });
    }
    getOpportunityProduct(){
        getProductList({
        oppId : this.oppid
        }).then((result) => {
        if(result.length > ZERO && !this.invoiceProductOption.some((option) => option.value === 'oppProduct')){
            this.invoiceProductOption.push({label: 'Populate Invoice with Opportunity Products', value: 'oppProduct'});
        }
        if(result.length > ZERO){
            this.customerInvoiceData.invoiceType = 'oppProduct';
            this.invoiceProductValue = 'oppProduct';
        }else{
            this.customerInvoiceData.invoiceType = 'blankProduct';
            this.invoiceProductValue = 'blankProduct';
        }
        }).catch((error) => {
            this.isLoading = false;
            this.showNotification(
                error.body?.message || 'An error occurred',
                'error'
            );
        });
    }
    renderedCallback() {
        if (typeof window !== 'undefined') {
            const style = document.createElement('style');
            style.innerText = `c-sample .slds-text-heading_small {
                color: blue;
            }
            .customCard article.slds-card.slds-card_narrow {
                background-color: rgb(229 229 229 / 79%);
            }.customCard .slds-card__header.slds-grid {
                width: fit-content;
                margin: auto;
                margin-top: 25px;
            }.customCard span.slds-text-heading_small.slds-truncate {
                font-size: 25px;
            }.customCard .slds-card__body {
                width: 75%;
                margin: auto;
                border: 1px solid #228b223d;
                border-top: 10px solid green;
                margin-top: 18px;
                margin-bottom: 50px;
                padding-bottom: 30px;
                background-color: #fff;
                    border-radius: 5px;
            }
            .slds-modal__content.slds-p-around_medium p{
                text-align: center;
            }@media only screen and (max-width: 767px) {
            .customCard .slds-card__body {
                width: 100%;
                }
            }`;
            this.template.querySelector('lightning-card').appendChild(style);
        }
    }
    getCustomerList(selected){
        getCustomerList({}).
        then((result) => {
            this.contactList = [...result];
            this.isLoading = false;
            if(this.contactList){
                this.picklistOrdered = result.map((contact) => {
                let name = contact.personalInfo.displayName;
                /*if(contact.personalInfo.displayName !== ''){
                    name = contact.personalInfo.displayName;
                }else if(contact.personalInfo.givenName !== '' || contact.personalInfo.familyName !== ''){
                    name = `${contact.personalInfo.givenName  } ${  contact.personalInfo.familyName}`;
                }*/
                    return ({
                        label:name,
                        value:contact.id
                    })
                });
            //   this.picklistOrdered = this.picklistOrdered.sort((ele1,ele2)=>{
            //       if(ele1.label < ele2.label){
            //           return MINUS_ONE
            //       }
            //     return null
            //   })
            }
            const newOption= { label: 'Add New Customer', value: 'new' };
            this.picklistOrdered = [
                newOption, 
                ...this.picklistOrdered
            ];            
            this.flagForCustomerList =  true;
            this.isLoading = false;
            if(selected === true) {
                this.handleCustomerChange();
            }
                
        })
    }
    handleCustomerChange(event){
        //this.invoiceAddressValue = 'contactAddress';
        try{
        if(typeof event !==  'undefined') {
            this.selectedCustomer = event.detail;
        }
        if(this.selectedCustomer === 'new'){
            this.actionAddNewCustomer();
        }else if(this.selectedCustomer !== '' && this.selectedCustomer !== null){
            this.customerInvoiceData.personalInfo = [];
            let index = '';
            if(this.selectedCustomer.length === EIGHTEEN || this.selectedCustomer.length === FIFTEEN){
            index = this.contactList.findIndex((item) => item.id === this.selectedCustomer);
            }else{
            index = this.contactList.findIndex((item) => (`${item.personalInfo.givenName} ${item.personalInfo.familyName}`) === this.selectedCustomer || item.personalInfo.displayName === this.selectedCustomer);
            }
            if(index >= ZERO){
            this.customerInvoiceData.Id = this.selectedCustomer;
            if(typeof this.contactList[index].personalInfo.middleName === 'undefined'){
                this.customerInvoiceData.MiddleName = '';
            }else{
                this.customerInvoiceData.MiddleName = this.contactList[index].personalInfo.middleName;  
            }
            if(typeof this.contactList[index].personalInfo.givenName === 'undefined'){
                this.customerInvoiceData.GivenName = '';
            }else{
                this.customerInvoiceData.GivenName = this.contactList[index].personalInfo.middleName;  
            }
            if(typeof this.contactList[index].personalInfo.familyName === 'undefined'){
                this.customerInvoiceData.FamilyName = '';
            }else{
                this.customerInvoiceData.FamilyName = this.contactList[index].personalInfo.familyName;  
            }
            if(typeof this.contactList[index].personalInfo.displayName === 'undefined'){
                this.customerInvoiceData.DisplayName = '';
            }else{
                this.customerInvoiceData.DisplayName = this.contactList[index].personalInfo.displayName;  
            }
            if(typeof this.contactList[index].personalInfo.email === 'undefined'){
                this.customerInvoiceData.Email = '';
            }else{
                this.customerInvoiceData.Email = this.contactList[index].personalInfo.email;  
            }
            if(typeof this.contactList[index].customerQBId === 'undefined'){
                this.customerInvoiceData.customerQBId = '';
            }else{
                this.customerInvoiceData.customerQBId = this.contactList[index].customerQBId;  
            }
            if(this.invoiceAddressValue === 'contactAddress'){
                this.customerInvoiceData.billingInfo = [];
                this.customerInvoiceData.shippingInfo = [];
                this.autopopulateAddress('');
                if(typeof this.contactList[index].billingInfo.billingLine === 'undefined'){
                    this.customerInvoiceData.BillingLine = '';
                }else{
                    this.customerInvoiceData.BillingLine = this.contactList[index].billingInfo.billingLine;  
                }
                if(typeof this.contactList[index].billingInfo.billingCountrySubDivisionCode === 'undefined'){
                    this.customerInvoiceData.BillingCountrySubDivisionCode = '';
                }else{
                    this.customerInvoiceData.BillingCountrySubDivisionCode = this.contactList[index].billingInfo.billingCountrySubDivisionCode;  
                }
                if(typeof this.contactList[index].billingInfo.billingPostalCode === 'undefined'){
                    this.customerInvoiceData.BillingPostalCode = '';
                }else{
                    this.customerInvoiceData.BillingPostalCode = this.contactList[index].billingInfo.billingPostalCode;  
                }
                if(typeof this.contactList[index].billingInfo.billingCountry === 'undefined'){
                    this.customerInvoiceData.BillingCountry = '';
                }else{
                    this.customerInvoiceData.BillingCountry = this.contactList[index].billingInfo.billingCountry;  
                }
                if(typeof this.contactList[index].billingInfo.billingCity === 'undefined'){
                    this.customerInvoiceData.BillingCity = '';
                }else{
                    this.customerInvoiceData.BillingCity = this.contactList[index].billingInfo.billingCity;  
                }
                if(typeof this.contactList[index].shippingInfo.shippingLine === 'undefined'){
                    this.customerInvoiceData.ShippingLine = '';
                }else{
                    this.customerInvoiceData.ShippingLine = this.contactList[index].shippingInfo.shippingLine;  
                }
                if(typeof this.contactList[index].shippingInfo.shippingCountrySubDivisionCode === 'undefined'){
                    this.customerInvoiceData.ShippingCountrySubDivisionCode = '';
                }else{
                    this.customerInvoiceData.ShippingCountrySubDivisionCode = this.contactList[index].shippingInfo.shippingCountrySubDivisionCode;  
                }
                if(typeof this.contactList[index].shippingInfo.shippingPostalCode === 'undefined'){
                    this.customerInvoiceData.ShippingPostalCode = '';
                }else{
                    this.customerInvoiceData.ShippingPostalCode = this.contactList[index].shippingInfo.shippingPostalCode;  
                }
                if(typeof this.contactList[index].shippingInfo.shippingCountry === 'undefined'){
                    this.customerInvoiceData.ShippingCountry = '';
                }else{
                    this.customerInvoiceData.ShippingCountry = this.contactList[index].shippingInfo.shippingCountry;  
                }
                if(typeof this.contactList[index].shippingInfo.shippingCity === 'undefined'){
                    this.customerInvoiceData.ShippingCity = '';
                }else{
                    this.customerInvoiceData.ShippingCity = this.contactList[index].shippingInfo.shippingCity;  
                }
            }
            
            if(typeof this.contactList[index].personalInfo.currencyCode === 'undefined'){
                this.customerInvoiceData.CurrencyCode = '';
            }else{
                this.customerInvoiceData.CurrencyCode = this.contactList[index].personalInfo.currencyCode;  
            }
            this.isLoading=false;
            this.flagForCustomerList = true;
            }
        }else{
            this.isLoading=false;
            this.flagForCustomerList = true;
        }
        }catch(error){
        console.log(error.body.message);
        }
    }
    actionAddNewCustomer(){
        this.getCurrencyOption();
        this.getRequiredFields();
        this.hideDropdown = false;
        this.isShowModal = true;
        this.customerData = {billingInfo: {},
        personalInfo: {},
        shippingInfo: {}};
    }
    hideModalBox(){
        this.isShowModal = false;
        this.flagForCustomerList = true;
        this.sameAsBillingAddressContact=false;
        this.sameAsBillingAddress=false;
    }
    handleSameAsShippingAddress(){
        if(this.sameAsShippingAddress === true){
            this.sameAsShippingAddress = false;
        }else{
            this.sameAsShippingAddress = true;
        }
    }
    get enableCurrencySelection(){
        return (this.isTaxable && this.currencyOptions)
    }
    actionContactValue(event){
        if(event.target.name === 'contactSameAsBilling'){ 
            this.customerData.personalInfo.contactSameAsBilling = event.target.checked;
            this.sameAsBillingAddressContact = event.target.checked;
            this.customerData.personalInfo.sameAsBillingAddress = this.sameAsBillingAddress = this.sameAsBillingAddressContact;
        }else if(event.target.name === 'currencyCode'){
            this.CurrencyCode = event.target.value;
            this.customerData.personalInfo['currencyCode'] = event.target.value;
        }else if(event.target.name === 'displayName'){
            this.customerData.personalInfo['displayName'] = event.target.value.trim();
        }else if(event.target.name === 'isTaxable'){
            this.isTaxable =  event.target.checked;
        }else{
            const billingInfoArry = [
                'billingCity',
                'billingCountry',
                'billingCountrySubDivisionCode',
                'billingLine',
                'billingPostalCode'
            ];                    
            const personalInfoArry = [
                'companyName',
                'email',
                'familyName',
                'fax',
                'givenName',
                'middleName',
                'mobile',
                'phone',
                'website'
            ];
            
            const shippingInfoArry = [
                'shippingLine',
                'shippingCity',
                'shippingCountry',
                'shippingPostalCode',
                'shippingCountrySubDivisionCode'
            ];            
            if(personalInfoArry.includes(event.target.name)){
                this.customerData.personalInfo[event.target.name] = event.target.value.trim();
                if(event.target.name === 'familyName' || event.target.name === 'middleName' || event.target.name === 'givenName'){
                let givenName, middleName, familyName = '';
                givenName = (this.customerData.personalInfo['givenName'] != undefined) ? 
                    this.customerData.personalInfo['givenName']:'';
                middleName = (this.customerData.personalInfo['middleName'] != undefined) ? 
                ((this.customerData.personalInfo['middleName'] === '')? '':' ')+this.customerData.personalInfo['middleName']:'' 
                familyName = (this.customerData.personalInfo['familyName'] != undefined) ? 
                ((this.customerData.personalInfo['familyName'] === '')? '':' ')+this.customerData.personalInfo['familyName']:'' ;
                //if(this.customerData.personalInfo['displayName'] === '' || typeof this.customerData.personalInfo['displayName'] === 'undefined'){
                    this.customerData.personalInfo['displayName'] = givenName + middleName + familyName;
                    this.customerData.personalInfo['displayName'] = this.customerData.personalInfo['displayName'].trim();
                //}
                    
                }
            }else if(billingInfoArry.includes(event.target.name)){
                this.customerData.billingInfo[event.target.name] = event.target.value.trim();
            }else if(shippingInfoArry.includes(event.target.name)){
                this.customerData.shippingInfo[event.target.name] = event.target.value.trim();
            }
        }
    }
    /*get checkFamilyNameReq(){

    }*/
    @track RequiredFieldsNames = {};
    getRequiredFields(){
        getInvoiceFields({"objectApiName": this.customerObjectApiName, "type": 'Customer'}).
            then((result) => {
                let matchedFields = [];
                var Objectfields = result.Objectfields;
                var InvoiceRequiredField = Objectfields.filter((field) => 
                    !field.required && 
                    ![
                        "REFERENCE", 
                        "BOOLEAN"
                    ].includes(field.fieldType)
                );             
                let checkFielding = true;
                checkFielding = InvoiceRequiredField.every((field) => {
                    return result.invoiceField.some((item) => item.value === field.value);
                });
                if(checkFielding === true){
                    InvoiceRequiredField.forEach((reqField) => {
                        const match = result.invoiceField.find((custField) => custField.value === reqField.value);
                        if (match) {
                            matchedFields.push(
                                match.name.replace(
                                /\s+/g,
                                ''
                                )
                            );
                        }
                    });
                }
                matchedFields.forEach((field) => {
                    this.RequiredFieldsNames[field] = true;
                });
            }).
                catch((error) => {
                    this.error = error;
                    this.showLoading = false;
                
                });
    }
    actionInsertContact(){
        this.flagForCustomerList =  false;
        this.isLoading = true;
        const inputFields = this.template.querySelectorAll(".validate");
            let isValid = true;
            inputFields.forEach((inputField) => {
                if (!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                
                }
                
            });
        if (!isValid) {
            this.showNotification(
                'Please solved below errors',
                'error'
            );
            this.isLoading = false;
        }else if(this.CurrencyCode !== '' && this.CurrencyCode !== null){
            checkCurrencyIsPresentInQB({sFCurrencyCode:this.CurrencyCode}).
            then((result) => {
                if(result === ''){
                    this.handleAlertClick();
                }else {
                    this.insertContact(); 
                }
            }).catch((error) => {
                this.showNotification(
                    error.body.message,
                    'error'
                );
            });
        }else if(!this.customerData.personalInfo.displayName && !this.customerData.personalInfo.givenName && !this.customerData.personalInfo.middleName && !this.customerData.personalInfo.familyName){
            this.showNotification(
                'Please fill at least one of the fields: Given Name, Display Name, Middle Name, or Family Name.',
                'error'
            );
            this.isLoading = false;
        }else {    
            this.insertContact();                 
        }
    }
    handleAlertClick() {
        LightningAlert.open({
            label: 'Currency Alert!',
            message: 'The currency you have selected is not available in QuickBooks. If you wish to use the same currency, please navigate to the QuickBooks setup and create a new currency. Alternatively, you can select a different currency',
            theme: 'warning'
        }).
        then(() => {
            this.isLoading = false;
        }).
        catch((error) => {
            console.error(
                'Error displaying alert:',
                error
            );
            this.isLoading = false;
        });
    }

    insertContact(){
    if(this.customerData.personalInfo.displayName === null || this.customerData.personalInfo.displayName === '' || typeof this.customerData.personalInfo.displayName === 'undefined'){
        const displayName = [
            this.customerData.personalInfo.givenName,
            this.customerData.personalInfo.middleName,
            this.customerData.personalInfo.familyName
        ].filter(Boolean);        
        this.customerData.personalInfo.displayName = displayName.join(' ');
    }
    if(this.sameAsBillingAddressContact === true){
        this.customerData.shippingInfo.shippingLine = this.customerData.billingInfo.billingLine;
        this.customerData.shippingInfo.shippingCity = this.customerData.billingInfo.billingCity;
        this.customerData.shippingInfo.shippingCountry = this.customerData.billingInfo.billingCountry;
        this.customerData.shippingInfo.shippingPostalCode = this.customerData.billingInfo.billingPostalCode;
        this.customerData.shippingInfo.shippingCountrySubDivisionCode = this.customerData.billingInfo.billingCountrySubDivisionCode;
    }
    this.customerData.personalInfo.isTaxable = this.isTaxable;
    insertCustomer({
        accid : this.accid,
        contactData : this.customerData,
        oppid:this.oppid
    }).then((result) => {
        if(result === 'Check Quickbook Connection to Salesforce'){
            this.refreshToken();
        }else if(result.includes('success')){
            const results = result.replace(
                'success ',
                ''
            )
            if(results.length === FIFTEEN || results.length === EIGHTEEN){
                this.selectedCustomer = results;
                    this.getCustomerList(true);
            }else{
                if(this.customerData.personalInfo.displayName === null){
                    this.selectedCustomer = `${this.customerData.personalInfo.givenName  } ${this.customerData.personalInfo.familyName}`;
                }else{
                    this.selectedCustomer = this.customerData.personalInfo.displayName;
                }
                const newOption= { label: this.selectedCustomer, value: this.selectedCustomer };
                this.picklistOrdered = [
                    newOption,
                    ...this.picklistOrdered
                ];                
                this.customerData.customerQBId = results.match(/(?:\d+)/u)[ZERO];
                if(this.customerData.personalInfo.contactSameAsBilling === true){ 
                    this.sameAsBillingAddress = true 
                }
                this.contactList.push(this.customerData);
                this.customerInvoiceData.customerQBId = results.match(/(?:\d+)/u)[ZERO];
                this.handleCustomerChange();
            }
            
            this.isShowModal = false;
            this.showNotification(
                'Customer added into QB',
                'success'
            );
        }else if(result === 'The name supplied already exists. : null'){
            result = 'Another customer, vendor or employee is already using this name. Please use a different name.';
            this.showNotification(
                result,
                'error'
            );
            this.isLoading = false;
        }else if(result.includes('fail customer insert')){
            const idObject = {};
            result.split('&').forEach((pair) => {
                const keyValue = pair.split('=');
                idObject[keyValue[0]] = keyValue[1];
            });
            this.customerData.qbCustomerSyncToken = idObject.customerSyncToken;
            //this.customerData.action = "update";
            this.customerData.customerQBId = idObject.customerQBID;
            this.showNotification(
                idObject.errorMessage,
                'error'
            );
            this.isLoading = false;
        }else{
            this.showNotification(
                result,
                'error'
            );
            this.isLoading = false;
        }
        this.qbCustomerSyncToken = this.qbCustomerSyncToken + 1;
    }).catch((error) => {
        this.isLoading = false;
        this.showNotification(
            error.body.message,
            'error'
        );
    });

    }
    refreshToken(clsName){
        refreshToken({}).
        then(() => {
            if(clsName === 'insertCustomer'){
                this.insertContact();
            }
        }).
        catch((error) => {
            this.showSpinner = false;
            this.showToastMessage(
                'error',
                error.body.message
            );
        });
    }
    actionInvoiceCustomerChange(event){
        try{
            
            if(event.target.name === 'sameAsBillingAddress'){ 
                this.customerData.personalInfo.sameAsBillingAddress = event.target.checked;
                this.sameAsBillingAddress = event.target.checked;
            }else {
                this.customerInvoiceData[event.target.name] = event.target.value.trim();
            }
            if(event.target.name === 'invoiceType'){
                this.customerInvoiceData.invoiceType = event.target.value;
                this.invoiceProductValue = event.target.value;
            }
            if(event.target.name === 'invoiceAddress'){
                this.autopopulateAddress();
                this.invoiceAddressValue = event.target.value;
                if(this.invoiceAddressValue === 'opportunityAddress' || this.invoiceAddressValue === 'accountAddress'){
                    this.autopopulateAddress(this.relatedObjectAddress);
                }else if(this.invoiceAddressValue === 'contactAddress'){
                    this.handleCustomerChange();
                }
            }
        }catch(error){
            console.log(
                '---error---',
                error.body.message
                );
        }
        
    }
    autopopulateAddress(result){
        this.customerInvoiceData.BillingCity = (result) ? result.BillingCity : '';
        this.customerInvoiceData.BillingCountry = (result) ? result.BillingState : '';
        this.customerInvoiceData.BillingPostalCode = (result) ? result.BillingPostalCode : '';
        this.customerInvoiceData.BillingCountrySubDivisionCode = (result) ? result.BillingCountry : '';
        this.customerInvoiceData.BillingLine = (result) ? result.BillingStreet : '';
        this.customerInvoiceData.ShippingCity = (result) ? result.ShippingCity : '';
        this.customerInvoiceData.ShippingCountry = (result) ? result.ShippingState : '';
        this.customerInvoiceData.ShippingPostalCode = (result) ? result.ShippingPostalCode : '';
        this.customerInvoiceData.ShippingCountrySubDivisionCode = (result) ? result.ShippingCountry : '';
        this.customerInvoiceData.ShippingLine = (result) ? result.ShippingStreet : '';
    }
    validateEmails(emailInput) {
        const emails = emailInput.split(',').map((email) => email.trim());
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const uniqueEmails = new Set();
        emails.forEach((email) => {
            if (!emailPattern.test(email)) {
                return false;
            }
            if (uniqueEmails.has(email)) {
                return false;
            }
            uniqueEmails.add(email);
        });
        return true;
    }
    actionSaveInvoiceCustomer(){
        //if(this.customerInvoiceData === null || this.customerInvoiceData.Id === null || Object.keys(this.customerInvoiceData).length === ZERO || typeof this.customerInvoiceData === 'undefined'){
        if(typeof this.customerInvoiceData.Id === 'undefined'){
            this.showNotification(
                'Please select the customer',
                'error'
            );
        }else if(!this.validateEmails(this.customerInvoiceData.Email) && this.customerInvoiceData.Email !== null && this.customerInvoiceData.Email !== ''){
            this.showNotification(
                'Please enter a valid email address. No duplicates are allowed. Multiple emails are allowed, separated by commas.',
                'error'
            );
        }else{
            this.customerInvoiceData.invoiceType = this.invoiceProductValue;
            if(this.sameAsBillingAddress === true){
                this.customerInvoiceData.ShippingLine = this.customerInvoiceData.BillingLine;
                this.customerInvoiceData.ShippingCity = this.customerInvoiceData.BillingCity;
                this.customerInvoiceData.ShippingCountrySubDivisionCode = this.customerInvoiceData.BillingCountrySubDivisionCode;
                this.customerInvoiceData.ShippingPostalCode = this.customerInvoiceData.BillingPostalCode;
                this.customerInvoiceData.ShippingCountry = this.customerInvoiceData.BillingCountry;
            }
            this.showInvoiceForm = true;
        }      
    }
    backHandler(){
        this[NavigationMixin.Navigate]({
            attributes: {
                actionName: 'view',
                recordId: this.recordId
            },
            type: 'standard__recordPage'
        });
    }
    handleResponse(){
        this.showInvoiceForm = false;
    }
    showNotification(msg, type) {

        if (typeof window !== 'undefined') {

            const evt = new ShowToastEvent({
                message: msg,
                title:'Invoice Sync',
                variant: type
            });
            this.dispatchEvent(evt);

        }

    }
    }