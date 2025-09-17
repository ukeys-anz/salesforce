/**
 * @author Ian Huang
 * @since  11/2024
 * @group Platform
 * @description EBD Financial Account external query base class
 */
public abstract with sharing class EBDFinancialAccountQueryBase extends ExternalObjectQueryBase {
  protected FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
  protected String productCategory;

  /**
   * @description Class constractor
   */
  public EBDFinancialAccountQueryBase() {
    this.parentField = 'CustomerId';
  }

  /**
   * @description Main execute method - the orchestration layer
   * @param queryContext DataSource QueryContext
   * @return ExternalQueryResult
   */
  public override ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.tableName = queryContext.TableSelection.tableSelected;
    ExternalObjectCalloutRequestBase calloutRequest = prepareCallout(
      queryContext,
      queryContext.TableSelection
    );
    HttpCalloutResponse response = makeCallout(calloutRequest);
    calloutResponse = parseResponse(response.body);
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
    FinancialAccountEntities.FinancialAccountCalloutRequest calloutRequest = new FinancialAccountEntities.FinancialAccountCalloutRequest(
      queryContext,
      this.queryMode,
      this.productCategory,
      null,
      null
    );
    return calloutRequest;
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param calloutRequest ExternalObjectCalloutRequest
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout(
    ExternalObjectCalloutRequestBase calloutRequest
  ) {
    ARNCService service = new ARNCService();
    HttpCalloutResponse response = service.queryExternalData(calloutRequest);
    if (response == null || !response.successful) {
      String errorMessge = String.format(
        'Unexpected error from makeCallout - {0} and query mode: {1}.\n {2}',
        new List<Object>{
          this.tableName,
          calloutRequest.queryMode,
          response?.error.getMessage()
        }
      );
      throw new CalloutException(errorMessge);
    }
    return response;
  }
}
