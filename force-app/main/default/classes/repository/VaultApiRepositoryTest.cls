/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for VaultApiRepository
 */
@isTest
public with sharing class VaultApiRepositoryTest {
  private static final Faker FAKER = new Faker('AU');

  private static final String MOCK_TOKENIZED_DOCUMENT_NUMBER = 'dGVzdA==';
  private static final String MOCK_DETOKENIZED_DOCUMENT_NUMBER = 'test';

  private static String ocvId = FAKER.randomString(10);
  private static String customerId = FAKER.randomString(10);
  private static String customerIdType = Service.IdType.OCVID.name();

  private static final String EXCEPTION_MSG = 'Exception occured.';

  private static Lib_MockProvider userMock;

  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'View_Card_Number' });
  }

  /**
   * @description test method for getFullCardNumberDetails with Valid Permission
   */
  @isTest
  public static void testGetFullCardNumberDetailsValid() {
    registerMocks();
    Test.startTest();
    VaultApiRepository vaultapi = new VaultApiRepository();
    DetokenizationResponseModel encryptedDataFromGCP = vaultapi.getFullCardNumberDetails(
      '1111',
      CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER
    );
    Test.stopTest();

    Assert.isTrue(
      encryptedDataFromGCP.value != null,
      'DetokenizationResponseModel will be generated based on mock response'
    );
  }

  /**
   * @description test method for getFullCardNumberDetails for Invalid Permission
   */
  @isTest
  public static void testGetFullCardNumberDetailsInValid() {
    Exception resultException;
    Test.startTest();
    try {
      VaultApiRepository vaultapi = new VaultApiRepository();
      vaultapi.getFullCardNumberDetails(
        '1111',
        CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER
      );
    } catch (Exception objException) {
      resultException = objException;
    }
    Test.stopTest();

    Assert.areEqual(
      resultException.getMessage(),
      'User does not have permission to view full card number',
      'Exception was expected'
    );
  }

  @isTest
  static void testTokenizeDocumentNumberSuccess() {
    TokenizeDocumentNumberRequestModel tokenizeDocumentNumberRequest = new TokenizeDocumentNumberRequestModel(
      MOCK_DETOKENIZED_DOCUMENT_NUMBER,
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );
    VaultApiRepository vaultApi = new VaultApiRepository();

    Test.startTest();
    TokenizeDocumentNumberResponseModel response = vaultApi.tokenizeDocumentNumber(
      customerId,
      customerIdType,
      tokenizeDocumentNumberRequest
    );
    Test.stopTest();

    Assert.isTrue(
      String.isNotBlank(response.value),
      'Response should have valid tokenized value.'
    );
  }

  @isTest
  static void testTokenizeDocumentNumberFailure() {
    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(VaultService.class);
    s.setCalloutResponse(res);

    TokenizeDocumentNumberRequestModel tokenizeDocumentNumberRequest = new TokenizeDocumentNumberRequestModel(
      MOCK_DETOKENIZED_DOCUMENT_NUMBER,
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );
    VaultApiRepository vaultApi = new VaultApiRepository();
    Test.startTest();
    try {
      vaultApi.tokenizeDocumentNumber(
        customerId,
        customerIdType,
        tokenizeDocumentNumberRequest
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception e) {
      Assert.areEqual(EXCEPTION_MSG, e.getMessage(), 'Exception was expected.');
    }
    Test.stopTest();
  }

  @isTest
  static void testDetokenizeDocumentNumberSuccess() {
    DetokenizeDocumentNumberRequestModel detokenizeDocumentNumberRequest = new DetokenizeDocumentNumberRequestModel(
      MOCK_TOKENIZED_DOCUMENT_NUMBER,
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );
    VaultApiRepository vaultApi = new VaultApiRepository();
    Test.startTest();
    DetokenizeDocumentNumberResponseModel response = vaultApi.detokenizeDocumentNumber(
      customerId,
      customerIdType,
      detokenizeDocumentNumberRequest
    );
    Test.stopTest();

    Assert.isTrue(
      String.isNotBlank(response.value),
      'Response should have valid detokenized value.'
    );
  }

  @isTest
  static void testDetokenizeDocumentNumberFailure() {
    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(VaultService.class);
    s.setCalloutResponse(res);

    DetokenizeDocumentNumberRequestModel detokenizeDocumentNumberRequest = new DetokenizeDocumentNumberRequestModel(
      MOCK_TOKENIZED_DOCUMENT_NUMBER,
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );
    VaultApiRepository vaultApi = new VaultApiRepository();
    Test.startTest();
    try {
      vaultApi.detokenizeDocumentNumber(
        customerId,
        customerIdType,
        detokenizeDocumentNumberRequest
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception e) {
      Assert.areEqual(EXCEPTION_MSG, e.getMessage(), 'Exception was expected.');
    }
    Test.stopTest();
  }

  /**
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(EXCEPTION_MSG);
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
