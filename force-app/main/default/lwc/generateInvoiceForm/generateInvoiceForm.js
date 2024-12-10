import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateInvoice from '@salesforce/apex/InvoiceController.generateInvoice';
import getFieldOption from '@salesforce/apex/InvoiceController.getFieldOption';
import getInvoiceConfiguration from '@salesforce/apex/InvoiceConfigurationController.getInvoiceConfiguration';
import getOpportunity from '@salesforce/apex/InvoiceConfigurationController.getOpportunity';
import getProductList from '@salesforce/apex/InvoiceController.getProductList';
import insertProductOnQb from '@salesforce/apex/InvoiceController.insertProductOnQb';
import refreshToken from '@salesforce/apex/QuickBooksIntegerationController.refreshToken';
import sendInvoiceEmail from '@salesforce/apex/InvoiceController.sendInvoiceEmail';

const DISCOUNTOPTIONS = [
            { label: 'Discount Value', value: 'value' },
            { label: 'Discount Percent', value: 'percent' }
      ],
      HUNDRED = 100,
      MINUS_ONE = -1,
      ONE = 1,
      SIXTEEN = 16,
      THIRTYSIX = 36,
      THREE = 3,
      TWO = 2,
      ZERO = 0,
      ZEROWITHTWODECIMAL = 0.00;

export default class GenerateInvoiceForm extends NavigationMixin(LightningElement) {
    disSaveNsend =  false;
    disSave =  false;
    @api recordId;
    @track invoiceSubtotal = ZEROWITHTWODECIMAL;
    @track amount = ZERO;
    @track taxValue = '';
    @track taxableSubtotal = ZEROWITHTWODECIMAL;
    @api getCustomerInvoice;
    customerInvoice;
    @api getAccid='';
    accId='';
    @api getOppid='';
    oppId='';
    @api getOpaccid='';
    opAccId = '';
    @track lineitemsRecords = [];
    @track invoiceCustomeData = {};
    @track discountTypeValue = 'value';
    @track discountValue = ZERO;
    @track discountTotal = ZEROWITHTWODECIMAL;
    @track totalTaxValue = ZEROWITHTWODECIMAL;
    @track totalBill = ZEROWITHTWODECIMAL;
    @track terms;
    @track invoiceDate;
    @track invoiceDueDate;
    @track sendInvoice = false;
    @track invoiceConfig; 
    @track taxPercentOptions;
    @track termsOption;
    @track taxId;
    @track taxRate;
    @track shipping = '0.00';
    @track discountAfterTax = true;
    @track syncToken = '';
    @track invoiceQBID = '';
    tempVar = false;
    accid;
    currencyOptions;
    saveDisable =false;
    saveAndSendDisable =false; 
    picklistOrdered;
    customerData ={
        billingInfo: {},
        personalInfo: {},
        shippingInfo: {}
    };
    discountOptions = DISCOUNTOPTIONS;
    insertProductStatus = [];
    productArray = [];
    get billingAddress() {
        const lines = [];
        if (this.customerInvoice.BillingLine) {
            lines.push(this.customerInvoice.BillingLine);
        }
        if (this.customerInvoice.BillingCity || this.customerInvoice.BillingCountrySubDivisionCode) {
            const citySubDivisionLine = [];
            if (this.customerInvoice.BillingCity) {
                citySubDivisionLine.push(this.customerInvoice.BillingCity);
            }
            if (this.customerInvoice.BillingCountrySubDivisionCode) {
                citySubDivisionLine.push(this.customerInvoice.BillingCountrySubDivisionCode);
            }
            lines.push(citySubDivisionLine.join(', '));
        }
        if (this.customerInvoice.BillingPostalCode || this.customerInvoice.BillingCountry) {
            const postalCodeCountryLine = [];
            if (this.customerInvoice.BillingPostalCode) {
                postalCodeCountryLine.push(this.customerInvoice.BillingPostalCode);
            }
            if (this.customerInvoice.BillingCountry) {
                postalCodeCountryLine.push(this.customerInvoice.BillingCountry);
            }
            lines.push(postalCodeCountryLine.join(', '));
        }
        return lines.join('<br>');
    }
    get shippingAddress(){
        const lines = [];
        if (this.customerInvoice.ShippingLine) {
            lines.push(this.customerInvoice.ShippingLine);
        }
        if (this.customerInvoice.ShippingCity || this.customerInvoice.ShippingCountrySubDivisionCode) {
            const citySubDivisionLine = [];
            if (this.customerInvoice.ShippingCity) {
                citySubDivisionLine.push(this.customerInvoice.ShippingCity);
            }
            if (this.customerInvoice.ShippingCountrySubDivisionCode) {
                citySubDivisionLine.push(this.customerInvoice.ShippingCountrySubDivisionCode);
            }
            lines.push(citySubDivisionLine.join(', '));
        }
        if (this.customerInvoice.ShippingPostalCode || this.customerInvoice.ShippingCountry) {
            const postalCodeCountryLine = [];
            if (this.customerInvoice.ShippingPostalCode) {
                postalCodeCountryLine.push(this.customerInvoice.ShippingPostalCode);
            }
            if (this.customerInvoice.ShippingCountry) {
                postalCodeCountryLine.push(this.customerInvoice.ShippingCountry);
            }
            lines.push(postalCodeCountryLine.join(', '));
        }
        return lines.join('<br>');
    }
    get getConfigForProduct(){
        return (this.invoiceOppProduct && this.invoiceConfig.CreateOpportunityProduct)
    }

    connectedCallback(){
        this.isLoading = true;   
        this.accId = this.getAccid;
        this.oppId = this.getOppid;
        this.opAccId = this.getOpaccid;
        this.customerInvoice = this.getCustomerInvoice;
        this.getInvoiceObjectOptions('Account');
        this.getInvoiceObjectOptions('salesTax');
        this.getInvoiceObjectOptions('Term',true);
    }
    getInvoiceConfigurationFunc(){
        
        getInvoiceConfiguration({})
        .then(result => {
            if(result === null){
                this.showNotification('Something Went Wrong','error');
                if (typeof window !== 'undefined') {
                    window.location.reload();
                }
            }else if(result==='createInQb'){
                 this.showNotification('Invoice creation in QuickBooks was successful, but encountered a failure while attempting to create the corresponding invoice in Salesforce. Please review the invoice configuration settings in the Setup.','warning');
            }
            else{
                this.invoiceConfig = result;
                if (!this.InvoiceCustomeData) {
                this.InvoiceCustomeData = {};
                }
                this.terms = result.Terms;
                this.taxId = result.Tax;
                const currentDate = new Date(),
                      index = this.taxPercentOptions.findIndex(row => row.value === this.taxId);
                if (index !== MINUS_ONE) {
                    this.taxValue = this.taxPercentOptions[index].id;
                    this.InvoiceCustomeData.taxRate = this.taxPercentOptions[index].label;
                }
                if(result.Income_Account !== '' && result.Income_Account !== null && typeof result.Income_Account !== 'undefined'){
                    this.incomeAccount = result.Income_Account.toString();
                }else{
                    this.incomeAccount = '';
                }
                this.disablingButtons(result);
                if(this.customerInvoice.invoiceType === 'oppProduct'){
                    this.invoiceOppProduct = true;
                }else{
                    this.invoiceOppProduct = false;
                }
                
                if(this.oppId === null || this.oppId === '' || typeof this.oppId === 'undefined'){
                    this.invoiceDueDate = currentDate.toISOString().split('T')[ZERO];
                    this.invoiceDate = currentDate.toISOString().split('T')[ZERO];
                    this.InvoiceCustomeData.dueDate = currentDate.toISOString().split('T')[ZERO];
                    this.InvoiceCustomeData.invoiceDate = currentDate.toISOString().split('T')[ZERO];
                }else{
                     this.getOpportunityUsingSetupFields();
                }
                if(this.invoiceOppProduct === true){
                    this.getProductListFunc();
                }
                else{
                    let myNewElement=[];
                    const randomId = Math.random() * SIXTEEN;
                    myNewElement = {amount:0,code:"",expenseAccount:"55",id: randomId.toString(THIRTYSIX),incomeAccount:this.incomeAccount,productDesc: "",productId:"",productName: "",quantity:0, rate:0,taxable:0};
                    this.lineitemsRecords.push(myNewElement);
                }
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.showNotification(error.body.message,'error');
            if (typeof window !== 'undefined') {
                window.location.reload();
            }
            this.isLoading = false;
        })
    }
    readInvoiceSetupData() {
        
        const fields = ['Invoice_Date', 'Invoice_Due_Date'];
        try {
            fields.forEach(field => {
                
                if(this.invoiceConfig[field] && this.invoiceConfig[field] !== '' && this.invoiceConfig[field].includes(';')){
                    const val = this.invoiceConfig[field].split(";");
                    let dateField = '',
                        days = '0';
                    if (val && val.length === THREE) {
                        
                        if (val[ZERO] && val[ZERO] !== '') {
                            days = val[ZERO];
                        }
                        if (val[ONE] && val[ONE] !== '' && (val[ONE] === 'Before' || val[ONE] === 'After')) {
                            if (val[ONE] === 'Before') {
                                days = `-${  days}`;
                            } else if (val[ONE] === 'After') {
                                days = `+${  days}`;
                            }
                        }
                        if (val[TWO] && val[TWO] !== '') {
                            dateField = val[TWO];
                        }
                    }
                    
                    if(days === '0'){
                        if (this.opportunity && Object.keys(this.opportunity).includes(dateField)) {
                            this.setfieldStringValue(field, this.opportunity[dateField]);
                        } else {
                            this.setfieldStringValue(field, '');
                        }
                    }else if (dateField && days){
                        
                        if (this.opportunity && Object.keys(this.opportunity).includes(dateField)) {
                            const date = new Date(this.opportunity[dateField]);
                            date.setDate(date.getDate() + parseInt(days, 10));
                            this.setfieldStringValue(field, date.toISOString().split('T')[ZERO]);
                        }
                    }else {
                        this.setfieldStringValue(field, '');
                    }
                }else if(this.invoiceConfig[field] !== '' && this.opportunity && Object.keys(this.opportunity).includes(this.invoiceConfig[field])) {
                        this.setfieldStringValue(field, this.opportunity[this.invoiceConfig[field]]);
                }else{
                    this.setfieldStringValue(field, '');
                }
            });
        } catch (error) {
            this.showNotification(error.body.message,'error');
        }
    }
    
    setfieldStringValue(field, value){
        
        if(field && field === 'Invoice_Date'){
            this.invoiceDate = value;
            this.InvoiceCustomeData.invoiceDate = value; 

        }else if(field && field === 'Invoice_Due_Date'){
            this.invoiceDueDate = value;
            this.InvoiceCustomeData.dueDate = value;
        }
    }
    decodeField(rawField){
        this.tempVar = true;
        if(rawField.includes(';')){
            const val = rawField.split(";");
            if(val && val.length === THREE){
                return val[TWO];
            }
            return '';
        }
        return rawField;
    }
    getInvoiceSetupFieldsAndPrepareArraay(){
        const fields = [];
        let fld = '';
        if(this.invoiceConfig && this.invoiceConfig.Invoice_Due_Date && this.invoiceConfig.Invoice_Due_Date !== ''){
            fld = this.decodeField(this.invoiceConfig.Invoice_Due_Date);
            if(fld && fld !== ''){
                fields.push(fld);
            }
        }
        if(this.invoiceConfig && this.invoiceConfig.Invoice_Date && this.invoiceConfig.Invoice_Date !== ''){
            fld = this.decodeField(this.invoiceConfig.Invoice_Date);
            if(fld && fld !== ''){
                fields.push(fld);
            }
        }
        return fields;
    }
    getOpportunityUsingSetupFields(){
        
        const fields = this.getInvoiceSetupFieldsAndPrepareArraay();
        
        getOpportunity({recordId : this.oppId, setupFields :fields})
		.then(result => {
            
            if(result === null){
                this.showNotification('Something Went Wrong','error');
                if (typeof window !== 'undefined') {
                    window.location.reload();
                }
            }else{
                this.opportunity = result;
                if(this.opportunity){
                    this.readInvoiceSetupData();
                }
            }
            
            this.isLoading = false;
		})
		.catch(error => {
            this.showNotification(error.body.message,'error');
            if (typeof window !== 'undefined') {
                window.location.reload();
            }
            this.isLoading = false;
		})
    }
    getProductListFunc(){
        getProductList({
            oppId : this.oppId})
            .then((result) => {
                this.picklistOrdered = result.map((product) =>({
                    code : product.ProductCode,
                    label:product.Product2.Name,
                    productDesc:product.Description,
                    productId:product.Product2.Id,
                    qbProductCode: product.Product2.KTQB__Item_QB_Id__c ,
                    quantity:product.Quantity,
                    taxable:product.Taxable__c,
                    totalprice:product.TotalPrice,
                    unitprice:product.UnitPrice,
                    value:product.Id
                }));
                /*this.picklistOrdered = result.map((product) =>{
                return ({
                            code : product.ProductCode,
                            label:product.Product2.Name,
                            productDesc:product.Description,
                            productId:product.Product2.Id,
                            qbProductCode: product.Product2.KTQB__Item_QB_Id__c ,
                            quantity:product.Quantity,
                            taxable:product.Taxable__c,
                            totalprice:product.TotalPrice,
                            unitprice:product.UnitPrice,
                            value:product.Id
                        })
              });*/
              this.picklistOrdered = this.picklistOrdered.sort((ele1,ele2)=>{
                  if(ele1.label < ele2.label){
                      return MINUS_ONE;
                  }
                  return null;
              })
              let myNewElement=[];
                for(let index=0;index<(this.picklistOrdered.length);index+=ONE){
                    const randomId = Math.random() * SIXTEEN;
                    myNewElement = {amount:this.picklistOrdered[index].totalprice,code:this.picklistOrdered[index].code,id: randomId.toString(THIRTYSIX),incomeAccount:this.incomeAccount,productDesc:this.picklistOrdered[index].productDesc,productId:this.picklistOrdered[index].productId,productName:this.picklistOrdered[index].label,qbProductCode:this.picklistOrdered[index].qbProductCode,quantity:this.picklistOrdered[index].quantity, rate:this.picklistOrdered[index].unitprice,sku:this.picklistOrdered[index].sku,taxable:0};
                    this.lineitemsRecords.push(myNewElement);
                }
                this.countsubTotal();
                this.calculateTaxableAmt();
                this.caculateTax();
                this.calculateBill();
          })
    }
    getInvoiceObjectOptions(entity,enableConfig){

        getFieldOption({type:entity})
            .then(result => {
                if(result !== '' || result !== null){
                    const arr = [];
                    let str = '';
                    for(let index=0; index < result.length;index+=ONE){
                        if(entity === 'salesTax') {
                            str = `${result[index].Name} (${result[index].KTQB__Sales_Tax_Rate__c}%)`;
                            arr.push({id : result[index].KTQB__Sales_Tax_Rate__c.toString(), label : str, value: result[index].KTQB__QB_Id__c.toString(), idSF : result[index].Id});
                        }
                        else {
                            str = result[index].Name;
                            arr.push({label : str, value : result[index].KTQB__QB_Id__c, idSF : result[index].Id});
                        }
                    }
                    if(entity === 'Term') {
                      this.termsOption = arr;
                    }
                    else if(entity === 'salesTax') {
                      this.taxPercentOptions = arr;
                    }
                    else if(entity === 'Account') {
                      this.incomeAccountOption = arr;
                    }
                    if(enableConfig === true) {
                      this.getInvoiceConfigurationFunc();
                    }
                }else {
                    this.showNotification('Something Went Wrong','error'); 
                    if (typeof window !== 'undefined') {
                        window.location.reload();
                    }
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.showNotification(error.body.message,'error');
                if (typeof window !== 'undefined') {
                    window.location.reload();
                }
                this.isLoading = false;
            })
    }
    disablingButtons(data){
        if(data){
            this.saveDisable = this.invoiceConfig.Save;
            this.saveAndSendDisable = this.invoiceConfig.Save_And_Send ;
        }
    }
    get getShippingAddress(){
        if(this.customerInvoice.ShippingStreet || this.customerInvoice.ShippingCity || this.customerInvoice.ShippingState || this.customerInvoice.ShippingZip || this.customerInvoice.ShippingCountry){
              return true;
        }
        return false; 
    }
    get getBillingAddress(){
        if(this.customerInvoice.BillingLine || this.customerInvoice.BillingCity || this.customerInvoice.BillingState || this.customerInvoice.BillingZip || this.customerInvoice.BillingCountry){
              return true;
        }
        return false;
    }
    get getContactDetails(){
        if(this.customerInvoice.DisplayName){
          return true;
        }
        else if(this.customerInvoice.GivenName || this.customerInvoice.FamilyName || this.customerInvoice.MiddleName){
          return true;
        }
        return false;
    }
    addlineitemClick(){

        const arandomId = Math.random() * SIXTEEN,
              myNewElement = {amount:0,code:"",id: arandomId.toString(THIRTYSIX),incomeAccount:this.incomeAccount,productDesc: "",productId:"",productName: "",qbProductCode:"",quantity:0, rate:0,taxable:0};
        this.lineitemsRecords = [...this.lineitemsRecords, myNewElement];
    }
    removeClick(event){
        const amount = parseFloat(event.target.dataset.amount).toFixed(TWO);
        this.invoiceSubtotal -= parseFloat(amount);
        if(event.target.dataset.tax === ONE || event.target.dataset.tax === "true"){
            const amt = parseFloat(event.target.dataset.amount).toFixed(TWO);
            this.taxableSubtotal -= parseFloat(amt); 
        }
        
        this.caculateDiscount();
        this.caculateTax();
        this.calculateBill();
        this.lineitemsRecords.splice(this.lineitemsRecords.findIndex(row => row.id === event.target.dataset.id), ONE);

    }
    calculateBill(){
        const invoiceSubtotal = parseFloat(this.invoiceSubtotal) || ZERO,
              totalTaxValue = parseFloat(this.totalTaxValue) || ZERO,
              discountTotal = parseFloat(this.discountTotal) || ZERO,
              shipping = parseFloat(this.shipping) || ZERO;
        this.totalBill = (invoiceSubtotal + totalTaxValue + discountTotal + shipping).toFixed(TWO);
    }
    calculateTaxableAmt(){
        let subTotal = ZERO;
        const temparr = this.lineitemsRecords;
        for(let index=ZERO;index<temparr.length;index+=ONE){
            if(temparr[index].taxable === ONE || temparr[index].taxable === true){
                  subTotal += Number(temparr[index].amount);
            }
        }
        this.taxableSubtotal = subTotal.toFixed(TWO);
    }
    @track termSFID='';
    @track taxSFID='';
    updateValues(event){
        try{    
            const foundelement = this.lineitemsRecords.find(ele => ele.id === event.target.dataset.id);
            if(event.target.name === 'quantity'){
                foundelement.quantity = event.target.value;
                foundelement.amount = this.countlineItemTotal(foundelement.quantity,foundelement.rate);
            }else if(event.target.name === 'shipping'){
                this.shipping = event.target.value;
            }else if(event.target.name === 'rate'){
                foundelement.rate = event.target.value;
                foundelement.amount = this.countlineItemTotal(foundelement.quantity,foundelement.rate);
            }else if(event.target.name === 'taxable'){
                foundelement.taxable = event.target.checked;
            }else if(event.target.name === 'discountType'){
                this.discountTypeValue = event.target.value;
            }else if(event.target.name === 'discount'){
                this.discountValue = event.target.value;
            }else if(event.target.name === 'taxPercent'){
                this.taxId = event.target.value.toString();
                const index = this.taxPercentOptions.findIndex(row => row.value === this.taxId);
                this.taxValue = this.taxPercentOptions[index].id;
                this.taxSFID = this.taxPercentOptions[index].idSF;
                this.InvoiceCustomeData.taxRate = this.taxPercentOptions[index].label;
            }else if(event.target.name === 'incomeAccount'){
                foundelement.incomeAccount = event.target.value;
            }else if(event.target.name === 'productDesc'){
                foundelement.productDesc = event.target.value;
            }else if(event.target.name === 'terms'){ 
                this.terms = event.target.value;
                const index = this.termsOption.findIndex(row => row.value === this.terms);
                this.termSFID = this.termsOption[index].idSF;
            }else if(event.target.name === 'invoiceDate'){
                this.InvoiceCustomeData.invoiceDate = event.target.value;
            }else if(event.target.name === 'invoiceDueDate'){
                this.InvoiceCustomeData.dueDate = event.target.value;
            }else if(event.target.name === 'discountAfterTax'){
                this.discountAfterTax = event.target.checked;
            }
            this.countsubTotal();
            this.calculateTaxableAmt();
            this.caculateDiscount();
            this.caculateTax();
            this.calculateBill();
        }catch(error){
            console.log(error);
        }
       
    }
    clearHandler(){

        this.isLoading = true;
        this.invoiceDueDate = this.invoiceDate='';
        this.invoiceSubtotal = ZEROWITHTWODECIMAL;
        this.taxableSubtotal = ZEROWITHTWODECIMAL;
        this.discountValue = ZERO;
        this.discountAfterTax = true;
        this.shipping = '0.00';
        this.totalBill = ZEROWITHTWODECIMAL;
        this.lineitemsRecords = [];
        this.totalTaxValue=ZEROWITHTWODECIMAL;
        this.taxId='';
        let searchParams = '';
        if (typeof window !== 'undefined') {
            searchParams = new URLSearchParams(window.location.href);
        }
        if(searchParams.get('t') === null || typeof searchParams.get('t') === 'undefined'){
            this.oppId = null;
            this.accId = null;
            this.opAccId = null;
            const updatedInvoiceData = JSON.parse(JSON.stringify(this.customerInvoice));
            updatedInvoiceData.invoiceType = 'blankProduct';
            this.customerInvoice = updatedInvoiceData;
        }   
        
        this.discountTotal = ZEROWITHTWODECIMAL;
        this.getInvoiceObjectOptions('Account');
        this.getInvoiceObjectOptions('salesTax');
        this.getInvoiceObjectOptions('Term',true);
    }
    caculateTax(){
        const discountTotal = parseFloat(this.discountTotal) || ZERO,
              taxableSubtotal = parseFloat(this.taxableSubtotal) || ZERO;
        if(this.discountAfterTax === true){
            this.totalTaxValue = (this.taxableSubtotal * (this.taxValue/HUNDRED)).toFixed(TWO);
        }
        else if(taxableSubtotal === ZERO){
            this.totalTaxValue = ZERO;
        }else{
            let taxDiscount = (discountTotal * taxableSubtotal) / this.invoiceSubtotal,
                taxAmt = taxableSubtotal + taxDiscount;
            this.totalTaxValue = (taxAmt * (this.taxValue/HUNDRED)).toFixed(TWO);

        }
    }
   
    caculateDiscount(){
        if(this.discountTypeValue === 'value'){
            this.discountTotal = -Math.abs(this.discountValue).toFixed(TWO);
        }else if(this.discountTypeValue === 'percent'){
            this.discountTotal = -Math.abs(this.invoiceSubtotal * (this.discountValue/HUNDRED)).toFixed(TWO);
        }
    }
    countlineItemTotal(quantity,price){
        this.tempVar = true;
        const numVal1 = quantity * price;
        return numVal1.toFixed(TWO);
    }
    countsubTotal(){
        let subTotal = ZERO;
        const temparr = this.lineitemsRecords;
        for(let index=ZERO;index<temparr.length;index+=ONE){
            subTotal += Number(temparr[index].amount);
        }
        this.invoiceSubtotal = subTotal.toFixed(TWO);
    }
    previousHandler(){

        if (typeof window !== 'undefined') {

            const storeEvent = new CustomEvent('myevent', 
            { detail: this.customerInvoice}
            );
            this.dispatchEvent(storeEvent);

        }
        
    }
    
    createInvoiceHandler(){
        console.log('createInvoiceHandler');
        
        this.disSave = true;
        let isValid = true;
        const inputFields = this.template.querySelectorAll('.validate');
         inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            if(this.lineitemsRecords && this.lineitemsRecords.length > ZERO){
                
                for(let index=ZERO;index<this.lineitemsRecords.length;index+=ONE){
                    if(this.lineitemsRecords[index].taxable === ONE){
                        this.lineitemsRecords[index].taxable = true;}
                    else if(this.lineitemsRecords[index].taxable === ZERO){
                        this.lineitemsRecords[index].taxable = false;}
                }
                console.log('this.lineitemsRecords ='+this.lineitemsRecords);
                
                this.productArray = this.lineitemsRecords.filter(product =>
                    (product.qbProductCode === null || typeof product.qbProductCode === 'undefined' || product.qbProductCode === '') &&
                    product.productId !== null &&
                    product.productName != null &&
                    product.productName != ''
                );
                console.log('productArray = '+ JSON.stringify(this.productArray));
                if(this.productArray && this.productArray.length > ZERO &&  this.invoiceOppProduct === true && this.invoiceConfig.CreateOpportunityProduct === true){
                    for(let index=ZERO;index<this.productArray.length;index+=ONE){
                        console.log('this.productArray = ',this.productArray[index]);
                        
                        this.insertproduct(this.productArray[index])
                    }

                }else{
                    this.generateInvoicefunc();
                }
            }else{
                this.disSave = false;
                this.disSaveNsend = false;
                this.showNotification('Please add atleast one line item','error');
            }
        }else{
            
            this.showNotification('Please resolved all errors','error');
            this.disSave = false;
            this.disSaveNsend = false;
        }  
    }
    
    insertproduct(productArray){
        console.log('insertproduct');
        
        insertProductOnQb({
            lineItemData:JSON.stringify(productArray)
          }).then( (result)   => {
            console.log('result = '+result);
            
            if(result === 'success'){
                this.insertProductStatus.push('success');
                
            }else if(result === 'Check Quickbook Connection to Salesforce'){
                this.refreshToken('insertproduct')
            }
            if(this.insertProductStatus.length === this.productArray.length){
                this.generateInvoicefunc();
            }
            //this.showNotification(result,'error');
            //this.isLoading = false;
            
          }).catch(error => {
            
            console.log('error = ',error);
            
            this.showNotification(error.body.message,'error');
            if (typeof window !== 'undefined') {
                window.location.reload();
            }
          });
          //return insProduct;
    }
    setDefault(value, defaultValue) {
        this.tempVar = true;
        if(value === '' || value === null){
            return defaultValue;
        }
        return value;
    }
    generateInvoicefunc(){
        if(this.accId === '' || this.accId === null){
            this.InvoiceCustomeData.getAccid = this.opAccId;
        }else{
            this.InvoiceCustomeData.getAccid = this.accId;
        }
        this.InvoiceCustomeData.discountValue = this.setDefault(this.discountValue, ZERO);
        this.InvoiceCustomeData.discountTotal = this.setDefault(this.discountTotal, ZERO);
        this.InvoiceCustomeData.terms = this.setDefault(this.terms, '');
        this.InvoiceCustomeData.discountTypeValue = this.setDefault(this.discountTypeValue, '');
        this.InvoiceCustomeData.taxId = this.setDefault(this.taxId, '');
        this.InvoiceCustomeData.getOppid = this.setDefault(this.oppId, '');
        this.InvoiceCustomeData.taxAmount = this.setDefault(this.totalTaxValue, ZERO);
        this.InvoiceCustomeData.shipping = this.setDefault(this.shipping, ZERO);
        this.InvoiceCustomeData.taxRate = this.setDefault(this.taxValue, '');
        this.InvoiceCustomeData.discountAfterTax = !this.discountAfterTax;
        this.InvoiceCustomeData.taxSFID = this.setDefault(this.taxSFID, '');
        this.InvoiceCustomeData.termSFID = this.setDefault(this.termSFID, '');
        this.InvoiceCustomeData.customerQBId = this.setDefault(this.customerInvoice.customerQBId, '');
        this.InvoiceCustomeData.invoiceQBID = this.invoiceQBID;
        if (this.syncToken) {
            this.InvoiceCustomeData.syncToken = this.syncToken;
        }else{
            this.InvoiceCustomeData.syncToken = '0';
        }
        const billingInfoArry = ['billingLine','billingCity','billingCountry','billingPostalCode','billingCountrySubDivisionCode'],
              personalInfoArry = ['givenName','familyName','displayName','email','phone','mobile','fax','website','companyName','currencyCode','middleName'],
              shippingInfoArry = ['shippingLine','shippingCity','shippingCountry','shippingPostalCode','shippingCountrySubDivisionCode'];
        personalInfoArry.forEach(fieldName => {
                this.customerData.personalInfo[fieldName] = this.customerInvoice[fieldName.charAt(ZERO).toUpperCase() + fieldName.slice(ONE)];
            });

        billingInfoArry.forEach(fieldName => {
            this.customerData.billingInfo[fieldName] = this.customerInvoice[fieldName.charAt(ZERO).toUpperCase() + fieldName.slice(ONE)];
        });

        shippingInfoArry.forEach(fieldName => {
            this.customerData.shippingInfo[fieldName] = this.customerInvoice[fieldName.charAt(ZERO).toUpperCase() + fieldName.slice(ONE)];
        });
        this.customerData.customerQBId = this.customerInvoice.customerQBId;
        this.customerData.invoiceType = this.customerInvoice.invoiceType;
        this.customerData.id = this.customerInvoice.Id;
        console.log('a = '+JSON.stringify(this.lineitemsRecords));
        
        generateInvoice({
                contactDetails:JSON.stringify(this.customerData),
                invoiceCustomeData: JSON.stringify(this.InvoiceCustomeData),
                lineItemData:JSON.stringify(this.lineitemsRecords)
            }).then((result)  => {
                
                const idObject = {};
                result.split('&').forEach((pair) => {
                    const keyValue = pair.split('=');
                    idObject[keyValue[ZERO]] = keyValue[ONE];
                });
                this.invoiceQBID = idObject.invoiceQBID;
                this.syncToken = idObject.invoiceSyncToken;
                if(idObject.success === 'true'){
                    const invoiceRecordId = idObject.recordId;
                    if(this.sendInvoice  === true){
                        sendInvoiceEmail({
                            invoiceId:idObject.invoiceId
                        })
                        .then(resultStr  => {
                            if(resultStr === 'success'){
                                this.showNotification('Invoice created and sent successfully','success');
                                if(invoiceRecordId) {
                                    this.navigateToInvoiceRecord(invoiceRecordId);
                                }
                            }else if(resultStr === 'error'){
                                this.showNotification('Invoice created successfully but failed to sent email','success');
                            }else if(resultStr === 'Check Quickbook Connection to Salesforce'){
                                this.refreshToken('sendEmail');
                            }else{
                                this.disSave = false;
                                this.disSaveNsend = false;
                                this.showNotification(resultStr,'error');
                            }
                          
                            
                        })
                        .catch(error => {
                            
                            console.log('error = ',error);
                            this.disSave = false;
                            this.disSaveNsend = false;
                            this.showNotification(error.body.message,'error');
                            if (typeof window !== 'undefined') {
                                window.location.reload();
                            }
                        });

                    }else{
                        this.showNotification('Invoice created successfully','success');
                        if(invoiceRecordId) {
                          this.navigateToInvoiceRecord(invoiceRecordId);
                        }
                    }
                }else if(result === 'Check Quickbook Connection to Salesforce'){
                    this.refreshToken('generateInvoice');
                }else if(idObject.success === 'fail in SF'){
                    this.disSave = false;
                    this.disSaveNsend = false;
                    this.showNotification(idObject.errorMessage,'error');
                }
                else{
                    this.disSave = false;
                    this.disSaveNsend = false;
                    this.showNotification(result,'error');
                }
              }).catch(error => {
                
                console.log('error 12 =',error);
                this.disSave = false;
                this.disSaveNsend = false;
                this.showNotification(error.body.message,'error');
                if (typeof window !== 'undefined') {
                    window.location.reload();
                }
              });
            
    }
    refreshToken(clsName){
        refreshToken({})
        .then(() => {
            if(clsName === 'generateInvoice'){
                this.generateInvoicefunc();
            }else if(clsName === 'insertproduct'){
               this.createInvoiceHandler();
            }else if(clsName === 'sendEmail'){
               this.sendEmail();
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToastMessage('error',error.body.message);
        });
    }
    navigateToInvoiceRecord(invoiceId){
        this[NavigationMixin.Navigate]({
              attributes: {
                  actionName: 'view',
                  recordId: invoiceId
              },
              type: 'standard__recordPage'
        });
    }
    sendEmail(invId){
        let resultStr = '';
        const sendEmail = sendInvoiceEmail({
            invoiceId:invId
        })
        .then(result  => {
            resultStr = result;
        })
        .catch(error => {
            if(resultStr === 'Check Quickbook Connection to Salesforce'){
                this.refreshToken('sendEmail');
            }
            this.disSave = false;
            this.disSaveNsend = false;
            this.showNotification(error.body.message,'error');
            if (typeof window !== 'undefined') {
                window.location.reload();
            }
          });
        return sendEmail;
    }
    showNotification(msg,type) {

        if (typeof window !== 'undefined') {

            const evt = new ShowToastEvent({
                message: msg,
                title:'Invoice Generation',
                variant: type
            });
            this.dispatchEvent(evt);

        }

    }
    createNsendInvoiceHandler(){
        this.disSaveNsend = true;
        if(this.customerInvoice.Email === '' || this.customerInvoice.Email === null){
            this.disSave = false;
            this.disSaveNsend = false;
            this.showNotification('Please enter the email address from the previous step to Send & Save the invoice.','error');
        }else{
            this.sendInvoice = true;
            this.createInvoiceHandler();
        }
    }
}