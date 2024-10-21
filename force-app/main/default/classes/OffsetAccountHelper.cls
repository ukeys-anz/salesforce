/**
 * @author Pooja Kirtishahi
 * @since August 2024
 * @description Helper for HomeLoanController
 */
public with sharing class OffsetAccountHelper {
  /**
   * @param offsetAccounts the List of OffsetAccountModel.LoanOffsets
   * @return `List<String>` the List of financial account numbers
   * @description to get the list of financial account numbers from response
   */
  public static List<String> getFinAccNumberList(
    List<OffsetAccountModel.LoanOffsets> offsetAccounts
  ) {
    List<String> finAccNumber = new List<String>();
    for (OffsetAccountModel.LoanOffsets record : offsetAccounts) {
      finAccNumber.addAll(record.offset_accounts);
    }
    return finAccNumber;
  }

  /**
   * @param loanAccountWithOffsetList the List of loan offset
   * @param accNumberToFinAccountMap Map of Financial Account to Account Number
   * @return `List<OffsetAccountModel.LoanOffsets>`
   * @description to transform the response for UI
   */
  public static List<OffsetAccountModel.LoanOffsets> transformDataForUI(
    List<OffsetAccountModel.LoanOffsets> loanAccountWithOffsetList,
    Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap
  ) {
    // Loop through all the Loan Accounts
    for (
      OffsetAccountModel.LoanOffsets loanAccount : loanAccountWithOffsetList
    ) {
      loanAccount.offsetDetails = new List<OffsetAccountModel.OffsetWrapper>();

      // Loop through all the offsets linked to each loan account
      for (String offsetAccountNumber : loanAccount.offset_accounts) {
        OffsetAccountModel.OffsetWrapper offsetDetails = new OffsetAccountModel.OffsetWrapper();
        offsetDetails.financialAccountNumber = offsetAccountNumber;
        offsetDetails.financialAccountId = accNumberToFinAccountMap.get(
            offsetAccountNumber
          )
          ?.Id;
        loanAccount.offsetDetails.add(offsetDetails);
      }
    }
    return loanAccountWithOffsetList;
  }
}
