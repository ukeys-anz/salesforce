/**
 * @author Hinduja Upadhyay
 * @since Aug 2024
 * @description Model class to create request ADR API
 * @group TFM
 */
public with sharing class ADRResponseModel extends CalloutModel {
  public List<Result> result;
  /**
   * @description This is wrapper class for ADR Request
   * @name Result
   * @author Hinduja Upadhyay
   */
  public class Result {
    public String id;
    public String status;
    public String clientName;
    public String updateDateTime;
    public String brandName;
  }
  /**
   * @description Represents Response body for ADRResponseModel API
   * @param json json response from onboarding API
   * @return `ADR` api response is serialised into ADRResponseModel
   */
  public static ADRResponseModel parse(String json) {
    return (ADRResponseModel) deserialize(json, ADRResponseModel.class);
  }
}
