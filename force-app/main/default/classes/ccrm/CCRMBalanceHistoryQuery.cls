/**
 * @author Ian Huang
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Balance History external query class
 */
public with sharing class CCRMBalanceHistoryQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description BalanceHistory Model class
   */
  public class BalanceHistoryModel extends CCRMFinancialAccountModelBase {
    public String compositeBalanceHistoryId;
    public String balancePeriod;
    public String month;
    public String year;
    public Decimal avgBalance;
    public Decimal maxBalance;
    public Decimal minBalance;
    public Integer excessDays;
    public String returnedItems;
    public Integer excessItems;
    public Integer excessTimes;
  }

  /**
   * @description BalanceHistory callout response
   */
  public class BalanceHistoryCalloutResponse extends FinancialAccountCalloutResponse {
    public List<BalanceHistoryModel> balanceHistory;
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public virtual override CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult queryResult = new CCRMFinancialAccountQueryBase.ExternalQueryResult();
    super.callExecuteOfQueryBase(queryContext);
    prepareCallout();

    // Display Dummay FA Detail Record
    if (displayDummyAccountDetails(this.externalId, this.parentId)) {
      queryResult = createDummyFinancialAccountDetail(this.externalId);
      return queryResult;
    }
    // Display Dummy/Empty FA List on related section of FM/RSV/SSI
    if (
      isDepositProductCategory(this.productCategory) &&
      displayDummyRecord(this.parentId)
    ) {
      queryResult = createDummyFinancialAccounts(this.parentId);
      return queryResult;
    }
    HttpCalloutResponse response = makeCallout();
    parseResponse(response.body);
    queryResult = createFinancialAccounts();
    return queryResult;
  }

  /**
   * @description constructor
   */
  public CCRMBalanceHistoryQuery() {
    this.productCategory = 'deposit';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'BALANCE_HISTORY';
    this.parent = 'DepositAccount';
    this.externalField = 'compositeBalanceHistoryId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  @TestVisible
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (BalanceHistoryCalloutResponse) CalloutModel.deserialize(
      responseBody,
      BalanceHistoryCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to BalanceHistory records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @TestVisible
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      BalanceHistoryModel bal : ((BalanceHistoryCalloutResponse) this.calloutResponse)
        .balanceHistory
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', bal.compositeBalanceHistoryId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          bal.compositeBalanceHistoryId
      );
      row.put('DepositAccount', this.parentId);
      row.put('BalancePeriod', bal.year + '-' + bal.month);
      row.put('Year', bal.year);
      row.put('Month', bal.month);
      row.put('AverageBalance', bal.avgBalance);
      row.put('MaximumBalance', bal.maxBalance);
      row.put('MinimumBalance', bal.minBalance);
      row.put('DaysInExcess', bal.excessDays);
      row.put('ReturnedItems', bal.returnedItems);
      row.put('ItemsInExcess', bal.excessItems);
      row.put('Times In Excess', bal.excessTimes);
      result.queryResult.add(row);
    }
    return result;
  }

  /**
   * @description Return empty query history while calling from FM/SSI DDA's related tab
   * @param externalId
   * @return empty queryResult
   **/
  @TestVisible
  private static CCRMExternalObjectQueryBase.ExternalQueryResult createDummyFinancialAccounts(
    String externalId
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    return result;
  }

  /**
   * @description checks if Account is FM or SSI or RSV.
   * @param payload payload created for Callout. Ex - {"accountNumber": "FM-111269467"},  {"compositeBalanceHistoryId": "DDA-234500817-0"}
   * @return boolean true/false
   */
  @TestVisible
  private static Boolean displayDummyRecord(String payload) {
    return (payload != null &&
    (payload.contains('FM-') ||
    payload.contains('SSI-') ||
    payload.contains('RSV-')));
  }

  /**
   * @description checks if Account is Deposit Account
   * @param productCategory FA name like Deposit, Loan, etc
   * @return boolean true/false
   */
  @TestVisible
  private static Boolean isDepositProductCategory(String productCategory) {
    return productCategory == 'deposit';
  }

  /**
   * @description Return true if detail section is requested
   * @param externalId externalId value. If true means detail page is showing
   * @param parentId parentId value. If true means list view page is showing
   * @return boolean true/false
   */
  @TestVisible
  private static Boolean displayDummyAccountDetails(
    String externalId,
    String parentId
  ) {
    return !String.isEmpty(externalId) && String.isEmpty(parentId);
  }

  /**
   * @description Create Dummy FA record
   * @param externalId Format - 'DDA-210568745-2'
   * @return dummy FA record
   **/
  @TestVisible
  private CCRMExternalObjectQueryBase.ExternalQueryResult createDummyFinancialAccountDetail(
    String externalId
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>{
      'ExternalId' => externalId,
      'AdditionalInformation' => 'No further information available'
    };
    result.queryResult.add(row);
    return result;
  }
}
