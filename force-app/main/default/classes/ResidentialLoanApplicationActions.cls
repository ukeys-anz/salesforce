/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description class for Residential Loan Application actions
 * @runTests ResidentialLoanAppActionsTest
 */
public with sharing class ResidentialLoanApplicationActions {
  private static final String HOME_LOAN_APP_DEV_NAME = 'Home_Loan_Applications_Queue';
  private static final String QUEUE_TYPE = 'Queue';
  @TestVisible
  private static final String ACCREDITATION_RETAIL = 'Retail';
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';
  private static final ResidentialLoanApplicationRepository RESIDENTIAL_LOAN_APP_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  @TestVisible
  private static BrokerSettings__c mockBrokerSettings;

  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */
  @TestVisible
  private static BrokerSettings__c brokerSettings() {
    if (mockBrokerSettings != null) {
      return mockBrokerSettings;
    }
    return BrokerSettings__c.getOrgDefaults();
  }

  /**
   * @description get Home Loan Applications Queue
   * @return Group homeLoanAppQueue
   */
  public static Group homeLoanAppQueue {
    get {
      if (homeLoanAppQueue != null) {
        return homeLoanAppQueue;
      }
      homeLoanAppQueue = [
        SELECT Id
        FROM Group
        WHERE developername = :HOME_LOAN_APP_DEV_NAME AND Type = :QUEUE_TYPE
      ];
      return homeLoanAppQueue;
    }
    private set;
  }

  /**
   * @description Assign Home Loan Applications Queue as owner
   * @param rlaRecords records to assign owner
   */
  public static void assignHomeLoanAppQueue(
    List<ResidentialLoanApplication> rlaRecords
  ) {
    for (ResidentialLoanApplication rla : rlaRecords) {
      if (rla.RecordTypeId == GetHelpConstants.LOAN_APPLICATION_RT_ID) {
        rla.OwnerId = homeLoanAppQueue.Id;
      }
    }
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
    List<Broker_Code__c> brokerCodes = getBrokerCodesByTPMISAO(
      extIdToBrokerIdMap.values()
    );
    Map<String, Id> brokerCodeToContactMap = new Map<String, Id>();
    for (Broker_Code__c brokerCode : brokerCodes) {
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
   * @description Syncs the process of creating cloud event model from loan app records and publishing the GCP events
   * @author Deepro De | 06-04-2024
   * @param records
   * @param triggerContext
   * @return List<SObject> published events
   **/
  public static List<Cloud_Event__e> synchronizeAndPublishCloudEvents(
    List<ResidentialLoanApplication> records,
    String triggerContext
  ) {
    //Checking Broker Settings Custom Setting if cloud event publish has to be bypassed
    if (brokerSettings().BypassApplicationSyncEvents__c == true) {
      return null;
    }
    //Creating map of records vs event type according to trigger context type, ie. insert/update
    List<Id> filteredLoanAppList = filterLoanAppsBasedOnSyncStatus(records);

    //Fetch the RLA records and the related parent record details
    List<ResidentialLoanApplication> rlaRecordList = RESIDENTIAL_LOAN_APP_REPOSITORY.queryMultipleLoanApplications(
      filteredLoanAppList
    );

    //Creating cloud event model from records vs event type map in order to pass into publish method
    List<BrokerCloudEventModel> cloudEventModels = ResidentialLoanApplicationGCPActions.createCloudEventModels(
      rlaRecordList,
      triggerContext
    );

    //Passing cloud event into publish method
    List<Cloud_Event__e> cloudEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    ResidentialLoanApplicationGCPActions.logSuccessEvents(cloudEvents);
    return cloudEvents;
  }

  @TestVisible
  private static List<Broker_Code__c> mockBrokerCodes = new List<Broker_Code__c>();

  /**
   * @description get Broker Codes by TPMI SAO
   * @param brokerIdentifiers concatenated broker identifiers + accreditation type
   * @return List<Broker_Code__c> broker codes
   */
  @TestVisible
  private static List<Broker_Code__c> getBrokerCodesByTPMISAO(
    List<String> brokerIdentifiers
  ) {
    if (mockBrokerCodes.isEmpty() == false) {
      return mockBrokerCodes;
    }
    if (brokerIdentifiers.isEmpty() == true) {
      return new List<Broker_Code__c>();
    }
    return [
      SELECT Id, External_Id__c, Broker_Name__c
      FROM Broker_Code__c
      WHERE External_Id__c IN :brokerIdentifiers
    ];
  }

  /**
   * @description Creates a map between the loan application and the type of event ie. add/update
   * @author Deepro De | 06-05-2024
   * @param records
   * @return List<Id>
   **/
  public static List<Id> filterLoanAppsBasedOnSyncStatus(
    List<ResidentialLoanApplication> records
  ) {
    List<Id> filteredRecords = new List<Id>();
    for (ResidentialLoanApplication record : records) {
      if (
        String.isNotBlank(record.Sync_Status__c) &&
        !record.Sync_Status__c.contains(SYNC_STATUS_BLOCKED)
      ) {
        filteredRecords.add(record.Id);
      }
    }
    return filteredRecords;
  }

  /**
   * @description Evaluates if Broker Code is present or not, and populates Sync Status
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param records
   **/
  public static void processTPMIBasedSyncStatus(
    List<ResidentialLoanApplication> records
  ) {
    //filtering out the applications which have the sync status as blocked
    List<ResidentialLoanApplication> filteredList = filterOutBlockedApplications(
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

  /**
   * @description Evaluates and filters out the applications which have Blocked Sync Status
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param records
   * @return List<ResidentialLoanApplication> filtered list
   **/
  public static List<ResidentialLoanApplication> filterOutBlockedApplications(
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
}
