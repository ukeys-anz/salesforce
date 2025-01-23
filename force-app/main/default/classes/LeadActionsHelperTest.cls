/**
 * @author Sanskriti
 * @since 1/2025
 * @description LeadActionHelperTest class for unit testing task creation upon insertion of BOH callback request lead
 */
@isTest
private class LeadActionsHelperTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testCallbackTaskCreation() {
    registerMocks();

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Firstname = 'Test',
      RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID,
      LeadSource = 'Web explore',
      Is_BOH_Lead__c = true
    );
    Lead leadrecord2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Firstname = 'Test2',
      RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID,
      LeadSource = 'Advertisement'
    );

    List<Lead> leadList = new List<Lead>{ leadrecord, leadrecord2 };
    Test.startTest();
    LeadActionsHelper.checkAndCreateCallbackTask(leadList);
    Test.stopTest();

    List<Task> taskCreated = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');

    Assert.isTrue(taskCreated.size() == 1, 'Only one Task should be created');
  }
}
