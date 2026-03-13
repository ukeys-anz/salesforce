/**
 * @author Victor Wang
 * @since November 2021
 * @description Test class for DocumentTypeController
 */
@isTest
public with sharing class StatementAPIRepositoryTest {
  private static final String ACCOUNT_OCV_ID = '2200993355';
  private static final String ACCOUNT_NUMBER = '210490765';
  private static final String PAGE_SIZE = '10';
  private static final String CONTEXT_TYPE = 'Statements';
  private static final String NAME = 'documents/7f3a9b2e-1c4d-4f12-8a2b-0d3e9f6a1234';
  static Lib_MockProvider userMock;
  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  /**
   * @description Test getStatements
   */
  @isTest
  public static void testGetStatement() {
    registerMocks();
    Test.startTest();
    ListDocumentModel model = DocumentTypeController.getStatements(
      ACCOUNT_OCV_ID,
      ACCOUNT_NUMBER,
      PAGE_SIZE,
      CONTEXT_TYPE
    );
    Test.stopTest();
    Assert.areEqual(
      23,
      model.allDocuments.size(),
      'Should return 23 statement records.'
    );
  }

  /**
   * @description Test getStatement for Notices
   */
  @isTest
  public static void testGetStatementForNotices() {
    registerMocks();
    Test.startTest();
    ListDocumentModel model = DocumentTypeController.getStatements(
      ACCOUNT_OCV_ID,
      ACCOUNT_NUMBER,
      PAGE_SIZE,
      'NOTICES'
    );
    Test.stopTest();
    Assert.areEqual(
      10,
      model.allDocuments.size(),
      'Should return 10 valid notice records.'
    );
  }

  /**
   * @description fetch statement url for a valid statement id
   */
  @isTest
  static void testGetStatementUrlAura() {
    registerMocks();
    Map<String, String> additionaldetails = new Map<String, String>();
    additionaldetails.put('accountId', 'test1234');
    additionaldetails.put('financialAccountId', '1234');
    additionaldetails.put('contextType', 'Statements');
    additionaldetails.put('fromDate', '2025-09-15');
    additionaldetails.put('toDate', '2025-09-30');
    additionaldetails.put('issueDate', '2025-09-15');
    additionaldetails.put('documentType', 'ANZ Test Product');
    additionaldetails.put('sUID', userinfo.getUserId());
    Test.startTest();
    DocumentSignedURLModel statement = DocumentTypeController.getStatementUrl(
      ACCOUNT_OCV_ID,
      NAME,
      additionaldetails
    );
    Test.stopTest();
    Assert.isNotNull(
      statement.document,
      'Statement document should not be null'
    );
  }

  /**
   * @description Test getStatements exception
   */
  @isTest
  public static void testGetStatementException() {
    registerMocks();
    ListDocumentModel model;
    HttpCalloutResponse res = getStatementInvalidResponse();
    Service s = ServiceProvider.getService(FabricService.class);
    s.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    try {
      model = DocumentTypeController.getStatements(
        ACCOUNT_OCV_ID,
        ACCOUNT_NUMBER,
        PAGE_SIZE,
        CONTEXT_TYPE
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'Statement retrieve failed',
      resultException.getMessage(),
      'Should return exception message.'
    );
  }

  /**
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getStatementInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Statement retrieve failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  /**
   * @description Test user without View Statements permission
   */
  @isTest
  public static void testGetStatementPermissionException() {
    registerMocks();
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', false);
    Exception ex;
    Test.startTest();
    try {
      DocumentTypeController.getStatements(
        ACCOUNT_OCV_ID,
        ACCOUNT_NUMBER,
        PAGE_SIZE,
        CONTEXT_TYPE
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'User does not have the view statements permission.',
      ex.getMessage(),
      'Exception should be thrown'
    );
  }

  /**
   * @description Test getStatementURL exception
   */
  @isTest
  public static void testGetStatementURLException() {
    registerMocks();
    Map<String, String> additionaldetails = new Map<String, String>();
    additionaldetails.put('accountId', 'test1234');
    additionaldetails.put('financialAccountId', '1234');
    additionaldetails.put('contextType', 'Statements');
    additionaldetails.put('fromDate', '2025-09-15');
    additionaldetails.put('toDate', '2025-09-30');
    additionaldetails.put('issueDate', '2025-09-15');
    additionaldetails.put('documentType', 'ANZ Test Product');
    additionaldetails.put('sUID', userinfo.getUserId());
    HttpCalloutResponse res = getStatementInvalidResponse();
    Service s = ServiceProvider.getService(FabricService.class);
    s.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    try {
      DocumentTypeController.getStatementUrl(
        ACCOUNT_OCV_ID,
        NAME,
        additionaldetails
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'Statement retrieve failed',
      resultException.getMessage(),
      'Should return exception for url generation.'
    );
  }

  /**
   * @description Test user without View Statements permission
   */
  @isTest
  public static void testGetStatementURLPermissionException() {
    registerMocks();
    Map<String, String> additionaldetails = new Map<String, String>();
    additionaldetails.put('accountId', 'test1234');
    additionaldetails.put('financialAccountId', '1234');
    additionaldetails.put('contextType', 'Statements');
    additionaldetails.put('fromDate', '2025-09-15');
    additionaldetails.put('toDate', '2025-09-30');
    additionaldetails.put('issueDate', '2025-09-15');
    additionaldetails.put('documentType', 'ANZ Test Product');
    additionaldetails.put('sUID', userinfo.getUserId());
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', false);
    Exception ex;
    Test.startTest();
    try {
      DocumentTypeController.getStatementUrl(
        ACCOUNT_OCV_ID,
        NAME,
        additionaldetails
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'User does not have the view statements permission.',
      ex.getMessage(),
      'Exception should be thrown'
    );
  }
}
