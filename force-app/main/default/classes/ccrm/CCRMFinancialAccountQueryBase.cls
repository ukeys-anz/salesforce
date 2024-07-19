/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Financial Account external query base class
 * @runTests CCRMDepositAccountQueryTest
 */
@SuppressWarnings(
  'PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount'
)
public abstract with sharing class CCRMFinancialAccountQueryBase extends CCRMExternalObjectQueryBase {
  /**
   * @description abstract FinancialAccount callout response
   */
  public abstract class FinancialAccountCalloutResponse {
    public String customerId;
    public String nextPageId;
    public List<CCRMFinancialAccountModelBase> accounts;
    public Customer customer;
  }

  /**
   * @description SourceSystem enums for dtermining API systems
   */
  public enum SourceSystemEnum {
    CAP,
    EBD
  }

  /**
   * @description AR&C financial account record type name
   */
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';

  /**
   * @description Financial account role types
   */
  protected Map<String, String> roleTypes = new Map<String, String>{
    'BCC' => 'Business Card Customer',
    'CLG' => 'Customer Lending Group',
    'COF' => 'Co-Owner First',
    'COO' => 'Co-Owner Other',
    'DBN' => 'Direct Beneficiary',
    'GTR' => 'Guarantor',
    'PCC' => 'Personal Card Customer',
    'PRI' => 'Primary Owner',
    'SOL' => 'Sole Owner',
    'TSF' => 'Trustee First',
    'TSO' => 'Trustee Other',
    'UNO' => 'Unnamed Owner'
  };
  protected String fieldSet = '';
  protected String productCategory = '';
  protected Set<String> productTypes = new Set<String>();
  protected SourceSystemEnum sourceSystem;
  protected String assetFinanceType;

  private List<String> accountNumberList;
  private String clgCustomerId;
  protected Map<String, FinServ__FinancialAccountRole__c> accountRoleMap;
  protected FinancialAccountCalloutResponse calloutResponse;
  protected Boolean useProductCodeFromFinancialAccount = false;

  /**
   * @description Constractor
   */
  public CCRMFinancialAccountQueryBase() {
    this.accountNumberList = new List<String>();
    this.accountRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
    this.parent = 'CustomerId';
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public virtual override CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    super.execute(queryContext);

    prepareCallout();
    HttpCalloutResponse response = makeCallout();
    parseResponse(response.body);
    CCRMExternalObjectQueryBase.ExternalQueryResult queryResult = createFinancialAccounts();
    setNextPageId(queryResult.queryMoreToken);

    return queryResult;
  }

  /**
   * @description Parse query filters and prepare for API callout
   */
  protected virtual override void prepareCallout() {
    getParent();
    parseFilters(this.parent);

    if (this.sourceSystem == SourceSystemEnum.CAP) {
      if (String.isNotBlank(this.parentId)) {
        Set<String> customerIds = getCLGRelatedCustomerIds(this.parentId);
        retrieveFinancialAccountsByCustomerId(customerIds);
      } else if (String.isNotBlank(this.externalId)) {
        retrieveFinancialAccountByAccountNumber(this.externalId);
      } else {
        Logger.error(
          'Invalid financial account request: ' +
            ' parent = ' +
            this.parent +
            ' parentId = ' +
            this.parentId +
            ' externalId = ' +
            this.externalId
        );
        Logger.saveLog();
      }
      //prepare account numbers for callout
      getCurrentBatchAccountNumbers();
    }
  }

  /**
   * @description virtual Deserialize API callout response
   * @param responseBody API response payload
   */
  protected virtual void parseResponse(String responseBody) {
  }

  /**
   * @description virtual Transform API response to financial account records
   * @return List<Map<String, Object>>
   */
  protected virtual CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    return null;
  }

  /**
   * @description get account relationship
   * @param accountNumber Account Number
   * @return Account relationship
   */
  protected String getAccountRelationship(String accountNumber) {
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
   * @description get customer related to the account
   * @param accountNumber Account Number
   * @return Customer external Id
   */
  protected String getCustomerId(String accountNumber) {
    if (String.isNotBlank(this.clgCustomerId)) {
      return this.clgCustomerId;
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
   * @description get customer related to the account
   * @param externalId External Id
   * @return String Customer Name
   */
  protected String getCustomerName(String externalId) {
    List<Account> customer = new List<Account>(
      [
        SELECT Id, Name, External_Id__c
        FROM Account
        WHERE External_Id__c = :'CAP-CIS_' + externalId
      ]
    );
    return customer.size() > 0 ? customer[0].Name : null;
  }

  /**
   * @description get account account key
   * @param accountNumber Account Number
   * @param productCode Product Code
   * @return String Account_key__c
   */
  @testVisible
  protected String getAccountKey(String accountNumber, String productCode) {
    String result = '';
    if (
      accountRoleMap.containsKey(accountNumber) &&
      accountRoleMap.get(accountNumber).FinServ__RelatedAccount__r != null
    ) {
      result = accountRoleMap.get(accountNumber)
        .FinServ__FinancialAccount__r.Account_Key__c;
    }
    return result + '|' + productCode + '-' + accountNumber;
  }

  /**
   * @description Retrieves list of financial accounts related to a customer via
   *                        financial account role relationship (FAR)
   * @param customerIds the customer external Ids
   */
  private void retrieveFinancialAccountsByCustomerId(Set<String> customerIds) {
    if (customerIds.isEmpty()) {
      return;
    }

    if (
      PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') &&
      PermissionUtils.canQuery('FinServ__FinancialAccount__c')
    ) {
      List<FinServ__FinancialAccountRole__c> faRoles = [
        SELECT
          FinServ__FinancialAccount__c,
          FinServ__FinancialAccount__r.Account_Key__c,
          FinServ__FinancialAccount__r.Name,
          FinServ__FinancialAccount__r.FinServ__Status__c,
          FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          FinServ__FinancialAccount__r.Product_Type__c,
          FinServ__FinancialAccount__r.Product_SubCode__c,
          FinServ__RelatedAccount__r.External_Id__c,
          Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE
          FinServ__RelatedAccount__r.External_Id__c IN :customerIds
          AND FinServ__FinancialAccount__r.RecordType.DeveloperName = :ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME
          AND FinServ__Active__c = TRUE
          AND FinServ__FinancialAccount__r.Product_Type__c IN :productTypes
          AND Role_Type__c IN :roleTypes.keyset()
        ORDER BY FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      ];
      for (FinServ__FinancialAccountRole__c faRole : faRoles) {
        this.accountNumberList.add(
          faRole.FinServ__FinancialAccount__r.Product_Type__c.right(3)
              .remove(':') +
            '-' +
            faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
        );
        this.accountRoleMap.put(
          faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          faRole
        );
      }
    }
  }

  /* @description returns list of finanicial account numbers for current page/batch
   *              base on page size & offset
   */
  private void getCurrentBatchAccountNumbers() {
    List<String> currentBatchAccountNumbers = new List<String>();

    this.accountNumberList.sort();
    if (this.accountNumberList.size() >= this.queryContext.offset) {
      Integer endPosition = this.accountNumberList.size() <=
        this.queryContext.offset + this.queryContext.maxResults
        ? this.accountNumberList.size()
        : this.queryContext.offset + this.queryContext.maxResults;
      for (Integer i = this.queryContext.offset; i < endPosition; i++) {
        currentBatchAccountNumbers.add(this.accountNumberList[i]);
      }
    }
    this.accountNumberList = currentBatchAccountNumbers;
  }

  /**
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param externalId Financial account external id
   */
  private void retrieveFinancialAccountByAccountNumber(String externalId) {
    if (PermissionUtils.canQuery('FinServ__FinancialAccount__c')) {
      String accountKey = externalId.left(this.externalId.indexOf('|'));
      List<FinServ__FinancialAccountRole__c> faRoles = [
        SELECT
          FinServ__FinancialAccount__c,
          FinServ__FinancialAccount__r.Account_Key__c,
          FinServ__FinancialAccount__r.Name,
          FinServ__FinancialAccount__r.FinServ__Status__c,
          FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          FinServ__FinancialAccount__r.Product_Type__c,
          FinServ__FinancialAccount__r.Product_SubCode__c,
          FinServ__RelatedAccount__r.External_Id__c,
          Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE FinServ__FinancialAccount__r.Account_Key__c = :accountKey
      ];
      for (FinServ__FinancialAccountRole__c faRole : faRoles) {
        this.accountNumberList.add(
          faRole.FinServ__FinancialAccount__r.Product_Type__c.right(3)
              .remove(':') +
            '-' +
            faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
        );
        this.accountRoleMap.put(
          faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          faRole
        );
      }
    }
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout() {
    CCRMARNCService service = new CCRMARNCService();
    CCRMARNCService.FinancialAccountQueryParameters queryParams = new CCRMARNCService.FinancialAccountQueryParameters();

    HttpCalloutResponse response;
    //Account detail view
    if (String.isNotEmpty(this.externalId)) {
      String accountNumber = this.externalId.right(
        this.externalId.length() - this.externalId.indexOf('|') - 1
      );
      String payload = '{"' + this.externalField + '": "' + accountNumber + '"';
      payload += String.isNotBlank(this.assetFinanceType)
        ? ',"type":"' + this.assetFinanceType + '"}'
        : '}';
      response = service.queryAccountDetail(this.productCategory, payload);
      //Child summary view
    } else if (
      String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isBlank(this.assetFinanceType)
    ) {
      String accountNumber = this.parentId.right(
        this.parentId.length() - this.parentId.indexOf('|') - 1
      );
      String payload =
        '{"accountNumber": "' +
        accountNumber +
        '"' +
        ',"pageSize":"' +
        String.valueOf(this.queryContext.maxResults) +
        '"';
      payload += String.isNotBlank(this.fieldSet)
        ? ',"fieldSet": "' + this.fieldSet + '"}'
        : getNextPageId() != null
            ? ',"nextPageId": "' + getNextPageId() + '"}'
            : '}';
      response = service.queryAccountDetail(this.productCategory, payload);
      //Child accounts summary having EBD as parent
    } else if (
      String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isNotBlank(this.assetFinanceType)
    ) {
      String payload = '{"compositeAccountNumber": "' + this.parentId + '"';
      payload += String.isNotBlank(this.fieldSet) &&
        String.isNotBlank(this.assetFinanceType)
        ? ',"fieldSet": "' +
          this.fieldSet +
          '"' +
          ',"type":"' +
          this.assetFinanceType +
          '"}'
        : String.isNotBlank(this.fieldSet)
            ? ',"fieldSet": "' + this.fieldSet + '"}'
            : null;
      response = service.queryAccountDetail(this.productCategory, payload);
      //child EBD accounts summary view having EBD as parent
    } else if (
      String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD &&
      String.isNotBlank(this.assetFinanceType)
    ) {
      String payload = '{"compositeAssetId": "' + this.parentId + '"';
      payload += String.isNotBlank(this.fieldSet) &&
        String.isNotBlank(this.assetFinanceType)
        ? ',"fieldSet": "' +
          this.fieldSet +
          '"' +
          ',"type":"' +
          this.assetFinanceType +
          '"}'
        : String.isNotBlank(this.fieldSet)
            ? ',"fieldSet": "' + this.fieldSet + '"}'
            : null;
      response = service.queryAccountDetail(this.productCategory, payload);
      //CAP accounts summary view
    } else if (this.sourceSystem == SourceSystemEnum.CAP) {
      for (Integer i = 0; i < accountNumberList.size(); i++) {
        queryParams.accounts.add(accountNumberList[i]);
      }
      response = service.queryCAPAccounts(this.productCategory, queryParams);
      //EBD accounts summary view
    } else if (
      this.parent == 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD
    ) {
      Set<String> customerIds = getCLGRelatedCustomerIds(this.parentId);
      for (String customerId : customerIds) {
        String parentId;
        customerId = customerId.contains('_')
          ? customerId.substringAfter('_')
          : customerId;
        queryParams.capCustomerIds.add(customerId);
      }
      queryParams.pageSize = String.valueOf(this.queryContext.maxResults);
      queryParams.nextPageId = getNextPageId();

      if (this.assetFinanceType == 'AMBIT' || this.assetFinanceType == 'ELS') {
        queryParams.type = this.assetFinanceType;
      }
      response = service.queryEBDAccounts(
        this.productCategory,
        queryParams,
        this.assetFinanceType
      );
      //Guarantee Fee Summary
    } else if (
      String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      (this.parent == 'ActiveGuaranteeId' ||
      this.parent == 'InactiveGuaranteeId') &&
      this.sourceSystem == SourceSystemEnum.EBD
    ) {
      String payload = '{"compositeGuaranteesId": "' + this.parentId + '"';
      payload += String.isNotBlank(this.fieldSet)
        ? ',"fieldSet": "' + this.fieldSet + '"}'
        : '}';
      response = service.queryAccountDetail(this.productCategory, payload);
      //CAP accounts summary view
    } else if (this.sourceSystem == SourceSystemEnum.CAP) {
      for (Integer i = 0; i < accountNumberList.size(); i++) {
        queryParams.accounts.add(accountNumberList[i]);
      }
      response = service.queryCAPAccounts(this.productCategory, queryParams);
      //EBD accounts child summary view
    } else if (
      String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD
    ) {
      String payload = '{"compositeAccountNumber": "' + this.parentId + '"';
      payload += String.isNotBlank(this.fieldSet) &&
        String.isNotBlank(this.assetFinanceType)
        ? ',"fieldSet": "' +
          this.fieldSet +
          '"' +
          ',"type":"' +
          this.assetFinanceType +
          '"}'
        : String.isNotBlank(this.fieldSet)
            ? ',"fieldSet": "' + this.fieldSet + '"}'
            : null;
      response = service.queryAccountDetail(this.productCategory, payload);
    } else {
      Logger.error('Invalid query source system: ' + this.sourceSystem);
      Logger.saveLog();
      throw new TypeException(
        'Invalid query source system: ' + this.sourceSystem
      );
    }

    return response;
  }

  /**
   * @description get legal entity customer Ids related to CLG
   * @param customerId CLG customer Id
   * @return Set<String> List of customer Ids
   */
  protected Set<String> getCLGRelatedCustomerIds(String customerId) {
    Set<String> result = new Set<String>();

    if (PermissionUtils.canQuery('Account')) {
      //check to see if customer is CLG
      List<Account> customers = [
        SELECT Id
        FROM Account
        WHERE External_Id__c = :customerId AND RecordType.DeveloperName = 'CLG'
        LIMIT 1
      ];
      if (customers.isEmpty()) {
        result.add(customerId);
        return result;
      }
    }

    if (PermissionUtils.canQuery('FinServ__AccountAccountRelation__c')) {
      for (FinServ__AccountAccountRelation__c aar : [
        SELECT Id, FinServ__RelatedAccount__r.External_Id__c
        FROM FinServ__AccountAccountRelation__c
        WHERE
          FinServ__Account__r.External_Id__c = :customerId
          AND FinServ__Active__c = TRUE
      ]) {
        result.add(aar.FinServ__RelatedAccount__r.External_Id__c);
      }
    }
    if (!result.isEmpty()) {
      //Set CLG customer Id as current customer Id
      this.clgCustomerId = customerId;
    }

    return result;
  }

  /**
   * @description Format Account Number
   * @param accountNumber Account Number
   * @return String formatted Account Number
   */
  protected String formatAccountNumber(String accountNumber) {
    if (String.isBlank(accountNumber)) {
      return '';
    }
    if (accountNumber.length() == 8) {
      accountNumber = '0' + accountNumber;
      return String.format(
        '{0}-{1}',
        new List<String>{
          accountNumber.subString(0, 4),
          accountNumber.subString(4, 9)
        }
      );
    } else if (accountNumber.length() == 9) {
      return String.format(
        '{0}-{1}',
        new List<String>{
          accountNumber.subString(0, 4),
          accountNumber.subString(4, 9)
        }
      );
    } else if (accountNumber.length() == 11) {
      return String.format(
        '{0}-{1}-{2}',
        new List<String>{
          accountNumber.subString(0, 4),
          accountNumber.subString(4, 7),
          accountNumber.subString(7, 11)
        }
      );
    } else if (accountNumber.length() == 16) {
      return String.format(
        '{0}-{1}-{2}-{3}',
        new List<String>{
          accountNumber.subString(0, 4),
          accountNumber.subString(4, 8),
          accountNumber.subString(8, 12),
          accountNumber.subString(12, 16)
        }
      );
    }
    return accountNumber;
  }

  /**
   * @description get record External Id
   * @param  finAccount Financial account record
   * @return String External Id
   */
  @testVisible
  protected String getExternalId(CCRMFinancialAccountModelBase finAccount) {
    String productCode = getProductCode(finAccount);
    return getAccountKey(finAccount.accountNumber, productCode);
  }

  /**
   * @description get product code
   * @param  finAccount Financial account record
   * @return String External Id
   */
  @testVisible
  private String getProductCode(CCRMFinancialAccountModelBase finAccount) {
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
   * @description get external record DisplayUrl
   * @param  finAccount Financial account record
   * @return String DisplayUrl
   */
  protected String getDisplayUrl(CCRMFinancialAccountModelBase finAccount) {
    return URL.getOrgDomainUrl().toExternalForm() +
      '/' +
      finAccount.productCode +
      '-' +
      finAccount.accountNumber;
  }

  /**
   * @description get next page Id for pagination
   * @return String next page Id
   */
  private String getNextPageId() {
    if (this.queryContext.offset == 0) {
      return null;
    }
    String cacheKey = getNextPageIdCacheKey();
    if (String.isNotBlank(cacheKey)) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );
      return String.valueOf(sessionPart.get(cacheKey));
    } else {
      return null;
    }
  }

  /**
   * @description Set next page Id for pagination
   * @param queryMoreToken Next page Id
   */
  private void setNextPageId(String queryMoreToken) {
    String cacheKey = getNextPageIdCacheKey();
    if (String.isNotBlank(cacheKey)) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );
      if (String.isBlank(queryMoreToken)) {
        sessionPart.remove(cacheKey);
      } else {
        sessionPart.put(cacheKey, queryMoreToken);
      }
    }
  }

  /**
   * @description get next page Id session cache key
   * @return String Cache key
   */
  private String getNextPageIdCacheKey() {
    if (String.isNotBlank(this.parentId)) {
      String key = this.parentId.right(
          this.parentId.length() - this.parentId.indexOf('|') - 1
        )
        .remove('-')
        .remove('_');
      return 'QueryMoreToken' + key;
    } else {
      return null;
    }
  }
}
