/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for StravinskyAPIRepository
 */
@isTest
public with sharing class StravinskyAPIRepositoryTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );

    insert acc;
  }
  @isTest
  static void testPackageClosureSuccess() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = faker.randomString(10)
    );
    String checkingAccount = faker.randomString(15);
    String savingsAccount = faker.randomString(15);

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();

    PackageClosureModel response = stravinskyApi.packageClosure(
      newCase,
      checkingAccount,
      savingsAccount
    );
    PackageClosureModel.Status status = response.status;

    Test.stopTest();
    System.assertEquals(200, status.code);
    System.assertEquals(
      'Package closure successfully completed',
      status.description
    );
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void closePackageInvalidResponse() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    );
    String checkingAccount = faker.randomString(15);
    String savingsAccount = faker.randomString(15);

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);
    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      PackageClosureModel response = stravinskyApi.packageClosure(
        newCase,
        checkingAccount,
        savingsAccount
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals('exception occured', resultException.getMessage());
  }

  /**
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('exception occured');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
