trigger IDRLetterApprovalTrigger on IDR_Letter_Approval__c (
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
	IDRLetterApprovalTriggerHandler handler = new IDRLetterApprovalTriggerHandler();
}