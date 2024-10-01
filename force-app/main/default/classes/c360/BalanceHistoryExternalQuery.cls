/**
 * @author Ian Huang
 * @since  08/2023
 * @group Platform
 * @description Balance History external query class
 */
public with sharing class BalanceHistoryExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description BalanceHistory Model class
   */
  public class BalanceHistoryModel extends FinancialAccountModelBase {
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
  public BalanceHistoryExternalQuery() {
    this.productCategory = 'deposit';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'BALANCE_HISTORY';
    this.parentField = 'DepositAccount';
    this.externalField = 'compositeBalanceHistoryId';
  }

  /**
   * @description Main execute method - the orchestration layer
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public virtual override ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    ExternalQueryResult externalQueryResult;
    QueryModeEnum queryMode = prepareCallout(queryContext);
    this.paginationKey = getPaginationKey(
      queryContext.tableSelection.tableSelected,
      this.parentId
    );
    // Display Dummay FA Detail Record
    if (displayDummyAccountDetails(this.externalId, this.parentId)) {
      externalQueryResult = createDummyFinancialAccountDetail(this.externalId);
      return externalQueryResult;
    }
    // Display Dummy/Empty FA List on related section of FM/RSV/SSI
    if (
      isDepositProductCategory(this.productCategory) && displayDummyRecord()
    ) {
      externalQueryResult = createDummyExternalRecord(
        this.parentId,
        new Map<String, Object>()
      );
      return externalQueryResult;
    }
    HttpCalloutResponse response = makeCallout(queryMode, queryContext);
    calloutResponse = parseResponse(response.body);
    externalQueryResult = createExternalRecords(calloutResponse);
    return externalQueryResult;
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
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    Map<String, Object> row;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    for (
      BalanceHistoryModel bal : ((BalanceHistoryCalloutResponse) this.calloutResponse)
        .balanceHistory
    ) {
      row = new Map<String, Object>{
        'ExternalId' => bal.compositeBalanceHistoryId,
        'DisplayUrl' => URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        bal.compositeBalanceHistoryId,
        this.parentField => this.parentId,
        'BalancePeriod' => bal.year +
        '-' +
        bal.month,
        'Year' => bal.year,
        'Month' => bal.month,
        'AverageBalance' => bal.avgBalance,
        'MaximumBalance' => bal.maxBalance,
        'MinimumBalance' => bal.minBalance
      };
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description Transform API response to DepositAccount records
   * @param externalId externalId
   * @param row externalRecord row
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createDummyExternalRecord(
    String externalId,
    Map<String, Object> row
  ) {
    return new ExternalObjectQueryBase.ExternalQueryResult();
  }

  /**
   * @description Need to display Dummy FA record? return false by default
   * @return true / false
   **/
  @TestVisible
  protected override Boolean displayDummyRecord() {
    return isFMOrSsiOrRsvProduct(this.accountNumber);
  }

  /**
   * @description checks if Account is FM or SSI or RSV.
   * @param payload payload created for Callout. Ex - {"accountNumber": "FM-111269467"},  {"compositeBalanceHistoryId": "DDA-234500817-0"}
   * @return boolean true/false
   */
  @TestVisible
  private static Boolean isFMOrSsiOrRsvProduct(String payload) {
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
    return String.isNotEmpty(externalId) && String.isEmpty(parentId);
  }

  /**
   * @description Create Dummy FA record
   * @param externalId Format - 'DDA-210568745-2'
   * @return dummy FA record
   **/
  @TestVisible
  private ExternalObjectQueryBase.ExternalQueryResult createDummyFinancialAccountDetail(
    String externalId
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>{
      'ExternalId' => externalId,
      'AdditionalInformation' => 'No further information available'
    };
    result.ExternalRecords.add(row);
    return result;
  }
}
