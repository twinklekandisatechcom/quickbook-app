/**
 * @description       :
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on : 10-05-2023
 * @last modified on  : 17-05-2023
 * @last modified by  : Mangesh Kadam
 **/

public with sharing class QBInvoiceResponse {
    /**
     * @description Parses JSON string to an InvoiceRes object.
     * @param json The JSON string representing an invoice response.
     * @return InvoiceRes object deserialized from JSON.
    */

    public static InvoiceRes parseJSON(String json) {
      InvoiceRes objQBInvoiceRes = (InvoiceRes) System.JSON.deserialize(
        json,
        InvoiceRes.class
      );
      return objQBInvoiceRes;
    }
    /**
     * @description Represents a line item in the invoice with associated details.
     */
    public class Line {
      public String Id;
      public Integer LineNum;
      public Double Amount;
      public String DetailType;
      public String Description;
      public SalesItemLineDetail SalesItemLineDetail;
      public CustomField SubTotalLineDetail;
      public DiscountLineDetail DiscountLineDetail;
    }
     /**
     * @description Details of a sales item line within an invoice.
     */
    public class SalesItemLineDetail {
      public String Id;
      public CurrencyRef ItemRef;
      public Double UnitPrice;
      public Decimal Qty;
      public TaxCodeRef TaxCodeRef;
      public CurrencyRef ClassRef;
    }
    /**
     * @description Details about any discount applied to a line item.
     */
    public class DiscountLineDetail {
          public Boolean PercentBased ; 
          public Double DiscountPercent ; 
          public CurrencyRef DiscountAccountRef ; 
    }
    /**
     * @description Reference to the tax code.
     */
    public class TaxCodeRef {
      public String value;
    }
    /**
     * @description Currency reference with value and name.
     */
    public class CurrencyRef {
      public String value;
      public String name;
    }
    /**
     * @description Represents a custom field associated with the transaction.
     */
    public class CustomField {
      public string TxnId;
      public string TxnType;
    }
    /**
     * @description Represents a customized field with specific properties.
     */
    public class xCustomField {
      public string DefinitionId;
      public string Name;
      public string Type;
      public string StringValue;
    }
    /**
     * @description Billing address details for the invoice.
     */
    public class BillAddr {
      public String Id;
      public String Line1;
      public String City;
      public String CountrySubDivisionCode;
      public String Country;
      public String PostalCode;

      public String Line2;
      public String Line3;
      public String Line4;
      public String Line5;
    }
     /**
     * @description Shipping address details for the invoice.
     */
    public class ShipAddr {
      public String Id;
      public String Line1;
      public String City;
      public String CountrySubDivisionCode;
      public String Country;
      public String PostalCode;

      public String Line2;
      public String Line3;
      public String Line4;
      public String Line5;
    }
    /**
     * @description Metadata information like creation and last updated time.
     */
    public class MetaData {
      public String CreateTime;
      public String LastUpdatedTime;
    }
    /**
     * @description Tax details for the transaction, including total tax and individual tax lines.
     */
    public class TxnTaxDetail {
      public TxnTaxCodeRef TxnTaxCodeRef;
          public Double TotalTax;   
          public TaxLine[] TaxLine;
    }
    /**
     * @description Reference to a transaction tax code.
     */
    public class TxnTaxCodeRef {
      public String value;  
    }
    /**
     * @description Represents a line item for tax within the transaction.
     */
    public class TaxLine {
      public Double Amount; 
      public String DetailType; 
      public TaxLineDetail TaxLineDetail;
    }
    /**
     * @description Details of a tax line, including the tax rate and taxable amount.
     */
    public class TaxLineDetail {
      public TaxRateRef TaxRateRef;
      public boolean PercentBased;
      public Double TaxPercent; 
      public Double NetAmountTaxable;   
    }
    /**
     * @description Reference to a tax rate.
     */
    public class TaxRateRef {
      public String value;  
    }
    /**
     * @description Represents a memo added by the customer.
     */
    public class xCustomerMemo {
      public String value;
    }
    /**
     * @description Contains main properties of an invoice.
     */
    public class XInvoice {
      public Double Deposit;
      public String EInvoiceStatus;
      public Boolean AllowIPNPayment;
      public Boolean AllowOnlinePayment;
      public Boolean AllowOnlineCreditCardPayment;
      public Boolean AllowOnlineACHPayment;
      public String domain;
      public Boolean sparse;
      public String Id;
      public String SyncToken;
      public MetaData MetaData;
      public List<xCustomField> CustomField;
      public String DocNumber;
      public String TxnDate;
      public CurrencyRef CurrencyRef;
      public List<CustomField> LinkedTxn;
      public List<Line> Line;
      public TxnTaxDetail TxnTaxDetail;
      public CurrencyRef CustomerRef;
      public CurrencyRef SalesTermRef;
      public BillAddr BillAddr;
      public ShipAddr ShipAddr;
      public String DueDate;
      public BillEmail BillEmail;
      public Double TotalAmt;
      public Boolean ApplyTaxAfterDiscount;
      public String PrintStatus;
      public String EmailStatus;
      public Double Balance;
      public xCustomerMemo CustomerMemo;
      public String PrivateNote;
      public Double HomeTotalAmt;
      public Double HomeBalance;
      public Double ExchangeRate;
    }
    /**
     * @description Represents the email address associated with the billing details.
     */
    public class BillEmail {
      public String Address;
    }
    /**
     * @description Contains query response for multiple invoices.
     */
    public class XQueryResponse {
      public List<XInvoice> Invoice;
    }
    /**
     * @description Represents a response containing a query response for invoices.
     */
    public class InvoiceRes {
      public XQueryResponse QueryResponse;
    }
    
    /**
     * @description Represents a response containing a single invoice.
     */
    public class InvoiceSingleRes {
      public XInvoice Invoice;
    }
  }