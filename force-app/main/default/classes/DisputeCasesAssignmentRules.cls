/**
 * @author Mohit Garg
 * @since 03/2026
 * @description Contains ANZx Case Assignment rules conditions
 */
public with sharing class DisputeCasesAssignmentRules {
  private static final String CANCEL_PAYMENT = 'Cancel Payment';
  private static final String SUSPECTED_FRAUD = 'Suspected fraud';
  private static final String MONEY_NOT_RECEIVED = 'Money not received';
  private static final String AMENDMENT_REQUEST = 'Amendment Request';

  private static final Set<String> SUPPORT_COACH_DISPUTE_REASONS = new Set<String>{
    CANCEL_PAYMENT,
    MONEY_NOT_RECEIVED,
    AMENDMENT_REQUEST
  };
  /**
   * @description Method to assign Dispute Cases to appropriate queues based on Dispute Reason. If Dispute Reason is in SUPPORT_COACH_DISPUTE_REASONS, assign to Support Coach Queue, if reason is SUSPECTED_FRAUD, assign to Digital Fraud Queue.
   * This method is called from onBeforeUpdate trigger handler of Dispute Cases.
   * @param newCases List of new Case records in trigger context
   * @param oldCases Map of old Case records in trigger context
   */
  public static void assignDisputeCases(
    List<Case> newCases,
    Map<Id, Case> oldCases
  ) {
    for (Case c : newCases) {
      Case oldCase = (oldCases != null ? oldCases.get(c.Id) : null);
      if (
        !isSubmitedChanged(c, oldCase) &&
        !isDisputeReasonChanged(c, oldCase) &&
        oldCase != null
      ) {
        continue;
      }

      if (c.Dispute_Reason__c == SUSPECTED_FRAUD) {
        c.OwnerId = QueryQueue.digitalFraudQueue.Id;
      } else if (
        SUPPORT_COACH_DISPUTE_REASONS.contains(c.Dispute_Reason__c) &&
        c.submitted__c == true
      ) {
        c.OwnerId = QueryQueue.supportCoachQueue.Id;
      }
    }
  }

  /**
   * @description Helper method to check if the submitted__c field has changed in the Case record.
   * @param newCase The new Case record.
   * @param oldCase The old Case record.
   * @return True if the submitted__c field has changed, false otherwise.
   */
  public static boolean isSubmitedChanged(Case newCase, Case oldCase) {
    return oldCase != null && newCase.submitted__c != oldCase.submitted__c;
  }

  /**
   * @description Helper method to check if the Dispute_Reason__c field has changed in the Case record.
   * @param newCase The new Case record.
   * @param oldCase The old Case record.
   * @return True if the Dispute_Reason__c field has changed, false otherwise.
   */
  public static boolean isDisputeReasonChanged(Case newCase, Case oldCase) {
    return oldCase != null &&
      newCase.Dispute_Reason__c != oldCase.Dispute_Reason__c;
  }
}
