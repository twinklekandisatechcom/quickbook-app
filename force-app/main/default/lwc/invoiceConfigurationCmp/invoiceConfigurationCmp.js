import {LightningElement, track} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getCustomerFieldsNConfiguration from "@salesforce/apex/InvoiceConfigurationController.getCustomerFieldsNConfiguration";
import getFieldOption from "@salesforce/apex/InvoiceConfigurationController.getFieldOption";
import getInvoiceConfiguration from "@salesforce/apex/InvoiceConfigurationController.getInvoiceConfiguration";
import getInvoiceFields from "@salesforce/apex/InvoiceConfigurationController.getInvoiceFields";
import getObjectList from "@salesforce/apex/InvoiceConfigurationController.getObjectList";
import getSiteProfileId from "@salesforce/apex/InvoiceConfigurationController.getSiteProfileId";
import refreshToken from "@salesforce/apex/QuickBooksIntegerationController.refreshToken";
import saveObjectConfiguration from "@salesforce/apex/InvoiceConfigurationController.saveObjectConfiguration";
import syncQbInvoiceObject from "@salesforce/apex/QbMetaDataController.syncQbInvoiceObject";
import updateConfig from "@salesforce/apex/InvoiceConfigurationController.updateInvoiceConfig";

const MINUS_ONE_NUM = -1,
    ONE_NUM = 1,
    THREE_NUM = 3,
    TWO_NUM = 2,
    ZERO_NUM = 0,
    lineItemOption = [
        {"label": "No Data Found",
            "value": ""}
    ],
    options = [
        {"label": "No Data Found",
            "value": ""}
    ];

export default class InvoiceConfigurationCmp extends LightningElement {

    // This variable is for code scanning
    tempVar = false;

    @track showLoadingModal = false;

    @track showCustomerOptions = false;

    customerSelectedLable;

    Objectfields = [];

    @track QBField = [];

    @track PaymentFields = [];

    @track InvoiceFields = [];

    @track LineItemFields = [];

    @track options = options;

    @track lineItemOption = lineItemOption;

    @track selectedValue;

    @track flagIndicatingDataHasBeenLoadedInVariables = false;

    @track flagIndicatingDataHasBeenLoadedInVariables1 = false;

    @track flagIndicatingDataHasBeenLoadedInVariables2 = false;

    @track siteProfileId = "";

    @track siteProfileName = "";

    LineItemselectedLabel;

    LineItemselectedValue;

    oldLineItemselectedValue;

    oldpaymentSelectedValue;

    paymentSelectedValue;

    paymentSelectedLabel;

    oldCustomerChildObjectselectedValue;

    selectObjectLabel;

    objectType;

    LineItemChildObjectselectedValue = "";

    PaymentChildObjectselectedValue = "";

    customerFieldList = [];

    customerConfigFieldList = [];

    oldselectedValue;

    InvoiceRequiredField = [];

    CustomerRequiredField = [];

    LineItemRequiredField = [];

    PaymentRequiredField = [];

    lastRefreshEntity = "";

    handleSelectOption (event) {
        
        this.showLoading = true;
        this.objectType = "Invoice";
        
        this.selectObjectLabel = this.options[this.options.findIndex((row) => row.value === event.detail)].label;
        this.selectedValue = event.detail;
        this.lineItemObjectFields = [];
        this.LineItemselectedValue = "";
        this.paymentSelectedValue = "";
        this.paymentObjectFields = [];
        if (this.selectedValue) {

            this.fetchObjectNfields(
                this.selectedValue,
                "Invoice"
            );

        }
        this.disableSave = false;

    }

    lineItemObjectFields = [];

    paymentObjectFields = [];

    clearMapping () {

        if (this.objectType === "Invoice") {

            this.InvoiceFields = this.QBField.map((field) => ({...field,
                "value": ""}));
            this.QBField = this.QBField.map((field) => ({...field,
                "value": ""}));
            this.CustomerConfigfields = this.CustomerConfigfields.map((field) => ({...field,
                "value": ""}));

        } else if (this.objectType === "LineItem") {

            this.LineItemFields = this.QBField.map((field) => ({...field,
                "value": ""}));
            this.QBField = this.QBField.map((field) => ({...field,
                "value": ""}));

        } else if (this.objectType === "Payment") {

            this.PaymentFields = this.QBField.map((field) => ({...field,
                "value": ""}));
            this.QBField = this.QBField.map((field) => ({...field,
                "value": ""}));

        }

    }

    fetchObjectNfields (selectedValue, objectType) {

        if (selectedValue) {

            getInvoiceFields({"objectApiName": selectedValue,
                "type": objectType}).
                then((result) => {

                    this.Objectfields = result.Objectfields;
                    console.log('Objectfields = ',JSON.stringify(this.Objectfields));
                    const aObjectRes = result,
                        groupedByFieldType = this.Objectfields.reduce(
                            (aObjectRes, current) => {

                                const {fieldType} = current;
                                if (!aObjectRes[fieldType]) {

                                    aObjectRes[fieldType] = [];

                                }
                                aObjectRes[fieldType].push(current);
                                return aObjectRes;

                            },
                            {}
                        );
                    this.QBField = [...aObjectRes.invoiceField];
                    console.log('this.QBField = ',JSON.stringify(this.QBField));
                    this.QBField.forEach((item) => {

                        if (item.type === "REFERENCE" && item.name === "QB Customer") {

                            item.showReference = true;

                        } else {

                            item.showReference = false;

                        }
                        const dataType = (item.type || "").split(","),
                            noneOption = {"fieldType": "",
                                "label": "Select Fields",
                                "referencedObjectApiName": "",
                                "required": true,
                                "value": ""};
                        dataType.forEach((typ) => {

                            if (item.options && groupedByFieldType[typ.trim()]) {

                                item.options = [
                                    ...item.options,
                                    ...groupedByFieldType[typ.trim()]
                                ];

                            } else {

                                item.options = groupedByFieldType[typ.trim()];

                            }

                        });
                        if (item.options) {

                            item.options.sort((ele1, ele2) => ele1.label.localeCompare(ele2.label));
                            item.options = [
                                noneOption,
                                ...item.options
                            ];

                        }

                    });
                    if (objectType === "Invoice") {

                        this.lineItemOption = aObjectRes.childObject;
                        this.lineItemOption.sort((ele1, ele2) => ele1.label.localeCompare(ele2.label));
                        this.lineItemOption = [
                            {"label": "None",
                                "name": "",
                                "value": ""},
                            ...this.lineItemOption
                        ];
                        this.InvoiceFields = [...this.QBField];
                        if (this.selectedValue !== this.oldselectedValue) {

                            this.InvoiceFields.forEach((item) => {

                                item.value = "";

                            });
                            this.LineItemselectedValue = "";
                            this.paymentSelectedValue = "";
                            this.lineItemObjectFields = [];
                            this.LineItemFields.forEach((item) => {

                                item.value = "";

                            });

                        }
                        this.flagIndicatingDataHasBeenLoadedInVariables = true;
                        this.flagIndicatingDataHasBeenLoadedInVariables1 = true;
                        this.flagIndicatingDataHasBeenLoadedInVariables2 = true;
                        this.handlelineItemSelectOption();
                        this.handlePaymentSelectOption();
                        this.InvoiceRequiredField = this.Objectfields.filter((field) => !field.required && ![
                            "REFERENCE",
                            "BOOLEAN"
                        ].includes(field.fieldType));
                        console.log('a = ',this.selectedValue);
                        console.log('b = ',JSON.stringify(this.Objectfields));
                        
                        //this.selectObjectLabel = this.Objectfields[this.Objectfields.findIndex((row) => row.value === this.selectedValue)].label;
                        if (this.InvoiceFields) {

                            const qbCustomer = this.InvoiceFields.find((item) => item.label === "QB Customer");
                            if (qbCustomer && qbCustomer.options) {

                                const checkedOptions = qbCustomer.options.find((op) => op.value === qbCustomer.value);
                                this.CustomerChildObjectselectedValue = qbCustomer.value;
                                if (checkedOptions) {

                                    if (checkedOptions.referencedObjectApiName) {

                                        this.showCustomerOptions = true;
                                        this.getCustomerFields(checkedOptions.referencedObjectApiName);

                                    }

                                } else {

                                    this.showCustomerOptions = false;
                                    this.CustomerConfigfields = [];

                                }

                            }

                        }

                    } else if (objectType === "LineItem") {

                        this.LineItemFields = [...this.QBField];
                        if (this.oldLineItemselectedValue !== this.LineItemselectedValue) {

                            this.LineItemFields.forEach((item) => {

                                item.value = "";

                            });
                            this.lineItemObjectFields = [];

                        }
                        this.lineItemObjectFields = [...this.Objectfields];
                        this.flagIndicatingDataHasBeenLoadedInVariables1 = true;
                        this.LineItemRequiredField = this.Objectfields.filter((field) => !field.required && ![
                            "REFERENCE",
                            "BOOLEAN"
                        ].includes(field.fieldType));

                    } else if (objectType === "Payment") {

                        this.PaymentFields = [...this.QBField];
                        if (this.oldpaymentSelectedValue !== this.paymentSelectedValue) {

                            this.PaymentFields.forEach((item) => {

                                item.value = "";

                            });
                            this.paymentObjectFields = [];

                        }
                        this.paymentObjectFields = [...this.Objectfields];
                        this.flagIndicatingDataHasBeenLoadedInVariables2 = true;
                        this.PaymentRequiredField = this.Objectfields.filter((field) => !field.required && ![
                            "REFERENCE",
                            "BOOLEAN"
                        ].includes(field.fieldType));

                    } else if (objectType === "Customer") {

                        this.CustomerConfigfields = [...this.QBField];
                        if (this.oldCustomerChildObjectselectedValue !== this.CustomerChildObjectselectedValue) {

                            this.CustomerConfigfields.forEach((item) => {

                                item.value = "";

                            });

                        }
                        this.CustomerRequiredField = this.CustomerObjectfields.filter((field) => !field.required && ![
                            "REFERENCE",
                            "BOOLEAN"
                        ].includes(field.fieldType));

                    }
                    this.showLoading = false;

                }).
                catch((error) => {

                    this.error = error;
                    this.showLoading = false;

                });

        }

    }

    handlePaymentSelectOption (event) {

        this.showLoading = true;
        this.objectType = "Payment";
        this.disableSave = false;
        if (event) {

            this.paymentSelectedValue = event.detail;
            if (this.options && this.options.length > ZERO_NUM) {

                this.paymentSelectedLabel = this.options[this.options.findIndex((row) => row.value === event.detail)].label;

            } else {

                this.paymentSelectedLabel = "";

            }

        }
        if (this.paymentSelectedValue !== null) {

            this.fetchObjectNfields(
                this.paymentSelectedValue,
                "Payment"
            );

        }

    }

    cancelModal () {

        this.closeModal();
        this.connectedCallback();

    }

    getSiteProfileId () {

        getSiteProfileId({}).then((result) => {

            if (result) {

                if (result !== "" && result !== null) {

                    const idObject = {};
                    result.split("&").forEach((pair) => {

                        const keyValue = pair.split("=");
                        idObject[keyValue[ZERO_NUM]] = keyValue[ONE_NUM];

                    });
                    this.siteProfileId = idObject.profileId;
                    this.siteProfileName = idObject.profileName;

                }

            } else {

                this.showToastPopMessage(
                    "Something went wrong",
                    "error"
                );

            }

        }).
            catch((error) => {

                this.showToastPopMessage(
                    error.body.message,
                    "error"
                );

            });

    }

    handlelineItemSelectOption (event) {

        this.disableSave = false;
        this.showLoading = true;
        if (event) {

            this.LineItemselectedValue = event.detail;
            if (this.options && this.options.length > ZERO_NUM) {

                const index = this.options.findIndex((row) => row.value === this.LineItemselectedValue);
                if (index === MINUS_ONE_NUM) {

                    this.LineItemselectedLabel = "";

                } else {

                    this.LineItemselectedLabel = this.options[index].label;

                }

            } else {

                this.LineItemselectedLabel = "";

            }

        }
        if (this.LineItemselectedValue !== null) {

            this.fetchObjectNfields(
                this.LineItemselectedValue,
                "LineItem"
            );

        }

    }

    getObjectFields () {

        getObjectList({ }).
            then((data) => {

                if (data) {

                    this.options = [...data];
                    this.options.sort((ele1, ele2) => ele1.label.localeCompare(ele2.label));
                    this.flagIndicatingDataHasBeenLoadedInVariables = true;
                    if (this.selectedValue !== null) {
                        this.selectObjectLabel = this.options[this.options.findIndex((row) => row.value === this.selectedValue)].label;
                        this.fetchObjectNfields(
                            this.selectedValue,
                            "Invoice",
                            true
                        );

                    }

                }

            }).
            catch((error) => {

                this.showToastPopMessage(
                    `Something went wrong. Error - ${error}`,
                    "error"
                );

            });

    }

    // Modal popup
    @track isModalOpen = false;

    openModal () {

        // To open modal set isModalOpen track value as true
        this.isModalOpen = true;
        this.showLoadingModal = false;

    }

    closeModal () {

        this.isModalOpen = false;

    }

    handleLineItemNew (event) {

        this.LineItemselectedValue = event.detail;
        this.lineItemObjectFields = [];
        this.LineItemFields.forEach((item) => {

            item.value = "";

        });
        this.disableSave = false;

    }

    handlePaymentNew (event) {

        this.paymentSelectedValue = event.detail;
        this.paymentObjectFields = [];
        this.PaymentFields.forEach((item) => {

            item.value = "";

        });
        this.disableSave = false;

    }

    /*
     * End modal popup
     * Map object starts
     */
    modalHeader;

    mapInvoiceFields () {

        try {

            this.disableSave = false;
            this.objectType = "Invoice";
            this.modalHeader = "Map Invoice Object Fields";
            this.QBField = [...this.InvoiceFields];
            this.selectObjectLabel = this.options[this.options.findIndex((row) => row.value === this.selectedValue)].label;

            if (this.CustomerChildObjectselectedValue !== "" && this.CustomerChildObjectselectedValue !== null && typeof this.CustomerChildObjectselectedValue !== "undefined") {

                this.showCustomerOptions = true;

            } else {

                this.showCustomerOptions = false;

            }
            if (this.QBField) {

                const qbCustomer = this.QBField.find((item) => item.label === "QB Customer");

                if (qbCustomer && qbCustomer.options) {

                    const checkedOptions = qbCustomer.options.find((op) => op.value === qbCustomer.value);
                    this.CustomerChildObjectselectedValue = qbCustomer.value;

                    if (checkedOptions) {

                        if (checkedOptions.referencedObjectApiName) {

                            this.showCustomerOptions = true;

                        }

                    } else {

                        this.showCustomerOptions = false;
                        this.CustomerConfigfields = [];

                    }

                }

            }
            this.openModal();

        } catch (error) {

            /* Empty */
        }

    }

    mapLineItemFields () {

        this.disableSave = false;
        this.objectType = "LineItem";
        this.modalHeader = "Map LineItem Object Fields";
        this.QBField = [...this.LineItemFields];
        this.openModal();
        this.selectObjectLabel = this.lineItemOption[this.lineItemOption.findIndex((row) => row.value === this.LineItemselectedValue)].label;
    }

    mapPaymentFields () {

        this.disableSave = false;
        this.objectType = "Payment";
        this.modalHeader = "Map Payment Object Fields";
        this.QBField = [...this.PaymentFields];
        this.selectObjectLabel = this.lineItemOption[this.lineItemOption.findIndex((row) => row.value === this.paymentSelectedValue)].label;
        this.openModal();

    }

    // Map objects ends
    CustomerObjectfields = [];

    @track CustomerConfigfields = [];

    handleCustomerfieldChange (event) {

        try {

            const configName = event.target.dataset.configname,
                fieldConfigIndex = this.CustomerConfigfields.findIndex((field) => field.name === configName),
                selectedValue = event.detail.value;
            this.CustomerConfigfields[fieldConfigIndex].value = selectedValue;

        } catch (error) {

            /* Empty */
        }

    }

    getCustomerFields (matchedOption) {

        this.CustomerChildObjectselectedValue = matchedOption;
        this.CustomerConfigfields = [];
        this.customerFieldList = [];
        getCustomerFieldsNConfiguration({
            "customerObjectName": matchedOption
        }).
            then((result) => {

                if (result) {

                    this.CustomerObjectfields = result.Objectfields;
                    const aObjectRes = result,
                        groupedByFieldType = this.CustomerObjectfields.reduce(
                            (aObjectRes, current) => {

                                const {fieldType} = current;
                                if (!aObjectRes[fieldType]) {

                                    aObjectRes[fieldType] = [];

                                }
                                aObjectRes[fieldType].push(current);
                                return aObjectRes;

                            },
                            {}
                        ),
                        sortedGroupedArray = Object.keys(groupedByFieldType).reduce(
                            (acc, key) => {

                                acc[key] = groupedByFieldType[key].sort((ele1, ele2) => (ele1.label > ele2.label
                                    ? ONE_NUM
                                    : MINUS_ONE_NUM));
                                return acc;

                            },
                            {}
                        );
                    this.CustomerConfigfields = [...aObjectRes.invoiceField];
                    this.CustomerConfigfields.forEach((item) => {

                        const dataType = (item.type || "").split(","),
                            noneOption = {"fieldType": "",
                                "label": "Select Fields",
                                "referencedObjectApiName": "",
                                "required": true,
                                "value": ""};
                        dataType.forEach((typ) => {

                            if (item.options && sortedGroupedArray[typ.trim()]) {

                                item.options = [
                                    ...item.options,
                                    ...sortedGroupedArray[typ.trim()]
                                ];

                            } else {

                                item.options = sortedGroupedArray[typ.trim()];

                            }

                        });
                        if (item.options) {

                            item.options = [
                                noneOption,
                                ...item.options
                            ];

                        }

                    });
                    this.CustomerRequiredField = this.CustomerObjectfields.filter((field) => !field.required && ![
                        "REFERENCE",
                        "BOOLEAN"
                    ].includes(field.fieldType));
                    if (this.oldCustomerChildObjectselectedValue !== this.CustomerChildObjectselectedValue) {

                        this.CustomerConfigfields.forEach((item) => {

                            item.value = "";

                        });

                    }
                    this.showLoadingModal = false;

                }

            }).
            catch((error) => {

                this.showToastPopMessage(
                    error.body.message,
                    "error"
                );

            });

    }

    handlefieldChange (event) {
        try{
            const configName = event.target.dataset.configname,
            selectedValue = event.detail.value;
            console.log('configName = ',configName);
            
        if (configName === "QB Customer") {

            this.showLoadingModal = true;
            this.showCustomerOptions = true;
            const matchedOption = this.QBField[this.QBField.findIndex((field) => field.label === "QB Customer")].options.find((option) => option.value === selectedValue).referencedObjectApiName;
            this.customerSelectedLable = matchedOption;
            this.CustomerChildObjectselectedValue = matchedOption;
            if (matchedOption !== "" && matchedOption !== null && typeof matchedOption !== "undefined") {

                this.getCustomerFields(matchedOption);

            } else {

                this.CustomerConfigfields = this.CustomerConfigfields.map((field) => ({...field,
                    "value": ""}));
                this.showCustomerOptions = false;

            }

        }
        let fieldConfigIndex = "";
        if (this.objectType === "Invoice") {

            fieldConfigIndex = this.InvoiceFields.findIndex((field) => field.label === configName);
            console.log('fieldConfigIndex = ',fieldConfigIndex);
            console.log('this.InvoiceFields = ',JSON.stringify(this.InvoiceFields));
            
            this.InvoiceFields[fieldConfigIndex].value = selectedValue;
            console.log('selectedValue = ',selectedValue);
            
            console.log('this.InvoiceFields1 = ',JSON.stringify(this.InvoiceFields));

        } else if (this.objectType === "Payment") {

            fieldConfigIndex = this.PaymentFields.findIndex((field) => field.label === configName);
            this.PaymentFields[fieldConfigIndex].value = selectedValue;

        } else if (this.objectType === "LineItem") {

            fieldConfigIndex = this.LineItemFields.findIndex((field) => field.label === configName);
            this.LineItemFields[fieldConfigIndex].value = selectedValue;

        }
        }catch(error){
            console.log('error = ',error);
        }
        

    }

    @track showLoading = false;

    disableSave = true;

    incAccValue;

    termValue;

    taxValue;

    termsOptions;

    @track invoiceConfig;

    @track accountOptions;

    @track salesTaxOptions;

    @track fields = {
        "dateFields": [],
        "textFields": []
    };

    @track invoiceDateOptions = {
        "Invoice_Date": {
            "Days": "",
            "SelectedBeforeAfterFieldValue": "After",
            "options": [
                {
                    "label": "After",
                    "value": "After"
                },
                {
                    "label": "Before",
                    "value": "Before"
                }
            ],
            "value": ""
        },
        "Invoice_Due_Date": {
            "Days": "",
            "SelectedBeforeAfterFieldValue": "After",
            "options": [
                {
                    "label": "After",
                    "value": "After"
                },
                {
                    "label": "Before",
                    "value": "Before"
                }
            ],
            "value": ""
        }
    };

    connectedCallback () {

        this.showLoading = true;
        this.invoiceConfiguration();
        this.getSiteProfileId();

    }

    // Get Invoice Configuration from custom setting using apex class
    invoiceConfiguration () {

        this.showLoading = true;
        getInvoiceConfiguration({}).
            then((result) => {

                this.showLoading = true;
                if (result === null) {

                    this.showToastPopMessage(
                        "Something Went Wrong",
                        "error"
                    );

                } else {

                    this.invoiceConfig = result;
                    this.prepareOpportunityFields(result);
                    this.preTermOptions(result);
                    this.incAccValue = result.Income_Account;
                    this.termValue = result.Terms;
                    this.taxValue = result.Tax;
                    this.oldselectedValue = result.Invoice_Object;
                    this.selectedValue = result.Invoice_Object;
                    console.log('Invoice_Object = '+result.Invoice_Object);
                    
                    this.oldLineItemselectedValue = result.LineItem_Object;
                    this.LineItemselectedValue = result.LineItem_Object;
                    this.oldCustomerChildObjectselectedValue = result.Customer_Object;
                    this.CustomerChildObjectselectedValue = result.Customer_Object;
                    this.oldpaymentSelectedValue = result.Payment_Object;
                    this.paymentSelectedValue = result.Payment_Object;
                    this.getObjectFields();

                }

            }).
            catch((error) => {

                this.error = error;
                this.showToastPopMessage(
                    error.body.message,
                    "error"
                );
                this.showLoading = false;

            });

    }

    prepareOpportunityFields (data) {

        const allFields = data.opportunityFieldMap;
        this.fields.dateFields = [
            {
                "fieldType": "",
                "label": "Select",
                "value": ""
            }
        ];
        this.fields.textFields = [
            {
                "fieldType": "",
                "label": "Select",
                "value": ""
            }
        ];
        if (allFields) {

            allFields.forEach((element) => {

                if (element.fieldType && element.fieldType.toUpperCase() === "DATE") {

                    this.fields.dateFields.push(element);

                } else {

                    this.fields.textFields.push(element);

                }

            });

        }
        this.readInvoiceSetupData();

    }

    readInvoiceSetupData () {

        const fields = [
            "Invoice_Date",
            "Invoice_Due_Date"
        ];
        if (this.invoiceConfig) {

            fields.forEach((field) => {

                if (this.invoiceConfig[field] && this.invoiceConfig[field] !== "" && this.invoiceConfig[field].includes(";")) {

                    const val = this.invoiceConfig[field].split(";");
                    if (val && val.length === THREE_NUM) {

                        this.invoiceDateOptions[field].Days = val[ZERO_NUM];
                        this.invoiceDateOptions[field].SelectedBeforeAfterFieldValue = val[ONE_NUM];
                        this.invoiceDateOptions[field].value = val[TWO_NUM];

                    }

                }

            });

        }

    }

    prepareInvoiceSetupData () {

        const fields = [
            "Invoice_Date",
            "Invoice_Due_Date"
        ];
        if (this.invoiceConfig) {

            fields.forEach((field) => {

                let val = "";
                val += `${this.invoiceDateOptions[field].Days};`;
                val += `${this.invoiceDateOptions[field].SelectedBeforeAfterFieldValue};`;
                val += this.invoiceDateOptions[field].value;
                this.invoiceConfig[field] = val;

            });

        }

    }

    preTermOptions (data) {

        const arr = [
                {"label": "Select",
                    "value": ""}
            ],
            arr1 = [
                {"label": "Select",
                    "value": ""}
            ],
            arr2 = [
                {"label": "Select",
                    "value": ""}
            ];
        for (let index = 0; index < data.oppTerms.length; index += ONE_NUM) {

            const str = data.oppTerms[index].Name;
            arr.push({"label": str,
                "value": data.oppTerms[index].KTQB__QB_Id__c});

        }
        this.termsOptions = arr;
        for (let index = 0; index < data.oppAccount.length; index += ONE_NUM) {

            const str = data.oppAccount[index].Name;
            arr1.push({"label": str,
                "value": data.oppAccount[index].KTQB__QB_Id__c});

        }
        this.accountOptions = arr1;
        for (let index = 0; index < data.salesTax.length; index += ONE_NUM) {

            const str = `${data.salesTax[index].Name} ${data.salesTax[index].KTQB__Sales_Tax_Rate__c}%`;
            arr2.push({"label": str,
                "value": data.salesTax[index].KTQB__QB_Id__c});

        }
        this.salesTaxOptions = arr2;

    }

    // To handle any changes
    handleChange (event) {

        this.showLoading = true;
        this.disableSave = false;
        const {name} = event.target;
        if (name === "Save") {

            this.invoiceConfig.Save = event.target.checked;

        } else if (name === "Save_And_Send") {

            this.invoiceConfig.Save_And_Send = event.target.checked;

        } else if (name === "Create_Update_Qb_Payment_In_Sf") {

            this.invoiceConfig.Create_Update_Qb_Payment_In_Sf = event.target.checked;

        } else if (name === "incAcc") {

            this.incAccValue = event.detail.value;
            this.invoiceConfig.Income_Account = event.target.value;

        } else if (name === "terms") {

            this.termValue = event.detail.value;
            this.invoiceConfig.Terms = event.target.value;

        } else if (name === "tax") {

            this.taxValue = event.detail.value;
            this.invoiceConfig.Tax = event.target.value;

        } else if (name === "enable_opportunity_product") {

            this.invoiceConfig.EnableOpportunityProduct = event.target.checked;

        } else if (name === "create_opportunity_product") {

            this.invoiceConfig.CreateOpportunityProduct = event.target.checked;

        }
        this.showLoading = false;

    }

    handleInvoiceChange (event) {

        this.disableSave = false;
        if (event.target.name.includes("_After_Or_Before") || event.target.name.includes("_Days")) {

            if (event.target.name.includes("_After_Or_Before")) {

                let name = "";
                if (event.target.name.split("_After_Or_Before").length > ZERO_NUM) {

                    name = event.target.name.split("_After_Or_Before")[ZERO_NUM];

                } else {

                    name = "";

                }
                this.invoiceDateOptions[name].SelectedBeforeAfterFieldValue = event.target.value;

            } else if (event.target.name.includes("_Days")) {

                let name = "";
                if (event.target.name.split("_Days").length > ZERO_NUM) {

                    name = event.target.name.split("_Days")[ZERO_NUM];

                } else {

                    name = "";

                }
                this.invoiceDateOptions[name].Days = event.target.value;

            }

        }

    }

    refreshToken (clsName) {

        refreshToken({}).
            then(() => {

                if (clsName === "refresh") {

                    this.handleRefresh();

                }

            }).
            catch((error) => {

                this.showSpinner = false;
                this.showToastMessage(
                    "error",
                    error.body.message
                );

            });

    }

    // Sync the object
    handleRefresh (event) {

        let value = "";
        if (typeof event === "undefined") {

            value = this.lastRefreshEntity;

        } else {

            value = event.target.value;

        }
        this.showLoading = true;
        syncQbInvoiceObject({"type": value}).
            then((result) => {

                if (result === "") {

                    this.showToastPopMessage(
                        "Something went Wrong",
                        "error"
                    );

                } else if (result === "Check Quickbook Connection to Salesforce") {

                    this.lastRefreshEntity = value;
                    this.refreshToken("refresh");

                } else {

                    this.refreshOptions(value);

                }
                this.showLoading = false;

            }).
            catch((error) => {

                this.error = error;
                this.showLoading = false;
                this.showToastPopMessage(
                    error.body.message,
                    "error"
                );

            });

    }

    refreshOptions (value) {

        const optionRefresh = getFieldOption({"type": value}).then((result) => {

            if (result !== "" || result !== null) {

                const arr = [
                    {"label": "Select",
                        "value": ""}
                ];
                let successMsg = "";
                if (value === "salesTax") {

                    successMsg = "Sales Tax Refreshed from QB";

                } else if (value === "Account") {

                    successMsg = "Income Account Refreshed from QB";

                } else {

                    successMsg = `${value} Refreshed from QB`;

                }
                for (let index = 0; index < result.length; index += ONE_NUM) {

                    let str = "";
                    if (value === "salesTax") {

                        str = `${result[index].Name} ${result[index].KTQB__Sales_Tax_Rate__c}%`;

                    } else {

                        str = result[index].Name;

                    }
                    arr.push({"label": str,
                        "value": result[index].KTQB__QB_Id__c});

                }
                if (value === "Term") {

                    this.termsOptions = arr;

                } else if (value === "salesTax") {

                    this.salesTaxOptions = arr;

                } else if (value === "Account") {

                    this.accountOptions = arr;

                }

                this.showToastPopMessage(
                    successMsg,
                    "success"
                );

            } else {

                this.showToastPopMessage(
                    "Something Went Wrong",
                    "error"
                );

            }
            this.showLoading = false;

        }).
            catch((error) => {

                this.isLoading = false;
                this.showToastPopMessage(
                    error.body.message,
                    "error"
                );

            });
        return optionRefresh;

    }

    CustomerChildObjectselectedValue = "";

    handleSave () {

        try {

            const inputFields = this.template.querySelectorAll(".validate");
            let isValid = true;
            inputFields.forEach((inputField) => {

                if (!inputField.checkValidity()) {

                    inputField.reportValidity();
                    isValid = false;

                }

            });
            if (isValid) {

                if (this.lineItemObjectFields && this.lineItemObjectFields.length > ZERO_NUM) {

                    const foundIndex = this.lineItemObjectFields.findIndex((row) => row.referencedObjectApiName === this.selectedValue);
                    if (foundIndex !== MINUS_ONE_NUM) {

                        this.LineItemChildObjectselectedValue = this.lineItemObjectFields[foundIndex].value;

                    }

                }
                if (this.paymentObjectFields && this.paymentObjectFields.length > ZERO_NUM) {

                    const foundIndex = this.paymentObjectFields.findIndex((row) => row.referencedObjectApiName === this.paymentSelectedValue);
                    if (foundIndex !== MINUS_ONE_NUM) {

                        this.PaymentChildObjectselectedValue = this.paymentObjectFields[foundIndex].value;

                    }

                }
                this.showLoading = true;
                if (this.invoiceConfig.Save === false && this.invoiceConfig.Save_And_Send === false) {

                    this.invoiceConfig.Save = true;

                }
                this.prepareInvoiceSetupData();
                if (this.InvoiceFields) {

                    const qbCustomer = this.InvoiceFields.find((item) => item.label === "QB Customer");
                    if (qbCustomer && qbCustomer.options) {

                        const checkedOptions = qbCustomer.options.find((op) => op.value === qbCustomer.value);
                        if (checkedOptions) {

                            if (checkedOptions.referencedObjectApiName) {

                                this.CustomerChildObjectselectedValue = checkedOptions.referencedObjectApiName;

                            }

                        } else {

                            this.CustomerChildObjectselectedValue = "";

                        }

                    }

                }
                let checkFielding = true,
                    objectName = "",
                    requireField = "";
                checkFielding = this.InvoiceRequiredField.every((field) => {

                    requireField = field.label;
                    if (this.selectObjectLabel) {

                        objectName = this.selectObjectLabel;

                    } else {

                        objectName = "";

                    }
                    return this.InvoiceFields.some((item) => item.value === field.value);

                });
                if (this.CustomerChildObjectselectedValue && checkFielding === true) {

                    checkFielding = this.CustomerRequiredField.every((field) => {

                        requireField = field.label;
                        if (this.customerSelectedLable) {

                            objectName = this.customerSelectedLable;

                        } else {

                            objectName = "";

                        }
                        return this.CustomerConfigfields.some((item) => item.value === field.value);

                    });

                }
                if (this.LineItemselectedValue && checkFielding === true) {

                    checkFielding = this.LineItemRequiredField.every((field) => {

                        requireField = field.label;
                        if (this.LineItemselectedLabel) {

                            objectName = this.LineItemselectedLabel;

                        } else {

                            objectName = "";

                        }
                        return this.LineItemFields.some((item) => item.value === field.value);

                    });

                }

                const CustomerRequireField = this.CustomerConfigfields.filter((item) => item.require === true && !item.value),
                    InvoiceRequireField = this.InvoiceFields.filter((item) => item.require === true && !item.value),
                    LineItemRequireField = this.LineItemFields.filter((item) => item.require === true && !item.value),
                    PaymentRequireField = this.PaymentFields.filter((item) => item.require === true && !item.value);
                if (InvoiceRequireField === null || InvoiceRequireField.length === ZERO_NUM) {
                // The array is either null or empty
                } else {
                // The array is not null and has elements
                }
                if (checkFielding === false && objectName !== "" && requireField !== "") {

                    const message = `Please map the following required Salesforce fields of ${objectName}: ${requireField}`;
                    this.showToastPopMessage(
                        message,
                        "error"
                    );
                    this.showLoading = false;

                } else if (InvoiceRequireField.length > ZERO_NUM) {

                    const fieldNames = InvoiceRequireField.map((item) => item.label),
                        message = `Please map the following required QuickBook Invoice fields : ${fieldNames.join(", ")}`;
                    this.showToastPopMessage(
                        message,
                        "error"
                    );
                    this.showLoading = false;

                } else if (LineItemRequireField.length > ZERO_NUM) {

                    const fieldNames = LineItemRequireField.map((item) => item.label),
                        message = `Please map the following required QuickBook LineItem fields : ${fieldNames.join(", ")}`;
                    this.showToastPopMessage(
                        message,
                        "error"
                    );
                    this.showLoading = false;

                } else if (PaymentRequireField.length > ZERO_NUM && this.paymentSelectedValue !== "" && this.paymentSelectedValue !== null && typeof this.paymentSelectedValue !== "undefined") {

                    const fieldNames = PaymentRequireField.map((item) => item.label),
                        message = `Please map the following required QuickBook Payment fields : ${fieldNames.join(", ")}`;
                    this.showToastPopMessage(
                        message,
                        "error"
                    );
                    this.showLoading = false;

                } else if (CustomerRequireField.length > ZERO_NUM && this.CustomerChildObjectselectedValue !== "") {

                    const fieldNames = CustomerRequireField.map((item) => item.label),
                        message = `Please map the following required QuickBook Invoice Customer fields : ${fieldNames.join(", ")}`;
                    this.showToastPopMessage(
                        message,
                        "error"
                    );
                    this.showLoading = false;

                } else {

                    updateConfig({
                        "configData": JSON.stringify(this.invoiceConfig),
                        "customerItemChildObjectName": this.CustomerChildObjectselectedValue,
                        "invoiceObject": this.selectedValue,
                        "lineItemChildObjectName": this.LineItemChildObjectselectedValue,
                        "lineItemObject": this.LineItemselectedValue,
                        "paymentChildObjectName": this.PaymentChildObjectselectedValue,
                        "paymentObject": this.paymentSelectedValue
                    }).then((result) => {

                        if (result) {

                            this.saveObjectSetting(
                                this.InvoiceFields,
                                "Invoice"
                            );
                            this.saveObjectSetting(
                                this.CustomerConfigfields,
                                "Customer"
                            );
                            this.saveObjectSetting(
                                this.LineItemFields,
                                "LineItem"
                            );
                            this.saveObjectSetting(
                                this.PaymentFields,
                                "Payment"
                            );
                            this.showToastPopMessage(
                                "Invoice Configuration is Updated",
                                "success"
                            );
                            requireField = "";
                            checkFielding = true;
                            objectName = "";
                            this.showLoading = false;
                            this.oldCustomerChildObjectselectedValue = this.CustomerChildObjectselectedValue;

                        } else {

                            this.showToastPopMessage(
                                "Something went wrong",
                                "error"
                            );

                        }
                        this.closeModal();

                    }).
                        catch((error) => {

                            this.showLoading = false;
                            this.showToastPopMessage(
                                error.body.message,
                                "error"
                            );

                        });

                }
                this.disableSave = true;

            }

        } catch (error) {

            /* Empty */
        }

    }

    runAfterCompletion () {

        this.showLoading = false;
        this.showToastPopMessage(
            "Invoice Configuration is Updated",
            "success"
        );

    }

    saveObjectSetting (objFields, objType) {
        console.log('objFields = ',objFields);
        console.log('objType = ',objType);
        
        this.tempVar = true;
        saveObjectConfiguration({
            "objectFields": objFields,
            "objectType": objType
        });

    }

    showToastPopMessage (messageParam, variantParam) {

        if (typeof window !== 'undefined') {

            this.dispatchEvent(new ShowToastEvent({
                "message": messageParam,
                "title": "Invoice Configuration",
                "variant": variantParam
            }));

        }

    }

    handleAssignPermission () {
        
        window.open(
            `/lightning/setup/Profiles/page?address=%2F${this.siteProfileId}`,
            "_blank"
        );

    }

}