/**
 * @author @ramvilas
 * @since April 2025
 * @description class for Loan Application Residential Loan Application actions
 * @runTests ResidentialLoanApplicationActionsTest
 */
public with sharing class ResidentialLoanApplicationActions {
  private static final String HOME_LOAN_APP_DEV_NAME = 'Home_Loan_Applications_Queue';
  @TestVisible
  private static final String ACCREDITATION_RETAIL = 'Retail';
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';

  private static final List<String> SUNSET_STATUSES = new List<String>{
    'STATE_UNSPECIFIED',
    'STATE_INELIGIBLE',
    'STATE_COMPLETED',
    'STATE_DECLINED',
    'STATE_CANCELLED',
    'STATE_EXPIRED'
  };

  private static final List<String> APP_PROGRESS_BLANK_STATUSES = new List<String>{
    'STATE_EXPIRED',
    'STATE_SETTLEMENT_INITATED',
    'STATE_COMPLETED',
    'STATE_DECLINED',
    'STATE_CANCELLED'
  };

  private static final LendingTaskRepository LENDING_TASK_REPOSITORY = (LendingTaskRepository) Lib_InstanceProvider.forType(
    LendingTaskRepository.class
  );
  private static final ResidentialLoanApplicationRepository RLA_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final LendingCaseRepository LENDING_CASE_REPOSITORY = (LendingCaseRepository) Lib_InstanceProvider.forType(
    LendingCaseRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final BrokerSettingsRepository BROKER_SETTINGS_REPOSITORY = (BrokerSettingsRepository) Lib_InstanceProvider.forType(
    BrokerSettingsRepository.class
  );

  /**
   * @description Assign Home Loan Applications Queue as owner
   * @param rlaRecords records to assign owner
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> assignHomeLoanAppQueue(
    List<ResidentialLoanApplication> rlaRecords
  ) {
    ListUtil.setField(
      rlaRecords,
      ResidentialLoanApplication.OwnerId,
      QueryQueue.get(HOME_LOAN_APP_DEV_NAME)?.Id
    );
    return rlaRecords;
  }

  /**
   * @description Set the sunset timestamp date time value (usually for insert context)
   * @param records records to update
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> setSunsetTimestamp(
    List<ResidentialLoanApplication> records
  ) {
    List<ResidentialLoanApplication> recordsEnteringSunset = ListUtil.filter(
        records
      )
      .equals(ResidentialLoanApplication.Status, SUNSET_STATUSES)
      .toList();

    recordsEnteringSunset = ListUtil.setField(
      recordsEnteringSunset,
      ResidentialLoanApplication.SunsetTimestamp__c,
      System.now()
    );

    return recordsEnteringSunset;
  }

  /**
   * @description Set the sunset timestamp date time value
   * @param records records to update
   * @param oldMap old records map
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> setEnteredSunsetTimestamp(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    // Process the records
    List<ResidentialLoanApplication> recordsEnteringSunset = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(ResidentialLoanApplication.Status, SUNSET_STATUSES)
      .oldNotEquals(ResidentialLoanApplication.Status, SUNSET_STATUSES)
      .toList();

    // Set sunset timestamp
    recordsEnteringSunset = ListUtil.setField(
      recordsEnteringSunset,
      ResidentialLoanApplication.SunsetTimestamp__c,
      System.now()
    );

    return recordsEnteringSunset;
  }

  /**
   * @description Set the sunset timestamp date time value
   * @param records records to update
   * @param oldMap old records map
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> setExitedSunsetTimestamp(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    // Process the records
    List<ResidentialLoanApplication> recordsExitingSunset = ListUtil.filter(
        records,
        oldMap
      )
      .notEquals(ResidentialLoanApplication.Status, SUNSET_STATUSES)
      .changedFrom(ResidentialLoanApplication.Status, SUNSET_STATUSES)
      .toList();

    // Set sunset timestamp
    recordsExitingSunset = ListUtil.setField(
      recordsExitingSunset,
      ResidentialLoanApplication.SunsetTimestamp__c,
      null
    );

    return recordsExitingSunset;
  }

  /** @description update Status field on Case to cancel if related RLA has cancelled status
   * @param newRlaRecords  Residential Loan application records from trigger on insert/update
   * @param  oldRlaRecords  Holds records information before update
   */
  public static void cancelRelatedCreditReferralCases(
    Map<Id, ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    try {
      Set<Id> rlaRecordIds = ResidentialLoanApplicationHelper.getCancelledRlaRecordsPostChatter(
        newRlaRecords.values(),
        oldRlaRecords
      );

      List<Case> masterCaseList = LENDING_CASE_REPOSITORY.queryRelatedCreditReferralCases(
        rlaRecordIds
      );

      List<Case> caseRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareCaseWithFieldsUpdate(
        masterCaseList,
        newRlaRecords
      );

      DML_REPOSITORY.doUpdate(caseRecordsToBeUpdated);
    } catch (Exception objException) {
      Logger.info(
        'Error in ResidentialLoanApplicationActions cancelRelatedCreditReferralCases',
        objException
      );
      Logger.saveLog();
    }
  }

  /**
   * @description Syncs the process of creating cloud event model from loan app records and publishing the GCP events
   * @author Deepro De | 06-04-2024
   * @param records
   * @param triggerContext
   * @return List<Cloud_Event__e> published events
   **/
  public static List<Cloud_Event__e> publishSyncEvents(
    List<ResidentialLoanApplication> records,
    String triggerContext
  ) {
    //Checking Broker Settings Custom Setting if cloud event publish has to be bypassed
    if (
      BROKER_SETTINGS_REPOSITORY.getBrokerSettings()
        .BypassApplicationEvent__c == true
    ) {
      return null;
    }

    //Creating map of records vs event type according to trigger context type, ie. insert/update

    List<ResidentialLoanApplication> rlaFilteredRecords = ListUtil.filter(
        records
      )
      .isNotNull(ResidentialLoanApplication.Sync_Status__c)
      .notContains(
        ResidentialLoanApplication.Sync_Status__c,
        SYNC_STATUS_BLOCKED
      )
      .contains(
        ResidentialLoanApplication.Sync_Status__c,
        SYNC_STATUS_BROKER_ORG
      )
      .toList();

    List<Id> filteredLoanAppList = new List<Id>(
      ListUtil.getIds(rlaFilteredRecords, ResidentialLoanApplication.Id)
    );

    //Fetch the RLA records and the related parent record details
    List<ResidentialLoanApplication> rlaRecordList = RLA_REPOSITORY.queryLoanApplications(
      filteredLoanAppList
    );

    //Creating cloud event model from records vs event type map in order to pass into publish method
    List<BrokerCloudEventModel> cloudEventModels = ApplicationEventActions.createCloudEventModels(
      rlaRecordList,
      triggerContext
    );

    //Passing cloud event into publish method
    List<Cloud_Event__e> cloudEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    ApplicationEventActions.logSuccessEvents(cloudEvents);
    return cloudEvents;
  }

  /**
   * @description populate Assisted Broker for Retail Residential Loan Applications
   * @param records records to update
   * @param oldMap old records
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> populateRetailLoanAssistedBroker(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    List<ResidentialLoanApplication> recordsToUpdate = ListUtil.filter(
        records,
        oldMap
      )
      .changed(ResidentialLoanApplication.Assisted_Broker_TPMI_SAO__c)
      .toList();

    return ResidentialLoanApplicationHelper.processAssistedBrokerPopulation(
      recordsToUpdate,
      ACCREDITATION_RETAIL
    );
  }

  /**
   * @description Evaluates if Broker Code is present or not, and populates Sync Status
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param records
   * @return List<ResidentialLoanApplication> updated records
   **/
  public static List<ResidentialLoanApplication> updateApplicationSyncStatus(
    List<ResidentialLoanApplication> records
  ) {
    //filtering out the applications which have the sync status as blocked
    List<ResidentialLoanApplication> filteredList = ResidentialLoanApplicationHelper.getUnblockedApplication(
      records
    );

    List<ResidentialLoanApplication> recordsWithStatusWithoutBrokerOrg = ListUtil.filter(
        filteredList
      )
      .isNotBlank(ResidentialLoanApplication.Sync_Status__c)
      .notContains(
        ResidentialLoanApplication.Sync_Status__c,
        SYNC_STATUS_BROKER_ORG
      )
      .toList();
    List<ResidentialLoanApplication> recordsWithoutStatus = ListUtil.filter(
        filteredList
      )
      .isBlank(ResidentialLoanApplication.Sync_Status__c)
      .toList();

    recordsWithStatusWithoutBrokerOrg = ListUtil.formatString(
      recordsWithStatusWithoutBrokerOrg,
      ResidentialLoanApplication.Sync_Status__c,
      '{0};' + SYNC_STATUS_BROKER_ORG
    );

    recordsWithoutStatus = ListUtil.setField(
      recordsWithoutStatus,
      ResidentialLoanApplication.Sync_Status__c,
      SYNC_STATUS_BROKER_ORG
    );

    List<ResidentialLoanApplication> updatedRLARecords = new List<ResidentialLoanApplication>();
    updatedRLARecords.addAll(recordsWithoutStatus);
    updatedRLARecords.addAll(recordsWithStatusWithoutBrokerOrg);
    return updatedRLARecords;
  }

  /**
   * @description check whether the RLA related to Task is updated with CANCELLED status and then Update the Task  STATUS to EXPIRE and SUBSTATUS to "*Customer cancelled"
   * @param newRlaRecords  Residential Loan application records from trigger on insert/update
   * @param  oldRlaRecords  Holds records information before update
   */
  public static void processCancelledRLARecords(
    List<ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    try {
      List<ResidentialLoanApplication> filteredRLARecords = ListUtil.filter(
          newRlaRecords,
          oldRlaRecords
        )
        .changedTo(ResidentialLoanApplication.Status, 'STATE_CANCELLED')
        .toList();

      Set<Id> rlaRecordIds = ListUtil.getIds(
        filteredRLARecords,
        ResidentialLoanApplication.Id
      );

      List<Task> masterTaskList = LENDING_TASK_REPOSITORY.queryActiveTaskWithRLA(
        rlaRecordIds
      );

      List<Task> taskRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareTaskWithFieldsUpdate(
        masterTaskList
      );

      DML_REPOSITORY.updateRecords(
        taskRecordsToBeUpdated,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
    } catch (Exception objException) {
      Logger.info(
        'Error in ResidentialLoanApplicationActions processCancelledRLARecords',
        objException
      );
      Logger.saveLog();
    }
  }

  /**
   * @description Update Application progress for Residential Loan Applications
   * @param records records to update
   * @param oldMap old records
   * @return List<ResidentialLoanApplication> updated records
   */
  public static List<ResidentialLoanApplication> updateApplicationProgressToBlank(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    List<ResidentialLoanApplication> recordsComplitionStatus = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(ResidentialLoanApplication.Status, APP_PROGRESS_BLANK_STATUSES)
      .toList();
    List<ResidentialLoanApplication> recordsToUpdate = ListUtil.setField(
      recordsComplitionStatus,
      ResidentialLoanApplication.Application_Progress__c,
      null
    );

    return recordsToUpdate;
  }

  /**
   * @description Set Loan Application validity when status of RLA is changed
   * @param rlas Residential Loan application records from trigger
   * @return List<ResidentialLoanApplication> list of RLA records with sunset timestamp calculated
   */
  public static List<ResidentialLoanApplication> setResidentialLoanApplicationValidity(
    List<ResidentialLoanApplication> rlas
  ) {
    for (ResidentialLoanApplication rla : rlas) {
      String recordTypeName = QueryRT.of(ResidentialLoanApplication.SObjectType)
        .get(rla.recordTypeId)
        .getName();
      if (recordTypeName != 'RLS') {
        continue;
      }

      Loan_Application_Validity__mdt loanApplicationValidityMDT = RLA_REPOSITORY.getLoanApplicationValidityMetadata(
        recordTypeName,
        rla.Status
      );
      if (loanApplicationValidityMDT == null) {
        continue;
      }

      Date sunsetTimeStampDate = ResidentialLoanApplicationHelper.getLoanApplicationValidity(
        loanApplicationValidityMDT
      );
      rla.SunsetTimestamp__c = sunsetTimeStampDate;
    }
    return rlas;
  }
}
