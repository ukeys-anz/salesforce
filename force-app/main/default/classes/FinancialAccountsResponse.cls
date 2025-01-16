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
  @AuraEnabled
  /**
   * @description Signing Authority of FinancialAccount
   */
  public String signingAuthority { get; set; }

  // Private constructor to enforce the Builder pattern
  private FinancialAccountsResponse(Builder builder) {
    this.id = builder.id;
    this.accountNumber = builder.accountNumber;
    this.productName = builder.productName;
    this.productId = builder.productId;
    this.balance = builder.balance;
    this.ownership = builder.ownership;
    this.marketingCode = builder.marketingCode;
    this.status = builder.status;
    this.recodTypeName = builder.recodTypeName;
    this.signingAuthority = builder.signingAuthority;
  }

  /**
   * @author Nilesh Kalal
   * @since Mon Dec 16 2024
   * @description Builder class for FinancialAccountsResponse
   */
  public class Builder {
    public String id;
    public String accountNumber;
    public String productName;
    public Id productId;
    public Decimal balance;
    public String ownership;
    public String marketingCode;
    public String status;
    public String recodTypeName;
    public String signingAuthority;

    /**
     * @description setter for fin account Id
     * @param id Fin Account Id
     * @return Builder
     */
    public Builder setId(String id) {
      this.id = id;
      return this;
    }
    /**
     * @description setter for accountNumber
     * @param accountNumber account number
     * @return Builder
     */
    public Builder setAccountNumber(String accountNumber) {
      this.accountNumber = accountNumber;
      return this;
    }
    /**
     * @description setter for productName
     * @param productName Product Name
     * @return Builder
     */
    public Builder setProductName(String productName) {
      this.productName = productName;
      return this;
    }
    /**
     * @description setter for productId
     * @param productId Product Name
     * @return Builder
     */
    public Builder setProductId(Id productId) {
      this.productId = productId;
      return this;
    }
    /**
     * @description setter for balance
     * @param balance
     * @return Builder
     */
    public Builder setBalance(Decimal balance) {
      this.balance = balance;
      return this;
    }
    /**
     * @description setter for ownership
     * @param ownership
     * @return Builder
     */
    public Builder setOwnership(String ownership) {
      this.ownership = ownership;
      return this;
    }
    /**
     * @description setter for marketingCode
     * @param marketingCode
     * @return Builder
     */
    public Builder setMarketingCode(String marketingCode) {
      this.marketingCode = marketingCode;
      return this;
    }
    /**
     * @description setter for status
     * @param status
     * @return Builder
     */
    public Builder setStatus(String status) {
      this.status = status;
      return this;
    }
    /**
     * @description setter for recodTypeName
     * @param recodTypeName
     * @return Builder
     */
    public Builder setRecodTypeName(String recodTypeName) {
      this.recodTypeName = recodTypeName;
      return this;
    }
    /**
     * @description setter for signing authority
     * @param signingAuthority
     * @return Builder
     */
    public Builder setSigningAuthority(String signingAuthority) {
      this.signingAuthority = signingAuthority;
      return this;
    }
    /**
     * @description Build method to create the instance
     * @return FinancialAccountsResponse
     */
    //
    public FinancialAccountsResponse build() {
      return new FinancialAccountsResponse(this);
    }
  }
}
