trigger LetterApprovalTrigger on Letter_Approval__c (
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
	LetterApprovalTriggerHandler handler = new LetterApprovalTriggerHandler();
}