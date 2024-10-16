/**
 * @author Ian Huang
 * @since  06/2023
 * @group Platform
 * @description Deposit Account external query class
 * @runTests DepositAccountExternalQueryTest
 */
@SuppressWarnings('PMD.TooManyFields')
public with sharing class DepositAccountExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Deposit account business Model class
   */
  @testVisible
  private class DepositAccountModel extends FinancialAccountModelBase {
    private String anzsicCode;
    private Boolean accountRestraint;
    private Boolean anzPlusIdentifier;
    private String bsb;
    private Decimal odLimit;
    private Decimal pledgeAmount;
    private Boolean pledge;
    private Decimal accountBalance;
    private Decimal availableBalance;
    private DateTime openDate;
    private String subProductCode;

    private Boolean accountRestrictions;
    private Boolean restrainsHardHold;
    private Boolean restrainsStopPay;
    private String restrainsStopPayNumber;
    private String controllingPostId;
    private String debitInterestCode;
    private Decimal debitInterestIndexRate;
    private Decimal debitInterestMargin;
    private Decimal debitInterestRate;
    private Decimal tempODAccountLimit;
    private Decimal tempODMargin;
    private Decimal tempODInterestRate;
    private String tpmiNumber;
    private String tpmiSAO;
    private String tempODInterestRepaymentFrequency;
    private String bsbCode;
    private Integer noOfSignatures;
    private DateTime tempODExpiryDate;
    private List<SeasonalLimits> seasonalLimits;
    private String productSetOff;
    private String regulatedFlag;
    private String serviceChargeCode;
    private String waiveCode;
    private String waiveExpiryDate;
    private String odChargeCode;
    private String odChargeWaiveCode;
    private String odChargeWaiveExpiryDate;
    private String address;
    private String creditRiskGrade;
    private DateTime closeDate;
    private String sourceSystemStatus;
  }
  /**
   * @description SeasonalLimits class
   */
  @testVisible
  private class SeasonalLimits {
    private Decimal seasonalLimit;
    private DateTime startDate;
    private DateTime endDate;
    /**
     * @description Constructor
     * @param seasonalLimit Decimal
     * @param startDate DateTime
     * @param endDate DateTime
     */
    public SeasonalLimits(
      Decimal seasonalLimit,
      DateTime startDate,
      DateTime endDate
    ) {
      this.seasonalLimit = seasonalLimit;
      this.startDate = startDate;
      this.endDate = endDate;
    }
  }

  /**
   * @description DepositAccount API callout response
   */
  @testVisible
  private class DepositAccountCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<DepositAccountModel> accounts;
  }

  /**
   * @description constructor
   */
  public DepositAccountExternalQuery() {
    this.productCategory = 'deposit';
    this.productTypes = new Set<String>{
      'CAP-CIS:DDA',
      'CAP-CIS:FM',
      'CAP-CIS:SSI',
      'CAP-CIS:RSV'
    };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
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
    this.calloutResponse = (DepositAccountCalloutResponse) CalloutModel.deserialize(
      responseBody,
      DepositAccountCalloutResponse.class
    );
    return this.calloutResponse;
  }

  private static final Map<Integer, String> MAP_NO_OF_SIGNATURES = new Map<Integer, String>{
    1 => '1 - ANY ONE TO SIGN',
    2 => '2 - BOTH TO SIGN (CONJOINTLY)',
    3 => '3 - REFER TO ACCOUNT SIGNING AUTHORITY'
  };

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    '03' => '03 - Inactive',
    '05' => '05 - Dormant',
    '06' => '06 - Unclaimed',
    '07' => '07 - Closed',
    '08' => '08 - Purgeable',
    '12' => '12 - Closing',
    '80' => '80 - SSA Active',
    '82' => '82 - SSA Inactive',
    '99' => '99 - Active'
  };

  /**
   * @description Transform API response to DepositAccount records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    Map<String, Object> row;
    String accNumber;
    String customerId;
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    List<DepositAccountModel> accounts = new List<DepositAccountModel>();
    if (calloutResponse == null) {
      return result;
    }

    for (
      DepositAccountModel fa : ((DepositAccountCalloutResponse) calloutResponse)
        .accounts
    ) {
      customerId = String.isBlank(
          ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) calloutResponse)
            .customerId
        )
        ? getCustomerId(fa.accountNumber)
        : ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) calloutResponse)
            .customerId;
      if (String.isBlank(customerId)) {
        continue;
      }
      accNumber = this.sourceSystem == SourceSystemEnum.CAP
        ? getAccountNumberwithFormat(fa.accountNumber)
        : formatAccountNumber(fa.accountNumber);

      row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => getExternalId(fa, this.accountRoleMap),
        'DisplayUrl' => getDisplayUrl(fa),
        'Relationship' => getAccountRelationship(fa.accountNumber),
        'AccountName' => fa.accountName,
        'AccountNumber' => accNumber,
        'AccountStatus' => fa.status,
        'ANZSICCode' => fa.anzsicCode,
        'accountRestrictions' => fa.accountRestrictions,
        'ANZPlusIdentifier' => fa.anzPlusIdentifier,
        'BSB' => fa.bsbCode,
        'Balance' => fa.accountBalance,
        'BalanceAvailable' => fa.availableBalance,
        'CPID' => fa.controllingPostId,
        'ProductCode' => fa.productCode,
        'SubProductCode' => fa.subProductCode,
        'OpenedDate' => formatDate(fa.openDate),
        'OverdraftLimit' => fa.odLimit,
        'PledgeAmount' => fa.pledgeAmount,
        'Pledge' => fa.pledge,
        'HardHold' => fa.restrainsHardHold,
        'ReferenceIndexRate' => fa.debitInterestIndexRate,
        'Margin' => fa.debitInterestMargin,
        'InterestRate' => fa.debitInterestRate,
        'Limit' => fa.tempODAccountLimit,
        'OverdraftMargin' => fa.tempODMargin,
        'OverdraftInterestRate' => fa.tempODInterestRate,
        'OverdraftLimitInterestRepaymentFrequency' => fa.tempODInterestRepaymentFrequency,
        'OverdraftExpiryDate' => formatDate(fa.tempODExpiryDate),
        'NumberOfSignatures' => MAP_NO_OF_SIGNATURES.get(fa.noOfSignatures),
        'StopPayNumber' => fa.restrainsStopPayNumber,
        'ReferenceIndexType' => fa.debitInterestCode,
        'OverdraftReferenceIndexRate' => fa.debitInterestIndexRate,
        'TPMISAO' => String.isBlank(fa.tpmiNumber)
          ? ''
          : fa.tpmiNumber + '-' + fa.tpmiSAO,
        'LinkedLoanOffsets' => fa.productSetOff,
        'RegulatedAccount' => fa.regulatedFlag,
        'ServiceChargeCode' => fa.serviceChargeCode,
        'ServiceChargeWaiveCode' => fa.waiveCode,
        'ServiceChargeWaiveExpiry' => fa.waiveExpiryDate,
        'ODServiceChargeCode' => fa.odChargeCode,
        'ODServiceChargeWaiveCode' => fa.odChargeWaiveCode,
        'ODServiceChargeWaiveExpiry' => fa.odChargeWaiveExpiryDate,
        'ProductName' => getProductName(fa.accountNumber),
        'StatementMailingAddress' => fa.address,
        'CCR' => fa.creditRiskGrade,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.containsKey(
            fa.sourceSystemStatus
          )
          ? MAP_SOURCE_SYSTEM_STATUS.get(fa.sourceSystemStatus)
          : fa.sourceSystemStatus,
        'Date_Closed' => formatDate(fa.closeDate),
        'ExpiryDate' => formatDate(fa.tempODExpiryDate)
      };
      row = populateSeasonalLimits(row, fa.seasonalLimits);
      result.externalRecords.add(row);
    }
    return result;
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
   * @description This is used to populate the seasonal limits
   * @param row Map<String, Object>
   * @param seasonalLimits List<SeasonalLimits>
   * @return Map<String, Object>
   **/
  @testVisible
  private Map<String, Object> populateSeasonalLimits(
    Map<String, Object> row,
    List<SeasonalLimits> seasonalLimits
  ) {
    if (seasonalLimits == null || seasonalLimits.isEmpty()) {
      return row;
    }
    if (seasonalLimits[0].seasonalLimit != null) {
      row.put('FluctuatingSeasonalLimit', seasonalLimits[0].seasonalLimit);
    }
    if (
      seasonalLimits[0].startDate != null &&
      seasonalLimits[0].endDate != null
    ) {
      row.put(
        'Fluctuating_Seasonal_Start_Expiry_Limit1',
        formatDate(seasonalLimits[0].startDate) +
          ' - ' +
          formatDate(seasonalLimits[0].endDate)
      );
    }
    if (seasonalLimits[1].seasonalLimit != null) {
      row.put('Fluctuating_Seasonal_Limit_2', seasonalLimits[1].seasonalLimit);
    }
    if (
      seasonalLimits[1].startDate != null &&
      seasonalLimits[1].endDate != null
    ) {
      row.put(
        'Fluctuating_Seasonal_Start_Expiry_Limit2',
        formatDate(seasonalLimits[1].startDate) +
          ' - ' +
          formatDate(seasonalLimits[1].endDate)
      );
    }
    if (seasonalLimits[2].seasonalLimit != null) {
      row.put('Fluctuating_Seasonal_Limit_3', seasonalLimits[2].seasonalLimit);
    }
    if (
      seasonalLimits[2].startDate != null &&
      seasonalLimits[2].endDate != null
    ) {
      row.put(
        'Fluctuating_Seasonal_Start_Expiry_Limit3',
        formatDate(seasonalLimits[2].startDate) +
          ' - ' +
          formatDate(seasonalLimits[2].endDate)
      );
    }
    return row;
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
}
