trigger CampaignFlexFieldTrigger on Campaign_Flex_Field__c(before insert) {
  CampaignFlexFieldTriggerHandler handler = new CampaignFlexFieldTriggerHandler();
}
