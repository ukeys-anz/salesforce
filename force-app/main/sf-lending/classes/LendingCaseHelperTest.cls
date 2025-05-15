/**
 *
 * @author Raman Gupta
 * @since May 2025
 * @description Test class for {@link LendingCaseHelper)
 */
@isTest
public with sharing class LendingCaseHelperTest {
  static Lib_MockProvider lendingCaseRefinance;
  static Lib_MockProvider lendingCaseAPIRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    lendingCaseRefinance = Lib_MockProvider.forType(LendingCaseRepository.class)
      .mock('queryCaseByRecordId', getCase);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    lendingCaseAPIRepoMock = Lib_MockProvider.forType(
      LendingCaseAPIRepository.class
    );
  }
  /**
   * @description Static method to return Case Record
   */
  static Case getCase {
    get {
      case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Address__c = 'Test';
      caseRecord.Status = 'New';
      return caseRecord;
    }
  }

  @isTest
  static void testUpdateCaseStatusRejectedSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    Test.startTest();
    LendingCaseHelper.updateCaseStatus(recordId, 'STATE_REJECTED');
    Test.stopTest();
    Case caseUpd = (Case) dmlMockProvider.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(caseUpd, 'Case is updated');
  }

  @isTest
  static void testUpdateCaseStatusApprovedSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    Test.startTest();
    LendingCaseHelper.updateCaseStatus(recordId, 'STATE_APPROVED');
    Test.stopTest();
    Case caseUpd = (Case) dmlMockProvider.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(caseUpd, 'Case is updated');
  }

  @isTest
  static void testUpdateCaseStatusException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    dmlMockProvider.mockException(
      'doUpdate',
      new AuraHandledException('Update failed!')
    );
    Test.startTest();
    Boolean caseUpdateSuccess = LendingCaseHelper.updateCaseStatus(
      recordId,
      'STATE_APPROVED'
    );
    Test.stopTest();
    Assert.isFalse(caseUpdateSuccess, 'Case update Failed');
  }
}
