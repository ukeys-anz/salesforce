/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for CryptoOperationsUtils
 */
@isTest
public with sharing class CryptoOperationsUtilsTest { 
  static Lib_MockProvider vaultServiceRepoMock;

  static void registerMocks() {
    vaultServiceRepoMock = Lib_MockProvider.forType(VaultServiceRepository.class);
  }

 /**
 * @description test method for decryptDataWithIV 
 */
  @isTest
  public static void testDecryptDataWithIV() {
    registerMocks();
    vaultServiceRepoMock.mock(
      'retrievePrivateKey',
      CardDetailsControllerTest.MOCK_PRIVATE_KEY
    );
    DetokenizationResponseModel encryptedDataFromGCP = (DetokenizationResponseModel) JSON.deserialize(
      VaultServiceTest.MOCK_GCP_RESPONSE.body.toString(),
      DetokenizationResponseModel.class
    );
    Test.startTest();
    String detokenizedCardNumber = CryptoOperationsUtils.decryptDataWithIV(
    encryptedDataFromGCP.publicKeyId,
    encryptedDataFromGCP.initializationVector,
    encryptedDataFromGCP.encryptedData
    );
    Test.stopTest();

    Assert.areEqual(
    CardDetailsControllerTest.MOCK_TOKENIZED_CARD_NUMBER, 
    detokenizedCardNumber,
    'Full Card Number mock response should be received'
    );
    
    Assert.isFalse(
    vaultServiceRepoMock.getHistories('retrievePrivateKey').isEmpty(),
    'retrievePrivateKey should have been called and return a value'
    );
  }
    
}