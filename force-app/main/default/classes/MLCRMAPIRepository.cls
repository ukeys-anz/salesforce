/**
 * @author Ashish Kumar
 * @since Jan 2024
 * @description MLCRM API repository for all callouts
 * @group Repository
 */
public class MLCRMAPIRepository extends RepositoryBase {
  /**
   * @param state from address search bar
   * @param postcode from address search bar
   * @param suburb from address search bar
   * @return CCRMValidateManualAddressModel result
   * @description calls the service class methods for integration/callout to validate manual addresss
   */
  @AuraEnabled(cacheable=false)
  public static CCRMValidateManualAddressModel validateManualAddressesV3LWC(
    String state,
    Integer postcode,
    String suburb
  ) {
    MLCRMAPIRepository ccrmapi = new MLCRMAPIRepository();
    try {
      return ccrmapi.validateManualAddressesV3(state, postcode, suburb);
    } catch (Exception e) {
      throw new AuraHandledException(LABEL.CCRM_Validate_Manual_Address);
    }
  }
  /**
   * @param state from address search bar
   * @param postcode from address search bar
   * @param suburb from address search bar
   * @return CCRMValidateManualAddressModel result
   * @description calls the service class methods for integration/callout to validate manual addresss
   */
  public CCRMValidateManualAddressModel validateManualAddressesV3(
    String state,
    Integer postcode,
    String suburb
  ) {
    CCRMValidateManualAddressModel result;
    HttpCalloutResponse responseResult;
    Service objService = ServiceProvider.getService(
      CCRMValidateAddressService.class
    );
    // callout to validate manual address based on state,postalcode and suburb.
    HttpCalloutResponse response = objService.getValidateAddressV3(
      state,
      postcode,
      suburb
    );
    if (response.body != null) {
      result = CCRMValidateManualAddressModel.parse(response.body);
    }
    if (
      response.successful &&
      result != null &&
      result.Result != null &&
      !result.Result.isEmpty()
    ) {
      result.hasValidAddress = true;
      return result;
    } else if (
      response.successful &&
      result != null &&
      result.Result != null &&
      result.Result.isEmpty()
    ) {
      // callout to validate manual address based on postalcode if above callout return no result
      responseResult = objService.getPostcodeLookupV3(postcode);
      result = CCRMValidateManualAddressModel.parse(responseResult.body);
      result.hasValidAddress = false;
      return result;
    } else if (
      response.successful &&
      result != null &&
      result.Result != null &&
      result.Result.isEmpty() &&
      responseResult.successful
    ) {
      result = CCRMValidateManualAddressModel.parse(responseResult.body);
      result.hasValidAddress = false;
      return result;
    } else if (
      response.successful &&
      result != null &&
      result.Result != null &&
      result.Result.isEmpty() &&
      !responseResult.successful
    ) {
      // logging error in case of callout failure
      handleErrors(response, null, CCRMAPIRepository.class);
    } else {
      // logging error in case of callout failure
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }
}
