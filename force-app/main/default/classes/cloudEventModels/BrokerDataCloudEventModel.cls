/**
 * @author Supriya
 * @since  08/Feb
 * @description Wrapper Class for Inserting brokerdata into Broker ORG
 * @runTests  BrokerDataCloudEventTest
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions, PMD.NcssConstructorCount'
)
public with sharing class BrokerDataCloudEventModel extends CloudEventModel {
  public BrokerDataCloudEventModel(
    Contact contact,
    List<MasterNode> payload,
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

  public class BrokerCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    public List<MasterNode> data { get; set; }
    public BrokerCloudEventDataModel(List<MasterNode> masterNodes) {
      this.data = masterNodes;
    }
  }

  /**
   * @description the model for master object to pass the source object data
   */
  public class MasterNode {
    public String sourceObjectExtId { get; set; }
    public String sourceObjectName { get; set; }
    public String sourceObjectParentExtId { get; set; }
    public String sourceObjectParentExtIdName { get; set; }
    public TargetNode targetObjects { get; set; }
  }
  /**
   * @description the model for building Target object data on which upsert should happen
   */
  public class TargetNode {
    public String extIdField { get; set; }
    public String extObjectName { get; set; }
    public List<ParentNode> parent { get; set; }
  }
  /**
   * @description the model for building Parent object data where we define the parent data
   */
  public class ParentNode {
    public String referenceField { get; set; }
    public String extId { get; set; }
    public String extIdField { get; set; }
    public String objectName { get; set; }
  }

  /**
   * @description the method to build the master object
   * @param brokerDataMap - the map of broker data
   * @return MasterObject - the master object
   */
  public static MasterNode buildMasterNode(Map<String, String> brokerDataMap) {
    ParentNode brokerParentNode = new ParentNode();
    brokerParentNode.extId = brokerDataMap.get('targetObjects_parent_extId');
    brokerParentNode.extIdField = brokerDataMap.get(
      'targetObjects_parent_extIdField'
    );
    brokerParentNode.objectName = brokerDataMap.get(
      'targetObjects_parent_objectName'
    );
    brokerParentNode.referenceField = brokerDataMap.get(
      'targetObjects_parent_referenceField'
    );

    TargetNode brokerTargetNode = new TargetNode();
    brokerTargetNode.extIdField = brokerDataMap.get('targetObjects_extIdField');
    brokerTargetNode.extObjectName = brokerDataMap.get(
      'targetObjects_extObjectName'
    );
    brokerTargetNode.parent = new List<ParentNode>{ brokerParentNode };

    MasterNode brokerMasterNode = new MasterNode();
    brokerMasterNode.sourceObjectExtId = brokerDataMap.get('sourceObjectExtId');
    brokerMasterNode.sourceObjectName = brokerDataMap.get('sourceObjectName');
    brokerMasterNode.sourceObjectParentExtId = brokerDataMap.get(
      'sourceObjectParentExtId'
    );
    brokerMasterNode.sourceObjectParentExtIdName = brokerDataMap.get(
      'sourceObjectParentExtIdName'
    );
    brokerMasterNode.targetObjects = brokerTargetNode;
    return brokerMasterNode;
  }
}
