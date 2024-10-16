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
    this.accountNumberList = getCurrentBatchAccountNumbers(
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
    if (queryMode == QueryModeEnum.RELATED_LIST) {
      response = getCAPSummaryAccounts(service, queryParams, payload);
      response = getEBDSummaryAccounts(
        service,
        queryParams,
        payload,
        response,
        queryContext
      );
    } else if (queryMode == QueryModeEnum.RECORD_DETAIL) {
      response = getDetailAccounts(service, payload, response);
    }

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
    row.put('AccountNumber', formatAccountNumber(getAccountNumber(externalId)));
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
    if (UserInfo.getProfileId() != QueryProfile.get(ML_USER_PROFILE_NAME).Id) {
      customerIds = getCLGRelatedCustomerIds(this.parentId);
    } else {
      customerIds.add(this.parentId);
    }
    faRoles = retrieveFinancialAccountsByCustomerId(customerIds);
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
    faRoles = retrieveFinancialAccountByAccountNumber(externalId);
    return populateData(faRoles);
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
      this.accountRoleMap.containsKey(accountNumber) &&
      this.accountRoleMap.get(accountNumber).FinServ__RelatedAccount__r != null
    ) {
      result = this.accountRoleMap.get(accountNumber)
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
   * @param accountRoleMap FinancialAccountRole map
   * @return String Account_key__c
   */
  @testVisible
  protected String getAccountKey(
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
   * @description Retrieves list of financial accounts related to a customer via
   *                        financial account role relationship (FAR)
   * @param customerIds the customer external Ids
   * @return List<FinServ__FinancialAccountRole__c>
   */
  private List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountsByCustomerId(
    Set<String> customerIds
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

  /* @description returns list of finanicial account numbers for current page/batch
   *              base on page size & offset
   * @param queryContext DataSource.QueryContext
   * @return List<String>
   */
  private List<String> getCurrentBatchAccountNumbers(
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
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param externalId Financial account external id
   * @return List<FinServ__FinancialAccountRole__c>
   */
  private List<FinServ__FinancialAccountRole__c> retrieveFinancialAccountByAccountNumber(
    String externalId
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = new List<FinServ__FinancialAccountRole__c>();

    String accountKey = this.externalId.contains('|')
      ? externalId.left(this.externalId.indexOf('|'))
      : '';
    if (String.isBlank(accountKey)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (PermissionUtils.canQuery('FinServ__FinancialAccount__c')) {
      faRoles = FA_REPOSITORY.getFinancialAccountsWithAcctNum(accountKey);
    }
    return faRoles;
  }

  protected String getPayload(DataSource.QueryContext queryContext) {
    String payload;
    payload = getPayloadForSingleAccount(payload);
    payload = getPayloadForCAPChildAccounts(payload, queryContext);
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
  private String getPayloadForCAPChildAccounts(
    String payload,
    DataSource.QueryContext queryContext
  ) {
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
        String.valueOf(queryContext?.maxResults) +
        '"';

      payload += (this.productCategory == 'transactions')
        ? ',"offSet":"' + String.valueOf(queryContext?.offSet) + '"'
        : '';
      payload += String.isNotBlank(this.fieldSet)
        ? ',"fieldSet": "' + this.fieldSet + '"}'
        : null;
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
      this.parentField != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isBlank(this.assetFinanceType);
  }

  private Boolean isQueryCAPChildAccountsWithAssetFinanceType() {
    return String.isNotEmpty(this.parentId) &&
      this.parentField != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.CAP &&
      String.isNotBlank(this.assetFinanceType);
  }

  private Boolean isQueryEBDChildAccountsWithAssetFinanceType() {
    return String.isNotEmpty(this.parentId) &&
      this.parentField != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD &&
      String.isNotBlank(this.assetFinanceType);
  }

  private Boolean isQueryCAPSummaryViewAccounts() {
    return this.sourceSystem == SourceSystemEnum.CAP;
  }

  private Boolean isQueryEBDSummaryViewAccounts() {
    return this.parentField == 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  private Boolean isQueryGuaranteeFeeSummaryAccounts() {
    return String.isNotEmpty(this.parentId) &&
      this.parentField != 'CustomerId' &&
      (this.parentField == 'ActiveGuaranteeId' ||
      this.parentField == 'InactiveGuaranteeId') &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  private Boolean isQueryEBDChildAccounts() {
    return String.isNotEmpty(this.parentId) &&
      this.parentField != 'CustomerId' &&
      this.sourceSystem == SourceSystemEnum.EBD;
  }

  //CAP accounts summary view
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

  //EBD accounts summary view
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
    //queryParams.nextPageId = getNextPageId();

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
   * @param finAccount Financial account record
   * @param accountRoleMap FinancialAccountRole map
   * @return String External Id
   */
  @testVisible
  protected String getExternalId(
    FinancialAccountModelBase finAccount,
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap
  ) {
    String productCode = getProductCode(finAccount);
    return getAccountKey(finAccount.accountNumber, productCode, accountRoleMap);
  }

  /**
   * @description get product code
   * @param  finAccount Financial account record
   * @return String External Id
   */
  @testVisible
  private String getProductCode(FinancialAccountModelBase finAccount) {
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
  protected virtual String getDisplayUrl(FinancialAccountModelBase finAccount) {
    return URL.getOrgDomainUrl().toExternalForm() +
      '/' +
      finAccount.productCode +
      '-' +
      finAccount.accountNumber;
  }

  /**
   * @description parse account number from external Id
   * @param  externalId
   * @return String account number
   */
  protected String getAccountNumber(String externalId) {
    String accountNumber = externalId.substringBefore('|');
    accountNumber = accountNumber.substringAfter('-');
    return accountNumber;
  }

  /**
   * @description get related customers of a particular account
   * @param accountKey Unique financial account key
   * @param roleTypes role types
   * @return List< FinServ_FinancialAccountRole__c>
   */
  @testVisible
  protected List<FinServ__FinancialAccountRole__c> getRelatedCustomersOfAccount(
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
   * @description get industry code and discription
   * @param  industryCode
   * @return String industryCode plus discription
   */
  @testVisible
  protected String retrieveIndustryCodeAndDescription(String industryCode) {
    if (industryCode == '0000' || String.isBlank(industryCode)) {
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
   * @description Retrieves formatted financial account numbers related to a customer for Financial Account Numbers
   * @param accountNumbers List of account numbers
   * @return Map<String, String> of account numbers to formatted Financial Account Numbers
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
}
