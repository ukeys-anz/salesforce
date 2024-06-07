/**
 * @author Paul Boyington
 * @since May 2022
 * @description Stravinsky implementation of the API service
 * @group Services
 */
public with sharing class StravinskyService extends Service {
  private Map<String, String> temporalCaseWorkflowEndpoints = new Map<String, String>{
    GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS => Label.ST_ApproveSelfieIDCheck,
    GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS => Label.ST_ApproveSelfieIDCheck,
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS => Label.ST_Approve_ID_Verification,
    GetHelpConstants.COB_FAILED_OK_STATUS => Label.ST_Retry_Stage,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS => Label.ST_Confirm_Fraud
  };

  @TestVisible
  private static final String EMPTY_BODY = '{}'; // An empty body is required at the moment, due to how Temporal's codegen works

  /**
   * @param ocvId customer id
   * @param closureCaseRecord Account Closure Wrapper record to be sent in the body
   * @return HttpCalloutResponse
   * @description stravinsky package closure api
   */
  public override HttpCalloutResponse closePackage(
    String ocvId,
    AccountClosurePackageWrapper closureCaseRecord
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.ST_Close_Package,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(closureCaseRecord)
    );

    return response;
  }

  /**
   * @param cobCase COB Case holding Id, personaId and status to be used for callout
   * @return `HttpCalloutResponse` api response
   * @description triggers Temporal Case Workflow
   */
  public override HttpCalloutResponse triggerTemporalCaseWorkflow(
    Case cobCase
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(
      Service.IdType.PERSONAID,
      cobCase.PersonaId__c,
      headers
    );
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      temporalCaseWorkflowEndpoints.get(cobCase.Status),
      HTTP_METHOD.HTTP_POST,
      headers,
      getCaseWorkflowPayload(cobCase)
    );

    return response;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param tokenizedFields the tokenized fields to be detokenized
   * @return HttpCalloutResponse
   * @description stravinsky COBPID detokenization api
   */
  public override HttpCalloutResponse detokenizeCOBPID(
    String personaId,
    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedFields
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.PERSONAID, personaId, headers);
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());

    Map<String, List<COBPrimaryIDDocumentModel.TokenizedValue>> callBody = new Map<String, List<COBPrimaryIDDocumentModel.TokenizedValue>>{
      'values' => tokenizedFields
    };

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.ST_Detokenize,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(callBody)
    );

    return response;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param detokenizedValue detokenized value (plain text) of a COBPID record
   * @return HttpCalloutResponse
   * @description stravinsky COBPID tokenization api
   */
  public override HttpCalloutResponse tokenizeCOBPID(
    String personaId,
    COBPrimaryIDDocumentModel detokenizedValue
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.PERSONAID, personaId, headers);
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());
    headers.put('Content-Type', 'application/json');

    Map<String, Object> callBody = new Map<String, Object>{
      'primaryIdDocument' => detokenizedValue.primaryIdDocument,
      'caseId' => detokenizedValue.caseId,
      'updateMask' => detokenizedValue.updateMask
    };

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.ST_UpdatePrimaryIdDocument,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(callBody, true)
    );

    return response;
  }

  /**
   * @param taxResidency COB Tax Residency record
   * @return HttpCalloutResponse
   * @description stravinsky COBTaxResidency detokenize api
   */
  public override HttpCalloutResponse detokenizeCOBTaxResidency(
    COBTaxResidency__c taxResidency
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(
      Service.IdType.PERSONAID,
      taxResidency.PersonaId__c,
      headers
    );
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.ST_Detokenize,
      HTTP_METHOD.HTTP_POST,
      headers,
      getDetokenizePayload(taxResidency)
    );

    return response;
  }

  /**
   * @param cobCase Customer Onboarding Case
   * @return String payload
   * @description returns payload for Case Workflow API
   */
  @TestVisible
  private String getCaseWorkflowPayload(Case cobCase) {
    Map<String, String> statusCaseIdMap = new Map<String, String>{
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS => cobCase.Id,
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS => cobCase.ParentId
    };
    Map<Id, String> reasonMap = new Map<Id, String>{
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID => GetHelpConstants.ONBOARDING_FAILED_REASON_CONFIRMED_FRAUD_WATCHLIST,
      GetHelpConstants.FRAUD_CHECK_RT_ID => GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    };
    RetryStagePayload retryStagePayload = new RetryStagePayload();

    if (statusCaseIdMap.containsKey(cobCase.Status)) {
      ApproveSelfieIDCheckPayload selfieIdPayload = new ApproveSelfieIDCheckPayload();
      selfieIdPayload.caseId = statusCaseIdMap.get(cobCase.Status);
      return JSON.serialize(selfieIdPayload);
    }
    if (cobCase.Status == GetHelpConstants.COB_FAILED_OK_STATUS) {
      retryStagePayload.reason = cobCase.OnboardingVerificationFailedReason__c;
      return JSON.serialize(retryStagePayload);
    }
    if (cobCase.Status != GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS) {
      return EMPTY_BODY;
    }
    if (!reasonMap.containsKey(cobCase.RecordTypeId)) {
      return EMPTY_BODY;
    }
    retryStagePayload.reason = reasonMap.get(cobCase.RecordTypeId);

    return JSON.serialize(retryStagePayload);
  }

  /**
   * @param taxResidency COB Tax Residency
   * @return String payload
   * @description returns payload for detokenize API
   */
  @TestVisible
  private String getDetokenizePayload(COBTaxResidency__c taxResidency) {
    List<COBTaxResidencyModel.TokenizedValue> tokenizedFields = new List<COBTaxResidencyModel.TokenizedValue>{
      new COBTaxResidencyModel.TokenizedValue(
        taxResidency.TaxIdentificationNumber__c
      )
    };

    Map<String, List<COBTaxResidencyModel.TokenizedValue>> payload = new Map<String, List<COBTaxResidencyModel.TokenizedValue>>{
      'values' => tokenizedFields
    };

    return JSON.serialize(payload);
  }

  /**
   * @description payload for ApproveSelfieIDCheck
   */
  private class ApproveSelfieIDCheckPayload {
    public String caseId;
  }

  /**
   * @description class payload for RetryState
   */
  private class RetryStagePayload {
    public String reason;
  }
}
