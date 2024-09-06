/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description VaultApiRepository for all the callouts to Vault System via GCP and Mulesoft
 * @group Repository
 */
public with sharing class VaultApiRepository {
  private static final String GET_CARD_NUMBER_PERMISSION_ERROR = 'User does not have the get full card number permission';
  /**
   * @param ocvId ocvId of the customer
   * @param cardNumberToBeDetokenized card number to be detokenzed
   * @return `DetokenizationResponseModel` detokenized card number with the details
   * @description fetches card list from fabric, deserialized to a model
   */
  public DetokenizationResponseModel getFullCardNumberDetails(
    String ocvId,
    String cardNumberToBeDetokenized
  ) {
    if (!FeatureManagement.checkPermission('ANZx_View_Card_Number')) {
      throw CommonUtil.logExceptionInfo(
        new CoachBankingAPIRepository.PermissionException(
          GET_CARD_NUMBER_PERMISSION_ERROR
        )
      );
    }
    VaultService serviceInstance = (VaultService) ServiceProvider.getService(
      VaultService.class
    );
    DetokenizationRequestModel contextReq = new DetokenizationRequestModel();
    contextReq.tokenizedCardNumber = cardNumberToBeDetokenized;
    HttpCalloutResponse response = serviceInstance.getFullCardNumberDetails(
      ocvId,
      contextReq
    );
    if (!response.successful) {
      throw CommonUtil.logException(response);
    }
    return DetokenizationResponseModel.parse(response.body);
  }

  /**
   * @author Shivam Swaraj
   * @since September 2024
   * @description no private key found
   */
  public class NoPrivateKeyFoundException extends Exception {
  }
}
