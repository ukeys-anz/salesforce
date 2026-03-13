/**
 * @author Sanskriti
 * @since Feb 2026
 * @description Model for DocumentSignedURL API
 *
 */
public with sharing class DocumentSignedURLModel {
  /**
   * @description document from api
   */
  @AuraEnabled
  public String document { get; set; }
  /**
   * @description document uri from api
   */
  @AuraEnabled
  public String uri { get; set; }
  /**
   * @description expiry time for the signed url - from api
   */
  @AuraEnabled
  public String expiry { get; set; }

  /**
   * @description Parse JSON into this model - callable from Lightning (must be static)
   * @param jsonString json string
   * @return  DocumentSignedURLModel instance created from the JSON string
   */
  @AuraEnabled
  public static DocumentSignedURLModel parse(String jsonString) {
    return (DocumentSignedURLModel) JSON.deserialize(
      jsonString,
      DocumentSignedURLModel.class
    );
  }
}
