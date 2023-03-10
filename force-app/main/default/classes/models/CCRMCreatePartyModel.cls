/**
 * @author Boobalakrishnan Duraisamy
 * @since Aug 2022
 * @description model for CAP Create Party API
 * @group Models
 */
public with sharing class CCRMCreatePartyModel extends CalloutModel {
  public String customerId;
  public String capcisId;
  public String customerName;

  /**
   * @param json input string to deserialize
   * @return CCRMCreatePartyModel
   * @description deserializes the input string into the model
   */
  public static CCRMCreatePartyModel parse(String json) {
    return (CCRMCreatePartyModel) System.JSON.deserialize(
      json,
      CCRMCreatePartyModel.class
    );
  }
}
