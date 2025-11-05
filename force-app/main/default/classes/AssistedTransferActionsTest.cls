/**
 * @author Hrushikesh
 * @since 10/2025
 * @description Test class for AssistedTransferActions.
 */
@isTest
public with sharing class AssistedTransferActionsTest {
  private static List<Case> getAssistedTransferCases() {
    List<Case> assistedTransferCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.assistedTransfer;
    record.AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    record.Status = 'In Progress';
    record.sub_status__c = 'Approved';
    record.FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSObjectType()
    );
    assistedTransferCases.add(record);
    return assistedTransferCases;
  }

  private static List<Case> getOldAssistedTransferCases() {
    List<Case> assistedTransferCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.assistedTransfer;
    record.AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    record.Status = 'In Progress';
    record.sub_status__c = 'Approved';
    record.FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSObjectType()
    );
    assistedTransferCases.add(record);
    return assistedTransferCases;
  }

  @isTest
  private static void testSetSubject() {
    Test.startTest();
    List<Case> assistedTransferCases = getAssistedTransferCases();
    AssistedTransferActions.setSubject(assistedTransferCases);
    Test.stopTest();
    Assert.areEqual(
      assistedTransferCases[0].Subject,
      'Assisted Transfer',
      'Case subject should be Assisted Transfer'
    );
  }

  @isTest
  private static void testUpdateOwnerOnSubStatusChange() {
    Test.startTest();
    List<Case> assistedTransferCases = getAssistedTransferCases();
    List<Case> oldAssistedTransferCases = getOldAssistedTransferCases();
    assistedTransferCases[0]
      .sub_status__c = AssistedTransferActions.AWAITING_SUPPORT_COACH_ACTION_SUB_STATUS;
    AssistedTransferActions.updateOwnerOnSubStatusChange(
      assistedTransferCases,
      new Map<Id, Case>{
        oldAssistedTransferCases[0].Id => oldAssistedTransferCases[0]
      }
    );
    Test.stopTest();
    String ownerId = assistedTransferCases[0].OwnerId;
    Assert.isTrue(
      ownerId.startsWith('00G'),
      'Case Owner should be updated to Support Coach Queue'
    );
  }
}
