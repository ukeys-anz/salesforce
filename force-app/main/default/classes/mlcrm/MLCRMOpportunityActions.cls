/**
 * @author Ankit Garg
 * @since  19/July/2023
 * @group MLCRM (Moblie Lending CRM)
 * @description MLCRMOpportunityActions is class to handle all the MLCRM Opportunity Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class MLCRMOpportunityActions {
  /**
   * @description validate MLCRM Opportunity
   * 1. CC-4528 validate opporutnity that it can't be closed unless all associated tasks are marked either as 'completed' or 'not required'.
   * @name validateMLCRMOpprtunity
   * @param newOppList list of new records
   * @param oldOppMap map of old records
   */
  public static void validateMLCRMOpportunity(
    List<Opportunity> newOppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    Map<Id, Opportunity> closingOppMap = new Map<Id, Opportunity>();
    for (Opportunity opp : newOppList) {
      //CC-4528 validate opporutnity that it can't be closed unless all associated tasks are marked either as 'completed' or 'not required'.
      if (
        opp.RecordTypeId == MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID &&
        oldOppMap != null &&
        opp.StageName != oldOppMap.get(opp.Id).StageName &&
        (opp.StageName.equalsIgnoreCase(MLCRMConstants.STAGE_CLOSED) ||
        opp.StageName.equalsIgnoreCase(MLCRMConstants.STAGE_LOST))
      ) {
        closingOppMap.put(opp.id, opp);
      }
    }
    if (!closingOppMap.isEmpty()) {
      CCRMOpportunityActions.checkOpportunityHasOpenTaskBeforeStageChange(
        closingOppMap,
        new Map<Id, Opportunity>()
      );
    }
  }
}
