/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @group Platform
 * @description AFAMBITContractExternalQuery external query class
 */
public with sharing class AFAMBITContractExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description AFAMBITContract model class
   */
  @testVisible
  private class AFAMBITContractModel extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    public String compositeContractNumber;
    public String contractNumber;
    public String accountNumber;
    public String status;
    public Date dateOpened;
    public Date expiryDate;
    public String termsInMonth;
    public String termsInYear;
    public Decimal amountFinanced;
    public String govtGuarantee;
    public String productCode;
    public String facilityDesc;
    public String interestType;
    public Decimal interestRate;
    public Decimal residualValue;
    public Decimal amountInArrears;
    public Decimal netOutstanding;
    public String securityIndicator;
    private String errorMessage;
  }

  /**
   * @description AFAMBITContract callout response
   */
  @testVisible
  private class AFAMBITContractCalloutResponse extends FinancialAccountEntities.FinancialAccountCalloutResponse {
    public List<AFAMBITContractModel> contracts;
  }

  /**
   * @description Class constructor
   */
  public AFAMBITContractExternalQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeContractNumber';
    this.assetFinanceType = 'AMBIT';
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
    if (
      this.queryMode == QueryModeEnum.RECORD_DETAIL && this.isCACHECustomer()
    ) {
      this.calloutResponse = (AFAMBITContractModel) CalloutModel.deserialize(
        responseBody,
        AFAMBITContractModel.class
      );
      return this.calloutResponse;
    }
    this.calloutResponse = (AFAMBITContractCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AFAMBITContractCalloutResponse.class
    );

    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse calloutResponse
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    if (calloutResponse == null) {
      return result;
    }

    if (
      this.queryMode == QueryModeEnum.RECORD_DETAIL && this.isCACHECustomer()
    ) {
      AFAMBITContractModel contract = ((AFAMBITContractModel) calloutResponse);
      result.externalRecords.add(createExternalRec(contract));
    } else {
      //Pass pagination token
      result.queryMoreToken = ((AFAMBITContractCalloutResponse) this.calloutResponse)
        .nextPageId;
      List<AFAMBITContractModel> contracts = ((AFAMBITContractCalloutResponse) calloutResponse)
        .contracts ?? new List<AFAMBITContractModel>();
      for (AFAMBITContractModel contract : contracts) {
        result.externalRecords.add(createExternalRec(contract));
      }
    }
    return result;
  }
  private Map<String, Object> createExternalRec(AFAMBITContractModel contract) {
    String externalId = getExternalId(contract);
    Map<String, Object> row = new Map<String, Object>{
      'ExternalId' => externalId,
      'DisplayUrl' => getDisplayUrl(externalId),
      this.parentField => this.parentId,
      'ContractNumber' => contract.contractNumber,
      'AccountNumber' => contract.accountNumber,
      'Status' => contract.status,
      'OpenedDate' => contract.dateOpened,
      'Expires' => contract.expiryDate,
      'LoanTermMonths' => contract.termsInMonth,
      'LoanTermYears' => contract.termsInYear,
      'GovernmentGuarantee' => contract.govtGuarantee == 'YES' ? true : false,
      'ProductCode' => contract.productCode,
      'IntType' => contract.interestType,
      'IntRate' => contract.interestRate,
      'AmountFinanced' => contract.amountFinanced,
      'SI' => contract.securityIndicator,
      'Amount' => contract.netOutstanding,
      'AmountInArrears' => contract.amountInArrears,
      'ResidualValue' => contract.residualValue,
      'ProductName' => contract.facilityDesc
    };
    return row;
  }
  private String getExternalId(AFAMBITContractModel contract) {
    if (String.isNotBlank(this.externalId)) {
      return this.externalId;
    }
    if (String.isNotBlank(contract.compositeContractNumber)) {
      return this.customerSourceSystem + '_' + contract.compositeContractNumber;
    }
    return this.parentId + '-' + contract.contractNumber;
  }
}
