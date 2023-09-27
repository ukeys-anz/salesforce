/**
 *
 * @author Tan Phan
 * @since 09/2023
 * @description Contains unit-tests for {@link FarOwnersRemovalService}
 */
@IsTest
private class FarOwnersRemovalServiceTest {
  static Faker faker = new Faker('AU');

  @IsTest
  static void testValidInput() {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();

    RestContext.request.requestBody = Blob.valueOf(
      JSON.serialize(
        new Map<String, String>{ 'victimId' => faker.randomString(10) }
      )
    );

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      FarOwnersRemovalService.doPost();
    }
    Test.stopTest();

    Assert.areEqual(
      200,
      RestContext.response.statusCode,
      'Request should success with status code 200'
    );
  }

  @IsTest
  static void testUnexpectedError() {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();

    Test.startTest();
    FarOwnersRemovalService.doPost();
    Test.stopTest();

    Assert.areEqual(
      500,
      RestContext.response.statusCode,
      'Request should fail with status code 500'
    );
  }

  @IsTest
  static void testInvalidInput() {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();

    RestContext.request.requestBody = Blob.valueOf('{}');

    Test.startTest();
    FarOwnersRemovalService.doPost();
    Test.stopTest();

    Assert.areEqual(
      400,
      RestContext.response.statusCode,
      'Request should fail with status code 400'
    );
  }

  @IsTest
  static void testFarAdditionOwnersRemoval() {
    FinServ__FinancialAccountRole__c newFar;
    Account customer;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      customer = CCRMTestDataFactory.createBusinessAccount();
      CCRMTestDataFactory.createSystemCustomer();

      //GIVEN a Financial Account initially created without Primary Owner
      FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c();
      insert fa;

      //WHEN a new FAR with role Primary Owner is created for the above FA
      newFar = new FinServ__FinancialAccountRole__c(
        RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
        FinServ__FinancialAccount__c = fa.Id,
        FinServ__RelatedAccount__c = customer.Id,
        FinServ__Role__c = 'Additional Owner',
        External_Id__c = faker.randomString(10)
      );
      insert newFar;
    }

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      FarOwnersRemovalService.removeAdditionOwnerFarsFromAccounts(
        new List<String>{ customer.External_Id__c }
      );
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [
        SELECT COUNT()
        FROM FinServ__FinancialAccountRole__c
        WHERE Id = :newFar.Id
      ],
      'Additional Owner FAR related to the provided customer should be deleted'
    );
  }
}
