/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 08-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class DeceasedCustomerCaseActionsTest {
  @IsTest
  static void testcheckValidityAndUpdateAccount() {
    Lib_MockProvider.forType(DMLRepository.class)
      .mock(
        'doUpdate',
        new List<Database.SaveResult>{
          TestUtil.getMockSaveResult('{"success":true}')
        }
      );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    List<Case> records = new List<Case>{
      new Case(Id = caseId, AccountId = accId, Status = 'Closed')
    };
    Map<Id, Case> oldMap = new Map<Id, Case>{
      caseId => new Case(Id = caseId, AccountId = accId, Status = 'Open')
    };

    Test.startTest();
    DeceasedCustomerCaseActions.checkValidityAndUpdateAccount(records, oldMap);
    Test.stopTest();
    List<Account> accountUpdated = (List<Account>) Lib_MockProvider.forType(
        DMLRepository.class
      )
      .getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      'Completed',
      accountUpdated[0].DeceasedEstateStatus__c,
      'Account is not updated'
    );
  }

  @IsTest
  static void testupdateDeceasedEstateStatusOnAccount() {
    Lib_MockProvider.forType(DMLRepository.class)
      .mock(
        'doUpdate',
        new List<Database.SaveResult>{
          TestUtil.getMockSaveResult('{"success":true}')
        }
      );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    List<Case> records = new List<Case>{
      new Case(Id = caseId, AccountId = accId, Status = 'Closed')
    };

    Test.startTest();
    DeceasedCustomerCaseActions.updateDeceasedEstateStatusOnAccount(
      records,
      'Completed'
    );
    Test.stopTest();
    List<Account> accountUpdated = (List<Account>) Lib_MockProvider.forType(
        DMLRepository.class
      )
      .getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      'Completed',
      accountUpdated[0].DeceasedEstateStatus__c,
      'Account is not updated'
    );
  }

  @IsTest
  static void testUpdateOwner() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    List<Case> records = new List<Case>{
      new Case(
        Id = caseId,
        AccountId = accId,
        Status = 'Closed',
        Type = 'Deceased Estate',
        Sub_Type__c = 'Removal of Electronic Access',
        Auto_Created__c = false
      )
    };
    Test.startTest();
    DeceasedCustomerCaseActions.updateOwner(records);
    Test.stopTest();
    Assert.areEqual(
      QueryQueue.get('ID_Ops_Queue').Id,
      records[0].OwnerId,
      'Owner is not updated'
    );
  }
}
