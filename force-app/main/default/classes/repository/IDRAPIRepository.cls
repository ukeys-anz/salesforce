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
        if (Label.IDR_Excluded_OCV_ProductTypes != null) {
          List<String> lstExcludedProductTypes = Label.IDR_Excluded_OCV_ProductTypes.split(
            ','
          );
          List<IDRCustomerInformationModel.Accounts> accounts = new List<IDRCustomerInformationModel.Accounts>();
          for (
            IDRCustomerInformationModel.Accounts oAccount : result.accounts
          ) {
            if (!lstExcludedProductTypes.contains(oAccount.subProductCode)) {
              accounts.add(oAccount);
            }
          }
          result.accounts = accounts;
        }
      } catch (Exception e) {
        handleErrors(null, e, IDRAPIRepository.class);
      }
    } else {
      handleErrors(response, null, IDRAPIRepository.class);
    }
    return result;
  }
  /**
   * @param riskEventId customer id to be searched
   * @return SNOWIntegrationModel
   * @description called from close complaint lwc page during Risk Event Id verification
   */
  @AuraEnabled(cacheable=false)
  public static SNOWIntegrationModel getSNOWEventInfoLWC(String riskEventId) {
    IDRAPIRepository cmosapi = new IDRAPIRepository();
    try {
      return cmosapi.getSNOWEventInfo(riskEventId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  /**
   * @param riskEventId risk event id to be searched
   * @return SNOWIntegrationModel result
   * @description calls the service class methods for integration/callout
   */
  public SNOWIntegrationModel getSNOWEventInfo(String riskEventId) {
    SNOWIntegrationModel result;
    SNOWIntegrationService service = (SNOWIntegrationService) ServiceProvider.getService(
      SNOWIntegrationService.class
    );
    HttpCalloutResponse response = service.getSNOWRiskEventInformation(
      riskEventId
    );
    if (response.successful == false) {
      handleErrors(response, null, IDRAPIRepository.class);
      Logger.error(
        'ServiceNow Error - Status Code - ' + response.statusCode,
        response.error,
        Logger.Severity.HIGH
      );
      Logger.saveLog();
    }
    try {
      result = SNOWIntegrationModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(null, e, IDRAPIRepository.class);
    }
    return result;
  }
}
