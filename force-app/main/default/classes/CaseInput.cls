/**
 * @author Nilesh Kalal
 * @since Mon Dec 16 2024
 * @description Wrapper class for Financial Accounts Response
 */
public with sharing class CaseInput {
  /**
   * @description Account Name for the Case
   */
  @AuraEnabled
  public String intendedAccountName { get; set; }
  /**
   * @description Account Bsb for the Case
   */
  @AuraEnabled
  public String intendedAccountBsb { get; set; }
  /**
   * @description Account Number for the Case
   */
  @AuraEnabled
  public String intendedAccountNumber { get; set; }
  /**
   * @description Closure Reason for the Case
   */
  @AuraEnabled
  public String closureReason { get; set; }
  /**
   * @description Account Type for the Case
   */
  @AuraEnabled
  public String accountType { get; set; }
  /**
   * @description ProductName for the Case
   */
  @AuraEnabled
  public String productName { get; set; }
  /**
   * @description accountId is Customer Record Id for the Case
   */
  @AuraEnabled
  public String accountId { get; set; }
  /**
   * @description Finiancial Account Id for the Case
   */
  @AuraEnabled
  public String financialAccountId { get; set; }
  /**
   * @description Finiancial Account Id for the Case
   */
  @AuraEnabled
  public Id productId { get; set; }
}
