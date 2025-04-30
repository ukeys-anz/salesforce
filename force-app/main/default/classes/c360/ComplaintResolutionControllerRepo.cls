/**
 * @since 04/2025
 * @description This class provides SOQL helpers for class related ComplaintResolutionController.
 * @runTests ComplaintResolutionControllerTest
 */
public class ComplaintResolutionControllerRepo {
    /**
     * @description REPO to Fetch Complaint Resolution records linked to Cases for a specific Customer Account
     * @param accountId ID of the Customer
     * @return List<Case> return the list of Cases and it's associated Complaint Resoltuion records (if any)
     */
     public list<Case> getCustomerCases(String accountId) {
        if (String.isBlank(accountId)) {
          return new List<Case>();
        }
        return [
          SELECT
            Id,
            Owner.Name,
            CaseNumber,
            IDR_Date_Received__c,
            toLabel(IDR_Complaint_Outcome__c),
            Status,
            toLabel(Type),
            toLabel(IDR_Subsequent_Issue__c),
            IDR_Total_Financial_Amount__c,
            (
              SELECT Id, Name, toLabel(IDR_Complaint_Remedy__c)
              FROM Complaint_Resolutions__r
              ORDER BY Name ASC
              LIMIT 1
            )
          FROM Case
          WHERE AccountId = :accountId
          WITH USER_MODE
          ORDER BY CreatedDate DESC
        ];
      }
    
}