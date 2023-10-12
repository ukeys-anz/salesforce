/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description ML_UserActions is class to handle onboarding of user and creating/updating user territory record.
 */
public class MLCRMUserTerritorySetupHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadTriggerHandler
   */
  public MLCRMUserTerritorySetupHandler() {
    super();
  }

  /**
   * @description onAfterInsert: After Insert actions on Lead.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    MLCRMUserTerritorySetupActions.subscribeUserRecord(records);
  }
}
