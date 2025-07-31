/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description class for Residential Loan Application actions
 * @runTests ResidentialLoanAppActionsTest
 */
public with sharing class ResidentialLoanApplicationActions {
  @TestVisible
  private static final String ACCREDITATION_RETAIL = 'Retail';
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';
  private static final ResidentialLoanApplicationRepository RLA_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final BrokerCodeRepository BROKER_CODE_REPOSITORY = (BrokerCodeRepository) Lib_InstanceProvider.forType(
    BrokerCodeRepository.class
  );
  private static final CustomSettingsRepository BROKER_SETTINGS_REPOSITORY = (CustomSettingsRepository) Lib_InstanceProvider.forType(
    CustomSettingsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

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
    List<ResidentialLoanApplication> recordsToUpdate = getRecordsToUpdateAssistedBroker(
      records,
      oldMap
    );
    return processAssistedBrokerPopulation(
      recordsToUpdate,
      ACCREDITATION_RETAIL
    );
  }

  /**
   * @description populate Assisted Broker for Retail Residential Loan Applications
   * @param records records to update
   * @param oldMap old records
   * @return List<ResidentialLoanApplication> updated records
   */
  @TestVisible
  private static List<ResidentialLoanApplication> getRecordsToUpdateAssistedBroker(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    List<ResidentialLoanApplication> recordsToUpdate = new List<ResidentialLoanApplication>();
    for (ResidentialLoanApplication record : records) {
      ResidentialLoanApplication oldRecord = oldMap.get(record.Id);
      if (
        oldRecord != null &&
        record.Assisted_Broker_TPMI_SAO__c ==
        oldRecord.Assisted_Broker_TPMI_SAO__c
      ) {
        continue;
      }
      recordsToUpdate.add(record);
    }
    return recordsToUpdate;
  }

  /**
   * @description populate Assisted Broker based on Loan Type
   * @param records records to update
   * @param accreditationType type of loan
   * @return List<ResidentialLoanApplication> updated records
   */
  @TestVisible
  private static List<ResidentialLoanApplication> processAssistedBrokerPopulation(
    List<ResidentialLoanApplication> records,
    String accreditationType
  ) {
    Map<String, String> extIdToBrokerIdMap = new Map<String, String>();
    for (ResidentialLoanApplication record : records) {
      String brokerIdentifier =
        record.Assisted_Broker_TPMI_SAO__c +
        '_' +
        accreditationType;
      extIdToBrokerIdMap.put(record.ApplicationExtIdentifier, brokerIdentifier);
    }
    Set<String> brokerIdentifiers = new Set<String>(
      extIdToBrokerIdMap.values()
    );
    List<Broker_Code__c> brokerCodes = BROKER_CODE_REPOSITORY.getBrokerIdentifiers(
      brokerIdentifiers
    );
    List<Broker_Code__c> validBrokerCodes = new List<Broker_Code__c>();

    for (Broker_Code__c brokerCode : brokerCodes) {
      String syncStatus = brokerCode.Broker_Name__r.Sync_Status__c;
      if (isInvalidSyncStatus(syncStatus)) {
        continue;
      }
      validBrokerCodes.add(brokerCode);
    }

    Map<String, Id> brokerCodeToContactMap = new Map<String, Id>();
    for (Broker_Code__c brokerCode : validBrokerCodes) {
      brokerCodeToContactMap.put(
        brokerCode.External_Id__c,
        brokerCode.Broker_Name__c
      );
    }
    for (ResidentialLoanApplication record : records) {
      String brokerIdentifier = extIdToBrokerIdMap.get(
        record.ApplicationExtIdentifier
      );
      if (brokerIdentifier != null) {
        record.Assisted_Broker__c = brokerCodeToContactMap.get(
          brokerIdentifier
        );
      }
    }
    return records;
  }

  /**
   * @description Filters out invalid Broker_Code__c records based on Sync_Status__c values in the related contact record.
   * @param syncStatus  sync status of the related contact record.
   * @return Boolean true if the record is invalid, false otherwise.
   */
  private static Boolean isInvalidSyncStatus(String syncStatus) {
    if (String.isBlank(syncStatus)) {
      return false;
    }

    String padded = ';' + syncStatus + ';';

    return padded.contains(
        ';' + BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL + ';'
      ) ||
      padded.contains(';' + BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID + ';');
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
      BROKER_SETTINGS_REPOSITORY.brokerSettings().BypassApplicationEvent__c ==
      true
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
   * @description Evaluates if Broker Code is present or not, and populates Sync Status
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param records
   **/
  public static void updateApplicationSyncStatus(
    List<ResidentialLoanApplication> records
  ) {
    //filtering out the applications which have the sync status as blocked
    List<ResidentialLoanApplication> filteredList = getUnblockedApplication(
      records
    );

    for (ResidentialLoanApplication eachLoanApp : filteredList) {
      //if the sync status is not blank and the 'Broker Org' staus is not added then append the status 'Broker Org' to the exisitng list of selected values
      if (
        String.isNotBlank(eachLoanApp.Sync_Status__c) &&
        eachLoanApp.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG) == false
      ) {
        eachLoanApp.Sync_Status__c += ';' + SYNC_STATUS_BROKER_ORG;
        continue;
      }
      //if the sync status is blank then add the status 'Broker Org'
      eachLoanApp.Sync_Status__c = SYNC_STATUS_BROKER_ORG;
    }
  }

  /** @description cancelResidentialLoanApplication cancels residential loan application
   * @param rlaObject map of residential loan application fields
   * @return response from mule
   */
  @AuraEnabled
  public static String cancelResidentialLoanApplication(
    Map<String, String> rlaObject
  ) {
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      HttpCalloutResponse response = rlaRepo.cancelResidentialLoanApp(
        rlaObject.get('requestId'),
        rlaObject.get('ocvId')
      );
      if (!response.successful) {
        throw CommonUtil.logException(response);
      }
      ResidentialLoanApplication rlaRecord = ResidentialLoanApplicationHelper.updateFieldsOnLoanCancellation(
        rlaObject
      );

      DML_REPOSITORY.doUpdate(rlaRecord);

      String postContent = ResidentialLoanApplicationHelper.postNotesToChatter(
        rlaObject
      );

      ChatterUtils.makeAPost(
        rlaObject.get('recordId'),
        postContent,
        ChatterUtils.POST_TYPE_RICH_TEXT
      );

      return 'success';
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description Evaluates and filters out the applications which have Blocked Sync Status
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param records
   * @return List<ResidentialLoanApplication> filtered list
   **/
  public static List<ResidentialLoanApplication> getUnblockedApplication(
    List<ResidentialLoanApplication> records
  ) {
    List<ResidentialLoanApplication> filteredList = new List<ResidentialLoanApplication>();
    for (ResidentialLoanApplication eachRecord : records) {
      //if the Broker code is null OR if the Sync Status contains 'Blocked' then do not process
      if (
        eachRecord.Assisted_Broker_TPMI_SAO__c == null ||
        (String.isNotBlank(eachRecord.Sync_Status__c) &&
        eachRecord.Sync_Status__c.contains(SYNC_STATUS_BLOCKED))
      ) {
        continue;
      }
      filteredList.add(eachRecord);
    }
    return filteredList;
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
      Set<Id> rlaRecordIds = getCancelledRlaRecordsPostChatter(
        newRlaRecords.values(),
        oldRlaRecords
      );

      List<Case> masterCaseList = RLA_REPOSITORY.queryRelatedCreditReferralCases(
        rlaRecordIds
      );

      List<Case> caseRecordsToBeUpdated = prepareCaseWithFieldsUpdate(
        masterCaseList,
        newRlaRecords
      );

      DML_REPOSITORY.doUpdate(caseRecordsToBeUpdated);
    } catch (Exception objException) {
      Logger.error('Error in ResidentialLoanApplicationActions ', objException);
      Logger.saveLog();
    }
  }

  /**
   * @description prepareCaseWithFieldsUpdate prepare Case record's field value which needs to be updated
   * @param masterCaseList master list of Case with all the related detail
   * @param newRlaRecords Map of RLAs with updated fields
   * @return List<Case>  Case records with status value as expired and sub status field value as Customer Cancelled.
   */
  @TestVisible
  private static List<Case> prepareCaseWithFieldsUpdate(
    List<Case> masterCaseList,
    Map<Id, ResidentialLoanApplication> newRlaRecords
  ) {
    List<Case> caseRecordsToBeUpdated = new List<Case>();
    for (Case caseRecord : masterCaseList) {
      if (
        newRlaRecords.get(caseRecord.Loan_Application__c)
          .Cancellation_Reason__c ==
        BOHConstants.RLA_CREDIT_ASSESSMENT_EXPIRED_REASON
      ) {
        caseRecord.Status = BOHConstants.CASE_CLOSED_EXPIRED_STATUS;
      } else {
        caseRecord.Status = BOHConstants.CASE_CLOSED_CANCELLED_STATUS;
      }
      caseRecordsToBeUpdated.add(caseRecord);
    }
    return caseRecordsToBeUpdated;
  }

  /**
   * @description To filter out the RLA records with Cancelled status
   * @param newRlaRecords Residential Loan application records from trigger on update
   * @param oldRlaRecords Holds records information before update
   * @return Residential Loan Application records with Cancelled status to process
   */
  @TestVisible
  public static Set<Id> getCancelledRlaRecordsPostChatter(
    List<ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    Set<Id> rlaRecordIds = new Set<Id>();
    for (ResidentialLoanApplication rlaRecord : newRlaRecords) {
      if (
        (RecordComparisonUtil.fieldWasChanged(
          rlaRecord,
          oldRlaRecords.get(rlaRecord.Id),
          ResidentialLoanApplication.Status
        )) && (rlaRecord.Status == BOHConstants.RLA_CANCELLED_STATUS)
      ) {
        rlaRecordIds.add(rlaRecord.Id);

        String postContent = ResidentialLoanApplicationHelper.postNotesToChatterWhenCancelled(
          oldRlaRecords.get(rlaRecord.Id).Status
        );

        ChatterUtils.makeAPost(
          rlaRecord.Id,
          postContent,
          ChatterUtils.POST_TYPE_RICH_TEXT
        );
      }
    }
    return rlaRecordIds;
  }
}
