/**
 * @author Manisha Srilekha
 * @since 05/2025
 * @description This class provides SOQL and DML helpers for classes related MailOutcomeMilestoneTimeCalculator.
 * @runTests MailOutcomeMilestoneTimeCalculatorTest
 */
public with sharing class MilestoneRepository {
  /**
   * @description Query Milestones on Case
   * @param caseId case Id in current context
   * @return case record with current Milestones
   */
  public Case queryCaseMilestoneonCase(Id caseId) {
    Set<String> currentMilestonesonCase = new Set<String>{
      IDRConstants.MILESTONE_STANDARD,
      IDRConstants.MILESTONE_PRIORITY
    };
    return [
      SELECT
        Id,
        IDR_Date_Received__c,
        (
          SELECT
            Id,
            TargetDate,
            MilestoneTypeId,
            MilestoneType.name,
            completionDate
          FROM CaseMilestones
          WHERE MilestoneType.name IN :currentMilestonesonCase
          ORDER BY CreatedDate
          LIMIT 1
        )
      FROM Case
      WHERE Id = :caseId AND IDR_Date_Received__c != NULL
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
