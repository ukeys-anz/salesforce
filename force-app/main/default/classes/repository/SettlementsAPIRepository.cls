/**
 * @author Peter Charalambous
 * @since October 2023
 * @description Settlements API repository
 * @group Repository
 */
public with sharing class SettlementsAPIRepository extends RepositoryBase {
  /**
   * @param poiDetails proof of insurance details
   * @return `VerifyInsuranceModel`
   * @description Verifies a customers proof of insurance
   */
  public VerifyInsuranceModel verifyInsurance(
    Proof_of_Insurance__c poiDetails
  ) {
    Service s = ServiceProvider.getService(BOHService.class);

    //Populate request body
    ProofOfInsuranceVerification poiVerification = new ProofOfInsuranceVerification();
    poiVerification.documentId = poiDetails.Document_Id__c;
    poiVerification.documentFileVersion = poiDetails.Document_File_Version__c;

    VerifyInsuranceRequestBody requestBody = new VerifyInsuranceRequestBody();
    requestBody.settlementId = poiDetails.Settlement_ID__r.Settlement_ID__c;
    requestBody.mortgageContractId = poiDetails.Mortgage_Contract_ID__c;
    requestBody.propertyId = poiDetails.Property_ID__c;
    requestBody.proofOfInsuranceVerification = poiVerification;

    HttpCalloutResponse response = s.verifyInsurance(
      json.serialize(requestBody),
      poiDetails.Settlement_ID__r.Loan_Application_Number__r.Account.OCV_ID__c
    );
    if (response.successful == false) {
      throw response.error;
    }

    VerifyInsuranceModel verifyInsurance;
    try {
      verifyInsurance = VerifyInsuranceModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, SettlementsAPIRepository.class);
    }

    return verifyInsurance;
  }

  /**
   * @description VerifyInsuranceRequestBody returns request body of verifyInsurance call
   */
  public class VerifyInsuranceRequestBody {
    public String settlementId;
    public String mortgageContractId;
    public String propertyId;
    public ProofOfInsuranceVerification proofOfInsuranceVerification;
  }

  /**
   * @description ProofOfInsuranceVerification returns request body of verifyInsurance call
   */
  public class ProofOfInsuranceVerification {
    public String documentId;
    public String documentFileVersion;
  }
}
