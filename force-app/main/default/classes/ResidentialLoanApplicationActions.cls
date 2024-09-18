/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description class for Residential Loan Application actions
 * @runTests ResidentialLoanAppActionsTest
 */
public with sharing class ResidentialLoanApplicationActions {
  private static final String HOME_LOAN_APP_DEV_NAME = 'Home_Loan_Applications_Queue';
  @TestVisible
  private static final String ACCREDITATION_RETAIL = 'Retail';
  private static final ResidentialLoanApplicationRepository RLA_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description get Home Loan Applications Queue
   * @return Group homeLoanAppQueue
   */
  public static Group homeLoanAppQueue {
    get {
      if (homeLoanAppQueue != null) {
        return homeLoanAppQueue;
      }
      homeLoanAppQueue = QueryQueue.get(HOME_LOAN_APP_DEV_NAME);
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
   * @description update Status field on Case to cancel if related RLA has cancelled status
   * @param newRlaRecords  Residential Loan application records from trigger on insert/update
   * @param  oldRlaRecords  Holds records information before update
   */
  public static void cancelRelatedCreditReferralCases(
    Map<Id, ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    try {
      Set<Id> rlaRecordIds = filterRlaAndReturnCancelledStatusRecords(
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

      DML_REPOSITORY.doUpdate(
        caseRecordsToBeUpdated,
        new DmlConfig().systemMode()
      );
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
    if (masterCaseList.isEmpty()) {
      return new List<Case>();
    }
    List<Case> caseRecordsToBeUpdated = new List<Case>();
    for (Case caseRecord : masterCaseList) {
      if (
        newRlaRecords.get(caseRecord.Loan_Application__c)
          .Cancellation_Reason__c ==
        GetHelpConstants.RLA_CANCELLATION_REASON_CREDIT_ASSESMENT_EXPIRED
      ) {
        caseRecord.Status = GetHelpConstants.CLOSED_EXPIRED_STATUS;
      } else {
        caseRecord.Status = GetHelpConstants.CLOSED_CANCELLED_STATUS;
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
  public static Set<Id> filterRlaAndReturnCancelledStatusRecords(
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
        )) && (rlaRecord.Status == GetHelpConstants.RLA_STATUS_CANCELLED)
      ) {
        rlaRecordIds.add(rlaRecord.Id);
      }
    }
    return rlaRecordIds;
  }
}
