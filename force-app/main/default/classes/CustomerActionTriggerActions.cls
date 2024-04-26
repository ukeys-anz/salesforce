/**
 * @author Peter Charalambous
 * @since Tue Mar 19 2024
 * @description class for customer action trigger actions
 */
public with sharing class CustomerActionTriggerActions {
  /**
   * @description Find and populate the fields with customer name via ocv id
   * @param records records to populate with customer name
   */
  public static void populateCustomerName(List<Customer_Action__c> records) {
    List<String> filteredRlaRecords = filterRlaRecords(records);
    updateLoanApplicant(records, filteredRlaRecords);
  }

  /**
   * @description Filter records to retrieve the RLA list to query for
   * @param records records to filter
   * @return List<String>
   */
  private static List<String> filterRlaRecords(
    List<Customer_Action__c> records
  ) {
    List<String> rlaIdList = new List<String>();
    for (Customer_Action__c customerAction : records) {
      rlaIdList.add(customerAction.Loan_Application_Id__c);
    }
    return rlaIdList;
  }

  /**
   * @description Update the loan applicant
   * @param records records to populate with customer name
   * @param rlaIdList RLA id list to query for
   */
  private static void updateLoanApplicant(
    List<Customer_Action__c> records,
    List<String> rlaIdList
  ) {
    for (LoanApplicant applicant : [
      SELECT Id, Account__r.OCV_ID__c, LoanApplicationId
      FROM LoanApplicant
      WHERE LoanApplicationId IN :rlaIdList
    ]) {
      //Loop through records and update the values to be the name provided from the loan applicant
      for (Customer_Action__c customerAction : records) {
        //Ensure the Loan Applications are the same as an applicant can be linked to multiple loan apps
        if (
          applicant.LoanApplicationId ==
          customerAction.Loan_Application_Id__c &&
          (applicant.Account__r.OCV_ID__c == customerAction.Accepted_By__c ||
          applicant.Account__r.OCV_ID__c == customerAction.Completed_By__c)
        ) {
          customerAction.Loan_Applicant__c = applicant.Id;
        }
      }
    }
  }
}
