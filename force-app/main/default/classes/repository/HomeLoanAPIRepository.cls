/**
 * @author Vidhya Raghavan
 * @since Dec 2022
 * @description banking API repository for all Home Loan callouts
 * @group Repository
 */

public with sharing class HomeLoanAPIRepository extends RepositoryBase {
  private static final string BOH_READ_ONLY_PERMISSION_ERROR = 'User does not have permissions to view home loans';
  /**
   * @param ocvId customer id
   * @return `HomeLoanAccountModel` model class constructed from api response
   * @description fetches financial accounts from fabric, deserialized to a model when the data has NOT been stored in the session cache
   */
  public HomeLoanModel getHomeLoanAccounts(String ocvId) {
    if (FeatureManagement.checkPermission('ANZx_Home_Loan') == false) {
      throw new PermissionException(BOH_READ_ONLY_PERMISSION_ERROR);
    }
    HomeLoanModel h1AccountDetails = DataPartitionUtil.getH1AccountDetailsCache(
      ocvId
    );
    if (h1AccountDetails != null) {
      return h1AccountDetails;
    }
    Service s = ServiceProvider.getService(HomeLoanService.class);
    HttpCalloutResponse response = s.getHomeLoanAccounts(ocvId);
    if (response.successful == false) {
      throw response.error;
    }
    try {
      h1AccountDetails = HomeLoanModel.parse(response.body);
      filterOutNonHomeLoanAccounts(h1AccountDetails);
      DataPartitionUtil.storeH1AccountDetailsCache(ocvId, h1AccountDetails);
      Logger.debug('Home Loan API hit:')
        .setPayload(json.serialize(h1AccountDetails));
      Logger.saveLog();
    } catch (Exception e) {
      handleErrors(response, e, HomeLoanAPIRepository.class);
    }
    return h1AccountDetails;
  }
  /**
   * @author Vidhya Raghavan
   * @since December 2022
   * @description insufficient permission exception
   */
  public class PermissionException extends Exception {
  }

  private void filterOutNonHomeLoanAccounts(HomeLoanModel result) {
    List<HomeLoanModel.HomeLoanAccount> homeLoanAccounts = new List<HomeLoanModel.HomeLoanAccount>();
    for (HomeLoanModel.HomeLoanAccount acc : result.accounts) {
      if (isHomeLoanAccount(acc)) {
        homeLoanAccounts.add(acc);
      }
      result.accounts = homeLoanAccounts;
    }
  }
  /**
   * @description checking if the retrieved data only passes through Home Loan Account(H1) Details
   * @param acc containing all information related to the account
   * @return true if product_code is 'ANZ Plus Standard Variable Rate Home Loan' (Variable & Fixed Loan)
   */
  private boolean isHomeLoanAccount(HomeLoanModel.HomeLoanAccount acc) {
    return (acc.product_details.marketing_code.equals('HLVAR01') ||
    acc.product_details.marketing_code.equals('HLFXD01'));
  }
}
