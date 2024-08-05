/**
 * @description Wrapper Class for Inserting Account into Broker ORG
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-05-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/

public virtual with sharing class CustomerDataCloudEventModel extends BrokerCloudEventModel {
  /**
   * @description parameterized constructor for creating the header for customer cloud event
   * @author Madhuri Edke | 07-18-2024
   * @param record
   * @param payload
   * @param action
   **/
  public CustomerDataCloudEventModel(
    Account record,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Customer_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'Account/' + record.Name;
    this.ce_partitionkey = 'External_Id__c/' + record.External_Id__c;
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema + '#customerdata';
    this.ce_xtargets = 'Broker/' + record.External_Id__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
}
