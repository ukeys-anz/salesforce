/**
 * @author       : Advait Yermalkar
 * @since        : 05/2024
 * @description  : A2ZReviewTriggerHandler is the handler class for A2ZReview Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialA2ZReviewTriggerHandler extends Lib_TriggerHandler {
  private static final Id AZ_REVIEW_RT_ID = Schema.SObjectType.A_Z_Review__c.getRecordTypeInfosByDeveloperName()
    .get('Commercial_A_Z_Review')
    .getRecordTypeId();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name A2ZReviewTriggerHandler
   */
  public CommercialA2ZReviewTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    A_Z_Review__c recordA2ZReview = (A_Z_Review__c) record;
    return recordA2ZReview.RecordTypeId == AZ_REVIEW_RT_ID;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialA2ZReviewActions.updateCompletedDate(records, null);
    CommercialA2ZReviewActions.setCustomerOnA2ZReview(records);
    CommercialA2ZReviewActions.performRedaction(records);
    CommercialA2ZReviewActions.restrictImagesInRichTextFields(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialA2ZReviewActions.updateCompletedDate(
      (List<A_Z_Review__c>) records,
      (Map<Id, A_Z_Review__c>) oldMap
    );
    CommercialA2ZReviewActions.performRedaction(records);
    CommercialA2ZReviewActions.restrictImagesInRichTextFields(
      (List<A_Z_Review__c>) records,
      (Map<Id, A_Z_Review__c>) oldMap
    );
  }
}
