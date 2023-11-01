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
  public String settlementId;
  @AuraEnabled
  public String mortgageContractId;
  @AuraEnabled
  public String propertyId;
  @AuraEnabled
  public Document document;
  @AuraEnabled
  public ProofOfInsuranceVerification proofOfInsuranceVerification;

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
    public String documentId;
    @AuraEnabled
    public Integer documentFileVersion;
    @AuraEnabled
    public CreateBy createBy;
    @AuraEnabled
    public CreateTime createTime;
    @AuraEnabled
    public CreateBy updateBy;
    @AuraEnabled
    public CreateTime updateTime;
  }

  /**
   * @description verify insurance document information
   */
  public class Document {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public CreateTime createTime;
    @AuraEnabled
    public Integer state;
    @AuraEnabled
    public String documentStorageId;
    @AuraEnabled
    public Integer documentStorageStatus;
    @AuraEnabled
    public List<DocumentFileDetails> documentFileDetails;
    @AuraEnabled
    public Integer source;
  }

  /**
   * @description verify insurance document file information
   */
  public class DocumentFileDetails {
    @AuraEnabled
    public String documentFileId;
    @AuraEnabled
    public Integer documentFileVersion;
    @AuraEnabled
    public Integer documentFileStatus;
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
