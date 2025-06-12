/**
 * @description Test class for COBTaxResidencyViewController
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
@isTest
private class COBTaxResidencyViewControllerTest {
  static final String TOKENIZED_TIN = 'Q2CmJdCA0';
  static final String DETOKENIZED_TIN = 'PA0940444';
  static final String DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE =
    '{' +
    '  \"values\": [' +
    '    {' +
    '      \"Tokenized\": \"' +
    TOKENIZED_TIN +
    '\",' +
    '      \"Detokenized\": \"' +
    DETOKENIZED_TIN +
    '\"' +
    '    }' +
    '  ]' +
    '}';

  static Lib_MockProvider stravinskyApiRepoMock;

  static void registerMocks() {
    stravinskyApiRepoMock = Lib_MockProvider.forType(
      StravinskyAPIRepository.class
    );
  }

  static COBTaxResidency__c taxResidency = new COBTaxResidency__c(
    TaxIdentificationNumber__c = TOKENIZED_TIN
  );

  static COBTaxResidencyModel cobTaxResidency = COBTaxResidencyModel.parse(
    DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE
  );

  @isTest
  private static void testDetokenizeCOBTaxResidencyDataSuccessful() {
    registerMocks();
    stravinskyApiRepoMock.mock(
      'cobTaxResidencyDetokenization',
      cobTaxResidency
    );

    String detokenizedValue;
    Test.startTest();
    try {
      detokenizedValue = COBTaxResidencyViewController.detokenizeCOBTaxResidencyData(
        taxResidency
      );
    } catch (Exception ex) {
      Assert.fail('Exception shouldn\'t be thrown');
    }
    Test.stopTest();

    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('cobTaxResidencyDetokenization')
        .isEmpty(),
      'cobTaxResidencyDetokenization call should have been made.'
    );
    Assert.isNotNull(detokenizedValue, 'Detokenized Value should not be null.');
  }

  @isTest
  private static void testDetokenizeCOBTaxResidencyDataCalloutException() {
    registerMocks();
    stravinskyApiRepoMock
      .mockException(
        'cobTaxResidencyDetokenization',
        new CalloutException('Error calling out')
      );

    String detokenizedValue = null;
    Test.startTest();
    try {
      detokenizedValue = COBTaxResidencyViewController.detokenizeCOBTaxResidencyData(
        taxResidency
      );
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.areEqual(
        null,
        detokenizedValue,
        'Detokenized Value should not have been updated.'
      );
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }
}
