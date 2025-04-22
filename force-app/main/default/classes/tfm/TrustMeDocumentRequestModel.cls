/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-15-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class TrustMeDocumentRequestModel extends CalloutModel {
  /**
   * @description related_user
   */
  @AuraEnabled
  public String related_user { get; set; }
  /**
   * @description evaluation_id
   */
  @AuraEnabled
  public String evaluation_id { get; set; }
  /**
   * @description related_id
   */
  @AuraEnabled
  public String related_id { get; set; }
  /**
   * @description attachments
   */
  @AuraEnabled
  public List<Attachments> attachments { get; set; }
  /**
   * @description This is wrapper class for Attachments
   * @name Attachments
   * @author Anuj
   */
  public class Attachments {
    /**
     * @description usedocumentIdrId
     */
    @AuraEnabled
    public String documentId { get; set; }
    /**
     * @description uri
     */
    @AuraEnabled
    public String uri { get; set; }
    /**
     * @description fileType
     */
    @AuraEnabled
    public String fileType { get; set; }
  }

  /**
   * @description performing deserilize operation
   * @param json json
   * @return  TrustMeDocumentRequestModel (An instance of TrustMeDocumentRequestModel class)
   */

  public static TrustMeDocumentRequestModel parse(String json) {
    return (TrustMeDocumentRequestModel) deserialize(
      json,
      TrustMeDocumentRequestModel.class
    );
  }
}
