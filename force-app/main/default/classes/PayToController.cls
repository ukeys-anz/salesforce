/**
 * @author Arpit
 * @since July 2023
 * @description Controller for PayTo flex card
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 */
global with sharing class PayToController implements Callable {
  private static final String METHODNAME_GET_MANDATE = 'getMandateList';
  private static final String METHODNAME_CHANGE_MANDATE = 'changeMandateStatus';
  private static final String METHODNAME_FRAUDX_CHANGE_STATUS = 'fraudxChangeStatus';
  private static final String USER_ID_TYPE = 'LANID';
  private static final String MANDATE_ACCOUNT_TYPE_BBAN = 'BBAN';
  private static final String MANDATE_ACCOUNT_TYPE_ALIA = 'ALIA';

  public enum MANDATE_STATUS_CODE {
    MANDATE_STATUS_CODE_UNSPECIFIED,
    MANDATE_STATUS_CODE_ACTIVE,
    MANDATE_STATUS_CODE_CANCELLED,
    MANDATE_STATUS_CODE_CREATED,
    MANDATE_STATUS_CODE_SUSPENDED
  }

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
    if (methodName.equals(METHODNAME_GET_MANDATE)) {
      return getMandateList(input, output, options);
    } else if (methodName.equals(METHODNAME_CHANGE_MANDATE)) {
      return changeMandateStatus(input, output, options);
    } else if (methodName.equals(METHODNAME_FRAUDX_CHANGE_STATUS)) {
      return fraudxChangeStatus(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean getMandateList(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String ocvId = (String) input.get('ocvId');
    String status = (String) input.get('status');
    Integer pageNumber = Integer.valueOf((String) input.get('pageNumber'));
    MandateResponse result = new MandateResponse();

    if (String.isBlank(ocvId)) {
      result.hasError = true;
      output.put('result', JSON.deserializeUntyped(JSON.serialize(result)));
      return true;
    }
    try {
      MANDATE_STATUS_CODE statusCode = MANDATE_STATUS_CODE.valueOf(status);

      PayToAPIRepository api = new PayToAPIRepository();
      PayToModel apiResponse = api.getMandateList(
        ocvId,
        statusCode.ordinal(),
        pageNumber
      );
      result.totalMandates = apiResponse.total;
      result.mandates = apiResponse.mandates;
      result.pageNumber = pageNumber;
    } catch (Exception ex) {
      result.hasError = true;
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }

    output.put('result', JSON.deserializeUntyped(JSON.serialize(result)));
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean changeMandateStatus(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String mandateId = String.valueOf(input.get('mandateId'));
    String ocvId = String.valueOf(input.get('ocvId'));
    String status = String.valueOf(input.get('status'));
    PayToFabricChangeStatusModel apiResponse = new PayToFabricChangeStatusModel();
    try {
      PayToAPIRepository api = new PayToAPIRepository();
      apiResponse = api.changeMandateStatus(mandateId, ocvId, status);
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }
    output.put('result', JSON.deserializeUntyped(JSON.serialize(apiResponse)));
    return true;
  }

  private class MandateResponse {
    public Boolean hasError = false;
    public Integer pageNumber;
    public Integer totalMandates = 0;
    public List<PayToModel.Mandate> mandates;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean fraudxChangeStatus(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String mandateId = String.valueOf(input.get('mandateId'));
    String ocvId = String.valueOf(input.get('ocvId'));
    String status = String.valueOf(input.get('status'));
    String mandateAccountIdentificationType;
    String mandateAccountIdentification;
    if (
      String.isNotBlank(String.valueOf(input.get('mandateAccountNumber'))) &&
      String.isNotBlank(String.valueOf(input.get('mandateAccountBsb')))
    ) {
      mandateAccountIdentificationType = MANDATE_ACCOUNT_TYPE_BBAN;
      mandateAccountIdentification =
        String.valueOf(input.get('mandateAccountBsb')) +
        String.valueOf(input.get('mandateAccountNumber'));
    } else if (String.isNotBlank(String.valueOf(input.get('mandatePayId')))) {
      mandateAccountIdentificationType = MANDATE_ACCOUNT_TYPE_ALIA;
      mandateAccountIdentification = String.valueOf(input.get('mandatePayId'));
    }
    String userId = [
      SELECT Id, Lan_Id__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ]
    .Lan_Id__c;

    PayToFabricChangeStatusModel result = new PayToFabricChangeStatusModel();
    if (
      String.isBlank(ocvId) ||
      String.isBlank(userId) ||
      String.isBlank(mandateAccountIdentificationType) ||
      String.isBlank(mandateAccountIdentification)
    ) {
      output.put('result', JSON.deserializeUntyped(JSON.serialize(result)));
      return true;
    }

    try {
      PayToFraudxAPIRepository api = new PayToFraudxAPIRepository();
      Map<String, String> headerProperties = new Map<String, String>{
        'userId' => userId,
        'userIdType' => USER_ID_TYPE,
        'mandateAccountIdentificationType' => mandateAccountIdentificationType,
        'mandateAccountIdentification' => mandateAccountIdentification
      };
      result = api.changeMandateStatus(
        mandateId,
        ocvId,
        status,
        headerProperties
      );
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }

    output.put('result', JSON.deserializeUntyped(JSON.serialize(result)));
    return true;
  }
}
