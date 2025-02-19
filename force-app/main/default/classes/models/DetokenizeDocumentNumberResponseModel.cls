/**
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 * @description Response Model for Detokenized Document Number
 */
public with sharing class DetokenizeDocumentNumberResponseModel  extends CalloutModel {
    /**
     * @description Detokenized document number value
     */
    public String value;

    /**
     * @description deserializes the input string into the model
     * @param json input string to deserialize
     * @return `DetokenizeDocumentNumberResponseModel`
     */
    public static DetokenizeDocumentNumberResponseModel parse(String json) {
      try {
        return (DetokenizeDocumentNumberResponseModel) deserialize(
          json,
          DetokenizeDocumentNumberResponseModel.class
        );
      } catch (Exception ex) {
        throw CommonUtil.logException(ex);
      }
    }
}
