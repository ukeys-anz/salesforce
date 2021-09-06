public with sharing class CMOSAPIRepository extends RepositoryBase {
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getCustomerInfoLWC(
    String customerId,
    String customerIdentifier
  ) {
    CMOSAPIRepository cmosapi = new CMOSAPIRepository();
    try {
      return cmosapi.getCustomerInfo(customerId, customerIdentifier);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public Map<String, Object> getCustomerInfo(
    String customerId,
    String customerIdentifier
  ) {
    map<String, Object> result;
    Service s = ServiceProvider.getService(CustomerProfileService.class);
    HttpCalloutResponse response = s.getCustomerInformation(
      customerId,
      customerIdentifier
    );
    if (response.successful) {
      try {
        result = CMOSCustomerInformationModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CMOSAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CMOSAPIRepository.class);
    }
    return result;
  }
}
