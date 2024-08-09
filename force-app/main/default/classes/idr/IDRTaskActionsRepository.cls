/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRCaseActions.
 * @runTests IDRTaskActionsTest
 */
public with sharing class IDRTaskActionsRepository {
  /**
   * @description Query cases to get the ownerId
   * @param caseIds case Ids in current context
   * @return list of cases
   */
  public List<Case> queryCases(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, OwnerId
      FROM Case
      WHERE Id IN :caseIds
    ];
  }
}
