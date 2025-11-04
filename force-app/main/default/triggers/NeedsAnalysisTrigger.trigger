trigger NeedsAnalysisTrigger on Needs_Analysis__c(
  before insert,
  before update
) {
  CommercialNeedsAnalysisTriggerHandler commercialHandler = new CommercialNeedsAnalysisTriggerHandler();
}
