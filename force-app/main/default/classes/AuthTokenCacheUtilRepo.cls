/**
 * @author       : CMOS
 * @since        : May-2026
 * @description  :  This class contains public repository for all queries used in AuthTokenCacheUtil
 **/
public with sharing class AuthTokenCacheUtilRepo {
  /**
   * @description It will fetch all permission set Ids having custom permission assigned
   * @param customPermission name of custom permission
   * @return List<SetupEntityAccess>
   */
  public List<SetupEntityAccess> getPermissionSetWithCustomPermission(
    String customPermission
  ) {
    if (customPermission == null) {
      return new List<SetupEntityAccess>();
    }
    return [
      SELECT ParentId
      FROM SetupEntityAccess
      WHERE
        SetupEntityId IN (
          SELECT Id
          FROM CustomPermission
          WHERE DeveloperName = :customPermission
        )
      WITH SYSTEM_MODE
    ];
  }
  /**
   * @description It will fetch all permission set groups containing mentioned permission sets
   * @param permissionSetWithCustomPermission permission set Ids having custom permission assigned
   * @return List<PermissionSetGroupComponent>
   */
  public List<PermissionSetGroupComponent> getPermissionSetGroupFromPS(
    Set<Id> permissionSetWithCustomPermission
  ) {
    if (permissionSetWithCustomPermission.isEmpty()) {
      return new List<PermissionSetGroupComponent>();
    }
    return [
      SELECT PermissionSetGroupId
      FROM PermissionSetGroupComponent
      WHERE PermissionSetId IN :permissionSetWithCustomPermission
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description It will fetch all users having assinged to permission set groups
   * @param userId set of ownerIds of lead
   * @param permissionSetWithCustomPermission permission set Ids having custom permission assigned
   * @param permissionSetGroupFromPS permission set groups containing mentioned permission sets
   * @return List<PermissionSetAssignment>
   */
  public List<PermissionSetAssignment> listOfPsetAssignmentCustomPermission(
    String userId,
    Set<Id> permissionSetWithCustomPermission,
    Set<Id> permissionSetGroupFromPS
  ) {
    if (
      permissionSetGroupFromPS.isEmpty() ||
      String.isBlank(userId) ||
      permissionSetWithCustomPermission.isEmpty()
    ) {
      return new List<PermissionSetAssignment>();
    }

    return [
      SELECT AssigneeId
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND (PermissionSetId IN :permissionSetWithCustomPermission
        OR PermissionSetGroupId IN :permissionSetGroupFromPS)
        AND AssigneeId = :userId
      WITH SYSTEM_MODE
    ];
  }
}
