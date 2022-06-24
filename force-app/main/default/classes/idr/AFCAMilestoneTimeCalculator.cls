/**
 * @author Greg Shaw
 * @since 2022
 * @description Implement MilestoneTriggerTimeCalculator for AFCA milestone.
 */

global without sharing class AFCAMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
  /**
   * @description  Return the number of days between Date Received and AFCA Due Date
   * @param caseId Id of Case with Entitlement
   * @param milestoneTypeId Id of Milestone Type. To determine what type of milestone is being checked.
   * @return Number of days between Date Received and AFCA Due Date.
   */

  global Integer calculateMilestoneTriggerTime(
    Id caseId,
    String milestoneTypeId
  ) {
    if (Schema.SObjectType.Case.isQueryable()) {
      Case oCase = [
        SELECT Id, IDR_Date_Received__c, IDR_AFCA_Due_Date__c
        FROM Case
        WHERE Id = :caseId
      ];

      if (
        oCase.IDR_Date_Received__c != null &&
        oCase.IDR_AFCA_Due_Date__c != null &&
        oCase.IDR_AFCA_Due_Date__c > oCase.IDR_Date_Received__c
      ) {
        return oCase.IDR_Date_Received__c.date()
            .daysBetween(oCase.IDR_AFCA_Due_Date__c) *
          24 *
          60;
      }
    }
    return 0;
  }
}
