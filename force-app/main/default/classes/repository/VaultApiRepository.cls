/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description VaultApiRepository for all the callouts to Vault System via GCP and Mulesoft
 * @group Repository
 */
public with sharing class VaultApiRepository {
  private static final String GET_CARD_NUMBER_PERMISSION_ERROR = 'User does not have permission to view full card number';
  private static final String TOKENIZATION_TYPE = 'TOKEN_TYPE_CARD_NUMBER';

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

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
    if (USER_INFO.checkCustomPermission('ANZx_View_Card_Number') == false) {
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
    contextReq.value = cardNumberToBeDetokenized;
    contextReq.type = TOKENIZATION_TYPE;
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
   * @description Tokenize Document number
   * @param customerId customer Id
   * @param customerIdType customer Id type
   * @param tokenizeDocumentNumberRequest tokenize document number request
   * @return `TokenizeDocumentNumberRequestModel` detokenized document number
   */
  public TokenizeDocumentNumberResponseModel tokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    TokenizeDocumentNumberRequestModel tokenizeDocumentNumberRequest
  ) {
    VaultService serviceInstance = (VaultService) ServiceProvider.getService(
      VaultService.class
    );

    HttpCalloutResponse response = serviceInstance.tokenizeDocumentNumber(
      customerId,
      customerIdType,
      tokenizeDocumentNumberRequest
    );

    if (response.successful == false) {
      throw CommonUtil.logException(response);
    }

    return TokenizeDocumentNumberResponseModel.parse(response.body);
  }

  /**
   * @description Detokenize Document number
   * @param customerId customer Id
   * @param customerIdType customer Id type
   * @param detokenizeDocumentNumberRequest detokenize document number request
   * @return `DetokenizeDocumentNumberRequestModel` detokenized document number
   */
  public DetokenizeDocumentNumberResponseModel detokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    DetokenizeDocumentNumberRequestModel detokenizeDocumentNumberRequest
  ) {
    VaultService serviceInstance = (VaultService) ServiceProvider.getService(
      VaultService.class
    );

    HttpCalloutResponse response = serviceInstance.detokenizeDocumentNumber(
      customerId,
      customerIdType,
      detokenizeDocumentNumberRequest
    );
    if (response.successful == false) {
      throw CommonUtil.logException(response);
    }

    return DetokenizeDocumentNumberResponseModel.parse(response.body);
  }

  /**
   * @author Shivam Swaraj
   * @since September 2024
   * @description no private key found
   */
  public class NoPrivateKeyFoundException extends Exception {
  }
}
