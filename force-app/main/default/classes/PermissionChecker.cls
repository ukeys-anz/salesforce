/**
 *
 * @author Peter Charalambous
 * @since 06/2020
 * @description Report whether a given user has 'Read' permission on a particular type of sObject
 */
public class PermissionChecker {
  public static PermissionReport HasReadAllPermission(
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

    report.HasPermission = permSetAssignments.size() > 0;

    if (report.HasPermission) {
      PermissionSetAssignment permSetAssignment = permSetAssignments[0];
      report.IsProfile = permSetAssignment.PermissionSet.isOwnedByProfile;
      report.Label = report.IsProfile
        ? permSetAssignment.PermissionSet.Profile.Name
        : permSetAssignment.PermissionSet.Label;
    }

    return report;
  }

  public class PermissionReport {
    public boolean HasPermission { get; set; } // true if have permission via profile or permission set
    public boolean IsProfile { get; set; } // true if profile, false if permission set
    public String Label { get; set; } // the name of the profile or permission set granting access
  }
}
