trigger LetterApprovalTrigger on IDR_Letter_Approval__c(
  after insert,
  after update
) {
  LetterApprovalTriggerHandler handler = new LetterApprovalTriggerHandler();
}
