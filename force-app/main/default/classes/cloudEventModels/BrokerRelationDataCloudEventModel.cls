/**
 * @author Saurabh
 * @since  28-Feb-2025
 * @description Wrapper Class for Inserting broker relation data into Broker ORG
 */
public with sharing class BrokerRelationDataCloudEventModel extends BrokerCloudEventModel {
  /**
   * @description To create wrapper instance of payload for inserting broker relation data into Broker ORG
   * @param payload master nodes of rbm for add / delete event
   * @param action action type to perform at broker org i.e add / delete
   */
  public BrokerRelationDataCloudEventModel(
    List<BrokerRelationDataCloudEventModel.MasterNode> payload,
    String action
  ) {
    super();
    this.ce_type = System.Label.ANZX_Broker_Relation_event_ce_type + action;
    this.ce_source = 'broker.salesforce.anzx';
    this.ce_subject = 'BrokerRelation/' + DateTime.now();
    this.ce_partitionkey = 'BR/' + DateTime.now();
    this.ce_traceparent = '';
    this.ce_data = new BrokerCloudEventDataModel(payload);
  }
}
