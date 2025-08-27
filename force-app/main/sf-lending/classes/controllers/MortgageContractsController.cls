/**
 * @author @fangl6
 * @since June 2025
 * @description Mortgage Contracts controller
 */
public with sharing class MortgageContractsController implements IGenericClass {
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  private static final String ERROR_MSG = 'Failed to retrieve Mortgage Contract details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description getData method to return Mortgage Contracts data
   * @param param Parameter to pass to the getData method
   * @return Object Array of Data
   */
  public Object getData(String param) {
    try {
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        param
      );
      Settlement__c settlement = SETTLEMENT_REPOSITORY.getSettlement(
        (String) params.get('recordId')
      );
      return LEX_API_REPOSITORY.getListMortgageContracts(
        settlement.Settlement_ID__c,
        settlement.Loan_Application_Number__r.Account.OCV_ID__c
      );
    } catch (Exception e) {
      Logger.error('Failure on get List Mortgage Contracts', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
