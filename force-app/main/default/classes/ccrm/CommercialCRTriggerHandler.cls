/**
 * @author Naman Garg
 * @since July'25
 * @description CommercialCRTriggerHandler is the handler class for customer relationship Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public class CommercialCRTriggerHandler extends Lib_TriggerHandler {
  private static final UserInfoRepository USER_INFO_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static Boolean isCommercialUser = USER_INFO_REPO.checkProfile(
    'ANZ CCRM Standard User'
  );

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialCRTriggerHandler
   */
  public CommercialCRTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return isCommercialUser;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialCRActions.restrictImagesInRichTextFields(records, null);
    TextUtils.maskSObjectDataANZExtended(records, 'Notes__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Other_Key_People__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Other_ANZ_Relationships__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Additional_Professional_Support__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Additional_Details__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Engagement_Topics__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Customer_Contact_Preferences__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Personal_Background__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Financial_Wealth_Background__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Business_Investment_Background__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Customer_Areas_of_Interest__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Priorities_and_Objectives__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Other_Account_Plan_Information__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'ANZ_Opportunities__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Competitive_Landscape_and_ANZ_Relative__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Other_Information__c');
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialCRActions.restrictImagesInRichTextFields(
      (List<Customer_Relationship__c>) records,
      (Map<Id, Customer_Relationship__c>) oldMap
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Notes__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Other_Key_People__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Other_ANZ_Relationships__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Additional_Professional_Support__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Additional_Details__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Engagement_Topics__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Customer_Contact_Preferences__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Personal_Background__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Financial_Wealth_Background__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Business_Investment_Background__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Customer_Areas_of_Interest__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Priorities_and_Objectives__c'
    );
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Other_Account_Plan_Information__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'ANZ_Opportunities__c');
    TextUtils.maskSObjectDataANZExtended(
      records,
      'Competitive_Landscape_and_ANZ_Relative__c'
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Other_Information__c');
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialCRActions.autoCreateInteraction(
      (List<Customer_Relationship__c>) records,
      (Map<Id, Customer_Relationship__c>) oldMap
    );
  }
}
