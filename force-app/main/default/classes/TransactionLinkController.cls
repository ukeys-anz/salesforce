/**
 * @author Batya Aisman Sufrin
 * @since Aug 2025
 * @description Controller for managing transaction links
 */
public with sharing class TransactionLinkController {
  private static final TransactionLinkRepository TRANSACTION_LINK_REPO = (TransactionLinkRepository) Lib_InstanceProvider.forType(
    TransactionLinkRepository.class
  );

  private static final String MSG_ERROR_GENERIC = 'Error fetching financial accounts. Please contact your System Administrator.';

  /**
   * @description Fetch financial accounts for a given account ID
   * @param accId The ID of the account to fetch financial accounts for
   * @return A list of financial accounts associated with the given account ID
   */
  @AuraEnabled(cacheable=true)
  public static List<FinServ__FinancialAccountRole__c> getFinancialAccounts(
    Id accId
  ) {
    try {
      return TRANSACTION_LINK_REPO.queryANZxAccountRoles(accId);
    } catch (Exception e) {
      throw CommonUtil.logAuraExceptionInfo(MSG_ERROR_GENERIC, accId, e);
    }
  }
}
