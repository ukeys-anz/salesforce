trigger CampaignDocumentTrigger on Campaign_Document__c(before insert) {
  CampaignDocumentTriggerHandler handler = new CampaignDocumentTriggerHandler();
}
