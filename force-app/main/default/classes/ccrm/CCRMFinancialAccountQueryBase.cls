/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Financial Account external query base class
 * @runTests CCRMDepositAccountQueryTest
 */
@SuppressWarnings(
  'PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount,PMD.ExcessiveClassLength'
)
public abstract with sharing class CCRMFinancialAccountQueryBase extends CCRMExternalObjectQueryBase {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMFinancialAccountQueryBaseRepository FA_REPOSITORY = (CCRMFinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    CCRMFinancialAccountQueryBaseRepository.class
  );
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
  @testVisible
  protected FinancialAccountCalloutResponse calloutResponse;
  protected Boolean useProductCodeFromFinancialAccount = false;
  protected Boolean retrieveBySOQLQuery = false;
  protected List<FinServ__FinancialAccountRole__c> relatedCustomers;
  private static final String ML_USER_PROFILE_NAME = 'ANZ ML Standard User';
  /**
   * @description Constractor
   */
  public CCRMFinancialAccountQueryBase() {
    this.accountNumberList = new List<String>();
    this.accountRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
    this.parent = 'CustomerId';
    this.relatedCustomers = new List<FinServ__FinancialAccountRole__c>();
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

    if (this.productCategory != 'transactions') {
      setNextPageId(queryResult.queryMoreToken);
    }

    return queryResult;
  }

  /**
   * @description Parse query filters and prepare for API callout
   */
  protected virtual override void prepareCallout() {
    getParent();
    parseFilters(this.parent);
    if (this.sourceSystem != SourceSystemEnum.CAP) {
      return;
    }

    getFinancialAccountsWhenParentIdIsNotBlank();
    getFinancialAccountsWhenExternalIdIsNotBlank();
    //prepare account numbers for callout
    getCurrentBatchAccountNumbers();

    if (accountRoleMap.keySet().isEmpty()) {
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
  }

  private void getFinancialAccountsWhenParentIdIsNotBlank() {
    List<FinServ__FinancialAccountRole__c> faRoles;
    Set<String> customerIds = new Set<String>();
    if (String.isBlank(this.parentId)) {
      return;
    }
    if (
      UserInfo.getProfileId() !=
      CommonUtil.getProfileByName(ML_USER_PROFILE_NAME).Id
    ) {
      customerIds = getCLGRelatedCustomerIds(this.parentId);
    } else {
      customerIds.add(this.parentId);
    }
    faRoles = retrieveFinancialAccountsByCustomerId(customerIds);
    populateData(faRoles);
  }

  private void getFinancialAccountsWhenExternalIdIsNotBlank() {
    List<FinServ__FinancialAccountRole__c> faRoles;
    if (String.isBlank(this.externalId)) {
      return;
    }
    faRoles = retrieveFinancialAccountByAccountNumber(this.externalId);
    populateData(faRoles);
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
   * @description virtual Transform SOQL response to financial account records
   * @return List<Map<String, Object>>
   */
  protected virtual CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccountsViaSOQL() {
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
   * @description get source system status
   * @param accountNumber Account Number
   * @return Source System Status
   */
  @testVisible
  protected String getSourceSystemStatus(String accountNumber) {
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
   * @description get financial account status
   * @param accountNumber Account Number
   * @return account status
   */
  @testVisible
  protected String getFinStatus(String accountNumber) {
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
   * @description get product name
   * @param accountNumber Account Number
   * @return product name
   */
  @testVisible
  protected String getProductName(String accountNumber) {
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
   * @description get product code
   * @param accountNumber Account Number
   * @return product code
   */
  @testVisible
  protected String getProductCode(String accountNumber) {
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
   * @description get Account Number with Format
   * @param accountNumber Account Number
   * @return Account Number with Format
   */
  @testVisible
  protected String getAccountNumberwithFormat(String accountNumber) {
    String result = '';
    if (
      accountRoleMap.containsKey(accountNumber) &&
      String.isNotEmpty(
        accountRoleMap.get(accountNumber)
          .FinServ__FinancialAccount__r.Account_Number__c
      )
    ) {
      result = accountRoleMap.get(accountNumber)
        .FinServ__FinancialAccount__r.Account_Number__c;
    }
    return result;
  }

  /**
   * @description Retrieves formatted financial account numbers related to a customer for Financial Account Numbers
   * @param accountNumbers List of account numbers
   * @return Map of account numbers to formatted Financial Account Numbers
   */
  @testVisible
  protected Map<String, String> getformattedFinancialAccountNumbers(
    List<String> accountNumbers
  ) {
    Map<String, String> formattedAccountNumbers = new Map<String, String>();
    List<FinServ__FinancialAccount__c> faAccnts = FA_Repository.getformattedFinancialAccounts(
      accountNumbers
    );

    if (faAccnts == null) {
      return formattedAccountNumbers;
    }

    for (FinServ__FinancialAccount__c fa : faAccnts) {
      formattedAccountNumbers.put(
        fa.FinServ__FinancialAccountNumber__c,
        fa.Account_Number__c
      );
    }
    return formattedAccountNumbers;
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
   * @return List<FinServ__FinancialAccountRole__c>
   */
  private List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountsByCustomerId(
    Set<String> customerIds
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = FA_REPOSITORY.getFinancialAccountsWithCustomerId(
      customerIds,
      ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME,
      productTypes,
      roleTypes
    );
    return faRoles;
  }

  @testVisible
  private void populateData(List<FinServ__FinancialAccountRole__c> faRoles) {
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
   *  @return List<FinServ__FinancialAccountRole__c>
   */
  private List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountByAccountNumber(
    String externalId
  ) {
    String accountKey = this.externalId.contains('|')
      ? externalId.left(this.externalId.indexOf('|'))
      : '';
    List<FinServ__FinancialAccountRole__c> faRoles = FA_REPOSITORY.getFinancialAccountsWithAcctNum(
      accountKey
    );
    return faRoles;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout() {
    CCRMARNCService.FinancialAccountQueryParameters queryParams = new CCRMARNCService.FinancialAccountQueryParameters();

    HttpCalloutResponse response;
    String payload = getPayload();

    response = getCAPSummaryAccounts(payload, queryParams);
    response = getEBDSummaryAccounts(payload, queryParams, response);
    response = getDetailAccounts(payload, response);

    if (response == null) {
      Logger.error('Invalid query source system: ' + this.sourceSystem);
      Logger.saveLog();
      throw new TypeException(
        'Invalid query source system: ' + this.sourceSystem
      );
    }
    return response;
  }

  protected String getPayload() {
    String payload;
    payload = getPayloadForSingleAccount(payload);
    payload = getPayloadForCAPChildAccounts(payload);
    payload = getPayloadForCAPChildAccountsWithAssetFinanceType(payload);
    payload = getPayloadForEBDChildAccountsWithAssetFinanceType(payload);
    payload = getPayloadForGuaranteeFeeSummaryAccounts(payload);
    payload = getPayloadForEBDChildAccounts(payload);
    return payload;
  }

  @testVisible
  private String getPayloadForSingleAccount(String payload) {
    //Account detail view
    if (isQuerySingleAccount()) {
      String accountNumber = this.externalId.right(
        this.externalId.length() - this.externalId.indexOf('|') - 1
      );
      payload = '{"' + this.externalField + '": "' + accountNumber + '"';
      payload += String.isNotBlank(this.assetFinanceType)
        ? ',"type":"' + this.assetFinanceType + '"}'
        : '}';
    }
    return payload;
  }

  @testVisible
  private String getPayloadForCAPChildAccounts(String payload) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Child summary view
    if (isQueryCAPChildAccounts()) {
      String accountNumber = this.parentId.right(
        this.parentId.length() - this.parentId.indexOf('|') - 1
      );
      payload =
        '{"accountNumber": "' +
        accountNumber +
        '"' +
        ',"pageSize":"' +
        String.valueOf(this.queryContext?.maxResults) +
        '"' +
        ',"offSet":"' +
        String.valueOf(this.queryContext?.offSet) +
        '"';
      payload += String.isNotBlank(this.fieldSet)
        ? ',"fieldSet": "' + this.fieldSet + '"}'
        : (this.productCategory != 'transactions'
            ? ',"nextPageId": "' + getNextPageId() + '"}'
            : '}');
    }
    return payload;
  }

  @testVisible
  private String getPayloadForCAPChildAccountsWithAssetFinanceType(
    String payload
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Child accounts summary having EBD as parent
    if (isQueryCAPChildAccountsWithAssetFinanceType()) {
      payload = '{"compositeAccountNumber": "' + this.parentId + '"';
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
    }
    return payload;
  }

  @testVisible
  private String getPayloadForEBDChildAccountsWithAssetFinanceType(
    String payload
  ) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //child EBD accounts summary view having EBD as parent
    if (isQueryEBDChildAccountsWithAssetFinanceType()) {
      payload = '{"compositeAssetId": "' + this.parentId + '"';
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
    }
    return payload;
  }

  @testVisible
  private String getPayloadForGuaranteeFeeSummaryAccounts(String payload) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //Guarantee Fee Summary
    if (isQueryGuaranteeFeeSummaryAccounts()) {
      payload = '{"compositeGuaranteesId": "' + this.parentId + '"';
      payload += String.isNotBlank(this.fieldSet)
        ? ',"fieldSet": "' + this.fieldSet + '"}'
        : '}';
    }
    return payload;
  }

  @testVisible
  private String getPayloadForEBDChildAccounts(String payload) {
    if (String.isNotBlank(payload)) {
      return payload;
    }
    //EBD accounts child summary view
    if (isQueryEBDChildAccounts()) {
      payload = '{"compositeAccountNumber": "' + this.parentId + '"';
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
    }
    return payload;
  }

  private Boolean isQuerySingleAccount() {
    return String.isNotEmpty(this.externalId);
  }

  private Boolean isQueryCAPChildAccounts() {
    return String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isBlank(this.assetFinanceType);
  }

  private Boolean isQueryCAPChildAccountsWithAssetFinanceType() {
    return String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isNotBlank(this.assetFinanceType);
  }

  private Boolean isQueryEBDChildAccountsWithAssetFinanceType() {
    return String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD &&
      String.isNotBlank(this.assetFinanceType);
  }

  private Boolean isQueryCAPSummaryViewAccounts() {
    return this.sourceSystem == SourceSystemEnum.CAP;
  }

  private Boolean isQueryEBDSummaryViewAccounts() {
    return this.parent == 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  private Boolean isQueryGuaranteeFeeSummaryAccounts() {
    return String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      (this.parent == 'ActiveGuaranteeId' ||
      this.parent == 'InactiveGuaranteeId') &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  private Boolean isQueryEBDChildAccounts() {
    return String.isNotEmpty(this.parentId) &&
      this.parent != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  //CAP accounts summary view
  @testVisible
  private HttpCalloutResponse getCAPSummaryAccounts(
    String payload,
    CCRMARNCService.FinancialAccountQueryParameters queryParams
  ) {
    HttpCalloutResponse response;
    CCRMARNCService service = new CCRMARNCService();
    if (!(isQueryCAPSummaryViewAccounts() && String.isBlank(payload))) {
      return response;
    }

    for (Integer i = 0; i < accountNumberList.size(); i++) {
      queryParams.accounts.add(accountNumberList[i]);
    }
    response = service.queryCAPAccounts(this.productCategory, queryParams);

    return response;
  }

  //EBD accounts summary view
  @testVisible
  private HttpCalloutResponse getEBDSummaryAccounts(
    String payload,
    CCRMARNCService.FinancialAccountQueryParameters queryParams,
    HttpCalloutResponse response
  ) {
    CCRMARNCService service = new CCRMARNCService();
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
    queryParams.pageSize = String.valueOf(this.queryContext?.maxResults);
    queryParams.nextPageId = getNextPageId();

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

  @testVisible
  private HttpCalloutResponse getDetailAccounts(
    String payload,
    HttpCalloutResponse response
  ) {
    CCRMARNCService service = new CCRMARNCService();
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
  protected String getNextPageId() {
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
  protected void setNextPageId(String queryMoreToken) {
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
  /**
   * @description get related customers of a particular account
   * @param  accountKey Account Key
   * @param roleTypes role types
   * @return List< FinServ_FinancialAccountRole__c>
   */
  @testVisible
  protected List<FinServ__FinancialAccountRole__c> getRelatedCustomersOfAccount(
    String accountKey,
    Set<String> roleTypes
  ) {
    relatedCustomers = FA_Repository.getRelatedCustomers(accountKey, roleTypes);
    return relatedCustomers;
  }
  /**
   * @description calles execute method of class CCRMExternalObjectQueryBase
   * @param queryContext query context
   */
  protected void callExecuteOfQueryBase(DataSource.QueryContext queryContext) {
    super.execute(queryContext);
  }
  /**
   * @description get industry code and discription
   * @param  industryCode
   * @return String industryCode plus discription
   */
  @testVisible
  protected String retrieveIndustryCodeAndDescription(String industryCode) {
    if (industryCode == '0000' || String.isBlank(industryCode)) {
      return '';
    }
    List<Industry__c> listOfindustry = FA_Repository.getIndustryCodeAndDescription(
      industryCode
    );
    if (listOfindustry == null || listOfindustry.isEmpty()) {
      return industryCode;
    }
    return listOfindustry[0].Code__c + ' - ' + listOfindustry[0].Name;
  }

  /**
   * @description Format Account Number
   * @param accountNumber Account Number
   * @return String formatted Account Number
   */
  @testvisible
  protected String formatAccountNumber(String accountNumber) {
    if (String.isBlank(accountNumber)) {
      return '';
    }
    switch on accountNumber.length() {
      when 8 {
        accountNumber = '0' + accountNumber;
        return String.format(
          '{0}-{1}',
          new List<String>{
            accountNumber.subString(0, 4),
            accountNumber.subString(4, 9)
          }
        );
      }
      when 9 {
        return String.format(
          '{0}-{1}',
          new List<String>{
            accountNumber.subString(0, 4),
            accountNumber.subString(4, 9)
          }
        );
      }
      when 11 {
        return String.format(
          '{0}-{1}-{2}',
          new List<String>{
            accountNumber.subString(0, 4),
            accountNumber.subString(4, 7),
            accountNumber.subString(7, 11)
          }
        );
      }
      when 16 {
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
      when else {
        return accountNumber;
      }
    }
  }
}
