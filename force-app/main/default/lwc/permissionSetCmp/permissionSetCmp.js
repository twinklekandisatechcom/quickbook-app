import {LightningElement, track} from "lwc";
import fetchPermission from "@salesforce/apex/PermissionSetController.fetchPermission";
import fetchPermissionSets from "@salesforce/apex/PermissionSetController.fetchPermissionSets";
const COLS = [
        {"fieldName": "name",
            "label": "Name",
            "sortable": true,
            "type": "text"},
        {"fieldName": "userName",
            "label": "User Name",
            "sortable": true,
            "type": "text"},
        {"fieldName": "email",
            "label": "Email",
            "sortable": true,
            "type": "Email"},
        {"fieldName": "isActive",
            "label": "Active",
            "type": "Checkbox"},
        {"fieldName": "profile",
            "label": "Profile",
            "sortable": true,
            "type": "text"}
    ],
    ONE = 1,
    ZERO = 0;

export default class PermissionSetCmp extends LightningElement {

    @track showLoading = false;  

    @track sortBy;

    @track sortDirection;

    @track permissionSets;

    @track adminUser = [];

    @track operationalUser = [];

    @track readOnlyUser = [];

    columns = COLS;

    connectedCallback () {

        this.getPermissionsets();
    
    }

    getPermissionsets () {

        this.showLoading = true;
        fetchPermissionSets({}).
            then((result) => {

                if (result.length > ZERO) {

                    for (let index = ZERO; index < result.length; index += ONE) {

                        if (result[index].permissionSetName === "Quickbook_Integration_User_Read_Only") {

                            this.readOnlyUser.push(result[index]);
                    
                        } else if (result[index].permissionSetName === "Quickbook_Integration_Operational") {

                            this.operationalUser.push(result[index]);
                    
                        } else if (result[index].permissionSetName === "Quickbook_Integration_Admin") {

                            this.adminUser.push(result[index]);
                    
                        }
                
                    }
            
                }
                this.showLoading = false;
        
            }).
            catch((error) => {

                this.error = error;
                this.showLoading = false;

                this.showToast("Something Went Wrong",
                    error,
                    "error",
                    "dismissable");
        
            });
        fetchPermission({}).
            then((result) => {

                if (result.length > ZERO) {

                    const pMap = new Map();
                    result.forEach((ele) => {

                        pMap.set(ele.name,
                            ele.setupUrl);
                
                    });
                    this.permissionSets = pMap;
            
                }
                this.showLoading = false;
        
            }).
            catch((error) => {

                this.error = error;
                this.showLoading = false;
                this.showToast("Something Went Wrong",
                    error,
                    "error",
                    "dismissable");
        
            });
    
    }

    handlePermission (event) {

        const permission = event.target.value,
            url = this.permissionSets.get(permission);
        window.open(url,
            "_blank");
    
    }

    sortAdmin (event) {

        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.adminUser = this.sortData(this.sortBy,
            this.sortDirection,
            this.adminUser);
    
    }

    sortOperational (event) {

        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.operationalUser = this.sortData(this.sortBy,
            this.sortDirection,
            this.operationalUser);
    
    }

    sortReadOnly (event) {

        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.readOnlyUser = this.sortData(this.sortBy,
            this.sortDirection,
            this.readOnlyUser);
    
    }

    sortData (fieldname, direction, data) {

        //For code scanning - 'class-methods-use-this'
        this.showLoading = false;
        let isReverse = 0;
        const keyValue = (akey) => akey[fieldname],
            num1 = 1,
            numminus1 = -1,
            parseData = JSON.parse(JSON.stringify(data));
        if (direction === "asc") {

            isReverse = num1;
        
        } else {

            isReverse = numminus1;
        
        }
        // Sorting data
        parseData.sort((xEle, yEle) => {

            let aEle = "",
                bEle = "";
            if (keyValue(xEle)) {

                aEle = keyValue(xEle);
            
            } else {

                aEle = "";
            
            }
            if (keyValue(yEle)) {

                bEle = keyValue(yEle);
            
            } else {

                bEle = "";
            
            }
            // Sorting values based on direction
            return isReverse * ((aEle > bEle) - (bEle > aEle));
        
        });
        return parseData;
    
    }

}