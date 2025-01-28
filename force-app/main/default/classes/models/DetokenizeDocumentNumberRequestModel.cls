/**
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 * @description Request Model for Deokenized Document Number
 */
public with sharing class DetokenizeDocumentNumberRequestModel extends CalloutModel {
  /**
   * @description Detokenized document number value
   */
  public String value;
  /**
   * @description Applicable document type
   */
  public VaultDocumentType type;

  /**
   * @description Constructor
   * @param value Document number value
   * @param type Document type
   */
  public DetokenizeDocumentNumberRequestModel(
    String value,
    VaultDocumentType type
  ) {
    this.value = value;
    this.type = type;
  }
}
