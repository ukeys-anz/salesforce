/**
 * @author Batya Aisman Sufrin
 * @since April 2025
 * @description Common actions for ANZPlus cases
 */
public with sharing class CommonCaseTriggerActions {
  private static final CommonCaseTriggerRepository REPOSITORY = (CommonCaseTriggerRepository) Lib_InstanceProvider.forType(
    CommonCaseTriggerRepository.class
  );
  private static final CaseDurationService CASE_DURATION_SERVICE = (CaseDurationService) Lib_InstanceProvider.forType(
    CaseDurationService.class
  );

  // Fields which may contain sensitive information
  private static final Set<SObjectField> FIELDS_TO_MASK = new Set<SObjectField>{
    Case.Comments,
    Case.Description
  };
  private static final String CLOSED_STATUS = 'Closed';

  /**
   * Deprecation notice: this metod has to be removed, once every case type moved to scoped handlers
   * @description Orchestrate common actions for ANZPlus cases as
   *
   * 1- auto-populate Contact lookup on ANZ Plus Cases.
   * 2- Mask tax numbers
   * 3- Update business hours field to match ANZ Plus business hours
   * Assumption: Case record types would not be manually changed from AR&C to ANZ Plus
   * @param records new trigger case records
   * @param oldMap previous values for changed records
   */
  public static void orchestrateANZPlusAction(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .equals(Case.RecordTypeId, CheckCaseRecordType.ANZX_RT_IDS)
      .toList();
    populateContactLookupForANZPlus(filteredCases, oldMap);
    maskTaxNumbers(filteredCases, oldMap);
    setBusinessHours(filteredCases);
  }

  /**
   * @description Populate contact lookup for ANZ Plus cases
   * @param records list of case records
   * @param oldMap previous values for changed records
   */
  public static void populateContactLookupForANZPlus(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .changed(Case.AccountId)
      .isNotNull(Case.AccountId)
      .toList();
    Set<Id> accountIds = ListUtil.getIds(filteredCases, Case.AccountId);
    Map<Id, Account> accountMap = new Map<Id, Account>(
      REPOSITORY.queryAccountsByIdSystemMode(accountIds)
    );

    populateContactLookupForANZPlus(filteredCases, accountMap);
  }

  /**
   * @description Populate contact lookup for ANZ Plus cases
   * @param records list of case records
   * @param accountMap map of account Id to Account
   */
  private static void populateContactLookupForANZPlus(
    List<Case> records,
    Map<Id, Account> accountMap
  ) {
    for (Case caseRec : records) {
      // Currently only caters for cases having PersonAccounts as parent (will have to handle Business Accounts later when we roll it out)
      caseRec.ContactId = accountMap.get(caseRec.AccountId)?.PersonContactId;
    }
  }

  /**
   * @description Mask tax numbers
   * @param records list of case records
   * @param oldMap previous values for changed records
   */
  public static void maskTaxNumbers(List<Case> records, Map<Id, Case> oldMap) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .anyChanged(FIELDS_TO_MASK)
      .toList();
    TextUtils.maskAndLog(filteredCases, FIELDS_TO_MASK);
  }

  /**
   * @description Set business hours to ANZ Plus business hours
   * @param records list of case records
   */
  public static void setBusinessHours(List<Case> records) {
    ListUtil.setField(
      records,
      Case.BusinessHoursId,
      QueryBusinessHours.anzXBusinessHours.Id
    );
  }

  /**
   * @description Update case duration time
   * @param records list of case records
   * @param oldMap previous values for changed records
   */
  public static void updateCaseDurationTime(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .changedTo(Case.Status, CLOSED_STATUS)
      .toList();

    try {
      Map<Id, CaseDurationObject.DurationTime> caseIdToDuration = CASE_DURATION_SERVICE.fetchCaseDurationTime(
        filteredCases,
        (Map<Id, Case>) oldMap
      );
      updateCaseDurationTime(filteredCases, caseIdToDuration);
    } catch (Exception e) {
      Logger.error('Failed to calculate case duration time', e);
      Logger.saveLog();
    }
  }

  /**
   * @description Update case duration time
   * @param records list of case records
   * @param caseIdToDuration map of case Id to duration time
   */
  private static void updateCaseDurationTime(
    List<Case> records,
    Map<Id, CaseDurationObject.DurationTime> caseIdToDuration
  ) {
    for (Case record : records) {
      Decimal durationHour = caseIdToDuration.get(record.Id)
        ?.dHours
        ?.setScale(2, RoundingMode.HALF_UP);
      if (durationHour != null) {
        record.Case_Hour_Duration__c = durationHour;
      }
    }
  }
}
