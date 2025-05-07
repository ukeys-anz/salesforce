/**
 * @author Kopal Goswami
 * @since  May/2025
 * @description Test Class for TaskCloudEventBuildHelper
 */
@isTest
public with sharing class TaskCloudEventBuildHelperTest {
  @isTest
  static void testCreateCloudEventPositive() {
    Test.startTest();
    CloudEventModel taskCloudEvent = TaskCloudEventBuildHelper.createCloudEvent(
      mockTaskRecord(RTTask.customerNudge),
      TestDataFactory.createAccount('account1', false),
      '',
      new CloudEventModel.UserModel()
    );
    Test.stopTest();

    Assert.isNotNull(taskCloudEvent, 'The task cloud event should be created');
  }

  @isTest
  static void testCreateCloudEventNegative() {
    Test.startTest();
    CloudEventModel taskCloudEvent = TaskCloudEventBuildHelper.createCloudEvent(
      mockTaskRecord(RTTask.coachNudge),
      TestDataFactory.createAccount('account1', false),
      '',
      new CloudEventModel.UserModel()
    );
    Test.stopTest();

    Assert.isNull(taskCloudEvent, 'The task cloud event should not be created');
  }

  /**
   * @description helper method to create a mock task
   * @param taskRecordType record type of the task
   * @return Mock Task
   */
  static Task mockTaskRecord(Id taskRecordType) {
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      taskRecordType,
      Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      UserInfo.getUserId(),
      false
    );

    mockPushToAppTask.Id = Lib_FakeIdGenerator.getMockId(Task.getSObjectType());
    mockPushToAppTask.Status = 'New';
    mockPushToAppTask.Pub_Sub_Event_Id__c = '12345_12';

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }
}
