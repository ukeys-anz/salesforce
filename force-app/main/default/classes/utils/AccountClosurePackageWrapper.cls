/**
 * * @description the wrapper representing CardControlResponse / SetControlsRequest etc
 */
public with sharing class AccountClosurePackageWrapper {
  /**
   * @description packageId present in the Case Record
   */
  public String packageId;
  /**
   * @description closeDate when the request raised
   */
  public String closeDate;
  /**
   * @description list of checking account numbers
   */
  public List<String> accountNumbersA1;
  /**
   * @description list of savings account numbers
   */
  public List<String> accountNumbersS1;
  /**
   * @description accountType ofor which case is raised
   */
  public String accountType;
  /**
   * @description list of customer ocvids
   */
  public List<String> ocvIds;
}
