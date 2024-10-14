/**
 * @author Ayushi Gupta
 * @since  06/2023
 * @group Platform
 * @description Account Relationship external query class
 * @runTests DepositAccountExternalQueryTest
 */
public with sharing class AccountRelationshipExternalQuery extends FinancialAccountQueryBase {
  @testVisible
  private Boolean retrieveBySOQLQuery = false;
  @testVisible
  private List<FinServ__FinancialAccountRole__c> relatedCustomers = new List<FinServ__FinancialAccountRole__c>();
  /**
   * @description AccountRelationship Model class
   */

  public class AccountRelationshipModel extends FinancialAccountModelBase {
    public String compositeAccountRelationshipId;
    public String relatedPartyCustomerId;
    public String relationshipType;
  }

  /**
   * @description AccountRelationship callout response
   */
  public class AccountRelationshipCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AccountRelationshipModel> accountRelationships;
  }

  /**
   * @description constructor
   */
  public AccountRelationshipExternalQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ACCOUNT_RELATIONSHIPS';
    this.externalField = 'compositeAccountRelationshipId';
  }

  /**
   * @description update productCategory base on parent / external Id
   */
  private void updateProductCategory() {
    if (String.isNotBlank(this.externalId)) {
      String productCode = this.externalId.subStringAfter('|')
        .subStringAfter(':')
        .subStringBefore('|');
      switch on productCode {
        when 'DDA', 'FM', 'SSI', 'RSV', 'CDA', 'ILS', 'PTF', 'OLL', 'PCA' {
          retrieveBySOQLQuery = true;
        }
        when else {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
          retrieveBySOQLQuery = false;
        }
      }
    } else {
      switch on this.parentField {
        when 'DepositAccount',
          'TermDepositId',
          'LoanAccount',
          'PortfolioOfLoanId',
          'OLLId',
          'CreditCard' {
          retrieveBySOQLQuery = true;
        }
        when else {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
          retrieveBySOQLQuery = false;
        }
      }
    }
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (AccountRelationshipCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AccountRelationshipCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @return QueryMode Enum
   */
  protected override QueryModeEnum prepareCallout(
    DataSource.QueryContext queryContext
  ) {
    this.parentField = getParentName(queryContext.TableSelection);
    return parseFilters(this.parentField, queryContext.TableSelection);
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public override ExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    ExternalObjectQueryBase.QueryModeEnum queryMode = prepareCallout(
      queryContext
    );
    updateProductCategory();
    ExternalObjectQueryBase.ExternalQueryResult queryResult;
    if (!retrieveBySOQLQuery) {
      HttpCalloutResponse response = makeCallout(queryMode, queryContext);
      ExternalObjectCalloutResponse calloutResponse = parseResponse(
        response.body
      );
      queryResult = createExternalRecords(calloutResponse);
    } else {
      String accountKey = String.isNotBlank(this.parentId)
        ? this.parentId.substringBefore('|')
        : this.externalId.substringBefore('|');
      relatedCustomers = getRelatedCustomersOfAccount(
        accountKey,
        this.roleTypes.keySet()
      );
      queryResult = createExternalRecordsBySOQLQuery();
    }
    return queryResult;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource QueryContext
   * @return HttpCalloutResponse
   */
  protected override HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    ARNCService service = new ARNCService();
    HttpCalloutResponse response;

    String payload = getPayload(queryContext);
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
   * @description Transform API response to AccountRelationship records
   *  @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    String customerId;
    String displayUrl;
    Map<String, Object> row;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 0;
    if (calloutResponse == null) {
      return result;
    }

    for (
      AccountRelationshipModel relationship : ((AccountRelationshipCalloutResponse) calloutResponse)
        .accountRelationships
    ) {
      index++;
      customerId = 'CAP-CIS_' + relationship.relatedPartyCustomerId;
      displayUrl =
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        relationship.compositeAccountRelationshipId;
      row = new Map<String, Object>{
        'Sequence' => getSequence(index),
        'ExternalId' => relationship.compositeAccountRelationshipId,
        'DisplayUrl' => displayUrl,
        'Customer' => customerId,
        'Relationship' => relationship.relationshipType
      };
      row.put(this.parentField, this.parentId);
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description Transform SOQL response to AccountRelationship records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecordsBySOQLQuery() {
    String externalId;
    String displayUrl;
    Map<String, Object> row;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 0;

    for (FinServ__FinancialAccountRole__c faRole : relatedCustomers) {
      externalId =
        faRole.FinServ__FinancialAccount__r.Account_Key__c +
        '|' +
        faRole.FinServ__FinancialAccount__r.Product_Type__c +
        '|' +
        faRole.FinServ__RelatedAccount__r.External_Id__c;
      displayUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + externalId;
      index++;

      row = new Map<String, Object>{
        'Sequence' => getSequence(index),
        'ExternalId' => externalId,
        'DisplayUrl' => displayUrl,
        'Customer' => faRole.FinServ__RelatedAccount__r.External_Id__c,
        'Relationship' => this.roleTypes.get(faRole.Role_Type__c)
      };
      row.put(this.parentField, this.parentId);
      result.externalRecords.add(row);
    }
    return result;
  }

  @testVisible
  private String getSequence(Integer index) {
    switch on String.valueOf(index).length() {
      when 1 {
        return '000' + index;
      }
      when 2 {
        return '00' + index;
      }
      when 3 {
        return '0' + index;
      }
      when else {
        return String.valueOf(index);
      }
    }
  }
}
