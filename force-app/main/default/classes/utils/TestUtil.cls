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
   * @description createTestUserWithProfile to make a test user with a specific profile
   * @param profileName profile name for different test scenarios.
   * @return `User` return a user.
   */
  public static User createTestUserWithProfile(String profileName) {
    Profile profile = CommonUtil.getProfileByName(profileName);

    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueUser =
      orgId +
      dateString +
      randomInt +
      '@test' +
      orgId +
      '.org';

    Map<String, String> info = new Map<String, String>{
      'Alias' => 'test',
      'Email' => uniqueUser,
      'EmailEncodingKey' => 'UTF-8',
      'LastName' => 'Testing',
      'LanguageLocaleKey' => 'en_US',
      'LocaleSidKey' => 'en_US',
      'TimeZoneSidKey' => 'Australia/Sydney',
      'UserName' => uniqueUser,
      'ProfileId' => profile.Id
    };

    User user = TestUtil.createTestUser(info);
    return user;
  }

  /**
   * @description createTestUserWithProfile to make a test user with a specific profile
   * @param profileName profile name for different test scenarios.
   * @param userInformations to have specific user informations
   * @return `User` return a user.
   */

  public static User createTestUserWithProfile(
    String profileName,
    Map<String, String> userInformations
  ) {
    Profile profile = CommonUtil.getProfileByName(profileName);

    User user = TestUtil.createTestUser(userInformations);
    user.put('ProfileId', profile.Id);
    return user;
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

  /**
   * @description assign a list of permission sets by name to a list of users
   * @param psNames List of string of permission set names
   * @param users List of Users
   */
  public static void assignPermissionSets(
    List<String> psNames,
    List<User> users
  ) {
    List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
    for (String permissionSetName : psNames) {
      PermissionSet ps = CommonUtil.getPermissionSetByName(permissionSetName);
      for (User currentUser : users) {
        psAssignments.add(TestUtil.createPSAssignment(currentUser.id, ps.Id));
      }
    }
    insert psAssignments;
  }

  /**
   * @description assign a list of permission set groups by name to a list of users
   * @param psgNames List of string of permission set group names
   * @param users List of Users
   */
  public static void assignPermissionSetGroups(
    List<String> psgNames,
    List<User> users
  ) {
    List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
    Map<String, PermissionSetGroup> pSetGroupMap = UserProvisioningCommonActions.getAllPsetGroupMap();

    for (String permissionSetGroupName : psgNames) {
      PermissionSetGroup psg = pSetGroupMap.get(permissionSetGroupName);
      for (User currentUser : users) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = currentUser.Id,
          PermissionSetGroupId = psg.Id
        );
        psAssignments.add(psa);
      }
    }
    insert psAssignments;
  }

  /**
   * @description Returns a mock Database.SaveResult record
   * @param mockSaveResultString The mock save result string
   * @return A mock Database.SaveResult record
   */
  public static Database.SaveResult getMockSaveResult(
    String mockSaveResultString
  ) {
    return (Database.SaveResult) JSON.deserialize(
      mockSaveResultString,
      Database.SaveResult.class
    );
  }

  /**
   * @description Returns a mock Database.MergeResult record
   * @param mockMergeResultString The mock merge result string
   * @return A mock Database.MergeResult record
   */
  public static Database.MergeResult getMockMergeResult(
    String mockMergeResultString
  ) {
    return (Database.MergeResult) JSON.deserialize(
      mockMergeResultString,
      Database.MergeResult.class
    );
  }

  /**
   * @description Returns a mock Database.UpsertResult record
   * @param mockUpsertResultString The mock upsert result string
   * @return A mock Database.UpsertResult record
   */
  public static Database.UpsertResult getMockUpsertResult(
    String mockUpsertResultString
  ) {
    return (Database.UpsertResult) JSON.deserialize(
      mockUpsertResultString,
      Database.UpsertResult.class
    );
  }

  /**
   * @description Returns a mock Database.DeleteResult record
   * @param mockDeleteResultString The mock delete result string
   * @return A mock Database.DeleteResult record
   */
  public static Database.DeleteResult getMockDeleteResult(
    String mockDeleteResultString
  ) {
    return (Database.DeleteResult) JSON.deserialize(
      mockDeleteResultString,
      Database.DeleteResult.class
    );
  }

  /**
   * @description Returns a mock Database.UndeleteResult record
   * @param mockUndeleteResultString The mock undelete result string
   * @return A mock Database.UndeleteResult record
   */
  public static Database.UndeleteResult getMockUndeleteResult(
    String mockUndeleteResultString
  ) {
    return (Database.UndeleteResult) JSON.deserialize(
      mockUndeleteResultString,
      Database.UndeleteResult.class
    );
  }
}
