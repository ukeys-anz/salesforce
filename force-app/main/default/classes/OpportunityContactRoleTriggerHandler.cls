/**
 * @description OpportunityContactRoleTriggerHandler is the handler class for Opportunity contact role Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author MLCRM Developer
 * @since 10/2024
 */
public with sharing class OpportunityContactRoleTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name OpportunityContactRoleTriggerHandler
   */
  public OpportunityContactRoleTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    OpportunityContactRoleActions.defaultRoleForMlOppContactRole(records);
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      records,
      null
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      records,
      (Map<Id, OpportunityContactRole>) oldMap
    );
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   * @name onBeforeDelete
   */
  public override void onBeforeDelete() {
    OpportunityContactRoleActions.restrictApplicantDeletion(records);
  }
}
