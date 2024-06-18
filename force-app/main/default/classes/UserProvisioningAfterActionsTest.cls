/**
 * @author Alan Hillgemann
 * @since June 2024
 * @description Test class for {@link UserProvisioningAfterActions}
 */
@isTest
private class UserProvisioningAfterActionsTest {
  @isTest
  static void testLogEntryWhenUserManuallyCreated() {
    User nonSailPointUser = TestUtil.createTestUserWithProfile(
      'ANZx Standard User'
    );
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Username = 'new.user@anzx.com';
    newUsers.add(newUser);
    Test.startTest();
    System.runAs(nonSailPointUser) {
      UserProvisioningAfterActions.logManualUserProvisioning(newUsers);
    }
    Test.stopTest();
    String expectedLogMessage =
      'User ' +
      newUser.Username +
      ' manually created by ' +
      nonSailPointUser.Username;
    List<LogEntry__c> logEntries = [
      SELECT LogMessage__c, Severity__c
      FROM LogEntry__c
      WHERE LogMessage__c LIKE :expectedLogMessage
    ];
    Assert.areEqual(
      1,
      logEntries.size(),
      'Log entry should be created when the user is manually created'
    );
    Assert.areEqual(
      Logger.Severity.CRITICAL.name(),
      logEntries[0].Severity__c,
      'Log entry severity should be critical'
    );
  }

  @isTest
  static void testNoLogEntryWhenUserNotManuallyCreated() {
    User sailPointUser = TestUtil.createTestUserWithProfile(
      'Minimum Access - External Apps'
    );
    sailPointUser.Username = 'sailpoint.user@anzx.com.unittest';
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Username = 'new.user@anzx.com';
    newUsers.add(newUser);
    Test.startTest();
    System.runAs(sailPointUser) {
      UserProvisioningAfterActions.logManualUserProvisioning(newUsers);
    }
    Test.stopTest();
    String unexpectedLogMessage =
      'User ' +
      newUser.Username +
      ' manually created by ' +
      sailPointUser.Username;
    List<LogEntry__c> logEntries = [
      SELECT LogMessage__c
      FROM LogEntry__c
      WHERE LogMessage__c LIKE :unexpectedLogMessage
    ];
    Assert.areEqual(
      0,
      logEntries.size(),
      'Log entry should not be created when the user is not manually created'
    );
  }
}
