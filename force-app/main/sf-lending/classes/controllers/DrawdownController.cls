/**
 * @author Peter Charalambous
 * @since Mon May 05 2025
 * @description Drawdown controller
 */
public with sharing class DrawdownController implements IGenericClass {
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  private static final String ERROR_MSG = 'Failed to retrieve Drawdown details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  /**
   * @description getData method to return Drawdown data
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
      return LEX_API_REPOSITORY.getListDrawdowns(
        settlement.Settlement_ID__c,
        settlement.Loan_Application_Number__r.Account.OCV_ID__c
      );
    } catch (Exception e) {
      Logger.error('Failure on get List Drawdowns', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
