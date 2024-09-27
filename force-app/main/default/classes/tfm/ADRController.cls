/**
 * @description       : LWC Controller for ADR
 * @author            : Hinduja Upadhyay
 * @group             :
 * @last modified on  : 09-24-2024
 **/
public with sharing class ADRController {
  /**
   * @param dateTimeValue String
   * @return `ADRResponseModel`
   * @description get ADR Data
   */
  @AuraEnabled(cacheable=true)
  public static List<ADRDataTableResponseWrapper> getDataFromApi(
    String dateTimeValue
  ) {
    List<ADRDataTableResponseWrapper> wrapperList = new List<ADRDataTableResponseWrapper>();
    ADRRepository api = new ADRRepository();
    try {
      wrapperList = api.getADRRows();
    } catch (ADRRepository.InsufficientAccessException ex) {
      ADRDataTableResponseWrapper wrapper = new ADRDataTableResponseWrapper();
      wrapper.isError = 'insufficientAccess';
      wrapperList.add(wrapper);
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    } catch (Exception e) {
      ADRDataTableResponseWrapper wrapper = new ADRDataTableResponseWrapper();
      wrapper.isError = 'serverError';
      wrapperList.add(wrapper);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return wrapperList;
  }

  /**
   * @param  rspId rspId
   * @param  actionName actionName
   * @return  returnMap
   * @description send parameter to update status
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, String> performADRAction(
    String rspId,
    String actionName
  ) {
    Map<String, String> returnMap = new Map<String, String>();
    ADRRepository api = new ADRRepository();
    String actionToPerform = actionName.equalsIgnoreCase('suspend')
      ? 'suspend'
      : 'unsuspend';
    HttpCalloutResponse response;
    try {
      response = api.performADRAction(rspId, actionToPerform);
      returnMap.put('status', 'Success');
      returnMap.put(
        'responseMessage',
        actionName.equalsIgnoreCase('suspend')
          ? 'Data Recipient Suspended'
          : 'Data Recipient Reactivated'
      );
    } catch (ADRRepository.InsufficientAccessException ex) {
      returnMap.put('status', 'Error');
      returnMap.put('responseMessage', 'You don\'t have required permission to perform this action.');
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    } catch (Exception ex) {
      returnMap.put('status', 'Error');
      returnMap.put(
        'responseMessage',
        'The server encountered an unexpected error. Please retry after some time.'
      );
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }
    return returnMap;
  }
}
