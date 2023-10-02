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
  public ResidentialLoanApplicationModel getListAssets(
    String ocvId,
    String sopId
  ) {
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

  /**
   * @param ocvId ocv id of the customer account
   * @param verification whether the income is verified
   * @param incomeBody post data of income information
   * @param loanId of the working loan application
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public void createIncome(
    String ocvId,
    String verification,
    String incomeBody,
    String loanId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(incomeBody);
    HttpCalloutResponse response = s.createIncome(
      verification,
      ocvId,
      uuidLog.attachUUID(incomeBody)
    );
    if (response.successful == false) {
      uuidLog.insertUUID(loanId, 'BOH - SOP - Create Income');
      throw response.error;
    }
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param verification whether the income is verified
   * @param incomeBody post data of income information
   * @param loanId of the working loan application
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public void updateIncome(
    String ocvId,
    String verification,
    String incomeBody,
    String loanId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(incomeBody);
    HttpCalloutResponse response = s.updateIncome(
      verification,
      ocvId,
      uuidLog.attachUUID(incomeBody)
    );
    if (response.successful == false) {
      uuidLog.insertUUID(loanId, 'BOH - SOP - Update Income');
      throw response.error;
    }
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `SOPModel` model class constructed from api response
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public SOPModel getSOP(String ocvId, String sopId) {
    Service s = ServiceProvider.getService(BOHService.class);
    SOPModel sopCache = DataPartitionUtil.getSOPDetailsCache(sopId);
    if (sopCache != null) {
      return sopCache;
    }

    HttpCalloutResponse response = s.getSOP(ocvId, sopId);
    if (response.successful == false) {
      throw response.error;
    }
    try {
      DataPartitionUtil.storeSOPDetailsCache(
        sopId,
        SOPModel.parse(response.body)
      );
      return SOPModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, SOPModel.class);
    }
    return null;
  }

  /**
   * @param sopId sop id to retrieve customer information
   * @param ocvId ocv id of the customer account
   * @param deleIncomeModel the name and tag of income to be deleted
   * @param loanId of the working loan application
   * @return `Boolean` indicate deletion result
   * @description delete a income from sop
   */
  public Boolean deleteIncome(
    String sopId,
    String ocvId,
    String deleIncomeModel,
    String loanId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.deleteIncome(
      sopId,
      ocvId,
      deleIncomeModel
    );
    if (!response.successful) {
      throw response.error;
    }
    try {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (Exception e) {
      handleErrors(response, e, ResidentialLoanApplicationAPIRepository.class);
    }
    return false;
  }
}
