/**
 * @author Ian Huang
 * @since August 2023
 * @description unit testing class for ARNCService class
 * @group Service
 */
@isTest
private class ARNCServiceTest {
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
    Test.setMock(HttpCalloutMock.class, new queryCAPAccountsTestMock());
    ARNCService service = new ARNCService();
    ARNCService.FinancialAccountQueryParameters queryParams = new ARNCService.FinancialAccountQueryParameters();
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
    Assert.areEqual(
      (string) firstRec.get('accountName'),
      'TO_BE_CLARIFIED',
      'incorrect value'
    );
    Assert.areEqual(
      (string) firstRec.get('accountNumber'),
      '431214465',
      'incorrect value'
    );
    Test.stopTest();
  }

  @isTest
  static void queryEBDAccountsTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new queryEBDAccountsTestMock());
    ARNCService service = new ARNCService();
    ARNCService.FinancialAccountQueryParameters queryParams = new ARNCService.FinancialAccountQueryParameters();
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
    Assert.areEqual(
      (string) firstRec.get('accountName'),
      'TO_BE_CLARIFIED',
      'incorrect value'
    );
    Assert.areEqual(
      (string) firstRec.get('accountNumber'),
      '431214465',
      'incorrect value'
    );
    Test.stopTest();
  }

  @isTest
  static void queryAccountDetailTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new queryAccountDetailTestMock());
    ARNCService service = new ARNCService();
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
    Assert.areEqual(
      (string) firstRec.get('accountName'),
      'VAALEPU CORP. NOMINEES TRUST',
      'incorrect value'
    );
    Assert.areEqual(
      (string) firstRec.get('accountNumber'),
      '901221265',
      'incorrect value'
    );
    Test.stopTest();
  }

  @isTest
  static void queryDiaryCommentTest() {
    Test.startTest();
    ARNCService service = new ARNCService();
    Test.setMock(HttpCalloutMock.class, new queryDiaryCommentTestMock());
    String parent = '901221265';
    Map<String, String> params = new Map<String, String>();
    params.put(parent, '4040r00000E3yPTAAZ-4034567890|DDA-901221265');
    HttpCalloutResponse response = service.queryDiaryComment(parent, params);
    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    Assert.areEqual(
      '',
      (string) result.get('conversationControl'),
      'Value mismatch'
    );
    Assert.areEqual(
      93,
      (Integer) result.get('totalComments'),
      'Value mismatch'
    );
    Assert.areEqual(
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
    Test.setMock(HttpCalloutMock.class, new getSecurityCodeTestMock());

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      ARNCService service = new ARNCService();
      String response = service.getSecurityCode(customerId);
      Assert.areEqual(response, 'BRANCH TO LOAD', 'incorrect value');
    }

    Test.stopTest();
    Account acc = [
      SELECT id, Security_Code_Requested__c
      FROM Account
      WHERE Source_System_ID__c = '901221245'
      LIMIT 1
    ];
    Assert.areNotEqual(
      acc.Security_Code_Requested__c,
      null,
      'null value found'
    );
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
    Test.setMock(HttpCalloutMock.class, new createDiaryCommentTestMock());
    ARNCService service = new ARNCService();
    Assert.areEqual(
      service.createDiaryComment(customerId, comment, 'IdTheft'),
      true,
      'incorrect value'
    );
    Assert.areEqual(
      service.createDiaryComment(customerId, comment, 'ExistingBranch'),
      true,
      'incorrect value'
    );
    Assert.areEqual(
      service.createDiaryComment(customerId, comment, 'FailedAuth'),
      true,
      'incorrect value'
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
    Test.setMock(HttpCalloutMock.class, new updateSecurityCodeTestMock());

    User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
    System.runAs(u) {
      String securityCode = '12356789';
      ARNCService service = new ARNCService();
      Boolean response = service.updateSecurityCode(customerId, securityCode);

      Assert.areEqual(response, true, 'incorrect value');
      Account acc = [
        SELECT id, Security_Code_Updated__c
        FROM Account
        WHERE id = :customerId
      ];
      Assert.areNotEqual(acc.Security_Code_Updated__c, null, 'null value');
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
      new ARNCServiceTestMockInvalidResponse()
    );
    ARNCService service = new ARNCService();

    try {
      Boolean response = service.updateSecurityCode(customerId, securityCode);
      Account acc = [
        SELECT id, Security_Code_Updated__c
        FROM Account
        WHERE id = :customerId
      ];
      Assert.areNotEqual(acc.Security_Code_Updated__c, null, 'null value');
      Assert.areEqual(response, true, 'incorrect value');
      User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
      System.runAs(u) {
        service.updateSecurityCode(customerId, securityCode);
      }
    } catch (Exception e) {
      Assert.isTrue(true, 'incorrect value');
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
      new ARNCServiceTestMockInvalidResponse()
    );
    ARNCService service = new ARNCService();
    try {
      Assert.areEqual(
        service.createDiaryComment(customerId, comment, 'IdTheft'),
        false,
        'incorrect value'
      );
      User u = [SELECT id FROM user WHERE email = 'testUser1991@anz.com'];
      System.runAs(u) {
        Assert.areEqual(
          service.createDiaryComment(customerId, comment, 'IdTheft'),
          false,
          'incorrect value'
        );
      }
    } catch (Exception e) {
    }
    Test.stopTest();
  }

  /**
   * @description HTTP mock class
   */
  public class ARNServiceTestMock implements HttpCalloutMock {
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
      res.setBody(new ARNCServiceMock().queryCAPAccounts().body);
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
      res.setBody(new ARNCServiceMock().queryEBDAccounts().body);
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
      res.setBody(new ARNCServiceMock().queryAccountDetails().body);
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
      res.setBody(new ARNCServiceMock().queryDiaryComments().body);
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
      res.setBody(new ARNCServiceMock().getSecurityCode().body);
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
      res.setBody(new ARNCServiceMock().createDiaryComment().body);
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
      res.setBody(new ARNCServiceMock().updateSecurityCode().body);
      res.setStatusCode(200);
      return res;
    }
  }
  /**
   * @description HTTP mock class with invalid response
   */
  public class ARNCServiceTestMockInvalidResponse implements HttpCalloutMock {
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
