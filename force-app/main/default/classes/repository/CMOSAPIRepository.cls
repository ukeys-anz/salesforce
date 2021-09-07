/**
 * @author Adnan
 * @since Sep 2021
 * @description CMOS API repository for all CMOS callouts
 * @group Repository
 */
public with sharing class CMOSAPIRepository extends RepositoryBase {
  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return Map<String, Object>
   * @description called from create complaint lwc page during customer search
   */
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

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return Map<String, Object>
   * @description calls the service class methods for integration/callout
   */
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
