/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 23-06-2023
 * @last modified on  : 23-06-2023
 * @last modified by  : Mangesh Kadam
 * Modified on 10-10-2024 by Twinkle
 **/
public with sharing class QBCustomerTypeResponse {
  /**
     * @description Parses the JSON string into a CustomerTypeRes object.
     *
     * @param json The JSON string to parse.
     * @return A CustomerTypeRes object representing the parsed JSON data.
     */
    public static CustomerTypeRes parseJSON(String json) {
      CustomerTypeRes objQBCustomerTypeRes = (CustomerTypeRes) System.JSON.deserialize(
        json,
        CustomerTypeRes.class
      );
      return objQBCustomerTypeRes;
    }
    /**
     * @description Represents the response structure for customer types in QuickBooks.
     */
    public class CustomerTypeRes {
      public QueryResponse QueryResponse;
    }
    /**
     * @description Represents the query response containing a list of customer types.
     */
    public class QueryResponse {
      public List<XCustomerType> CustomerType;
    }
     /**
     * @description Represents a customer type with attributes such as Name and Id.
     */
    public class xCustomerType {
      public string Name;
      public string Id;
    }
  }