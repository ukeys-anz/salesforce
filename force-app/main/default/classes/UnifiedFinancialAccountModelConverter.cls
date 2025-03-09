/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description Database financial account records are converted into UnifiedFinancialAccountModel format
 */
public with sharing class UnifiedFinancialAccountModelConverter {
  //Map of database ownership value  to fabric ownership
  private static final Map<String, String> FABRIC_OWNERSHIP = new Map<String, String>{
    'Multi-party' => 'OWNERSHIP_TYPE_MULTIPARTY', // its a joint account
    'Single' => 'OWNERSHIP_TYPE_SINGLEPARTY' // its an individual account
  };

  //Map of fabric ownership and user friendly names for UI
  private static final Map<String, String> FABRIC_OWNERSHIP_UI = new Map<String, String>{
    'Multi-party' => 'Joint',
    'Single' => 'Single'
  };

  private static final Integer DEFAULT_SORT_ORDER = 999;

  /**
   * @description convert the financial accounts from database to UnifiedFinancialAccountModel
   * @param finAccounts list of financial accounts from the database
   * @return  sorted , added metadata values into UnifiedFinancialAccountModel
   */
  public static List<UnifiedFinancialAccountModel.AccountList> convertToUnifiedFinancialAccountModel(
    List<FinServ__FinancialAccount__c> finAccounts
  ) {
    List<UnifiedFinancialAccountModel.AccountList> finAccountList = new List<UnifiedFinancialAccountModel.AccountList>();

    for (FinServ__FinancialAccount__c finAccount : finAccounts) {
      UnifiedFinancialAccountModel.AccountList finAccountDetail = new UnifiedFinancialAccountModel.AccountList();
      String finAccountKey =
        finAccount.Marketing_Code__c +
        '_' +
        FABRIC_OWNERSHIP_UI.get(finAccount.Ownership__c);
      FinancialAccountUIConfiguration__mdt finAccConfig = QueryFinancialAccountUIConfig.configByDeveloperName.get(
        finAccountKey
      );

      finAccountDetail.id = finAccount.Id;
      finAccountDetail.account_name = finAccount.Name;
      finAccountDetail.account_number = finAccount.FinServ__FinancialAccountNumber__c;
      finAccountDetail.finserv_status = finAccount.FinServ__Status__c;
      finAccountDetail.finserv_product_name = finAccount.FinServ__ProductName__c;
      finAccountDetail.finserv_opendate = finAccount.FinServ__OpenDate__c;
      finAccountDetail.finserv_closedate = finAccount.FinServ__CloseDate__c;
      finAccountDetail.finserv_ownership = finAccount.Ownership__c;
      finAccountDetail.balances = convertBalances(
        finAccount.FinServ__Balance__c,
        finAccount.FinServ__CurrentPostedBalance__c
      );
      finAccountDetail.product_details = convertProductDetails(
        finAccount.Marketing_Code__c
      );
      finAccountDetail.Ownership = convertOwnership(finAccount.Ownership__c);
      finAccountDetail.finserv_sortorder = finAccConfig?.Sort_Order__c ??
        DEFAULT_SORT_ORDER;
      finAccountDetail.finserv_showgoal = finAccConfig?.Show_Goals__c ?? true;

      finAccountList.add(finAccountDetail);
    }
    UnifiedFinancialAccountModel model = new UnifiedFinancialAccountModel(
      finAccountList
    );
    return model.accounts;
  }

  private static UnifiedFinancialAccountModel.Balances convertBalances(
    Decimal balance,
    Decimal currentBalance
  ) {
    UnifiedFinancialAccountModel.Balances finAccountBalances = new UnifiedFinancialAccountModel.Balances();
    finAccountBalances.balance = convertBalance(balance);
    finAccountBalances.current_balance = convertBalance(currentBalance);
    return finAccountBalances;
  }

  private static UnifiedFinancialAccountModel.Balance convertBalance(
    Decimal balanceValue
  ) {
    UnifiedFinancialAccountModel.Balance finAccountBalance = new UnifiedFinancialAccountModel.Balance();
    finAccountBalance.units = String.valueOf(balanceValue);
    finAccountBalance.nanos = 0;
    return finAccountBalance;
  }

  private static UnifiedFinancialAccountModel.ProductDetails convertProductDetails(
    String marketingCode
  ) {
    UnifiedFinancialAccountModel.ProductDetails finAccountProductDetails = new UnifiedFinancialAccountModel.ProductDetails();
    finAccountProductDetails.marketing_code = marketingCode;
    return finAccountProductDetails;
  }

  private static UnifiedFinancialAccountModel.Ownership convertOwnership(
    String ownership
  ) {
    UnifiedFinancialAccountModel.Ownership finAccountOwnership = new UnifiedFinancialAccountModel.Ownership();
    finAccountOwnership.type = FABRIC_OWNERSHIP.get(ownership);
    return finAccountOwnership;
  }
}
