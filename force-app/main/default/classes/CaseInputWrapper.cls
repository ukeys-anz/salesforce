/**
 * @author Nilesh Kalal
 * @since Mon Dec 16 2024
 * @description Wrapper class for Financial Accounts Response
 */
public with sharing class CaseInputWrapper {
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

  /**
   * @description Salesforce Case Number for the Case
   */
  @AuraEnabled
  public String salesforceCaseNumber { get; set; }
  /**
   * @description Precheck Acceptance Status for the Case
   */
  @AuraEnabled
  public String acceptance { get; set; }
  /**
   * @description Precheck Failed Reasons for the Case
   */
  @AuraEnabled
  public List<String> failedReasons { get; set; }
  /**
   * @description Business Process Id for the Case
   */
  @AuraEnabled
  public String businessProcessId { get; set; }
  /**
   * @description status code of the failure Case
   */
  @AuraEnabled
  public String code { get; set; }
  /**
   * @description message of the failure case
   */
  @AuraEnabled
  public String message { get; set; }
  /**
   * @description ParentId for the Case
   */
  @AuraEnabled
  public String parentCaseId { get; set; }
  /**
   * @description COP Reason for the Case
   */
  @AuraEnabled
  public String copReason { get; set; }
  /**
   * @description COP Reason for the Case
   */
  @AuraEnabled
  public String issueType { get; set; }
  /**
   * @description Record Type for the Case
   */
  @AuraEnabled
  public String recordTypeId {
    get {
      switch on issueType {
        when 'Account Closure' {
          return RTCase.accountClosure;
        }
        when 'Confirmation of Payee Opt-In', 'Confirmation of Payee Opt-Out' {
          return RTCase.confirmationOfPayee;
        }
        when else {
          return null;
        }
      }
    }
    set;
  }
}
