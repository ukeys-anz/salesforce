/**
 * * @description the wrapper class used in StravinskyAPIRepository to create Account Closure Package body to be sent to Mulesoft
 * */
public with sharing class AccountClosurePackageWrapper {
  /**
   * @description accountType ofor which case is raised
   */
  public String accountType;
  /**
   * @description closeDate when the request raised
   */
  public String closeDate;
  /**
   * @description packageId present in the Case Record
   */
  public String packageId;
  /**
   * @description list of checking account numbers
   */
  public List<String> accountNumbersA1;
  /**
   * @description list of savings account numbers
   */
  public List<String> accountNumbersS1;
  /**
   * @description list of customer ocvids
   */
  public List<String> ocvIds;
}
