/**
 * @author Lance Shi
 * @since 12/2021
 * @description Contains ANZx Case Assignment rules conditions
 * @group ANZx
 */
public with sharing class GetHelpCaseAssignmentRules {
  private static final Map<String, Id> QUEUE_MAP = IDRCaseAssignmentRules.getAnzxWorkbaskets();
  public static final String UNAUTHORISED_TRANSACTION = 'Unauthorised Transaction';
  public static final String DID_NOT_AUTHORISE_TRANSACTION = 'Didn\'t authorise transaction';
  public static final String DO_NOT_RECOGNISE_TRANSACTION = 'Don\'t recognise the transaction';
  public static final String CASH_DEPOSIT_ERROR = 'Cash Deposit Error';
  public static final String CHEQUE_DEPOSIT_ERROR = 'Cheque Deposit Error';
  /**
   * @description method to call the Case assignment rules for Disputes
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignDisputeCases(Case[] cases, Map<Id, Case> oldMap) {
    for (Case c : cases) {
      if (CheckCaseRecordType.isDispute(c) && c.submitted__c == true) {
        Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
        if (isSubmittedOrReasonChanged(c, oldCase)) {
          c.OwnerId = getOwnerId(c);
        }
      }

      if (
        c.RecordTypeId == GetHelpConstants.CARD_DISPUTE_RT_ID &&
        c.Transaction_Status__c == GetHelpConstants.TRANSACTION_STATUS_PENDING
      ) {
        c.OwnerId = getPendingOwnerId(c);
      }
    }
  }

  /**
   * @description method to verify if a case is newly created or have updated subumitted or dispute reason
   * @param newCase new case record
   * @param oldCase old case record
   * @return whether this is a new case or dispute reason or submitted has been changed
   */
  private static Boolean isSubmittedOrReasonChanged(
    Case newCase,
    Case oldCase
  ) {
    return (oldCase == null ||
    oldCase.submitted__c == false ||
    newCase.Dispute_Reason__c != oldCase.Dispute_Reason__c);
  }

  /**
   * @description method to set transaction status based on the origin and year
   * @param cases Records in the current context
   */
  public static void setTransactionStatus(Case[] cases) {
    for (Case rec : cases) {
      if (
        rec.RecordTypeId == GetHelpConstants.CARD_DISPUTE_RT_ID &&
        rec.Origin == 'App'
      ) {
        if (rec.Date_Posted__c == null || rec.Date_Posted__c.year() == 1970) {
          rec.Transaction_Status__c = GetHelpConstants.TRANSACTION_STATUS_PENDING;
          rec.Submitted__c = false;
        } else {
          rec.Transaction_Status__c = GetHelpConstants.TRANSACTION_STATUS_POSTED;
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
        rec.Dispute_Reason__c == DO_NOT_RECOGNISE_TRANSACTION ||
        rec.Dispute_Reason__c == UNAUTHORISED_TRANSACTION
      ) {
        return QUEUE_MAP.get(GetHelpConstants.CARD_DISPUTE_FRAUD_QUEUE);
      }
      if (
        rec.Dispute_Reason__c == CASH_DEPOSIT_ERROR ||
        rec.Dispute_Reason__c == CHEQUE_DEPOSIT_ERROR
      ) {
        return QUEUE_MAP.get(GetHelpConstants.SUPPORT_COACH_QUEUE);
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

  /**
   * @description method to run the Case assignment rules conditions for pending card cases
   * @param rec case record
   * @return Queue Id
   */
  private static ID getPendingOwnerId(Case rec) {
    if (
      rec.Dispute_Reason__c == DID_NOT_AUTHORISE_TRANSACTION ||
      rec.Dispute_Reason__c == DO_NOT_RECOGNISE_TRANSACTION
    ) {
      return QUEUE_MAP.get(GetHelpConstants.PENDING_CARD_DISPUTE_FRAUD_QUEUE);
    } else {
      return QUEUE_MAP.get(GetHelpConstants.PENDING_CARD_DISPUTE_GENERAL_QUEUE);
    }
  }
  /**
   * @description method to call the Case assignment rules for unauthenticated enquiries
   * Will assign those cases to Coach Queue
   * @param records List<Case> to be checked.
   */
  public static void assignUnauthenticatedEnquiryCases(List<Case> records) {
    Id coachQueueId = [SELECT Id FROM Group WHERE Name = 'Coach Queue' LIMIT 1]
    .Id;
    for (Case record : records) {
      if (CheckCaseRecordType.isAEM(record)) {
        record.OwnerId = coachQueueId;
        record.Queue__c = 'Coach Queue';
      }
    }
  }
}
