/**
 * @author Naman Garg
 * @since Sept 2023
 * @description unit testing class for CCRMFinancialSummaryController class
 * @group Service
 */
@isTest
private class CCRMFinancialSummaryTest {
  @testSetup
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
    testAcc.External_Id__c = 'CAP-CIS_4017192605';
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
  static void testGetTotalBalance() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalCustomerBalanceMock()
    );

    CCRMFinancialSummaryController.CCRMBalanceWrapper totalBalanceWrap = new CCRMFinancialSummaryController.CCRMBalanceWrapper();
    totalBalanceWrap.accounts.add('DDA-901221265');
    totalBalanceWrap.accounts.add('ILS-397519424');
    totalBalanceWrap.accounts.add('FM-251500720');
    totalBalanceWrap.fieldSet = 'TOTAL_CUSTOMER_BALANCE';
    totalBalanceWrap.responseId = '0019h000009g1TxAAI';
    String status = CCRMFinancialSummaryController.getTotalBalance(
      totalBalanceWrap.responseId,
      totalBalanceWrap.accounts,
      totalBalanceWrap.fieldSet
    );
    system.assertEquals(status, 'Request Received');
    Test.stopTest();
  }

  @isTest
  static void testGetTotalTerminals() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalTerminalsMock()
    );

    CCRMFinancialSummaryController.CCRMTerminalTotalAssetWrapper terminalAssetWrap = new CCRMFinancialSummaryController.CCRMTerminalTotalAssetWrapper();
    terminalAssetWrap.capCustomerIds.add('4017192605');
    terminalAssetWrap.fieldSet = 'TERMINALS';
    terminalAssetWrap.responseId = '0019h000009g1TxAAI';
    String status = CCRMFinancialSummaryController.getTotalMerchantTerminals(
      terminalAssetWrap.responseId,
      terminalAssetWrap.capCustomerIds,
      terminalAssetWrap.fieldSet
    );
    system.assertEquals(status, 'Request Received');
    Test.stopTest();
  }

  @isTest
  static void testGetTotalAssetFinanceBalance() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalAssetFinanceBalanceMock()
    );

    CCRMFinancialSummaryController.CCRMTerminalTotalAssetWrapper terminalAssetWrap = new CCRMFinancialSummaryController.CCRMTerminalTotalAssetWrapper();
    terminalAssetWrap.capCustomerIds.add('4017192605');
    terminalAssetWrap.fieldSet = 'TOTAL_ASSET_FINANCE_BALANCE';
    terminalAssetWrap.responseId = '0019h000009g1TxAAI';
    terminalAssetWrap.type = 'BOTH';
    String status = CCRMFinancialSummaryController.getTotalAssetFinanceBalance(
      terminalAssetWrap.responseId,
      terminalAssetWrap.capCustomerIds,
      terminalAssetWrap.type,
      terminalAssetWrap.fieldSet
    );
    system.assertEquals(status, 'Request Received');
    Test.stopTest();
  }

  @isTest
  static void testGetSummariesInCacheByResponseId() {
    Test.startTest();
    User getUser = [
      SELECT Id, Name
      FROM User
      WHERE email = 'testUser1991@anz.com'
      LIMIT 1
    ];
    System.runAs(getUser) {
      Account accRec = [
        SELECT Id
        FROM Account
        WHERE Source_System_ID__c = '901221245'
        LIMIT 1
      ];

      String totalBalanceResponse =
        '{"data":{"schema":"2I3prliMclRc7FFVs2YMHA","payload":{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","CreatedById":"0059h000002n9pgAAA","Last_Calculated_Time__c":"2023-09-23T07:31:53Z","CreatedDate":"2023-09-23T07:31:53Z","Response_Id__c": "' +
        accRec.Id +
        '","Summary__c":178.01},"event":{"replayId":63102}},"channel":"/event/Financial_Summary_Calculation__e"}';
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      String terminalResponse =
        '{"data":{"schema":"2I3prliMclRc7FFVs2YMHA","payload":{"Summary_Type__c":"TERMINALS","CreatedById":"0059h000002n9pgAAA","Last_Calculated_Time__c":"2023-09-23T07:31:53Z","CreatedDate":"2023-09-23T07:31:53Z","Response_Id__c":"' +
        accRec.Id +
        '","Summary__c":3},"event":{"replayId":63102}},"channel":"/event/Financial_Summary_Calculation__e"}';
      CCRMFinancialSummaryController.insertDataInCache(terminalResponse);
      String assetBalanceResponse =
        '{"data":{"schema":"2I3prliMclRc7FFVs2YMHA","payload":{"Summary_Type__c":"TOTAL_ASSET_FINANCE_BALANCE","CreatedById":"0059h000002n9pgAAA","Last_Calculated_Time__c":"2023-09-23T07:31:53Z","CreatedDate":"2023-09-23T07:31:53Z","Response_Id__c":"' +
        accRec.Id +
        '","Summary__c":347.01},"event":{"replayId":63102}},"channel":"/event/Financial_Summary_Calculation__e"}';
      CCRMFinancialSummaryController.insertDataInCache(assetBalanceResponse);

      CCRMFinancialSummaryController.CCRMFinancialSummaryWrapper summariesWrap = new CCRMFinancialSummaryController.CCRMFinancialSummaryWrapper();
      summariesWrap = CCRMFinancialSummaryController.getSummariesByResponseId(
        accRec.Id
      );
      String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
      String expectedResponse =
        '{"totalMerchantTerminals":3,"totalBalance":178.01,"totalAssetFinanceBalance":347.01,"responseId":"' +
        accRec.Id +
        '","lastSummaryUpdateDate":"' +
        currentDateTime +
        '","acknowledgement":null}';
      System.assertEquals(
        expectedResponse,
        JSON.serialize(summariesWrap),
        'Financial Summaries Response not matched'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetSummariesByResponseId() {
    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalCustomerBalanceMock()
    );

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalTerminalsMock()
    );

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalAssetFinanceBalanceMock()
    );

    User getUser = [
      SELECT Id, Name
      FROM User
      WHERE email = 'testUser1991@anz.com'
      LIMIT 1
    ];
    System.runAs(getUser) {
      Account accRec = [
        SELECT Id
        FROM Account
        WHERE Source_System_ID__c = '901221245'
        LIMIT 1
      ];

      CCRMFinancialSummaryController.CCRMFinancialSummaryWrapper summariesWrap = new CCRMFinancialSummaryController.CCRMFinancialSummaryWrapper();
      summariesWrap = CCRMFinancialSummaryController.getSummariesByResponseId(
        accRec.Id
      );

      String expectedResponse = '{"totalMerchantTerminals":null,"totalBalance":null,"totalAssetFinanceBalance":null,"responseId":null,"lastSummaryUpdateDate":null,"acknowledgement":"Request sent"}';
      System.assertEquals(
        expectedResponse,
        JSON.serialize(summariesWrap),
        'Financial Summaries Response not matched when making callout'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testSummariesCallout() {
    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalCustomerBalanceMock()
    );

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalTerminalsMock()
    );

    Test.setMock(
      HttpCalloutMock.class,
      new CCRMFinancialSummaryTest.GetTotalAssetFinanceBalanceMock()
    );

    User getUser = [
      SELECT Id, Name
      FROM User
      WHERE email = 'testUser1991@anz.com'
      LIMIT 1
    ];
    System.runAs(getUser) {
      Account accRec = [
        SELECT Id, External_Id__c
        FROM Account
        WHERE Source_System_ID__c = '901221245'
        LIMIT 1
      ];
      CCRMFinancialSummaryController.summariesCallout(
        accRec.Id,
        true,
        true,
        true
      );
    }
    Test.stopTest();
  }

  /**
   * @description HTTP Mock class
   */
  public class GetTotalCustomerBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String response = '{"status": "Request Received", "fieldSet": "TOTAL_CUSTOMER_BALANCE", "responseId": "0019h000009g1TxAAI"}';
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(response);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP Mock class
   */
  public class GetTotalTerminalsMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String response = '{"status": "Request Received", "fieldSet": "TERMINALS", "responseId": "0019h000009g1TxAAI"}';
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(response);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description HTTP Mock class
   */
  public class GetTotalAssetFinanceBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String response = '{"status": "Request Received", "fieldSet": "TOTAL_ASSET_FINANCE_BALANCE", "responseId": "0019h000009g1TxAAI"}';
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(response);
      res.setStatusCode(200);
      return res;
    }
  }
}
