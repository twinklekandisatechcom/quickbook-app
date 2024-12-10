/**
 * @Author : Kandisa Technologies
 * @description Quickbook Setup : Callout Response Class
 * @created on        : 2023
 * @last modified on  : 17-1-2024
 * @last modified by  : Piyush V Ganorkar
 * Modified on 08/10/2024 by Twinkle
 */
public class InvoiceLineItemGlobalWrapper {
    @AuraEnabled @InvocableVariable(required=true)
    public Double UnitPrice;
    @AuraEnabled @InvocableVariable(required=true)
    public Decimal Qty;
    @AuraEnabled @InvocableVariable
    public String Description;
    @AuraEnabled @InvocableVariable(required=true)
    public String ProductQbId;
    @AuraEnabled @InvocableVariable(required=true)
    public String ProductName;
}