/**
 * @author Peter Charalambous
 * @since Fri Oct 27 2023
 * @description Model for Verify insurance call
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions, PMD.ExcessivePublicCount')
public class VerifyInsuranceModel extends CalloutModel {
  /**
   * @description verify insurance create time information
   */
  public class CreateTime {
    public Integer seconds;
    public Integer nanos;
  }

  @AuraEnabled
  public String settlement_id;
  @AuraEnabled
  public String mortgage_contract_id;
  @AuraEnabled
  public String property_id;
  @AuraEnabled
  public Document document;
  @AuraEnabled
  public ProofOfInsuranceVerification proof_of_insurance_verification;

  /**
   * @description verify insurance create by information
   */
  public class CreateBy {
    public String id;
  }

  /**
   * @description verify insurance proof of insurance verification information
   */
  public class ProofOfInsuranceVerification {
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String document_id;
    @AuraEnabled
    public Integer document_file_version;
    @AuraEnabled
    public CreateBy create_by;
    @AuraEnabled
    public CreateTime create_time;
    @AuraEnabled
    public CreateBy update_by;
    @AuraEnabled
    public CreateTime update_time;
  }

  /**
   * @description verify insurance document information
   */
  public class Document {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public CreateTime create_time;
    @AuraEnabled
    public Integer state;
    @AuraEnabled
    public String document_storage_id;
    @AuraEnabled
    public Integer document_storage_status;
    @AuraEnabled
    public List<DocumentFileDetails> document_file_details;
    @AuraEnabled
    public Integer source;
  }

  /**
   * @description verify insurance document file information
   */
  public class DocumentFileDetails {
    @AuraEnabled
    public String document_file_id;
    @AuraEnabled
    public Integer document_file_version;
    @AuraEnabled
    public Integer document_file_status;
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
