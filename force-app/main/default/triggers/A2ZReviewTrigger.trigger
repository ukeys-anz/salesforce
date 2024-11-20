trigger A2ZReviewTrigger on A_Z_Review__c(before insert, before update) {
  CCRMA2ZReviewTriggerHandler handler = new CCRMA2ZReviewTriggerHandler();
}
