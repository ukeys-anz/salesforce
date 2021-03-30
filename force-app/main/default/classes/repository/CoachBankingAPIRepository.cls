/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description banking API repository for all banking callouts
 */
public with sharing class CoachBankingAPIRepository extends RepositoryBase {
  /**
   * @param ocvId customer id
   * @return `AccountsAndGoalsModel` model class constructed from api response
   * @description fetches financial accounts and goals from fabric, deserialized to a model
   */
  public AccountsAndGoalsModel getAccounts(String ocvId) {
    AccountsAndGoalsModel result;
    if (FeatureManagement.checkPermission('ANZx_Accounts_and_Goals')) {
      Service s = ServiceProvider.getService(FabricService.class);
      HttpCalloutResponse response = s.getAccountsAndGoals(ocvId);
      if (response.successful) {
        try {
          result = AccountsAndGoalsModel.parse(response.body);
        } catch (Exception e) {
          handleErrors(null, e, CoachBankingAPIRepository.class);
        }
      } else {
        handleErrors(response, null, CoachBankingAPIRepository.class);
      }
    } else {
      handleErrors(
        null,
        new PermissionException(
          'User does not have the ANZx Accounts and Goals permission'
        ),
        CoachBankingAPIRepository.class
      );
    }
    return result;
  }

  /**
   * @description  The getAccounts(ocvId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * The Namedcredentials used in this method is also temporary and needs to be changed.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to Fabric to have the logs recorded for monitoring.
   *
   * @param ocvId Ocv id for which accounts and goals needs to be fetched
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled(cacheable=false)
  public static AccountsAndGoalsModel getAccountsAura(String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    try {
      AccountsAndGoalsModel responseModel = coachapi.getAccounts(ocvId);
      return responseModel;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }
  }

  /**
   * @author Lance
   * @since March 2021
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }
}
