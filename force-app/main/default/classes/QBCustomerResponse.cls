/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on        : 23-06-2023
 * @last modified on  : 23-06-2023
 * @last modified by  : Mangesh Kadam
 * Modified on 10-09-2024 by Twinkle
 **/
public without sharing class QBCustomerResponse {
    /**
     * @description Parses the JSON string into a CustomerRes object.
     *
     * @param json The JSON string to parse.
     * @return A CustomerRes object representing the parsed JSON data.
    */
    public static CustomerRes parseJSON(String json) {
      CustomerRes objQBCustomer = (CustomerRes) System.JSON.deserialize(
        json,
        CustomerRes.class
      );
      return objQBCustomer;
    }
    /**
     * @description Represents the billing address of a customer.
    */
    public class BillAddr {
      public String Id;
      public String Line1;
      public String Line2;
      public String Line3;
      public String Line4;
      public String Line5;
      public String City;
      public String Country;
      public String CountrySubDivisionCode;
      public String PostalCode;
    }
    /**
     * @description Represents the currency reference associated with a customer.
    */
    public class CurrencyRef {
      public String value;
      public String name;
    }
    /**
     * @description Contains metadata information such as creation and last updated time.
    */
    public class MetaData {
      public String CreateTime;
      public String LastUpdatedTime;
    }
    /**
     * @description Represents the primary email address of a customer.
    */
    public class PrimaryEmailAddr {
      public String Address;
    }
    /**
     * @description Represents a web address associated with a customer.
    */
    public class WebAddr {
      public String URI;
    }
    /**
     * @description Represents the customer type reference.
    */
    public class CustomerTypeRef {
      public String value;
    }
    /**
     * @description Represents the primary phone number of a customer.
    */
    public class PrimaryPhone {
      public String FreeFormNumber;
    }
    /**
     * @description Represents a customer object containing various attributes.
    */
    public class XCustomer {
      public Boolean Taxable;
      public BillAddr BillAddr;
      public BillAddr ShipAddr;
      public String Notes;
      public Boolean Job;
      public Boolean BillWithParent;
      public Decimal Balance;
      public Decimal BalanceWithJobs;
      public CurrencyRef CurrencyRef;
      public String PreferredDeliveryMethod;
      public Boolean IsProject;
      public String domain;
      public Boolean sparse;
      public String Id;
      public String SyncToken;
      public MetaData MetaData;
      public String Title;
      public String GivenName;
      public String MiddleName;
      public String FamilyName;
      public String Suffix;
      public String FullyQualifiedName;
      public String CompanyName;
      public String DisplayName;
      public String PrintOnCheckName;
      public Boolean Active;
      public PrimaryEmailAddr PrimaryEmailAddr;
      public WebAddr WebAddr;
      public CustomerTypeRef CustomerTypeRef;
      public PrimaryPhone PrimaryPhone;
      public PrimaryPhone Mobile; 
      public PrimaryPhone Fax;
    }
    /**
     * @description Represents the query response containing a list of customers.
    */
    public class QueryResponse {
      public List<XCustomer> Customer;
    }
  
    public QueryResponse QueryResponse;
    /**
     * @description Represents a response containing a single customer object.
    */
    public class CustomerSingleRes {
      public XCustomer Customer;
    }
    /**
     * @description Represents the overall response containing the query response.
    */
    public class CustomerRes {
      public QueryResponse QueryResponse;
    }
  }