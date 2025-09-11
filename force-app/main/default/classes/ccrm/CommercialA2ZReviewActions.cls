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

  public static final String STATUS_COMPLETED = 'Completed';

  private static final CommercialA2ZReviewRepository A2ZREVIEW_REPO = (CommercialA2ZReviewRepository) Lib_InstanceProvider.forType(
    CommercialA2ZReviewRepository.class
  );

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
    TextUtils.maskSObjectDataANZExtended(records, 'Name');
    TextUtils.maskSObjectDataANZExtended(records, 'Business_Details__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Personal_Banking__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Transaction_Banking__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Borrowing_OFI_Relationship__c'
    );
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
      List<A_Z_Review__c> azRecordList = ListUtil.filter(records, oldMap)
        .changedTo(A_Z_Review__c.Status__c, STATUS_COMPLETED)
        .toList();

      ListUtil.setField(
        azRecordList,
        A_Z_Review__c.Completed_Date__c,
        Date.today()
      );
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

  /**
   * @description : sets business owner field to blank if populated
   * @name : setBusinessOwnerToBlank
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void setBusinessOwnerToBlank(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .isNotNull(A_Z_Review__c.Business_Owner__c)
      .changedTo(A_Z_Review__c.Existing_Business_Owner__c, 'No')
      .toList();
    ListUtil.setField(filteredRecords, A_Z_Review__c.Business_Owner__c, null);
  }

  /**
   * @description : sets business contact field to blank if populated
   * @name : setBusinessContactToBlank
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void setBusinessContactToBlank(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .isNotNull(A_Z_Review__c.Business_Contact__c)
      .changedTo(A_Z_Review__c.Existing_Business_Owner__c, 'Yes')
      .toList();
    ListUtil.setField(filteredRecords, A_Z_Review__c.Business_Contact__c, null);
  }

  /**
   * @description : sets business owner field to individual customer
   * @name : populateBusinessOwner
   * @param records List of A-Z records
   * @param oldMap Map of old A-Z records
   */
  public static void populateBusinessOwner(
    List<A_Z_Review__c> records,
    Map<Id, A_Z_Review__c> oldMap
  ) {
    List<A_Z_Review__c> filteredRecords = ListUtil.filter(records, oldMap)
      .changed(A_Z_Review__c.Business_Owner__c)
      .toList();
    Set<Id> accountIds = ListUtil.getIds(
      filteredRecords,
      A_Z_Review__c.Customer__c
    );
    List<A_Z_Review__c> individualCustomers = A2ZREVIEW_REPO.getA2ZRecordsAssociatedWithIndividualCustomers(
      accountIds
    );
    Set<Id> individualAccountIds = ListUtil.getIds(
      individualCustomers,
      A_Z_Review__c.Customer__c
    );
    setBusinessOwner(filteredRecords, individualAccountIds);
  }

  /**
   * @description : set business owner
   * @name : setBusinessOwner
   * @param records List of A-Z records
   * @param individualAccountIds set of account ids
   */
  public static void setBusinessOwner(
    List<A_Z_Review__c> records,
    Set<Id> individualAccountIds
  ) {
    for (A_Z_Review__c rec : records) {
      if (!individualAccountIds.contains(rec.Customer__c)) {
        continue;
      }
      rec.Existing_Business_Owner__c = 'Yes';
      rec.Business_Owner__c = rec.Customer__c;
      rec.Business_Contact__c = null;
    }
  }
}
