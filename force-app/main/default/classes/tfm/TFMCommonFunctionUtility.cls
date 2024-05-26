/**
 * @description       : class contains method that is common among all the classes
 * @author            : Hinduja Upadhyay
 * @group             : TFM
 * @last modified on  : 01-05-2024
 **/
public with sharing class TFMCommonFunctionUtility extends Service {
  /**
   * @param idValue value for staffModel.idValue
   * @return `StaffTokenRequestModel`
   * @description set StaffTokenRequestModel class instance
   */
  public static StaffTokenRequestModel setStaffModel(String idValue) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = idValue;
    staffModel.anzTokenType = TFMConstants.ANZTOKENTYPE;
    return staffModel;
  }

  /**
   * @description method is setting common headers used in api callout
   * @param staffModel staff model
   * @return Map<String, String>
   */
  public Map<String, String> setCommonHeadersInMap(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('x-anz-application-id', 'salesforce');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    headers.put('Content-Type', 'application/json');
    return headers;
  }

  /**
   * @param response HttpCalloutResponse
   * @return HttpCalloutResponse response
   * @description checks status code
   */
  public static HttpCalloutResponse checkResponse(
    HttpCalloutResponse response
  ) {
    if (
      response.successful ||
      response.statusCode == 401 ||
      response.statusCode == 403
    ) {
      return response;
    } else {
      throw response.error;
    }
  }
}
