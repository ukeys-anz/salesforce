/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is to provide generic setups configs for unit tests.
 * @group Utils
 */
@isTest
public with sharing class TestUtil {
  /**
   * @description Add required PermissionSet
   */
  public static void addAccountsGoalsPs() {
    PermissionSet ps = CommonUtil.getPermissionSetByName(
      'Accounts_Goals_Read_Only'
    );
    PermissionSetAssignment psa = createPSAssignment(
      UserInfo.getUserId(),
      ps.Id
    );
    insert psa;
  }

  /**
   * @description Create test user record with default values - no arguement version
   * @return User
   */
  public static User createTestUser() {
    User testUser = createTestUser(null);
    return testUser;
  }

  /**
   * @description Create test user record with default values
   * @param additionalParams additional parameters to be populated on user instance
   * @return User
   */
  public static User createTestUser(Map<String, Object> additionalParams) {
    User testUser = new User();

    testUser = (User) FakerFactory.make(
      new FakerUserFactory(),
      additionalParams
    );
    return testUser;
  }

  /**
   * @description Create PermissionSetAssignment record
   * @param assigneeId user id of the assignee
   * @param psId permission set Id
   * @return PermissionSetAssignment
   */
  public static PermissionSetAssignment createPSAssignment(
    String assigneeId,
    String psId
  ) {
    PermissionSetAssignment psAssignment = new PermissionSetAssignment(
      AssigneeId = assigneeId,
      PermissionSetId = psId
    );
    return psAssignment;
  }

  /**
   * @description Create PermissionSetAssignment record
   * @param assigneeId user id of the assignee
   * @param psGroupId permission set group Id
   * @return PermissionSetAssignment
   */
  public static PermissionSetAssignment createPSGroupAssignment(
    String assigneeId,
    String psGroupId
  ) {
    PermissionSetAssignment psGroupAssignment = new PermissionSetAssignment(
      PermissionSetGroupId = psGroupId,
      AssigneeId = assigneeId
    );
    return psGroupAssignment;
  }

  /**
   * @description Get user record by FirstName
   * @param firstName given first name of the user
   * @return User
   */
  public static User getUserByFirstName(String firstName) {
    User testUser = new User();
    for (User user : [SELECT Id FROM User WHERE FirstName = :firstName]) {
      testUser = user;
    }

    return testUser;
  }

  /**
   * @param psNameList permission name list
   * @description Add required PermissionSet
   */
  public static void addPermissionSets(List<String> psNameList) {
    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :psNameList
    ];
    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = UserInfo.getUserId(),
        PermissionSetId = ps.Id
      );
      psaList.add(psa);
    }
    insert psaList;
  }
}
