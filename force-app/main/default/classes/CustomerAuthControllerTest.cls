/**
 * @author Ayushi Gupta
 * @since 08/2022
 * @description Test class for Customer Authentication controller class
 */
@isTest
public class CustomerAuthControllerTest {
  @testSetup
  static void setup() {
    // Insert User & PermissionSet as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
      User testUser = new User(
        Alias = 'standt',
        Email = 'testUser1991@anz.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'testUser1991@anz.com'
      );
      insert testUser;
      PermissionSet permSet = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'MLCRM_Base'
      ][0];
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = testUser.Id,
        PermissionSetId = permSet.Id
      );
      insert psa;
    }
    Account testAcc = TestDataFactory.createAccount(false);
    testAcc.Source_System_ID__c = '901221245';
    insert testAcc;

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    AccountShare accountShare = new AccountShare();
    accountShare.AccountId = testAcc.Id;
    accountShare.AccountAccessLevel = 'Edit';
    accountShare.ContactAccessLevel = 'Read';
    accountShare.CaseAccessLevel = 'Read';
    accountShare.OpportunityAccessLevel = 'Read';
    accountShare.UserOrGroupId = u.Id;
    insert accountShare;
  }
  @isTest
  static void getSecurityCodeTest() {
    String customerId = [
      SELECT Id
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ]
    .Id;
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CustomerAuthControllerTest.getSecurityCodeTestMock()
    );

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      String response = CustomerAuthController.getSecurityCode(customerId);
      System.assertEquals('BRANCH TO LOAD', response, 'Code mismatch');
    }

    Test.stopTest();
    Account acc = [
      SELECT id, Security_Code_Requested__c
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      acc.Security_Code_Requested__c,
      'value mismatch'
    );
  }
  @isTest
  static void updateSecurityCodeTest() {
    String customerId = [
      SELECT Id
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ]
    .Id;

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CustomerAuthControllerTest.updateSecurityCodeTestMock()
    );

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      String securityCode = '12356789';
      Boolean response = CustomerAuthController.updateSecurityCode(
        customerId,
        securityCode
      );

      System.assertEquals(true, response, 'Response is not true');
      Account acc = [
        SELECT id, Security_Code_Updated__c
        FROM Account
        WHERE id = :customerId
      ];
      System.assertNotEquals(
        null,
        acc.Security_Code_Updated__c,
        'Security code updated is not null'
      );
    }
    Test.stopTest();
  }
  @isTest
  static void createDiaryCommentTest() {
    String customerId = [
      SELECT Id
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ]
    .Id;
    String comment = 'some comment';
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CustomerAuthControllerTest.createDiaryCommentTestMock()
    );
    system.assertEquals(
      true,
      CustomerAuthController.createDiaryComment(customerId, comment, 'IdTheft'),
      'Result is not true'
    );
    system.assertEquals(
      true,
      CustomerAuthController.createDiaryComment(
        customerId,
        comment,
        'ExistingBranch'
      ),
      'Result is not true'
    );
    system.assertEquals(
      true,
      CustomerAuthController.createDiaryComment(
        customerId,
        comment,
        'FailedAuth'
      ),
      'Result is not true'
    );
    Test.stopTest();
  }

  /**
   * @description HTTP mock class for getSecurityCodeTest
   */
  public class GetSecurityCodeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'get-security-code');
      res.setBody(new CCRMARNCServiceMock().getSecurityCode().body);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description HTTP mock class for Create Diary Comment
   */
  public class CreateDiaryCommentTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'create-diary-comment');
      res.setBody(new CCRMARNCServiceMock().createDiaryComment().body);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP mock class for Update Security Code
   */
  public class UpdateSecurityCodeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'update-security-code');
      res.setBody(new CCRMARNCServiceMock().updateSecurityCode().body);
      res.setStatusCode(200);
      return res;
    }
  }
}
