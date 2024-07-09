/**
 * @author Batya Aisman Sufrin
 * @since 09/2023
 * @description AutoKYCQACaseActions class is to handle all the Auto KYC QA Case Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class AutoKYCQACaseActions {
  public static final String DUPLICATE_KYCQA_ERROR = 'Error occurred while creating KYC QA Case. A KYC QA Case already exists for this customer. Case number: ';

  private static final AutoKYCQACaseRepository AUTO_KYCQA_CASE_REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );

  private static final ProfileStagingHandler PROFILE_STAGING_HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  @TestVisible
  private static final String KYC_QA_CASE_MUST_BE_LINKED_TO_COB = 'KYC QA case must be linked to a Customer Onboarding Application';
  @TestVisible
  private static final String YES = 'Yes';
  @TestVisible
  private static final String NO = 'No';
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
  private static final String RECTIFY_DEFECT_STATUS = 'Rectify Defect';
  @TestVisible
  private static final String PENDING_DOCUMENTS_STATUS = 'Pending Documents';
  @TestVisible
  private static final String UNDER_REVIEW_STATUS = 'Under Review';
  @TestVisible
  private static final String TRIGGERED_FROM_PREFIX = 'Case.KYC_QA';
  private static final String CURRENT = 'Current';

  @TestVisible
  private static final Map<String, String> VERIFICATION_TYPE_PRIORITY_MAP = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  @TestVisible
  private static final String DOWNGRADE = 'Downgrade';
  @TestVisible
  private static final String DOWNGRADE_KYC_STATUS = 'PC';
  @TestVisible
  private static final String DOWNGRADE_KYC_VERIFICATION_LEVEL = 'RR';
  @TestVisible
  private static final String UPGRADE = 'Upgrade';
  @TestVisible
  private static final String UPGRADE_KYC_STATUS = 'CO';
  @TestVisible
  private static final String UPGRADE_KYC_VERIFICATION_LEVEL = 'VE';

  /**
   * @description Update KYC QA Case fields
   * @param cases List of Cases
   */
  public static void setKYCQAFields(List<Case> cases) {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>();

    for (Case kycCase : cases) {
      if (String.isEmpty(kycCase.CustomerOnboardingApplication__c)) {
        CommonUtil.addErrorToRecordAndLog(
          kycCase,
          KYC_QA_CASE_MUST_BE_LINKED_TO_COB
        );
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

    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap = getCOBPIDsByPersonaIds(
      personaIDToKYCCasesMap.keySet()
    );
    setKYCQAFieldsCOBPID(
      personaIDToKYCCasesMap,
      personaIDToCOBAppsMap,
      personaIDToPrimaryDocumentMap
    );

    Map<String, COBAddress__c> personaIDToCOBAddressMap = getCOBAddressByPersonaIdsAndAddressType(
      personaIDToKYCCasesMap.keySet(),
      CURRENT
    );
    setKYCQAFieldsCOBAddress(personaIDToKYCCasesMap, personaIDToCOBAddressMap);
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
   * @param personaIDToPrimaryDocumentMap Map of Persona Ids and COB Primary ID Documents
   */
  @TestVisible
  private static void setKYCQAFieldsCOBPID(
    Map<String, Case> personaIDToKYCCasesMap,
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap,
    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap
  ) {
    Logger.debug('Set KYC QA fields from PID started: ' + System.now());
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
   * @param personaIDToCOBAddressMap Map of Persona Ids and COB Addresses
   */
  @TestVisible
  private static void setKYCQAFieldsCOBAddress(
    Map<String, Case> personaIDToKYCCasesMap,
    Map<String, COBAddress__c> personaIDToCOBAddressMap
  ) {
    Logger.debug('Set KYC QA fields from Address started: ' + System.now());
    for (Case kycCase : personaIDToKYCCasesMap.values()) {
      if (!personaIDToCOBAddressMap.containsKey(kycCase.PersonaId__c)) {
        continue;
      }
      COBAddress__c cobAddress = personaIDToCOBAddressMap.get(
        kycCase.PersonaId__c
      );
      kycCase.Fraud_PO_Box__c = cobAddress.QASAddress__c == true ? YES : NONE;
      kycCase.Fraud_Address_Valid__c = cobAddress.QASAddress__c == true
        ? YES
        : NONE;
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
    if (personaIds.isEmpty() == true) {
      return new Map<String, CustomerOnboardingApplication__c>();
    }

    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppMap = new Map<String, CustomerOnboardingApplication__c>();
    for (
      CustomerOnboardingApplication__c cobApp : AUTO_KYCQA_CASE_REPOSITORY.queryCOBByPersonaId(
        personaIds
      )
    ) {
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
    if (personaIds.isEmpty() == true) {
      return new Map<String, COBPrimaryIDDocument__c>();
    }

    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap = new Map<String, COBPrimaryIDDocument__c>();
    //get latest COB PID record by max createdDate for each PersonaId
    for (
      CustomerOnboardingApplication__c cobApp : AUTO_KYCQA_CASE_REPOSITORY.queryCOBWithPIDByPersonaId(
        personaIds
      )
    ) {
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
    if (personaIds.isEmpty() == true) {
      return new Map<String, COBAddress__c>();
    }

    Map<String, COBAddress__c> personaIDToCOBAddressMap = new Map<String, COBAddress__c>();
    //get latest COB Address record by max createdDate for each PersonaId and certain Address Type
    for (
      CustomerOnboardingApplication__c cobApp : AUTO_KYCQA_CASE_REPOSITORY.queryCOBWithCOBAddressByAddresTypeAndPersonaId(
        personaIds,
        addressType
      )
    ) {
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
   * @param cases List of Cases
   */
  public static void validateDuplicateKYCQACasePerAccount(List<Case> cases) {
    Map<Id, Case> accountIdAndCaseMap = new Map<Id, Case>();
    for (Case kycCase : cases) {
      if (kycCase.AccountId != null) {
        accountIdAndCaseMap.put(kycCase.AccountId, kycCase);
      }
    }
    if (accountIdAndCaseMap.isEmpty() == true) {
      return;
    }

    List<Case> existingKYCCases = AUTO_KYCQA_CASE_REPOSITORY.queryKYCQACasesByAccountIds(
      accountIdAndCaseMap.keySet()
    );
    for (Case existingKYCCase : existingKYCCases) {
      Case kycCase = accountIdAndCaseMap.get(existingKYCCase.AccountId);
      CommonUtil.addErrorToRecordAndLog(
        kycCase,
        DUPLICATE_KYCQA_ERROR + existingKYCCase.CaseNumber
      );
    }
  }

  /**
   * @description Prevent Duplicate KYC QA Against an COB Application
   * @param cases List of Cases
   */
  public static void validateDuplicateKYCQACasePerCOBApp(List<Case> cases) {
    Map<Id, Case> cobAppIdAndCaseMap = new Map<Id, Case>();
    for (Case kycCase : cases) {
      if (kycCase.CustomerOnboardingApplication__c != null) {
        cobAppIdAndCaseMap.put(
          kycCase.CustomerOnboardingApplication__c,
          kycCase
        );
      }
    }
    if (cobAppIdAndCaseMap.isEmpty() == true) {
      return;
    }

    List<Case> existingKYCCases = AUTO_KYCQA_CASE_REPOSITORY.queryKYCQACasesByCOBAppIds(
      cobAppIdAndCaseMap.keySet()
    );
    for (Case existingKYCCase : existingKYCCases) {
      Case kycCase = cobAppIdAndCaseMap.get(
        existingKYCCase.CustomerOnboardingApplication__c
      );
      CommonUtil.addErrorToRecordAndLog(
        kycCase,
        DUPLICATE_KYCQA_ERROR + existingKYCCase.CaseNumber
      );
    }
  }

  /**
   * @description Update Tested Date
   * @param cases List of Cases
   */
  public static void updateTestedDate(List<Case> cases) {
    for (Case oCase : cases) {
      if (canPopulateTestedDate(oCase)) {
        oCase.TestedDate__c = System.now();
      }
    }
  }

  /**
   * @description If all Test fields are not empty then capture the current date
   * @param oCase Case
   * @return True if all Test fields are not empty, false otherwise
   */
  @TestVisible
  private static Boolean canPopulateTestedDate(Case oCase) {
    return oCase?.TestedDate__c == null &&
      areTestFieldsNotEmpty(oCase) &&
      String.isNotEmpty(oCase?.Fraud_Restraint_Status__c);
  }

  /**
   * @description Check if all Test fields are not empty
   * @param oCase Case
   * @return True if all Test fields are not empty, false otherwise
   */
  @TestVisible
  private static boolean areTestFieldsNotEmpty(Case oCase) {
    return String.isNotEmpty(oCase?.Fraud_Customer_Details__c) &&
      String.isNotEmpty(oCase?.Fraud_MiddleNameCheck__c) &&
      String.isNotEmpty(oCase?.Fraud_Selfie_Comparison_Match__c) &&
      String.isNotEmpty(oCase?.Fraud_PO_Box__c) &&
      String.isNotEmpty(oCase?.Fraud_Address_Valid__c) &&
      String.isNotEmpty(oCase?.Fraud_ID_Legible__c) &&
      String.isNotEmpty(oCase?.Fraud_Customer_Photo_Modified__c) &&
      String.isNotEmpty(oCase?.Fraud_ID_Not_Picture__c) &&
      String.isNotEmpty(oCase?.Fraud_Security_Features__c);
  }

  /**
   * @description Downgrade the KYC Case
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   */
  public static void downgrade(List<Case> cases, Map<Id, Case> oldMap) {
    List<Case> casesToDowngrade = checkIfDowngrade(cases, oldMap);
    if (casesToDowngrade.isEmpty() == true) {
      return;
    }

    List<Account> oldAccounts = getAccounts(casesToDowngrade);
    List<Account> newAccounts = oldAccounts?.deepClone(true, true, true);

    setDowngradeAccountValue(newAccounts);

    processCases(casesToDowngrade, newAccounts, oldAccounts);
  }

  /**
   * @description Filter Cases to Downgrade
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   * @return List of Downgrade Cases
   */
  @TestVisible
  private static List<Case> checkIfDowngrade(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesToDowngrade = new List<Case>();
    for (Case kycQaCase : cases) {
      Case oldCase = oldMap.get(kycQaCase.Id);
      if (
        doesKYCQAHaveADefect(kycQaCase) == true &&
        checkValidStatusForDowngrade(kycQaCase, oldCase)
      ) {
        casesToDowngrade.add(kycQaCase);
      }
    }
    return casesToDowngrade;
  }

  /**
   * @description Check if the KYC QA Case status change is valid
   * @param kycQaCase KYC QA Case
   * @param oldCase Old Cases
   * @return True if the KYC QA Case has a valid status, false otherwise
   */
  @TestVisible
  private static Boolean checkValidStatusForDowngrade(
    Case kycQaCase,
    Case oldCase
  ) {
    return (oldCase.Status == GetHelpConstants.OPEN_STATUS ||
      oldCase.Status == UNDER_REVIEW_STATUS) &&
      (kycQaCase.Status == RECTIFY_DEFECT_STATUS ||
      kycQaCase.Status == PENDING_DOCUMENTS_STATUS);
  }

  /**
   * @description Check if the KYC QA Case has a defect
   * @param oCase KYC QA Case
   * @return True if the KYC QA Case has a defect, false otherwise
   */
  @TestVisible
  private static Boolean doesKYCQAHaveADefect(Case oCase) {
    return areTestFieldsNotEmpty(oCase) &&
      (oCase?.Fraud_Customer_Details__c == NO ||
      oCase?.Fraud_MiddleNameCheck__c == NO ||
      oCase?.Fraud_Selfie_Comparison_Match__c == NO ||
      oCase?.Fraud_PO_Box__c == NO ||
      oCase?.Fraud_Address_Valid__c == NO ||
      oCase?.Fraud_ID_Legible__c == NO ||
      oCase?.Fraud_Customer_Photo_Modified__c == NO ||
      oCase?.Fraud_ID_Not_Picture__c == NO ||
      oCase?.Fraud_Security_Features__c == NO);
  }

  /**
   * @description Set Downgrade Account Value
   * @param newAccounts List of New Accounts
   */
  @TestVisible
  private static void setDowngradeAccountValue(List<Account> newAccounts) {
    for (Account acc : newAccounts) {
      acc.FinServ__KYCStatus__c = DOWNGRADE_KYC_STATUS;
      acc.KYC_Verification_Level__c = DOWNGRADE_KYC_VERIFICATION_LEVEL;
    }
  }

  /**
   * @description Get Account Ids from Cases
   * @param cases List of Cases
   * @return List of Accounts
   */
  @TestVisible
  private static List<Account> getAccounts(List<Case> cases) {
    if (cases.isEmpty() == true) {
      return new List<Account>();
    }
    Set<Id> accountIds = new Set<Id>();
    for (Case oCase : cases) {
      accountIds.add(oCase.AccountId);
    }
    return AUTO_KYCQA_CASE_REPOSITORY.queryAccounts(accountIds);
  }

  /**
   * @description Upgrade the KYC Case
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   */
  public static void upgrade(List<Case> cases, Map<Id, Case> oldMap) {
    List<Case> casesToUpgrade = checkIfUpgradeInitial(cases, oldMap);
    if (casesToUpgrade.isEmpty() == true) {
      return;
    }

    List<Account> initialListOfOldAccounts = getAccounts(casesToUpgrade);

    List<Account> oldAccounts = checkAccountExitFlag(initialListOfOldAccounts);
    if (oldAccounts.isEmpty() == true) {
      return;
    }

    List<Account> newAccounts = oldAccounts?.deepClone(true, true, true);

    setUpgradeAccountValue(newAccounts);

    processCases(casesToUpgrade, newAccounts, oldAccounts);
  }

  /**
   * @description Filter Cases to Upgrade
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   * @return List of Upgrade Cases - initial list
   */
  @TestVisible
  private static List<Case> checkIfUpgradeInitial(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesToUpgrade = new List<Case>();
    for (Case kycQaCase : cases) {
      Case oldCase = oldMap.get(kycQaCase.Id);
      if (
        kycQaCase.Fraud_Defects_Rectified__c == YES &&
        kycQaCase.Status != oldCase.Status &&
        kycQaCase.Status == GetHelpConstants.CLOSED_STATUS
      ) {
        casesToUpgrade.add(kycQaCase);
      }
    }
    return casesToUpgrade;
  }

  /**
   * @description Check Account Exit Flag
   * @param initialListOfOldAccounts List of Old Accounts
   * @return List of Accounts to Upgrade
   */
  @TestVisible
  private static List<Account> checkAccountExitFlag(
    List<Account> initialListOfOldAccounts
  ) {
    List<Account> oldAccounts = new List<Account>();
    for (Account acc : initialListOfOldAccounts) {
      if (acc.CustomerExitFlag__c == false) {
        oldAccounts.add(acc);
      }
    }

    return oldAccounts;
  }

  /**
   * @description Set Upgrade Account Value
   * @param newAccounts List of New Accounts
   */
  @TestVisible
  private static void setUpgradeAccountValue(List<Account> newAccounts) {
    for (Account acc : newAccounts) {
      acc.FinServ__KYCStatus__c = UPGRADE_KYC_STATUS;
      acc.KYC_Verification_Level__c = UPGRADE_KYC_VERIFICATION_LEVEL;
    }
  }

  /**
   * @description process the KYC Cases
   * @param casesToProcess List of Cases
   * @param newAccounts List of New Accounts
   * @param oldAccounts List of Old Accounts
   */
  @TestVisible
  private static void processCases(
    List<Case> casesToProcess,
    List<Account> newAccounts,
    List<Account> oldAccounts
  ) {
    Map<Id, Case> mapAccountIdToCase = buildMapAccountIdToCase(casesToProcess);

    AutoKYCQAProfileStagingConfig config = new AutoKYCQAProfileStagingConfig(
      mapAccountIdToCase
    );

    PROFILE_STAGING_HANDLER
      .process(config, newAccounts, new Map<Id, Account>(oldAccounts));
  }

  /**
   * @description Build Map of Account Id to Case
   * @param cases List of Cases
   * @return Map of Account Id to Case
   */
  @TestVisible
  private static Map<Id, Case> buildMapAccountIdToCase(List<Case> cases) {
    Map<Id, Case> mapAccountIdToCase = new Map<Id, Case>();

    for (Case oCase : cases) {
      mapAccountIdToCase.put(oCase.AccountId, oCase);
    }

    return mapAccountIdToCase;
  }
}
