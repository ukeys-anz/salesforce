/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @group Platform
 * @description AFAMBITContractExternalQuery external query class
 */
public with sharing class AFAMBITContractExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description AFAMBITContract Model class
   */
  @testVisible
  private class AFAMBITContractModel extends FinancialAccountModelBase {
    public String compositeCreditLineId;
    public String contractNumber;
    public String accountNumber;
    public String status;
    public DateTime dateOpened;
    public DateTime expiryDate;
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
  }

  /**
   * @description AFAMBITContract callout response
   */
  @testVisible
  private class AFAMBITContractCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AFAMBITContractModel> contracts;
  }

  /**
   * @description Class constructor
   */
  public AFAMBITContractExternalQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'CONTRACT';
    this.externalField = 'compositeCreditLineId';
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
    Map<String, Object> row;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    if (calloutResponse == null) {
      return result;
    }
    for (
      AFAMBITContractModel contract : ((AFAMBITContractCalloutResponse) calloutResponse)
        .contracts
    ) {
      row = new Map<String, Object>{
        'ExternalId' => contract.compositeCreditLineId,
        'DisplayUrl' => getDisplayUrl(contract.compositeCreditLineId),
        this.parentField => this.parentId,
        'ContractNumber' => contract.contractNumber,
        'AccountNumber' => contract.accountNumber,
        'Status' => contract.status,
        'OpenedDate' => formatDate(contract.dateOpened),
        'Expires' => formatDate(contract.expiryDate),
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
      result.externalRecords.add(row);
    }
    return result;
  }
}
