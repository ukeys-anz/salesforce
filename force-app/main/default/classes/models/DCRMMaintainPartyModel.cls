/**
 * @author Ankit Garg
 * @since Jun 2023
 * @description model for OCV Maintain Party API
 * @group Models
 */
public with sharing class DCRMMaintainPartyModel extends CalloutModel {
  public SourceSystems[] sourceSystems;
  public String ocvId;
  public String[] profileIds;
  public String newCustomer;

  /**
   * @description Source Systems wrapper
   */
  public class SourceSystems {
    public String sourceSystemId; //1212201901
    public String sourceSystemName; //CAP-CIS
  }

  /**
   * @description Constructor
   */
  public DCRMMaintainPartyModel() {
    //newCustomer = 'false';
  }
  /**
   * @param json input string to deserialize
   * @return DCRMMaintainPartyModel
   * @description deserializes the input string into the model
   */
  public static DCRMMaintainPartyModel parse(String json) {
    return (DCRMMaintainPartyModel) System.JSON.deserialize(
      json,
      DCRMMaintainPartyModel.class
    );
  }
}
