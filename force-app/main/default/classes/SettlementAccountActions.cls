/**
 * @author Peter Charalambous
 * @since Tue Apr 16 2024
 * @description class for Settlement Account actions
 */
public with sharing class SettlementAccountActions {
  private static final ResidentialLoanApplicationRepository RESIDENTIAL_LOAN_APP_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  /**
   * @description Find and populate the fields with customer name via ocv id
   * @param records records to populate with customer name
   */
  public static void populateCustomerName(List<Settlement_Account__c> records) {
    List<String> filteredRlaRecords = filterRlaRecords(records);
    updateNominatedBy(records, filteredRlaRecords);
  }

  /**
   * @description Filter records to retrieve the RLA list to query for
   * @param records records to filter
   * @return List<String>
   */
  private static List<String> filterRlaRecords(
    List<Settlement_Account__c> records
  ) {
    List<String> rlaIdList = new List<String>();
    for (Settlement_Account__c settlementAccount : records) {
      rlaIdList.add(settlementAccount.Loan_Application_Id__c);
    }
    return rlaIdList;
  }

  /**
   * @description Update the verified by with customer account name
   * @param records records to populate with customer name
   * @param rlaIdList RLA id list to query for
   */
  private static void updateNominatedBy(
    List<Settlement_Account__c> records,
    List<String> rlaIdList
  ) {
    for (LoanApplicant applicant : [
      SELECT Id, Account__r.OCV_ID__c, LoanApplicationId
      FROM LoanApplicant
      WHERE LoanApplicationId IN :rlaIdList
    ]) {
      //Loop through records and update the values to be the name provided from the loan applicant
      for (Settlement_Account__c settlementAccount : records) {
        //Ensure the Loan Applications are the same as an applicant can be linked to multiple loan apps
        if (
          applicant.LoanApplicationId ==
          settlementAccount.Loan_Application_Id__c &&
          applicant.Account__r.OCV_ID__c == settlementAccount.Nominated_By_Id__c
        ) {
          settlementAccount.Nominated_By__c = applicant.Id;
        }
      }
    }
  }
  /**
   * @description  filter the loanappIds from settlement account
   * @param records settlement account records for filtering
   * @return List<loanapplicationIds>
   */
  @Testvisible
  private static List<Id> getLoanApplicationIdFromSettlementAccounts(
    List<Settlement_Account__c> records
  ) {
    List<Id> loanApplicationIds = new List<Id>();
    for (Settlement_Account__c settleAcc : records) {
      if (settleAcc.IsValidCloudEvent__c == true) {
        loanApplicationIds.add(settleAcc.Loan_Application_Id__c);
      }
    }
    return loanApplicationIds;
  }
  /**
   * @description on settlement account update/insert publish application event to migrate data to broker org.
   * @param records records to publish the application event
   * @param cloudEventType  add or update event
   */
  public static void publishSettlementAccountCloudEvents(
    List<Settlement_Account__c> records,
    String cloudEventType
  ) {
    List<Id> loanApplicationIds = getLoanApplicationIdFromSettlementAccounts(
      records
    );
    List<ResidentialLoanApplication> rlaList = RESIDENTIAL_LOAN_APP_REPOSITORY.queryLoanApplicatioins(
      loanApplicationIds
    );
    ResidentialLoanApplicationActions.publishSyncEvents(
      rlaList,
      cloudEventType
    );
  }
}
