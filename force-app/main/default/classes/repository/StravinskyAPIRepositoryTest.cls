/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for StravinskyAPIRepository
 */
@isTest
public with sharing class StravinskyAPIRepositoryTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String EXCEPTION_JSON =
    '{' +
    '    \"code\": \"exception occurred\"' +
    '}';

  private static final String EXPECTED_RESPONSE_STAGE_ACK_ID_CHECK_JSON =
    '{' +
    '    \"code\": \"failed_precondition\",' +
    '    \"message\": \"assisted request not expected\", ' +
    '    \"details\": [' +
    '        {' +
    '            \"type\": \"ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '            \"value\": \"CAI\",' +
    '            \"debug\": {' +
    '                \"@type\": \"type.googleapis.com/ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '                \"cxOnboardingStage\": \"STAGE_ACK_ID_CHECK\"' +
    '            }' +
    '        }' +
    '    ]' +
    '}';

  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';
  private static final String EXPECTED_RESPONSE_STAGE_TNC_JSON =
    '{' +
    '    \"code\": \"failed_precondition\",' +
    '    \"message\": \"assisted request not expected\", ' +
    '    \"details\": [' +
    '        {' +
    '            \"type\": \"ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '            \"value\": \"CAI\",' +
    '            \"debug\": {' +
    '                \"@type\": \"type.googleapis.com/ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '                \"cxOnboardingStage\": \"STAGE_TNC\", ' +
    '                \"retryReason\": \"' +
    FAILED_REASON +
    '\"' +
    '            }' +
    '        }' +
    '    ]' +
    '}';

  private static final String DUMMY_RESPONSE_JSON =
    '{' +
    '    \"code\": \"failed_precondition\",' +
    '    \"message\": \"assisted request not expected\", ' +
    '    \"details\": [' +
    '        {' +
    '            \"type\": \"ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '            \"value\": \"CAI\",' +
    '            \"debug\": {' +
    '                \"@type\": \"type.googleapis.com/ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
    '                \"cxOnboardingStage\": \"DUMMY\" ' +
    '            }' +
    '        }' +
    '    ]' +
    '}';

  @testSetup
  static void setup() {
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = FAKER.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = FAKER.randomString(10)
    );

    insert acc;
  }

  @isTest
  static void testPackageClosureSuccess() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Case newCase = new Case(
      AccountId = acc.Id,
      Account_Type__c = 'Individual',
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = FAKER.randomString(10)
    );

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();

    PackageClosureModel response = stravinskyApi.packageClosure(
      newCase,
      StravinskyServiceTest.CHECKING_ACCOUNT_LIST,
      StravinskyServiceTest.SAVINGS_ACCOUNT_LIST,
      StravinskyServiceTest.CUSTOMER_OCVIDS_LIST
    );
    PackageClosureModel.Status status = response.status;

    Test.stopTest();
    System.assertEquals(200, status.code, 'Status code of 200 expected');
    System.assertEquals(
      'Package closure successfully completed',
      status.description,
      'Package closure was not successful'
    );
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void closePackageInvalidResponse() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Case newCase = new Case(
      AccountId = acc.Id,
      Account_Type__c = 'Individual',
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    );

    HttpCalloutResponse res = getMockedResponse(false, 500, null);
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);
    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      PackageClosureModel response = stravinskyApi.packageClosure(
        newCase,
        StravinskyServiceTest.CHECKING_ACCOUNT_LIST,
        StravinskyServiceTest.SAVINGS_ACCOUNT_LIST,
        StravinskyServiceTest.CUSTOMER_OCVIDS_LIST
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals(
      EXCEPTION_JSON,
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void testTriggerTemporalCaseWorkflowFailureResponse() {
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      PersonaId__c = FAKER.randomString(15),
      Status = GetHelpConstants.COB_DAON_FAILED_STATUS
    );

    HttpCalloutResponse res = getMockedResponse(false, 500, EXCEPTION_JSON);
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    try {
      temporalCaseWorkflowAPI.triggerTemporalCaseWorkflow(newCase);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      EXCEPTION_JSON,
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  @isTest
  static void testCobPIdDetokenizationSuccess() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456'
    );

    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedValues = COBPrimaryIDDocumentModel.buildTokenizedValues(
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBPrimaryIDDocumentModel response = stravinskyApi.cobPidDetokenization(
      cobPid.PersonaId__c,
      tokenizedValues
    );
    Test.stopTest();

    Assert.isTrue(
      !response.values.isEmpty(),
      'Response should have valid detokenized values.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBPIDInvalidResponse() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456'
    );

    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedValues = COBPrimaryIDDocumentModel.buildTokenizedValues(
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    HttpCalloutResponse res = getMockedResponse(false, 500, null);
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      stravinskyApi.cobPidDetokenization(cobPid.PersonaId__c, tokenizedValues);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    System.assertEquals(
      EXCEPTION_JSON,
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  @isTest
  static void testCobPidTokenizationSuccess() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      FirstName__c = 'firstName',
      MiddleNames__c = 'middle names',
      LastName__c = 'lastName',
      DateOfBirth__c = Date.today(),
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456',
      ExpiryDate__c = Date.today(),
      StateOfIssue__c = 'AU'
    );

    COBPrimaryIDDocumentModel requestBody = COBPrimaryIDDocumentModel.buildUpdateRequestBody(
      cobPid
    );

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBPrimaryIDDocumentModel response = stravinskyApi.cobPidTokenization(
      cobPid.PersonaId__c,
      requestBody
    );
    Test.stopTest();

    Assert.isTrue(
      String.isNotEmpty(response.passport.passportNumberToken.value),
      'Response should have valid tokenized values.'
    );
  }

  @isTest
  static void testCobPidTokenizationFailure() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      FirstName__c = 'firstName',
      MiddleNames__c = 'middle names',
      LastName__c = 'lastName',
      DateOfBirth__c = Date.today(),
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456',
      ExpiryDate__c = Date.today(),
      StateOfIssue__c = 'AU'
    );

    COBPrimaryIDDocumentModel requestBody = COBPrimaryIDDocumentModel.buildUpdateRequestBody(
      cobPid
    );

    HttpCalloutResponse res = getMockedResponse(false, 500, null);
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      stravinskyApi.cobPidTokenization(cobPid.PersonaId__c, requestBody);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      EXCEPTION_JSON,
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  @isTest
  static void testHandleTemporalWorkflowResponseSuccessfull() {
    //Set successfull mock response
    HttpCalloutResponse response = getMockedResponse(true, 200, null);

    Exception resultException = null;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    StravinskyAPIRepository.CxStageWrapper cobStage;
    try {
      cobStage = temporalCaseWorkflowAPI.handleTemporalWorkflowResponse(
        response
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      null,
      resultException,
      'Exception should not have been thrown'
    );

    Assert.areEqual(
      StravinskyAPIRepository.COB_UPDATED,
      cobStage.cxOnboardingStage,
      'COB stage should have been: ' + StravinskyAPIRepository.COB_UPDATED
    );
  }

  @isTest
  static void testHandleTemporalWorkflowResponseExpectedResponseStageOnly() {
    //Set un-successfull expected mock response
    HttpCalloutResponse response = getMockedResponse(
      false,
      400,
      EXPECTED_RESPONSE_STAGE_ACK_ID_CHECK_JSON
    );

    Exception resultException = null;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    StravinskyAPIRepository.CxStageWrapper cobStage;
    try {
      cobStage = temporalCaseWorkflowAPI.handleTemporalWorkflowResponse(
        response
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      null,
      resultException,
      'Exception should not have been thrown'
    );
    Assert.areEqual(
      StravinskyAPIRepository.STAGE_ACK_ID_CHECK,
      cobStage.cxOnboardingStage,
      'COB stage should have been: ' +
      StravinskyAPIRepository.STAGE_ACK_ID_CHECK
    );
    Assert.isNull(cobStage.retryReason, 'Failed reason should be null');
  }

  @isTest
  static void testHandleTemporalWorkflowResponseExpectedResponseStageAndReason() {
    //Set un-successfull expected mock response
    HttpCalloutResponse response = getMockedResponse(
      false,
      400,
      EXPECTED_RESPONSE_STAGE_TNC_JSON
    );

    Exception resultException = null;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    StravinskyAPIRepository.CxStageWrapper cobStage;
    try {
      cobStage = temporalCaseWorkflowAPI.handleTemporalWorkflowResponse(
        response
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      null,
      resultException,
      'Exception should not have been thrown'
    );
    Assert.areEqual(
      StravinskyAPIRepository.STAGE_TNC,
      cobStage.cxOnboardingStage,
      'COB stage should have been: ' + StravinskyAPIRepository.STAGE_TNC
    );
    Assert.areEqual(
      FAILED_REASON,
      cobStage.retryReason,
      'Failed reason should have been: ' + FAILED_REASON
    );
  }

  @isTest
  static void testHandleTemporalWorkflowResponseNotExpectedResponse() {
    //Set un-successfull un-expected mock response
    HttpCalloutResponse response = getMockedResponse(
      false,
      400,
      DUMMY_RESPONSE_JSON
    );

    Exception resultException = null;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    StravinskyAPIRepository.CxStageWrapper cobStage;
    try {
      cobStage = temporalCaseWorkflowAPI.handleTemporalWorkflowResponse(
        response
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.isNotNull(
      resultException,
      'Exception should have been thrown due to not expected response'
    );
  }

  @isTest
  static void testHandleTemporalWorkflowResponseException() {
    //Set un-successfull mock response
    HttpCalloutResponse response = getMockedResponse(false, 401, null);

    Exception resultException = null;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    StravinskyAPIRepository.CxStageWrapper cobStage;
    try {
      cobStage = temporalCaseWorkflowAPI.handleTemporalWorkflowResponse(
        response
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.isNotNull(
      resultException,
      'Exception should have been thrown due to unsuccesfull response'
    );
  }

  /**
   * @param successfull true for a successfull mocked response, false for unsuccess,
   * @param statusCode mocked status code
   * @param body body of the mocked response
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getMockedResponse(
    Boolean successfull,
    Integer statusCode,
    String body
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    if (statusCode == 500) {
      response.error = new CalloutException(EXCEPTION_JSON);
    } else if (statusCode == 400) {
      response.error = new CalloutException(body);
    } else {
      response.body = body;
    }

    response.statusCode = statusCode;
    response.successful = successfull;

    return response;
  }
}
