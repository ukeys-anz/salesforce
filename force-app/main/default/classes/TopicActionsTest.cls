/**
 * @author Aman Gupta
 * @since 04/2025
 * @description TopicActionsTest is the test class to cover tests for {@link TopicActions.cls}
 */
@isTest
public class TopicActionsTest {
  static Lib_MockProvider userMock;

  static void registerPositiveMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  static void registerNegativeMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', false);
  }

  @isTest
  static void testValidatePermissionForTopicCreationWithPermission() {
    Test.startTest();
    registerPositiveMocks();
    Topic topicRec = new Topic();
    TopicActions.validatePermissionForTopicCreation(
      new List<Topic>{ topicRec }
    );
    Test.stopTest();
    Assert.isFalse(topicRec.hasErrors(), 'Topic should not have error');
  }

  @isTest
  static void testValidatePermissionForTopicCreationWithoutPermission() {
    Test.startTest();
    registerNegativeMocks();
    Topic topicRec = new Topic();
    TopicActions.validatePermissionForTopicCreation(
      new List<Topic>{ topicRec }
    );
    Test.stopTest();
    Assert.isTrue(topicRec.hasErrors(), 'Topic should have error');
  }
}
