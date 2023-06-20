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
      cobPid.PassportNumberOCRMatch__c =
        cobPid.PassportNumber__c == cobPid.PassportNumberOCRServer__c;
      cobPid.LicenceNumberOCRMatch__c =
        cobPid.LicenceNumber__c == cobPid.LicenceNumberOCRServer__c;
      cobPid.LicenceCardNumberOCRMatch__c =
        cobPid.LicenceCardNumber__c == cobPid.LicenceCardNumberOCRServer__c;
      cobPid.DateofBirthOCRMatch__c =
        cobPid.DateofBirth__c == cobPid.DateofBirthOCRServer__c;
      cobPid.FirstNameOCRMatch__c =
        cobPid.FirstName__c == cobPid.FirstNameOCRServer__c;
      cobPid.LastNameOCRMatch__c =
        cobPid.LastName__c == cobPid.LastNameOCRServer__c;
      cobPid.MiddleNamesOCRMatch__c = COBPIDActionsHelper.compareMiddleNamesValues(
        cobPid.MiddleNames__c,
        cobPid.MiddleNamesOCRServer__c
      );
    }
  }
}
