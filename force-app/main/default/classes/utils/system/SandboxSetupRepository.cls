/**
 * @author Alan Hillgemann
 * @since September 2024
 * @description Repository class for SandboxSetup.
 */
public with sharing class SandboxSetupRepository {
  /**
   * @description Get the user who created, cloned or refreshed the sandbox.
   * @return User.
   */
  public User getUser() {
    return [
      SELECT Id, ProfileId, Name
      FROM User
      WHERE
        Email LIKE '%anz.com'
        AND (NOT Name LIKE '%system%')
        AND IsActive = TRUE
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
  }

  /**
   * @description Get the permission set assignments of the sandbox user to modify.
   * @param psNames Permission set names.
   * @param userId User Id.
   * @return Permission set assignments to modify.
   */
  public List<PermissionSetAssignment> getPsas(Set<String> psNames, Id userId) {
    return [
      SELECT Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSet.Name IN :psNames
      WITH SECURITY_ENFORCED
    ];
  }
}
