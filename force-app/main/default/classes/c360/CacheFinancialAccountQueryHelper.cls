/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description Cache Financial Account external query helper class
 */
public with sharing class CacheFinancialAccountQueryHelper {
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';
  private static final CacheFinancialAccountQueryBaseRepository FA_REPOSITORY = (CacheFinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    CacheFinancialAccountQueryBaseRepository.class
  );
  /**
   * @description Retrieves list of financial accounts related to a customer via
   *                        financial account role relationship (FAR)
   * @param customerIds the customer external Ids
   * @param productTypes product type set
   * @param roleTypes roleType map
   * @return List<FinServ__FinancialAccountRole__c>
   */
  public static List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountsByCustomerId(
    Set<String> customerIds,
    Set<String> productTypes,
    Map<String, String> roleTypes
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = new List<FinServ__FinancialAccountRole__c>();
    if (customerIds.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    faRoles = FA_REPOSITORY.getFinancialAccountsWithCustomerId(
      customerIds,
      ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME,
      productTypes,
      roleTypes
    );

    return faRoles;
  }

  /**
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param externalId Financial account external id
   * @return List<FinServ__FinancialAccountRole__c>
   */
  public static List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountByAccountNumber(
    String externalId
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = new List<FinServ__FinancialAccountRole__c>();

    String accountKey = externalId.contains('|')
      ? externalId.left(externalId.indexOf('|'))
      : '';
    if (String.isBlank(accountKey)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    faRoles = FA_REPOSITORY.getFinancialAccountsWithAcctNum(accountKey);

    return faRoles;
  }
}
