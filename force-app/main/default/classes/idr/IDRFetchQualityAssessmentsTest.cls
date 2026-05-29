/**
 * @author CMOS
 * @since 04/2026
 * @description  Test class for {@link IDRFetchQualityAssessmentsController}
 */
@isTest
public class IDRFetchQualityAssessmentsTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider userMock;
  static Lib_MockProvider compMock;

  static final Faker FAKER = new Faker('0-9');
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );
  private static final Id FAKER_USER_ID = Lib_FakeIdGenerator.getMockId(
    User.getSObjectType()
  );
  static User testQAUser = new User(Id = FAKER_USER_ID);

  static void registerMock() {
    repoMock = Lib_MockProvider.forType(IDRQualityAssessmentRepo.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
    compMock = Lib_MockProvider.forType(ComplaintsRepository.class);
  }

  /**
   * @description Test Positive scenario with valid response for callout
   */
  @isTest
  private static void testFetchQualityAssessments() {
    registerMock();
    userMock.mock('getUser', testQAUser);
    QualityAssessmentResponseModel mocKRespModel = QualityAssessmentResponseModel.parse(
      '{"status" : "SUCCESS","httpsStatusCode" : 201,"qualityAssessmentId": "a01x000000BcDefAAB","message" : "Record created Successfully"}'
    );
    repoMock.mock('getQualityAssessments', mockRespModel);
    Test.startTest();
    QualityAssessmentResponseModel response = IDRFetchQualityAssessmentsController.fetchQualityAssessments(
      String.valueOf(caseRecord.CaseNumber)
    );
    Test.stopTest();
    Assert.areEqual(
      response.httpsStatusCode,
      201,
      'Response should be success'
    );
  }

  /**
   * @description Test Error scenarios with error response for callout error with 400 status code
   */
  @isTest
  static void testFetchQualityAssessmentsFailure() {
    registerMock();
    userMock.mock('getUser', testQAUser);
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.successful = false;
    mockResponse.statusCode = 400;
    mockResponse.error = new CalloutException('Callout failed');
    repoMock.mockException(
      'getQualityAssessments',
      new IDRQualityAssessmentRepo.IntegrationIssueException(mockResponse)
    );
    try {
      Test.startTest();
      IDRFetchQualityAssessmentsController.fetchQualityAssessments(
        String.valueOf(caseRecord.CaseNumber)
      );
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  /**
   * @description Test Error scenarios with error response for callout error with 500 status code
   */
  @isTest
  static void testFetchQualityAssessmentsTimeoutError() {
    registerMock();
    userMock.mock('getUser', testQAUser);
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.successful = false;
    mockResponse.statusCode = 500;
    mockResponse.error = new CalloutException('Callout failed');
    repoMock.mockException(
      'getQualityAssessments',
      new IDRQualityAssessmentRepo.TimeoutException(mockResponse)
    );
    try {
      Test.startTest();
      IDRFetchQualityAssessmentsController.fetchQualityAssessments(
        String.valueOf(caseRecord.CaseNumber)
      );
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  /**
   * @description Test Error scenarios with error response for Unhandled callout error with 501 status code
   */
  @isTest
  static void testFetchQualityAssessmentsUnhandled() {
    registerMock();
    userMock.mock('getUser', testQAUser);
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.successful = false;
    mockResponse.statusCode = 501;
    mockResponse.error = new CalloutException('Callout failed');
    repoMock.mockException(
      'getQualityAssessments',
      new IDRQualityAssessmentRepo.UnhandledException(mockResponse)
    );
    try {
      Test.startTest();
      IDRFetchQualityAssessmentsController.fetchQualityAssessments(
        String.valueOf(caseRecord.CaseNumber)
      );
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  /**
   * @description test get case method with valid response
   */
  @isTest
  static void testCheckCaseExists() {
    registerMock();
    compMock.mock('getCaseByCaseNumber', caseRecord);
    Test.startTest();
    Boolean caseExists = IDRFetchQualityAssessmentsController.checkCaseExists(
      String.valueOf(caseRecord.CaseNumber)
    );
    Test.stopTest();
    Assert.isTrue(caseExists, 'Case should exist');
  }
}
