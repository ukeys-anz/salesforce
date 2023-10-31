//TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
trigger COBApplicationTrigger on CustomerOnboardingApplication__c(
  after update
) {
  COBApplicationTriggerHandler handler = new COBApplicationTriggerHandler();
}
