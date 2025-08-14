/**
 * @author @fangl6
 * @since June 2025
 * @description Automatic Repayment Preferences controller
 */
public with sharing class RepaymentPreferencesController implements IGenericClass {
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  private static final String ERROR_MSG = 'Failed to retrieve Automatic Repayment Preferences. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description getData method to return Automatic Repayment Preferences data
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
      return LEX_API_REPOSITORY.listAutomaticRepaymentPreferences(
        settlement.Settlement_ID__c,
        settlement.Loan_Application_Number__r.Account.OCV_ID__c
      );
    } catch (Exception e) {
      Logger.error('Failure on get List Automatic Repayment Preferences', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
