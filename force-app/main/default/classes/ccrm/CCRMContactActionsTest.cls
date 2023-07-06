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

  @IsTest
  static void testContactEndDate() {
    //GIVEN
    List<Contact> contactList = CCRMTestDataFactory.createContacts(5, true);

    //WHEN
    for (Contact contact : contactList) {
      contact.MobilePhone = '';
      contact.Phone = '';
      contact.Fax = '';
    }
    update contactList;

    //THEN
    List<Contact> contacts = [
      SELECT Active_To__c, RecordTypeId
      FROM Contact
      WHERE Email = :'testenddate@anz.com'
    ];
    for (Contact record : contacts) {
      System.assertEquals(
        record.Active_To__c,
        System.today(),
        'Contact end date updated to today date'
      );
      System.assertEquals(
        record.RecordTypeId,
        CCRMConstants.CONTACT_HIDDEN_RT_ID,
        'Contact record type changed to Hidden'
      );
    }
  }

  @IsTest
  static void testContactEndDateShouldNotPopulate() {
    //GIVEN: Contacts created without Mobile, Fax and Phone
    List<Contact> contactList = CCRMTestDataFactory.createContacts(5, false);

    //WHEN: Update contact Title
    for (Contact contact : contactList) {
      contact.Title = 'Prof';
    }
    update contactList;

    //THEN: Active To date should not populated abd record type do not change
    List<Contact> contacts = [
      SELECT Active_To__c, RecordTypeId
      FROM Contact
      WHERE Email = :'testenddate@anz.com'
    ];
    for (Contact record : contacts) {
      System.assertEquals(
        record.Active_To__c,
        null,
        'Contact end date NOT updated to today date'
      );
      System.assertEquals(
        record.RecordTypeId,
        CCRMConstants.CONTACT_BUSINESS_RT_ID,
        'Contact record type remain unchanged to Business'
      );
    }
  }

  @IsTest
  static void testContactEndDateWhenPhoneAndFaxAreNullAndMobileWithValue() {
    //GIVEN: Contacts created without Mobile, Fax and Phone
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = faker.randomString(10);
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    accnt.Phone = faker.person.phone(true, false);
    accnt.Source_System_ID__c = 'BUS1234';
    accnt.Source_System_Name__c = System.Label.CCRM_Source_System_Name;
    accnt.FinServ__Status__c = 'Active';
    insert accnt;

    List<Contact> contactList = new List<Contact>();
    Integer count = 5;
    for (Integer i = 1; i <= count; i++) {
      Contact contact = new Contact();
      contact.FirstName = faker.person.firstName();
      contact.LastName = faker.randomString(10);
      contact.Email = 'testenddate@anz.com';
      contact.MobilePhone = faker.person.phone(true, true);
      contact.AccountId = accnt.Id;
      contactList.add(contact);
    }
    insert contactList;

    //WHEN: Update contact Title
    for (Contact contact : contactList) {
      contact.MobilePhone = '';
    }
    update contactList;

    //THEN: Active To date should not populated abd record type do not change
    List<Contact> contacts = [
      SELECT Active_To__c, RecordTypeId
      FROM Contact
      WHERE Email = :'testenddate@anz.com'
    ];
    for (Contact record : contacts) {
      System.assertEquals(
        record.Active_To__c,
        System.today(),
        'Contact end date updated to today date'
      );
      System.assertEquals(
        record.RecordTypeId,
        CCRMConstants.CONTACT_HIDDEN_RT_ID,
        'Contact record type changed to Hidden'
      );
    }
  }
}
