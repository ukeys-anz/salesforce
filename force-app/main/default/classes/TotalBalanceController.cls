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

    Set<String> marketingCodes = getMarketingCodes();

    List<FinServ__FinancialAccountRole__c> financialAccountAllRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllAccountNumberPerOwner(
      ownerId,
      marketingCodes
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
      marketingCodes
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

    Set<String> marketingCodes = getMarketingCodes();

    Id savingsRecordType = GetHelpConstants.SAVINGS_ACCOUNT_RT_ID;

    List<FinServ__FinancialAccountRole__c> financialAccountSavingsRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllSavingsAccountNumberPerOwner(
      ownerId,
      marketingCodes,
      savingsRecordType
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
      marketingCodes
    );

    return new FinancialSummaryWrapper(
      totalSavedBalance,
      new List<String>(savingsAccountProductNames)
    );
  }

  private static Set<String> getMarketingCodes() {
    List<FinancialAccountUIConfiguration__mdt> listOfFinAccConfig = FINANCIAL_ACCOUNT_REPOSITORY.fetchEligibleProductCodesForTotal();

    return new Set<String>(
      ListUtil.getStrings(
        listOfFinAccConfig,
        FinancialAccountUIConfiguration__mdt.Product_Code__c
      )
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
