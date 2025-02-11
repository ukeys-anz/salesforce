/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActionsTest is the test class for CommercialContactActions.
 */

@isTest
public with sharing class CommercialContactActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider contactRepoMock;
  static Lib_MockProvider accountRepoMock;
  static void registerMocks() {
    contactRepoMock = Lib_MockProvider.forType(
      CommercialContactRepository.class
    );
    accountRepoMock = Lib_MockProvider.forType(
      CommercialAccountRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testPopulateLastNameOnInsert() {
    registerMocks();

    //GIVEN Contact record List
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

    //WHEN calling populateLastName method on Insert
    Test.startTest();
    CommercialContactActions.populateLastName(conList, null);
    Test.stopTest();

    //THEN It should update LastName on Contact
    Assert.isNotNull(conList[0].LastName, 'Last Name not populated correctly');
  }

  @isTest
  static void testPopulateLastNameOnUpdate() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Contact record List and old Contact List
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

    //WHEN calling populateLastName method on Update
    Test.startTest();
    CommercialContactActions.populateLastName(conList, conMap);
    Test.stopTest();

    //THEN It should update LastName on Contact
    Assert.areEqual(
      conList[0].Name__c,
      conList[0].LastName,
      'Last Name not updated correctly'
    );
  }

  @isTest
  static void testPopulateNameOnInsert() {
    registerMocks();

    //GIVEN Contact record List
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType()),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        LastName = 'Sample Contact',
        RecordTypeId = RTContact.organisation
      )
    };

    contactRepoMock.mock('getUserProfileId', QueryProfile.integrationUser.Id);

    //WHEN calling populateName method on Insert
    Test.startTest();
    CommercialContactActions.populateName(conList, null);
    Test.stopTest();

    //THEN It should update Name__c on Contact
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

    //GIVEN Contact record List and old Contact List
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

    contactRepoMock.mock('getUserProfileId', QueryProfile.integrationUser.Id);

    //WHEN calling populateName method on Update
    Test.startTest();
    CommercialContactActions.populateName(conList, conMap);
    Test.stopTest();

    //THEN It should update Name__c on Contact
    Assert.areEqual(
      conList[0].LastName,
      conList[0].Name__c,
      'Contact name not get updated correctly'
    );
  }

  @isTest
  static void testValidateExistingOrProspectContacts() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Contact record List
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact New',
        RecordTypeId = RTContact.organisation,
        Phone = '+61412345678',
        Email = 'sample@gmail.com'
      )
    };
    contactRepoMock.mock('isSkipValidation', false);

    //WHEN calling validateExistingOrProspectContacts method
    Test.startTest();
    CommercialContactActions.validateExistingOrProspectContacts(conList);
    Test.stopTest();

    //THEN It shouldn't throw any error
    Assert.isFalse(
      conList[0].hasErrors(),
      'Error while validating the contact'
    );
  }

  @isTest
  static void testValidateExistingOrProspectContactsNegative() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Contact record List
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact New',
        RecordTypeId = RTContact.organisation,
        Phone = '+61412345678',
        Email = 'sample'
      )
    };
    contactRepoMock.mock('isSkipValidation', false);

    //WHEN calling validateExistingOrProspectContacts method
    Test.startTest();
    CommercialContactActions.validateExistingOrProspectContacts(conList);
    Test.stopTest();

    //THEN It should throw an error
    Assert.isTrue(
      conList[0].hasErrors(),
      'Failed to check the validation on Contacts'
    );
  }

  @isTest
  static void testCheckMaxContactsPerOrganisation() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Contact record List and Account aggregate result
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact New',
        RecordTypeId = RTContact.organisation,
        Phone = '+61412345678'
      )
    };
    Account accRecord = (Account) TestUtil.setFields(
      new Account(
        Id = accId,
        RecordTypeId = RTAccount.businessAccount,
        Name = 'Sample Account'
      ),
      new Map<String, List<Contact>>{
        'Contacts' => new List<Contact>{
          new Contact(Id = conId, RecordTypeId = RTContact.organisation)
        }
      }
    );
    Map<Id, Account> accountAndRelatedContactMap = new Map<Id, Account>{
      accId => accRecord
    };
    contactRepoMock.mock(
      'getAccountAndRelatedContactMap',
      accountAndRelatedContactMap
    );

    //WHEN calling validateExistingOrProspectContacts method
    Test.startTest();
    CommercialContactActions.checkMaxContactsPerOrganisation(conList);
    Test.stopTest();

    //THEN It shouldn't throw an error
    Assert.isFalse(
      conList[0].hasErrors(),
      'Error while linking contacts to accounts'
    );
  }

  @isTest
  static void testDeleteCommercialContactsWithoutContactDetails() {
    registerMocks();
    Id conId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Contact record List
    List<Contact> conList = new List<Contact>{
      new Contact(
        Id = conId,
        AccountId = accId,
        LastName = 'Sample Contact New',
        RecordTypeId = RTContact.organisation
      )
    };

    List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>{
      TestUtil.getMockDeleteResult(
        '{"id":"0039p00000O5p46AAB","success":true,"errors":[]}'
      )
    };
    contactRepoMock.mock('getContacts', conList);
    dmlRepoMock.mock('doDelete', deleteResults);

    //WHEN calling deleteCommercialContactsWithoutContactDetails method
    Test.startTest();
    CommercialContactActions.deleteCommercialContactsWithoutContactDetails(
      conList
    );
    Test.stopTest();

    List<Contact> delConList = (List<Contact>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    //THEN it should delete contact record
    Assert.areEqual(1, delConList.size(), 'Contact not get deleted');
  }
}
