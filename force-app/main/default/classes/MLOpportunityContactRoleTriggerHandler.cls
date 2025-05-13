/**
 * @description MLOpportunityContactRoleTriggerHandler is the handler class for Opportunity contact role Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author MLCRM Developer
 * @since 10/2024
 */
public with sharing class MLOpportunityContactRoleTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MLOpportunityContactRoleTriggerHandler
   */
  public MLOpportunityContactRoleTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.defaultRoleForOppContactRole(
      filteredOCRRecords
    );
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      filteredOCRRecords,
      null
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.insertOpportunityContactRoleSyncRecords(
      filteredOCRRecords
    );
  }

  /**
   * @description onAfterUpdate to handle after insert trigger actions.
   * @name onAfterUpdate
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.updateOpportunityContactRoleSyncRecords(
      filteredOCRRecords,
      (Map<Id, OpportunityContactRole>) oldMap
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      filteredOCRRecords,
      (Map<Id, OpportunityContactRole>) oldMap
    );
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   * @name onBeforeDelete
   */
  public override void onBeforeDelete() {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.restrictApplicantDeletion(filteredOCRRecords);
  }

  /**
   * @description onAfterDelete to handle after delete trigger actions.
   * @name onAfterDelete
   */
  public override void onAfterDelete() {
    List<OpportunityContactRole> filteredOCRRecords = OpportunityContactRoleActions.filteredRecords(
      records
    );
    OpportunityContactRoleActions.deleteOpportunityContactRoleSyncRecords(
      filteredOCRRecords
    );
  }
}
