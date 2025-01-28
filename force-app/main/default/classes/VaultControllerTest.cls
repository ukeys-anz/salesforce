/**
 * @description Test class for VaultController
 * @author Batya Aisman Sufrin
 * @since Jan 2025
 */
@isTest
private class VaultControllerTest {
  private static final Faker FAKER = new Faker('AU');

  private static final String MOCK_TOKENIZED_DOCUMENT_NUMBER = '##test@@';

  private static final String MOCK_DETOKENIZED_DOCUMENT_NUMBER = 'test';

  private static final String SUCCESS_TOKENIZE_DOCUMENT_NUMBER_RESPONSE =
    '{' +
    '    \"value\": \"' +
    MOCK_TOKENIZED_DOCUMENT_NUMBER +
    '\"' +
    '}';

  private static final String SUCCESS_DETOKENIZE_DOCUMENT_NUMBER_RESPONSE =
    '{' +
    '    \"value\": \"' +
    MOCK_DETOKENIZED_DOCUMENT_NUMBER +
    '\"' +
    '}';

  static Lib_MockProvider vaultApiRepoMock;

  static DetokenizeDocumentNumberResponseModel detokenizeDocNumberModel = DetokenizeDocumentNumberResponseModel.parse(
    SUCCESS_DETOKENIZE_DOCUMENT_NUMBER_RESPONSE
  );

  static TokenizeDocumentNumberResponseModel tokenizeDocNumberModel = TokenizeDocumentNumberResponseModel.parse(
    SUCCESS_TOKENIZE_DOCUMENT_NUMBER_RESPONSE
  );

  static void registerMocks() {
    vaultApiRepoMock = Lib_MockProvider.forType(VaultApiRepository.class);
  }

  static String customerId = FAKER.randomString(10);
  static String customerIdType = Service.IdType.OCVID.name();

  @isTest
  static void testDetokenizeDocumentNumberUnspecifiedDocError() {
    Test.startTest();
    try {
      VaultController.detokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_TOKENIZED_DOCUMENT_NUMBER,
        'DOCUMENT_TYPE_UNSPECIFIED'
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'An AuraHandledException should be thrown'
      );
    }
  }

  @isTest
  static void testDetokenizeDocumentNumberCalloutFailure() {
    registerMocks();
    vaultApiRepoMock.mockException(
      'detokenizeDocumentNumber',
      new CalloutException('Error calling out')
    );

    Test.startTest();
    try {
      VaultController.detokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_TOKENIZED_DOCUMENT_NUMBER,
        VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE.name()
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'An AuraHandledException should be thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testDetokenizeDocumentNumberCalloutSuccess() {
    registerMocks();
    vaultApiRepoMock.mock('detokenizeDocumentNumber', detokenizeDocNumberModel);

    String detokenizedDocNumber;
    Test.startTest();
    try {
      detokenizedDocNumber = VaultController.detokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_TOKENIZED_DOCUMENT_NUMBER,
        VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE.name()
      );
    } catch (Exception e) {
      Assert.fail('Exception shouldn\'t be thrown.');
    }
    Test.stopTest();

    Assert.isFalse(
      vaultApiRepoMock.getHistories('detokenizeDocumentNumber').isEmpty(),
      'tokenizeDocumentNumber call should have been made.'
    );
    Assert.isNotNull(detokenizedDocNumber, 'Response should not be null.');
  }

  @isTest
  static void testTokenizeDocumentNumberUnspecifiedDocError() {
    Test.startTest();
    try {
      VaultController.tokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_DETOKENIZED_DOCUMENT_NUMBER,
        'DOCUMENT_TYPE_UNSPECIFIED'
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'An AuraHandledException should be thrown'
      );
    }
  }

  @isTest
  static void testTokenizeDocumentNumberCalloutFailure() {
    registerMocks();
    vaultApiRepoMock.mockException(
      'tokenizeDocumentNumber',
      new CalloutException('Error calling out')
    );
    Test.startTest();
    try {
      VaultController.tokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_DETOKENIZED_DOCUMENT_NUMBER,
        VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE.name()
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'An AuraHandledException should be thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testTokenizeDocumentNumberCalloutSuccess() {
    registerMocks();
    vaultApiRepoMock.mock('tokenizeDocumentNumber', tokenizeDocNumberModel);

    String tokenizedDocNumber;
    Test.startTest();
    try {
      tokenizedDocNumber = VaultController.tokenizeDocumentNumber(
        customerId,
        customerIdType,
        MOCK_DETOKENIZED_DOCUMENT_NUMBER,
        VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE.name()
      );
    } catch (Exception e) {
      Assert.fail('Exception shouldn\'t be thrown.');
    }
    Test.stopTest();

    Assert.isFalse(
      vaultApiRepoMock.getHistories('tokenizeDocumentNumber').isEmpty(),
      'tokenizeDocumentNumber call should have been made.'
    );
    Assert.isNotNull(tokenizedDocNumber, 'Response should not be null.');
  }
}
