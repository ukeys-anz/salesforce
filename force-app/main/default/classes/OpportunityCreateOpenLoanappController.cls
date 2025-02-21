/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group Platform
 * @description Used as a controller for opportunityCreateOpenLoanapp LWC.
 */
public with sharing class OpportunityCreateOpenLoanappController {
  private static final OpportunityCreateOpenLoanappRepository LOANAPP_CTRL_REPOSITORY = (OpportunityCreateOpenLoanappRepository) Lib_InstanceProvider.forType(
    OpportunityCreateOpenLoanappRepository.class
  );

  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description to get the opportunity details
   * @param recordId String
   * @return Opportunity
   */
  @AuraEnabled
  public static String getOpportunityDetails(String recordId) {
    try {
      Opportunity currentOpp = LOANAPP_CTRL_REPOSITORY.getOpportunity(recordId);
      return JSON.serialize(currentOpp); //to preserve OCR Related list
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description to create loanapp using Service class
   * @param oppJson String
   * @param isOpen to identify Open Loanapp req
   * @return Opportunity
   */
  @AuraEnabled
  public static String createOpenLoanApp(String oppJson, Boolean isOpen) {
    try {
      if (String.isBlank(oppJson)) {
        return null;
      }
      Opportunity currentOpp = (Opportunity) JSON.deserialize(
        oppJson,
        Opportunity.class
      ); //to preserve OCR Related list
      LoanappModel requestModel = OpportunityCreateOpenLoanappHelper.createOpenLoanAppRequestBody(
        currentOpp,
        isOpen
      );
      LoanappService service = new LoanappService();
      String appKey = service.getCreateApplicationCalloutResponse(requestModel);
      return appKey;
    } catch (CalloutException cex) {
<<<<<<< HEAD
      String errorMessage = cex.getMessage();
      try {
        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(
          errorMessage
        );
        errorMessage = String.valueOf(
          errorMap?.get('message') ?? cex.getMessage()
        );
      } catch (Exception e) {
        Logger.info('Unable to parse JSON, error is not of JSON type!');
      }
=======
      String errorMessage = getCalloutExceptionErrorMessage(cex.getMessage());
>>>>>>> develop
      Logger.error(errorMessage + '\n' + cex.getStackTraceString());
      Logger.saveLog();
      throw new AuraHandledException(errorMessage);
    } catch (Exception e) {
      Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description to create loanapp using Service class
   * @param opp Opportunity
   */
  @AuraEnabled
  public static void updateOpportunity(Opportunity opp) {
    try {
      if (opp == null) {
        return;
      }
      DML.doUpdate(
        opp,
        new DMLConfig()
          .systemMode()
          .errorLog('Failed to update Opportunity application key!')
      );
    } catch (exception e) {
      Logger.error('Failure on Opportunity update!', opp.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }
<<<<<<< HEAD
=======

  /**
   * @description to handle callout exception error
   * @param errorMsg
   * @return String
   */
  public static String getCalloutExceptionErrorMessage(String errorMsg) {
    try {
      Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(
        errorMsg
      );
      return String.valueOf(errorMap?.get('message') ?? errorMsg);
    } catch (Exception e) {
      Logger.info('Unable to parse JSON, error is not of JSON type!');
      return errorMsg;
    }
  }
>>>>>>> develop
}
