/**
 * @description View Model for Loan Account Changes
 * @author Pooja Kirtishahi
 * @since Mar 2025
 */
public with sharing class LoanAccountChangesViewModel {
  /**
   * @description accountHistoryList
   */
  @AuraEnabled
  public List<AccountHistory> accountHistoryList { get; set; }

  /**
   * @description AccountHistory details
   */
  public class AccountHistory {
    /**
     * @description updatedTime
     */
    @AuraEnabled
    public DateTime updatedTime { get; set; }

    /**
     * @description changeRequest
     */
    @AuraEnabled
    public String changeRequest { get; set; }

    /**
     * @description user name
     */
    @AuraEnabled
    public String user { get; set; }

    /**
     * @description userId
     */
    @AuraEnabled
    public String userId { get; set; }

    /**
     * @description caseId
     */
    @AuraEnabled
    public String caseId { get; set; }

    /**
     * @description caseNumber
     */
    @AuraEnabled
    public String caseNumber { get; set; }

    /**
     * @description field
     */
    @AuraEnabled
    public String field { get; set; }

    /**
     * @description newValue
     */
    @AuraEnabled
    public String newValue { get; set; }
  }

  /**
   * @description LoanAccountChangesViewModel constructor
   */
  public LoanAccountChangesViewModel() {
  }

  /**
   * @description LoanAccountChangesViewModel with params
   * @param approvedChanges
   * @param caseMap
   */
  public LoanAccountChangesViewModel(
    List<LoanAccountChangesModel.LoanAccountChange> approvedChanges,
    Map<String, Case> caseMap
  ) {
    this.accountHistoryList = new List<AccountHistory>();
    for (LoanAccountChangesModel.LoanAccountChange change : approvedChanges) {
      Case caseItem = caseMap.get(change.name);
      if (caseItem != null) {
        AccountHistory accountHistory = new AccountHistory();
        accountHistory.updatedTime = change.approval.updatedTime;
        accountHistory.changeRequest = caseItem.Sub_Type__c;
        accountHistory.user = caseItem.Verified_By__r.name;
        accountHistory.userId = caseItem.Verified_By__c;
        accountHistory.field = change.updateMask;
        accountHistory.caseId = caseItem.Id;
        accountHistory.caseNumber = caseItem.caseNumber;
        accountHistory.newValue = change.response.productType;
        this.accountHistoryList.add(accountHistory);
      }
    }
  }
}
