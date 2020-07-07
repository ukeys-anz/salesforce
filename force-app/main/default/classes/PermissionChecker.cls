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
    report.sObjectAccess = new Set<String>();
    List<PermissionSetAssignment> permSetAssignments;

    if (
      PermissionSetAssignment.SObjectType.getDescribe().isAccessible() &&
      ObjectPermissions.SObjectType.getDescribe().isAccessible()
    ) {
      permSetAssignments = new List<PermissionSetAssignment>(
        [
          SELECT
            Assignee.Name,
            PermissionSetId,
            PermissionSet.isOwnedByProfile,
            PermissionSet.Profile.Name,
            PermissionSet.Label
          FROM PermissionSetAssignment
          WHERE
            PermissionSetId IN (
              SELECT ParentId
              FROM ObjectPermissions
              WHERE SObjectType IN :sObjectList AND PermissionsRead = TRUE
            )
            AND Assignee.Id = :userId
        ]
      );
    } else {
      throw new CheckerException(
        'The running user does not have access to the PermissionSetAssignment and the ObjectPermissions SObjects.'
      );
    }

    report.hasPermission = permSetAssignments.size() > 0;

    if (report.hasPermission) {
      PermissionSetAssignment permSetAssignment = permSetAssignments[0];
      report.isProfile = permSetAssignment.PermissionSet.isOwnedByProfile;
      report.label = report.isProfile
        ? permSetAssignment.PermissionSet.Profile.Name
        : permSetAssignment.PermissionSet.label;
      for (ObjectPermissions op : [
        SELECT SObjectType
        FROM ObjectPermissions
        WHERE
          SObjectType IN :sObjectList
          AND PermissionsRead = TRUE
          AND ParentId = :permSetAssignment.PermissionSetId
      ]) {
        report.sObjectAccess.add(op.SObjectType);
      }
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

    /**
     * @description A collection of the names of objects the user has access to
     */
    public Set<String> sObjectAccess { get; set; }
  }

  /**
   * @description Extends the Exception class to throw custom exceptions
   */
  public class CheckerException extends Exception {
  }
}
