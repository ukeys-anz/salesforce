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
  }

  /**
   * @description BalanceHistory callout response
   */
  public class BalanceHistoryCalloutResponse extends FinancialAccountCalloutResponse {
    public List<BalanceHistoryModel> balanceHistory;
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
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
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
      result.queryResult.add(row);
    }
    return result;
  }
}
