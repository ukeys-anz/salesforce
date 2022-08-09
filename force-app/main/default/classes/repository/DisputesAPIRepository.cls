/**
 * @author Emma Bindi
 * @since July 2022
 * @description disputes API repository for all disputes callouts
 * @group Repository
 */
public with sharing class DisputesAPIRepository extends RepositoryBase {
  private static final String RAISE_DISPUTE_PERMISSION_ERROR = 'User does not have the raise dispute permission';

  /**
   * @param ocvId customer id
   * @param transactionId transaction id
   * @return `String` tokenized card number relating to the passed in transaction Id
   * @description getTokenizedCardNumber retrieves the tokenized card number
   */
  public String getTokenizedCardNumber(String ocvId, String transactionId) {
    String tokenizedCardNumber;

    if (FeatureManagement.checkPermission('ANZx_Raise_Dispute')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getTokenizedCardNumber(
        ocvId,
        transactionId
      );

      if (response.successful) {
        try {
          DisputesModel.SearchTokenizedCardResponseCls result = DisputesModel.parseTokenizedCardResponse(
            response.body
          );
          tokenizedCardNumber = result.tokenized_card_number;
        } catch (Exception e) {
          handleErrors(null, e, DisputesAPIRepository.class);
        }
      } else {
        // If response is error, return a null value and allow continuing to raise dispute
        return tokenizedCardNumber;
      }
    } else {
      handleErrors(
        null,
        new PermissionException(RAISE_DISPUTE_PERMISSION_ERROR),
        DisputesAPIRepository.class
      );
    }

    return tokenizedCardNumber;
  }

  /**
   * @author Emma Bindi
   * @since July 2022
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
}
