/**
 * @authur CMOS
 * @since March 2025
 * @description Provide All FinancialAccount Records releated to Customer
 */

public with sharing class GetCustomerInformation {
  private static final GetCustomerInformationRepo CUSTOMER_REPOSITORY = (GetCustomerInformationRepo) Lib_InstanceProvider.forType(
    GetCustomerInformationRepo.class
  );
  @testVisible
  private static final set<String> ROLE_TYPES = new Set<String>{
    'SOL',
    'COO',
    'COF',
    'GTR',
    'PCC',
    'TSF',
    'TSO'
  };
  /**
   * @description To Get Financial Accounts Releated to the Customer
   * @param accId ID of the Customer
   * @param ocvId ocvId of the Customer
   * @return list<FinServ__FinancialAccountRole__c> return the list of Financial Accounts Roles
   */
  @AuraEnabled(cacheable=true)
  public static List<FinServ__FinancialAccountRole__c> fetchCustomerFinancialAccounts(
    Id accId,
    String ocvId
  ) {
    return CUSTOMER_REPOSITORY.getFinancialAccounts(accId, ocvId, ROLE_TYPES);
  }
}
