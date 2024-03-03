/**
 * @author Hrushikesh
 * @since Dec 2023
 * @description Controller for Signing Authority Updates
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=2253292239
 */
global with sharing class SigningAuthorityController implements Callable {
  private static final String METHODNAME_UPDATE_SIGN_AUTH = 'updateSigningAutority';

  /**
   * @param action beaviour of the method to exhibit
   * @param args arguments to be used by the specified action
   * @return method to be invoked
   * @description To dispatch actual method
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }

  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName.equalsIgnoreCase(METHODNAME_UPDATE_SIGN_AUTH)) {
      return updateSigningAutority(input, output, options);
    }
    return false;
  }

  /**
   * @description  The updateSigningAutority is the method to make the callout to Mulesoft to update the number of signature field
   * @param input arg for omnistudio IP
   * @param output arg for omnistudio IP
   * @param options arg for omnistudio IP
   * @return `AlterAccountSignModeModel` response of the api
   */
  @AuraEnabled
  public static Boolean updateSigningAutority(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String financialAccountNumber = (String) input.get('finAccountNumber');
    String signMode = (String) input.get('numberOfSign');
    String ocvId = (String) input.get('ocvId');
    String finAccountId = (String) input.get('finAccountId');
    AlterAccountSignModeModel apiResponse = new AlterAccountSignModeModel();
    try {
      SigningAuthorityRepository api = new SigningAuthorityRepository();
      apiResponse = api.updateSigningAutority(
        financialAccountNumber,
        Integer.valueOf(signMode),
        ocvId
      );
      processCustomerAction(apiResponse, finAccountId);
      output.put('httpCode', JSON.serialize(apiResponse.httpCode));
      output.put('isDefaultError', JSON.serialize(apiResponse.isDefaultError));
      output.put('status', JSON.serialize(apiResponse.status));
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }
    return true;
  }

  /**
   * @description  The processCustomerAction method to update customer action if api fails
   * @param alterModel Alter Account Sign Mode Model
   * @param finAccountId financial account id
   * @description process Customer Action record
   */
  public static void processCustomerAction(
    AlterAccountSignModeModel alterModel,
    String finAccountId
  ) {
    if (alterModel.status == 'Error') {
      List<Customer_Action__c> custActionRecords = getLatestPendingCustomerAction(
        finAccountId
      );
      if (custActionRecords.isEmpty()) {
        return;
      }
      List<Customer_Action__c> updatedCustomerActions = updateCustomerAction(
        alterModel,
        custActionRecords
      );
      DMLUtil.updateRecords(
        updatedCustomerActions,
        DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
        DMLUtil.SYSTEM_MODE
      );
    }
  }

  /**
   * @description  The getLatestPendingCustomerAction method to get the pending customer action record
   * @param finAccountId Alter Account Sign Mode Model
   * @return `custActionRecords` pending customer action record
   */
  public static List<Customer_Action__c> getLatestPendingCustomerAction(
    String finAccountId
  ) {
    List<Customer_Action__c> custActionRecords = [
      SELECT Id, Status__c, Error_Description__c
      FROM Customer_Action__c
      WHERE
        Financial_Account__c = :finAccountId
        AND Status__c = :GetHelpFinancialAccountActions.CUSTOMER_ACTION_STATUS_PEDING
        AND RecordTypeId = :GetHelpConstants.CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID
      ORDER BY LastModifiedDate
      LIMIT 1
    ];
    return custActionRecords;
  }

  /**
   * @description  The updateCustomerAction method to update the customer action with Error
   * @param alterModel Alter Account Sign Mode Model
   * @param custActionRecords Customer Action Record
   * @return `custActionRecords` updated records
   */
  public static List<Customer_Action__c> updateCustomerAction(
    AlterAccountSignModeModel alterModel,
    List<Customer_Action__c> custActionRecords
  ) {
    custActionRecords[0].Status__c = alterModel.status;
    custActionRecords[0].Error_Description__c =
      alterModel.httpCode +
      ' | ' +
      alterModel.message;
    return custActionRecords;
  }
}
