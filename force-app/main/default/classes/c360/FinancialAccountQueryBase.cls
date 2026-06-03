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
   * @description is CAP customer?
   * @return is CAP customer yes or no
   */
  public Boolean isCAPCustomer() {
    return this.customerSourceSystem == 'CAP-CIS';
  }

  /**
   * @description is CACHE customer?
   * @return is CACHE customer yes or no
   */
  public Boolean isCACHECustomer() {
    return this.customerSourceSystem == 'CACHE';
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
  protected String customerSourceSystem;
  protected Boolean useProductCodeFromFinancialAccount = false;
  protected Boolean retrieveBySOQLQuery = false;
  private static final String CCRM_USER_PROFILE_NAME = 'ANZ CCRM Standard User';

  /**
   * @description Class constractor
   */
  public FinancialAccountQueryBase() {
    this.accountNumberList = new List<String>();
    this.accountRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
    this.parentField = 'CustomerId';
  }

  /**
   * @description  Cache AssetFinance callout request class
   */
  public virtual class CacheAssetFinanceCalloutRequest extends ExternalObjectQueryBase.ExternalObjectCalloutRequestBase {
    FinancialAccountExternalQueryHelper faHelper = new FinancialAccountExternalQueryHelper();
    public String productCategory;
    private Map<String, String> cacheAssetFinanceEndPointsMap = new Map<String, String>{
      'AFAMBITContractRELATED_LIST' => 'ListCacheAssetFinanceAmbitContracts',
      'AFAMBITContractRECORD_DETAIL' => 'GetCacheAssetFinanceAmbitContract',
      'AFAMBITCreditLineRELATED_LIST' => 'ListCacheAssetFinanceAmbitCreditLines',
      'AFAMBITCreditLineRECORD_DETAIL' => 'GetCacheAssetFinanceAmbitCreditLine',
      'AssetFinanceAssetDetailRELATED_LIST' => 'ListCacheAssetFinanceAmbitAssets',
      'AssetFinanceAssetDetailRECORD_DETAIL' => 'GetCacheAssetFinanceAmbitAsset',
      'AFAMBITRepaymentRELATED_LIST' => 'ListCacheAssetFinanceAmbitRepayments',
      'AccountRelationshipRELATED_LIST' => 'ListCacheAssetFinanceAmbitRelationships'
    };
    public String tableName;

    /**
     * @description abstract FinancialAccount callout response class
     * @param queryContext DataSource QueryContext
     * @param queryMode Query Mode Enum
     * @param productCategory productCategory
     * @param assetFinanceType asset finance type
     * @param cacheCustomerIds cacheCustomerIds
     * @param infoWrapper infoWrapper
     */
    public CacheAssetFinanceCalloutRequest(
      DataSource.QueryContext queryContext,
      QueryModeEnum queryMode,
      String productCategory,
      String assetFinanceType,
      Set<String> cacheCustomerIds,
      FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper infoWrapper
    ) {
      super(queryContext, queryMode);
      this.productCategory = productCategory;
      this.tableName = queryContext.tableSelection.tableSelected;
      this.payload = new FinancialAccountEntities.AssetFinancePayload();
      getPayload(cacheCustomerIds, queryContext, assetFinanceType, infoWrapper);
    }
    /**
     * @description Creates FinancialAccountEntities.AssetFinancePayload payload
     * @param queryContext
     * @param infoWrapper infoWrapper
     * @return FinancialAccountEntities.AssetFinancePayload payload
     **/
    protected FinancialAccountEntities.AssetFinancePayload getPayload(
      DataSource.QueryContext queryContext,
      FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper infoWrapper
    ) {
      FinancialAccountEntities.AssetFinancePayload assetPayload;
      if (this.isDetailRequest()) {
        return faHelper.getPayloadForSingleAccountForCache(infoWrapper);
      }
      if (infoWrapper.parentField != 'CustomerId') {
        assetPayload = new FinancialAccountEntities.AssetFinancePayload();
        List<String> externalIds = infoWrapper.parentId.substringAfter('_')
          .split('-');
        assetPayload.contractNumber = externalIds[1];
        assetPayload.type = infoWrapper.assetFinanceType;
      }
      return assetPayload;
    }

    /**
     * @description get payload method
     * @param cacheCustomerIds cache customer ids set
     * @param queryContext DataSource QueryContext
     * @param assetFinanceType asset finance type
     * @param infoWrapper infoWrapper
     */
    public void getPayload(
      Set<String> cacheCustomerIds,
      DataSource.QueryContext queryContext,
      String assetFinanceType,
      FinancialAccountExternalQueryHelper.FAQueryBaseInfoWrapper infoWrapper
    ) {
      FinancialAccountEntities.AssetFinancePayload payloadBody = getPayload(
        queryContext,
        infoWrapper
      );
      if (payloadBody == null) {
        payloadBody = new FinancialAccountEntities.AssetFinancePayload();
        payloadBody.customerIds = cacheCustomerIds;
        payloadBody.type = assetFinanceType;
        payloadBody.offSet = String.valueOf(queryContext.offSet);
        payloadBody.pageSize = String.valueOf(queryContext.maxResults);
      }
      this.payload = payloadBody;
    }

    /**
     * @description getEndpoint method
     * @return String
     */
    public override String getEndpoint() {
      String host = Label.Financial_Account_CACHE360_Endpoint;
      if (this.isSummaryRequest()) {
        return host +
          this.cacheAssetFinanceEndPointsMap.get(
            this.tableName + 'RELATED_LIST'
          );
      } else {
        return host +
          this.cacheAssetFinanceEndPointsMap.get(
            this.tableName + 'RECORD_DETAIL'
          );
      }
    }

    /**
     * @description getStaffModel method
     * @return StaffTokenRequestModel
     */
    public override StaffTokenRequestModel getStaffModel() {
      StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
      staffModel.anzTokenType = 'staff';
      staffModel.apiScopesRequested = 'CCRM_CACHE_360';
      staffModel.realm = 'system';
      staffModel.isSecureWafFlow = true;
      return staffModel;
    }
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @return QueryMode Enum
   */
  protected virtual override ExternalObjectQueryBase.QueryModeEnum prepareCallout(
    DataSource.QueryContext queryContext
  ) {
    this.queryMode = super.prepareCallout(queryContext);
    String customerId = this.parentId != null ? this.parentId : this.externalId;
    getCustomerSource(customerId);
    if (this.sourceSystem != SourceSystemEnum.CAP) {
      return this.queryMode;
    }
    //retrieve financial accounts based on query mode
    this.accountRoleMap = getFinancialAccounts(
      this.queryMode,
      this.parentId,
      this.externalId
    );
    //prepare account numbers for callout
    this.accountNumberList = externalQueryHelper.getCurrentBatchAccountNumbers(
      queryContext,
      this.accountNumberList
    );
    return this.queryMode;
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
    HttpCalloutResponse response;
    switch on this.customerSourceSystem {
      when 'CAP-CIS' {
        ARNCService service = new ARNCService();
        ARNCService.FinancialAccountQueryParameters queryParams = new ARNCService.FinancialAccountQueryParameters();
        String payload = getPayload(queryContext);
        queryParams.offSet = String.valueOf(queryContext.offSet);
        queryParams.pageSize = String.valueOf(queryContext.maxResults);
        response = getCAPSummaryAccounts(service, queryParams, payload);
        response = getEBDSummaryAccounts(
          service,
          queryParams,
          payload,
          response,
          queryContext
        );
        response = getDetailAccounts(service, payload, response);
      }
      when 'CACHE' {
        CacheAssetFinanceCalloutRequest calloutRequest = new CacheAssetFinanceCalloutRequest(
          queryContext,
          queryMode,
          this.productCategory,
          this.assetFinanceType,
          getCustomerIds(),
          prepareInfoWrapper()
        );
        ARNC360ServiceRepository serviceRepo = new ARNC360ServiceRepository();
        response = serviceRepo.makeCacheAccountCallout(calloutRequest);
      }
      when else {
        // for other source system, treat them as non-CAP/ non-cache customer to avoid callout failure, and log a warning message.
        String errorMessge = String.format(
          'Unexpected error from makeCallout - {0} and query mode: {1}.\n {2}',
          new List<Object>{
            this.tableName,
            queryMode,
            'Customer Source System Not Found or Unsupported. Please check the source system value: ' +
            this.customerSourceSystem
          }
        );
        throw new CalloutException(errorMessge);
      }
    }
    if (response == null || !response.successful) {
      String errorMessge = String.format(
        'Unexpected error from makeCallout - {0} and query mode: {1}.\n {2}',
        new List<Object>{
          this.tableName,
          queryMode,
          response?.error.getMessage()
        }
      );
      throw new CalloutException(errorMessge);
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
    if (String.isBlank(parentId)) {
      return new Map<String, FinServ__FinancialAccountRole__c>();
    }

    List<FinServ__FinancialAccountRole__c> faRoles = externalQueryHelper.retrieveFinancialAccountsByCustomerId(
      new Set<String>{ this.parentId },
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
    if (accountNumberList.isEmpty()) {
      response = new HttpCalloutResponse();
      response.successful = true;
      return response;
    }
    queryParams.accounts.addAll(accountNumberList);
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
    queryParams.capCustomerIds.addAll(getCustomerIds());
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

  private Set<String> getCustomerIds() {
    Set<String> result = new Set<String>();
    Set<String> customerIds = new Set<String>{ this.parentId };
    if (
      //for CCRM users only
      UserInfo.getProfileId() ==
      CommonUtil.getProfileByName(CCRM_USER_PROFILE_NAME).Id
    ) {
      // retrieve the entities related to CLG
      customerIds = getCLGRelatedCustomerIds(this.parentId);
    }
    for (String customerId : customerIds) {
      customerId = customerId != null && customerId.contains('_')
        ? customerId.substringAfter('_')
        : customerId;
      result.add(customerId);
    }
    return result;
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

  protected void getCustomerSource(String externalId) {
    if (String.isBlank(externalId)) {
      return;
    }
    this.customerSourceSystem = externalId.contains('CACHE')
      ? 'CACHE'
      : 'CAP-CIS';
  }
}
