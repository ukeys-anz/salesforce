/**
 * @description Data model for OCDD KYC review status response.
 * @author  Supriya Kempanna
 * @created 2024-06-20
 */
public with sharing class OCDDResponseModel extends CalloutModel {
  public KycReviewStatus kycReviewStatus;
  /**
   * @description The current OCDD status of the customer in terms of KYC Review compliance, visible to internal agents and coaches
   */
  public class KycReviewStatus {
    // The unique id of the status, usually the alphanumeric ID for the latest OCDD rule applied, eg: 3y+1d
    public String id;
    // The human readable description of the OCDD status, eg: "In Progress - 1 Year"
    public String description;
  }

  /**
   * @param responseInput input string to deserialize
   * @return `OCDDResponseModel`
   * @description deserializes the input string into the model
   */
  public static OCDDResponseModel parse(String responseInput) {
    return (OCDDResponseModel) deserialize(
      responseInput,
      OCDDResponseModel.class
    );
  }
}
