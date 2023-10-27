/**
 * @author Arpit
 * @since August 2023
 * @description PayTo Change Status Model to get response from Fabric thru mule
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 * @group Repository
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class PayToChangeStatusModel extends CalloutModel {
  public String mandateId;
  public Integer httpCode;
  public String httpMessage;
  public String severity;
  public List<Error> errors;

  /**
   * @description a single error record from the Change Status API
   */
  public class Error {
    public Integer statusCode;
    public String statusMessage;
    public String description;
    public String location;
  }

  /**
   * @description Represents Response body for Change Status API
   * @param json json response from Change Status API
   * @return `PayToChangeStatusModel` api response is serialised into PayToChangeStatusModel
   */
  public static PayToChangeStatusModel parse(String json) {
    return (PayToChangeStatusModel) deserialize(
      json,
      PayToChangeStatusModel.class
    );
  }
}
