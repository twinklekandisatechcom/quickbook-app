/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on : 09-06-2023
 * @last modified on  : 09-06-2023
 * @last modified by  : Mangesh Kadam
 **/
public with sharing class QBErrorResponse {
    /**
     * @description Parses the JSON string into an errorCls object.
     *
     * @param json The JSON string containing the error response.
     * @return An errorCls object representing the parsed error data.
     */
    public static errorCls parseJSON(String json){
        return (errorCls) System.JSON.deserialize(json, errorCls.class);
    }
    /**
     * @description Represents the main error response structure.
     */
    public class errorCls{
        public cls_Fault Fault;
    }
    /**
     * @description Represents the fault section in an error response, which includes details on each error.
     */
    public class cls_Fault {
        public cls_Error[] Error;
        public String type; 
    }
    /**
     * @description Represents individual error details, including message, code, and specific element information.
     */
    public class cls_Error {
        public String Message;  
        public String Detail;   
        public String code; 
        public String element;  
    }
}