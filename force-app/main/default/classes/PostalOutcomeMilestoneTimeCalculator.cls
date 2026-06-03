/**
 * @author Shivam Goyal
 * @since 2026
 * @description Calculates milestone trigger time for Postal Outcome Letter-Due
 */

public with sharing class PostalOutcomeMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
  private static final MilestoneRepository MILESTONE_REPOSITORY = (MilestoneRepository) Lib_InstanceProvider.forType(
    MilestoneRepository.class
  );

  /**
   * @description  Calculate the new Milestone trigger time
   * @param caseId Id of the case
   * @param milestoneTypeId Id of Milestones based on which postal outcome milestone time is calculated
   * @return  Integer Number of days between Date Received and Mail Outcome Letter Milestone
   */

  public Integer calculateMilestoneTriggerTime(
    Id caseId,
    String milestoneTypeId
  ) {
    Case oCase = (Case) MILESTONE_REPOSITORY.queryCaseMilestoneonCase(caseId);
    return calculatePostalOutcomeTime(
      oCase.CaseMilestones[0].MilestoneType.Name,
      oCase.IDR_Date_Received__c
    );
  }
  @TestVisible
  private Integer calculatePostalOutcomeTime(
    String milestoneName,
    Datetime dateReceived
  ) {
    Map<String, Integer> mapOfMilestoneNameToDays = new Map<String, Integer>{
      IDRConstants.MILESTONE_PRIORITY => 14,
      IDRConstants.MILESTONE_STANDARD => 23
    };
    Long millisecsUntilTarget;
    Datetime newTargetDate;
    Integer postalOutComeTimeRemaininginMins;
    Integer postalDurationDays = 0;

    if (mapOfMilestoneNameToDays.containsKey(milestoneName)) {
      postalDurationDays = mapOfMilestoneNameToDays.get(milestoneName);
    }

    newTargetDate = dateReceived.addDays(postalDurationDays);
    millisecsUntilTarget = newTargetDate.getTime() - dateReceived.getTime();
    postalOutComeTimeRemaininginMins = (Integer) (millisecsUntilTarget / 60000);

    return Math.max(postalOutComeTimeRemaininginMins, 0);
  }
}
