/**
 * @author Naman Garg
 * @since April'25
 * @description CommercialCppTriggerHandler is the handler class for ContactPointPhone Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class CommercialCppTriggerHandler extends Lib_TriggerHandler {
  private static final ContactPointObjectActionsRepository PHONE_REPOSITORY = (ContactPointObjectActionsRepository) Lib_InstanceProvider.forType(
    ContactPointObjectActionsRepository.class
  );

  private static final UserInfoRepository USERINFO_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  public static final Boolean IS_COMMERCIAL_USER = USERINFO_REPO.checkProfile(
    'ANZ CCRM Standard User'
  );

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialCppTriggerHandler
   */
  public CommercialCppTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Contact point Phone records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    ContactPointPhone cppRecord = (ContactPointPhone) record;
    return IS_COMMERCIAL_USER && !PHONE_REPOSITORY.isCustomValidationsSkipped();
  }

  /**
   * @description onBeforeInsert to handle Before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CommercialCppActions.validateUsageType(records);
  }

  /**
   * @description onBeforUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialCppActions.preventEdit(
      records,
      (Map<Id, ContactPointPhone>) oldMap
    );
  }
}
