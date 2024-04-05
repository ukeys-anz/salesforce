/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description CCRMContactPointActionsTest is class to handle all the CCRM Contact Point Object Actions
 * @runTests CCRMContactPointActionsTest
 */
@isTest
private class CCRMContactPointActionsTest {
  @testSetup
  static void setup() {
    User ocvIntegrationUser = CCRMTestDataFactory.createOcvIntegrationUser();
    System.runAs(ocvIntegrationUser) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = TestDataFactory.createAccount(
        faker.person.firstName(),
        true
      );
    }
  }
  @isTest
  static void testUpdateContactPointAddress() {
    //GIVEN
    Account acc = [SELECT id, name FROM Account LIMIT 1];
    User ocvIntegrationUser = [
      SELECT id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
      LIMIT 1
    ];
    ContactPointAddress testContactPointAddress = new ContactPointAddress();
    testContactPointAddress.Name = acc.Name;
    testContactPointAddress.ParentId = acc.Id;
    System.runAs(ocvIntegrationUser) {
      insert testContactPointAddress;
      //WHEN
      testContactPointAddress.ActiveToDate = System.today() - 1;
      update testContactPointAddress;
    }

    //THEN
    ContactPointAddress cpa = [
      SELECT ParentId, Previous_Related_Account__c
      FROM ContactPointAddress
    ];
    System.assertEquals(null, cpa.ParentId, 'Parent Id set to null');

    System.assertEquals(
      acc.Id,
      cpa.Previous_Related_Account__c,
      'Previous account id should match'
    );
  }

  @isTest
  static void testUpdateContactPointPhone() {
    Account acc = [SELECT id, name FROM Account LIMIT 1];
    User ocvIntegrationUser = [
      SELECT id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
      LIMIT 1
    ];
    ContactPointPhone testContactPointPhone = new ContactPointPhone();
    testContactPointPhone.TelephoneNumber = '123-456-7890';
    testContactPointPhone.ParentId = acc.Id;
    System.runAs(ocvIntegrationUser) {
      insert testContactPointPhone;
      //WHEN
      testContactPointPhone.ActiveToDate = System.today() - 1;
      update testContactPointPhone;
    }

    //THEN
    ContactPointPhone cpp = [
      SELECT ParentId, Previous_Related_Account__c
      FROM ContactPointPhone
    ];
    System.assertEquals(null, cpp.ParentId, 'Parent Id set to null');

    System.assertEquals(
      acc.Id,
      cpp.Previous_Related_Account__c,
      'Previous account id should match'
    );
  }

  @isTest
  static void testUpdateContactPointEmail() {
    //GIVEN
    Account acc = [SELECT id, name FROM Account LIMIT 1];
    User ocvIntegrationUser = [
      SELECT id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
      LIMIT 1
    ];
    ContactPointEmail testContactPointEmail = new ContactPointEmail();
    testContactPointEmail.EmailAddress = 'mhtest@anz.com';
    testContactPointEmail.ParentId = acc.Id;
    System.runAs(ocvIntegrationUser) {
      insert testContactPointEmail;
      //WHEN
      testContactPointEmail.ActiveToDate = System.today() - 1;
      update testContactPointEmail;
    }

    //THEN
    ContactPointEmail cpe = [
      SELECT ParentId, Previous_Related_Account__c
      FROM ContactPointEmail
    ];
    System.assertEquals(null, cpe.ParentId, 'Parent Id set to null');

    System.assertEquals(
      acc.Id,
      cpe.Previous_Related_Account__c,
      'Previous account id should match'
    );
  }
}
