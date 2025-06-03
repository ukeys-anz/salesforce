/**
 * @authur CMOS
 * @since March 2025
 * @description Provide All FinancialAccount Records releated to Customer
*/
 
public with sharing class GetCustomerInformation {
    private static final GetCustomerInformationRepo CUSTOMER_REPOSITORY = (GetCustomerInformationRepo) Lib_InstanceProvider.forType(
    GetCustomerInformationRepo.class);
    /**
   * @description To Get Financial Accounts Releated to the Customer
   * @param accId ID of the Customer
   * @param ocvId ocvId of the Customer
   * @return list<FinServ__FinancialAccount__c> return the list of Financial Accounts
   */
    @AuraEnabled(cacheable= true)
    public static List<FinServ__FinancialAccount__c> fetchCustomerFinancialAccounts(Id accId,String ocvId) {               
        return CUSTOMER_REPOSITORY.getFinancialAccounts( accId, ocvId);   
              
    }

}