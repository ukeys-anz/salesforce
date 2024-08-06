/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description Request Model for Stravinsky detokenize callout
 */
public with sharing class DetokenizeRequestModel {
  //use in api request
  public List<TokenizedValue> values = new List<TokenizedValue>();

  /**
   * @description constructor to build DetokenizeRequestModel requestBody
   * @param fieldValues the tokenized field values
   * @param transformValue the token transform value use for detokenisation
   */
  public DetokenizeRequestModel(
    Set<String> fieldValues,
    String transformValue
  ) {
    for (String value : fieldValues) {
      this.values.add(new TokenizedValue(value, transformValue));
    }
  }
}
