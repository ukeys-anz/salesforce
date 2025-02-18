/**
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 * @description Response Model for Tokenized Document Number
 */
public with sharing class TokenizeDocumentNumberResponseModel extends CalloutModel {
  /**
   * @description Tokenized document number value
   */
  public String value;

  /**
   * @description deserializes the input string into the model
   * @param json input string to deserialize
   * @return `TokenizeDocumentNumberResponseModel`
   */
  public static TokenizeDocumentNumberResponseModel parse(String json) {
    try {
      return (TokenizeDocumentNumberResponseModel) deserialize(
        json,
        TokenizeDocumentNumberResponseModel.class
      );
    } catch (Exception ex) {
      throw CommonUtil.logException(ex);
    }
  }
}
