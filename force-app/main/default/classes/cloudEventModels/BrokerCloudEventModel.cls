/**
 * @description       : Wrapper class for creating the cloud event publish structure
 * @author            : Deepro De
 * @last modified on  : 05-30-2024
 * @last modified by  :  Harshit Goyal | Salesforce
 **/
@SuppressWarnings('PMD.ExcessivePublicCount')
public virtual with sharing class BrokerCloudEventModel extends CloudEventModel {
  /**
   * @description inner class for creating the cloud event model
   **/
  public virtual class BrokerCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description List of MasterNodes
     **/
    public List<MasterNode> data { get; set; }
    /**
     * @description parameterized constructor for BrokerCloudEventDataModel
     * @author Deepro De | 05-30-2024
     * @param masterNodes
     **/
    public BrokerCloudEventDataModel(List<MasterNode> masterNodes) {
      this.data = masterNodes;
    }
  }

  /**
   * @description Master Node class for creating and storing MasterNode details
   **/
  public class MasterNode {
    /**
     * @description to capture source object external id
     **/
    public String sourceObjectExtId { get; set; }
    /**
     * @description to capture source object name
     **/
    public String sourceObjectName { get; set; }
    /**
     * @description to capture source object parent external id
     **/
    public String sourceObjectParentExtId { get; set; }
    /**
     * @description to capture source object parent external id field name
     **/
    public String sourceObjectParentExtIdName { get; set; }
    /**
     * @description to capture target object name
     **/
    public TargetNode targetObjects { get; set; }
  }

  /**
   * @description the model for building Target object data on which upsert should happen
   **/
  public class TargetNode {
    /**
     * @description to capture the external id field
     **/
    public String extIdField { get; set; }
    /**
     * @description to capture external object name
     **/
    public String extObjectName { get; set; }
    /**
     * @description to capture parent object name
     **/
    public List<ParentNode> parent { get; set; }
  }
  /**
   * @description the model for building Parent object data where we define the parent data
   **/
  public class ParentNode {
    /**
     * @description to capture parent reference field
     **/
    public String referenceField { get; set; }
    /**
     * @description to capture parent external id value
     **/
    public String extId { get; set; }
    /**
     * @description to capture parent external id field value
     **/
    public String extIdField { get; set; }
    /**
     * @description to capture object name
     **/
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