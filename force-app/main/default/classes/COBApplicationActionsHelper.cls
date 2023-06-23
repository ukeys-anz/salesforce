/**
 * @author Batya Aisman Sufrin
 * @since 05/2023
 * @description Helper class for @link COBApplicationActions
 */
public with sharing class COBApplicationActionsHelper {
  private static final Group PENDING_KYC_QA_QUEUE = CommonUtil.getQueueByName(
    'Pending_KYC_QA'
  );

  private static final String EXPR_0 = 'expr0';

  public static final Map<String, String> VERIFICATION_TYPE_PRIORITY = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  @TestVisible
  private static final String YES = 'Yes';
  @TestVisible
  private static final String NONE = null;
  @TestVisible
  private static final String PASS = 'PASS';
  @TestVisible
  private static final String LICENCE = 'Licence';
  @TestVisible
  private static final String PASSPORT = 'Passport';

  /**
   * @description Create KYC QA case
   * @param cobApp Customer Onboarding Application
   * @return Case KYC QA case
   */
  public static Case createKYCQACase(CustomerOnboardingApplication__c cobApp) {
    Case kycQACase = new Case(
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      OwnerId = PENDING_KYC_QA_QUEUE.Id,
      CustomerOnboardingApplication__c = cobApp.Id,
      PersonaId__c = cobApp.PersonaId__c,
      OCV_Id__c = cobApp.OCVId__c,
      Priority = VERIFICATION_TYPE_PRIORITY.get(cobApp.VerificationType__c)
    );

    return kycQACase;
  }

  /**
   * @description Get Accounts by OCV ids
   * @param ocvIds OCV Ids
   * @return Map<Id, Account> Map of OCV ids and Accounts
   */

  public static Map<String, Account> getAccountsByOCVIDs(Set<String> ocvIds) {
    Map<String, Account> accountsByOCVIDs = new Map<String, Account>();

    if (ocvIds.isEmpty()) {
      return accountsByOCVIDs;
    }

    if (PermissionUtils.canQuery('Account')) {
      List<Account> accs = [
        SELECT Id, OCV_ID__c
        FROM Account
        WHERE OCV_ID__c IN :ocvIds
      ];

      for (Account acc : accs) {
        accountsByOCVIDs.put(acc.OCV_ID__c, acc);
      }
    }

    return accountsByOCVIDs;
  }

  /**
   * @description Get PID by  OCV Ids
   * @param ocvIds OCV Ids
   * @return Map<Id, COBPrimaryIDDocument__c> Map of OCV ids and COB Primary ID Documents
   */
  public static Map<String, COBPrimaryIDDocument__c> getCOBPIDsByOCVIds(
    Set<String> ocvIds
  ) {
    Map<String, COBPrimaryIDDocument__c> cobPIDs = new Map<String, COBPrimaryIDDocument__c>();
    if (ocvIds.isEmpty()) {
      return cobPIDs;
    }

    if (PermissionUtils.canQuery('COBPrimaryIDDocument__c')) {
      //getting max COB PID records createdDate for each cobAppId
      List<CustomerOnboardingApplication__c> cobApps = [
        SELECT
          OCVId__c,
          (
            SELECT
              Id,
              IdDocumentType__c,
              CustomerOnboardingApplication__c,
              MiddleNamesOCRMatch__c,
              FirstNameOCRMatch__c,
              LastNameOCRMatch__c,
              LicenceNumberOCRMatch__c,
              LicenceCardNumberOCRMatch__c,
              PassportNumberOCRMatch__c,
              DateOfBirthOCRMatch__c
            FROM COBPrimaryIDDocuments__r
            ORDER BY CreatedDate DESC
          )
        FROM CustomerOnboardingApplication__c
        WHERE OCVId__c IN :ocvIds
      ];

      for (CustomerOnboardingApplication__c cobApp : cobApps) {
        if (!cobApp.COBPrimaryIDDocuments__r.isEmpty()) {
          cobPIDs.put(cobApp.OCVId__c, cobApp.COBPrimaryIDDocuments__r[0]);
        }
      }
    }

    return cobPIDs;
  }

  /**
   * @description Get COB Address by AddressType
   * @param ocvIds  OCV id
   * @param addressType  Address Type
   * @return getCOBAddressByAddressType COB Address
   */
  @testVisible
  public static Map<String, COBAddress__c> getCOBAddressByOCVIdAddressType(
    Set<String> ocvIds,
    String addressType
  ) {
    Map<String, COBAddress__c> cobAppIdAddresses = new Map<String, COBAddress__c>();
    if (ocvIds.isEmpty()) {
      return cobAppIdAddresses;
    }

    if (PermissionUtils.canQuery('COBAddress__c')) {
      List<CustomerOnboardingApplication__c> cobApps = [
        SELECT
          OCVId__c,
          (
            SELECT Id, CustomerOnboardingApplication__c, QASAddress__c
            FROM COBAddresses__r
            WHERE AddressType__c = :addressType
            ORDER BY CreatedDate DESC
          )
        FROM CustomerOnboardingApplication__c
        WHERE OCVId__c IN :ocvIds
      ];

      for (CustomerOnboardingApplication__c cobApp : cobApps) {
        if (!cobApp.COBAddresses__r.isEmpty()) {
          cobAppIdAddresses.put(cobApp.OCVId__c, cobApp.COBAddresses__r[0]);
        }
      }
    }
    return cobAppIdAddresses;
  }

  /**
   * @description Populate Fraud Customer Details test result
   * @param cobApp  COB Application
   * @param cobPrimaryIDDocument  COB Primary ID Document
   * @return Fraud Customer Details result
   */
  public static String populateFraudCustomerDetails(
    CustomerOnboardingApplication__c cobApp,
    COBPrimaryIDDocument__c cobPrimaryIDDocument
  ) {
    Boolean isLicenceMatch =
      cobPrimaryIDDocument.IdDocumentType__c == LICENCE &&
      cobPrimaryIDDocument.LicenceNumberOCRMatch__c;
    Boolean isPassportMatch =
      cobPrimaryIDDocument.IdDocumentType__c == PASSPORT &&
      cobPrimaryIDDocument.PassportNumberOCRMatch__c;
    if (cobApp != null && cobPrimaryIDDocument != null) {
      if (
        cobApp.EquifaxDVSResult__c == PASS &&
        (isLicenceMatch || isPassportMatch)
      ) {
        return YES;
      } else if (
        cobApp.EquifaxDVSResult__c != PASS &&
        cobPrimaryIDDocument.FirstNameOCRMatch__c &&
        cobPrimaryIDDocument.LastNameOCRMatch__c &&
        cobPrimaryIDDocument.DateOfBirthOCRMatch__c &&
        ((isLicenceMatch &&
        cobPrimaryIDDocument.LicenceCardNumberOCRMatch__c) || isPassportMatch)
      ) {
        return YES;
      }
    }
    return NONE;
  }
}
