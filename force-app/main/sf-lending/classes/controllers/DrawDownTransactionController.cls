/**
 * @author @fangl6
 * @since June 2025
 * @description Drawdown Transaction controller
 */
public with sharing class DrawDownTransactionController implements IGenericClass {
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  private static final String ERROR_MSG = 'Failed to retrieve Drawdown details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  /**
   * @description getData method to return Drawdown Transaction data
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
      return enrichResponseData(
        LEX_API_REPOSITORY.getDrawdown(
          (String) params.get('id'),
          settlement.Loan_Application_Number__r.Account.OCV_ID__c
        ),
        'scheduledReason'
      );
    } catch (Exception e) {
      Logger.error('Failure on get Drawdown', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }

  private LexSLMV1alpha2LoanManagementTypes.Drawdown enrichResponseData(
    LexSLMV1alpha2LoanManagementTypes.Drawdown response,
    String condition
  ) {
    switch on condition {
      when 'scheduledReason' {
        if (response?.state != 'STATE_SCHEDULED') {
          response.scheduledReason = '';
        }
      }
    }
    return response;
  }
}
