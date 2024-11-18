/**
 * @author Paul Boyington
 * @since May 2022
 * @description Stravinsky API repository for all Stravinsky callouts
 * @group Repository
 */
public with sharing class StravinskyAPIRepository extends RepositoryBase {
  @TestVisible
  public static Boolean throwException = false; // This is to force an exception to increase unit test coverage as current mock framework only returns positive response. A PDR will be raised to extend the mock framework if similar instances arise.
  @TestVisible
  private static final String MOCK_ERROR = 'Mock Error'; // This is to force an exception to increase unit test coverage as current mock framework only returns positive response. A PDR will be raised to extend the mock framework if similar instances arise.
  @TestVisible
  private static final String FAILED_PRECONDITION_CODE = 'failed_precondition';

  /**
   * Internal stage
   */
  public static final String COB_UPDATED = 'COB_UPDATED';
  public static final String STAGE_ASSISTED_SELFIE = 'STAGE_ASSISTED_SELFIE';
  public static final String STAGE_ASSISTED_KYC = 'STAGE_ASSISTED_KYC';
  public static final String STAGE_ACK_ID_CHECK = 'STAGE_ACK_ID_CHECK';
  public static final String STAGE_TNC = 'STAGE_TNC';
  public static final String STAGE_TERMINATED = 'STAGE_TERMINATED';

  @TestVisible
  private static final Set<String> EXPECTED_STAGES_SET = new Set<String>{
    STAGE_ASSISTED_SELFIE,
    STAGE_ASSISTED_KYC,
    STAGE_ACK_ID_CHECK,
    STAGE_TNC,
    STAGE_TERMINATED
  };

  /**
   * @param caseRecord contains ocv id and package id
   * @param  setOfAccountNumberToBeClosed the account numbers for the checking account
   * @param customerOCVIds ocvIds of the customer individual or joint
   * @return GenesisPackageClosureModel
   * @description stravinsky package closure api
   */
  public GenesisPackageClosureModel packageClosure(
    Case caseRecord,
    Set<String> setOfAccountNumberToBeClosed,
    List<String> customerOCVIds
  ) {
    GenesisPackageClosureModel result;

    Service s = ServiceProvider.getService(StravinskyService.class);
    //Updated ClosedPackage method to accept OCVId and ClosureCaseRequest
    HttpCalloutResponse response = s.closePackage(
      caseRecord.Account.OCV_ID__c,
      generateJsonRequest(
        caseRecord,
        setOfAccountNumberToBeClosed,
        customerOCVIds
      )
    );

    if (response.successful) {
      try {
        result = GenesisPackageClosureModel.parse(response.body);
      } catch (Exception objException) {
        throw CommonUtil.logException(objException);
      }
    } else {
      throw CommonUtil.logException(response);
    }

    return result;
  }

  /**
   * @param caseRecord COB Case to be updated
   * @return String representing an onboarding stage of the expected Temporal API error response, otherwise throws exception
   * @description triggers Temporal Case Workflow API
   */
  public CxStageWrapper triggerTemporalCaseWorkflow(Case caseRecord) {
    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.triggerTemporalCaseWorkflow(caseRecord);
    return handleTemporalWorkflowResponse(response);
  }

  /**
   * @param response HttpCalloutResponse to be handled
   * @return CxStageWrapper Onboarding stage of the expected Temporal API error response, otherwise throws exception
   * @description Handles Temporal Workflow successfull, expected unsuccessfull and unsuccessfull responses.
   */
  @TestVisible
  private CxStageWrapper handleTemporalWorkflowResponse(
    HttpCalloutResponse response
  ) {
    CxStageWrapper cobStage = new CxStageWrapper();
    if (response.successful == true) {
      cobStage.cxOnboardingStage = COB_UPDATED;
      return cobStage;
    }

    //Attempt to parse expected Error response
    String responseErrMsg = response.error.getMessage();

    if (String.isBlank(responseErrMsg) || !responseErrMsg.containsIgnoreCase(FAILED_PRECONDITION_CODE) ) {
      throw CommonUtil.logException(response);
    }

    COBRASErrorModel parsedResponse = COBRASErrorModel.parse(responseErrMsg);

    for (COBRASErrorModel.Details errDetail : parsedResponse.details) {
      COBRASErrorModel.Debug debug = errDetail.debug;
      String errorStage = debug?.cxOnboardingStage;
      if (EXPECTED_STAGES_SET.contains(errorStage)) {
        cobStage.cxOnboardingStage = errorStage;
        cobStage.reason = debug.reason;
        return cobStage;
      }
    }

    throw CommonUtil.logException(response);
  }

  /**
   * @param personaId COB Primary ID record's PersonaId
   * @param fieldValues the field values to be detokenized
   * @param transformValue the token transform value use for detokenizing
   * @return DetokenizeModel
   * @description stravinsky COBPID detokenization api
   */
  public DetokenizeModel detokenize(
    String personaId,
    Set<String> fieldValues,
    String transformValue
  ) {
    DetokenizeRequestModel request = new DetokenizeRequestModel(
      fieldValues,
      transformValue
    );

    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.detokenize(personaId, request);

    if (response.successful == false) {
      throw CommonUtil.logException(response);
    }

    return DetokenizeModel.parse(response.body);
  }

  /**
   * @param record COB Primary ID record
   * @param caseId the linked Case Id to the COBPID record
   * @return COBPrimaryIDDocumentModel
   * @description stravinsky COBPID tokenization api
   */
  public COBPrimaryIDDocumentModel updatePrimaryIDDocument(
    COBPrimaryIDDocument__c record,
    Id caseId
  ) {
    COBPrimaryIDDocUpdateRequestModel requestBody = new COBPrimaryIDDocUpdateRequestModel(
      record,
      caseId
    );

    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.updatePrimaryIDDocument(
      record.PersonaId__c,
      requestBody
    );

    if (response.successful == true) {
      return COBPrimaryIDDocumentModel.parse(response.body);
    }

    if (response.statusCode != 500) {
      throw CommonUtil.logException(response);
    }

    String responseErrMsg = response.error.getMessage() ?? 'No response from API';
    throw new PIDDataException(responseErrMsg);
  }

  /**
   * @param taxResidency COB Tax Residency record
   * @return COBTaxResidencyModel
   * @description triggers Temporal detokenization api
   */
  public COBTaxResidencyModel cobTaxResidencyDetokenization(
    COBTaxResidency__c taxResidency
  ) {
    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.detokenizeCOBTaxResidency(taxResidency);

    if (response.successful == false || throwException == true) {
      throw CommonUtil.logException(mockException());
    }

    return COBTaxResidencyModel.parse(response.body);
  }

  private MockException mockException() {
    MockException ex = null;
    if (throwException == true) {
      ex = new MockException();
      ex.setMessage(MOCK_ERROR);
    }

    return ex;
  }

  /**
   * @description Wrapper class for COB Stage w/o Onboarding Stage Change Reason
   */
  public class CxStageWrapper {
    /**
     * @description cxOnboardingStage
     */
    public String cxOnboardingStage { get; set; }
    /**
     * @description reason
     */
    public String reason { get; set; }
  }

  /**
   * @description Mismatched Data exception
   */
  private class PIDDataException extends Exception {
  }

  /**
   * @description Mock exception
   */
  private class MockException extends Exception {
  }
  /**
   * @description Generate Json Request to be sent to Mulesoft
   * @param caseRecord contains ocv id and package id
   * @param setOfAccountNumberToBeClosed the account numbers to be closed
   * @param customerOCVIds ocvIds of the customer individual or joint
   * @return JSON string to be sent to Mulesoft
   */
  @TestVisible
  private String generateJsonRequest(
    Case caseRecord,
    Set<String> setOfAccountNumberToBeClosed,
    List<String> customerOCVIds
  ) {
    //Added in order to create a json string to be sent to Mulesoft
    JSONGenerator body = JSON.createGenerator(true);
    body.writeStartObject();
    body.writeObjectField('ocv_ids', customerOCVIds);
    body.writeFieldName('items');
    body.writeStartArray();
    for (String accNum : setOfAccountNumberToBeClosed) {
      body.writeStartObject();
      body.writeStringField('account_resource', accNum);
      body.writeEndObject();
    }
    if (!isS2ProductOnCase(caseRecord)) {
      body.writeStartObject();
      body.writeStringField('package_resource', caseRecord.Package_Id__c);
      body.writeEndObject();
    }
    body.writeEndArray();
    body.writeEndObject();
    return body.getAsString();
  }

  /**
   * @description check if the Product on the case record is S2 or not.
   * @param caseRecord Case record of Account Closure record type
   * @return true if Product on Case is not S2
   */
  public static Boolean isS2ProductOnCase(Case caseRecord) {
    return System.Label.S2AccountEnabled.toLowerCase() == 'true' &&
      caseRecord.Account_Product__c == 'ANZ Plus Flex Saver';
  }
}
