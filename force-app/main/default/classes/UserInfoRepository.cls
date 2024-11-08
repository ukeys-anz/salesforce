/**
 * @description This class is responsible for replicating the standard UserInfo so that unittest can mock execution user.
 * @author Tan Phan
 * @since 09/2024
 * @group Util
 */
public with sharing class UserInfoRepository {
  private User currentUser {
    get {
      return currentUser ??
        (currentUser = [
          SELECT Id, UserName, Lan_Id__c, Profile.Name, UserRole.DeveloperName
          FROM User
          WHERE Id = :UserInfo.getUserId()
          WITH SYSTEM_MODE
        ]);
    }
    set;
  }

  private Set<String> assignedPermissions {
    get {
      return assignedPermissions ??
        (assignedPermissions = (Set<String>) ListUtil.getUniques(
          [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE IsActive = TRUE AND AssigneeId = :UserInfo.getUserId()
            WITH SYSTEM_MODE
          ],
          'PermissionSet.Name',
          String.class
        ));
    }
    set;
  }

  /**
   * @description Returns the User object of the current user.
   * @return The User record of the current User.
   */
  public User getUser() {
    return currentUser;
  }

  /**
   * @description Checks if the current user has a specific profile.
   * @param profileName The name of the profile to check.
   * @return True if the current user has the specified profile, false otherwise.
   */
  public Boolean checkProfile(String profileName) {
    return this.currentUser.Profile.Name == profileName;
  }

  /**
   * @description Checks if the user has any of the specified profiles.
   * @param profileNames A set of profile names to check.
   * @return True if the user has any of the specified profiles, false otherwise.
   */
  public Boolean checkAnyProfiles(Set<String> profileNames) {
    return profileNames.contains(this.currentUser.Profile.Name);
  }

  /**
   * @description Checks if the current user has a specific role.
   * @param roleName The name of the role to check.
   * @return True if the current user has the specified role, false otherwise.
   */
  public Boolean checkRole(String roleName) {
    return this.currentUser.UserRole.DeveloperName == roleName;
  }

  /**
   * @description Checks if the user has any of the specified roles.
   * @param roleNames A set of role names to check.
   * @return True if the user has any of the specified roles, false otherwise.
   */
  public Boolean checkAnyRoles(Set<String> roleNames) {
    return roleNames.contains(this.currentUser.UserRole.DeveloperName);
  }

  /**
   * @description Checks if the current user has a specific custom permission.
   * @param customPermission The name of the custom permission to check.
   * @return True if the current user has the specified custom permission, false otherwise.
   */
  public Boolean checkCustomPermission(String customPermission) {
    return FeatureManagement.checkPermission(customPermission);
  }

  /**
   * @description Checks if the user has a specific permission.
   * @param permissionSetOrGroupName The name of the permission set or group to check.
   * @return True if the user has the specified permission, false otherwise.
   */
  public Boolean checkPermission(String permissionSetOrGroupName) {
    return this.assignedPermissions.contains(permissionSetOrGroupName);
  }

  /**
   * @description Checks if the user has any of the specified permissions.
   * @param permissionSetOrGroupNames A set of permission set or group names to check.
   * @return True if the user has any of the specified permissions, false otherwise.
   */
  public Boolean checkAnyPermissions(Set<String> permissionSetOrGroupNames) {
    for (String ps : permissionSetOrGroupNames) {
      if (this.assignedPermissions.contains(ps)) {
        return true;
      }
    }
    return false;
  }
}
