/**
 * @author Peter Charalambous
 * @since Fri Oct 27 2023
 * @description Model for Verify insurance call
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions, PMD.ExcessivePublicCount')
public class VerifyInsuranceModel extends CalloutModel {
  @AuraEnabled
  public String settlementId;
  @AuraEnabled
  public String mortgageContractId;
  @AuraEnabled
  public String propertyId;
  @AuraEnabled
  public ProofOfInsuranceVerification proofOfInsuranceVerification;


  /**
   * @description verify insurance proof of insurance verification information
   */
  public class ProofOfInsuranceVerification {
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String documentId;
    @AuraEnabled
    public Integer documentFileVersion;
  }

  /**
   * @param json input string to deserialize
   * @return `VerifyInsuranceModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static VerifyInsuranceModel parse(String json) {
    return (VerifyInsuranceModel) System.JSON.deserialize(
      json,
      VerifyInsuranceModel.class
    );
  }
}
