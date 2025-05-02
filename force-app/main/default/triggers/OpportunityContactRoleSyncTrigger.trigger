trigger OpportunityContactRoleSyncTrigger on Opportunity_Contact_Role_Sync__c(
  after insert,
  after update,
  after delete
) {
  OpportunityContactRoleSyncTriggerHandler handler = new OpportunityContactRoleSyncTriggerHandler();
}
