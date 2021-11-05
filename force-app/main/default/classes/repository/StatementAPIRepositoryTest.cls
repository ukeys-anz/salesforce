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
        null
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
        model = statementapi.getStatements('1111', '1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();

      System.assertEquals(
        'Get statement failed',
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
    response.error = new CalloutException('Get statement failed');
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
          null
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
    HttpCalloutResponse response = s.getStatements('1111', '1111');
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
}
