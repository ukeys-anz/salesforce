/**
 * @author Kopal Goswami
 * @since 12/2024
 * @description AccountClosureCaseActionsHelperTest is the test class to cover tests for {@link AccountClosureCaseActionsHelper.cls}
 */

@isTest
public with sharing class AccountClosureCaseActionsHelperTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  @isTest
  private static void testSetFieldsForNewParentCase() {
    List<Case> childRecords = mockQueryChildCaseRecords(null);

    Test.startTest();
    List<Case> newParentCaseRecords = AccountClosureCaseActionsHelper.setFieldsForNewParentCase(
      childRecords,
      new Map<Id, Case>()
    );
    Test.stopTest();

    Assert.isTrue(
      newParentCaseRecords.size() > 0,
      'New parent records are initialized'
    );
  }

  @isTest
  private static void testAssignClosureCasesToParentCase() {
    List<Case> parentRecords = mockParentCaseRecord('Open', null);
    Map<Id, Case> accountIdToExistingParentCaseMap = new Map<Id, Case>();
    accountIdToExistingParentCaseMap.put(
      parentRecords[0].AccountId,
      parentRecords[0]
    );

    Test.startTest();
    List<Case> assignedCases = AccountClosureCaseActionsHelper.assignClosureCasesToParentCase(
      mockQueryChildCaseRecords(null),
      accountIdToExistingParentCaseMap,
      null
    );
    Test.stopTest();

    Assert.isTrue(
      assignedCases[0].ParentId == FAKER_PARENT_CASE_ID,
      'Parent case is assigned to the child case record'
    );
  }

  @isTest
  private static void testSetChildCaseField() {
    Map<Id, Case> parentIdAndCaseDetailsMap = new Map<Id, Case>(
      mockParentCaseRecord('Escalated', null)
    );
    Set<Schema.SObjectField> fieldsToMonitor = new Set<Schema.SObjectField>{
      Case.OwnerId,
      Case.Status,
      Case.Circumstance__c
    };
    Test.startTest();
    List<Case> updatedCases = AccountClosureCaseActionsHelper.setChildCaseField(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID),
      new Map<Id, Case>(mockParentCaseRecord('Open', null)),
      parentIdAndCaseDetailsMap,
      fieldsToMonitor
    );
    Test.stopTest();

    Assert.isTrue(
      updatedCases[0].Status == 'Escalated',
      'Parent case is assigned to the child case record'
    );
  }

  @isTest
  private static void testAssignOwnerAsQueue() {
    List<Case> childCaseRecords = mockQueryChildCaseRecords(
      FAKER_PARENT_CASE_ID
    );

    Test.startTest();
    AccountClosureCaseActionsHelper.assignOwnerAsQueue(childCaseRecords);
    Test.stopTest();

    Assert.isTrue(
      childCaseRecords[0].OwnerId ==
      AccountClosureCaseActionsHelper.accountClosureQueue.Id,
      'OwnerId of the case is updated to accountClosureQueue'
    );
  }

  @isTest
  private static void testAssignCaseSubject() {
    List<Case> childCaseRecords = mockQueryChildCaseRecords(
      FAKER_PARENT_CASE_ID
    );
    Map<Id, Account> accountIdToAccountInfoMap = new Map<Id, Account>(
      mockQueryAccountName()
    );

    Test.startTest();
    AccountClosureCaseActionsHelper.assignCaseSubject(
      childCaseRecords,
      accountIdToAccountInfoMap
    );
    Test.stopTest();

    Assert.isTrue(
      childCaseRecords[0].Subject == 'Account Closure - Sample Name',
      'Subject of the record is updated'
    );
  }

  private static List<Case> mockQueryChildCaseRecords(Id parentId) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'Open';
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.accountClosure;

    childcases.add(caseRecord);
    return childcases;
  }

  private static List<Case> mockParentCaseRecord(
    String statusValue,
    String circumstanceValue
  ) {
    List<Case> parentCases = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_PARENT_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = statusValue;
    caseRecord.RecordTypeId = RTCase.caseGroup;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.Type = GetHelpConstants.ACCOUNT_CLOSURE;
    caseRecord.Circumstance__c = circumstanceValue;

    parentCases.add(caseRecord);
    return parentCases;
  }

  private static List<Account> mockQueryAccountName() {
    List<Account> accountRecords = new List<Account>();
    Account acc = new Account();
    acc.Id = FAKER_ACCOUNT_ID;
    acc.Name = 'Sample Name';
    accountRecords.add(acc);
    return accountRecords;
  }
}
