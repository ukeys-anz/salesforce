/**
 * @author Farid Masjedi
 * @since 11/2022
 * @description to check what is the recordType of a specific case
 * @group Utils
 */
public with sharing class CheckCaseRecordType {
  public static final Set<Id> FRAUD_RT_IDS = new Set<Id>{
    GetHelpConstants.FRAUD_RT_ID,
    GetHelpConstants.IDENTITY_RT_ID,
    GetHelpConstants.RECIPIENT_MULE_RT_ID,
    GetHelpConstants.SCAM_RT_ID,
    GetHelpConstants.KYCQA_RT_ID
  };

  public static final Set<Id> DISPUTE_RT_IDS = new Set<Id>{
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
    GetHelpConstants.NPP_DISPUTE_RT_ID,
    GetHelpConstants.BPAY_DISPUTE_RT_ID
  };

  /**
   * @description isANZPlusCaseType checks if record type is of ANZ Plus type.
   * As this Trigger will be used across various teams we identify case record based on ANZ Plus record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of ANZ Plus type false otherwise.
   */
  public static Boolean isANZPlusCaseType(Case record) {
    if (
      FRAUD_RT_IDS.contains(record.RecordTypeId) ||
      record.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID ||
      record.RecordTypeId == GetHelpConstants.BUG_RT_ID ||
      record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID ||
      record.RecordTypeId == GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID ||
      DISPUTE_RT_IDS.contains(record.RecordTypeId)
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if a case is Fraud case
   * @param record The case record to check
   * @param oldCase old case
   * @return if the case is a Fraud case
   */
  public static Boolean isFraud(Case record, Case oldCase) {
    if (
      FRAUD_RT_IDS.contains(record.RecordTypeId) &&
      String.isNotBlank(record.Type) &&
      (oldCase == null ||
      record.Type != oldCase.Type ||
      record.RecordTypeId != oldCase.RecordTypeId)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Dispute Case
   * @param record The case record to check
   * @return if the case is a Dispute Case
   */
  public static Boolean isDispute(Case record) {
    return DISPUTE_RT_IDS.contains(record.RecordTypeId);
  }

  /**
   * @description Check if a case is Unauthenticated Enquiry Case
   * @param record The case record to check
   * @return true if the case is a Unauthenticated Enquiry Case
   */
  public static Boolean isUnauthenticatedEnquiry(Case record) {
    return GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID ==
      record.RecordTypeId;
  }

  /**
   * @description Check if a case is General Enquiry Case
   * @param record The case record to check
   * @return true if the case is a General Enquiry Case
   */
  public static Boolean isGeneralEnquiry(Case record) {
    return GetHelpConstants.GENERAL_INQUIRY_RT_ID == record.RecordTypeId;
  }

  /**
   * @description Check if a case is ANZ Plus Complaint Case
   * @param record The case record to check
   * @return true if the case is a ANZ Plus Complaint Case
   */
  public static Boolean isANZPlusComplaint(Case record) {
    return GetHelpConstants.COMPLAINT_RT_ID == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Non Customer Complaint Case
   * @param record The case record to check
   * @return true if the case is a Non Customer Complaint Case
   */
  public static Boolean isNonCustomerComplaint(Case record) {
    return GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Complaint case
   * @param record The case record to check
   * @param oldCase old case
   * @return if the case is a Complaint case
   */
  public static Boolean isComplaint(Case record, Case oldCase) {
    if (
      record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID &&
      (oldCase == null ||
      record.Type != oldCase.Type)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is an ANZx Non Customer Complaint case
   * @param record The case record to check
   * @param oldCaseMap old case map
   * @return if the case is an ANZx Non Customer Complaint case
   */
  public static Boolean isANZxNonCustomerComplaint(
    Case record,
    Map<Id, Case> oldCaseMap
  ) {
    if (
      record.RecordTypeId == GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID &&
      String.isNotBlank(record.Type) &&
      record.ANZx_Customer__c &&
      (oldCaseMap == null ||
      record.Type != oldCaseMap.get(record.Id).Type ||
      record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Account Closure case
   * @param record The case record to check
   * @param oldCase old case
   * @return if the case is a Complaint case
   */
  public static Boolean isAccountClosure(Case record, Case oldCase) {
    if (
      record.RecordTypeId == GetHelpConstants.ACCOUNT_CLOSURE_RT_ID &&
      (oldCase == null ||
      record.Type != oldCase.Type)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is created by AEM or no -
   * - means if the recordType is unauthenticated enquiry, Origin is ANZ plus Web and ANZx_Customer__c is true
   * @param record The case record to check
   * @return true if the case is a Case created by AEM web form
   */
  public static Boolean isAEM(Case record) {
    return isUnauthenticatedEnquiry(record) &&
      record.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN &&
      record.ANZx_Customer__c;
  }
}
