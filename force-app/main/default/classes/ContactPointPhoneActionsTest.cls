/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description ContactPointPhoneActionsTest is the test class for ContactPointPhoneActions Class.
 */
@isTest
public with sharing class ContactPointPhoneActionsTest {
  static Lib_MockProvider phoneRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    phoneRepoMock = Lib_MockProvider.forType(
      ContactPointObjectActionsRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testCopyParentIdToCustomerName() {
    ContactPointPhone phoneRecord = new ContactPointPhone(
      ParentId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      UsageType = 'Security Mobile'
    );
    Test.startTest();
    ContactPointPhoneActions.copyParentIdToCustomerName(
      new List<ContactPointPhone>{ phoneRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      phoneRecord.ParentId,
      phoneRecord.Customer_Name__c,
      'Check Customer name is populated'
    );
  }

  @isTest
  static void testCheckExistingPhoneOnIndividualRecords() {
    registerMocks();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<ContactPointPhone> phoneRecords = new List<ContactPointPhone>{
      getPhoneRecord(accountId, 'Security Mobile'),
      getPhoneRecord(accountId, 'Security Mobile')
    };
    phoneRepoMock.mock('getContactPointPhones', phoneRecords);
    Test.startTest();
    ContactPointPhoneActions.checkExistingPhoneOnIndividualRecords(
      phoneRecords
    );
    Test.stopTest();
    Assert.isTrue(
      phoneRecords[0].getErrors()[0]
        .getMessage()
        .contains(Label.ExistingContactPointPhoneError),
      'Check Usage type is existing error'
    );
  }

  @isTest
  static void testValidatePhonesMobileError() {
    registerMocks();
    phoneRepoMock.mock('isCustomValidationsSkipped', false);
    ContactPointPhone testContactPointPhone = new ContactPointPhone(
      TelephoneNumber = '+6112345678',
      ParentId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      UsageType = 'Mobile Telephone'
    );
    Test.startTest();
    ContactPointPhoneActions.validatePhones(
      new List<ContactPointPhone>{ testContactPointPhone }
    );
    Test.stopTest();
    Assert.areEqual(
      'Please enter Mobile Number in +61412345678/+61512345678 format.',
      testContactPointPhone.getErrors()[0].getMessage(),
      'Invalid Mobile error'
    );
  }

  @isTest
  static void testValidatePhonesPhoneError() {
    registerMocks();
    phoneRepoMock.mock('isCustomValidationsSkipped', false);
    ContactPointPhone testContactPointPhone = new ContactPointPhone(
      TelephoneNumber = '+6112345678',
      ParentId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      UsageType = 'Home Telephone'
    );
    Test.startTest();
    ContactPointPhoneActions.validatePhones(
      new List<ContactPointPhone>{ testContactPointPhone }
    );
    Test.stopTest();
    Assert.areEqual(
      'Please enter Phone Number in +61212345678 format.',
      testContactPointPhone.getErrors()[0].getMessage(),
      'Invalid Phone error'
    );
  }

  @isTest
  static void testGetExistingOrProspectCPP() {
    registerMocks();
    Id prospectAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id existingAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account prospectAccount = (Account) TestUtil.setFields(
      new Account(Name = 'ABC', Id = prospectAccountId),
      new Map<String, Object>{ 'Is_Prospect__c' => true }
    );
    Account existingAccount = (Account) TestUtil.setFields(
      new Account(
        Name = 'ABC',
        Id = existingAccountId,
        FinServ__Status__c = 'Active',
        Source_System_Name__c = Label.CCRM_Source_System_Name,
        ANZx_Customer__c = false,
        RecordTypeId = RTAccount.personAccount
      ),
      new Map<String, Object>{ 'isPersonAccount' => true }
    );
    phoneRepoMock.mock(
      'fetchAccounts',
      new List<Account>{ prospectAccount, existingAccount }
    );
    ContactPointPhone prospectCPP = new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      Customer_Name__c = prospectAccountId,
      Customer_Name__r = prospectAccount
    );
    ContactPointPhone existingCPP = new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      Customer_Name__c = existingAccountId,
      Customer_Name__r = existingAccount
    );
    Test.startTest();
    ContactPointPhoneActions.ContactPointPhoneWrapper cppWrapper = ContactPointPhoneActions.getExistingOrProspectCPP(
      new List<ContactPointPhone>{ prospectCPP, existingCPP }
    );
    Test.stopTest();
    Assert.areEqual(
      prospectCPP.Id,
      cppWrapper.prospectCPP[0].Id,
      'Check prospect account added in prospectCPP list'
    );
    Assert.areEqual(
      existingCPP.Id,
      cppWrapper.existingCPP[0].Id,
      'Check existing account added in existingCPP list'
    );
  }

  @isTest
  static void testValidateUsageType() {
    registerMocks();
    phoneRepoMock.mock('isCurrentLoggedInMLUser', true);
    phoneRepoMock.mock('isCustomValidationsSkipped', false);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<ContactPointPhone> phoneList = new List<ContactPointPhone>{
      getPhoneRecord(accountId, 'Mobile Telephone'),
      getPhoneRecord(accountId, 'Security Mobile')
    };

    Test.startTest();
    ContactPointPhoneActions.validateUsageType(phoneList);
    Test.stopTest();

    Assert.areEqual(
      0,
      phoneList[0].getErrors().size(),
      'validateUsageType is adding unexpted error'
    );
    Assert.areEqual(
      'You are not authorized to insert the ANZx mobile phone',
      phoneList[1].getErrors()[0].getMessage(),
      'validateUsageType is not restricting anzx phone'
    );
  }

  @isTest
  static void testPreventEdit() {
    registerMocks();
    phoneRepoMock.mock('isCurrentLoggedInMLUser', true);
    phoneRepoMock.mock('isCustomValidationsSkipped', false);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<ContactPointPhone> phoneRecords = new List<ContactPointPhone>{
      getPhoneRecord(accountId, 'Security Mobile'),
      getPhoneRecord(accountId, 'Home Telephone'),
      getPhoneRecord(accountId, 'Mobile Telephone')
    };

    Map<Id, ContactPointPhone> phoneRecordsMap = new Map<Id, ContactPointPhone>();
    phoneRecordsMap.put(
      phoneRecords[0].Id,
      new ContactPointPhone(
        Id = phoneRecords[0].Id,
        Usagetype = 'Security Mobile'
      )
    );
    phoneRecordsMap.put(
      phoneRecords[1].Id,
      new ContactPointPhone(
        Id = phoneRecords[1].Id,
        Usagetype = 'Business Phone'
      )
    );
    phoneRecordsMap.put(
      phoneRecords[2].Id,
      new ContactPointPhone(
        Id = phoneRecords[2].Id,
        Usagetype = 'Mobile Telephone'
      )
    );

    Test.startTest();
    ContactPointPhoneActions.preventEdit(phoneRecords, phoneRecordsMap);
    Test.stopTest();

    Assert.areEqual(
      'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.',
      phoneRecords[0].getErrors()[0].getMessage(),
      'preventEdit method is allowing to edit Security Phone'
    );
    Assert.areEqual(
      'You do not have the necessary privileges to update the usage type',
      phoneRecords[1].getErrors()[0].getMessage(),
      'preventEdit method is allowing to edit usage type'
    );
    Assert.areEqual(
      0,
      phoneRecords[2].getErrors().size(),
      'preventEdit method is throwing unexpeted error'
    );
  }

  @isTest
  static void testDeleteExpiredRecords() {
    registerMocks();
    List<ContactPointPhone> phoneRecords = new List<ContactPointPhone>{
      new ContactPointPhone(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
        ActiveToDate = System.today().addDays(-2)
      )
    };
    Map<Id, ContactPointPhone> oldMap = new Map<Id, ContactPointPhone>{
      phoneRecords[0].Id => new ContactPointPhone(
        Id = phoneRecords[0].Id,
        ActiveToDate = null
      )
    };
    Test.startTest();
    ContactPointPhoneActions.deleteExpiredRecords(phoneRecords, oldMap);
    Test.stopTest();
    List<ContactPointPhone> deletedRecords = (List<ContactPointPhone>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      deletedRecords.size(),
      'The inactive phone record is not deleted'
    );
  }

  static ContactPointPhone getPhoneRecord(Id parentId, String usageType) {
    return new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      UsageType = usageType,
      Customer_Name__c = parentId,
      ParentId = parentId
    );
  }
}
