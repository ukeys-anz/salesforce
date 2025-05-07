/** @author Jaya Srivastava
 * @since Nov 2024
 * @description Response model for Update Loan Preference
 * @group Models
 */
public with sharing class LoanPreferenceUpdateResponseModel extends CalloutModel {
  @AuraEnabled
  public Boolean successful;
  @AuraEnabled
  public Integer errorCode;
  @AuraEnabled
  public String errorReason;
  @AuraEnabled
  public String message;

  /**
   * @param json input string to deserialize
   * @return `LoanPreferenceUpdateResponseModel`
   * @description Method to deserialize Response body.
   */
  public static LoanPreferenceUpdateResponseModel parse(String json) {
    return (LoanPreferenceUpdateResponseModel) deserialize(
      json,
      LoanPreferenceUpdateResponseModel.class
    );
  }
}
