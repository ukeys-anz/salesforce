/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceController is the apex side controller for the totalBalance LWC
 */
public with sharing class TotalBalanceController {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static FinancialSummaryWrapper getTotalBalance(Id ownerId) {
    if (!USER_INFO.checkCustomPermission('ANZx_Accounts_and_Goals')) {
      return null;
    }

    List<FinancialAccountUIConfiguration__mdt> finAccUIConfig = ListUtil.filter(
        QueryFinancialAccountUIConfig.configByProductCode.values()
      )
      .equals(
        FinancialAccountUIConfiguration__mdt.Include_In_Total_Financial_Position__c,
        true
      )
      .toList();

    Set<String> productCodes = ListUtil.getStrings(
      finAccUIConfig,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );

    List<FinServ__FinancialAccountRole__c> financialAccountAllRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllAccountNumberPerOwner(
      ownerId,
      productCodes
    );

    Set<String> allAccountNumbers = ListUtil.getStrings(
      financialAccountAllRoles,
      FinServ__FinancialAccountRole__c.Account_Number__c
    );

    Set<String> allAccountsProductNames = ListUtil.getStrings(
      financialAccountAllRoles,
      FinServ__FinancialAccountRole__c.Product_Name_Display__c
    );

    AggregateResult totalBalance = FINANCIAL_ACCOUNT_REPOSITORY.getTotalBalance(
      allAccountNumbers,
      productCodes
    );

    return new FinancialSummaryWrapper(
      totalBalance,
      new List<String>(allAccountsProductNames)
    );
  }

  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static FinancialSummaryWrapper getTotalSaved(Id ownerId) {
    if (!USER_INFO.checkCustomPermission('ANZx_Accounts_and_Goals')) {
      return null;
    }

    List<FinancialAccountUIConfiguration__mdt> finAccUIConfig = ListUtil.filter(
        QueryFinancialAccountUIConfig.configByProductCode.values()
      )
      .equals(
        FinancialAccountUIConfiguration__mdt.Include_In_Total_Financial_Position__c,
        true
      )
      .toList();

    Set<String> productCodes = ListUtil.getStrings(
      finAccUIConfig,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );

    List<FinServ__FinancialAccountRole__c> financialAccountSavingsRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllSavingsAccountNumberPerOwner(
      ownerId,
      productCodes
    );

    Set<String> savingAccountNumbers = ListUtil.getStrings(
      financialAccountSavingsRoles,
      FinServ__FinancialAccountRole__c.Account_Number__c
    );

    Set<String> savingsAccountProductNames = ListUtil.getStrings(
      financialAccountSavingsRoles,
      FinServ__FinancialAccountRole__c.Product_Name_Display__c
    );

    AggregateResult totalSavedBalance = FINANCIAL_ACCOUNT_REPOSITORY.getTotalBalance(
      savingAccountNumbers,
      productCodes
    );

    return new FinancialSummaryWrapper(
      totalSavedBalance,
      new List<String>(savingsAccountProductNames)
    );
  }

  /**
   * @description FinancialSummaryWrapper for Financial Summary data
   */
  public class FinancialSummaryWrapper {
    @AuraEnabled
    public AggregateResult aggregateResult;
    @AuraEnabled
    public List<String> productNames;
    /**
     * @description FinancialSummaryWrapper constructor for Financial Summary data
     * @param aggregateResult
     * @param productNames
     */
    public FinancialSummaryWrapper(
      AggregateResult aggregateResult,
      List<String> productNames
    ) {
      this.aggregateResult = aggregateResult;
      this.productNames = productNames;
    }
  }
}
