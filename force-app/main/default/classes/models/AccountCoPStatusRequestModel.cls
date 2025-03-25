/**
 * @author Aman Gupta
 * @since February 2025
 * @description Model for requesting financial accounts for Confirmation of Payee (CoP).
 * @group Models
 */
public with sharing class AccountCoPStatusRequestModel {
  public List<AccountList> accountList;

  /**
   * @description Represents an account identification number.
   */
  public class AccountList {
    public String accountIdentification;
  }
}