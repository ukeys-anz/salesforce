/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Asset Finance AMBIT external query class
 */
public with sharing class AssetFinanceAMBITExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description wrapper class for response
   */
  public class AssetFinanceAMBITModel extends FinancialAccountModelBase {
    public String contractNumber;
    public String compositeAccountNumber;
    public String productCode;
    public Decimal originalAmountFinanced;
    public DateTime openedDate;
    public Decimal balloonAmount;
    public Decimal interestRate;
    public String interestType;
    public String loanTermYears;
    public String loanTermMonths;
    public DateTime expiryDate;
    public String govtGuarantee;
    public Decimal amountInArrears;
    public String securityIndicator;
    public Decimal undrawnBalance;
  }

  /**
   * @description Asset Finance AMBIT API callout response
   */
  public class AssetFinanceAMBITCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<AssetFinanceAMBITModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public AssetFinanceAMBITExternalQuery() {
    this.productCategory = 'asset-finance';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.assetFinanceType = 'AMBIT';
    this.externalField = 'compositeAccountNumber';
    this.enableServerPagination = true;
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
    this.calloutResponse = (AssetFinanceAMBITCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetFinanceAMBITCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to AMBIT accounts
   * @param calloutResponse
   * @return ExternalObjectQueryBase.ExternalQueryResult object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    List<AssetFinanceAMBITModel> accounts = ((AssetFinanceAMBITCalloutResponse) this.calloutResponse)
      .accounts;
    //Pass pagination token
    result.queryMoreToken = ((AssetFinanceAMBITCalloutResponse) this.calloutResponse)
      .nextPageId;

    for (AssetFinanceAMBITModel af : accounts) {
      String displayUrl = getDisplayUrl(af.compositeAccountNumber);
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => af.compositeAccountNumber,
        'DisplayUrl' => displayUrl,
        'AccountStatus' => af.status,
        'AccountName' => af.accountName,
        'ProductCode' => af.productCode,
        'AccountNumber' => af.contractNumber,
        'Balance' => af.accountBalance,
        'Limit' => af.accountLimit,
        'OriginalAmountFinanced' => af.originalAmountFinanced,
        'OpenedDate' => formatDate(af.openedDate),
        'BalloonPayments' => af.balloonAmount,
        'IntRate' => af.interestRate,
        'IntType' => af.interestType,
        'LoanTermMonths' => af.loanTermMonths,
        'LoanTermYears' => af.loanTermYears,
        'Expires' => formatDate(af.expiryDate),
        'GovernmentGuarantee' => af.govtGuarantee == 'YES' ? true : false,
        'AmountInArrears' => af.amountInArrears,
        'SI' => af.securityIndicator,
        'UndrawnBalance' => af.undrawnBalance
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
