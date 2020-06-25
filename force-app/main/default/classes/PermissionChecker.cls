/**
 *
 * @author Peter Charalambous
 * @since 06/2020
 * @description Report whether a given user has 'Read' permission on a particular type of sObject
 */
public with sharing class PermissionChecker {
  /**
   * @description check if user has permissions to sobjects
   * @param sObjectList array of sObjects
   * @param userId Id of user to check permissions against
   * @return Permission Report
   */
  public static PermissionReport hasReadAllPermission(
    String[] sObjectList,
    Id userId
  ) {
    PermissionReport report = new PermissionReport();
    List<PermissionSetAssignment> permSetAssignments = [
      SELECT
        Assignee.Name,
        PermissionSet.Id,
        PermissionSet.isOwnedByProfile,
        PermissionSet.Profile.Name,
        PermissionSet.Label
      FROM PermissionSetAssignment
      WHERE
        PermissionSetId IN (
          SELECT ParentId
          FROM ObjectPermissions
          WHERE SObjectType IN :sObjectList AND PermissionsRead = true
        )
        AND Assignee.Id = :userId
    ];

    report.hasPermission = permSetAssignments.size() > 0;

    if (report.hasPermission) {
      PermissionSetAssignment permSetAssignment = permSetAssignments[0];
      report.isProfile = permSetAssignment.PermissionSet.isOwnedByProfile;
      report.label = report.isProfile
        ? permSetAssignment.PermissionSet.Profile.Name
        : permSetAssignment.PermissionSet.label;
    }

    return report;
  }

  /**
   * @description Report on users permission
   */
  public class PermissionReport {
    /**
     * @description Getter/Setter for whether or not user has permission
     */
    public boolean hasPermission { get; set; }

    /**
     * @description Getter/Setter for whether or not users permissions are from profile
     */
    public boolean isProfile { get; set; }

    /**
     * @description Getter/Setter for the name of the profile or permission set granting access
     */
    public String label { get; set; }
  }
}
