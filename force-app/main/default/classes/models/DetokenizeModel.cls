/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description Response Model for Detokenized Values
 */
public with sharing class DetokenizeModel extends CalloutModel {
  public List<DetokenizedValue> values;

  /**
   * @description Wrapper for Detokenized and Tokenized value
   */
  public class DetokenizedValue {
    @AuraEnabled
    public String tokenized;
    @AuraEnabled
    public String detokenized;
  }

  /**
   * @param json input string to deserialize
   * @return `DetokenizeModel`
   * @description deserializes the input string into the model
   */
  public static DetokenizeModel parse(String json) {
    try {
      return (DetokenizeModel) deserialize(json, DetokenizeModel.class);
    } catch (Exception ex) {
      throw CommonUtil.logException(ex);
    }
  }
}
