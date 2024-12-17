/**
 * @author Nilesh Kalal
 * @since Mon Dec 16 2024
 * @description Wrapper class for Financial Accounts Response
 */
public with sharing class FinancialAccountsResponse {
  /**
   * @description Id of FinancialAccount
   */
  @AuraEnabled
  public String id { get; set; }
  /**
   * @description Account Number of FinancialAccount
   */
  @AuraEnabled
  public String accountNumber { get; set; }
  /**
   * @description Product Name of FinancialAccount
   */
  @AuraEnabled
  public String productName { get; set; }
  /**
   * @description Product Id of FinancialAccount
   */
  @AuraEnabled
  public Id productId { get; set; }
  /**
   * @description Balance of FinancialAccount
   */
  @AuraEnabled
  public Decimal balance { get; set; }
  /**
   * @description Ownership of FinancialAccount
   */
  @AuraEnabled
  public String ownership { get; set; }
  /**
   * @description Marketing Code of FinancialAccount
   */
  @AuraEnabled
  public String marketingCode { get; set; }
  /**
   * @description Status of FinancialAccount
   */
  @AuraEnabled
  public String status { get; set; }
  /**
   * @description Record Type Developer Name of FinancialAccount
   */
  @AuraEnabled
  public String recodTypeName { get; set; }

  public FinancialAccountsResponse(
    String id,
    String accountNumber,
    String productName,
    Id productId,
    Decimal balance,
    String ownership,
    String marketingCode,
    String status,
    String recodTypeName
  ) {
    this.id = id;
    this.accountNumber = accountNumber;
    this.productName = productName;
    this.productId = productId;
    this.balance = balance;
    this.ownership = ownership;
    this.marketingCode = marketingCode;
    this.status = status;
    this.recodTypeName = recodTypeName;
  }
}
