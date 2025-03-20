/**
 *
 * @author Aman Gupta
 * @since 2025
 * @description CaseGroupFinancialAccountModel
 */
public with sharing class CaseGroupFinancialAccountModel {
  /**
   * @description id of Financial Account
   */
  @AuraEnabled
  public String id;
  /**
   * @description productName of Financial Account
   */
  @AuraEnabled
  public String productName;
  /**
   * @description productId of Financial Account
   */
  @AuraEnabled
  public String productId;
  /**
   * @description accountNumber of Financial Account
   */
  @AuraEnabled
  public String accountNumber;
  /**
   * @description finAccountType of Financial Account
   */
  @AuraEnabled
  public String finAccountType;
  /**
   * @description signingAuthority of Financial Account
   */
  @AuraEnabled
  public String signingAuthority;
  /**
   * @description balance of Financial Account
   */
  @AuraEnabled
  public Decimal balance;
  /**
   * @description accountStatusCOP of Financial Account
   */
  @AuraEnabled
  public String accountStatusCOP;
  /**
   * @description apiFinAccountType of Financial Account
   */
  @AuraEnabled
  public String apiFinAccountType;
  /**
   * @description updateAccountStatusCOP of Financial Account
   */
  @AuraEnabled
  public String updateAccountStatusCOP;
  /**
   * @description requestedByName of Financial Account
   */
  @AuraEnabled
  public String requestedByName;
  /**
   * @description modifiedByName of Financial Account
   */
  @AuraEnabled
  public String modifiedByName;
  /**
   * @description statusChangeDateTime of Financial Account
   */
  @AuraEnabled
  public String statusChangeDateTime;
  /**
   * @description isError of Financial Account
   */
  @AuraEnabled
  public Boolean isError = false;
  /**
   * @description accountingSystem of Financial Account
   */
  @AuraEnabled
    public String accountingSystem;
}
