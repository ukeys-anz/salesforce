/**
 * @author Ian Huang
 * @since  06/2023
 * @group Platform
 * @description Financial Account external query base class
 * @runTests DepositAccountExternalQueryTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveParameterList')
public abstract with sharing class FinancialAccountQueryBase extends ExternalObjectQueryBase {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final FinancialAccountQueryBaseRepository FA_REPOSITORY = (FinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    FinancialAccountQueryBaseRepository.class
  );
  FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
  /**
   * @description abstract FinancialAccount callout response class
   */
  public abstract class FinancialAccountCalloutResponse extends ExternalObjectQueryBase.ExternalObjectCalloutResponse {
    public String customerId;
    public String nextPageId;
    public List<FinancialAccountModelBase> accounts;
    public Customer customer;
  }

  /**
   * @description SourceSystem enums for determining API systems
   */
  public enum SourceSystemEnum {
    CAP,
    EBD
  }

  /**
   * @description AR&C financial account record type name
   */
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';
  private List<String> accountNumberList;
  private String clgCustomerId;

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
  @TestVisible
  protected String accountNumber;
  @TestVisible
  protected Map<String, FinServ__FinancialAccountRole__c> accountRoleMap;
  protected String assetFinanceType;
  protected String fieldSet = '';
  protected String productCategory = '';
  protected Set<String> productTypes = new Set<String>();
  protected SourceSystemEnum sourceSystem;
  protected Boolean useProductCodeFromFinancialAccount = false;
  protected Boolean retrieveBySOQLQuery = false;
  private static final String ML_USER_PROFILE_NAME = 'ANZ ML Standard User';
  /**
   * @description Class constractor
   */
  public FinancialAccountQueryBase() {
    this.accountNumberList = new List<String>();
    this.accountRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
    this.parentField = 'CustomerId';
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @return QueryMode Enum
   */
  protected virtual override ExternalObjectQueryBase.QueryModeEnum prepareCallout(
    DataSource.QueryContext queryContext
  ) {
    QueryModeEnum queryMode = super.prepareCallout(queryContext);
    if (this.sourceSystem != SourceSystemEnum.CAP) {
      return queryMode;
    }
    //retrieve financial accounts based on query mode
    this.accountRoleMap = getFinancialAccounts(
      queryMode,
      this.parentId,
      this.externalId
    );
    //prepare account numbers for callout
    this.accountNumberList = externalQueryHelper.getCurrentBatchAccountNumbers(
      queryContext,
      this.accountNumberList
    );
    if (this.accountRoleMap.keySet().isEmpty()) {
      String errorMessge = String.format(
        'Invalid financial account request: parent={0} parentId={1} externalId={2}',
        new List<Object>{ this.parentField, this.parentId, this.externalId }
      );
      Logger.error(errorMessge);
      Logger.saveLog();
    }
    return queryMode;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource QueryContext
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    ARNCService service = new ARNCService();
    ARNCService.FinancialAccountQueryParameters queryParams = new ARNCService.FinancialAccountQueryParameters();
    HttpCalloutResponse response;

    String payload = getPayload(queryContext);
    response = getCAPSummaryAccounts(service, queryParams, payload);
    response = getEBDSummaryAccounts(
      service,
      queryParams,
      payload,
      response,
      queryContext
    );
    response = getDetailAccounts(service, payload, response);
    if (response == null) {
      String errorMessge = String.format(
        'Invalid source system: {0} or query mode: {1}',
        new List<Object>{ this.sourceSystem, queryMode }
      );
      Logger.error(errorMessge);
      Logger.saveLog();
      throw new TypeException(errorMessge);
    }
    return response;
  }

  /**
   * @description Create a Dummy Financial account record
   * @param externalId External Id
   * @param row Additional dummy values from derived class
   * @return dummy financial account record
   **/
  @TestVisible
  protected virtual override ExternalObjectQueryBase.ExternalQueryResult createDummyExternalRecord(
    String externalId,
    Map<String, Object> row
  ) {
    row.put(
      'AccountNumber',
      externalQueryHelper.formatAccountNumber(
        externalQueryHelper.getAccountNumber(externalId)
      )
    );
    return super.createDummyExternalRecord(externalId, row);
  }

  /**
   * @description Get Financial account record
   * @param queryMode QueryMode Enum
   * @param parentId parent customer Id
   * @param externalId account external Id
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @TestVisible
  private Map<String, FinServ__FinancialAccountRole__c> getFinancialAccounts(
    QueryModeEnum queryMode,
    String parentId,
    String externalId
  ) {
    if (queryMode == QueryModeEnum.RELATED_LIST) {
      return getRelatedFinancialAccounts(parentId);
    } else {
      return getFinancialAccountDetail(externalId);
    }
  }

  /**
   * @description Get related Financial accounts
   * @param parentId parent customer Id
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @TestVisible
  private Map<String, FinServ__FinancialAccountRole__c> getRelatedFinancialAccounts(
    String parentId
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles;
    Set<String> customerIds = new Set<String>();
    if (String.isBlank(parentId)) {
      return new Map<String, FinServ__FinancialAccountRole__c>();
    }
    if (
      UserInfo.getProfileId() !=
      CommonUtil.getProfileByName(ML_USER_PROFILE_NAME).Id
    ) {
      customerIds = getCLGRelatedCustomerIds(this.parentId);
    } else {
      customerIds.add(this.parentId);
    }
    faRoles = externalQueryHelper.retrieveFinancialAccountsByCustomerId(
      customerIds,
      productTypes,
      roleTypes
    );
    return populateData(faRoles);
  }

  /**
   * @description Get Financial account detail
   * @param externalId account external Id
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @TestVisible
  private Map<String, FinServ__FinancialAccountRole__c> getFinancialAccountDetail(
    String externalId
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles;
    if (String.isBlank(externalId)) {
      return new Map<String, FinServ__FinancialAccountRole__c>();
    }
    faRoles = externalQueryHelper.retrieveFinancialAccountByAccountNumber(
      externalId
    );
    return populateData(faRoles);
  }

  /**
   * @description get account relationship
   * @param accountNumber Account Number
   * @return Account relationship
   */
  protected String getAccountRelationship(String accountNumber) {
    return externalQueryHelper.getAccountRelationship(
      accountNumber,
      roleTypes,
      accountRoleMap
    );
  }

  /**
   * @description get source system status
   * @param accountNumber Account Number
   * @return Source System Status
   */
  @testVisible
  protected String getSourceSystemStatus(String accountNumber) {
    return externalQueryHelper.getSourceSystemStatus(
      accountNumber,
      accountRoleMap
    );
  }

  /**
   * @description get financial account status
   * @param accountNumber Account Number
   * @return account status
   */
  @testVisible
  protected String getFinStatus(String accountNumber) {
    return externalQueryHelper.getFinStatus(accountNumber, accountRoleMap);
  }

  /**
   * @description get product name
   * @param accountNumber Account Number
   * @return product name
   */
  @testVisible
  protected String getProductName(String accountNumber) {
    return externalQueryHelper.getProductName(accountNumber, accountRoleMap);
  }

  /**
   * @description get product code
   * @param accountNumber Account Number
   * @return product code
   */
  @testVisible
  protected String getProductCode(String accountNumber) {
    return externalQueryHelper.getProductCode(accountNumber, accountRoleMap);
  }

  /**
   * @description get customer related to the account
   * @param accountNumber Account Number
   * @return Customer external Id
   */
  protected String getCustomerId(String accountNumber) {
    return externalQueryHelper.getCustomerId(
      accountNumber,
      this.clgCustomerId,
      this.accountRoleMap
    );
  }
  /**
   * @description get customer related to the account
   * @param customerIdSet Customer External Id Set
   * @return Map<String, String>  Customer External Id and Customer Name Map
   */
  protected Map<String, String> getCustomerName(Set<String> customerIdSet) {
    Map<String, String> customerNameMap = new Map<String, String>();
    List<Account> customers = FA_Repository.getCustomerUsingExternalId(
      customerIdSet
    );
    for (Account acc : customers) {
      customerNameMap.put(acc.External_Id__c, acc.Name);
    }
    return customerNameMap;
  }

  /**
   * @description get account account key
   * @param accountNumber Account Number
   * @param productCode Product Code
   * @param accountRoleMap FinancialAccountRole map
   * @return String Account_key__c
   */
  @testVisible
  protected String getAccountKey(
    String accountNumber,
    String productCode,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    return externalQueryHelper.getAccountKey(
      accountNumber,
      productCode,
      accountRoleMap
    );
  }

  /**
   * @description Populates Data
   * @param faRoles far list
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @testVisible
  private Map<String, FinServ__FinancialAccountRole__c> populateData(
    List<FinServ__FinancialAccountRole__c> faRoles
  ) {
    Map<String, FinServ__FinancialAccountRole__c> result = new Map<String, FinServ__FinancialAccountRole__c>();
    for (FinServ__FinancialAccountRole__c faRole : faRoles) {
      this.accountNumberList.add(
        faRole.FinServ__FinancialAccount__r.Product_Type__c.right(3)
            .remove(':') +
          '-' +
          faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      );
      result.put(
        faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        faRole
      );
    }
    return result;
  }

  /**
   * @description Creates string payload
   * @param queryContext
   * @return payload string
   **/
  protected String getPayload(DataSource.QueryContext queryContext) {
    String payload;
    payload = externalQueryHelper.getPayloadForSingleAccount(
      payload,
      prepareInfoWrapper()
    );
    payload = externalQueryHelper.getPayloadForCAPChildAccounts(
      payload,
      queryContext,
      prepareInfoWrapper()
    );
    payload = externalQueryHelper.getPayloadForCAPChildAccountsWithAssetFinanceType(
      payload,
      prepareInfoWrapper()
    );
    payload = externalQueryHelper.getPayloadForEBDChildAccountsWithAssetFinanceType(
      payload,
      prepareInfoWrapper()
    );
    payload = externalQueryHelper.getPayloadForGuaranteeFeeSummaryAccounts(
      payload,
      prepareInfoWrapper()
    );
    payload = externalQueryHelper.getPayloadForEBDChildAccounts(
      payload,
      prepareInfoWrapper()
    );
    return payload;
  }

  /**
   * @description checks if QueryCAPSummaryViewAccounts needed
   * @return true/false
   **/
  private Boolean isQueryCAPSummaryViewAccounts() {
    return this.sourceSystem == SourceSystemEnum.CAP;
  }

  /**
   * @description checks if QueryEBDSummaryViewAccounts needed
   * @return true/false
   **/
  private Boolean isQueryEBDSummaryViewAccounts() {
    return this.parentField == 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  /**
   * @description get CAP Summary Accounts
   * @param service ARNCService instance
   * @param queryParams
   * @param payload string
   * @return htttpResonse
   **/
  @testVisible
  protected HttpCalloutResponse getCAPSummaryAccounts(
    ARNCService service,
    ARNCService.FinancialAccountQueryParameters queryParams,
    String payload
  ) {
    HttpCalloutResponse response;
    if (!(isQueryCAPSummaryViewAccounts() && String.isBlank(payload))) {
      return response;
    }
    for (Integer i = 0; i < accountNumberList.size(); i++) {
      queryParams.accounts.add(accountNumberList[i]);
    }
    response = service.queryCAPAccounts(this.productCategory, queryParams);
    return response;
  }

  /**
   * @description get EBDS Accounts
   * @param service ARNCService instance
   * @param queryParams FinancialAccountQueryParameters
   * @param payload string
   * @param response HttpCalloutResponse
   * @param queryContext DataSource.QueryContext
   * @return HttpCalloutResponse
   **/
  @testVisible
  protected HttpCalloutResponse getEBDSummaryAccounts(
    ARNCService service,
    ARNCService.FinancialAccountQueryParameters queryParams,
    String payload,
    HttpCalloutResponse response,
    DataSource.QueryContext queryContext
  ) {
    if (
      !(isQueryEBDSummaryViewAccounts() && String.isBlank(payload)) ||
      response != null
    ) {
      return response;
    }
    Set<String> customerIds = getCLGRelatedCustomerIds(this.parentId);
    for (String customerId : customerIds) {
      customerId = customerId.contains('_')
        ? customerId.substringAfter('_')
        : customerId;
      queryParams.capCustomerIds.add(customerId);
    }
    queryParams.pageSize = String.valueOf(queryContext?.maxResults);
    if (this.assetFinanceType == 'AMBIT' || this.assetFinanceType == 'ELS') {
      queryParams.type = this.assetFinanceType;
    }
    response = service.queryEBDAccounts(
      this.productCategory,
      queryParams,
      this.assetFinanceType
    );
    return response;
  }

  /**
   * @description get detail accounts
   * @param service ARNCService instance
   * @param payload string
   * @param response
   * @return httpResonse
   **/
  @testVisible
  protected HttpCalloutResponse getDetailAccounts(
    ARNCService service,
    String payload,
    HttpCalloutResponse response
  ) {
    if (String.isBlank(payload) || response != null) {
      return response;
    }
    response = service.queryAccountDetail(this.productCategory, payload);
    return response;
  }

  /**
   * @description get legal entity customer Ids related to CLG
   * @param customerId CLG customer Id
   * @return Set<String> List of customer Ids
   */
  protected Set<String> getCLGRelatedCustomerIds(String customerId) {
    Set<String> result = externalQueryHelper.getCLGRelatedCustomerIds(
      customerId
    );
    if (!result.isEmpty()) {
      //Set CLG customer Id as current customer Id
      this.clgCustomerId = customerId;
    }
    return result;
  }

  /**
   * @description get record External Id
   * @param finAccount Financial account record
   * @param accountRoleMap FinancialAccountRole map
   * @return String External Id
   */
  @testVisible
  protected String getExternalId(
    FinancialAccountModelBase finAccount,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String productCode = externalQueryHelper.getProductCode(
      finAccount,
      useProductCodeFromFinancialAccount,
      accountRoleMap
    );
    return externalQueryHelper.getAccountKey(
      finAccount.accountNumber,
      productCode,
      accountRoleMap
    );
  }

  /**
   * @description get product code
   * @param  finAccount Financial account record
   * @return String External Id
   */
  @testVisible
  private String getProductCode(FinancialAccountModelBase finAccount) {
    return externalQueryHelper.getProductCode(
      finAccount,
      useProductCodeFromFinancialAccount,
      accountRoleMap
    );
  }

  /**
   * @description get sub product code
   * @param accountNumber Account Number
   * @return sub product code
   */
  @testVisible
  protected String getSubProductCode(String accountNumber) {
    String result = '';
    if (
      !accountRoleMap.containsKey(accountNumber) ||
      String.isEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.Sub_product_Code_Display__c
      )
    ) {
      return result;
    }
    result = accountRoleMap.get(accountNumber)
      .FinServ__FinancialAccount__r.Sub_product_Code_Display__c;
    return result;
  }

  /**
   * @description prepares FAQueryBaseInfoWrapper to pass values from this class to Helper Class
   * @return FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper
   */
  @testVisible
  public FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper prepareInfoWrapper() {
    FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper infoWrapper = new FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper();
    infoWrapper.fieldSet = this.fieldSet;
    infoWrapper.assetFinanceType = this.assetFinanceType;
    infoWrapper.parentId = this.parentId;
    infoWrapper.parentField = this.parentField;
    infoWrapper.sourceSystem = this.sourceSystem;
    infoWrapper.productCategory = this.productCategory;
    infoWrapper.externalId = this.externalId;
    infoWrapper.externalField = this.externalField;
    return infoWrapper;
  }
}
