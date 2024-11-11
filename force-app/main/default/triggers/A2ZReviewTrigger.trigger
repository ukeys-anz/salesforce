trigger A2ZReviewTrigger on A_Z_Review__c(before insert, before update) {
  CommercialA2ZReviewTriggerHandler commercialHandler = new CommercialA2ZReviewTriggerHandler();
}
