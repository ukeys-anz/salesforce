/**
 * @author Peter Charalambous
 * @since October 2023
 * @description handles verifying customer proof of insurance
 */
public with sharing class ProofOfInsuranceController {
  public static final String TECH_ASSIST_ERROR = 'Verify Insurance Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String MISSING_DATA_ERROR = 'Missing Proof of Insurance data. Please correct and try again. Raise a fault through TechAssist if the problem persists.';
  /**
   * @description Verifies a customers proof of insurance
   * @param recordId Record id of proof of insurance to verify
   * @return `VerifyInsuranceModel` if verification call was successful
   */
  @AuraEnabled
  public static VerifyInsuranceModel verifyInsurance(Id recordId) {
    PermissionUtils.canQuery('Proof_of_Insurance__c');

    Proof_of_Insurance__c poiDetails = [
      SELECT
        Settlement_ID__c,
        Mortgage_Contract_ID__c,
        Property_ID__c,
        Document_Id__c,
        Document_File_Version__c,
        Settlement_ID__r.Loan_Application_Number__r.Account.OCV_ID__c
      FROM Proof_of_Insurance__c
      WHERE Id = :recordId
    ];

    try {
      if (!checkFieldSanity(poiDetails)) {
        throw new AuraHandledException(MISSING_DATA_ERROR);
      }
      SettlementsAPIRespository settlementsAPI = new SettlementsAPIRespository();
      VerifyInsuranceModel response = settlementsAPI.verifyInsurance(
        poiDetails
      );

      return response;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      e.setMessage(TECH_ASSIST_ERROR);
      throw e;
    }
  }

  private static Boolean checkFieldSanity(Proof_of_Insurance__c poi) {
    return String.isNotBlank(poi.Settlement_ID__c) &&
      String.isNotBlank(poi.Mortgage_Contract_ID__c) &&
      String.isNotBlank(poi.Property_ID__C) &&
      String.isNotBlank(poi.Document_Id__c) &&
      String.isNotBlank(poi.Document_File_Version__c);
  }
}
