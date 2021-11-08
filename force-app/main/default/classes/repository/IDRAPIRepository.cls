/**
 * @author Adnan
 * @since Sep 2021
 * @description CMOS API repository for all CMOS callouts
 * @group Repository
 */
public with sharing class IDRAPIRepository extends RepositoryBase {
  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return IDRCustomerInformationModel
   * @description called from create complaint lwc page during customer search
   */
  @AuraEnabled(cacheable=false)
  public static IDRCustomerInformationModel getCustomerInfoLWC(
    String customerId,
    String customerIdentifier
  ) {
    IDRAPIRepository cmosapi = new IDRAPIRepository();
    try {
      return cmosapi.getCustomerInfo(customerId, customerIdentifier);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return IDRCustomerInformationModel result
   * @description calls the service class methods for integration/callout
   */
  public IDRCustomerInformationModel getCustomerInfo(
    String customerId,
    String customerIdentifier
  ) {
    IDRCustomerInformationModel result;
    Service s = ServiceProvider.getService(IDRCustomerProfileService.class);
    HttpCalloutResponse response = s.getCustomerInformation(
      customerId,
      customerIdentifier
    );
    if (response.successful) {
      try {
        result = IDRCustomerInformationModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, IDRAPIRepository.class);
      }
    } else {
      handleErrors(response, null, IDRAPIRepository.class);
    }
    return result;
  }
}
