/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Help and Support Component [HelpSupportCmp]
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 */ 

public with sharing class HelpSupportController {
    /**
     * @description Help and Support Component : For User data in salesforce.
     * @return User data
     */
    @AuraEnabled public static User getUserInfo(){
        User ui = new User();
        try{
            ui = [ SELECT Id, FirstName, LastName, Email 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()
                   WITH USER_MODE 
                   LIMIT 1];
        }catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return ui;
    }
    
    /**
     * @description Help and Support Component : For set uploaded document length.
     * @param docIdList - Content document id.
     * @return Boolean
     */
    @AuraEnabled public static Boolean getFilesSize(List<String> docIdList){
        Boolean flag = true;
        try{
            List<ContentDocument> cdList = [ Select Id,ContentSize 
                                            From ContentDocument
                                            WHERE Id IN: docIdList
                                            WITH USER_MODE];
            Integer totalSize = 0;
            for(ContentDocument cd : cdList){
                totalSize += cd.ContentSize;
            }
            if(totalSize > 2097152){
                flag = false;
                if(Schema.sObjectType.ContentDocument.isDeletable()){
                    Database.delete(cdList, false,AccessLevel.User_mode);
                }
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return flag;
    }
    
    /** @description Help and Support Component : Wrapper Class. */
    public class SupportDataWrapper{
        /** @description Help and Support Component : For Record id. */
        public String firstName;
        /** @description Help and Support Component : For Record id. */
        public String lastName;
        /** @description Help and Support Component : For Record id. */
        public String email;
        /** @description Help and Support Component : For Record id. */
        public String enquiryValue;
        /** @description Help and Support Component : For Record id. */
        public String description;
    }
    
    /**
     * @description Help and Support Component : For sending email to support team.
     * @param supportData - User data.
     * @param filesData - Content document id.
     * @return Boolean
     */
    @AuraEnabled public static Boolean submitCase(String supportData, List<String> filesData){
        Boolean caseFlag = false;
        SupportDataWrapper sdWrap = new SupportDataWrapper();
        try {
            if(String.isNotBlank(supportData)){
                sdWrap = (SupportDataWrapper)JSON.deserialize(supportData,SupportDataWrapper.class);
            }

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String supportEmailsLabel = System.label.Support_Email;
            String[] supportEmailsArray = supportEmailsLabel.split(',');
            message.toAddresses = supportEmailsArray;
            message.subject = 'Quickbook Sync: New Support Request from '+sdWrap.email;
            String emailBody = 'Hello Kandisa Support Team,<br/><br/>';
            emailBody += 'A new support request has been made. Please find details below: <br/>';
            emailBody += '<p><b>Customer Name:</b> '+sdWrap.firstName+' '+sdWrap.lastName+'<br/>';
            emailBody += '<b>Customer email:</b> '+sdWrap.email+'<br/>';
            if(String.isNotBlank(sdWrap.enquiryValue)){
                emailBody += '<b>Type:</b> '+sdWrap.enquiryValue+'<br/>';
            }
            if(String.isNotBlank(sdWrap.description)){
                emailBody += '<b>Detailed Description:</b> '+sdWrap.description+'<br/>';
            }
            emailBody += '<br/>Please resolve the issue soon.';
            emailBody += 'Have a lovely time ahead.<br/><br/>';
            emailBody += 'Best Wishes,<br/>';
            emailBody += 'Kandisa Quickbook Sync for Salesforce<p>';
            message.setHtmlBody(emailBody);
            if(filesData.size()>0){
                message.setEntityAttachments(filesData);
            }
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success) {
                caseFlag = true;
            } else {
                caseFlag = false;
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return caseFlag;
    }

    /**
     * @description Help and Support Component : For deleting uploaded document before creating case.
     * @param deleteDocIds -  Content document ids.
     * @return Boolean
     */
    @AuraEnabled public static Boolean deleteDocuments(List<String> deleteDocIds){
        Boolean deleteFlag = false;
        try {
            if(deleteDocIds.size()>0){
                List<ContentDocument> cdList = [ SELECT Id, ContentSize 
                                                 FROM ContentDocument 
                                                 WHERE LatestPublishedVersionId IN: deleteDocIds
                                                 WITH USER_MODE ];
                // Delete ContentDocuments
                Database.DeleteResult[] drList = Database.delete(cdList, false,AccessLevel.User_mode);
                // Iterate through each returned result
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        deleteFlag = true;
                    }else {
                        deleteFlag = false;
                        break;
                    }
                }
            }
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return deleteFlag;
    }

    /*public class FilesDataWrapper{
        public String name;
        public String documentId;
        public String contentVersionId;
        public String contentBodyId;
        public String mimeType;
    }*/
}