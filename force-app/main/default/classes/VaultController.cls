/**
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 * @description Controller class for legalNameDocuments lwc
 */
public with sharing class VaultController {
  private static final VaultApiRepository VAULT_API_REPOSITORY = (VaultApiRepository) Lib_InstanceProvider.forType(
    VaultApiRepository.class
  );

  private static final String UNSPECIFIED_DOCUMENT_TYPE = 'Unspecified Document Type';

  private static final String ERROR_DETOKENIZING_DATA = 'Error detokenizing Document Number';
  private static final String FAILED_DETOKENIZATION = 'Failed to perform detokenization. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  private static final String ERROR_TOKENIZING_DATA = 'Error tokenizing Document Number';
  private static final String FAILED_TOKENIZATION = 'Failed to perform tokenization. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description method to retrieve tokenized Document number and return to lwc component
   * @param customerId the customer Id
   * @param customerIdType the customer Id type
   * @param docNumber the document number
   * @param docType the document type
   * @return `String` tokenized document number
   */
  @AuraEnabled
  public static String tokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    String docNumber,
    String docType
  ) {
    VaultDocumentType documentType = getTypeFromString(docType);

    TokenizeDocumentNumberRequestModel tokenizeDocumentNumberRequest = new TokenizeDocumentNumberRequestModel(
      docNumber,
      documentType
    );

    try {
      return VAULT_API_REPOSITORY.tokenizeDocumentNumber(
          customerId,
          customerIdType,
          tokenizeDocumentNumberRequest
        )
        .value;
    } catch (Exception e) {
      Logger.error(ERROR_TOKENIZING_DATA, e).save();
      throw new AuraHandledException(FAILED_TOKENIZATION);
    }
  }

  /**
   * @description method to retrieve detokenized Document number and return to lwc component
   * @param customerId the customer Id
   * @param customerIdType the customer Id type
   * @param docNumber the document number
   * @param docType the document type
   * @return `String` detokenized document number
   */
  @AuraEnabled
  public static String detokenizeDocumentNumber(
    String customerId,
    String customerIdType,
    String docNumber,
    String docType
  ) {
    VaultDocumentType documentType = getTypeFromString(docType);

    DetokenizeDocumentNumberRequestModel detokenizeDocumentNumberRequest = new DetokenizeDocumentNumberRequestModel(
      docNumber,
      documentType
    );

    try {
      return VAULT_API_REPOSITORY.detokenizeDocumentNumber(
          customerId,
          customerIdType,
          detokenizeDocumentNumberRequest
        )
        .value;
    } catch (Exception e) {
      Logger.error(ERROR_DETOKENIZING_DATA, e).save();
      throw new AuraHandledException(FAILED_DETOKENIZATION);
    }
  }

  /**
   * @description method to retrieve VaultDocumentType from String
   * @param docType the document type
   * @return `VaultDocumentType` document type
   */
  private static VaultDocumentType getTypeFromString(String docType) {
    try {
      return VaultDocumentType.valueOf(docType);
    } catch (Exception e) {
      Logger.error(UNSPECIFIED_DOCUMENT_TYPE, e).save();
      throw new AuraHandledException(UNSPECIFIED_DOCUMENT_TYPE);
    }
  }
}
