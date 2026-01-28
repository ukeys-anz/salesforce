/**
 * @author Ian Huang
 * @since  06/2025
 * @group Platform
 * @description CAP Financial Account external query base class
 */
public abstract with sharing class CAPFinancialAccountQueryBase extends ExternalObjectQueryBase {
  protected String productCategory = '';
  protected Set<String> accountNumbers = new Set<String>();
  protected Set<String> productTypes = new Set<String>();
  @TestVisible
  protected Map<String, FinServ__FinancialAccountRole__c> accountRoleMap;
  @TestVisible
  protected Boolean useProductCodeFromFinancialAccount = false;
  protected SourceSystemEnum sourceSystem;
  protected String fieldSet;
  protected String assetFinanceType;
  protected String accountNumber;

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

  /**
   * @description abstract CAP FinancialAccount Summary callout response class
   */
  public virtual class CAPFinancialAccountCalloutRequest extends ExternalObjectQueryBase.ExternalObjectCalloutRequestBase {
    public String productCategory;
    public QueryModeEnum queryMode;
    /**
     * @description abstract FinancialAccount callout response class
     * @param queryContext DataSource QueryContext
     * @param queryMode Query Mode Enum
     * @param productCategory productCategory
     * @param fieldSet fieldSet
     * @param accounts accounts
     */
    public CAPFinancialAccountCalloutRequest(
      DataSource.QueryContext queryContext,
      QueryModeEnum queryMode,
      String productCategory,
      String fieldSet,
      Set<String> accounts
    ) {
      super(queryContext, queryMode);
      this.productCategory = productCategory;
      this.payload = new FinancialAccountEntities.FinancialAccountPayload();

      if (this.isSummaryRequest()) {
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .offSet = String.valueOf(queryContext.offSet);
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .pageSize = String.valueOf(queryContext.maxResults);
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .fieldSet = fieldSet;
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .accounts = accounts;
      } else if (!accounts.isEmpty()) {
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .accountNumber = new List<String>(accounts).get(0);
      }
    }
    public override String getEndpoint() {
      String host = Label.Financial_Account_Endpoint;
      if (this.isSummaryRequest()) {
        return host + 'summaries';
      } else {
        return host + this.productCategory + '-accounts';
      }
    }
  }

  /**
   * @description Class constractor
   */
  public CAPFinancialAccountQueryBase() {
    this.externalField = 'accountNumber';
    this.parentField = 'CustomerId';
  }

  /**
   * @description Main execute method - the orchestration layer
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public virtual override ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.tableName = queryContext.TableSelection.tableSelected;
    ExternalObjectCalloutRequestBase calloutRequest = prepareCallout(
      queryContext,
      queryContext.TableSelection
    );
    ExternalObjectCalloutResponse calloutResponse;
    if (!this.accountNumbers.isEmpty()) {
      HttpCalloutResponse response = makeCallout(calloutRequest);
      calloutResponse = parseResponse(response.body);
    }

    return createExternalRecords(calloutResponse);
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @param tableSelection DataSource.TableSelection
   * @return ExternalObjectCalloutRequestBase Callout Request
   */
  protected virtual override ExternalObjectCalloutRequestBase prepareCallout(
    DataSource.QueryContext queryContext,
    DataSource.TableSelection tableSelection
  ) {
    super.prepareCallout(queryContext, queryContext.TableSelection);
    this.accountNumbers = getAccountNumbers(
      queryContext,
      this.queryMode,
      this.parentId,
      this.externalId
    );
    CAPFinancialAccountCalloutRequest calloutRequest = new CAPFinancialAccountCalloutRequest(
      queryContext,
      this.queryMode,
      this.productCategory,
      this.fieldSet,
      this.accountNumbers
    );
    return calloutRequest;
  }

  /**
   * @description get accounts numbers reated to customer
   * @param queryContext DataSource.QueryContext
   * @param queryMode QueryModeEnum
   * @param parentId parent Id
   * @param externalId external Id
   * @return Set<String> set of account numbers
   */
  protected Set<String> getAccountNumbers(
    DataSource.QueryContext queryContext,
    QueryModeEnum queryMode,
    String parentId,
    String externalId
  ) {
    //retrieve financial accounts based on query mode
    List<FinServ__FinancialAccountRole__c> faRoles;
    if (queryMode == QueryModeEnum.RELATED_LIST) {
      faRoles = getRelatedFinancialAccounts(parentId);
    } else {
      faRoles = getFinancialAccountDetail(externalId);
    }

    this.accountRoleMap = getFinancialAccountRoleMap(faRoles);
    this.accountNumbers = getAccountNumberSet(faRoles);

    //prepare account numbers for callout
    this.accountNumbers = getCurrentBatchExternalIds(
      queryContext,
      this.accountNumbers
    );

    return this.accountNumbers;
  }

  /**
   * @description Populates Data
   * @param faRoles far list
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @testVisible
  private Map<String, FinServ__FinancialAccountRole__c> getFinancialAccountRoleMap(
    List<FinServ__FinancialAccountRole__c> faRoles
  ) {
    Map<String, FinServ__FinancialAccountRole__c> result = new Map<String, FinServ__FinancialAccountRole__c>();
    for (FinServ__FinancialAccountRole__c faRole : faRoles) {
      result.put(
        faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        faRole
      );
    }
    return result;
  }

  /**
   * @description Populates Data
   * @param faRoles far list
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @testVisible
  private Set<String> getAccountNumberSet(
    List<FinServ__FinancialAccountRole__c> faRoles
  ) {
    Set<String> result = new Set<String>();
    for (FinServ__FinancialAccountRole__c faRole : faRoles) {
      result.add(
        faRole.FinServ__FinancialAccount__r.Product_Type__c.right(3)
            .remove(':') +
          '-' +
          faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      );
    }
    return result;
  }

  /**
   * @description returns list of external identifiers for current page/batch
   *              base on page size and offset
   * @param queryContext DataSource.QueryContext
   * @param externalIds list of external Ids
   * @return Set<String>
   */
  private Set<String> getCurrentBatchExternalIds(
    DataSource.QueryContext queryContext,
    Set<String> externalIds
  ) {
    Set<String> result = new Set<String>();

    List<String> externalIdList = new List<String>(externalIds);
    externalIdList.sort();
    if (externalIdList.size() >= queryContext.offset) {
      Integer endPosition = externalIdList.size() <=
        queryContext.offset + queryContext.maxResults
        ? externalIdList.size()
        : queryContext.offset + queryContext.maxResults;
      for (Integer i = queryContext.offset; i < endPosition; i++) {
        result.add(externalIdList[i]);
      }
    }
    return result;
  }

  /**
   * @description Get related Financial accounts
   * @param parentId parent customer Id
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @TestVisible
  private List<FinServ__FinancialAccountRole__c> getRelatedFinancialAccounts(
    String parentId
  ) {
    if (String.isBlank(parentId)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    List<FinServ__FinancialAccountRole__c> faRoles = FinancialAccountQueryHelper.retrieveFinancialAccountsByCustomerId(
      new Set<String>{ this.parentId },
      productTypes,
      roleTypes
    );
    return faRoles;
  }

  /**
   * @description Get Financial account detail
   * @param externalId account external Id
   * @return Map<String, FinServ__FinancialAccountRole__c>
   **/
  @TestVisible
  private List<FinServ__FinancialAccountRole__c> getFinancialAccountDetail(
    String externalId
  ) {
    if (String.isBlank(externalId)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    List<FinServ__FinancialAccountRole__c> faRoles = FinancialAccountQueryHelper.retrieveFinancialAccountByAccountNumber(
      externalId
    );
    return faRoles;
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
    String productCode = FinancialAccountQueryHelper.getProductCode(
      finAccount,
      this.useProductCodeFromFinancialAccount,
      accountRoleMap
    );
    return FinancialAccountQueryHelper.getAccountKey(
      finAccount.accountNumber,
      productCode,
      accountRoleMap
    );
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
}
