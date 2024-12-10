/**
 * @description : this class encapsulates functionalities for handling token management, checking organization settings
 * and securely managing encrypted data
 */
public with sharing class Utils {

    /**
     * @description : This method is useful for managing session tokens in applications 
     * where timely validation is crucial, ensuring that tokens are only used when still valid.
     * @param lastRefreshDate Accepts a DateTime object.
     * @return Boolean
     */
    public static Boolean checkTokenExpiry(DateTime lastRefreshDate){
		Boolean flag = false;
		try{
            DateTime currDt = System.now();
            Long previousDate = lastRefreshDate.getTime();
            Long currentDate = currDt.getTime();
            if(currDt.isSameDay(lastRefreshDate)){
                Long milliseconds = currentDate - previousDate;
                Long hours = (milliseconds / 60000) / 60;
                if(hours <= 0){
                    Long mins = milliseconds / 60000;
                    if(mins <= 25){
                        flag = true;
                    }
                }
            }
		}catch(Exception e){
		    flag = false;
		}
		return flag;
	}

    /**
     * @description : This method is useful for the currency configuration of the org
     * allowing for dynamic handling of currency-related operations.
     * @return boolean
     */
    @AuraEnabled
    public static boolean getIsMultiCurrencyOrg() {
        boolean isMultiCurrecyOrg = false;
        try {
            //isMultiCurrecyOrg = Schema.getGlobalDescribe().containsKey('CurrencyType');
            isMultiCurrecyOrg = UserInfo.isMultiCurrencyOrganization();
        } catch (Exception e) {
            HandleCustomException.logException(e);
        }
        return isMultiCurrecyOrg;
    }

    /**
     * @description : This method is essential for securely processing sensitive information that has been encrypted
     * @param encryptedData Accepts a String representing the encrypted data.
     * @return a String containing the decrypted data, or null if an error occurs during the decryption process.
     */
    public static String processDecryption(string encryptedData){ 

        String decryptedData = ''; 
        String expMsg = '';
        
        try{ 

            if(String.isNotBlank(encryptedData)){
                Blob data = EncodingUtil.base64Decode (encryptedData); 
                
                // Get the hex key from the encrypted field
                KTQB__Encryption_Configuration__c setting = KTQB__Encryption_Configuration__c.getOrgDefaults();
                Blob cryptoKey = EncodingUtil.base64Decode(setting.KTQB__Encryption_Key__c);
    
                Blob dataToDecrypt = Crypto.decryptWithManagedIV ('AES256', cryptoKey, data); 
    
                decryptedData = dataToDecrypt.toString(); 
            }

        }catch(Exception e){ 

            expMsg = e.getMessage();
        } 

        return (String.isEmpty(expMsg) ?  decryptedData :  null);  

    }

    /**
     * @description : This method is used for securely encrypting sensitive information
     * @param decryptedData Accepts a String representing the data to be encrypted.
     * @return a String containing the encrypted data, or null if an error occurs during the encryption process.
     */
     public static String processEncryption(String decryptedData){ 

        String b64Data = '';
        String expMsg = '';
        try{
            
            if(String.isNotBlank(decryptedData)){
                KTQB__Encryption_Configuration__c setting = KTQB__Encryption_Configuration__c.getOrgDefaults();
                String strKey = setting.KTQB__Encryption_Key__c;
                Blob cryptoKey = EncodingUtil.base64Decode(strKey);
        
        
                Blob data = Blob.valueOf(decryptedData); 
        
                Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data ); 
        
                b64Data = EncodingUtil.base64Encode (encryptedData);  
            }

        }catch(Exception e){
            expMsg = e.getMessage();
        }
        
        return (String.isEmpty(expMsg) ?  b64Data :  null);
    } 

}