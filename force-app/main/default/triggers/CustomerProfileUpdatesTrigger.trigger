trigger CustomerProfileUpdatesTrigger on Customer_Profile_Updates__c(
  after update
) {
  AutoKYCQACustomerUpdateTriggerHandler kycQaCustomerProfileUpdateHandler = new AutoKYCQACustomerUpdateTriggerHandler();
}
