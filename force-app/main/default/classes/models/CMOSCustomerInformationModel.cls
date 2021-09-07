public with sharing class CMOSCustomerInformationModel extends CalloutModel {
  public static Map<String, Object> parse(String responseString) {
    return (Map<String, Object>) System.JSON.deserializeUntyped(responseString);
  }
}
