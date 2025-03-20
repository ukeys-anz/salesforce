trigger CircleOfInfluenceTrigger on Circle_Of_Influence__c(
  before insert,
  before update
) {
  CommercialCOITriggerHandler commercialCOIHandler = new CommercialCOITriggerHandler();
}
