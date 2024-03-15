/**
 * @author CMOS
 * @since  03/2024
 * @description IDRCaseActionsHelper is class to handle all the IDR (Internal Dispute Resolution) Actions
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseActionsHelper {
  /**
   * @description Populate modified date when the picklist value is updated
   * @param record  from the trigger
   * @param oldCaserecord Old Record from the trigger
   * @return DateTime returning DateTime value
   */
  public static DateTime populateHardshipUpdateDate(
    Case record,
    Case oldCaserecord
  ) {
    if (
      record.IDR_Is_Hardship_Resolution_Letter_Sent__c ==
      oldCaserecord.IDR_Is_Hardship_Resolution_Letter_Sent__c
    ) {
      return null;
    }
    return DateTime.now();
  }

  /**
   * @description populateOldOwnerID(record, oldRecord) method handles the following
   * 1. Assigns old owner to Previous Case Owner
   * 2. Assigns the date/time to Date Case Allocated to CM.
   * @param record from the trigger
   * @param oldRecord old Value of the trigger record.
   * @return Id
   */
  public static Id populateOldOwnerID(Case record, Case oldRecord) {
    if (record.OwnerId == oldRecord.OwnerId) {
      return record.Previous_Case_Owner__c;
    }
    ID oldOwner = oldRecord.OwnerId;
    if (oldOwner.getSObjectType() == Group.SObjectType) {
      return null;
    } else {
      return oldOwner;
    }
  }

  /**
   * @description populateDateCaseAllocatedToCM(record, oldRecord) method handles the following
   * 1. Assigns old owner to Previous Case Owner
   * 2. Assigns the date/time to Date Case Allocated to CM.
   * @param record from the trigger
   * @param oldRecord old Value of the trigger record.
   * @return DateTime
   */
  public static DateTime populateDateCaseAllocatedToCM(
    Case record,
    Case oldRecord
  ) {
    if (record.OwnerId == oldRecord.OwnerId) {
      return record.Date_Case_allocated_to_CM__c;
    }
    ID newOwner = record.OwnerId;
    if (newOwner.getSObjectType() == User.SObjectType) {
      return DateTime.now();
    } else {
      return null;
    }
  }

  public static DateTime populateAfcaRegistrationResponseDate(
    Case oldRecord,
    Case newRecord
  ) {
    if (
      oldRecord.IDR_AFCA_Registration_Response_Provided__c ==
      newRecord.IDR_AFCA_Registration_Response_Provided__c
    ) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }

    if (!newRecord.IDR_AFCA_Registration_Response_Provided__c) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }
    return DateTime.now();
  }
}
