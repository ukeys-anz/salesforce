/**
 * @description Test class for {@link COBPIDTriggerHandler}
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
@isTest
public with sharing class COBPIDTriggerHandlerTest {
  private static final String NON_OCR_LICENCE_NUMBER = '123456789';
  private static final String NON_OCR_LICENCE_CARD_NUMBER = 'LC-88888';
  private static final String NON_OCR_PASSPORT_NUMBER = 'PB-454545';
  private static final String NON_OCR_FIRST_NAME = 'First';
  private static final String NON_OCR_LAST_NAME = 'Last';
  private static final Date NON_OCR_DATE_OF_BIRTH = Date.today();

  private static final String SERVER_OCR_MATCHING_LICENCE_NUMBER = '123456789';
  private static final String SERVER_OCR_MATCHING_LICENCE_CARD_NUMBER = 'LC-88888';
  private static final String SERVER_OCR_MATCHING_PASSPORT_NUMBER = 'PB-454545';
  private static final String SERVER_OCR_MATCHING_FIRST_NAME = 'First';
  private static final String SERVER_OCR_MATCHING_LAST_NAME = 'Last';
  private static final Date SERVER_OCR_MATCHING_DATE_OF_BIRTH = Date.today();

  private static final String SERVER_OCR_NON_MATCHING_LICENCE_NUMBER = '987654321';
  private static final String SERVER_OCR_NON_MATCHING_LICENCE_CARD_NUMBER = 'LC-000000';
  private static final String SERVER_OCR_NON_MATCHING_PASSPORT_NUMBER = 'PB-898989';
  private static final String SERVER_OCR_NON_MATCHING_FIRST_NAME = 'FirstFirst';
  private static final String SERVER_OCR_NON_MATCHING_LAST_NAME = 'LastLast';
  private static final Date SERVER_OCR_NON_MATCHING_DATE_OF_BIRTH =
    Date.today() + 1;

  private static final Integer SIZE = Integer.valueOf(Label.Test_Bulk_Size);

  @TestSetup
  private static void makeData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    for (Integer i = 0; i < SIZE; i++) {
      CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();
      cobApps.add(cobApp);
    }

    insert cobApps;
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [SELECT Id FROM CustomerOnboardingApplication__c];
  }

  private static List<COBPrimaryIDDocument__c> createCobPid() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();
    List<COBPrimaryIDDocument__c> cobPids = new List<COBPrimaryIDDocument__c>();
    for (Integer i = 0; i < SIZE; i++) {
      COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
      cobPid.CustomerOnboardingApplication__c = cobApps[i].id;

      cobPid.LicenceNumber__c = NON_OCR_LICENCE_NUMBER;
      cobPid.LicenceNumberOCRServer__c = SERVER_OCR_MATCHING_LICENCE_NUMBER;
      cobPid.LicenceCardNumber__c = NON_OCR_LICENCE_CARD_NUMBER;
      cobPid.LicenceCardNumberOCRServer__c = SERVER_OCR_MATCHING_LICENCE_CARD_NUMBER;
      cobPid.PassportNumber__c = NON_OCR_PASSPORT_NUMBER;
      cobPid.PassportNumberOCRServer__c = SERVER_OCR_MATCHING_PASSPORT_NUMBER;
      cobPid.FirstName__c = NON_OCR_FIRST_NAME;
      cobPid.FirstNameOCRServer__c = SERVER_OCR_MATCHING_FIRST_NAME;
      cobPid.LastName__c = NON_OCR_LAST_NAME;
      cobPid.LastNameOCRServer__c = SERVER_OCR_MATCHING_LAST_NAME;
      cobPid.DateOfBirth__c = NON_OCR_DATE_OF_BIRTH;
      cobPid.DateOfBirthOCRServer__c = SERVER_OCR_MATCHING_DATE_OF_BIRTH;

      cobPids.add(cobPid);
    }

    return cobPids;
  }

  private static List<COBPrimaryIDDocument__c> getCobPid() {
    return [
      SELECT
        LicenceNumberOCRMatch__c,
        LicenceCardNumberOCRMatch__c,
        PassportNumberOCRMatch__c,
        FirstNameOCRMatch__c,
        LastNameOCRMatch__c,
        DateOfBirthOCRMatch__c
      FROM COBPrimaryIDDocument__c
    ];
  }

  //Test setting OCRMach fields on beforeInsert
  @isTest
  public static void testSetOCRMatchOnBeforeInsert() {
    List<COBPrimaryIDDocument__c> cobPids = createCobPid();

    Test.startTest();
    insert cobPids;
    Test.stopTest();

    //get inserted COB Primary ID Documents
    List<COBPrimaryIDDocument__c> insertedCobPids = getCobPid();

    Assert.areEqual(
      SIZE,
      insertedCobPids.size(),
      SIZE + ' new COB Primary ID Documents should have been created.'
    );

    Assert.isTrue(
      insertedCobPids[0].LicenceNumberOCRMatch__c,
      'Licence Number OCR Match should be true'
    );

    Assert.isTrue(
      insertedCobPids[0].LicenceCardNumberOCRMatch__c,
      'Licence Card Number OCR Match should be true'
    );

    Assert.isTrue(
      insertedCobPids[0].PassportNumberOCRMatch__c,
      'Passport Number OCR Match should be true'
    );

    Assert.isTrue(
      insertedCobPids[0].FirstNameOCRMatch__c,
      'First Name OCR Match should be true'
    );

    Assert.isTrue(
      insertedCobPids[0].LastNameOCRMatch__c,
      'Last Name OCR Match should be true'
    );

    Assert.isTrue(
      insertedCobPids[0].DateofBirthOCRMatch__c,
      'Date Of Birth OCR Match should be true'
    );
  }

  @isTest
  public static void testSetOCRMatchOnBeforeUpdate() {
    List<COBPrimaryIDDocument__c> cobPids = createCobPid();
    for (Integer i = 0; i < SIZE; i++) {
      cobPids[i]
        .LicenceNumberOCRServer__c = SERVER_OCR_NON_MATCHING_LICENCE_NUMBER;
      cobPids[i]
        .LicenceCardNumberOCRServer__c = SERVER_OCR_NON_MATCHING_LICENCE_CARD_NUMBER;
      cobPids[i]
        .PassportNumberOCRServer__c = SERVER_OCR_NON_MATCHING_PASSPORT_NUMBER;
      cobPids[i].FirstNameOCRServer__c = SERVER_OCR_NON_MATCHING_FIRST_NAME;
      cobPids[i].LastNameOCRServer__c = SERVER_OCR_NON_MATCHING_LAST_NAME;
      cobPids[i]
        .DateOfBirthOCRServer__c = SERVER_OCR_NON_MATCHING_DATE_OF_BIRTH;
    }

    insert cobPids;

    Test.startTest();
    update cobPids;
    Test.stopTest();

    //get updated COB Primary ID Documents
    List<COBPrimaryIDDocument__c> updatedCobPids = getCobPid();

    Assert.isFalse(
      updatedCobPids[0].LicenceNumberOCRMatch__c,
      'Licence Number OCR Match should be false'
    );

    Assert.isFalse(
      updatedCobPids[0].LicenceCardNumberOCRMatch__c,
      'Licence Card Number OCR Match should be false'
    );

    Assert.isFalse(
      updatedCobPids[0].PassportNumberOCRMatch__c,
      'Passport Number OCR Match should be false'
    );

    Assert.isFalse(
      updatedCobPids[0].FirstNameOCRMatch__c,
      'First Name OCR Match should be false'
    );

    Assert.isFalse(
      updatedCobPids[0].LastNameOCRMatch__c,
      'Last Name OCR Match should be false'
    );

    Assert.isFalse(
      updatedCobPids[0].DateofBirthOCRMatch__c,
      'Date Of Birth OCR Match should be false'
    );
  }
}
