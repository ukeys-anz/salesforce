/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description Model for Tokenized Field values
 */
public with sharing class TokenizedValue {
  public String tokenized;
  public String transform;
  public String value;

  /**
   * @description Constructor for inner TokenizedValue class
   * @param tokenizedValue the record's tokenized field value
   * @param transform the token transform value for the field
   */
  public TokenizedValue(String tokenizedValue, String transform) {
    this.tokenized = tokenizedValue;
    this.transform = transform;
  }
}
