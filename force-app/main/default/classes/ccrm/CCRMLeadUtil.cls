/**
 * @author Mairaj Haider
 * @since  07/2022
 * @group CCRM (Commercial CRM)
 * @description Utility class for CCRM Lead
 */
public with sharing class CCRMLeadUtil {
  @TestVisible
  static final String EXPIRY_DATE_MISSING_ERROR_MESSAGE = 'EXPIRY DATE IS MISSING';
  @TestVisible
  static final String ADOBE_LEAD_OWNER_MISSING_ERROR_MESSAGE = 'CCRM-VAL-13: BANKER DOES NOT EXIST IN CRM';
  @TestVisible
  static final String UNICA_LEAD_OWNER_MISSING_ERROR_MESSAGE = 'BANKER DOES NOT EXIST IN CRM';
  /**
   * @description Check if record type is of CCRM Lead type.
   * @name isCCRMLeadType
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of CCRM Lead type otherwise false.
   */
  public static Boolean isCCRMLeadType(Lead record) {
    if (record.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if this Lead record is re-assigned to a different Lead Owner.
   * @name isLeadOwnerChanged
   * @param record lead record
   * @param oldRec old lead record from trigger
   * @return `Boolean` True if the Lead Owner is updated otherwise false.
   */
  public static Boolean isLeadOwnerChanged(Lead record, Lead oldRec) {
    if (oldRec != null && record.OwnerId != oldRec.OwnerId) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if this Lead record has updated status to Completed
   * @name isLeadOwnerChanged
   * @param record lead record
   * @param oldRec old lead record from trigger
   * @return `Boolean` True if the Lead Owner is updated otherwise false.
   */
  public static Boolean isLeadStatusChanged(Lead record, Lead oldRec) {
    if (oldRec != null && record.Status != oldRec.Status) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if user is ADOBE/UNICA integration user
   * @name isIntegrationUser
   * @return `Boolean` True if user is integration user
   */
  public static Boolean isIntegrationUser() {
    if (
      UserInfo.getUserName()
        .startsWithIgnoreCase(CCRMConstants.INTEGRATION_USER_UNICA) ||
      UserInfo.getUserName()
        .startsWithIgnoreCase(CCRMConstants.INTEGRATION_USER_ADOBE)
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if Lead is from UNICA
   * @name isUnicaLead
   * @param record The lead record that needs to be checked
   * @return `Boolean` True if the lead originator is Unica, otherwise return false
   */
  public static Boolean isUnicaLead(Lead record) {
    return isCCRMLeadType(record) &&
      record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA;
  }

  /**
   * @description Check if Lead is from ADOBE
   * @name isAdobeLead
   * @param record The lead record that needs to be checked
   * @return `Boolean` True if the lead originator is ADOBE, otherwise return false
   */
  public static Boolean isAdobeLead(Lead record) {
    return isCCRMLeadType(record) &&
      record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE;
  }

  /**
   * @description Validate lead originated from UNICA
   * @name validateUnicaLeads
   * @param records List of lead NEW records.
   */
  public static void validateUnicaLeads(List<Lead> records) {
    Set<Id> leadOwnerIds = new Set<Id>();
    for (Lead record : records) {
      if (isUnicaLead(record)) {
        if (record.Expiry_Date__c == null) {
          record.addError(EXPIRY_DATE_MISSING_ERROR_MESSAGE);
        } else {
          leadOwnerIds.add(record.OwnerId);
        }
      }
      validateUnicaLeadOwner(records, leadOwnerIds);
    }
  }

  /**
   * @description Validate lead originated from ADOBE
   * @name validateAdobeLeads
   * @param records List of lead NEW records.
   */
  public static void validateAdobeLeads(List<Lead> records) {
    Set<Id> leadOwnerIds = new Set<Id>();
    for (Lead record : records) {
      if (isAdobeLead(record)) {
        leadOwnerIds.add(record.OwnerId);
      }
    }
    validateAdobeLeadOwner(records, leadOwnerIds);
  }

  /**
   * @description Add validation error for UNICA and ADOBE leads if lead owner is integration user or owner is missing
   * @name validateUnicaLeadOwner
   * @param records List of lead NEW records.
   * @param leadOwnerIds Set of lead Ids
   */
  private static void validateUnicaLeadOwner(
    List<Lead> records,
    Set<Id> leadOwnerIds
  ) {
    if (!leadOwnerIds.isEmpty()) {
      Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id, Username FROM User WHERE Id IN :leadOwnerIds]
      );

      for (Lead record : records) {
        User user = userMap.get(record.OwnerId);
        //Add error if lead owner is integration user
        if (
          user != null &&
          user.Username.startsWithIgnoreCase(
            CCRMConstants.INTEGRATION_USER_UNICA
          )
        ) {
          record.addError(UNICA_LEAD_OWNER_MISSING_ERROR_MESSAGE);
        } else if (!userMap.containsKey(record.OwnerId)) {
          //Add error if lead owner don't exist in salesforce
          record.addError(UNICA_LEAD_OWNER_MISSING_ERROR_MESSAGE);
        }
      }
    }
  }

  /**
   * @description Add validation error for UNICA and ADOBE leads if lead owner is integration user or owner is missing
   * @name validateAdobeLeadOwner
   * @param records List of lead NEW records.
   * @param leadOwnerIds Set of lead Ids
   */
  private static void validateAdobeLeadOwner(
    List<Lead> records,
    Set<Id> leadOwnerIds
  ) {
    if (!leadOwnerIds.isEmpty()) {
      Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id, Username FROM User WHERE Id IN :leadOwnerIds]
      );

      for (Lead record : records) {
        User user = userMap.get(record.OwnerId);
        //Add error if lead owner is integration user
        if (
          user != null &&
          user.Username.startsWithIgnoreCase(
            CCRMConstants.INTEGRATION_USER_ADOBE
          )
        ) {
          record.addError(ADOBE_LEAD_OWNER_MISSING_ERROR_MESSAGE);
        } else if (!userMap.containsKey(record.OwnerId)) {
          //Add error if lead owner don't exist in salesforce
          record.addError(ADOBE_LEAD_OWNER_MISSING_ERROR_MESSAGE);
        }
      }
    }
  }
}
