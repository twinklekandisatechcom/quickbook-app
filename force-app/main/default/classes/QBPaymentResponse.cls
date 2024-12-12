/**
 * @description       : class is designed to handle and parse JSON responses from QuickBooks
 * @author            : Kandisa Technologies Pvt Ltd
 * @group             :
 * @created on : 10-05-2023
 * @last modified on  : 10-05-2023
 * @last modified by  : Mangesh Kadam
 **/

public with sharing class QBPaymentResponse {
    
    /**
     * @description : parseJSON method is responsible for converting a JSON string of payment data into a structured Apex object.
     * @param json String accepts a JSON-formatted string.
     * @return an instance of the PaymentRes class.
    */  
    public static PaymentRes parseJSON(String json) {
      PaymentRes objQBPaymentRes = (PaymentRes) System.JSON.deserialize(
        json,
        PaymentRes.class
      );
      return objQBPaymentRes;
    }
  
    /**
     * @description inner class
     */
    public class xLinkedTxn {
      public String TxnId;
      public String TxnType;
    }
  
    /**
     * @description inner class
     */
    public class xLine {
      public Decimal Amount;
      public List<xLinkedTxn> LinkedTxn;
    }
    
  /**
     * @description inner class
     */
    public class xPayment {
      public String Id;
      public String SyncToken;
      public decimal TotalAmt;
      public decimal UnappliedAmt;
      public decimal ExchangeRate;
      public string TxnDate;
      public string PaymentRefNum;
      public List<xLine> Line;
      public xPaymentMethodRef PaymentMethodRef;
      public xPaymentMethodRef CustomerRef;
      public xPaymentMethodRef CurrencyRef;
    }

    /**
     * @description inner class
     */
    public class xPaymentMethodRef{
      public string value;
    }
  
    /**
     * @description inner class
     */
    public class QueryResponse {
      public List<xPayment> Payment;
    }
  
    /**
     * @description inner class
     */
    public class PaymentRes {
      public QueryResponse QueryResponse;
    }
  
    /**
     * @description inner class
     */
    public class PaymentSingleRes {
      public xPayment Payment;
    }
  }