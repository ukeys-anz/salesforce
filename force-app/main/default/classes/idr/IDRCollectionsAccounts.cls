/**
 * @author Afreen Khan
 * @since  02/2021
 * @description Wrapper class to send Financial Accounts for Collections
 */
public with sharing class IDRCollectionsAccounts {
  public String accountNumber;
  public String productName;

  /**
   * @description Constructor
   * @param accNumber
   * @param prodName
   */
  public IDRCollectionsAccounts(
    String accNumber,
    String prodName
  ) {
    accountNumber = accNumber;
    productName = prodName;
  }
}