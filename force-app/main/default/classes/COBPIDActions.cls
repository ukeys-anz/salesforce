/**
 * @author Batya Aisman Sufrin
 * @since  05/2023
 * @description COBPIDActions is to handle all the COB PID Trigger actions
 */
public with sharing class COBPIDActions {
  private static final String PASSPORT_TYPE = 'Passport';
  private static final String LICENCE_TYPE = 'Licence';

  /**
   * @description Set OCR Match
   * @param records PID records from trigger
   */
  public static void setOCRMatch(List<COBPrimaryIDDocument__c> records) {
    for (COBPrimaryIDDocument__c cobPid : records) {
      cobPid.PassportNumberOCRMatch__c = String.isNotEmpty(
          cobPid.PassportNumber__c
        )
        ? cobPid.PassportNumber__c == cobPid.PassportNumberOCRServer__c
        : false;
      cobPid.LicenceNumberOCRMatch__c = String.isNotEmpty(
          cobPid.LicenceNumber__c
        )
        ? cobPid.LicenceNumber__c == cobPid.LicenceNumberOCRServer__c
        : false;
      cobPid.LicenceCardNumberOCRMatch__c = String.isNotEmpty(
          cobPid.LicenceCardNumber__c
        )
        ? cobPid.LicenceCardNumber__c == cobPid.LicenceCardNumberOCRServer__c
        : false;
      cobPid.DateofBirthOCRMatch__c = cobPid.DateofBirth__c != null
        ? cobPid.DateofBirth__c == cobPid.DateofBirthOCRServer__c
        : false;
      cobPid.FirstNameOCRMatch__c = String.isNotEmpty(cobPid.FirstName__c)
        ? cobPid.FirstName__c == cobPid.FirstNameOCRServer__c
        : false;
      cobPid.LastNameOCRMatch__c = String.isNotEmpty(cobPid.LastName__c)
        ? cobPid.LastName__c == cobPid.LastNameOCRServer__c
        : false;
      cobPid.MiddleNamesOCRMatch__c = COBPIDActionsHelper.compareMiddleNamesValues(
        cobPid.MiddleNames__c,
        cobPid.MiddleNamesOCRServer__c
      );
    }
  }
}
