/**
 * @author Tan Phan
 * @since 11/2022
 * @description Test class for {@link CCRMContactActions}
 */
@IsTest
private class CCRMContactActionsTest {
  static Faker faker = new Faker('AU');

  @TestSetup
  static void makeData() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Account acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );
    }
  }

  @IsTest
  static void testTrackProspectChanges() {
    //GIVEN Contact record linked to a prospect customer
    Contact contact = [
      SELECT Id, FirstName
      FROM Contact
      WHERE Account.Is_Prospect__c = TRUE
      LIMIT 1
    ];

    //WHEN That contact is updated
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      contact.FirstName = contact.FirstName + faker.person.firstName();
      contact.Occurrence_Number__c = faker.randomInteger(2);
      update contact;
    }
    Test.stopTest();

    //THEN a customer profile update record is created
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Customer_Profile_Updates__c],
      'Customer_Profile_Updates__c record should be created when contact is updated'
    );
  }

  @IsTest
  static void testCheckMaxContactsPerOrganisation() {
    //GIVEN a prospect with 10 contacts
    Account prospect = [
      SELECT Id
      FROM Account
      WHERE Is_Prospect__c = TRUE
      LIMIT 1
    ];
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 9; i++) {
      contacts.add(
        new Contact(
          LastName = faker.person.lastName(),
          AccountId = prospect.Id,
          Phone = faker.person.phone(true, false)
        )
      );
    }
    insert contacts;

    //WHEN banker adds another contact to the same prospect
    Contact newContact = new Contact(AccountId = prospect.Id);
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMContactActions.checkMaxContactsPerOrganisation(
        new List<Contact>{ newContact }
      );
    }
    Test.stopTest();

    //THEN the contact won't be added
    System.assert(
      newContact.hasErrors(),
      'Banker should not be able to add more than 10 contacts to a prospect'
    );
  }
}
