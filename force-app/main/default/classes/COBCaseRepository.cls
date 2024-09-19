/**
 * @author Batya Aisman Sufrin
 * @since 07/2024
 * @description  COBCaseStatusRepository is the repository class for COB Case.
 */
public with sharing class COBCaseRepository {
  private static final String EQUIFAX_DVS_PASS = 'PASS';
  /**
   * @description Get the case's child records count
   * @param parentCaseId Parent case ids
   * @return Numbers of child cases
   */
  public Integer queryCountOpenChildren(Id parentCaseId) {
    if (parentCaseId == null || SObjectType.Case.isQueryable() == false) {
      return 0;
    }
    return [
      SELECT COUNT()
      FROM Case
      WHERE ParentId = :parentCaseId AND IsClosed = FALSE
    ];
  }

  /**
   * @description Checks whether the case's (with cobCaseId) Customer Onboarding Application has an Equifax DVS Result == PASS
   * @param cobCaseId Case ids
   * @return Boolean True if case's (with cobCaseId) Customer Onboarding Application has an Equifax DVS Result == PASS, false otherwise
   */
  public Boolean isCobEquifaxDvsPass(Id cobCaseId) {
    if (
      cobCaseId == null ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false ||
      SObjectType.Case.isQueryable() == false
    ) {
      return false;
    }
    return [
        SELECT COUNT()
        FROM Case
        WHERE
          Id = :cobCaseId
          AND CustomerOnboardingApplication__r.EquifaxDVSResult__c = :EQUIFAX_DVS_PASS
      ] > 0;
  }

  /**
   * @description Get cases by ids
   * @param caseIds Case ids
   * @return List<Case> List of cases
   */
  public List<Case> getCasesByIds(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [SELECT Id, Status FROM Case WHERE Id IN :caseIds WITH USER_MODE];
  }

  /**
   * @description Check whether the logged in user has Join Leasd role
   * @return Boolean True if a user is Join Lead, false otherwise
   */
  public Boolean isCurrentUserJoinLead() {
    return UserInfo.GetUserRoleId() == QueryRole.joinLead.Id;
  }
}
