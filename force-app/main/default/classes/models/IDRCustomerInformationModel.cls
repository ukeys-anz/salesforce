/**
 * @author Adnan
 * @since Sep 2021
 * @description model for CMOS get customer information API (CMOSAPIRepository), extending the base
 * @group Models
 */
public with sharing class IDRCustomerInformationModel extends CalloutModel {
  /**
   * @param responseString input string to deserialize
   * @return Map<String, Object>
   * @description deserializes the input string into the model
   */
  public static Map<String, Object> parse(String responseString) {
    return (Map<String, Object>) System.JSON.deserializeUntyped(responseString);
  }
}
