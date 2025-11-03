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
    record.Status = 'Open';
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
}
