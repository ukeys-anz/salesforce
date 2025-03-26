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
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
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
   * @return SOPViewModel for successful updateSOPAndParty exection
   */
  @AuraEnabled
  public static SOPViewModel updateSOPAndParty(
    SOPViewModel sopModel,
    Id loanId
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }
      List<Object> urlParameters = new List<Object>{
        loanRec.SOP_Id__c,
        sopModel?.isSOPDataUpdated ?? false,
        sopModel?.isPartyDataUpdated ?? false
      };

      SOPUpdateSOPAndPartyRequestModel sopRequestModel = new SOPUpdateSOPAndPartyRequestModel(
        sopModel
      );

      SOPViewModel response = SOP_API_REPOSITORY.updateSOPAndParty(
        loanRec.Account?.OCV_ID__c,
        sopRequestModel,
        urlParameters
      );
      response.parties = SOPUpdateSOPandPartyHelper.transformPartiesList(
        response
      );
      return response;
    } catch (Exception e) {
      Logger.info('Failure on Update SOP And Party callout', e);
      Logger.saveLog();
      return null;
    }
  }
}
