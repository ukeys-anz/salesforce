public with sharing class CMOSCustomerInformationModel extends CalloutModel {
  public static Map<String, Object> parse(String json) {
    map<String, Object> customerData = new Map<String, Object>();
    customerData = (Map<String, Object>) JSON.deserializeUntyped(json);
    return customerData;
  }
}
