/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description CCRMContactPointActionsTest is class to handle all the CCRM Contact Point Object Actions
 * @runTests CCRMContactPointActionsTest
 */
@isTest
private class CCRMContactPointActionsTest {
  @isTest
  static void testUpdateContactPointAddress() {
    Faker faker = new Faker('AU');
    //GIVEN
    Account acc = TestDataFactory.createAccount(faker.person.firstName(), true);
    ContactPointAddress testContactPointAddress = new ContactPointAddress();
    testContactPointAddress.Name = acc.Name;
    testContactPointAddress.ParentId = acc.Id;
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      insert testContactPointAddress;
    }

    //WHEN
    testContactPointAddress.ActiveToDate = System.today() - 1;
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
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
    //GIVEN
    Faker faker = new Faker('AU');
    Account acc = TestDataFactory.createAccount(faker.person.firstName(), true);
    ContactPointPhone testContactPointPhone = new ContactPointPhone();
    testContactPointPhone.TelephoneNumber = '123-456-7890';
    testContactPointPhone.ParentId = acc.Id;
    insert testContactPointPhone;

    //WHEN
    testContactPointPhone.ActiveToDate = System.today() - 1;
    update testContactPointPhone;

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
    Faker faker = new Faker('AU');
    Account acc = TestDataFactory.createAccount(faker.person.firstName(), true);
    ContactPointEmail testContactPointEmail = new ContactPointEmail();
    testContactPointEmail.EmailAddress = 'mhtest@anz.com';
    testContactPointEmail.ParentId = acc.Id;
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      insert testContactPointEmail;
    }

    //WHEN
    testContactPointEmail.ActiveToDate = System.today() - 1;
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
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
