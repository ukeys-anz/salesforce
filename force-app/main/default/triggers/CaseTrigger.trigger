/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 12-18-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/
trigger CaseTrigger on Case(
  before insert,
  before update,
  after insert,
  after update,
  before delete,
  after delete
) {
  CaseTriggerHandler handler = new CaseTriggerHandler();
  CreditReferralCaseTriggerHandler creditRefHandle = new CreditReferralCaseTriggerHandler();
  COBCaseTriggerHandler cobhandler = new COBCaseTriggerHandler();
  AutoKYCQACaseTriggerHandler kycQaHandler = new AutoKYCQACaseTriggerHandler();
  DisputesCaseTriggerHandler disputesHandler = new DisputesCaseTriggerHandler();
  AccountClosureCaseTriggerHandler accountClosureHandler = new AccountClosureCaseTriggerHandler();
  CaseGroupTriggerHandler caseGroupHandler = new CaseGroupTriggerHandler();
  ConfirmationOfPayeeCaseTriggerHandler copHandler = new ConfirmationOfPayeeCaseTriggerHandler();
  BrokerEnquiryCaseTriggerHandler brokerEnquiryHandler = new BrokerEnquiryCaseTriggerHandler();
  ProfileUpdateCaseTriggerHandler profileUpdateHandler = new ProfileUpdateCaseTriggerHandler();
  IDRCaseTriggerHandler idrHandler = new IDRCaseTriggerHandler();
  TrustMeCaseTriggerHandler trustMeHandler = new TrustMeCaseTriggerHandler();
  FalseCustomerProfileCaseTriggerHandler fcpHandler = new FalseCustomerProfileCaseTriggerHandler();
  FraudXCaseTriggerHandler fraudHandler = new FraudXCaseTriggerHandler();
  LendingCaseTriggerHandler lendingHandler = new LendingCaseTriggerHandler();
  CustomerComplaintCaseTriggerHandler customerComplaintHandler = new CustomerComplaintCaseTriggerHandler();
}
