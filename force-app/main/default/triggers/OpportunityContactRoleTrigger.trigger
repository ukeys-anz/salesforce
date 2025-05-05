trigger OpportunityContactRoleTrigger on OpportunityContactRole(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
}
