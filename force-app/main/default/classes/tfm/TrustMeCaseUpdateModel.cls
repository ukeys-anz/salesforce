/**
 * @description       : TrustMeCaseUpdateModel
 * @author            : Shivraj Kadam
 * @group             :
 * @last modified on  : Mar 2025
 * @last modified by  : Shivraj Kadam
 **/
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class TrustMeCaseUpdateModel extends CalloutModel {
  /**
   * @description evaluation_id
   */
  public String evaluation_id { get; set; }
  /**
   * @description state
   */
  public String state { get; set; }
  /**
   * @description case_type
   */
  public String case_type { get; set; }
  /**
   * @description case_number
   */
  public String case_number { get; set; }
  /**
   * @description primary_denied_reason
   */
  public String primary_denied_reason { get; set; }
  /**
   * @description secondary_denied_reason
   */
  public String secondary_denied_reason { get; set; }
  /**
   * @description checks
   */
  public Checks checks { get; set; }
  /**
   * @description case_id
   */
  public String case_id { get; set; }
  /**
   * @description qa_review_state
   */
  public String qa_review_state { get; set; }
  /**
   * @description kyc_reverification_id
   */
  public String kyc_reverification_id { get; set; }
  /**
   * @description checks
   */
  public class Checks {
    /**
     * @description customer_photo_id_legibility
     */
    public Boolean customer_photo_id_legibility { get; set; }
    /**
     * @description residential_address_validity
     */
    public Boolean residential_address_validity { get; set; }
    /**
     * @description customer_photo_id_modification
     */
    public Boolean customer_photo_id_modification { get; set; }
    /**
     * @description selfie_comparison
     */
    public Boolean selfie_comparison { get; set; }
    /**
     * @description picture_of_picture
     */
    public Boolean picture_of_picture { get; set; }
    /**
     * @description middle_name
     */
    public Boolean middle_name { get; set; }
    /**
     * @description id_document_security_features
     */
    public Boolean id_document_security_features { get; set; }
    /**
     * @description kyc_info_and_id_doc_type
     */
    public Boolean kyc_info_and_id_doc_type { get; set; }
  }

  /**
   * @description Represents details body for request action
   * @param json details body for request action
   * @return `TrustMeCaseUpdateModel` api response is serialised into TrustMeCaseUpdateModel
   */
  public static TrustMeCaseUpdateModel parse(String json) {
    return (TrustMeCaseUpdateModel) deserialize(
      json,
      TrustMeCaseUpdateModel.class
    );
  }
}
