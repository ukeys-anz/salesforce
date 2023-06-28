trigger COBApplicationTrigger on CustomerOnboardingApplication__c(
  after update
) {
  COBApplicationTriggerHandler handler = new COBApplicationTriggerHandler();
}
