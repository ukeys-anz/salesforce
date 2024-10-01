/**
 * @author Tan Phan
 * @since 11/2022
 * @description Test class for {@link CCRMContactActions}
 */
@IsTest
private class CCRMContactActionsTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider contactRepoMock;
  static void registerMocks() {
    contactRepoMock = Lib_MockProvider.forType(
      CommercialContactRepository.class
    );
  }

  @TestSetup
  static void makeData() {
    Account prospectAccount;
    Account activeAccount;
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(CCRMTestDataFactory.getOcvIntegrationUser()) {
      prospectAccount = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );

      activeAccount = CCRMTestDataFactory.createBusinessAccountWithOwner(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );
    }

    CCRMTestDataFactory.createAccountShare(prospectAccount.Id, ccrmBaseUser.Id);
    CCRMTestDataFactory.createAccountShare(activeAccount.Id, ccrmBaseUser.Id);
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
      contact.Name__c = contact.FirstName + faker.person.firstName();
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
    List<Contact> contactUpdateList;
    List<Contact> contactInsertList;

    System.runAs(CCRMTestDataFactory.getOcvIntegrationUser()) {
      //GIVEN contacts with value in fax, mobile and/or phone
      contactUpdateList = CCRMTestDataFactory.createContacts(
        Integer.valueOf(Label.Test_Bulk_Size),
        true
      );

      //WHEN fax, mobile and phone of 1 of the records are set to blank, and the rest still keep their fax detail
      for (Contact contact : contactUpdateList) {
        contact.Phone = contact.MobilePhone = null;
      }
      contactUpdateList[0].Fax = null;

      Test.startTest();
      contactInsertList = CCRMTestDataFactory.createContacts(
        Integer.valueOf(Label.Test_Bulk_Size),
        false
      );
      update contactUpdateList;
      Test.stopTest();
    }

    //THEN the contact without any of the details is deleted
    System.assertEquals(
      0,
      [
        SELECT COUNT()
        FROM Contact
        WHERE Id = :contactUpdateList[0].Id OR Id IN :contactInsertList
      ],
      'Contact should be deleted when fax, mobile and phone are blank'
    );
    //AND other contacts shouldn't be deleted
    System.assertEquals(
      contactUpdateList.size() - 1,
      [SELECT COUNT() FROM Contact WHERE Id IN :contactUpdateList],
      'Contacts that still have fax detail should not be deleted'
    );
  }

  @IsTest
  static void testCheckMaxContactsPerActiveOrganisation() {
    //GIVEN a activeAccount with 10 contacts
    Account activeAccount = [
      SELECT Id
      FROM Account
      WHERE
        RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
        AND FinServ__Status__c = :CCRMConstants.ACTIVE_STATUS
        AND Source_System_Name__c = :Label.CCRM_Source_System_Name
        AND ANZx_Customer__c = FALSE
      LIMIT 1
    ];
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 9; i++) {
      contacts.add(
        new Contact(
          LastName = faker.person.lastName(),
          AccountId = activeAccount.Id,
          Phone = faker.person.phone(true, false)
        )
      );
    }
    insert contacts;

    //WHEN banker adds another contact to the same activeAccount
    Contact newContact = new Contact(AccountId = activeAccount.Id);
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
      'Banker should not be able to add more than 10 contacts to a active Account'
    );
  }

  @isTest
  static void testPopulateLastNameOnInsert() {
    registerMocks();
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType()),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        Name__c = 'Sample Contact',
        RecordTypeId = RTContact.organisation
      )
    };

    contactRepoMock.mock(
      'getUserProfileId',
      QueryProfile.anzCCRMStandardUser.Id
    );
    Test.startTest();
    CCRMContactActions.populateLastName(conList, null);
    Test.stopTest();

    Assert.isNotNull(conList[0].LastName, 'Last Name not populated correctly');
  }

  @isTest
  static void testPopulateLastNameOnUpdate() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        Name__c = 'Sample Contact New',
        RecordTypeId = RTContact.organisation
      )
    };
    Map<Id, Contact> conMap = new Map<Id, Contact>{
      conId => new Contact(
        Id = conId,
        AccountId = accId,
        Name__c = 'Sample Contact Old',
        RecordTypeId = RTContact.organisation
      )
    };
    contactRepoMock.mock(
      'getUserProfileId',
      QueryProfile.anzCCRMStandardUser.Id
    );
    Test.startTest();
    CCRMContactActions.populateLastName(conList, conMap);
    Test.stopTest();
    Assert.areEqual(
      conList[0].Name__c,
      conList[0].LastName,
      'Last Name not updated correctly'
    );
  }

  @isTest
  static void testPopulateNameOnInsert() {
    registerMocks();
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType()),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        LastName = 'Sample Contact',
        RecordTypeId = RTContact.organisation
      )
    };
    contactRepoMock.mock('getUserName', 'ocvintegration.user@anzx.com.test24');
    Test.startTest();
    CCRMContactActions.populateName(conList, null);
    Test.stopTest();
    Assert.areEqual(
      conList[0].LastName,
      conList[0].Name__c,
      'Contact name not get populated correctly'
    );
  }

  @isTest
  static void testPopulateNameOnUpdate() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact New',
        RecordTypeId = RTContact.organisation
      )
    };
    Map<Id, Contact> conMap = new Map<Id, Contact>{
      conId => new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact Old',
        RecordTypeId = RTContact.organisation
      )
    };

    contactRepoMock.mock('getUserName', 'ocvintegration.user@anzx.com.test24');

    Test.startTest();
    CCRMContactActions.populateName(conList, conMap);
    Test.stopTest();

    Assert.areEqual(
      conList[0].LastName,
      conList[0].Name__c,
      'Contact name not get updated correctly'
    );
  }
}
