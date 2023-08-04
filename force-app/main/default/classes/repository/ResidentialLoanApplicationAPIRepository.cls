/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description SOP API repository for all SOP callouts
 * @group Repository
 */
public with sharing class ResidentialLoanApplicationAPIRepository extends RepositoryBase {
  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `ResidentialLoanApplicationModel` model class constructed from api response
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public ResidentialLoanApplicationModel getListAssets(String ocvId, String sopId) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getListAssets(ocvId, sopId);
    if (response.successful == false) {
      throw response.error;
    }
    try {
      return ResidentialLoanApplicationModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, ResidentialLoanApplicationAPIRepository.class);
    }
    return null;
  }
}
