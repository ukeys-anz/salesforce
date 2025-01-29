/**
 * @author       : Advait Yermalkar
 * @since        : 05/2024
 * @description  :
 **/
public with sharing class CommercialA2ZReviewActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description This method will update Customer lookup when the A-Z review gets created from Opportunity/Lead having customer linked to it.
   * @name setCustomerOnA2ZReview
   * @param records from the trigger
   */
  public static void setCustomerOnA2ZReview(List<A_Z_Review__c> records) {
    try {
      Map<Id, Id> mapOfCustomerWithLeadAndOpp = new Map<Id, Id>();
      mapOfCustomerWithLeadAndOpp.putAll(
        CCRMA2ZReviewActionHelper.fetchOpportunities(records)
      );
      mapOfCustomerWithLeadAndOpp.putAll(
        CCRMA2ZReviewActionHelper.fetchLeads(records)
      );
      CCRMA2ZReviewActionHelper.associateReviewsToCustomer(
        records,
        mapOfCustomerWithLeadAndOpp
      );
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw new CustomException(e.getMessage());
    }
  }

  /**
   * @description This method will update Customer lookup when the A-Z review gets created from Opportunity having customer linked to it.
   * @name performRedaction
   * @param records from the trigger
   */
  public static void performRedaction(List<A_Z_Review__c> records) {
    try {
      TextUtils.RecordListWrapper wrapperDataCCRM = TextUtils.checkRecordTypeRedactionMethod(
        records,
        new List<Id>{ CCRMConstants.AZ_REVIEW_RT_ID }
      );
      TextUtils.maskSObjectDataANZExtended(
        wrapperDataCCRM.dcrmRecordList,
        'Name'
      );
      TextUtils.maskSObjectDataANZExtended(
        wrapperDataCCRM.dcrmRecordList,
        'Business_Details__c'
      );
      TextUtils.maskSObjectDataANZExtended(
        wrapperDataCCRM.dcrmRecordList,
        'Personal_Banking__c'
      );
      TextUtils.maskSObjectDataANZExtended(
        wrapperDataCCRM.dcrmRecordList,
        'Transaction_Banking__c'
      );
      TextUtils.maskSObjectDataANZExtended(
        wrapperDataCCRM.dcrmRecordList,
        'Borrowing_OFI_Relationship__c'
      );
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw new CustomException(e.getMessage());
    }
  }

  /**
   * @description : It will update the completed date as soon as status changes to 'Completed'.
   * @name : updateCompletedDate
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */

  public static void updateCompletedDate(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    try {
      for (A_Z_Review__c azRecord : records) {
        A_Z_Review__c oldRecord = oldMap?.get(azRecord.Id);
        if (azRecord.Status__c == oldRecord?.Status__c) {
          continue;
        }
        if (azRecord.Status__c != CCRMConstants.STATUS_COMPLETED) {
          continue;
        }
        azRecord.Completed_Date__c = Date.today();
      }
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw new CustomException(e.getMessage());
    }
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void restrictImagesInRichTextFields(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.A_Z_Review__c.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on A-Z Review', e).save();
    }
  }
}
