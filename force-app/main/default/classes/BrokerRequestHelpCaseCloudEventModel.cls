/**
 * @description       : Wrapper class for creating the cloud event publish structure for case
 * @author            : Smruti Khobragade |  Salesforce
 * @group             :
 * @last modified on  : 12-01-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/
public virtual with sharing class BrokerRequestHelpCaseCloudEventModel extends CloudEventModel {
  /**
   * @description inner class for creating the Broker Case cloud event model
   **/
  public virtual class BrokerRequestHelpCaseCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description List of MasterNode String
     **/
    public List<MasterNode> data { get; set; }
    /**
     * @description parameterized constructor for BrokerRequestHelpCaseCloudEventDataModel
     * @author Smruti Khobragade | 27-11-2024
     * @param masterNodes
     **/
    public BrokerRequestHelpCaseCloudEventDataModel(
      List<MasterNode> masterNodes
    ) {
      this.data = masterNodes;
    }
  }

  /**
   * @description the model for master object to pass the source object data
   */
  public class MasterNode {
    /**
     * @description to capture Source object External Case ID field
     **/
    public String sourceObjectExtId { get; set; }
    /**
     * @description to capture the Source object name field
     **/
    public String sourceObjectName { get; set; }
    /**
     * @description to capture the Source objects parents External  ID field
     **/
    public String sourceObjectParentExtId { get; set; }
    /**
     * @description to capture the Source objects parents name field
     **/
    public String sourceObjectParentExtIdName { get; set; }
    /**
     * @description to capture target object name
     **/
    public TargetNode targetObjects { get; set; }
  }
  /**
   * @description the model for building Target object data on which upsert should happen
   */
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
     * @description to capture case 'Status' value
     **/
    public String status { get; set; }
  }

  /**
   * @description the method to build the master object
   * @param brokerDataMap - the map of broker data
   * @return MasterObject - the master object
   */
  public static MasterNode buildMasterNode(Map<String, String> brokerDataMap) {
    TargetNode brokerTargetNode = new TargetNode();
    brokerTargetNode.extIdField = brokerDataMap.get('targetObjects_extIdField');
    brokerTargetNode.extObjectName = brokerDataMap.get(
      'targetObjects_extObjectName'
    );
    brokerTargetNode.status = brokerDataMap.get('targetObjects_status');

    MasterNode brokerMasterNode = new MasterNode();
    brokerMasterNode.sourceObjectExtId = brokerDataMap.get('sourceObjectExtId');
    brokerMasterNode.sourceObjectName = brokerDataMap.get('sourceObjectName');
    brokerMasterNode.targetObjects = brokerTargetNode;
    return brokerMasterNode;
  }
}
