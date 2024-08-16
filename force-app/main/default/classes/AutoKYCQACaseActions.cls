/**
 * @author Batya Aisman Sufrin
 * @since 09/2023
 * @description AutoKYCQACaseActions class is to handle all the Auto KYC QA Case Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class AutoKYCQACaseActions {
  private static final AutoKYCQACaseRepository REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );

  private static final ProfileStagingHandler PROFILE_STAGING_HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  @TestVisible
  private static final String DUPLICATE_KYCQA_ERROR = 'Error occurred while creating KYC QA Case. A KYC QA Case already exists for this customer. Case number: ';
  @TestVisible
  private static final String ERROR_NO_COB = 'KYC QA case must be linked to a Customer Onboarding Application';
  @TestVisible
  private static final String YES = 'Yes';
  @TestVisible
  private static final String NO = 'No';
  @TestVisible
  private static final String LICENCE = 'Licence';
  @TestVisible
  private static final String PASSPORT = 'Passport';
  @TestVisible
  private static final String VERIFICATION_TYPE_ASSISTED = 'ASSISTED';
  @TestVisible
  private static final String VERIFICATION_TYPE_STP = 'STP';

  private static final Set<String> DOWNGRADE_OLD_STATUSES = new Set<String>{
    'Open',
    'Under Review'
  };

  private static final Set<String> DOWNGRADE_NEW_STATUSES = new Set<String>{
    'Rectify Defect',
    'Pending Documents',
    'Refer to Fraud'
  };

  private static final Set<SObjectField> TEST_FIELDS = new Set<SObjectField>{
    Case.Fraud_Customer_Details__c,
    Case.Fraud_MiddleNameCheck__c,
    Case.Fraud_Selfie_Comparison_Match__c,
    Case.Fraud_PO_Box__c,
    Case.Fraud_Address_Valid__c,
    Case.Fraud_ID_Legible__c,
    Case.Fraud_ID_Not_Picture__c,
    Case.Fraud_Customer_Photo_Modified__c,
    Case.Fraud_Security_Features__c
  };

  @TestVisible
  private static final Map<String, String> VERIFICATION_PRIORITY = new Map<String, String>{
    'MANUAL' => 'High',
    'UNSPECIFIED' => 'High',
    'ASSISTED' => 'Medium',
    'STP' => 'Standard'
  };

  @TestVisible
  private static final String DOWNGRADE_KYC_STATUS = 'PC';
  @TestVisible
  private static final String DOWNGRADE_KYC_VERIFICATION_LEVEL = 'RR';
  @TestVisible
  private static final String UPGRADE_KYC_STATUS = 'CO';
  @TestVisible
  private static final String UPGRADE_KYC_VERIFICATION_LEVEL = 'VE';

  /**
   * @description Update KYC QA Case fields
   * @param cases List of Cases
   */
  public static void populateAutoKYCQAChecks(List<Case> cases) {
    Logger.debug('Set KYC QA fields from COB App started: ' + System.now());

    cases = ListUtil.filterNoError(cases);
    Map<String, Case> personaIdToCaseMap = (Map<String, Case>) ListUtil.mapByString(
      cases,
      Case.PersonaId__c
    );
    List<CustomerOnboardingApplication__c> cobApps = REPOSITORY.queryCobsByPersonaIds(
      personaIdToCaseMap.keySet()
    );
    Map<String, CustomerOnboardingApplication__c> cobMap = (Map<String, CustomerOnboardingApplication__c>) ListUtil.mapByString(
      cobApps,
      CustomerOnboardingApplication__c.PersonaId__c
    );
    setFieldsFromCob(personaIdToCaseMap.values(), cobMap);

    Logger.debug('Set KYC QA fields from COB App finished: ' + System.now());
  }

  /**
   * @description Validates the Customer Onboarding Application and builds a map of Cases.
   * @param cases The list of Cases to validate and build the map from.
   */
  public static void validateCobExist(List<Case> cases) {
    for (Case record : cases) {
      if (record.CustomerOnboardingApplication__c == null) {
        CommonUtil.addErrorToRecordAndLog(record, ERROR_NO_COB);
      }
    }
  }

  /**
   * @description Sets fields on Case records based on data from CustomerOnboardingApplication__c records.
   * @param cases A list of Case records to update.
   * @param cobMap A map of PersonaId__c to CustomerOnboardingApplication__c records.
   */
  @TestVisible
  private static void setFieldsFromCob(
    List<Case> cases,
    Map<String, CustomerOnboardingApplication__c> cobMap
  ) {
    for (Case record : cases) {
      if (!cobMap.containsKey(record.PersonaId__c)) {
        continue;
      }
      CustomerOnboardingApplication__c cob = cobMap.get(record.PersonaId__c);

      record.Priority = VERIFICATION_PRIORITY.get(cob.VerificationType__c);
      setAddressChecks(record, cob);
      setCustomerChecks(record, cob);
    }
  }

  /**
   * @description Sets the address checks for a Case record based on the CustomerOnboardingApplication__c record.
   * @param record The Case record to update.
   * @param cob The CustomerOnboardingApplication__c record.
   */
  @TestVisible
  private static void setAddressChecks(
    Case record,
    CustomerOnboardingApplication__c cob
  ) {
    Logger.debug('Set KYC QA fields from Address started: ' + System.now());

    if (cob.COBAddresses__r.isEmpty()) {
      return;
    }
    COBAddress__c address = cob.COBAddresses__r[0];
    record.Fraud_PO_Box__c = address.QASAddress__c ? YES : null;
    record.Fraud_Address_Valid__c = address.QASAddress__c ? YES : null;

    Logger.debug('Set KYC QA fields from Address finished: ' + System.now());
  }

  /**
   * @description Sets the customer checks for a given Case record and CustomerOnboardingApplication__c.
   * COBPrimaryIDDocument__c from the COBPrimaryIDDocuments__r list and performs the following checks:
   * - checkMiddleName: Sets the Fraud_MiddleNameCheck__c field of the Case record to YES if the check passes, otherwise sets it to null.
   * - checkCustomer: Sets the Fraud_Customer_Details__c field of the Case record to YES if the check passes, otherwise sets it to null.
   *
   * @param record The Case record to set the customer checks on.
   * @param cob The CustomerOnboardingApplication__c to retrieve the COBPrimaryIDDocuments__r list from.
   */
  @TestVisible
  private static void setCustomerChecks(
    Case record,
    CustomerOnboardingApplication__c cob
  ) {
    Logger.debug('Set KYC QA fields from PID started: ' + System.now());

    if (cob.COBPrimaryIDDocuments__r.isEmpty()) {
      return;
    }

    COBPrimaryIDDocument__c pid = cob.COBPrimaryIDDocuments__r[0];
    record.Fraud_MiddleNameCheck__c = checkMiddleName(pid) ? YES : null;
    record.Fraud_Customer_Details__c = checkPrimaryId(
        pid,
        cob.VerificationType__c
      )
      ? YES
      : null;

    Logger.debug('Set KYC QA fields from PID finished: ' + System.now());
  }

  /**
   * @description Checks if the customer's information matches the provided primary ID document.
   * @param pid The COBPrimaryIDDocument__c object representing the primary ID document.
   * @param verificationType The type of verification being performed.
   * @return `Boolean` Indicating whether the customer's information matches the document.
   */
  @TestVisible
  private static Boolean checkPrimaryId(
    COBPrimaryIDDocument__c pid,
    String verificationType
  ) {
    Boolean doesFullNameMatch = doesFullNameMatch(pid);
    Boolean doesDocumentMatch = doesDocumentMatch(pid);

    Logger.debug('Verification Type: ' + verificationType);
    Logger.debug('Licence/Passport match: ' + doesDocumentMatch);
    Logger.debug('Fullname match: ' + doesFullNameMatch);
    Logger.debug('Date Of Birth OCR Match: ' + pid.DateOfBirthOCRMatch__c);
    Logger.debug('Expiry Date OCR Match: ' + pid.ExpiryDateOCRMatch__c);

    if (
      verificationType == VERIFICATION_TYPE_STP ||
      verificationType == VERIFICATION_TYPE_ASSISTED
    ) {
      return doesDocumentMatch;
    }

    return doesFullNameMatch &&
      pid.DateOfBirthOCRMatch__c &&
      pid.ExpiryDateOCRMatch__c &&
      doesDocumentMatch;
  }

  /**
   * @description Populate Middle Name Check test result
   * @param pid COB Primary ID Document
   * @return `Boolean` Middle Name Check result
   */
  @TestVisible
  private static Boolean checkMiddleName(COBPrimaryIDDocument__c pid) {
    Boolean areFirstLastNamesOcrServerBlank =
      String.isBlank(pid.FirstNameOCRServer__c) &&
      String.isBlank(pid.LastNameOCRServer__c);
    Boolean doesMiddleNamesMatch =
      pid.MiddleNamesOCRMatch__c &&
      String.isNotBlank(pid.MiddleNamesOCRServer__c);

    Logger.debug('Midddle Names match: ' + doesMiddleNamesMatch);
    Logger.debug(
      'First And Last Names OCR Server Blank: ' +
      areFirstLastNamesOcrServerBlank
    );

    if (areFirstLastNamesOcrServerBlank) {
      return false;
    }
    if (doesMiddleNamesMatch) {
      return true;
    }
    return doesFullNameMatch(pid) && doesDocumentMatch(pid);
  }

  /**
   * @description Check whether Full Name values matching Full Name Server OCR values
   * @param pid COB Primary Document
   * @return `Boolean` True if Full Name values matching Full Name Server OCR values, false otherwise
   */
  @TestVisible
  private static Boolean doesFullNameMatch(COBPrimaryIDDocument__c pid) {
    String cobPIDDFullName = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{ pid.FirstName__c, pid.MiddleNames__c, pid.LastName__c }
    );
    String cobPIDDFullNameOCRServer = CommonUtil.buildTrimmedConcatenatedString(
      new List<String>{
        pid.FirstNameOCRServer__c,
        pid.MiddleNamesOCRServer__c,
        pid.LastNameOCRServer__c
      }
    );

    return cobPIDDFullName.equalsIgnoreCase(cobPIDDFullNameOCRServer);
  }

  /**
   * @description Determines whether the provided COBPrimaryIDDocument__c object matches the document type and OCR match criteria.
   * @param pid The COBPrimaryIDDocument__c object to check for a match.
   * @return `Boolean` Returns true if the document matches the criteria, otherwise returns false.
   */
  @TestVisible
  private static Boolean doesDocumentMatch(COBPrimaryIDDocument__c pid) {
    Boolean doesLicenceMatch =
      pid.IdDocumentType__c == LICENCE && pid.LicenceNumberOCRMatch__c;
    Boolean doesPassportMatch =
      pid.IdDocumentType__c == PASSPORT && pid.PassportNumberOCRMatch__c;
    return doesLicenceMatch || doesPassportMatch;
  }

  /**
   * @description Prevent Duplicate KYC QA Against a Customer (Account)
   * @param cases List of Cases
   */
  public static void validateDuplicateKYCQACasePerAccount(List<Case> cases) {
    Map<Id, Case> accountIdAndCaseMap = (Map<Id, Case>) ListUtil.mapById(
      cases,
      Case.AccountId
    );

    List<Case> existingKYCCases = REPOSITORY.queryKYCQACasesByAccountIds(
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
    Map<Id, Case> cobAppIdAndCaseMap = (Map<Id, Case>) ListUtil.mapById(
      cases,
      Case.CustomerOnboardingApplication__c
    );

    List<Case> existingKYCCases = REPOSITORY.queryKYCQACasesByCOBAppIds(
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
      hasKycCheckCompleted(oCase) &&
      String.isNotEmpty(oCase?.Fraud_Restraint_Status__c);
  }

  /**
   * @description Check if all Test fields are not empty
   * @param oCase Case
   * @return True if all Test fields are not empty, false otherwise
   */
  @TestVisible
  private static boolean hasKycCheckCompleted(Case oCase) {
    for (SObjectField field : TEST_FIELDS) {
      String value = String.valueOf(oCase?.get(field));
      if (String.isBlank(value)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Downgrade the KYC Case
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   */
  public static void downgrade(List<Case> cases, Map<Id, Case> oldMap) {
    List<Case> casesToDowngrade = filterDowngradeCases(cases, oldMap);
    Map<Id, Case> accIdToCaseMap = (Map<Id, Case>) ListUtil.mapById(
      casesToDowngrade,
      Case.AccountId
    );
    List<Account> oldAccounts = REPOSITORY.queryAccounts(
      accIdToCaseMap.keySet()
    );
    List<Account> newAccounts = buildDowngradedAccounts(oldAccounts);
    AutoKYCQAProfileStagingConfig config = new AutoKYCQAProfileStagingConfig(
      accIdToCaseMap
    );
    PROFILE_STAGING_HANDLER
      .process(config, newAccounts, new Map<Id, Account>(oldAccounts));
  }

  /**
   * @description Filter Cases to Downgrade
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   * @return List of Downgrade Cases
   */
  @TestVisible
  private static List<Case> filterDowngradeCases(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesToDowngrade = new List<Case>();
    for (Case kycQaCase : cases) {
      Case oldCase = oldMap.get(kycQaCase.Id);
      if (
        hasKycCheckCompletedWithDefect(kycQaCase) == true &&
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
    return DOWNGRADE_OLD_STATUSES.contains(oldCase.Status) &&
      DOWNGRADE_NEW_STATUSES.contains(kycQaCase.Status);
  }

  /**
   * @description Check if the KYC QA Case has a defect
   * @param oCase KYC QA Case
   * @return True if the KYC QA Case has a defect, false otherwise
   */
  @TestVisible
  private static Boolean hasKycCheckCompletedWithDefect(Case oCase) {
    if (!hasKycCheckCompleted(oCase)) {
      return false;
    }
    for (SObjectField field : TEST_FIELDS) {
      if (oCase.get(field) == NO) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description Set Downgrade Account Value
   * @param accounts List of Accounts
   * @return `List<Account>` new instance of accounts with KYC downgrade values
   */
  @TestVisible
  private static List<Account> buildDowngradedAccounts(List<Account> accounts) {
    List<Account> newAccounts = accounts.deepClone(true, true, true);
    for (Account acc : newAccounts) {
      acc.FinServ__KYCStatus__c = DOWNGRADE_KYC_STATUS;
      acc.KYC_Verification_Level__c = DOWNGRADE_KYC_VERIFICATION_LEVEL;
    }
    return newAccounts;
  }

  /**
   * @description Upgrade the KYC Case
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   */
  public static void upgrade(List<Case> cases, Map<Id, Case> oldMap) {
    List<Case> casesToUpgrade = filterUpgradeCases(cases, oldMap);
    Map<Id, Case> accIdToCaseMap = (Map<Id, Case>) ListUtil.mapById(
      casesToUpgrade,
      Case.AccountId
    );
    List<Account> accounts = REPOSITORY.queryAccountsNotExited(
      accIdToCaseMap.keySet()
    );
    Set<String> ocvIds = ListUtil.getStrings(accounts, Account.OCV_ID__c);
    List<Account> exitedAccounts = REPOSITORY.queryExitedAccountsByOcvIds(
      ocvIds
    );
    List<Account> oldAccounts = filterAccountsNotExited(
      accounts,
      exitedAccounts
    );
    List<Account> newAccounts = buildUpgradedAccounts(oldAccounts);
    AutoKYCQAProfileStagingConfig config = new AutoKYCQAProfileStagingConfig(
      accIdToCaseMap
    );
    PROFILE_STAGING_HANDLER
      .process(config, newAccounts, new Map<Id, Account>(oldAccounts));
  }

  /**
   * @description Filter Cases to Upgrade
   * @param cases List of Cases
   * @param oldMap Old Map of Cases
   * @return List of Upgrade Cases - initial list
   */
  @TestVisible
  private static List<Case> filterUpgradeCases(
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
   * @description Filter list of accounts against exited accounts
   * @param accounts List of Old Accounts
   * @param exitedAccounts Exited accounts
   * @return List of Accounts that are not exited
   */
  @TestVisible
  private static List<Account> filterAccountsNotExited(
    List<Account> accounts,
    List<Account> exitedAccounts
  ) {
    Set<String> exitedOcvIds = ListUtil.getStrings(
      exitedAccounts,
      Account.OCV_ID__c
    );
    List<Account> accountsNotExited = new List<Account>();
    for (Account acc : accounts) {
      if (exitedOcvIds.contains(acc.OCV_ID__c) == false) {
        accountsNotExited.add(acc);
      }
    }
    return accountsNotExited;
  }

  /**
   * @description Set Upgrade Account Value
   * @param accounts List of Accounts
   * @return `List<Account>` new instance of accounts with KYC upgrade values
   */
  @TestVisible
  private static List<Account> buildUpgradedAccounts(List<Account> accounts) {
    List<Account> newAccounts = accounts.deepClone(true, true, true);
    for (Account acc : newAccounts) {
      acc.FinServ__KYCStatus__c = UPGRADE_KYC_STATUS;
      acc.KYC_Verification_Level__c = UPGRADE_KYC_VERIFICATION_LEVEL;
    }
    return newAccounts;
  }

  /**
   * @description populate default fields on KYC QA cases if the status is Closed and Sub Status is No Defect
   * @param records The list of Case records to populate with default values.
   * @param oldMap The map of old Case records, used to compare with the new records.
   */
  public static void populateClosedNoDefectDefaults(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    for (Case record : records) {
      if (!checkClosedAsNoDefect(record, oldMap.get(record.Id))) {
        continue;
      }
      for (SObjectField field : TEST_FIELDS) {
        record.put(field, YES);
      }
      record.Fraud_Middle_Name__c = YES;
      record.Fraud_Middle_Initial__c = YES;
      record.Fraud_Restraint_Status__c = 'N/A';
      record.Fraud_Defects_Rectified__c = 'Not Applicable';
    }
  }

  /**
   * @description Checks if the case is closed as "No Defect" and not downgraded.
   * @param record The new Case record.
   * @param oldRecord The old Case record.
   * @return `Boolean` Returns true if the case is closed as "No Defect" and not downgraded, false otherwise.
   */
  @TestVisible
  private static Boolean checkClosedAsNoDefect(Case record, Case oldRecord) {
    Boolean closedAsNoDefect =
      record.Sub_Status__c != oldRecord?.Sub_Status__c &&
      record.Sub_Status__c == GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT;
    Boolean wasDowngraded =
      hasKycCheckCompletedWithDefect(record) &&
      record.Fraud_Defects_Rectified__c == YES;
    return closedAsNoDefect && !wasDowngraded && !record.hasErrors();
  }
}
