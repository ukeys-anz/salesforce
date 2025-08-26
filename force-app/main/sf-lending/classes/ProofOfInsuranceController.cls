/**
 * @author Peter Charalambous
 * @since October 2023
 * @description handles verifying customer proof of insurance
 */
public with sharing class ProofOfInsuranceController implements IGenericClass {
  public static final String TECH_ASSIST_ERROR = 'Verify Insurance Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String MISSING_DATA_ERROR = 'Missing Proof of Insurance data. Please correct and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String ERROR_MSG = 'Failed to retrieve Proof Of Insurance details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final LexAPIRepository LEX_API_REPOSITORY = (LexAPIRepository) Lib_InstanceProvider.forType(
    LexAPIRepository.class
  );
  private static final SettlementRepository SETTLEMENT_REPOSITORY = (SettlementRepository) Lib_InstanceProvider.forType(
    SettlementRepository.class
  );
  /**
   * @description Verifies a customers proof of insurance
   * @param settlementId Record id of settlement to verify
   * @param mortgageContractId Record id of mortgage to verify
   * @param propertyId Record id of property to verify
   * @param documentId Record id of document to verify
   * @param documentFileVersion Record id of documentFileVersion to verify
   * @return `VerifyInsuranceModel` if verification call was successful
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  @AuraEnabled
  public static VerifyInsuranceModel verifyInsurance(
    String settlementId,
    String mortgageContractId,
    String propertyId,
    String documentId,
    String documentFileVersion
  ) {
    Settlement__c settlement = SETTLEMENT_REPOSITORY.getSettlementBySettlementId(
      settlementId
    );

    VerifyInsuranceWrapper poiDetails = new VerifyInsuranceWrapper();
    poiDetails.settlementId = settlementId;
    poiDetails.mortgageContractId = mortgageContractId;
    poiDetails.propertyId = propertyId;
    poiDetails.documentId = documentId;
    poiDetails.documentFileVersion = documentFileVersion;
    poiDetails.ocvId = settlement?.Loan_Application_Number__r.Account.OCV_ID__c;

    try {
      if (!checkFieldSanity(poiDetails)) {
        throw new AuraHandledException(MISSING_DATA_ERROR);
      }
      VerifyInsuranceModel response = LEX_API_REPOSITORY.verifyInsurance(
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

  private static Boolean checkFieldSanity(VerifyInsuranceWrapper poi) {
    return String.isNotBlank(poi.settlementId) &&
      String.isNotBlank(poi.mortgageContractId) &&
      String.isNotBlank(poi.propertyId) &&
      String.isNotBlank(poi.documentId) &&
      String.isNotBlank(poi.documentFileVersion);
  }

  /**
   * @description VerifyInsuranceWrapper wrapper class for verify insurance
   */
  public class VerifyInsuranceWrapper {
    public String settlementId;
    public String mortgageContractId;
    public String propertyId;
    public String documentId;
    public String documentFileVersion;
    public String ocvId;
  }

  /**
   * @description getData method to return settlement data
   * @param param Parameter to pass to the getData method (record id)
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
      return LEX_API_REPOSITORY.getProofOfInsurance(
        settlement.Settlement_ID__c,
        settlement.Loan_Application_Number__r.Account.OCV_ID__c
      );
    } catch (Exception e) {
      Logger.error('Failure on Get Proof Of Insurance API', e);
      Logger.saveLog();

      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
