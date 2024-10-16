/**
 * @author Hinduja Upadhyay
 * @since Aug 2024
 * @description ADR repository to invoke Mule to get response
 * @group Repository
 */
public with sharing class ADRRepository extends RepositoryBase {
  public static final String ACTIVE_ADR = 'ACTIVE';
  public static final String ACTIVE_ADR_VALUE = 'Active from ';
  public static final String ANZX_SUSPENDED_ADR = 'ANZX_SUSPENDED';
  public static final String SUSPENDED_ADR_VALUE = 'Suspended on ';
  public static final String ADR_DATE_FORMAT = 'dd MMM yyyy';
  public static final String REMOVED_ADR_VALUE = 'Removed on ';
  public static final String ANZX_REMOVED_ADR = 'REMOVED';
  public static final String ANZX_INACTIVE_ADR = 'INACTIVE';
  public static final String INACTIVE_ADR_VALUE = 'Inactive on ';
  public static final String DELETED_ADR_VALUE = 'Deleted on ';
  public static final String ANZX_DELETED_ADR = 'DELETED';
  /**
   * @return List<ADRDataTableResponseWrapper> response
   * @description send parameter to get ADR data
   */
  public List<ADRDataTableResponseWrapper> getADRRows() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = TFMConstants.ANZ_STAFF_TOKEN_TYPE;
    staffModel.realm = TFMConstants.ANZ_REALM_SYSTEM_VALUE;

    ADRService s = (ADRService) ServiceProvider.getService(ADRService.class);

    HttpCalloutResponse response = s.getADRRows(staffModel);
    HttpCalloutResponse handledResponse = handleResponse(response);

    ADRResponseModel aDRResponse = ADRResponseModel.parse(handledResponse.body);
    List<ADRResponseModel.Result> resultList = (List<ADRResponseModel.Result>) aDRResponse.result;
    List<ADRDataTableResponseWrapper> adrRespWrapperList = getADRList(
      resultList
    );
    return adrRespWrapperList;
  }

  /**
   * @param  resultList List<ADRResponseModel.Result>
   * @return List<ADRDataTableResponseWrapper>
   * @description gives rows of table in ADRDataTableResponseWrapper format
   */
  @testVisible
  private List<ADRDataTableResponseWrapper> getADRList(
    List<ADRResponseModel.Result> resultList
  ) {
    List<ADRDataTableResponseWrapper> adrRespWrapperList = new List<ADRDataTableResponseWrapper>();
    for (ADRResponseModel.Result adrModel : resultList) {
      ADRDataTableResponseWrapper dataTableResponse = new ADRDataTableResponseWrapper(
        adrModel.id,
        adrModel.clientName + ' by ' + adrModel.brandName,
        getStatus(adrModel.status) + getDateTime(adrModel.updateDateTime),
        adrModel.status,
        'false'
      );
      adrRespWrapperList.add(dataTableResponse);
    }
    return adrRespWrapperList;
  }

  /**
   * @param dateWithTime dateTime datatype
   * @return String
   * @description gives column value for status
   */
  @testVisible
  private String getDateTime(String dateWithTime) {
    String toConvert = dateWithTime.replace(TFMConstants.LETTERT, ' ')
      .replace(TFMConstants.LETTERZ, '');
    Datetime actualDatetime = Datetime.valueOf(toConvert);
    return actualDatetime.format(ADR_DATE_FORMAT);
  }

  /**
   * @param status status
   * @return String
   * @description gives column value for status
   */
  @testVisible
  private String getStatus(String status) {
    Map<String, String> statusVsActalValue = new Map<String, String>{
      ACTIVE_ADR => ACTIVE_ADR_VALUE,
      ANZX_SUSPENDED_ADR => SUSPENDED_ADR_VALUE,
      ANZX_REMOVED_ADR => REMOVED_ADR_VALUE,
      ANZX_DELETED_ADR => DELETED_ADR_VALUE,
      ANZX_INACTIVE_ADR => INACTIVE_ADR_VALUE
    };
    return statusVsActalValue.get(status);
  }

  /**
   * @param  rspId rspId
   * @param  actionToPerform actionName
   * @return  response
   * @description send parameter to update status
   */
  public HttpCalloutResponse performADRAction(
    String rspId,
    String actionToPerform
  ) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = TFMConstants.ANZ_STAFF_TOKEN_TYPE;
    staffModel.realm = TFMConstants.ANZ_REALM_SYSTEM_VALUE;
    ADRService s = (ADRService) ServiceProvider.getService(ADRService.class);
    HttpCalloutResponse response = s.performADRAction(
      staffModel,
      rspId,
      actionToPerform
    );
    HttpCalloutResponse handledResponse = handleResponse(response);
    return handledResponse;
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  public HttpCalloutResponse handleResponse(HttpCalloutResponse response) {
    if (response.successful) {
      return response;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw new InsufficientAccessException(response.error.getMessage());
    } else {
      throw response.error;
    }
  }

  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
  }
}
