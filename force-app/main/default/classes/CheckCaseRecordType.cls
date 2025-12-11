/**
 * @author Farid Masjedi
 * @since 11/2022
 * @description to check what is the recordType of a specific case
 * @group Utils
 */
public with sharing class CheckCaseRecordType {
  public static final Set<Id> ENTITLEMENT_RT_IDS = new Set<Id>{
    RTCase.generalInquiry,
    RTCase.customerFeedback,
    RTCase.kycQa,
    RTCase.confirmationOfPayee,
    RTCase.atmDispute,
    RTCase.cardDispute,
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.nppDispute,
    RTCase.bpayDispute
  };

  public static final Set<Id> FRAUD_RT_IDS = new Set<Id>{
    RTCase.fraud,
    RTCase.identity,
    RTCase.recipientMule,
    RTCase.scam
  };

  public static final Set<Id> DISPUTE_RT_IDS = new Set<Id>{
    RTCase.atmDispute,
    RTCase.bankPostDispute,
    RTCase.cardDispute,
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.nppDispute,
    RTCase.imtDispute,
    RTCase.bpayDispute,
    RTCase.payToDispute
  };

  public static final Set<Id> ANZX_RT_IDS = new Set<Id>{
    //fraud record types
    RTCase.fraud,
    RTCase.identity,
    RTCase.recipientMule,
    RTCase.scam,
    RTCase.kycQa,
    //dispute redcord types
    RTCase.atmDispute,
    RTCase.cardDispute,
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.nppDispute,
    RTCase.imtDispute,
    RTCase.bpayDispute,
    //other record types
    RTCase.generalInquiry,
    RTCase.anzxComplaint,
    RTCase.customerFeedback,
    RTCase.accountClosure,
    RTCase.falseCustomerProfile,
    RTCase.profileUpdate,
    RTCase.signAuth
  };

  public static final Set<Id> VALID_RTS_TO_CREATE_EXT_CASE_STATUS = new Set<Id>{
    RTCase.directDebitDispute,
    RTCase.directEntryDispute,
    RTCase.bpayDispute,
    RTCase.payToDispute
  };

  /**
   * @description isValidCaseToCreateExtCaseStatus checks if record type is of ANZ Plus type and supoprts external Case status creation.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type supports external Case status creation false otherwise.
   */
  public static Boolean isValidCaseToCreateExtCaseStatus(Case record) {
    return VALID_RTS_TO_CREATE_EXT_CASE_STATUS.contains(record?.RecordTypeId) ||
      (record.RecordTypeId == RTCase.nppDispute &&
      record.Dispute_Reason__c ==
      GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION);
  }

  /**
   * @description isANZPlusCaseType checks if record type is of ANZ Plus type.
   * As this Trigger will be used across various teams we identify case record based on ANZ Plus record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of ANZ Plus type false otherwise.
   */
  public static Boolean isANZPlusCaseType(Case record) {
    return ANZX_RT_IDS.contains(record?.RecordTypeId);
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
   * @description Check if an entitlement is applicable
   * @param record The case record to check
   * @return if the case is eligible for entitlement
   */
  public static Boolean isEntitlementEnabled(Case record) {
    return ENTITLEMENT_RT_IDS.contains(record.RecordTypeId);
  }
  /**
   * @description Check if a case is Unauthenticated Enquiry Case
   * @param record The case record to check
   * @return true if the case is a Unauthenticated Enquiry Case
   */
  public static Boolean isUnauthenticatedEnquiry(Case record) {
    return RTCase.generalInquiryCmos == record.RecordTypeId;
  }

  /**
   * @description Check if a case is General Enquiry Case
   * @param record The case record to check
   * @return true if the case is a General Enquiry Case
   */
  public static Boolean isGeneralEnquiry(Case record) {
    return RTCase.generalInquiry == record.RecordTypeId;
  }

  /**
   * @description Check if a case is ANZ Plus Complaint Case
   * @param record The case record to check
   * @return true if the case is a ANZ Plus Complaint Case
   */
  public static Boolean isANZPlusComplaint(Case record) {
    return RTCase.anzxComplaint == record?.RecordTypeId;
  }

  /**
   * @description Check if a case is False Customer Profile Case
   * @param record The case record to check
   * @return true if the case is a False Customer Profile Case
   */
  public static Boolean isFalseCustomerProfile(Case record) {
    return RTCase.falseCustomerProfile == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Non Customer Complaint Case
   * @param record The case record to check
   * @return true if the case is a Non Customer Complaint Case
   */
  public static Boolean isNonCustomerComplaint(Case record) {
    return RTCase.nonCustomerComplaint == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Complaint case
   * @param record The case record to check
   * @param oldCase old case
   * @return if the case is a Complaint case
   */
  public static Boolean isComplaint(Case record, Case oldCase) {
    if (
      record.RecordTypeId == RTCase.anzxComplaint &&
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
      record.RecordTypeId == RTCase.nonCustomerComplaint &&
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
      record.RecordTypeId == RTCase.accountClosure &&
      (oldCase == null ||
      record.Type != oldCase.Type)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Credit Referral case
   * @param record The case record to check
   * @param oldCase old case
   * @return if the case is a Credit Referral case
   */
  public static Boolean isCreditReferral(Case record, Case oldCase) {
    if (
      record.RecordTypeId == RTCase.creditReferral &&
      (oldCase == null ||
      record.Type != oldCase.Type)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Check if a case is Non Fraud NPP Case
   * @param record The case record to check
   * @return true if the case is a Non Fraud NPP Case
   */
  public static Boolean isNPPNonFraudDispute(Case record) {
    return record.RecordTypeId == RTCase.nppDispute &&
      record.Dispute_Reason__c !=
      GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION;
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

  /**
   * @description Check if a case is IMT_Dispute Case
   * @param record The case record to check
   * @return true if the case is a IMT_Dispute Case
   */
  public static Boolean isImtDispute(Case record) {
    return RTCase.imtDispute == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Card_Dispute Case
   * @param record The case record to check
   * @return true if the case is a Card_Dispute Case
   */
  public static Boolean isCardDispute(Case record) {
    return RTCase.cardDispute == record.RecordTypeId;
  }

  /**
   * @description Check if a case is ATM_Dispute Case
   * @param record The case record to check
   * @return true if the case is a ATM_Dispute Case
   */
  public static Boolean isAtmDispute(Case record) {
    return RTCase.atmDispute == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Direct_Debit_Dispute Case
   * @param record The case record to check
   * @return true if the case is a Direct_Debit_Dispute Case
   */
  public static Boolean isDirectDebitDispute(Case record) {
    return RTCase.directDebitDispute == record.RecordTypeId;
  }

  /**
   * @description Check if a case is Bank_Post_Dispute Case
   * @param record The case record to check
   * @return true if the case is a Bank_Post_Dispute Case
   */
  public static Boolean isBankPostDispute(Case record) {
    return RTCase.bankPostDispute == record.RecordTypeId;
  }
}
