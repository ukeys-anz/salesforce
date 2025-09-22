/**
 * @author Ian Huang
 * @since  07/2025
 * @group Platform
 * @description Balance History external query class
 */
public with sharing class BalanceHistoryExternalQuery extends CAPFinancialAccountQueryBase {
  /**
   * @description BalanceHistory Model class
   */
  public class BalanceHistoryModel extends FinancialAccountModelBase {
    private String compositeBalanceHistoryId;
    private String balancePeriod;
    private String month;
    private String year;
    private Decimal avgBalance;
    private Decimal maxBalance;
    private Decimal minBalance;
    private Integer excessDays;
    private String returnedItems;
    private Integer excessItems;
    private Integer excessTimes;
  }

  /**
   * @description abstract CAP FinancialAccount Summary callout response class
   */
  public virtual class BalanceHistoryCalloutRequest extends ExternalObjectQueryBase.ExternalObjectCalloutRequestBase {
    public String productCategory;
    public QueryModeEnum queryMode;
    /**
     * @description abstract FinancialAccount callout response class
     * @param queryContext DataSource QueryContext
     * @param queryMode Query Mode Enum
     * @param productCategory productCategory
     * @param fieldSet fieldSet
     * @param accountNumber accountNumber
     */
    public BalanceHistoryCalloutRequest(
      DataSource.QueryContext queryContext,
      QueryModeEnum queryMode,
      String productCategory,
      String fieldSet,
      String accountNumber
    ) {
      super(queryContext, queryMode);
      this.productCategory = productCategory;
      this.payload = new FinancialAccountEntities.FinancialAccountPayload();

      if (this.isSummaryRequest()) {
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .fieldSet = fieldSet;
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .accountNumber = accountNumber;
      } else {
        ((FinancialAccountEntities.FinancialAccountPayload) this.payload)
          .compositeBalanceHistoryId = accountNumber;
      }
    }
    public override String getEndpoint() {
      return this.productCategory + '-accounts';
    }
  }

  /**
   * @description BalanceHistory callout response
   */
  @testVisible
  private class BalanceHistoryCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    public List<BalanceHistoryModel> balanceHistory;
  }

  /**
   * @description constructor
   */
  public BalanceHistoryExternalQuery() {
    this.productCategory = 'deposit';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'BALANCE_HISTORY';
    this.parentField = 'DepositAccount';
    this.externalField = 'compositeBalanceHistoryId';
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
    String accountNumber;
    ExternalObjectCalloutRequestBase calloutRequest = super.prepareCallout(
      queryContext,
      queryContext.TableSelection
    );
    if (calloutRequest.isSummaryRequest()) {
      accountNumber = this.parentId.right(
        this.parentId.length() - this.parentId.indexOf('|') - 1
      );
    } else {
      accountNumber = this.externalId;
    }
    BalanceHistoryCalloutRequest balHistorycalloutRequest = new BalanceHistoryCalloutRequest(
      queryContext,
      this.queryMode,
      this.productCategory,
      this.fieldSet,
      accountNumber
    );
    this.accountNumbers = new Set<String>{ accountNumber };
    return balHistorycalloutRequest;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return calloutResopnse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (BalanceHistoryCalloutResponse) CalloutModel.deserialize(
      responseBody,
      BalanceHistoryCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to BalanceHistory records
   * @param calloutResponse calloutResponseWrapper
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    for (
      BalanceHistoryModel bal : ((BalanceHistoryCalloutResponse) this.calloutResponse)
        .balanceHistory
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => bal.compositeBalanceHistoryId,
        'DisplayUrl' => getDisplayUrl(bal.compositeBalanceHistoryId),
        this.parentField => this.parentId,
        'BalancePeriod' => bal.year +
        '-' +
        bal.month,
        'Year' => bal.year,
        'Month' => bal.month,
        'AverageBalance' => bal.avgBalance,
        'MaximumBalance' => bal.maxBalance,
        'MinimumBalance' => bal.minBalance,
        'DaysInExcess' => bal.excessDays,
        'ReturnedItems' => bal.returnedItems,
        'ItemsInExcess' => bal.excessItems,
        'Times In Excess' => bal.excessTimes
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
