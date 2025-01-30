trigger OpportunityContactRoleTrigger on OpportunityContactRole(
  before insert,
  before update,
  before delete
) {
  OpportunityContactRoleTriggerHandler handler = new OpportunityContactRoleTriggerHandler();
}
