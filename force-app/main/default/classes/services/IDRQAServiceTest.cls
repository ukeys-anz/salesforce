/**
 * @author CMOS
 * @since 04/2026
 * @description  Test class for {@link IDRQAService}
 */
@isTest
public class IDRQAServiceTest {
  static final Faker FAKER = new Faker('0-9');
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );
  @isTest
  public static void getQualityAssessmentsTest() {
    StaffTokenRequestModel staffModel = IDRQAService.setStaffModel(
      IDRConstants.QA_FORGE_RECORD
    );
    String hashedKey = AuthTokenCacheUtil.getHashedKey(
      'forgeJWTToken' + staffModel.apiScopesRequested
    );
    Cache.Session.put(
      'local.ForgeToken.' + hashedKey,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IDRQAServiceTest.GetQualityAssessmentsMock()
    );
    QualityAssessmentRequestModel reqObj = new QualityAssessmentRequestModel(
      String.valueOf(caseRecord.CaseNumber),
      String.valueOf(userinfo.getuserId())
    );
    HttpCalloutResponse resp = new IDRQAService().getQualityAssessments(reqObj);
    Assert.isTrue(
      resp.statusCode == 200,
      'Qulaity Assessment API should return 200'
    );
  }
  /**
   * @description HTTP mock class for IDRQAService
   */
  public class GetQualityAssessmentsMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponses
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = '{"status" : "SUCCESS","httpsStatusCode" : 201,"qualityAssessmentId": "a01x000000BcDefAAB","message" : "Record created Successfully"}';
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
