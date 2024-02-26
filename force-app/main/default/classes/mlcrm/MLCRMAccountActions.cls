/**
 * @author Ankit Garg
 * @since  12/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMAccountActions is class to handle all the MLCRM Account Actions
 * @runTests CCRMAccountActionsTest
 */
public with sharing class MLCRMAccountActions {
  /**
   * @description CC-5112 && CC-7016 to restrict Date of Birth in Future
   * @name validateDateOfBirth
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void validateDateOfBirth(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    for (Account rec : records) {
      if (
        rec.isPersonAccount &&
        rec.PersonBirthdate != null &&
        rec.PersonBirthdate >= System.TODAY()
      ) {
        rec.addError(Label.ML_DateOfBirth_ErrorMessage);
      }
    }
  }
}
