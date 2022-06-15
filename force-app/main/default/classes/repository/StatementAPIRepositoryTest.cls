/**
 * @author Victor Wang
 * @since November 2021
 * @description Test class for StatementAPIRepository
 */
@isTest
public with sharing class StatementAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'View_Statements' });

    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a FraudX User with 'FraudX Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      UserRole role = CommonUtil.getUserRoleByDevName('FraudX_Agent');
      User fraudXAgent = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'FraudXTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert fraudXAgent;
    }
  }

  /**
   * @description Test getStatements list
   */
  @isTest
  public static void testGetStatement() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      StatementModel model = StatementAPIRepository.getStatementsAura(
        '1111',
        null,
        '10'
      );
      Test.stopTest();

      System.assert(
        model.statements.size() == 4,
        'Should return 4 statement records.'
      );
    }
  }

  /**
   * @description Test getStatements exception
   */
  @isTest
  public static void testGetStatementException() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      StatementModel model;
      HttpCalloutResponse res = getStatementInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      StatementAPIRepository statementapi = new StatementAPIRepository();
      try {
        model = statementapi.getStatements('1111', '1111', '10');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();

      System.assertEquals(
        'Statement retrieve failed',
        resultException.getMessage(),
        'Should return exception message.'
      );
    }
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
    User fraudUser = TestUtil.getUserByFirstName('FraudXTest');
    System.runAs(fraudUser) {
      Exception resultException;
      Test.startTest();
      try {
        StatementModel model = StatementAPIRepository.getStatementsAura(
          '1111',
          null,
          '10'
        );
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();

      System.assertEquals(
        'User does not have the view statements permission.',
        resultException.getMessage(),
        'Should return exception message.'
      );
    }
  }

  /**
   * @description Test year attribute is null
   */
  @isTest
  static void missingYearInResponse() {
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getStatements('1111', '1111', '10');
    String validResponse = response.body;

    validResponse = validResponse.replaceAll('\n', '');
    String matchString = '2021';
    String manipulatedResponse = validResponse.replaceFirst(
      matchString,
      'null'
    );

    Exception resultException;

    Test.startTest();

    try {
      StatementModel modelInstance = StatementModel.parse(manipulatedResponse);
    } catch (Exception e) {
      resultException = e;
    }

    Test.stopTest();

    System.assert(
      resultException.getMessage()
        .contains('Statements Information is invalid.'),
      'Should return Statements Information is invalid. exception message.'
    );
  }

  /**
   * @description fetch statement statement id for a account number
   */
  @isTest
  public static void statementsAuraTest() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      StatementModel statement = StatementAPIRepository.getStatementsAura(
        '1234',
        '1111',
        '10'
      );
      Test.stopTest();
      System.assertEquals(
        4,
        statement.statements.size(),
        'The statements size should be as expected.'
      );
    }
  }
  /**
   * @description fetch statement url for a valid statement id
   */
  @isTest
  static void statementUrlTest() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Map<String, String> additionaldetails = new Map<String, String>();
      additionaldetails.put('statementId', 'test1234');
      additionaldetails.put('url', 'https://test.invalid.com');
      additionaldetails.put('sfUserId', '005134242');
      additionaldetails.put('statementId', '12345');
      additionaldetails.put('url', '2453535');
      Test.startTest();
      StatementModel statement = StatementAPIRepository.getStatementUrlAura(
        '1234',
        '1111',
        additionaldetails
      );
      Test.stopTest();
      System.assert(statement != null, 'Statement should not be null.');
    }
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void statementInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      StatementModel statementModel;
      HttpCalloutResponse res = getStatementInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      StatementAPIRepository statementAPI = new StatementAPIRepository();
      try {
        statementModel = statementAPI.getStatements('1111', '2222', '10');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Statement retrieve failed',
        resultException.getMessage(),
        'Error message should be as expected.'
      );
    }
  }
}
