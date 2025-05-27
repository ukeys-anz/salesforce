/**
 * @author Manisha Srilekha
 * @since 2025
 * @description Implement MailOutcomeMilestoneTimeCalculator for Mail Outcome milestone.
 */

public with sharing class MailOutcomeMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
  private static final MilestoneRepository MILESTONE_REPOSITORY = (MilestoneRepository) Lib_InstanceProvider.forType(
    MilestoneRepository.class
  );
  /**
   * @description  Return the number of days between Date Received and AFCA Due Date
   * @param caseId Id of Case with Entitlement
   * @param milestoneTypeId Id of Milestone Type. To determine what type of milestone is being checked.
   * @return Number of days between Date Received and Mail Outcome Letter Milestone
   */

  public Integer calculateMilestoneTriggerTime(
    Id caseId,
    String milestoneTypeId
  ) {
    Case oCase = (Case) MILESTONE_REPOSITORY.queryCaseMilestoneonCase(caseId);

    if (oCase.CaseMilestones.isEmpty()) {
      return 0;
    }
    return calculateMailOutcomeTime(
      oCase.CaseMilestones[0].MilestoneType.Name,
      oCase.IDR_Date_Received__c
    );
  }
  /**
   * @description  Calculate the new Milestone trigger time
   * @param milestoneName Milestone based on which Mail outcome milestone time is calculated
   * @param dateReceived Date received of the case
   * @return Number of days between Date Received and Mail Outcome Letter Milestone
   */

  private Integer calculateMailOutcomeTime(
    String milestoneName,
    Datetime dateReceived
  ) {
    Map<String, Integer> mapOfMilestoneNameToDays = new Map<String, Integer>{
      IDRConstants.MILESTONE_PRIORITY => 14,
      IDRConstants.MILESTONE_STANDARD => 23
    };
    Datetime newTargetDate = dateReceived.addDays(
      mapOfMilestoneNameToDays.get(milestoneName)
    );

    Long millisecsUntilTarget =
      newTargetDate.getTime() - dateReceived.getTime();

    Integer mailOutComeTimeRemaininginMins = (Integer) (millisecsUntilTarget /
    60000);

    return Math.max(mailOutComeTimeRemaininginMins, 0);
  }
}
