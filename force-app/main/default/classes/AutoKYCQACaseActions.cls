/**
 * @author Batya Aisman Sufrin
 * @since 09/2023
 * @description AutoKYCCaseActions class is to handle all the Auto KYC QA Case Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class AutoKYCQACaseActions {
  private List<Case> newKYCCasesList;
  private Map<Id, Case> oldKYCCaseMap;

  public static final String DUPLICATE_KYCQA_ERROR = 'Error occurred while creating KYC QA Case. A KYC QA Case already exists for this customer. Case number: ';

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  @TestVisible
  private static final String CANT_MOVE_NOT_CLOSED_CASE = 'Please complete the KYC QA case and not move the case to this queue';

  @TestVisible
  private static final String KYC_QA_CASE_MUST_BE_LINKED_TO_COB = 'KYC QA case must be linked to a Customer Onboarding Application';
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
  @TestVisible
  private static final String CURRENT = 'Current';

  @TestVisible
  private static final Map<String, String> VERIFICATION_TYPE_PRIORITY_MAP = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  /**
   * @description Constructor
   * @param newCasesList List of Case records passed from Trigger.new()
   * @param oldMap Map of Case records passed from Trigger.oldMap()
   */

  public AutoKYCQACaseActions(List<Case> newCasesList, Map<Id, Case> oldMap) {
    newKYCCasesList = getAutoKYCQACases(newCasesList).values();
    if (oldMap != null) {
      oldKYCCaseMap = getAutoKYCQACases(oldMap.values());
    }
  }

  /**
   * @description onBeforeInsert handles before insert trigger actions
   */
  public void onBeforeInsert() {
    validateDuplicateKYCQACasePerAccount();
    validateDuplicateKYCQACasePerCOBApp();
    setKYCQAFields();
  }

  /**
   * @description onBeforeUpdate handles before update trigger actions
   */
  public void onBeforeUpdate() {
    linkKYCQACasesToAccount();
    validateKYCQACases();
    updateTestedDate();
  }

  /**
   * @description Update KYC QA Case fields
   */
  private void setKYCQAFields() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>();

    for (Case kycCase : newKYCCasesList) {
      if (String.isEmpty(kycCase.CustomerOnboardingApplication__c)) {
        Logger.error(KYC_QA_CASE_MUST_BE_LINKED_TO_COB);
        kycCase.addError(KYC_QA_CASE_MUST_BE_LINKED_TO_COB);
      } else {
        personaIDToKYCCasesMap.put(kycCase.PersonaId__c, kycCase);
      }
    }

    if (personaIDToKYCCasesMap.isEmpty() == true) {
      return;
    }

    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap = getCOBAppsByPersonaIds(
      personaIDToKYCCasesMap.keySet()
    );

    setKYCQAFieldsCOBApp(personaIDToKYCCasesMap, personaIDToCOBAppsMap);
    setKYCQAFieldsCOBPID(personaIDToKYCCasesMap, personaIDToCOBAppsMap);
    setKYCQAFieldsCOBAddress(personaIDToKYCCasesMap);

    Logger.saveLog();
  }

  /**
   * @description Update KYC QA case Fields base on COB App
   * @param personaIDToKYCCasesMap Map of Persona Ids and KYC  cases
   * @param personaIDToCOBAppsMap Map of Persona Ids and COB Apps
   */
  @TestVisible
  private static void setKYCQAFieldsCOBApp(
    Map<String, Case> personaIDToKYCCasesMap,
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap
  ) {
    Logger.debug('Set KYC QA fields from COB App started: ' + System.now());

    for (Case kycCase : personaIDToKYCCasesMap.values()) {
      CustomerOnboardingApplication__c cobApp = personaIDToCOBAppsMap.get(
        kycCase.PersonaId__c
      );
      kycCase.Priority = VERIFICATION_TYPE_PRIORITY_MAP.get(
        cobApp?.VerificationType__c
      );
    }
    Logger.debug('Set KYC QA fields from COB App finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description Update KYC QA case Fields base on COB Primary ID Document
   * @param personaIDToKYCCasesMap Map of Persona Ids and KYC QA cases
   * @param personaIDToCOBAppsMap Map of Persona Ids and COB Apps
   */
  @TestVisible
  private static void setKYCQAFieldsCOBPID(
    Map<String, Case> personaIDToKYCCasesMap,
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap
  ) {
    Logger.debug('Set KYC QA fields from PID started: ' + System.now());
    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap = getCOBPIDsByPersonaIds(
      personaIDToKYCCasesMap.keySet()
    );

    for (Case kycCase : personaIDToKYCCasesMap.values()) {
      COBPrimaryIDDocument__c cobPid = personaIDToPrimaryDocumentMap.get(
        kycCase.PersonaId__c
      );
      kycCase.Fraud_MiddleNameCheck__c = populateMiddleNameCheck(cobPid);

      CustomerOnboardingApplication__c cobApp = personaIDToCOBAppsMap.get(
        kycCase.PersonaId__c
      );
      kycCase.Fraud_Customer_Details__c = populateFraudCustomerDetails(
        cobApp,
        cobPid
      );
    }
    Logger.debug('Set KYC QA fields from PID finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description Update KYC QA case Fields base on COB Address
   * @param personaIDToKYCCasesMap Map of Persona Ids and KYC QA cases
   */
  @TestVisible
  private static void setKYCQAFieldsCOBAddress(
    Map<String, Case> personaIDToKYCCasesMap
  ) {
    Logger.debug('Set KYC QA fields from Address started: ' + System.now());
    Map<String, COBAddress__c> personaIDToCOBAddresMap = getCOBAddressByPersonaIdsAndAddressType(
      personaIDToKYCCasesMap.keySet(),
      CURRENT
    );

    for (Case kycCase : personaIDToKYCCasesMap.values()) {
      COBAddress__c cobAddress = personaIDToCOBAddresMap.get(
        kycCase.PersonaId__c
      );
      if (cobAddress != null) {
        kycCase.Fraud_PO_Box__c = cobAddress.QASAddress__c ? YES : NONE;
        kycCase.Fraud_Address_Valid__c = cobAddress.QASAddress__c ? YES : NONE;
      }
    }
    Logger.debug('Set KYC QA fields from Address finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description Get COB Apps by PersonaIds
   * @param personaIds PersonaIds
   * @return Map <String, CustomerOnboardingApplication__c> Map of PersonaIds with COB Apps
   */
  @TestVisible
  private static Map<String, CustomerOnboardingApplication__c> getCOBAppsByPersonaIds(
    Set<String> personaIds
  ) {
    if (
      personaIds.isEmpty() ||
      PermissionUtils.canQuery('CustomerOnboardingApplication__c') == false
    ) {
      return new Map<String, CustomerOnboardingApplication__c>();
    }

    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppMap = new Map<String, CustomerOnboardingApplication__c>();

    for (CustomerOnboardingApplication__c cobApp : [
      SELECT PersonaId__c, VerificationType__c
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ]) {
      personaIDToCOBAppMap.put(cobApp.PersonaId__c, cobApp);
    }

    return personaIDToCOBAppMap;
  }

  /**
   * @description Get COB PID by PersonaIds
   * @param personaIds PersonaIds
   * @return Map <String, COBPrimaryIDDocument__c> Map of PersonaIds with COB Primary ID Documents
   */
  @TestVisible
  private static Map<String, COBPrimaryIDDocument__c> getCOBPIDsByPersonaIds(
    Set<String> personaIds
  ) {
    if (
      personaIds.isEmpty() ||
      PermissionUtils.canQuery('CustomerOnboardingApplication__c') == false ||
      PermissionUtils.canQuery('COBPrimaryIDDocument__c') == false
    ) {
      return new Map<String, COBPrimaryIDDocument__c>();
    }

    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap = new Map<String, COBPrimaryIDDocument__c>();
    //get latest COB PID record by max createdDate for each PersonaId
    for (CustomerOnboardingApplication__c cobApp : [
      SELECT
        PersonaId__c,
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
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ]) {
      if (cobApp.COBPrimaryIDDocuments__r.isEmpty() == false) {
        personaIDToPrimaryDocumentMap.put(
          cobApp.PersonaId__c,
          cobApp.COBPrimaryIDDocuments__r[0]
        );
      }
    }

    return personaIDToPrimaryDocumentMap;
  }

  /**
   * @description Get COB Address by PersonaID and AddressType
   * @param personaIds PersonaIds
   * @param addressType Address Type
   * @return Map<String, COBAddress__c> Map of PersonaIds with COB Addresses
   */
  @TestVisible
  private static Map<String, COBAddress__c> getCOBAddressByPersonaIdsAndAddressType(
    Set<String> personaIds,
    String addressType
  ) {
    if (
      personaIds.isEmpty() ||
      PermissionUtils.canQuery('CustomerOnboardingApplication__c') == false ||
      PermissionUtils.canQuery('COBAddress__c') == false
    ) {
      return new Map<String, COBAddress__c>();
    }

    Map<String, COBAddress__c> personaIDToCOBAddressMap = new Map<String, COBAddress__c>();
    //get latest COB Address record by max createdDate for each PersonaId and certain Address Type
    for (CustomerOnboardingApplication__c cobApp : [
      SELECT
        PersonaId__c,
        (
          SELECT Id, CustomerOnboardingApplication__c, QASAddress__c
          FROM COBAddresses__r
          WHERE AddressType__c = :addressType
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ]) {
      if (cobApp.COBAddresses__r.isEmpty() == false) {
        personaIDToCOBAddressMap.put(
          cobApp.PersonaId__c,
          cobApp.COBAddresses__r[0]
        );
      }
    }

    return personaIDToCOBAddressMap;
  }

  /**
   * @description Populate Fraud Customer Details test result
   * @param cobApp  COB Application
   * @param cobPrimaryIDDocument  COB Primary ID Document
   * @return Fraud Customer Details result
   */
  @TestVisible
  private static String populateFraudCustomerDetails(
    CustomerOnboardingApplication__c cobApp,
    COBPrimaryIDDocument__c cobPrimaryIDDocument
  ) {
    Logger.debug('Verification Type: ' + cobApp?.VerificationType__c);
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
      'Date Of Birth OCR Match: ' +
      (cobPrimaryIDDocument?.DateOfBirthOCRMatch__c == true)
    );
    Logger.debug(
      'Expiry Date OCR Match: ' +
      (cobPrimaryIDDocument?.ExpiryDateOCRMatch__c == true)
    );
    Logger.saveLog();

    if (
      (cobApp?.VerificationType__c == VERIFICATION_TYPE_STP ||
      cobApp?.VerificationType__c == VERIFICATION_TYPE_ASSISTED)
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
      cobPrimaryIDDocument?.DateOfBirthOCRMatch__c == true &&
      cobPrimaryIDDocument?.ExpiryDateOCRMatch__c == true &&
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
  @TestVisible
  private static String populateMiddleNameCheck(
    COBPrimaryIDDocument__c cobPid
  ) {
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

  /**
   * @description Checks whether FirstNameOCRServer and LastNameOCRServer values are blank
   * @param cobPid COB Primary Document
   * @return True if the FirstNameOCRServer and LastNameOCRServer values are blank, false otherwise
   */
  @TestVisible
  private static Boolean areFirstAndLastNamesOCRServerBlank(
    COBPrimaryIDDocument__c cobPid
  ) {
    return String.isBlank(cobPid?.FirstNameOCRServer__c) &&
      String.isBlank(cobPid?.LastNameOCRServer__c);
  }

  /**
   * @description Checks whether MiddleNames and MiddleNames Server OCR values are matching and MiddleNamesOCRServer is not blank
   * @param cobPid COB Primary Document
   * @return True if MiddleNames and MiddleNames Server OCR values are matching and MiddleNamesOCRServer is not blank, false otherwise
   */
  @TestVisible
  private static Boolean doMiddleNamesMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid?.MiddleNamesOCRMatch__c == true &&
      String.isNotBlank(cobPid?.MiddleNamesOCRServer__c);
  }

  /**
   * @description Check whether Full Name values matching Full Name Server OCR values
   * @param cobPid COB Primary Document
   * @return True if Full Name values matching Full Name Server OCR values, false otherwise
   */
  @TestVisible
  private static Boolean doesFullNameMatch(COBPrimaryIDDocument__c cobPid) {
    String cobPIDDFullName = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{
        cobPid?.FirstName__c,
        cobPid?.MiddleNames__c,
        cobPid?.LastName__c
      }
    );
    String cobPIDDFullNameOCRServer = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{
        cobPid?.FirstNameOCRServer__c,
        cobPid?.MiddleNamesOCRServer__c,
        cobPid?.LastNameOCRServer__c
      }
    );

    return cobPIDDFullName.equalsIgnoreCase(cobPIDDFullNameOCRServer);
  }

  /**
   * @description Checks whether Document type is Licence and the LicenceNumber and LicenceNumber Server OCR values are matching
   * @param cobPid COB Primary Document
   * @return True if the Document type is Licence and the LicenceNumber and LicenceNumberOCR values are matching, false otherwise
   */
  @TestVisible
  private static Boolean doesLicenceMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid?.IdDocumentType__c == LICENCE &&
      cobPid?.LicenceNumberOCRMatch__c == true;
  }

  /**
   * @description Checks whether Document type is Passport and the PassportNumber and PassportNumber Server OCR values are matching
   * @param cobPid COB Primary Document
   * @return True if the Document type is Passport and the PassportNumber and PassportNumberOCR values are matching, false otherwise
   */
  @TestVisible
  private static Boolean doesPassportMatch(COBPrimaryIDDocument__c cobPid) {
    return cobPid?.IdDocumentType__c == PASSPORT &&
      cobPid?.PassportNumberOCRMatch__c == true;
  }

  /**
   * @description Prevent Duplicate KYC QA Against a Customer (Account)
   */
  public void validateDuplicateKYCQACasePerAccount() {
    if (PermissionUtils.canQuery('Case')) {
      Map<Id, Case> accountIdAndCaseMap = new Map<Id, Case>();
      for (Case kycCase : newKYCCasesList) {
        if (kycCase.AccountId != null) {
          accountIdAndCaseMap.put(kycCase.AccountId, kycCase);
        }
      }
      if (accountIdAndCaseMap.size() == 0) {
        return;
      }

      List<Case> existingKYCCases = getKYCCasesByAccountIds(
        accountIdAndCaseMap.keySet()
      );
      for (Case existingKYCCase : existingKYCCases) {
        Case kycCase = accountIdAndCaseMap.get(existingKYCCase.AccountId);
        kycCase.addError(DUPLICATE_KYCQA_ERROR + existingKYCCase.CaseNumber);
      }
    }
  }

  /**
   * @description Prevent Duplicate KYC QA Against an COB Application
   */
  public void validateDuplicateKYCQACasePerCOBApp() {
    if (PermissionUtils.canQuery('Case')) {
      Map<Id, Case> cobAppIdAndCaseMap = new Map<Id, Case>();
      for (Case kycCase : newKYCCasesList) {
        if (kycCase.CustomerOnboardingApplication__c != null) {
          cobAppIdAndCaseMap.put(
            kycCase.CustomerOnboardingApplication__c,
            kycCase
          );
        }
      }
      if (cobAppIdAndCaseMap.size() == 0) {
        return;
      }

      List<Case> existingKYCCases = getKYCCasesByCOBAppIds(
        cobAppIdAndCaseMap.keySet()
      );
      for (Case existingKYCCase : existingKYCCases) {
        Case kycCase = cobAppIdAndCaseMap.get(
          existingKYCCase.CustomerOnboardingApplication__c
        );
        kycCase.addError(DUPLICATE_KYCQA_ERROR + existingKYCCase.CaseNumber);
      }
    }
  }

  /**
   * @description Get list of KYC cases By list of account Ids
   * @param accountIds set of account Ids
   * @return List<Case> list of cases
   */
  private List<Case> getKYCCasesByAccountIds(Set<Id> accountIds) {
    return [
      SELECT Id, CaseNumber, AccountId
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND AccountId IN :accountIds
    ];
  }

  /**
   * @description Get list of KYC cases By list of COB application Ids
   * @param cobAppIds set of COB application Ids
   * @return List<Case> list of cases
   */
  private List<Case> getKYCCasesByCOBAppIds(Set<Id> cobAppIds) {
    return [
      SELECT Id, CaseNumber, CustomerOnboardingApplication__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND CustomerOnboardingApplication__c IN :cobAppIds
    ];
  }

  /**
   * @description Get KYC QA Cases
   * @param casesList - List of cases to filter to get KYC QA Cases
   * @return Map<Id, Case> Map of Cases Ids and Cases
   */
  private Map<Id, Case> getAutoKYCQACases(List<Case> casesList) {
    if (casesList.isEmpty() == true) {
      return new Map<Id, Case>();
    }

    Map<Id, Case> kycCaseMap = new Map<Id, Case>();
    List<Case> kycCasesList = CommonUtil.filterCasesByRecordTypeId(
      casesList,
      GetHelpConstants.KYCQA_RT_ID
    );
    for (Case kycCase : kycCasesList) {
      kycCaseMap.put(kycCase.Id, kycCase);
    }
    return kycCaseMap;
  }

  /**
   * @description linkCasestoAccountByOCVId link case to customer profile by OCV Id or Mobile number
   * - TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   */
  private void linkKYCQACasesToAccount() {
    //get all the cases with no customer from filtered kycQACases
    List<Case> kycCasesWithNoCustomer = AutoKYCQACaseActionsHelper.getKYCQACasesWithoutCustomer(
      newKYCCasesList
    );

    if (kycCasesWithNoCustomer.isEmpty()) {
      return;
    }

    Map<String, String> mobileByCaseIdMap = AutoKYCQACaseActionsHelper.getMobileByCaseId(
      new Map<Id, Case>(kycCasesWithNoCustomer).keySet()
    );

    Map<String, Account> accountByMobileMap = AutoKYCQACaseActionsHelper.getAccountsByMobile(
      mobileByCaseIdMap.values()
    );
    // Get matched Accounts Entitelments
    Map<Id, Id> accountIdEntitlmentMap = GetHelpCaseActionsHelper.getAccountIdEntitlmentMap(
      accountByMobileMap.values()
    );

    for (Case c : kycCasesWithNoCustomer) {
      Account matchingAcc = accountByMobileMap.get(mobileByCaseIdMap.get(c.Id));
      if (matchingAcc != null) {
        Id accountEntitlmentId = accountIdEntitlmentMap.get(matchingAcc.Id);
        AutoKYCQACaseActionsHelper.setMatchingAccountFields(
          c,
          matchingAcc,
          accountEntitlmentId
        );
      } else {
        Case oldCase = oldKYCCaseMap.get(c.Id);
        AutoKYCQACaseActionsHelper.handleKYCQACaseNoCustomer(c, oldCase);
      }
      Logger.debug('KYC QA Case Number: ' + c.CaseNumber__c);
    }
    Logger.saveLog();
  }

  /**
   * @description Prevent the Cases either not in Close status or in Close status with linked Account to be moved to Pending KYC QA - No Customer queue
   * - TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
   */
  private void validateKYCQACases() {
    for (Case kycCase : newKYCCasesList) {
      Case oldCase = oldKYCCaseMap.get(kycCase.Id);
      if (
        (oldCase.OwnerId != kycCase.OwnerId &&
        kycCase.OwnerId ==
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id) &&
        (kycCase.Status != GetHelpConstants.CLOSED_STATUS ||
        (kycCase.Status == GetHelpConstants.CLOSED_STATUS &&
        kycCase.AccountId != null))
      ) {
        kycCase.addError(CANT_MOVE_NOT_CLOSED_CASE);
      }
    }
  }

  /**
   * @description If all 10 fields are not empty then capture the current date
   */
  private void updateTestedDate() {
    for (Case oCase : newKYCCasesList) {
      if (
        oCase.RecordTypeId == GetHelpConstants.KYCQA_RT_ID &&
        canPopulateTestedDate(oCase)
      ) {
        oCase.TestedDate__c = System.now();
      }
    }
  }

  private Boolean canPopulateTestedDate(Case oCase) {
    return oCase.TestedDate__c == null &&
      String.isNotEmpty(oCase.Fraud_Customer_Details__c) &&
      String.isNotEmpty(oCase.Fraud_MiddleNameCheck__c) &&
      String.isNotEmpty(oCase.Fraud_Selfie_Comparison_Match__c) &&
      String.isNotEmpty(oCase.Fraud_PO_Box__c) &&
      String.isNotEmpty(oCase.Fraud_Address_Valid__c) &&
      String.isNotEmpty(oCase.Fraud_Restraint_Status__c) &&
      String.isNotEmpty(oCase.Fraud_ID_Legible__c) &&
      String.isNotEmpty(oCase.Fraud_Customer_Photo_Modified__c) &&
      String.isNotEmpty(oCase.Fraud_ID_Not_Picture__c) &&
      String.isNotEmpty(oCase.Fraud_Security_Features__c);
  }
}
