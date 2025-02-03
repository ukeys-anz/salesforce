/**
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 * @description Request Model for Tokenized Document Number
 */
public with sharing class TokenizeDocumentNumberRequestModel extends CalloutModel {
  /**
   * @description Tokenized document number value
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
  public TokenizeDocumentNumberRequestModel(
    String value,
    VaultDocumentType type
  ) {
    this.value = value;
    this.type = type;
  }
}
