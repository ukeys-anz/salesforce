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
  before delete
) {
  CaseTriggerHandler handler = new CaseTriggerHandler();
  COBCaseTriggerHandler cobhandler = new COBCaseTriggerHandler();
  AutoKYCQACaseTriggerHandler kycQaHandler = new AutoKYCQACaseTriggerHandler();
  DisputesCaseTriggerHandler disputesHandler = new DisputesCaseTriggerHandler();
  BrokerEnquiryCaseTriggerHandler brokerEnquiryHandler = new BrokerEnquiryCaseTriggerHandler();
}
