/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActionsTest is the test class for CommercialContactActions.
 */

@isTest
public with sharing class CommercialContactActionsTest {
  static Lib_MockProvider contactRepoMock;
  static void registerMocks() {
    contactRepoMock = Lib_MockProvider.forType(
      CommercialContactRepository.class
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
    CommercialContactActions.populateLastName(conList, null);
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
    CommercialContactActions.populateLastName(conList, conMap);
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

    contactRepoMock.mock('getUserProfileId', QueryProfile.integrationUser.Id);

    Test.startTest();
    CommercialContactActions.populateName(conList, null);
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

    contactRepoMock.mock('getUserProfileId', QueryProfile.integrationUser.Id);

    Test.startTest();
    CommercialContactActions.populateName(conList, conMap);
    Test.stopTest();

    Assert.areEqual(
      conList[0].LastName,
      conList[0].Name__c,
      'Contact name not get updated correctly'
    );
  }
}
