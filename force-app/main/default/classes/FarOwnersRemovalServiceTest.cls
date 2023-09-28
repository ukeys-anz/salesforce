/**
 *
 * @author Tan Phan
 * @since 09/2023
 * @description Contains unit-tests for {@link FarOwnersRemovalService}
 */
@IsTest
private class FarOwnersRemovalServiceTest {
  static Faker faker = new Faker('AU');

  @TestSetup
  static void makeData() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      CCRMTestDataFactory.createPersonAccount();
      CCRMTestDataFactory.createBusinessAccount();
      CCRMTestDataFactory.createSystemCustomer();
    }
  }

  @IsTest
  static void testValidInput() {
    Account customer = [
      SELECT Id, External_Id__c
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();

    RestContext.request.requestBody = Blob.valueOf(
      JSON.serialize(
        new Map<String, String>{ 'victimId' => customer.External_Id__c }
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
    Account customer = [SELECT Id FROM Account WHERE Name = 'Test Pty Ltd'];

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
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
      FarOwnersRemovalService.removeAdditionalOwnerFarsFromAccounts(
        new List<Account>{ customer }
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

  @IsTest
  static void testRemoveContactDataFromAccounts() {
    Account customer = [SELECT Id FROM Account WHERE Name = 'Test Pty Ltd'];

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      insert new List<SObject>{
        new ContactPointAddress(
          ParentId = customer.Id,
          Name = 'Primary Mailing'
        ),
        new ContactPointEmail(
          ParentId = customer.Id,
          EmailAddress = faker.internet.companyEmail()
        ),
        new ContactPointPhone(
          ParentId = customer.Id,
          TelephoneNumber = faker.person.phone()
        )
      };
    }

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      FarOwnersRemovalService.removeContactDataFromAccounts(
        new List<Account>{ customer }
      );
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [SELECT COUNT() FROM ContactPointAddress WHERE ParentId = :customer.Id],
      'ContactPointAddress related to the provided customer should be deleted'
    );
    Assert.areEqual(
      0,
      [SELECT COUNT() FROM ContactPointEmail WHERE ParentId = :customer.Id],
      'ContactPointAddress related to the provided customer should be deleted'
    );
    Assert.areEqual(
      0,
      [SELECT COUNT() FROM ContactPointPhone WHERE ParentId = :customer.Id],
      'ContactPointAddress related to the provided customer should be deleted'
    );
  }

  @IsTest
  static void testRemoveP2PRelationsFromAccounts() {
    Contact businessContact = [
      SELECT Id
      FROM Contact
      WHERE Account.Name = 'Test Pty Ltd'
    ];
    Account personCustomer = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE IsPersonAccount = TRUE
    ];

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      String ocvReciprocalRole = faker.randomString(10);
      FinServ__ReciprocalRole__c nonReciprocalRole = CCRMTestDataFactory.createNonReciprocalRole(
        ocvReciprocalRole
      );
      insert new List<SObject>{
        new FinServ__ContactContactRelation__c(
          FinServ__Contact__c = personCustomer.PersonContactId,
          FinServ__RelatedContact__c = businessContact.Id,
          OCV_Role__c = ocvReciprocalRole
        )
      };
    }

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      FarOwnersRemovalService.removeP2PRelationsFromAccounts(
        new List<Account>{ personCustomer }
      );
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [
        SELECT COUNT()
        FROM FinServ__ContactContactRelation__c
        WHERE FinServ__Contact__c = :personCustomer.PersonContactId
      ],
      'ContactContactRelation related to the provided customer should be deleted'
    );
  }
}
