/**
 * @author Ian Huang
 * @since  06/2025
 * @group Platform
 * @description Financial Account external query helper class
 */
public with sharing class FinancialAccountQueryHelper {
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';
  private static final FinancialAccountQueryBaseRepository FA_REPOSITORY = (FinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    FinancialAccountQueryBaseRepository.class
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

  /**
   * @description get legal entity customer Ids related to CLG
   * @param customerId CLG customer Id
   * @return Set<String> List of customer Ids
   */
  public static Set<String> getCLGRelatedCustomerIds(String customerId) {
    Set<String> result = new Set<String>();

    //check to see if customer is CLG
    List<Account> customers = FA_Repository.getCustomerUsingExternalIdAndRtName(
      customerId,
      'CLG'
    );
    if (customers.isEmpty()) {
      result.add(customerId);
      return result;
    }

    for (
      FinServ__AccountAccountRelation__c aar : FA_Repository.getCLGRelatedCustomers(
        customerId
      )
    ) {
      result.add(aar.FinServ__RelatedAccount__r.External_Id__c);
    }

    return result;
  }

  /**
   * @description Format Account Number
   * @param accountNumber Account Number
   * @return String formatted Account Number
   */
  public static String formatAccountNumber(String accountNumber) {
    if (String.isBlank(accountNumber)) {
      return '';
    }

    Map<Integer, List<Integer>> lengthFormat = new Map<Integer, List<Integer>>{
      9 => new List<Integer>{ 0, 4, 9 },
      11 => new List<Integer>{ 0, 4, 7, 11 },
      16 => new List<Integer>{ 0, 4, 8, 12, 16 }
    };

    if (accountNumber.length() < 9) {
      accountNumber = accountNumber.leftPad(9, '0');
    }

    if (!lengthFormat.containsKey(accountNumber.length())) {
      return accountNumber;
    }

    return joinAccountNumberParts(
      accountNumber,
      lengthFormat.get(accountNumber.length())
    );
  }

  /**
   * @description join subparts of the account number
   * @param accountNumber Account Number
   * @param formatter formatter
   * @return String account number
   */
  public static String joinAccountNumberParts(
    String accountNumber,
    List<Integer> formatter
  ) {
    List<String> parts = new List<String>();
    for (Integer i = 0; i < (formatter.size() - 1); i++) {
      parts.add(accountNumber.subString(formatter[i], formatter[i + 1]));
    }
    return String.join(parts, '-');
  }

  /**
   * @description get account account key
   * @param accountNumber Account Number
   * @param productCode Product Code
   * @param accountRoleMap FinancialAccountRole map
   * @return String Account_key__c
   */
  public static String getAccountKey(
    String accountNumber,
    String productCode,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      accountRoleMap.containsKey(accountNumber) &&
      accountRoleMap.get(accountNumber).FinServ__RelatedAccount__r != null
    ) {
      result = accountRoleMap.get(accountNumber)
        .FinServ__FinancialAccount__r.Account_Key__c;
    }
    result += '|' + productCode + '-' + accountNumber;
    return result;
  }

  /**
   * @description get account relationship
   * @param accountNumber Account Number
   * @param roleTypes role type map
   * @param accountRoleMap far map
   * @return Account relationship
   */
  public static String getAccountRelationship(
    String accountNumber,
    Map<String, String> roleTypes,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      accountRoleMap.containsKey(accountNumber) &&
      String.isNotEmpty(accountRoleMap.get(accountNumber).Role_Type__c)
    ) {
      result = roleTypes.get(accountRoleMap.get(accountNumber).Role_Type__c);
    }
    return result;
  }

  /**
   * @description get product code
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return product code
   */
  public static String getProductCode(
    String accountNumber,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      !accountRoleMap.containsKey(accountNumber) ||
      String.isEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.Product_Code_Display__c
      )
    ) {
      return result;
    }
    result = accountRoleMap.get(accountNumber)
      .FinServ__FinancialAccount__r.Product_Code_Display__c;
    return result;
  }

  /**
   * @description get product code
   * @param  finAccount Financial account record
   * @param useProductCodeFromFinancialAccount boolean flag
   * @param accountRoleMap FAR map
   * @return String External Id
   */
  public static String getProductCode(
    FinancialAccountModelBase finAccount,
    Boolean useProductCodeFromFinancialAccount,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    List<String> values = new List<String>();
    if (!useProductCodeFromFinancialAccount) {
      return finAccount.productCode;
    }
    if (
      accountRoleMap.containsKey(finAccount.accountNumber) &&
      String.isNotEmpty(
        accountRoleMap.get(finAccount.accountNumber)
          .FinServ__FinancialAccount__r.Product_Type__c
      )
    ) {
      values = accountRoleMap.get(finAccount.accountNumber)
        .FinServ__FinancialAccount__r.Product_Type__c.split(':');
    }
    return values.size() > 1 ? values[1] : '';
  }

  /**
   * @description get product name
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return product name
   */
  public static String getProductName(
    String accountNumber,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      !accountRoleMap.containsKey(accountNumber) ||
      String.isEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.Product_Name_Display__c
      )
    ) {
      return result;
    }
    result = accountRoleMap.get(accountNumber)
      .FinServ__FinancialAccount__r.Product_Name_Display__c;
    return result;
  }

  /**
   * @description get related customers of a particular account
   * @param accountKey Unique financial account key
   * @param roleTypes role types
   * @return List< FinServ_FinancialAccountRole__c>
   */
  public static List<FinServ__FinancialAccountRole__c> getRelatedCustomersOfAccount(
    String accountKey,
    Set<String> roleTypes
  ) {
    List<FinServ__FinancialAccountRole__c> relatedCustomers = new List<FinServ__FinancialAccountRole__c>();
    relatedCustomers = FA_Repository.getRelatedCustomers(accountKey, roleTypes);

    return relatedCustomers;
  }

  /**
   * @description get role type name
   * @param roleTypeCode role code
   * @return String role type name
   */
  public static String getRoleTypeNameByCode(String roleTypeCode) {
    return CommonUtil.getSinglePicklistLabel(
      FinServ__FinancialAccountRole__c.Role_Type__c,
      roleTypeCode
    );
  }
}
