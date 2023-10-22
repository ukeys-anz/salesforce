/**
 * @author Hrushikesh
 * @since July 2023
 * @description PayToPermissionCheckerTest is provide unit test coverage for PayToPermissionChecker.
 */
@isTest
private class PayToPermissionCheckerTest {
  /**
   * @description Setup data for test classes
   */
  @testSetup
  public static void setup() {
    Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    User coach = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'CoachTest',
        'ProfileId' => profile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coach;

    User coach1 = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'CoachTest1',
        'ProfileId' => profile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coach1;

    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'PayTo_View_Agreements'
      LIMIT 1
    ];
    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coach.Id,
      PermissionSetId = ps.Id
    );
    insert psa;
    PermissionSet ps1 = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'PayTo_Cancel_Agreements'
      LIMIT 1
    ];
    PermissionSetAssignment psa1 = new PermissionSetAssignment(
      AssigneeId = coach.Id,
      PermissionSetId = ps1.Id
    );
    insert psa1;
  }

  // Test scenario where both the permission sets are assigned
  @isTest
  static void testPositiveCheckPermissions() {
    User u = [SELECT Id FROM User WHERE FirstName = 'CoachTest' LIMIT 1];
    System.runAs(u) {
      Test.startTest();
      Map<String, Object> inputMap = new Map<String, Object>();
      Map<String, Object> outMap = new Map<String, Object>();
      Map<String, Object> options = new Map<String, Object>();
      PayToPermissionChecker ctrl = new PayToPermissionChecker();
      Boolean isInvoked = (Boolean) ctrl.call(
        'checkPermissions',
        new Map<String, Object>{
          'input' => inputMap,
          'output' => outMap,
          'options' => options
        }
      );
      Test.stopTest();
      System.assertEquals(true, (Boolean) outMap.get('canView'));
      System.assertEquals(true, (Boolean) outMap.get('canCancel'));
    }
  }
  // Test scenario where both the permission sets are not assigned
  @isTest
  static void testNegativeCheckPermissions() {
    User u = [SELECT Id FROM User WHERE FirstName = 'CoachTest1' LIMIT 1];
    System.runAs(u) {
      Test.startTest();
      Map<String, Object> inputMap = new Map<String, Object>();
      Map<String, Object> outMap = new Map<String, Object>();
      Map<String, Object> options = new Map<String, Object>();
      PayToPermissionChecker ctrl = new PayToPermissionChecker();
      Boolean isInvoked = (Boolean) ctrl.call(
        'checkPermissions',
        new Map<String, Object>{
          'input' => inputMap,
          'output' => outMap,
          'options' => options
        }
      );
      Test.stopTest();
      System.assertEquals(false, (Boolean) outMap.get('canView'));
      System.assertEquals(false, (Boolean) outMap.get('canCancel'));
    }
  }
}
