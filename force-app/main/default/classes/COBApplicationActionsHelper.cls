/**
 * @author Batya Aisman Sufrin
 * @since 05/2023
 * @description Helper class for @link COBApplicationActions
 */
public with sharing class COBApplicationActionsHelper {
  public static final Group PENDING_KYC_QA_QUEUE = CommonUtil.getQueueByName(
    'Pending_KYC_QA'
  );
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
  @TestVisible
  private static final String VERIFICATION_TYPE_ASSISTED = 'ASSISTED';
  @TestVisible
  private static final String VERIFICATION_TYPE_STP = 'STP';

  /**
   * @description Set KYC QA case base fields
   * @param cobApp Customer Onboarding Application
   * @return Case KYC QA case
   */
  public static Case setKYCQACaseBaseFields(
    CustomerOnboardingApplication__c cobApp
  ) {
    Case kycQACase = new Case(
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      OwnerId = PENDING_KYC_QA_QUEUE.Id,
      CustomerOnboardingApplication__c = cobApp.Id,
      PersonaId__c = cobApp.PersonaId__c,
      OCV_Id__c = cobApp.OCVId__c,
      Priority = VERIFICATION_TYPE_PRIORITY.get(cobApp.VerificationType__c)
    );

    Logger.debug('KYC QA Case with base fields: ' + kycQACase);
    Logger.saveLog();
    return kycQACase;
  }

  /**
   * @description Get Accounts by OCV ids
   * @param ocvIds OCV Ids
   * @return Map<String, Account> Map of OCV ids and Accounts
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
    if (
      ocvIds.isEmpty() ||
      PermissionUtils.canQuery('COBPrimaryIDDocument__c') == false
    ) {
      return new Map<String, COBPrimaryIDDocument__c>();
    }

    Map<String, COBPrimaryIDDocument__c> cobPIDs = new Map<String, COBPrimaryIDDocument__c>();
    //getting max COB PID records createdDate for each cobAppId
    List<CustomerOnboardingApplication__c> cobApps = [
      SELECT
        OCVId__c,
        (
          SELECT
            Id,
            IdDocumentType__c,
            CustomerOnboardingApplication__c,
            FirstName__c,
            FirstNameOCRServer__c,
            FirstNameOCRMatch__c,
            MiddleNames__c,
            MiddleNamesOCRServer__c,
            MiddleNamesOCRMatch__c,
            LastName__c,
            LastNameOCRServer__c,
            LastNameOCRMatch__c,
            LicenceNumberOCRMatch__c,
            LicenceCardNumberOCRMatch__c,
            PassportNumberOCRMatch__c,
            DateOfBirthOCRMatch__c,
            ExpiryDateOCRMatch__c
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

    Logger.debug('COB Primary ID Documents: ' + cobPIDs);
    Logger.saveLog();
    return cobPIDs;
  }

  /**
   * @description Get COB Address by AddressType
   * @param ocvIds  OCV id
   * @param addressType  Address Type
   * @return getCOBAddressByAddressType COB Address
   */
  public static Map<String, COBAddress__c> getCOBAddressByOCVIdAddressType(
    Set<String> ocvIds,
    String addressType
  ) {
    if (
      ocvIds.isEmpty() || PermissionUtils.canQuery('COBAddress__c') == false
    ) {
      return new Map<String, COBAddress__c>();
    }

    Map<String, COBAddress__c> cobAppIdAddresses = new Map<String, COBAddress__c>();
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

    Logger.debug('COB Addressess: ' + cobAppIdAddresses);
    Logger.saveLog();

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
    Logger.debug('Verification Type: ' + cobApp.VerificationType__c);
    Logger.debug(
      'Does Licence Match: ' + doesLicenceMatch(cobPrimaryIDDocument)
    );
    Logger.debug(
      'Does Passport Match: ' + doesPassportMatch(cobPrimaryIDDocument)
    );
    Logger.debug(
      'Does Full Name Match: ' + doesFullNameMatch(cobPrimaryIDDocument)
    );
    Logger.debug(
      'Date Of Birth OCR Match: ' + cobPrimaryIDDocument.DateOfBirthOCRMatch__c
    );
    Logger.debug(
      'Expiry Date OCR Match: ' + cobPrimaryIDDocument.ExpiryDateOCRMatch__c
    );
    Logger.saveLog();

    if (
      (cobApp.VerificationType__c == VERIFICATION_TYPE_STP ||
      cobApp.VerificationType__c == VERIFICATION_TYPE_ASSISTED)
    ) {
      if (
        doesLicenceMatch(cobPrimaryIDDocument) ||
        doesPassportMatch(cobPrimaryIDDocument)
      ) {
        return YES;
      } else {
        return NONE;
      }
    } else if (
      doesFullNameMatch(cobPrimaryIDDocument) &&
      cobPrimaryIDDocument.DateOfBirthOCRMatch__c &&
      cobPrimaryIDDocument.ExpiryDateOCRMatch__c &&
      (doesLicenceMatch(cobPrimaryIDDocument) ||
      doesPassportMatch(cobPrimaryIDDocument))
    ) {
      return YES;
    }
    return NONE;
  }

  /**
   * @description Populate Middle Name Check test result
   * @param cobPid  COB Primary ID Document
   * @return Middle Name Check result
   */
  public static String populateMiddleNameCheck(COBPrimaryIDDocument__c cobPid) {
    Logger.debug(
      'Are First And Last Names OCR Server Blank: ' +
      areFirstAndLastNamesOCRServerBlank(cobPid)
    );
    Logger.debug('Does Midddle Names Match: ' + doMiddleNamesMatch(cobPid));
    Logger.debug('Does Full Name Match: ' + doesFullNameMatch(cobPid));
    Logger.debug('Does Licence Match: ' + doesLicenceMatch(cobPid));
    Logger.debug('Does Passport Match: ' + doesPassportMatch(cobPid));
    Logger.saveLog();

    if (areFirstAndLastNamesOCRServerBlank(cobPid)) {
      return NONE;
    } else if (doMiddleNamesMatch(cobPid)) {
      return YES;
    } else if (
      doesFullNameMatch(cobPid) &&
      (doesLicenceMatch(cobPid) || doesPassportMatch(cobPid))
    ) {
      return YES;
    }

    return NONE;
  }

  @TestVisible
  private static Boolean areFirstAndLastNamesOCRServerBlank(
    COBPrimaryIDDocument__c cobPid
  ) {
    return String.isBlank(cobPid.FirstNameOCRServer__c) &&
      String.isBlank(cobPid.LastNameOCRServer__c);
  }

  @TestVisible
  private static Boolean doMiddleNamesMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid.MiddleNamesOCRMatch__c &&
      String.isNotBlank(cobPid.MiddleNamesOCRServer__c);
  }

  @TestVisible
  private static Boolean doesFullNameMatch(COBPrimaryIDDocument__c cobPid) {
    String cobPIDDFullName = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{
        cobPid.FirstName__c,
        cobPid.MiddleNames__c,
        cobPid.LastName__c
      }
    );
    String cobPIDDFullNameOCRServer = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{
        cobPid.FirstNameOCRServer__c,
        cobPid.MiddleNamesOCRServer__c,
        cobPid.LastNameOCRServer__c
      }
    );

    return cobPIDDFullName.equalsIgnoreCase(cobPIDDFullNameOCRServer);
  }

  @TestVisible
  private static Boolean doesLicenceMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid.IdDocumentType__c == LICENCE &&
      cobPid.LicenceNumberOCRMatch__c;
  }

  @TestVisible
  private static Boolean doesPassportMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid.IdDocumentType__c == PASSPORT &&
      cobPid.PassportNumberOCRMatch__c;
  }
}
