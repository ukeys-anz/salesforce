/**
 * @author Vidhya Raghavan
 * @since Dec 2022
 * @description banking API repository for all Home Loan callouts
 * @group Repository
 */

public with sharing class HomeLoanAPIRepository extends RepositoryBase {
  /**
   * @param ocvId ocv id
   * @param loanAccNumber param to get the offset linked with financial account
   * @param recordId record ID
   * @return `OffsetAccountModel`
   * @description fetches linked offset account from lex, deserialized to a model
   */
  public OffsetAccountModel getOffsetAccounts(
    String ocvId,
    String loanAccNumber,
    String recordId
  ) {
    OffsetAccountModel offsetDetails = (OffsetAccountModel) DataPartitionUtil.getDataFromCache(
      recordId
    );
    if (offsetDetails != null) {
      return offsetDetails;
    }
    FinancialAccountService s = (FinancialAccountService) ServiceProvider.getService(
      FinancialAccountService.class
    );
    HttpCalloutResponse response = s.getOffsetAccounts(ocvId, loanAccNumber);
    try {
      if (
        response.statusCode == 404 &&
        response.error?.getMessage().contains('HTTP:NOT_FOUND')
      ) {
        throw new HomeLoanController.NotFoundException(
          'No Offset Found Exception'
        );
      }
      if (response.successful == false) {
        throw response.error;
      }
      String offsetStr = (response.body).replace('accounts/', '');
      offsetDetails = OffsetAccountModel.parse(offsetStr);
      DataPartitionUtil.storeDataToCache(recordId, offsetDetails);
    } catch (Exception e) {
      handleErrors(response, e, HomeLoanAPIRepository.class);
    }
    return offsetDetails;
  }
}
