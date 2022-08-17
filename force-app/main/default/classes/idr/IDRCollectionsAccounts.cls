/**
 * @author Afreen Khan
 * @since  02/2021
 * @description Wrapper class to send Financial Accounts for Collections
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCollectionsAccounts {
  public String accountNumber;
  public String productName;
  public String productCategory;

  /**
   * @description Constructor
   * @param accNumber
   * @param prodName
   * @param prodCat
   */
  public IDRCollectionsAccounts(
    String accNumber,
    String prodName,
    String prodCat
  ) {
    accountNumber = accNumber;
    productName = prodName;
    productCategory = prodCat;
  }
}
