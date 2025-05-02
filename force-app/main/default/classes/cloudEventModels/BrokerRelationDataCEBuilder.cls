/**
 * @author Saurabh Chauhan
 * @since  28/02/2025
 * @description Builder class to build the GCP Event for the broker relation add/delete
 */
public with sharing class BrokerRelationDataCEBuilder {
  private static final String OBJECT_CONTACT = 'Contact';
  private static final String OBJECT_CONTACT_CONTACT_RELATIONSHIP = 'FinServ__ContactContactRelation__c';
  private static final String OBJECT_RECIPROCAL_ROLE = 'FinServ__ReciprocalRole__c';
  private static final String FIELD_FINSERV_EXTERNAL_ID = 'FinServ__ExternalId__c';
  private static final String FIELD_OCV_ROLE = 'OCV_Role__c';
  private static final String FIELD_FINSERV_ROLE = 'FinServ__Role__c';
  private static final String FIELD_FINSERV_CONTACT = 'FinServ__Contact__c';
  private static final String FIELD_FINSERV_RELATED_CONTACT = 'FinServ__RelatedContact__c';
  private static final String FIELD_EXTERNAL_ID = 'External_Id__c';
  private static final String FIELD_LAN_ID = 'Lan_Id__c';

  /**
   * @description Create Broker Relation Master Node for publishing cloud event
   * @author  Saurabh Chauhan | Salesforce | 28-02-2025
   * @param record broker contact record
   * @param rbmType type of rbm primary or secondary
   * @return BrokerCloudEventModel.MasterNode
   **/
  public static BrokerCloudEventModel.MasterNode buildBrokerRelationAdd(
    Contact record,
    String rbmType
  ) {
    String rbmLanId = returnLanIdForAddEvent(record.Broker_Set__r, rbmType);
    String externalId = rbmLanId + '-' + record.External_Id__c + '-' + rbmType;

    Map<String, String> brokerRelationAddMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CONTACT_CONTACT_RELATIONSHIP,
      'sourceObjectExtId' => externalId,
      'targetObjects_extIdField' => FIELD_FINSERV_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_CONTACT_CONTACT_RELATIONSHIP,
      'targetObjects_parent_nodes' => JSON.serialize(
        buildBrokerRelationParentNodes(record, rbmType, rbmLanId)
      )
    };
    return BrokerCloudEventModel.buildMasterNode(brokerRelationAddMap);
  }

  /**
   * @description Create Broker Relation Master Node for publishing cloud event
   * @author  Saurabh Chauhan | Salesforce | 28-02-2025
   * @param record broker contact record
   * @param rbmType type of rbm primary or secondary
   * @param oldBrokerSet older broker set record of type LanIdWrapper
   * @return BrokerCloudEventModel.MasterNode
   **/
  public static BrokerCloudEventModel.MasterNode buildBrokerRelationDelete(
    Contact record,
    String rbmType,
    RetailBrokerRelationEventActions.LanIdWrapper oldBrokerSet
  ) {
    String externalId =
      returnLanIdForDeleteEvent(oldBrokerSet, rbmType) +
      +'-' +
      record.External_Id__c +
      '-' +
      rbmType;

    Map<String, String> brokerRelationDeleteMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CONTACT_CONTACT_RELATIONSHIP,
      'sourceObjectExtId' => externalId,
      'targetObjects_extIdField' => FIELD_FINSERV_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_CONTACT_CONTACT_RELATIONSHIP
    };

    BrokerCloudEventModel.MasterNode masterNode = BrokerCloudEventModel.buildMasterNode(
      brokerRelationDeleteMap
    );
    //Remove unnecessary node
    masterNode.targetObjects.parent = null;
    return masterNode;
  }

  /**
   * @description to get the lan id of PRBM/SRBM
   * @author  Saurabh Chauhan | Salesforce | 12-03-2025
   * @param brokerSet broker relation record
   * @param rbmType type of rbm primary or secondary
   * @return String
   **/
  @TestVisible
  private static String returnLanIdForAddEvent(
    Broker_Relation__c brokerSet,
    String rbmType
  ) {
    if (rbmType.equals('PRBM')) {
      return brokerSet?.Primary_RBM__r?.Lan_Id__c;
    }
    return brokerSet?.Secondary_RBM__r?.Lan_Id__c;
  }

  /**
   * @description Create Broker Relation Master Node for publishing cloud event
   * @author  Saurabh Chauhan | Salesforce | 28-02-2025
   * @param lanIdObj RetailBrokerRelationEventActions.LanIdWrapper
   * @param rbmType type of rbm primary or secondary
   * @return String
   **/
  @TestVisible
  private static String returnLanIdForDeleteEvent(
    RetailBrokerRelationEventActions.LanIdWrapper lanIdObj,
    String rbmType
  ) {
    if (rbmType.equals('PRBM')) {
      return lanIdObj?.prbmLanId;
    }
    return lanIdObj?.srbmLanId;
  }

  /**
   * @description Create Parent Node List of Master node for publishing cloud event
   * @author  Saurabh Chauhan | Salesforce | 28-02-2025
   * @param record
   * @param rbmType type of rbm primary or secondary
   * @param rbmLanId lan id of the rbm
   * @return BrokerCloudEventModel.ParentNode
   **/
  @TestVisible
  private static List<BrokerCloudEventModel.ParentNode> buildBrokerRelationParentNodes(
    Contact record,
    String rbmType,
    String rbmLanId
  ) {
    List<BrokerCloudEventModel.ParentNode> brokerRelationParentNodes = new List<BrokerCloudEventModel.ParentNode>();

    BrokerCloudEventModel.ParentNode brokerParentNode = new BrokerCloudEventModel.ParentNode();
    brokerParentNode.extId = record.External_Id__c;
    brokerParentNode.extIdField = FIELD_EXTERNAL_ID;
    brokerParentNode.objectName = OBJECT_CONTACT;
    brokerParentNode.referenceField = FIELD_FINSERV_CONTACT;
    brokerRelationParentNodes.add(brokerParentNode);

    BrokerCloudEventModel.ParentNode rbmParentNode = new BrokerCloudEventModel.ParentNode();
    rbmParentNode.extId = rbmLanId;
    rbmParentNode.extIdField = FIELD_LAN_ID;
    rbmParentNode.objectName = OBJECT_CONTACT;
    rbmParentNode.referenceField = FIELD_FINSERV_RELATED_CONTACT;
    brokerRelationParentNodes.add(rbmParentNode);

    BrokerCloudEventModel.ParentNode roleParentNode = new BrokerCloudEventModel.ParentNode();
    roleParentNode.extId = rbmType;
    roleParentNode.extIdField = FIELD_OCV_ROLE;
    roleParentNode.objectName = OBJECT_RECIPROCAL_ROLE;
    roleParentNode.referenceField = FIELD_FINSERV_ROLE;
    brokerRelationParentNodes.add(roleParentNode);

    return brokerRelationParentNodes;
  }
}
