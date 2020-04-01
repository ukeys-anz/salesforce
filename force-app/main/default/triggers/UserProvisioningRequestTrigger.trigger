trigger UserProvisioningRequestTrigger on User_Provisioning_Request__c(
  before insert,
  before update,
  after insert,
  after update
) {
  UserProvisioningRequestHandler handler = new UserProvisioningRequestHandler();
}
