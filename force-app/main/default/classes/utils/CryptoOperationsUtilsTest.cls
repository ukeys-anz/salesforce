/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for CryptoOperationsUtils
 */
@isTest
public with sharing class CryptoOperationsUtilsTest { 
  
  //Mock Tokenized Card Number and Private Key for test class to be used in other test classes
  public static final String MOCK_TOKENIZED_CARD_NUMBER = '8051997368527878';
  public static final String MOCK_PRIVATE_KEY = 'O0zkiWYRjkrVisuHCb3iUzp3E9CekUH6R7s6lpp2XZE=';
  public static final StaticResource MOCK_GCP_RESPONSE = [
        SELECT body
        FROM StaticResource
        WHERE Name = 'mock_fullCardNumberSuccess'
      ];

  static Lib_MockProvider keyServiceRepoMock;

  static void registerMocks() {
    keyServiceRepoMock = Lib_MockProvider.forType(KeyServiceRepository.class);
  }

 /**
 * @description test method for decryptDataWithIV 
 */
  @isTest
  public static void testDecryptDataWithIV() {
    registerMocks();
    keyServiceRepoMock.mock(
      'retrievePrivateKey',
      createMockPrivateKeyStorageList()
    );
    DetokenizationResponseModel encryptedDataFromGCP = (DetokenizationResponseModel) JSON.deserialize(
      MOCK_GCP_RESPONSE.body.toString(),
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
    MOCK_TOKENIZED_CARD_NUMBER, 
    detokenizedCardNumber,
    'Full Card Number mock response should be received'
    );
    
    Assert.isFalse(
    vaultServiceRepoMock.getHistories('retrievePrivateKey').isEmpty(),
    'retrievePrivateKey should have been called and return a value'
    );
  }
   
   /**
   * @description method to prepare mock private key storage to be used for other test classes as well
   * @return List<PrivateKeyStorage__c> mock list of PPrivateKeyStorage__cr
   */
  public static List<PrivateKeyStorage__c> createMockPrivateKeyStorageList(){
    PrivateKeyStorage__c mockPrivateKey = new PrivateKeyStorage__c();
    mockPrivateKey.Private_Key__c = MOCK_PRIVATE_KEY;
    return new List<PrivateKeyStorage__c>{mockPrivateKey};
  }
}