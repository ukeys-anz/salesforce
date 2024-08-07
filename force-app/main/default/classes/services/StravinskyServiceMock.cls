/**
 * @author Paul Boyington
 * @since May 2022
 * @description Mock implementation of Stravinsky api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class StravinskyServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public StravinskyServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CLOSE_PACKAGE_RESPONSE_ALL_FIELDS = getStaticResource(
    'mock_accountClosure'
  );

  @TestVisible
  private static final String TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_SUCCESS = '{}';

  @TestVisible
  private static final String SUCCESS_RETRIEVE_DETOKENIZED_COBPID_RESPONSE =
    '{' +
    '  \"values\": [' +
    '    {' +
    '      \"Tokenized\": \"Q2CmJdCA0\",' +
    '      \"Detokenized\": \"PA0940444\"' +
    '    },' +
    '    {' +
    '      \"Tokenized\": \"Q2CmJdCA1\",' +
    '      \"Detokenized\": \"PA0940441\"' +
    '    }' +
    '  ]' +
    '}';

  @TestVisible
  private static final String FAILURE_RETRIEVE_DETOKENIZED_COBPID_RESPONSE =
    '{' +
    '  \"error\": \"Invalid token.\"' +
    '}';

  @TestVisible
  private static final String SUCCESS_TOKENIZING_COBPID_RESPONSE =
    '{' +
    '  \"passport\": {' +
    '    \"firstName\": \"Adam\",' +
    '    \"middleNames\": \"Foo Bar\",' +
    '    \"lastName\": \"Baz\",' +
    '    \"passport\": {' +
    '      \"year\": 2000,' +
    '      \"month\": 10,' +
    '      \"day\": 16' +
    '     },' +
    '    \"passportNumberToken\": {' +
    '      \"value\": \"werwerwer\",' +
    '      \"transform\": \"fpe.personal-identifier\"' +
    '     }' +
    '  }' +
    '}';

  @TestVisible
  private static final String FAILURE_TOKENIZING_COBPID_RESPONSE =
    '{' +
    '  \"code\": \"unknown\",' +
    '  \"message\": \"error signaling Temporal\"' +
    '}';

  @TestVisible
  private static final String TOKENIZED_TIN = 'Q2CmJdCA0';

  @TestVisible
  private static final String DETOKENIZED_TIN = 'PA0940444';

  @TestVisible
  private static final String DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE =
    '{' +
    '  \"values\": [' +
    '    {' +
    '      \"Tokenized\": \"' +
    TOKENIZED_TIN +
    '\",' +
    '      \"Detokenized\": \"' +
    DETOKENIZED_TIN +
    '\"' +
    '    }' +
    '  ]' +
    '}';

  @TestVisible
  private static final String DETOKENIZED_COB_TAX_RESIDENCY_FAILURE_RESPONSE =
    '{' +
    '  \"code\": \"unknown\",' +
    '  \"message\": \"error signaling Temporal\"' +
    '}';

  /**
   * @param ocvId customer id
   * @param closureCaseRequest Account Closure case request to be sent in the body
   * @return `HttpCalloutResponse` method response
   * @description stravinsky package closure api
   */
  public override HttpCalloutResponse closePackage(
    String ocvId,
    String closureCaseRequest
  ) {
    if (!preset) {
      response.body = CLOSE_PACKAGE_RESPONSE_ALL_FIELDS;
    }
    return response;
  }

  /**
   * @param cobCase Customer Onboarding Case
   * @return `HttpCalloutResponse` method response
   * @description mock for Temporal Case Workflow API
   */
  public override HttpCalloutResponse triggerTemporalCaseWorkflow(
    Case cobCase
  ) {
    if (!preset) {
      response.body = TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_SUCCESS;
    }
    return response;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param request the tokenized fields to be detokenized
   * @return HttpCalloutResponse
   * @description stravinsky cobPid detokenize api
   */
  public override HttpCalloutResponse detokenize(
    String personaId,
    DetokenizeRequestModel request
  ) {
    if (!preset) {
      response.body = SUCCESS_RETRIEVE_DETOKENIZED_COBPID_RESPONSE;
    }

    return response;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param request COB Primary ID Document request data
   * @return HttpCalloutResponse
   * @description stravinsky cobPid detokenize api
   */
  public override HttpCalloutResponse updatePrimaryIDDocument(
    String personaId,
    COBPrimaryIDDocUpdateRequestModel request
  ) {
    if (!preset) {
      response.body = SUCCESS_TOKENIZING_COBPID_RESPONSE;
    }

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
    if (!preset) {
      response.body = DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE;
    }

    return response;
  }
}
