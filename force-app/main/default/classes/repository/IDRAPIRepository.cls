/**
 * @author Adnan
 * @since Sep 2021
 * @description CMOS API repository for all CMOS callouts
 * @group Repository
 */
public with sharing class IDRAPIRepository extends RepositoryBase {

  public class CustomCustomerNotFoundException extends Exception{}
  public class CustomOCVDownException extends Exception{}

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
    if (Label.IDR_Excluded_OCV_ProductTypes == null) {
      return null;
    }
    IDRAPIRepository cmosapi = new IDRAPIRepository();
    try {
      return cmosapi.getCustomerInfo(customerId, customerIdentifier);
    }catch(CustomCustomerNotFoundException e){
      throw new AuraHandledException(e.getMessage());
    }catch(CustomOCVDownException e){
      throw new AuraHandledException(e.getMessage());
    }catch (Exception e) {
      Logger.error(
        'OCV Error' ,
        String.valueOf(e),
        Logger.Severity.HIGH
      );
      Logger.saveLog();
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
    Service s = ServiceProvider.getService(IDRCustomerProfileService.class);
    HttpCalloutResponse response = s.getCustomerInformation(
      customerId,
      customerIdentifier
    );

    if (response.statusCode == 422) {
      throw new CustomCustomerNotFoundException('Customer not found');
    }

    if(response.statusCode > 499){
      throw new CustomOCVDownException('OCV Down');
    }

    if(!response.successful){
      throw response.error;
    }
      IDRCustomerInformationModel result = IDRCustomerInformationModel.parse(response.body);
        List<String> lstExcludedProductTypes = Label.IDR_Excluded_OCV_ProductTypes.split(
          ','
        );
        List<IDRCustomerInformationModel.Accounts> accounts = new List<IDRCustomerInformationModel.Accounts>();
        for (IDRCustomerInformationModel.Accounts oAccount : result.accounts) {
          if (!lstExcludedProductTypes.contains(oAccount.subProductCode)) {
            accounts.add(oAccount);
          }
        }
        result.accounts = accounts;
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
    SNOWIntegrationService service = (SNOWIntegrationService) ServiceProvider.getService(
      SNOWIntegrationService.class
    );

    try {
      HttpCalloutResponse response = service.getSNOWRiskEventInformation(
        riskEventId
      );
      if (response.successful == true) {
        return SNOWIntegrationModel.parse(response.body);
      }
      if (response.statusCode >= 500) {
        Logger.error(
          'ServiceNow Error - Status Code - ' + response.statusCode,
          response.error,
          Logger.Severity.HIGH
        );
        Logger.saveLog();
      }
      handleErrors(null, response.error, IDRAPIRepository.class);
      throw response.error;
    } catch (Exception e) {
      handleErrors(null, e, IDRAPIRepository.class);
      throw e;
    }
  }
}
