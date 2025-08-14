/**
 * @author Ashish Kumar
 * @since 06/2025
 * @description class for Residential Loan Application actions
 * @runTests MobileLendingResidentialLoanApplicationTest
 */
public with sharing class MobileLendingResidentialLoanApplication {
  @TestVisible
  private static final Map<String, String> LOAN_APPLICATION_STATUSES = new Map<String, String>{
    'Unspecified' => 'Needs Analysis',
    'Capture ' => 'Needs Analysis',
    'Approved' => 'Assessed',
    'Declined' => 'Closed - Lost',
    'Referred' => 'Submitted',
    'Completed' => 'Closed - Won',
    'Cancelled' => 'Closed - Lost',
    'Expired' => 'Closed - Lost',
    'Submitted' => 'Submitted',
    'Confirmed' => 'Closed - Lost',
    'Ineligible' => 'Needs Analysis',
    'Settlement Initiated' => 'Documents'
  };

  @TestVisible
  private static final Map<String, String> CLOSED_LOST_STATUSES = new Map<String, String>{
    'Cancelled' => 'Application Withdrawn',
    'Expired ' => 'Not Proceeding',
    'Declined' => 'Declined by Credit'
  };

  private static final ResidentialLoanApplicationRepository RESIDENTIAL_LOAN_APP_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description To filter out the RLA records with with Broker and LanId populated and status is changed
   * @param records Residential Loan application records from trigger on update
   * @param oldMap Holds records information before update
   */
  public static void updateOpportunityFromRLA(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    List<ResidentialLoanApplication> filteredResidentialLoanApplication = ListUtil.filter(
        records,
        oldMap
      )
      .changed(ResidentialLoanApplication.status)
      .toList();
    updateOpportunity(filteredResidentialLoanApplication);
  }

  /**
   * @description To update ML Opportunity on RLA insertion/updation
   * @param records Residential Loan application records from trigger on update
   */
  @TestVisible
  private static void updateOpportunity(
    List<ResidentialLoanApplication> records
  ) {
    List<Opportunity> lstOfOppToUpdate = new List<Opportunity>();
    for (ResidentialLoanApplication eachRLA : records) {
      Opportunity oppToUpdate = new Opportunity();
      oppToUpdate.Id = eachRLA.OpportunityId;
      oppToUpdate.stageName = LOAN_APPLICATION_STATUSES.get(eachRLA.status);
      if (CLOSED_LOST_STATUSES.containsKey(eachRLA.Status)) {
        oppToUpdate.Lost_Reason__c = CLOSED_LOST_STATUSES.get(eachRLA.status);
      }
      lstOfOppToUpdate.add(oppToUpdate);
    }
    DML_REPOSITORY.doUpdate(lstOfOppToUpdate, new DmlConfig().allowPartial());
  }
  /**
   * @description To populate the Assisted Lender field on RLA if the Broker TPMI SAO and LanId is populated
   * @param records Residential Loan application records from trigger on update or insert
   * @param oldMap Holds records information before update or insert
   */
  public static void populateRetailLoanAssistedLender(
    List<ResidentialLoanApplication> records,
    Map<Id, ResidentialLoanApplication> oldMap
  ) {
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      ResidentialLoanApplication.Assisted_Broker_TPMI_SAO__c,
      ResidentialLoanApplication.LANID__c
    };
    List<ResidentialLoanApplication> filteredRecords = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(fieldsToValidateChange)
      .toList();
    Set<String> lanIdSet = ListUtil.getStrings(
      filteredRecords,
      ResidentialLoanApplication.LANID__c
    );
    List<User> assistedBrokers = RESIDENTIAL_LOAN_APP_REPOSITORY.getAssistedLendersByLanId(
      lanIdSet
    );
    if (assistedBrokers.isEmpty()) {
      return;
    }
    Map<String, User> userLanIdMap = (Map<String, User>) ListUtil.mapBy(
      assistedBrokers,
      User.Lan_Id__c
    );
    for (ResidentialLoanApplication rla : filteredRecords) {
      rla.Assisted_Lender__c = userLanIdMap?.get(rla.LANID__c).Id;
    }
  }
}
