/**
 * @description       : Wrapper Class for Updating Case into Broker ORG
 * @author            : Smruti Khobragade | Salesforce
 * @last modified on  : 12-01-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/

public virtual with sharing class BrokerRequestHelpCaseDataCloudEventModel extends BrokerRequestHelpCaseCloudEventModel {
  /**
   * @description parameterized constructor for creating the header for Case cloud event
   * @author Smruti Khobragade | 11-2024
   * @param record Case
   * @param payload
   * @param action
   **/
  public BrokerRequestHelpCaseDataCloudEventModel(
    Case record,
    List<BrokerRequestHelpCaseDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Case_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'Case/' + record.CaseNumber;
    this.ce_partitionkey = 'External_Case_ID__c/' + record.External_Case_ID__c;
    this.ce_dataschema = System.Label.ANZX_Broker_Event_Proto_Data_Schema;
    this.ce_xtargets = 'Broker/' + record.External_Case_ID__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerRequestHelpCaseCloudEventDataModel(payload);
  }
}
