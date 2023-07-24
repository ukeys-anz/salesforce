/**
 * @author Mani
 * @since July 2023
 * @description ViewServiceabilityControllerTest is provide unit test coverage for ViewServiceabilityController.
 */
@isTest
private class ViewServiceabilityControllerTest {
  private static Faker faker;
  /**
   * @description Setup data for test classes
   */
  @testSetup
  public static void setup() {
    faker = new Faker('AU');

    List<Account> applicants = new List<Account>();
    applicants.add(getTestAccount('Sara', 'khan', '1000990280'));
    applicants.add(getTestAccount('Cameron', 'hanks', '1000990281'));
    applicants.add(getTestAccount('John', 'Tran', '1000990282'));
    applicants.add(getTestAccount('yuri', 'wang', '1000990283'));
    applicants.add(getTestAccount('Alan', 'king', '1000990284'));
    insert applicants;

    List<ResidentialLoanApplication> rlaLst = new List<ResidentialLoanApplication>();
    rlaLst.add(
      getTestResidentialLoanApplication(applicants[0].Id, '123', '123', '123')
    );
    rlaLst.add(
      getTestResidentialLoanApplication(applicants[1].Id, '456', '456', '')
    );
    insert rlaLst;
  }

  private static Account getTestAccount(
    string name,
    String lastname,
    String ocvId
  ) {
    return new Account(
      FirstName = name,
      LastName = lastname,
      OCV_ID__c = ocvId,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonMobilePhone = '0401' + faker.randomInteger(6)
    );
  }

  private static ResidentialLoanApplication getTestResidentialLoanApplication(
    string accId,
    string name,
    String sopId,
    String creditId
  ) {
    return new ResidentialLoanApplication(
      Name = name,
      AccountId = accId,
      Credit_ID__c = creditId,
      SOP_Id__c = sopId,
      Assessment_Outcome__c = 'Approved'
    );
  }

  @isTest
  static void testgetUMIAssessments() {
    Test.startTest();
    ResidentialLoanApplication rla = [
      SELECT Id
      FROM ResidentialLoanApplication
      WHERE Name = '123'
      LIMIT 1
    ];
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    ViewServiceabilityController ctrl = new ViewServiceabilityController();

    inputMap.put('loanId', rla.Id);
    Boolean isInvoked = ctrl.invokeMethod(
      'getUMIAssessments',
      inputMap,
      outMap,
      new Map<String, Object>()
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assert(
      (Boolean) payload.get('hasError') == false,
      'Invalid response'
    );
    System.assert(
      (Boolean) payload.get('isSubmitted'),
      'Application is should be submitted'
    );
  }
  @isTest
  static void testgetUMIAssessmentsWithError() {
    Test.startTest();
    ResidentialLoanApplication rla = [
      SELECT Id
      FROM ResidentialLoanApplication
      WHERE Name = '456'
      LIMIT 1
    ];
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    ViewServiceabilityController ctrl = new ViewServiceabilityController();

    inputMap.put('loanId', rla.Id);
    Boolean isInvoked = ctrl.invokeMethod(
      'getUMIAssessments',
      inputMap,
      outMap,
      new Map<String, Object>()
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assert((Boolean) payload.get('hasError'), 'Invalid response');
  }
  @isTest
  static void testBOHServicegetUMIAssessments() {
    Test.setMock(HttpCalloutMock.class, new MockViewUMICallout());
    String loanId = '123';
    BOHService serv = new BOHService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      loanId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    HttpCalloutResponse res = serv.getUMIAssessments(
      new List<String>{ loanId },
      loanId,
      loanId
    );
    Test.stopTest();
    System.assertEquals(res.statusCode, 200, 'api call unsucessfully');
  }
  /**
   * @description Mock view umi api callout
   */
  public class MockViewUMICallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      string jsonBody = Service.getStaticResource('mock_UMIListAssessments');
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonBody);
      return res;
    }
  }
}
