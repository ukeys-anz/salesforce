/**
 * @author CMOS
 * @since 04/2026
 * @description  Test class for {@link IDRQualityAssessmentRepo}
 */
@isTest
public class IDRQualityAssessmentRepoTest {
  private static Lib_MockProvider serviceMock = Lib_MockProvider.forType(
    IDRQAService.class
  );
  private static Lib_MockProvider calloutMock = Lib_MockProvider.forType(
    Lib_HttpCallout.class
  );
  static final Faker FAKER = new Faker('0-9');
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );
  @isTest
  private static void testgetQualityAssessments() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = '{"status" : "SUCCESS","httpsStatusCode" : 201,"qualityAssessmentId": "a01x000000BcDefAAB","message" : "Record created Successfully"}';
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;
    serviceMock.mock('getQualityAssessments', mockResponse);

    Test.startTest();

    QualityAssessmentRequestModel reqObj = new QualityAssessmentRequestModel(
      String.valueOf(caseRecord.CaseNumber),
      String.valueOf(userinfo.getuserId())
    );
    QualityAssessmentResponseModel respModel = new IDRQualityAssessmentRepo()
      .getQualityAssessments(reqObj);
    Test.stopTest();
    Assert.isTrue(
      respModel.status == 'SUCCESS',
      'Quality Assessment Should be fetched'
    );
  }
  @isTest
  private static void testTimeOutException() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.error = new DMLException('exceptionText');
    mockResponse.statusCode = 500;
    serviceMock.mock('getQualityAssessments', mockResponse);

    try {
      Test.startTest();

      QualityAssessmentRequestModel reqObj = new QualityAssessmentRequestModel(
        String.valueOf(caseRecord.CaseNumber),
        String.valueOf(userinfo.getuserId())
      );
      new IDRQualityAssessmentRepo().getQualityAssessments(reqObj);
      Test.stopTest();
      Assert.fail('TimeoutException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        IDRQualityAssessmentRepo.TimeoutException.class,
        'TimeoutException expected.'
      );
    }
  }
  @isTest
  private static void testIntegrationIssueException() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.error = new DMLException('exceptionText');
    mockResponse.statusCode = 400;
    serviceMock.mock('getQualityAssessments', mockResponse);

    try {
      Test.startTest();

      QualityAssessmentRequestModel reqObj = new QualityAssessmentRequestModel(
        String.valueOf(caseRecord.CaseNumber),
        String.valueOf(userinfo.getuserId())
      );
      new IDRQualityAssessmentRepo().getQualityAssessments(reqObj);
      Test.stopTest();
      Assert.fail('IntegrationIssueException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        IDRQualityAssessmentRepo.IntegrationIssueException.class,
        'IntegrationIssueException expected.'
      );
    }
  }

  @isTest
  private static void testUnhandledException() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.error = new DMLException('exceptionText');
    mockResponse.successful = false;
    serviceMock.mock('getQualityAssessments', mockResponse);

    try {
      Test.startTest();

      QualityAssessmentRequestModel reqObj = new QualityAssessmentRequestModel(
        String.valueOf(caseRecord.CaseNumber),
        String.valueOf(userinfo.getuserId())
      );
      new IDRQualityAssessmentRepo().getQualityAssessments(reqObj);
      Test.stopTest();
      Assert.fail('UnhandledException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        IDRQualityAssessmentRepo.UnhandledException.class,
        'UnhandledException expected.'
      );
    }
  }
}
