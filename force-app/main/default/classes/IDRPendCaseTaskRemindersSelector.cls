/**
 * @author Adnan
 * @since  09/2021
 * @description Selector class which contains queries for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersSelector {
  /**
   * @description method to get case records from soql query
   * @param caseIdList list of case ids
   * @return Map<Id, Case> returns map of case with its id
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //No need for CRUD validation as all the profiles will have access to CaseNumber, OwnerId of Case Object
  public static Map<Id, Case> getCasesFromIds(List<Id> caseIdList) {
    return new Map<Id, Case>(
      [
        SELECT
          Id,
          CaseNumber,
          OwnerId,
          TYPEOF Owner
            WHEN User THEN Id, FirstName, ManagerId
          END
        FROM Case
        WHERE Id IN :caseIdList AND Owner.Type = 'User'
      ]
    );
  }
}
