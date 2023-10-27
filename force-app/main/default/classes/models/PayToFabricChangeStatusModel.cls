/**
 * @author Aman
 * @since July 2023
 * @description PayTo Model to get response from Fabric thru mule
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 * @group Repository
 */
public with sharing class PayToFabricChangeStatusModel extends CalloutModel {
  public Integer httpCode;
  public String message;
  public String status;

  /**
   * @param json json String
   * @return `PayToCancelMandateModel` the api response wrapper
   * @description transposes the string into object
   */
  public static PayToFabricChangeStatusModel parse(String json) {
    return (PayToFabricChangeStatusModel) deserialize(
      json,
      PayToFabricChangeStatusModel.class
    );
  }
}
