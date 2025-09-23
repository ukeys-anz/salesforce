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
  public static final String HOME_LOANS_PRODUCT_CATEGORY = 'Home loans';
  public static final String CANCEL_TRANSFER = 'Cancel transfer';
  public static final String SUSPECTED_FRAUD = 'Suspected fraud';
  public static final String PAYEE_HAS_NOT_RECIEVED_FUNDS = 'Payee has not received funds';
  public static final String AMENDMENT_REQUEST = 'Amendment Request';
  public static final Group COACH_QUEUE = CommonUtil.getQueueByName(
    'Coach_Queue'
  );
  public static final Group BOH_COACH_QUEUE = CommonUtil.getQueueByName(
    'BOH_Coach_Queue'
  );
  public static final Group SUPPORT_COACH_QUEUE = CommonUtil.getQueueByName(
    'Support_Coach_Queue'
  );
  public static final Group DIGITAL_FRAUD_QUEUE = CommonUtil.getQueueByName(
    GetHelpConstants.DIGITAL_FRAUD_QUEUE
  );

  private static final Set<String> CARD_DISPUTE_FRAUD_REASONS = new Set<String>{
    DID_NOT_AUTHORISE_TRANSACTION,
    DO_NOT_RECOGNISE_TRANSACTION,
    UNAUTHORISED_TRANSACTION
  };

  private static final Set<String> SUPPORT_COACH_DISPUTE_REASONS = new Set<String>{
    CANCEL_TRANSFER,
    PAYEE_HAS_NOT_RECIEVED_FUNDS,
    AMENDMENT_REQUEST
  };

  private static final Map<String, String> SUB_TYPE_TO_TYPE_MAP_SUPPORT_COACH = new Map<String, String>{
    'VAU Opt-In' => 'Cards',
    'VAU Opt-Out' => 'Cards',
    'Merchant Refund' => 'Cards',
    'ATM Cash Deposit Dispute' => 'Money',
    'ATM Cheque Deposit Dispute' => 'Money',
    'PayID technical issue' => 'PayID Issue/Dispute',
    'Email PayID already registered' => 'PayID Issue/Dispute',
    'Mobile PayID already registered' => 'PayID Issue/Dispute',
    'IMT Enquiry/Disputes' => 'Payments'
  };

  private static final Map<String, String> SUB_TYPE_TO_TYPE_MAP_DIGITAL_FRAUD_QUEUE = new Map<String, String>{
    'Suspect ConnectID Fraud' => 'Profile'
  };

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
        c.Transaction_Status__c ==
        GetHelpConstants.TRANSACTION_STATUS_PENDING ||
        c.Transaction_Status__c == GetHelpConstants.TRANSACTION_PENDING
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
        rec.RecordTypeId == RTCase.cardDispute &&
        rec.Origin == 'App' &&
        (rec.Date_Posted__c == null ||
        rec.Date_Posted__c.year() == 1970)
      ) {
        rec.Submitted__c = false;
      }
    }
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @return Queue Id
   */
  private static ID getOwnerId(Case rec) {
    if (
      CheckCaseRecordType.isCardDispute(rec) ||
      CheckCaseRecordType.isAtmDispute(rec)
    ) {
      return getCardDisputeOwnerId(rec);
    } else if (CheckCaseRecordType.isImtDispute(rec)) {
      return getOwnerIdForImt(rec);
    } else if (
      rec.Dispute_Reason__c == UNAUTHORISED_TRANSACTION &&
      !CheckCaseRecordType.isDirectDebitDispute(rec)
    ) {
      return QueryQueue.digitalFraudQueue.Id;
    } else {
      return QueryQueue.supportCoachQueue.Id;
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
    for (Case record : records) {
      if (CheckCaseRecordType.isAEM(record) == false) {
        continue;
      }
      if (record.IDR_Product_Category__c == HOME_LOANS_PRODUCT_CATEGORY) {
        record.OwnerId = BOH_COACH_QUEUE.Id;
        record.Queue__c = BOH_COACH_QUEUE.Name;
      } else {
        record.OwnerId = COACH_QUEUE.Id;
        record.Queue__c = COACH_QUEUE.Name;
      }
    }
  }

  /**
   * @description method to call the Case assignment rules for general enquiry cases
   * Will assign those cases to corresponding queue
   * @param records List<Case> to be checked.
   */
  public static void assignGeneralEnquiryCases(List<Case> records) {
    for (Case record : records) {
      if (!CheckCaseRecordType.isGeneralEnquiry(record)) {
        continue;
      }
      String recordSubType = record.Sub_Type__c;
      String recordType = record.Type;
      if (SUB_TYPE_TO_TYPE_MAP_SUPPORT_COACH.get(recordSubType) == recordType) {
        record.OwnerId = SUPPORT_COACH_QUEUE.Id;
        record.Queue__c = SUPPORT_COACH_QUEUE.Name;
        continue;
      }
      if (
        SUB_TYPE_TO_TYPE_MAP_DIGITAL_FRAUD_QUEUE.get(recordSubType) ==
        recordType
      ) {
        record.OwnerId = QueryQueue.digitalFraudQueue.Id;
        record.Queue__c = QueryQueue.digitalFraudQueue.Name;
      }
    }
  }

  /**
   * @description to deterine if record's dispute reason belong to matching support queue
   * Will return true of Record.Dispute reason is one of from SUPPORT_COACH_DISPUTE_REASONS
   * @param disputeReason String.
   * @return true if the case dispute reason is any from SUPPORT_COACH_DISPUTE_REASONS
   */
  private static boolean isSupportCoachDisputeReasons(String disputeReason) {
    return SUPPORT_COACH_DISPUTE_REASONS.contains(disputeReason);
  }

  /**
   * @description to deterine if record's dispute reason belong to matching card sispute fraud or general queue
   * Will return true of Record.Dispute reason is one of from CARD_DISPUTE_FRAUD_REASONS
   * @return true if the case dispute reason is any from CARD_DISPUTE_FRAUD_REASONS
   * @param disputeReason String.
   */
  private static boolean isCardDisputeFraudDisputeReasons(
    String disputeReason
  ) {
    return CARD_DISPUTE_FRAUD_REASONS.contains(disputeReason);
  }

  /**
   * @description method to run the Case assignment rules conditions for Card or Atm case
   * @param rec case record
   * @return Queue Id
   */
  private static Id getCardDisputeOwnerId(Case rec) {
    if (isCardDisputeFraudDisputeReasons(rec.Dispute_Reason__c)) {
      return QueryQueue.cardDisputeFraudQueue.Id;
    } else {
      return QueryQueue.cardDisputeGeneralQueue.Id;
    }
  }

  /**
   * @description method to run the Case assignment rules conditions for IMT_Dispute case
   * @param rec case record
   * @return Queue Id
   */
  private static Id getOwnerIdForImt(Case rec) {
    if (isSupportCoachDisputeReasons(rec.Dispute_Reason__c)) {
      return QueryQueue.supportCoachQueue.Id;
    } else {
      return QueryQueue.digitalFraudQueue.Id;
    }
  }
}
