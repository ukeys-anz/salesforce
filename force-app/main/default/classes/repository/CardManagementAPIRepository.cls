/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description card management API repository for all card management callouts
 * @group Repository
 */
public with sharing class CardManagementAPIRepository extends RepositoryBase {
  /**
   * @param fraudLockInformation `Map<String,String>` which contains:
   * - cardNumber card number to send to api
   * - ocvId customer id
   * - status chosen by fraud agent
   * - reason for fraud action. If chosen to cancel the card, this will be "Fraud"
   * @return `Boolean` to check if it is successful or not
   * @description fraud response api
   */
  public Boolean setFraudCardStatus(Map<String, String> fraudLockInformation) {
    Service s = ServiceProvider.getService(CardManagementService.class);

    HttpCalloutResponse response = s.setFraudCardStatus(fraudLockInformation);

    if (!response.successful) {
      handleErrors(response, null, CardManagementAPIRepository.class);
    }
    return response.successful;
  }
}
