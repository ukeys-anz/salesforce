trigger UserProvisioningRequestTrigger on User_Provisioning_Request__c(
  after insert
) {
  UserProvisioningRequestHandler handler = new UserProvisioningRequestHandler();
}
