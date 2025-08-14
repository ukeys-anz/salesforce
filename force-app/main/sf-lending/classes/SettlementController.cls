/**
 * @description settlements controller class for genericSection lwc
 * @author @cruzb
 * @since 04/2025
 */
public with sharing class SettlementController implements IGenericClass {
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  private static final String ERROR_MSG = 'Failed to retrieve settlement details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  /**
   * @description getData method to return settlement data
   * @param param Parameter to pass to the getData method (record id)
   * @return Object Array of Data
   */
  public Object getData(String param) {
    try {
      Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(
        param
      );
      String recordId = (String) paramMap.get('recordId');

      Settlement__c settlement = SETTLEMENT_REPOSITORY.getSettlement(recordId);
      return LEX_API_REPOSITORY.getSettlement(
        settlement.Settlement_ID__c,
        settlement.Loan_Application_Number__r.Account.OCV_ID__c
      );
    } catch (Exception e) {
      Logger.error('Failure on Settlement API', e);
      Logger.saveLog();

      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
