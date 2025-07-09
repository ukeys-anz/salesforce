/**
 * @author Ayushi Gupta
 * @since  04/06/2025
 * @description Opp Team Member trigger handler for CCRM
 */
public with sharing class CommercialOppTeamMemberTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialOppTeamMemberTriggerHandler
   */
  public CommercialOppTeamMemberTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert: After Insert actions on Opp Team Member.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    CommercialOppTeamMemberActions.createAppFormShareRecords(records);
  }

  /**
   * @description onAfterDelete to perform processing during the after delete phase
   */
  public override void onAfterDelete() {
    CommercialOppTeamMemberActions.deleteAppFormShareRecords(records);
  }
}
