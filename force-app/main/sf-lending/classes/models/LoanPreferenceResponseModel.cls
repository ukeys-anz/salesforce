/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description response model for Loan Preference
 * @group Models
 */
public with sharing class LoanPreferenceResponseModel extends CalloutModel {
  public FabricType.FabricMoney initialAmount;
  @AuraEnabled
  public Integer interestRate;

  /**
   * @description converts amount to decimal
   */
  @AuraEnabled
  public Decimal convertedAmount {
    get {
      return initialAmount?.value();
    }
  }

  /**
   * @param json input string to deserialize
   * @return `LoanPreferenceResponseModel`
   * @description deserializes the input string into the model
   */
  public static LoanPreferenceResponseModel parse(String json) {
    return (LoanPreferenceResponseModel) deserialize(
      json,
      LoanPreferenceResponseModel.class
    );
  }
}
