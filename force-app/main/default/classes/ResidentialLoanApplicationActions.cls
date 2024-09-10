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
}
