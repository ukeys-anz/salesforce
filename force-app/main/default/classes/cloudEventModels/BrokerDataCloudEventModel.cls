/**
 * @author Supriya
 * @since  08/Feb
 * @description Wrapper Class for Inserting brokerdata into Broker ORG
 * @runTests  BrokerDataCloudEventTest
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions, PMD.NcssConstructorCount'
)
public virtual with sharing class BrokerDataCloudEventModel extends BrokerCloudEventModel {
  public BrokerDataCloudEventModel(
    Contact contact,
    List<BrokerDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Broker_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'Contact/' + contact.Name;
    this.ce_partitionkey = 'External_Id__c/' + contact.External_Id__c;
    this.ce_sequence = contact.OCV_Event_Version__c;
    this.ce_dataschema =
      System.Label.ANZX_Broker_Event_Proto_Data_Schema + '#brokerdata';
    this.ce_xtargets = 'Broker/' + contact.External_Id__c;
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
}