/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for VaultApiRepository
 */
@isTest
public with sharing class VaultApiRepositoryTest {
    /**
	* @description Add required PermissionSet
	*/
    @testSetup
    public static void setup() {
        TestUtil.addPermissionSets(new List<String>{'View_Card_Number'});
    }

    /**
    * @description test method for getFullCardNumberDetails with Valid Permission
    */
    @isTest
    public static void testGetFullCardNumberDetailsValid() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	System.runAs(thisUser) {
            Test.startTest();
            VaultApiRepository vaultapi = new VaultApiRepository();
            DetokenizationResponseModel encryptedDataFromGCP = vaultapi.getFullCardNumberDetails(
                '1111',
                CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER
            );
            Test.stopTest();
            
            Assert.isTrue(
                encryptedDataFromGCP.encryptedData != null,
                'DetokenizationResponseModel will be generated based on mock response'
            );
        }
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
            DetokenizationResponseModel encryptedDataFromGCP = vaultapi.getFullCardNumberDetails(
                '1111',
                CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER
            );
        }
        catch (Exception objException) {
            resultException = objException;
        }
        Test.stopTest();
        
        Assert.areEqual(
            resultException.getMessage(),
            'User does not have the get full card number permission',
            'Exception was expected'
        );
      }
}