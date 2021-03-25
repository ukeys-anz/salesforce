/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description TransactionHistoryControllerTest is the test class to cover tests for {@link TransactionHistoryController}
 */
@isTest
public with sharing class TransactionHistoryControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addAccountsGoalsPs();
  }

  /**
   * @description test method for getTransactions when successful
   */
  @isTest
  public static void validResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.setMock(
        HttpCalloutMock.class,
        new ForgeTokenHandlerTest.MockForgeCallout()
      );
      Id userId = UserInfo.getUserId();
      Cache.Session.put(
        'local.SessionAzureTokens.idToken' + userId,
        ForgeTokenHandlerTest.IDTESTVALUE,
        300,
        Cache.Visibility.NAMESPACE,
        false
      );

      Test.startTest();
      String respBody = TransactionHistoryController.getTransactions(
        '1111',
        '11111111',
        ''
      );
      System.assertEquals(
        '{"access_token":"xxxxx","expires_in":900}',
        respBody
      );
      Test.stopTest();
    }
  }

  /**
   * @description test method for getTransactions when forge token failed
   */
  @isTest
  public static void invalidResponseFromForgeToken() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.setMock(
        HttpCalloutMock.class,
        new ForgeTokenHandlerTest.MockForgeCalloutFailed()
      );
      Id userId = UserInfo.getUserId();
      Cache.Session.put(
        'local.SessionAzureTokens.idToken' + userId,
        ForgeTokenHandlerTest.IDTESTVALUE,
        300,
        Cache.Visibility.NAMESPACE,
        false
      );
      String expMessage;

      Test.startTest();
      try {
        TransactionHistoryController.getTransactions('1111', '11111111', '');
      } catch (Exception e) {
        expMessage = e.getMessage();
      }

      System.assertEquals('Get access token failed', expMessage);

      Test.stopTest();
    }
  }

  /**
   * @description test method for getTransactions when failed
   */
  @isTest
  public static void invalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.setMock(HttpCalloutMock.class, new MockInvalidTransactionCallout());
      Id userId = UserInfo.getUserId();
      Cache.Session.put(
        'local.SessionAzureTokens.idToken' + userId,
        ForgeTokenHandlerTest.IDTESTVALUE,
        300,
        Cache.Visibility.NAMESPACE,
        false
      );

      String expMessage;

      Test.startTest();
      try {
        TransactionHistoryController.getTransactions('1111', '11111111', '');
      } catch (Exception e) {
        expMessage = e.getMessage();
      }

      System.assertEquals('Get transactions failed', expMessage);

      Test.stopTest();
    }
  }

  class MockInvalidTransactionCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().contains('/api/transactions?account_number')) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Get transactions failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }

  /**
   * @description test method for getDisputeRecordTypeMap
   */
  @isTest
  public static void testGetDisputeRecordTypeMap() {
    Test.startTest();
    String recordTypesString = TransactionHistoryController.getDisputeRecordTypeMap();
    Test.stopTest();
    Map<String, RecordType> disputeRecordTypeMap = (Map<String, RecordType>) JSON.deserialize(
      recordTypesString,
      Map<String, RecordType>.class
    );
    System.assertNotEquals(
      0,
      disputeRecordTypeMap.size(),
      'Dispute record types are returned'
    );
  }

  /*
   * @description test method for getPersonContactId
   */
  @isTest
  public static void testGetPersonContactId() {
    String recTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'
    ]
    .Id;

    Account acc = new Account(
      RecordTypeId = recTypeId,
      FirstName = 'Steve',
      LastName = 'Rogers',
      OCV_ID__c = '123456',
      External_Id__c = 'a#@sjaf0832'
    );
    insert acc;
    FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c(
      Name = 'Savings Account',
      FinServ__PrimaryOwner__c = acc.Id,
      Account_Key__c = 'b#2fa8s0',
      Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11')
    );
    insert finAcc;
    Test.startTest();
    String personContactId = TransactionHistoryController.getPersonContactId(
      finAcc.Id
    );
    Test.stopTest();
    System.assertEquals(
      [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1][0]
      .Id,
      personContactId,
      'Person Contact Id was retrieved'
    );
  }
}
