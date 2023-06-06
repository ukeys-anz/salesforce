/**
 * @author Batya Aisman Sufrin
 * @since May 2023
 * @description Model for Stravinsky Customer Onboarding Tax Residency related APIs
 */
public with sharing class COBTaxResidencyModel extends CalloutModel {
  public static final string TIN_TRANSFORM = 'fpe.base64-tax-identification-number';

  // List detokenize API response
  public List<DetokenizedValue> values;

  /**
   * @description Tokenized Data wrapper
   */
  public class TokenizedValue {
    public String tokenized;
    public String transform;

    /**
     * @description Constructor for inner TokenizedValue class
     * @param tokenizedValue Tokenized field value
     */
    public TokenizedValue(String tokenizedValue) {
      this.tokenized = tokenizedValue;
      this.transform = TIN_TRANSFORM;
    }
  }

  /**
   * @description Detokenized Data wrapper
   */
  public class DetokenizedValue {
    @AuraEnabled
    public String tokenized;
    @AuraEnabled
    public String detokenized;
  }

  /**
   * @param json input string to deserialize
   * @return `COBTaxResidencyModel`
   * @description deserializes the input string into the model
   */
  public static COBTaxResidencyModel parse(String json) {
    return (COBTaxResidencyModel) deserialize(json, COBTaxResidencyModel.class);
  }
}
