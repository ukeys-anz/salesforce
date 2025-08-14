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
      String errorMessage = getCalloutExceptionErrorMessage(cex.getMessage());
      Logger.error(errorMessage);
      Logger.saveLog();
      throw new AuraHandledException(errorMessage);
    } catch (Exception e) {
      Logger.error(e.getMessage());
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

  /**
   * @description to create ANZ Plus loanapp using Service class
   * @param oppJson String opportunity JSON.
   * @param ut User_Territory__c
   * @return String
   */
  @AuraEnabled
  public static Map<String, String> createANZPlusLoanapp(
    String oppJson,
    User_Territory__c ut
  ) {
    try {
      Opportunity currentOpp = (Opportunity) JSON.deserialize(
        oppJson,
        Opportunity.class
      );
      ANZPlusLoanAppModel model = new ANZPlusLoanAppModel(currentOpp, ut);
      LoanAppAPIRepository loanappApi = new LoanAppAPIRepository();
      String response = loanappApi.anzPlusLoanAppCallout(model);
      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        response
      );
      if (
        !responseMap.containsKey('applicationId') ||
        responseMap.get('applicationId') == null
      ) {
        return new Map<String, String>{
          'status' => 'error',
          'message' => 'Application Id not received in response'
        };
      }
      String applicationId = String.valueOf(responseMap.get('applicationId'));
      DML.doUpdate(
        new Opportunity(
          Id = currentOpp.Id,
          Application_Numbers__c = applicationId
        ),
        new DmlConfig()
          .errorLog('Failed to update Opportunity application Number!')
      );
      return new Map<String, String>{
        'status' => 'success',
        'applicationId' => applicationId
      };
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description to create ANZ Plus loanapp using Service class
   * @param ownerId String opportunity ownerId.
   * @param territoryId String territoryId
   * @return User_Territory__c
   */
  @AuraEnabled
  public static User_Territory__c getUserTerritory(
    String ownerId,
    String territoryId
  ) {
    return LOANAPP_CTRL_REPOSITORY.getUserTerritory(ownerId, territoryId);
  }
}
