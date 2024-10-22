@isTest
public class BlockPrivateKeyQueryEventHandlerTest {
  @isTest
  static void testEvaluatePositive() {
    Test.startTest();
    ApiEvent testEvent = mockAPIEventForTest(
      'PrivateKeyStorage__c',
      '[SELECT Id, Private_Key__c  FROM PrivateKeyStorage__c]'
    );
    Boolean result = BlockPrivateKeyQueryEventHandler.evaluate(testEvent);
    Test.stopTest();

    Assert.isTrue(
      result,
      'An query for PrivateKeyStorage__c should not be allowed'
    );
  }

  @isTest
  static void testEvaluateNagative() {
    Test.startTest();
    ApiEvent testEvent = mockAPIEventForTest('User', '[SELECT Id FROM User]');
    Boolean result = BlockPrivateKeyQueryEventHandler.evaluate(testEvent);
    Test.stopTest();

    Assert.isFalse(result, 'User object can be quried, hence it is allowed');
  }

  @isTest
  static void testEvaluateDefault() {
    Test.startTest();
    Boolean result = BlockPrivateKeyQueryEventHandler.evaluate(null);
    Test.stopTest();

    Assert.isFalse(result, 'Event should be null, so operation is allowed');
  }

  private static ApiEvent mockAPIEventForTest(
    String queriedEntity,
    String query
  ) {
    ApiEvent testEvent = new ApiEvent();
    testEvent.QueriedEntities = queriedEntity;
    testEvent.query = query;
    testEvent.UserId = UserInfo.getUserId();
    testEvent.username = UserInfo.getUsername();
    return testEvent;
  }
}
