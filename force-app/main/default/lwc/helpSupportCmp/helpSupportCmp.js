import {LightningElement, track} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import deleteDocuments from "@salesforce/apex/HelpSupportController.deleteDocuments";
import getFilesSize from "@salesforce/apex/HelpSupportController.getFilesSize";
import getUserInfo from "@salesforce/apex/HelpSupportController.getUserInfo";
import submitCase from "@salesforce/apex/HelpSupportController.submitCase";

const ENQ_OPTIONS = [
        {"label": "Technical",
            "value": "Technical"},
        {"label": "Suggestions",
            "value": "Suggestions"},
        {"label": "Functionality Understanding",
            "value": "Functionality Understanding"},
        {"label": "Sales or Demo",
            "value": "Sales or Demo"},
        {"label": "Subscription",
            "value": "Subscription"},
        {"label": "Other",
            "value": "Other"}
    ],
    NUM_ONE = 1,
    NUM_ZERO = 0;

export default class HelpSupportCmp extends LightningElement {

    showLoading = false;

    enquiryOptions = ENQ_OPTIONS;

    error;

    @track supportData = {
        "description": "",
        "email": "",
        "enquiryValue": "",
        "firstName": "",
        "lastName": ""
    };

    documentIdList = [];

    @track docVersionList = [];

    @track fileData = [];

    documentVersionList = [];

    docList = [];

    deleteDocList = [];

    newFileDataList = [];

    fileMsg = "(Keep total file size <= 2MB)";

    fontColour = "yellowfont";

    fileAvailable = false;

    connectedCallback () {

        this.showLoading = true;
        this.preUserInfo();
    
    }
    renderedCallback() {
        if (!this.baseUrl) {
            this.baseUrl = window.location.origin;
        }
    }
    preUserInfo () {
      
        getUserInfo({}).then((result) => {
          
            if (result) {
              
                this.supportData.firstName = result.FirstName;
                this.supportData.lastName = result.LastName;
                this.supportData.email = result.Email;
              
            }
            this.showLoading = false;
          
        }).catch((error) => {
          
            this.error = error;
            this.showLoading = false;
            this.showToast("Something Went Wrong",
                "Please try again later",
                "error",
                "dismissable");
          
        });
      
    }

    handleChange (event) {
      
        const {name} = event.target;
        if (name === "FirstName") {
          
            this.supportData.firstName = event.detail.value;
          
        } else if (name === "LastName") {
          
            this.supportData.lastName = event.detail.value;
          
        } else if (name === "Email") {
          
            this.supportData.email = event.detail.value;
          
        } else if (name === "EnquiryType") {
          
            this.supportData.enquiryValue = event.detail.value;
          
        } else if (name === "Description") {
          
            this.supportData.description = event.detail.value;
          
        }
      
    }

    handleUploadFinished (event) {
      
        this.showLoading = false;
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach((file) => {
          
            const fileInfo = {
                "contentBodyId": file.contentDocumentId,
                "contentVersionId": file.contentVersionId,
                "documentId": file.documentId,
                "mimeType": file.mimeType,
                "name": file.name
            };
            this.fileData.push(fileInfo);
          
        });
        this.fileAvailable = true;
        this.documentVersionList = [];
        this.docList = [];
        this.fileData.forEach((element) => {
          
            this.documentVersionList.push(element.contentVersionId);
            this.docList.push(element.documentId);
          
        });
        this.getFilesSize();
        this.showLoading = false;

    }

    getFilesSize () {
      
        getFilesSize({
            "docIdList": this.docList
        }).then((result) => {
          
            if (result) {
              
                if (this.fileData.length > NUM_ONE) {
                  
                    this.fileMsg = `${this.fileData.length} files attached`;
                  
                } else {
                  
                    this.fileMsg = `${this.fileData.length} file attached`;
                  
                }
                this.fontColour = "greenfont";
                this.documentIdList = this.docList;
                this.docVersionList = this.documentVersionList;
              
            } else {
              
                this.fileData = this.fileData.filter((item) => !this.docList.includes(item.documentId));
                this.documentIdList = [];
                this.docVersionList = [];
                this.fileMsg = "(Keep total file size <= 2MB)";
                this.showToast("Total file size is bigger than 2 MB",
                    "Keep files size <= 2MB",
                    "error",
                    "dismissable");
              
            }
          
        }).catch((error) => {
          
            this.error = error;
            this.showLoading = false;
            this.showToast("Something Went Wrong",
                "Please try again later",
                "error",
                "dismissable");
          
        });
      
    }

    handleRemove (event) {
      
        this.showLoading = true;
        const indexToRemove = event.target.name;
        this.fileData = this.fileData.filter((file, index) => index !== indexToRemove);
        this.docVersionList.splice(indexToRemove,
            NUM_ONE);
        this.getFilesSize();
        this.deleteFiles();
        this.showLoading = false;
      
    }

    handleSubmit () {
      
        this.showLoading = true;
        submitCase({
            "filesData": this.docVersionList,
            "supportData": JSON.stringify(this.supportData)
        }).then((result) => {
          
            if (result) {
              
                this.showToast("Case has been submitted",
                    "You will hear back from us soon",
                    "success",
                    "dismissable");
                this.supportData.enquiryValue = "";
                this.supportData.description = "";
                this.showLoading = false;
                if (this.documentIdList.length > NUM_ZERO) {
                  
                    this.deleteFiles();
                    this.fileMsg = "(Keep total file size <= 2MB)";
                    this.fontColour = "yellowfont";
                    this.documentIdList = [];
                    this.docVersionList = [];
                    this.fileData = [];
                  
                }
              
            }
          
        }).catch((error) => {
          
            this.error = error;
            this.showLoading = false;
            this.showToast("Something Went Wrong",
                "Please try again later",
                "error",
                "dismissable");
          
        });
      
    }

    deleteFiles () {
      
        deleteDocuments({
            "deleteDocIds": this.deleteDocList
        }).then((result) => {
          
            if (result) {
                //
            }
          
        }).catch((error) => {
          
            this.error = error;
            this.showLoading = false;
            this.showToast("Something Went Wrong",
                "Please try again later",
                "error",
                "dismissable");
          
        });
      
    }

    showToast (tlt, msg, vrt, mod) {

        if (typeof window !== 'undefined') {
      
            const evt = new ShowToastEvent({
                "message": msg,
                "mode": mod,
                "title": tlt,
                "variant": vrt
            });
            this.dispatchEvent(evt);

        }
      
    }
  
}