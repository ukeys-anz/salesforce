/**
 * @description Test class for COBTaxResidencyViewController
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
@isTest
public with sharing class COBTaxResidencyViewControllerTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();
    insert cobApp;

    COBTaxResidency__c taxResidency = new COBTaxResidency__c(
      TaxIdentificationNumber__c = StravinskyServiceMock.TOKENIZED_TIN,
      PersonaId__c = faker.randomString(15),
      CustomerOnboardingApplication__c = cobApp.Id
    );

    insert taxResidency;
  }

  private static COBTaxResidency__c getTaxResidency() {
    return [
      SELECT Id, PersonaId__c, TaxIdentificationNumber__c
      FROM COBTaxResidency__c
    ];
  }

  @isTest
  private static void testDetokenizeCOBTaxResidencyDataSuccessful() {
    COBTaxResidency__c taxResidency = getTaxResidency();

    Test.startTest();
    String detokenizedValue = COBTaxResidencyViewController.detokenizeCOBTaxResidencyData(
      taxResidency
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      detokenizedValue,
      'Detokenized value should not be null.'
    );
    Assert.areEqual(
      StravinskyServiceMock.DETOKENIZED_TIN,
      detokenizedValue,
      'Detokenized value is not correct.'
    );
  }

  @isTest
  private static void testDetokenizeCOBTaxResidencyDataCalloutException() {
    COBTaxResidency__c taxResidency = getTaxResidency();

    StravinskyAPIRepository.throwException = true; // Simulate a callout exception

    String detokenizedValue = null;
    Test.startTest();
    try {
      detokenizedValue = COBTaxResidencyViewController.detokenizeCOBTaxResidencyData(
        taxResidency
      );
    } catch (Exception e) {
      Assert.areEqual(
        null,
        detokenizedValue,
        'Detokenized Value should not have been updated.'
      );
      Assert.areEqual(
        true,
        e.getMessage()
          .contains(COBTaxResidencyViewController.FAILED_DETOKENIZATION),
        'Exception should have been thrown.'
      );
    }
    Test.stopTest();
  }
}
