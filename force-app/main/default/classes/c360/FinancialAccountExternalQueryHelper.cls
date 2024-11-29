/**
 * @author Hitesh Wasdani
 * @since  09/2024
 * @group Platform
 * @description Financial Account external query base class
 * @runTests DepositAccountExternalQueryTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessivePublicCount')
public with sharing class FinancialAccountExternalQueryHelper {
  private static final String ML_USER_PROFILE_NAME = 'ANZ ML Standard User';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final FinancialAccountQueryBaseRepository FA_REPOSITORY = (FinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    FinancialAccountQueryBaseRepository.class
  );
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';

  /**
   * @description get industry code and discription
   * @param  industryCode
   * @return String industryCode plus discription
   */
  public String retrieveIndustryCodeAndDescription(String industryCode) {
    if (String.isBlank(industryCode) || industryCode == '0000') {
      return '';
    }
    Industry__c industry = FA_Repository.getIndustryCodeAndDescription(
      industryCode
    );
    return industry == null
      ? industryCode
      : industry.Code__c + ' - ' + industry.Name;
  }

  /**
   * @description get related customers of a particular account
   * @param accountKey Unique financial account key
   * @param roleTypes role types
   * @return List< FinServ_FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> getRelatedCustomersOfAccount(
    String accountKey,
    Set<String> roleTypes
  ) {
    List<FinServ__FinancialAccountRole__c> relatedCustomers = new List<FinServ__FinancialAccountRole__c>();
    if (PermissionUtils.canQuery('FinServ__FinancialAccount__c')) {
      relatedCustomers = FA_Repository.getRelatedCustomers(
        accountKey,
        roleTypes
      );
    }
    return relatedCustomers;
  }

  /**
   * @description parse account number from external Id
   * @param  externalId
   * @return String account number
   */
  public String getAccountNumber(String externalId) {
    String accountNumber = externalId.substringBefore('|');
    accountNumber = accountNumber.substringAfter('-');
    return accountNumber;
  }

  /**
   * @description get product code
   * @param  finAccount Financial account record
   * @param useProductCodeFromFinancialAccount boolean flag
   * @param accountRoleMap FAR map
   * @return String External Id
   */
  public String getProductCode(
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
   * @description Format Account Number for Account Numbers of Linked Accounts for PTF
   * @param accountNumber Account Number
   * @param productCode Product Code
   * @return String formatted Account Number
   */
  public String formatAccountNumber(String accountNumber, String productCode) {
    if (String.isBlank(accountNumber)) {
      return '';
    }

    Map<Integer, List<Integer>> lengthFormat = new Map<Integer, List<Integer>>{
      7 => new List<Integer>{ 0, 2, 5, 7 },
      9 => new List<Integer>{ 0, 3, 6, 9 }
    };

    Set<String> accountNumberBasedOnProductCodeSet = new Set<String>{
      'APP',
      'MOS',
      'SVC'
    };

    if (!accountNumberBasedOnProductCodeSet.contains(productCode)) {
      return formatAccountNumber(accountNumber);
    }

    if (
      (productCode == 'APP' || productCode == 'MOS') &&
      accountNumber.length() < 9
    ) {
      accountNumber = accountNumber.leftPad(9, '0');
    }

    if (productCode == 'SVC' && accountNumber.length() < 7) {
      accountNumber = accountNumber.leftPad(7, '0');
    }

    return joinAccountNumberParts(
      accountNumber,
      lengthFormat.get(accountNumber.length())
    );
  }

  /**
   * @description Format Account Number
   * @param accountNumber Account Number
   * @return String formatted Account Number
   */
  public String formatAccountNumber(String accountNumber) {
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
  public String joinAccountNumberParts(
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
   * @description get legal entity customer Ids related to CLG
   * @param customerId CLG customer Id
   * @return Set<String> List of customer Ids
   */
  public Set<String> getCLGRelatedCustomerIds(String customerId) {
    Set<String> result = new Set<String>();
    if (PermissionUtils.canQuery('Account')) {
      //check to see if customer is CLG
      List<Account> customers = FA_Repository.getCustomerUsingExternalIdAndRtName(
        customerId,
        'CLG'
      );
      if (customers.isEmpty()) {
        result.add(customerId);
        return result;
      }
    }
    if (PermissionUtils.canQuery('FinServ__AccountAccountRelation__c')) {
      for (
        FinServ__AccountAccountRelation__c aar : FA_Repository.getCustomerAAR(
          customerId
        )
      ) {
        result.add(aar.FinServ__RelatedAccount__r.External_Id__c);
      }
    }
    return result;
  }

  /**
   * @description checks isQueryEBDChildAccounts
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return boolean
   */
  public Boolean isQueryEBDChildAccounts(FAQueryBaseInfoWrapper infoWrapper) {
    return String.isNotEmpty(infoWrapper.parentId) &&
      infoWrapper.parentField != 'CustomerId' &&
      infoWrapper.sourceSystem ==
      FinancialAccountQueryBase.SourceSystemEnum.EBD;
  }

  /**
   * @description checks isQueryGuaranteeFeeSummaryAccounts
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return boolean
   */
  public Boolean isQueryGuaranteeFeeSummaryAccounts(
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    return String.isNotEmpty(infoWrapper.parentId) &&
      infoWrapper.parentField != 'CustomerId' &&
      (infoWrapper.parentField == 'ActiveGuaranteeId' ||
      infoWrapper.parentField == 'InactiveGuaranteeId') &&
      infoWrapper.sourceSystem ==
      FinancialAccountQueryBase.SourceSystemEnum.EBD;
  }

  /**
   * @description checks isQueryEBDChildAccountsWithAssetFinanceType
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return boolean
   */
  public Boolean isQueryEBDChildAccountsWithAssetFinanceType(
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    return String.isNotEmpty(infoWrapper.parentId) &&
      infoWrapper.parentField != 'CustomerId' &&
      infoWrapper.sourceSystem ==
      FinancialAccountQueryBase.SourceSystemEnum.EBD &&
      String.isNotBlank(infoWrapper.assetFinanceType);
  }

  /**
   * @description checks isQueryCAPChildAccountsWithAssetFinanceType
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return boolean
   */
  public Boolean isQueryCAPChildAccountsWithAssetFinanceType(
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    return String.isNotEmpty(infoWrapper.parentId) &&
      infoWrapper.parentField != 'CustomerId' &&
      infoWrapper.sourceSystem ==
      FinancialAccountQueryBase.SourceSystemEnum.CAP &&
      String.isNotBlank(infoWrapper.assetFinanceType);
  }

  /**
   * @description checks isQueryCAPChildAccounts
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return boolean
   */
  public Boolean isQueryCAPChildAccounts(FAQueryBaseInfoWrapper infoWrapper) {
    return String.isNotEmpty(infoWrapper.parentId) &&
      infoWrapper.parentField != 'CustomerId' &&
      infoWrapper.sourceSystem ==
      FinancialAccountQueryBase.SourceSystemEnum.CAP &&
      String.isBlank(infoWrapper.assetFinanceType);
  }

  /**
   * @description prepare payload for EDB Chaid Accounts
   * @param  payload string
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForEBDChildAccounts(
    String payload,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //EBD accounts child summary view
    if (isQueryEBDChildAccounts(infoWrapper)) {
      payload = String.isNotBlank(infoWrapper.assetFinanceType)
        ? '{"compositeContractNumber": "' +
          infoWrapper.parentId +
          '" ,"type":"' +
          infoWrapper.assetFinanceType +
          '"'
        : '{"compositeAccountNumber": "' + infoWrapper.parentId + '"';

      payload += String.isNotBlank(infoWrapper.fieldSet)
        ? ',"fieldSet": "' + infoWrapper.fieldSet + '"}'
        : '"}';
    }
    return payload;
  }

  /**
   * @description prepare payload for GuranteeFeeSummary Accounts
   * @param  payload string
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForGuaranteeFeeSummaryAccounts(
    String payload,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Guarantee Fee Summary
    if (isQueryGuaranteeFeeSummaryAccounts(infoWrapper)) {
      payload = '{"compositeGuaranteesId": "' + infoWrapper.parentId + '"';
      payload += String.isNotBlank(infoWrapper.fieldSet)
        ? ',"fieldSet": "' + infoWrapper.fieldSet + '"}'
        : '}';
    }
    return payload;
  }

  /**
   * @description prepare payload for EDBChil Account of AssetFinance
   * @param  payload string
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForEBDChildAccountsWithAssetFinanceType(
    String payload,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //child EBD accounts summary view having EBD as parent
    if (isQueryEBDChildAccountsWithAssetFinanceType(infoWrapper)) {
      payload = '{"compositeContractNumber": "' + infoWrapper.parentId + '"';
      payload += String.isNotBlank(infoWrapper.fieldSet) &&
        String.isNotBlank(infoWrapper.assetFinanceType)
        ? ',"fieldSet": "' +
          infoWrapper.fieldSet +
          '"' +
          ',"type":"' +
          infoWrapper.assetFinanceType +
          '"}'
        : String.isNotBlank(infoWrapper.fieldSet)
            ? ',"fieldSet": "' + infoWrapper.fieldSet + '"}'
            : null;
    }
    return payload;
  }

  /**
   * @description prepare payload for CAPChild Asset Accounts
   * @param  payload string
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForCAPChildAccountsWithAssetFinanceType(
    String payload,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Child accounts summary having EBD as parent
    if (isQueryCAPChildAccountsWithAssetFinanceType(infoWrapper)) {
      payload = '{"compositeAccountNumber": "' + infoWrapper.parentId + '"';
      payload += String.isNotBlank(infoWrapper.fieldSet) &&
        String.isNotBlank(infoWrapper.assetFinanceType)
        ? ',"fieldSet": "' +
          infoWrapper.fieldSet +
          '"' +
          ',"type":"' +
          infoWrapper.assetFinanceType +
          '"}'
        : String.isNotBlank(infoWrapper.fieldSet)
            ? ',"fieldSet": "' + infoWrapper.fieldSet + '"}'
            : null;
    }
    return payload;
  }

  /**
   * @description prepare payload for CAP Child Accounts
   * @param payload string
   * @param queryContext
   * @param infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForCAPChildAccounts(
    String payload,
    DataSource.QueryContext queryContext,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Child summary view
    if (isQueryCAPChildAccounts(infoWrapper)) {
      String accountNumber = infoWrapper.parentId.right(
        infoWrapper.parentId.length() - infoWrapper.parentId.indexOf('|') - 1
      );
      payload =
        '{"accountNumber": "' +
        accountNumber +
        '"' +
        ',"pageSize":"' +
        String.valueOf(queryContext?.maxResults) +
        '"';
      payload += (infoWrapper.productCategory == 'transactions')
        ? ',"offSet":"' + String.valueOf(queryContext?.offSet) + '"'
        : '';
      payload += String.isNotBlank(infoWrapper.fieldSet)
        ? ',"fieldSet": "' + infoWrapper.fieldSet + '"}'
        : '}';
    }
    return payload;
  }

  /**
   * @description prepare payload for single account
   * @param  payload string
   * @param  infoWrapper FAQueryBaseInfoWrapper
   * @return string final payload
   */
  public String getPayloadForSingleAccount(
    String payload,
    FAQueryBaseInfoWrapper infoWrapper
  ) {
    if (String.isEmpty(infoWrapper.externalId)) {
      return payload;
    }
    //Account detail view
    String accountNumber = infoWrapper.externalId.right(
      infoWrapper.externalId.length() - infoWrapper.externalId.indexOf('|') - 1
    );
    payload = '{"' + infoWrapper.externalField + '": "' + accountNumber + '"';
    payload += String.isNotBlank(infoWrapper.assetFinanceType)
      ? ',"type":"' + infoWrapper.assetFinanceType + '"}'
      : '}';
    return payload;
  }

  /**
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param externalId Financial account external id
   * @return List<FinServ__FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountByAccountNumber(
    String externalId
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = new List<FinServ__FinancialAccountRole__c>();

    String accountKey = externalId.contains('|')
      ? externalId.left(externalId.indexOf('|'))
      : '';
    if (String.isBlank(accountKey)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (PermissionUtils.canQuery('FinServ__FinancialAccount__c')) {
      faRoles = FA_REPOSITORY.getFinancialAccountsWithAcctNum(accountKey);
    }
    return faRoles;
  }

  /**
   * @description returns list of finanicial account numbers for current page/batch
   *              base on page size and offset
   * @param queryContext DataSource.QueryContext
   * @param accountNumbers list of account numbers
   * @return List<String>
   */
  public List<String> getCurrentBatchAccountNumbers(
    DataSource.QueryContext queryContext,
    List<String> accountNumbers
  ) {
    List<String> currentBatchAccountNumbers = new List<String>();
    accountNumbers.sort();
    if (accountNumbers.size() >= queryContext.offset) {
      Integer endPosition = accountNumbers.size() <=
        queryContext.offset + queryContext.maxResults
        ? accountNumbers.size()
        : queryContext.offset + queryContext.maxResults;
      for (Integer i = queryContext.offset; i < endPosition; i++) {
        currentBatchAccountNumbers.add(accountNumbers[i]);
      }
    }
    return currentBatchAccountNumbers;
  }

  /**
   * @description Retrieves list of financial accounts related to a customer via
   *                        financial account role relationship (FAR)
   * @param customerIds the customer external Ids
   * @param productTypes product type set
   * @param roleTypes roleType map
   * @return List<FinServ__FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountsByCustomerId(
    Set<String> customerIds,
    Set<String> productTypes,
    Map<String, String> roleTypes
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = new List<FinServ__FinancialAccountRole__c>();
    if (customerIds.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (
      PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') &&
      PermissionUtils.canQuery('FinServ__FinancialAccount__c')
    ) {
      faRoles = FA_REPOSITORY.getFinancialAccountsWithCustomerId(
        customerIds,
        ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME,
        productTypes,
        roleTypes
      );
    }
    return faRoles;
  }

  /**
   * @description get account account key
   * @param accountNumber Account Number
   * @param productCode Product Code
   * @param accountRoleMap FinancialAccountRole map
   * @return String Account_key__c
   */
  public String getAccountKey(
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
   * @description get customer related to the account
   * @param accountNumber Account Number
   * @param clgCustomerId CLG customer Id
   * @param accountRoleMap far map
   * @return Customer external Id
   */
  public String getCustomerId(
    String accountNumber,
    String clgCustomerId,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    if (String.isNotBlank(clgCustomerId)) {
      return clgCustomerId;
    }
    String result = '';
    if (
      accountRoleMap.containsKey(accountNumber) &&
      accountRoleMap.get(accountNumber).FinServ__RelatedAccount__r != null
    ) {
      result = accountRoleMap.get(accountNumber)
        .FinServ__RelatedAccount__r.External_Id__c;
    }
    return result;
  }

  /**
   * @description get product code
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return product code
   */
  public String getProductCode(
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
   * @description get product name
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return product name
   */
  public String getProductName(
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
   * @description get financial account status
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return account status
   */
  public String getFinStatus(
    String accountNumber,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      !accountRoleMap.containsKey(accountNumber) ||
      String.isEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.FinServ__Status__c
      )
    ) {
      return result;
    }
    result = accountRoleMap.get(accountNumber)
      .FinServ__FinancialAccount__r.FinServ__Status__c;
    return result;
  }

  /**
   * @description get source system status
   * @param accountNumber Account Number
   * @param accountRoleMap far map
   * @return Source System Status
   */
  public String getSourceSystemStatus(
    String accountNumber,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String result = '';
    if (
      !accountRoleMap.containsKey(accountNumber) ||
      String.isEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.Source_System_Status_Display__c
      )
    ) {
      return result;
    }
    result = accountRoleMap.get(accountNumber)
      .FinServ__FinancialAccount__r.Source_System_Status_Display__c;
    return result;
  }

  /**
   * @description get account relationship
   * @param accountNumber Account Number
   * @param roleTypes role type map
   * @param accountRoleMap far map
   * @return Account relationship
   */
  public String getAccountRelationship(
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
   * @description This is the wrapper class to get values from FinancialAccountQueryBase
   */
  public class FAQueryBaseInfoWrapper {
    public String externalId;
    public String externalField;
    public String parentId;
    public String parentField;
    public String fieldSet;
    public String assetFinanceType;
    public String productCategory;
    public FinancialAccountQueryBase.SourceSystemEnum sourceSystem;
  }
}
