/**
 * @author Afreen Khan
 * @since  02/2021
 * @description Wrapper class to send Financial Accounts for Collections
 */
public with sharing class IDRCollectionsAccounts {
  public String accountNumber;
  public String productCode;
  public String subProductCode;

  /**
   * @description Constructor
   * @param accNumber
   * @param prodCode
   * @param subProdCode
   */
  public IDRCollectionsAccounts(
    String accNumber,
    String prodCode,
    String subProdCode
  ) {
    accountNumber = accNumber;
    productCode = prodCode;
    subProductCode = subProdCode;
  }
}
