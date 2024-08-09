/**
 * @author Anuj Jain
 * @since May 2024
 * @description Model class to createresponse for Onboarding API
 * @group TFM
 */
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class OnboardingResponseModel extends CalloutModel {
  /**
  * @description requester_sf_id
  */
  @AuraEnabled
  public String requester_sf_id { get; set; }
  /**
    * @description DAONFile
    */
  @AuraEnabled
  public List<DAONFilesResponse> DAONFile { get; set; }

   /**
   * @description This is wrapper class for DAONFilesResponse Request
   * @name DAONFilesResponse
   * @author Shivraj Kadam
  */
  public class DAONFilesResponse {
    /**
    * @description contentVersionId
    */
    @AuraEnabled
    public String contentVersionId { get; set; }
    /**
    * @description code
    */
    @AuraEnabled
    public String code { get; set; }
    /**
    * @description message
    */
    @AuraEnabled
    public String message { get; set; }
  }

  /**
   * @description Represents Response body for onboarding API
   * @param json json response from onboarding API
   * @return `Onboarding` api response is serialised into OnboardingModel
   */
  public static OnboardingResponseModel parse(String json) {
    return (OnboardingResponseModel) deserialize(json, OnboardingResponseModel.class);
  }
}