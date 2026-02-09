/**
 * @author Mani
 * @since 12/2024
 * @description This acts as a action class profile update case types to perform the business process and automations
 */
public with sharing class ProfileUpdateCaseActions {
  @TestVisible
  private static Group idOpsQueue = QueryQueue.get('ID_Ops_Queue');
  @TestVisible
  private static final String AU_DOC_PREFIX = 'DOCUMENT_TYPE_AUSTRALIAN_';
  @TestVisible
  private static final String ERROR_STAGING_PENDING = 'Cannot close case until the legal name is updated in OCV.';
  private static final String AU_COUNTRY_CODE = 'AUS';
  @TestVisible
  private static final String ADDRESS_TEMPLATE = '{0}\r\n{1} {2} {3}\r\n{4}';
  public static final string CASE_TYPE_LEGAL_NAME = 'Legal Name QA';
  public static final string PASS = 'Pass';
  public static final string FAILED_DOCUMENT_INVALID = 'Failed - Document Provided Invalid';
  public static final string FAILED_DOCUMENT_QUALITY = 'Failed - Document Quality Issue';
  private static final Set<String> LEGALNAME_NOTIFICATION_STATUSES = new Set<String>{
    PASS,
    FAILED_DOCUMENT_INVALID,
    FAILED_DOCUMENT_QUALITY
  };
  private static final ProfileUpdateCaseRepository REPOSITORY = (ProfileUpdateCaseRepository) Lib_InstanceProvider.forType(
    ProfileUpdateCaseRepository.class
  );
  private static final ProfileStagingHandler PROFILE_STAGING = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  /**
   * @description Assign newly created Profile Update Cases to ID Ops Queue
   * @param records Case records being inserted by trigger
   */
  public static void setOwnerToIDOpsQueue(List<Case> records) {
    ListUtil.setField(records, Case.OwnerId, idOpsQueue.Id);
  }

  /**
   * @description when a legal name cases are closed, cloud events will be published to send email communications
   * @param records Case records being updated by trigger
   * @param oldMap old instaces Case records being updated by trigger
   */
  public static void legalNameNotifications(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> validCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .changedTo(Case.Status, GetHelpConstants.CLOSED_STATUS)
      .equals(Case.Fraud_Review_Outcome__c, LEGALNAME_NOTIFICATION_STATUSES)
      .toList();
    Set<Id> caseIds = ListUtil.getIds(validCases, Case.Id);
    List<Case> caseToSendNotification = REPOSITORY.getLegalNameCaseForNotification(
      caseIds
    );
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    for (Case theCase : caseToSendNotification) {
      cloudEventModels.add(new LegalNameCaseCloudEventModel(theCase));
    }
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description Validates the staging progress for legal name cases on close.
   * @param records Case records being updated by trigger
   * @param oldMap old instances of Case records being updated by trigger
   */
  public static void validateStagingProgress(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> legalNameCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .equals(Case.Fraud_Review_Outcome__c, PASS)
      .changedTo(Case.Status, 'Closed')
      .toList();
    Set<Id> caseIds = new Map<Id, Case>(legalNameCases).keySet();
    List<Customer_Profile_Updates__c> pendingStagings = REPOSITORY.getPendingStagingRecordsByCaseIds(
      caseIds
    );
    Set<Id> pendingCaseIds = ListUtil.getIds(
      pendingStagings,
      Customer_Profile_Updates__c.Case__c
    );
    List<Case> pendingCases = ListUtil.filter(legalNameCases)
      .equals(Case.Id, pendingCaseIds)
      .toList();
    ListUtil.addError(pendingCases, ERROR_STAGING_PENDING);
  }

  /**
   * @description Sets the document country code for legal name cases based on the document type.
   * @param records Case records being updated by trigger
   * @param oldMap old instances of Case records being updated by trigger
   */
  public static void setDocumentCountryCode(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> legalNameCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .changed(Case.DocumentType__c)
      .toList();

    List<Case> auDocCases = ListUtil.filter(legalNameCases, oldMap)
      .contains(Case.DocumentType__c, AU_DOC_PREFIX)
      .toList();
    ListUtil.setField(auDocCases, Case.CountryCode__c, 'AUS');

    List<Case> nonAuDocCases = ListUtil.filter(legalNameCases)
      .notContains(Case.DocumentType__c, AU_DOC_PREFIX)
      .equals(Case.CountryCode__c, AU_COUNTRY_CODE)
      .toList();
    ListUtil.setField(nonAuDocCases, Case.CountryCode__c, null);
  }

  /**
   * @description when case's Review Outcome is set to 'Pass', a staging record will be created and a Cloud Event will be published
   * @param records Case records being updated by trigger
   * @param oldMap old instaces Case records being updated by trigger
   */
  public static void sendLegalNameUpdateToOCV(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> validCases = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .changedTo(Case.Fraud_Review_Outcome__c, PASS)
      .toList();

    Map<Id, Case> accIdToCaseMap = (Map<Id, Case>) ListUtil.mapBy(
      validCases,
      Case.AccountId
    );
    List<Account> acctRecords = REPOSITORY.getAccounts(accIdToCaseMap.keySet());

    PROFILE_STAGING.process(
      new ProfileUpdateCaseStagingConfig(accIdToCaseMap),
      acctRecords,
      null
    );
  }

  /**
   * @description Filters the provided Case records to include only legal name cases
   * and retrieves associated Account information for further processing.
   * @param records The list of Case records to filter and process.
   */
  public static void setLegalNameQAInfo(List<Case> records) {
    records = ListUtil.filter(records)
      .equals(Case.Type, CASE_TYPE_LEGAL_NAME)
      .toList();
    Set<Id> accountIds = ListUtil.getIds(records, Case.AccountId);
    List<Account> accounts = REPOSITORY.getAccounts(accountIds);
    setLegalNameQAInfo(records, accounts);
  }

  /**
   * @description Updates the provided Case records with legal name and address information
   * from the associated Account records.
   * @param records  The list of Case records to update.
   * @param accounts The list of Account records containing legal name and address information.
   */
  @TestVisible
  public static void setLegalNameQAInfo(
    List<Case> records,
    List<Account> accounts
  ) {
    Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
    for (Case c : records) {
      Account acc = accountMap.get(c.AccountId);
      if (acc == null) {
        continue;
      }
      c.CurrentFirstName__c = acc.FirstName;
      c.CurrentMiddleName__c = acc.MiddleName;
      c.CurrentLastName__c = acc.LastName;
      c.CurrentAddress__c = String.format(
        ADDRESS_TEMPLATE,
        new List<String>{
          acc.PersonOtherStreet,
          acc.PersonOtherCity,
          acc.PersonOtherState,
          acc.PersonOtherPostalCode,
          acc.PersonOtherCountry
        }
      );
    }
  }
}
