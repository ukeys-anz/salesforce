/**
 * @description controller class for sop page
 * @author raman
 * @since March 2025
 */
public with sharing class BOHController {
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final SOPAPIRepository SOP_API_REPOSITORY = (SOPAPIRepository) Lib_InstanceProvider.forType(
    SOPAPIRepository.class
  );

  /**
   * @description method to invoke getSOP
   * @param loanId
   * @return SOPViewModel for successful getSOP execution
   */
  @AuraEnabled
  public static SOPViewModel getSOP(Id loanId) {
    try {
      if (loanId == null) {
        throw new AuraHandledException('Loan Id cannot be null');
      }
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new AuraHandledException('Valid Loan Record not found');
      }

      SOPViewModel response = SOP_API_REPOSITORY.getSOP(
        loanRec.Account?.OCV_ID__c,
        loanRec.SOP_Id__c
      );
      response.parties = SOPUpdateSOPandPartyHelper.transformPartiesList(
        response
      );
      return response;
    } catch (Exception e) {
      Logger.info('Failure on Get SOP callout', e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description method to invoke updateSOPAndParty
   * @param sopModel
   * @param loanId
   * @param ocvId
   * @return SOPViewModel for successful updateSOPAndParty exection
   */
  @AuraEnabled
  public static SOPViewModel updateSOPAndParty(
    SOPViewModel sopModel,
    Id loanId,
    String ocvId
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }
      List<String> urlParameters = new List<String>{
        loanRec.SOP_Id__c,
        String.valueOf(sopModel.isSOPDataUpdated ?? false),
        String.valueOf(sopModel.isPartyDataUpdated ?? false)
      };

      SOPUpdateSOPAndPartyRequestModel sopRequestModel = new SOPUpdateSOPAndPartyRequestModel(
        sopModel
      );

      SOPViewModel response = SOP_API_REPOSITORY.updateSOPAndParty(
        ocvId,
        sopRequestModel,
        urlParameters
      );
      response.parties = SOPUpdateSOPandPartyHelper.transformPartiesList(
        response
      );

      //updating reasessment if any of the API success.
      SOPHelper.setToReassessmentIsRequired(loanId);

      return response;
    } catch (Exception e) {
      throw new AuraHandledException(
        'The changes to the About You did not save. Please review and try again.'
      );
    }
  }
}
