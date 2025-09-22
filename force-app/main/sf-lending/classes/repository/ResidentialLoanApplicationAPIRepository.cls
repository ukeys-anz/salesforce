/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description SOP API repository for all SOP callouts
 * @group Repository
 */
//@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class ResidentialLoanApplicationAPIRepository extends RepositoryBase {
  private static final SOPService SOP_SERVICE = (SOPService) Lib_InstanceProvider.forType(
    SOPService.class
  );
  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `SOPGetConsolidatedModel` model class constructed from api response
   * @description fetches consolidated sop message
   */
  public SOPGetConsolidatedModel getConsolidatedSOP(
    String ocvId,
    String sopId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getListAssets(ocvId, sopId);
    if (response.successful == false) {
      throw response.error;
    }
    try {
      return SOPGetConsolidatedModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, SOPGetConsolidatedModel.class);
    }
    return null;
  }

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
   * @param paramMap parameter map includes:
   * ocvId: ocv id of the customer account
   * verification: whether the income is verified
   * incomeBody: post data of income information
   * loanId: record id of the working loan application
   * @param incomeVerifiedChanged checks if the income verified value has changed
   * @description fetches a list of assets from flex for a sop, deserialized to a model
   */
  public void updateIncome(
    Map<String, String> paramMap,
    Boolean incomeVerifiedChanged
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(paramMap.get('incomeBody'));
    HttpCalloutResponse response = s.updateIncome(
      paramMap.get('verification'),
      paramMap.get('ocvId'),
      uuidLog.attachUUID(paramMap.get('incomeBody')),
      incomeVerifiedChanged
    );
    if (response.successful == false) {
      uuidLog.insertUUID(paramMap.get('loanId'), 'BOH - SOP - Update Income');
      throw response.error;
    }
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param expenseBody expense edited information
   * @param loanId of the working loan application
   * @description fetches updated expense details and deserialized to a model
   */
  public void editExpense(String ocvId, String expenseBody, String loanId) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(expenseBody);
    HttpCalloutResponse response = s.editExpense(
      ocvId,
      uuidLog.attachUUID(expenseBody)
    );
    if (response.successful == false) {
      uuidLog.insertUUID(loanId, 'BOH - SOP - Update Expense');
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
    SOPModel sopCache = DataPartitionUtil.getSOPDetailsCache(sopId);
    if (sopCache != null) {
      return sopCache;
    }

    HttpCalloutResponse response = SOP_SERVICE.getSOP(ocvId, sopId);
    return handleGetSOPResponse(response, sopId);
  }

  /**
   * @param sopId sop id to retrieve customer information
   * @param ocvId ocv id of the customer account
   * @param deleModel the name and tag of income to be deleted
   * @param loanId of the working loan application
   * @return `Boolean` indicate deletion result
   * @description delete a income from sop
   */
  public Boolean deleteIncome(
    String sopId,
    String ocvId,
    String deleModel,
    String loanId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.deleteIncome(sopId, ocvId, deleModel);
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

  /**
   * @param ocvId ocv id of the customer account
   * @param debtBody post data of debt information
   * @param loanId of the working loan application
   * @return `Boolean` indicate creation result
   * @description creates a new debt
   */
  public Boolean createDebt(String ocvId, String debtBody, String loanId) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(debtBody);
    HttpCalloutResponse response = s.createDebt(
      ocvId,
      uuidLog.attachUUID(debtBody)
    );
    if (response.successful == false) {
      uuidLog.insertUUID(loanId, 'BOH - SOP - Create Debt');
      AuraHandledException err = new AuraHandledException(
        SOPController.ADD_DEBT_ERROR
      );
      err.setMessage(SOPController.ADD_DEBT_ERROR);
      throw err;
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

  /**
   * @param ocvId ocv id of the customer account
   * @param debtBody post data of debt information
   * @param loanId of the working loan application
   * @return `Boolean` indicate creation result
   * @description edits an existing debt
   */
  public Boolean editDebt(String ocvId, String debtBody, String loanId) {
    Service s = ServiceProvider.getService(BOHService.class);
    UUIDLog uuidLog = new UUIDLog(debtBody);
    HttpCalloutResponse response = s.editDebt(ocvId, debtBody);
    if (response.successful == false) {
      uuidLog.insertUUID(loanId, 'BOH - SOP - Update Debt');
      AuraHandledException err = new AuraHandledException(
        SOPController.EDIT_DEBT_ERROR
      );
      err.setMessage(SOPController.EDIT_DEBT_ERROR);
      throw err;
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

  /**
   * @param sopId sop id to retrieve customer information
   * @param ocvId ocv id of the customer account
   * @param deleModel the name and tag of debt to be deleted
   * @return `Boolean` indicate deletion result
   * @description delete a debt from sop
   */
  public Boolean deleteDebt(String sopId, String ocvId, String deleModel) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.deleteDebt(sopId, ocvId, deleModel);
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

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @param sopId sop id to retrieve customer information
   * @return SOPModel
   */
  private static SOPModel handleGetSOPResponse(
    HttpCalloutResponse response,
    String sopId
  ) {
    if (response.successful == false) {
      throw new UnhandledGetSOPException(response);
    }
    DataPartitionUtil.storeDataToCache(
      BOHConstants.CACHE_DATA_KEY_PREFIX_SOPINELIGIBLE + sopId,
      SOPModel.parse(response.body)
    );

    return SOPModel.parse(response.body);
  }

  /**
   * @description Exception class for Unhandled Get SOP API Response
   */
  public class UnhandledGetSOPException extends Exception {
    /**
     * @description Exception class for Unhandled Get SOP API Response
     * @param response HttpCalloutResponse
     */
    public UnhandledGetSOPException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetSOPException SOPService: getSOP',
          response.error
        )
        .save();
    }
  }
}
