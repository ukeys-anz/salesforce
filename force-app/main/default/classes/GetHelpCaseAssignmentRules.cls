/**
 * @author Lance Shi
 * @since 12/2021
 * @description Contains ANZx Dispute Case Assignment rules conditions
 * @group ANZx
 */
public with sharing class GetHelpCaseAssignmentRules {
  private static final Map<String, Id> QUEUE_MAP = IDRCaseAssignmentRules.getAnzxWorkbaskets();
  public static final String UNAUTHORISED_TRANSACTION = 'Unauthorised Transaction';
  public static final String DID_NOT_AUTHORISE_TRANSACTION = 'Didn\'t authorise transaction';
  /**
   * @description method to call the Case assignment rules
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignDisputeCases(Case[] cases, Map<Id, Case> oldMap) {
    for (Case c : cases) {
      if (GetHelpCaseActionsHelper.isDispute(c) && c.submitted__c == true) {
        Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
        if (
          oldCase == null ||
          oldCase.submitted__c == false ||
          c.Dispute_Reason__c != oldCase.Dispute_Reason__c
        ) {
          c.OwnerId = getOwnerId(c);
        }
      }
    }
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @return Queue Id
   */
  private static ID getOwnerId(Case rec) {
    //rules to run only on escalation
    if (
      rec.RecordTypeId == GetHelpConstants.CARD_DISPUTE_RT_ID ||
      rec.RecordTypeId == GetHelpConstants.ATM_DISPUTE_RT_ID
    ) {
      if (
        rec.Dispute_Reason__c == DID_NOT_AUTHORISE_TRANSACTION ||
        rec.Dispute_Reason__c == UNAUTHORISED_TRANSACTION
      ) {
        return QUEUE_MAP.get(GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE);
      } else {
        return QUEUE_MAP.get(GetHelpConstants.CARD_DISPUTE_GENERAL_QUEUE);
      }
    } else {
      if (
        rec.Dispute_Reason__c == UNAUTHORISED_TRANSACTION &&
        rec.RecordTypeId != GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID
      ) {
        return QUEUE_MAP.get(GetHelpConstants.DIGITAL_FRAUD_QUEUE);
      } else {
        return QUEUE_MAP.get(GetHelpConstants.SUPPORT_COACH_QUEUE);
      }
    }
  }
}
