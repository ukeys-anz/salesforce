/**
 * @author Ian Huang
 * @since  11/2024
 * @group CCRM (Commercial CRM)
 * @description Trade Finance external query class
 */
public with sharing class TradeFinanceExternalQuery extends EBDFinancialAccountQueryBase {
  /**
   * @description Trade Finance Model class
   */
  @testVisible
  private class TradeFinanceModel extends FinancialAccountModelBase {
    public String  compositeAccountNumber;  
    public Decimal capAccountLimit;
    public String  currencyCode;
    public Decimal interestRate;
    public Decimal originalLimit;
    public Date    limitExpiry;
    public String  ollAccountNumber;
    public String  productDescription;
    public Decimal sequenceNumber;
    public String  subProductCode;
    public Decimal term;
  }

  /**
   * @description Asset Detail callout response
   */
  public class TradeFinanceCalloutResponse extends FinancialAccountQueryBase.FinancialAccountCalloutResponse {
    public List<TradeFinanceModel> accounts;
  }

  /**
   * @description constructor
   */
  public TradeFinanceExternalQuery() {
    this.externalField = 'compositeAccountNumber';
    this.productCategory = 'tradefinance-otl';
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @param tableSelection DataSource TableSelection
   * @return QueryMode Enum
   */
  @TestVisible  
  protected override ExternalObjectCalloutRequestBase prepareCallout(
    DataSource.QueryContext queryContext,
    DataSource.TableSelection tableSelection
  ) {
    ExternalObjectQueryBase.ExternalObjectCalloutRequestBase calloutRequest = super.prepareCallout(
      queryContext, 
      queryContext.TableSelection
    );
      
    if(calloutRequest.isSummaryRequest()) {
      Set<String> customerIds = externalQueryHelper.getCLGRelatedCustomerIds(this.parentId);
      ((FinancialAccountEntities.FinancialAccountPayload)calloutRequest.payload).capCustomerIds = new Set<String>();  
      for (String customerId : customerIds) {
        customerId = customerId.contains('_')
          ? customerId.substringAfter('_')
          : customerId;
        ((FinancialAccountEntities.FinancialAccountPayload)calloutRequest.payload).capCustomerIds.add(customerId);
      }
    } else if(calloutRequest.isDetailRequest()) {
      ((FinancialAccountEntities.FinancialAccountPayload)calloutRequest.payload).compositeAccountNumber = this.externalId;
    }
      
    return calloutRequest;
  }
    
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @TestVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (TradeFinanceCalloutResponse)CalloutModel.deserialize(
      responseBody,
      TradeFinanceCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse calloutResponse
   */
  @TestVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    for (
      TradeFinanceModel account : ((TradeFinanceCalloutResponse)this.calloutResponse)
        .accounts
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => account.compositeAccountNumber,
        'DisplayUrl' => getDisplayUrl(account.compositeAccountNumber),
        this.parentField => this.parentId,
        'AccountNumber' => externalQueryHelper.formatAccountNumber(account.accountNumber),
        'CAPLimit' => account.capAccountLimit,
        'Currency' => account.currencyCode,
        'InterestRate' => account.interestRate,
        'Limit' => account.originalLimit,
        'LimitExpiry' => account.LimitExpiry,
        'OLLAccountNumber' => externalQueryHelper.formatAccountNumber(account.ollAccountNumber),
        'ProductCode' => account.productCode,
        'ProductName' => account.productDescription,
        'SequenceNumber' => account.sequenceNumber,
        'SubProductCode' => account.subProductCode,
        'Term' => account.term    
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}