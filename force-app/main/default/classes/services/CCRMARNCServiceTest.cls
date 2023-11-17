/**
 * @author Ian Huang
 * @since August 2023
 * @description unit testing class for CCRMARNCService class
 * @group Service
 */
@isTest
private class CCRMARNCServiceTest {
  @TestSetup
  static void createTestData() {
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
  static void queryCAPAccountsTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMARNCServiceTest.queryCAPAccountsTestMock()
    );
    CCRMARNCService service = new CCRMARNCService();
    CCRMARNCService.FinancialAccountQueryParameters queryParams = new CCRMARNCService.FinancialAccountQueryParameters();
    queryParams.accounts.add('4034567890');
    queryParams.accounts.add('4034567891');
    queryParams.accounts.add('4034567892');
    HttpCalloutResponse response = service.queryCAPAccounts(
      'DepositAccount',
      queryParams
    );
    List<Object> res = (List<Object>) ((Map<String, Object>) JSON.deserializeUntyped(
        response.body
      ))
      .get('accounts');
    Map<String, Object> firstRec = (Map<String, Object>) res[0];
    system.assertEquals(
      (string) firstRec.get('accountName'),
      'TO_BE_CLARIFIED'
    );
    system.assertEquals((string) firstRec.get('accountNumber'), '431214465');
    Test.stopTest();
  }

  @isTest
  static void queryEBDAccountsTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMARNCServiceTest.queryEBDAccountsTestMock()
    );
    CCRMARNCService service = new CCRMARNCService();
    CCRMARNCService.FinancialAccountQueryParameters queryParams = new CCRMARNCService.FinancialAccountQueryParameters();
    queryParams.capCustomerIds.add('4017192605');
    HttpCalloutResponse response = service.queryEBDAccounts(
      'CommercialBill',
      queryParams,
      null
    );
    List<Object> res = (List<Object>) ((Map<String, Object>) JSON.deserializeUntyped(
        response.body
      ))
      .get('accounts');
    Map<String, Object> firstRec = (Map<String, Object>) res[0];
    system.assertEquals(
      (string) firstRec.get('accountName'),
      'TO_BE_CLARIFIED'
    );
    system.assertEquals((string) firstRec.get('accountNumber'), '431214465');
    Test.stopTest();
  }

  @isTest
  static void queryAccountDetailTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMARNCServiceTest.queryAccountDetailTestMock()
    );
    CCRMARNCService service = new CCRMARNCService();
    String payload = '{"accountNumber": "DDA-901221265"}';
    HttpCalloutResponse response = service.queryAccountDetail(
      'deposit',
      payload
    );
    List<Object> res = (List<Object>) ((Map<String, Object>) JSON.deserializeUntyped(
        response.body
      ))
      .get('accounts');
    Map<String, Object> firstRec = (Map<String, Object>) res[0];
    system.assertEquals(
      (string) firstRec.get('accountName'),
      'VAALEPU CORP. NOMINEES TRUST'
    );
    system.assertEquals((string) firstRec.get('accountNumber'), '901221265');
    Test.stopTest();
  }

  @isTest
  static void queryDiaryCommentTest() {
    Test.startTest();
    CCRMARNCService service = new CCRMARNCService();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMARNCServiceTest.queryDiaryCommentTestMock()
    );
    String parent = '901221265';
    Map<String, String> params = new Map<String, String>();
    params.put(parent, '4040r00000E3yPTAAZ-4034567890|DDA-901221265');
    String nextPageId = '';
    HttpCalloutResponse response = service.queryDiaryComment(
      parent,
      params,
      nextPageId
    );
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    System.assertEquals(
      '',
      (string) result.get('conversationControl'),
      'Value mismatch'
    );
    System.assertEquals(
      93,
      (Integer) result.get('totalComments'),
      'Value mismatch'
    );
    System.assertEquals(
      43,
      (Integer) result.get('commentsCount'),
      'Value mismatch'
    );
    Test.stopTest();
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
      new CCRMARNCServiceTest.getSecurityCodeTestMock()
    );

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      CCRMARNCService service = new CCRMARNCService();
      String response = service.getSecurityCode(customerId);
      System.assertEquals(response, 'BRANCH TO LOAD');
    }

    Test.stopTest();
    Account acc = [
      SELECT id, Security_Code_Requested__c
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ];
    System.assertNotEquals(acc.Security_Code_Requested__c, null);
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
      new CCRMARNCServiceTest.createDiaryCommentTestMock()
    );
    CCRMARNCService service = new CCRMARNCService();
    system.assertEquals(
      service.createDiaryComment(customerId, comment, 'IdTheft'),
      true
    );
    system.assertEquals(
      service.createDiaryComment(customerId, comment, 'ExistingBranch'),
      true
    );
    system.assertEquals(
      service.createDiaryComment(customerId, comment, 'FailedAuth'),
      true
    );
    Test.stopTest();
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
      new CCRMARNCServiceTest.updateSecurityCodeTestMock()
    );

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      String securityCode = '12356789';
      CCRMARNCService service = new CCRMARNCService();
      Boolean response = service.updateSecurityCode(customerId, securityCode);

      System.assertEquals(response, true);
      Account acc = [
        SELECT id, Security_Code_Updated__c
        FROM Account
        WHERE id = :customerId
      ];
      System.assertNotEquals(acc.Security_Code_Updated__c, null);
    }
    Test.stopTest();
  }

  @isTest
  static void updateSecurityCodeTestWithInvalidRespone() {
    String customerId = [
      SELECT Id
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ]
    .Id;
    String securityCode = '12356789';
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMARNCServiceTest.CCRMARNServiceTestMockInvalidResponse()
    );
    CCRMARNCService service = new CCRMARNCService();

    try {
      Boolean response = service.updateSecurityCode(customerId, securityCode);
      Account acc = [
        SELECT id, Security_Code_Updated__c
        FROM Account
        WHERE id = :customerId
      ];
      system.assertNotEquals(acc.Security_Code_Updated__c, null);
      system.assertEquals(response, true);
      User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
      System.runAs(u) {
        service.updateSecurityCode(customerId, securityCode);
      }
    } catch (Exception e) {
      system.assert(true);
    }
    Test.stopTest();
  }

  @isTest
  static void createDiaryCommentInvalidResponseTest() {
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
      new CCRMARNCServiceTest.CCRMARNServiceTestMockInvalidResponse()
    );
    CCRMARNCService service = new CCRMARNCService();
    try {
      system.assertEquals(
        service.createDiaryComment(customerId, comment, 'IdTheft'),
        false
      );
      User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
      System.runAs(u) {
        system.assertEquals(
          service.createDiaryComment(customerId, comment, 'IdTheft'),
          false
        );
      }
    } catch (Exception e) {
    }
    Test.stopTest();
  }

  /**
   * @description HTTP mock class
   */
  public class CCRMARNServiceTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String response = '{"ResponseKey": "ResponseValue", "status":"Success"}';
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(response);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP mock class for QueyCapAccount
   */
  public class QueryCAPAccountsTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'cap-account');
      res.setBody(new CCRMARNCServiceMock().queryCAPAccounts().body);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP mock class for QueryEBDAccounts
   */
  public class QueryEBDAccountsTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'deposity-success-with-one-account');
      res.setBody(new CCRMARNCServiceMock().queryEBDAccounts().body);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP mock class for queryAccountDetailTest
   */
  public class QueryAccountDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'query-account-details');
      res.setBody(new CCRMARNCServiceMock().queryAccountDetails().body);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP mock class for queryDiaryCommentTest
   */
  public class QueryDiaryCommentTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'query-diary-comment');
      res.setBody(new CCRMARNCServiceMock().queryDiaryComments().body);
      res.setStatusCode(200);
      return res;
    }
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
   * @description HTTP mock class for Creae Diary Comment
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
  /**
   * @description HTTP mock class with invalid response
   */
  public class CCRMARNServiceTestMockInvalidResponse implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String response = '{{{"{{{{{ResponseKey": "ResponseValue", "status":"Success", "securityCode":"mx123"}';
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(response);
      res.setStatusCode(200);
      return res;
    }
  }
}
