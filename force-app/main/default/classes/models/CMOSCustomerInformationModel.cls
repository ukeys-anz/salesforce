public with sharing class CMOSCustomerInformationModel extends CalloutModel {
  public static Map<String, Object> parse(String json) {
    return (Map<String, Object>) JSON.deserializeUntyped(json);
  }
}
