/**
 * @author Ian Huang
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description AccountRelationship external query class
 * @runTests CCRMAccountRelationshipQueryTest
 */
public with sharing class CCRMAccountRelationshipQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description AccountRelationship Model class
   */
  public class AccountRelationshipModel extends CCRMFinancialAccountModelBase {
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
  public CCRMAccountRelationshipQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ACCOUNT_RELATIONSHIPS';
    this.externalField = 'compositeAccountRelationshipId';
  }

  /**
   * @description Parse query filters and prepare for API callout
   */
  protected virtual override void prepareCallout() {
    this.getParent();
    this.parseFilters(this.parent);
    updateProductCategory();
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
          this.retrieveBySOQLQuery = true;
        }
        when else {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
          this.retrieveBySOQLQuery = false;
        }
      }
    } else {
      switch on this.parent {
        when 'DepositAccount',
          'TermDepositId',
          'LoanAccount',
          'PortfolioOfLoanId',
          'OLLId',
          'CreditCard' {
          this.retrieveBySOQLQuery = true;
        }
        when else {
          this.productCategory = 'asset-finance';
          this.assetFinanceType = 'AMBIT';
          this.retrieveBySOQLQuery = false;
        }
      }
    }
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (AccountRelationshipCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AccountRelationshipCalloutResponse.class
    );
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public override CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.tableSelection = queryContext.TableSelection;
    prepareCallout();
    CCRMExternalObjectQueryBase.ExternalQueryResult queryResult;
    if (!this.retrieveBySOQLQuery) {
      HttpCalloutResponse response = makeCallout();
      parseResponse(response.body);
      queryResult = createFinancialAccounts();
    } else {
      String accountKey = String.isNotBlank(this.parentId)
        ? this.parentId.substringBefore('|')
        : this.externalId.substringBefore('|');
      relatedCustomers = getRelatedCustomersOfAccount(
        accountKey,
        this.roleTypes.keySet()
      );
      queryResult = createFinancialAccountsViaSOQL();
    }
    setNextPageId(queryResult.queryMoreToken);
    return queryResult;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @return HttpCalloutResponse
   */
  protected override HttpCalloutResponse makeCallout() {
    CCRMARNCService service = new CCRMARNCService();

    HttpCalloutResponse response;
    if (String.isNotEmpty(this.externalId)) {
      String accountNumber = this.externalId.right(
        this.externalId.length() - this.externalId.indexOf('|') - 1
      );
      String payload = '{"' + this.externalField + '": "' + accountNumber + '"';
      payload += String.isNotBlank(this.assetFinanceType)
        ? ',"type":"' + this.assetFinanceType + '"}'
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
   * @description Transform API response to AccountRelationship records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 0;

    for (
      AccountRelationshipModel relationship : ((AccountRelationshipCalloutResponse) this.calloutResponse)
        .accountRelationships
    ) {
      row = new Map<String, Object>();
      index++;
      row.put('Sequence', getSequence(index));
      row.put('ExternalId', relationship.compositeAccountRelationshipId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          relationship.compositeAccountRelationshipId
      );
      row.put(this.parent, this.parentId);
      row.put('Customer', 'CAP-CIS_' + relationship.relatedPartyCustomerId);
      row.put('Relationship', relationship.relationshipType);
      result.queryResult.add(row);
    }
    return result;
  }

  /**
   * @description Transform SOQL response to AccountRelationship records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccountsViaSOQL() {
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Integer index = 0;

    for (FinServ__FinancialAccountRole__c faRole : this.relatedCustomers) {
      row = new Map<String, Object>();
      index++;
      row.put('Sequence', getSequence(index));
      row.put(
        'ExternalId',
        faRole.FinServ__FinancialAccount__r.Account_Key__c +
          '|' +
          faRole.FinServ__FinancialAccount__r.Product_Type__c +
          '|' +
          faRole.FinServ__RelatedAccount__r.External_Id__c
      );
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          faRole.FinServ__FinancialAccount__r.Account_Key__c +
          '|' +
          faRole.FinServ__FinancialAccount__r.Product_Type__c +
          '|' +
          faRole.FinServ__RelatedAccount__r.External_Id__c
      );
      row.put(this.parent, this.parentId);
      row.put('Customer', faRole.FinServ__RelatedAccount__r.External_Id__c);
      row.put('Relationship', this.roleTypes.get(faRole.Role_Type__c));
      result.queryResult.add(row);
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
