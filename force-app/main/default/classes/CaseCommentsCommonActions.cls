/**
 * @author Shermal Warnakula
 * @since 11/2020
 * @description Common Case Comments Action methods
 */
public with sharing class CaseCommentsCommonActions {
  private static final String INSERT_ERROR_FOR_FRAUDX = 'You cannot add comments on this Case record type';
  private static final String FRAUDX_AGENT_ROLE_NAME = 'FraudX Agent';
  private static final List<String> FRAUDX_CASE_RECORD_TYPES = new List<String>{
    'x',
    'y'
  };

  /**
   * @description Block record inserts based on User 'Role' and Case 'Record Type'
   * @param records The Case Comments records passed from Trigger.new()
   */
  public static void blockInsertsBasedOnUserRole(List<CaseComment> records) {
    // Check the Role of current user
    String uRoleName = '';
    String uRoleId = UserInfo.getUserRoleId();
    if (Schema.sObjectType.User.isQueryable()) {
      User loggedInUser = [
        SELECT id, UserRole.Name
        FROM User
        WHERE UserRoleId = :uRoleId
        LIMIT 1
      ];
      uRoleName = loggedInUser.UserRole.Name;
    }

    // Make sure FraudX Agents are only allowed to add Case Comments on Fraud case record types
    if (FRAUDX_AGENT_ROLE_NAME == uRoleName) {
      // Performing the SOQL query after the Role check to save SOQL limits.
      // We can always bring it outside when we have more requiements in the future around different user roles.
      if (Schema.sObjectType.Case.isQueryable()) {
        // Extract related Case IDs
        Set<Id> relatedCaseIDs = new Set<Id>();
        for (CaseComment record : (List<CaseComment>) records) {
          relatedCaseIDs.add(record.ParentId);
        }

        Map<ID, Case> caseRecordsById = new Map<ID, Case>(
          [
            SELECT Id, RecordType.DeveloperName
            FROM Case
            WHERE Id IN :relatedCaseIDs
          ]
        );

        // Validating Case Record Types of Case Comments being inserted
        for (CaseComment record : (List<CaseComment>) records) {
          if (
            !FRAUDX_CASE_RECORD_TYPES.contains(
              caseRecordsById.get(record.ParentId).RecordType.DeveloperName
            )
          ) {
            record.addError(INSERT_ERROR_FOR_FRAUDX);
          }
        }
      }
    }
  }
}
