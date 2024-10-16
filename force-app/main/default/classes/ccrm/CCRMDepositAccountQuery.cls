/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Deposit Account external query class
 * @runTests CCRMDepositAccountQueryTest
 */
@SuppressWarnings('PMD.TooManyFields')
public with sharing class CCRMDepositAccountQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Deposit account Model class
   */
  @testVisible
  private class CCRMDepositAccountModel extends CCRMFinancialAccountModelBase {
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
    private Decimal accountLimit;
    private Decimal tempODMargin;
    private Decimal tempODInterestRate;
    private String tpmiNumber;
    private String tpmiSAO;
    private String tempODInterestRepaymentFrequency;
    private String bsbCode;
    private Integer noOfSignatures;
    private DateTime expiryDate;
    private DateTime limitExpiryDate;
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
    @testVisible
    private Decimal seasonalLimit;
    @testVisible
    private DateTime startDate;
    @testVisible
    private DateTime endDate;
  }

  private static Map<String, String> mapOfCycleCode = new Map<String, String>{
    '00' => '00 - No Cycle',
    '01' => '01 - Calendar Day of Month',
    '02' => '02 - Calendar Day of Month',
    '03' => '03 - Calendar Day of Month',
    '04' => '04 - Calendar Day of Month',
    '05' => '05 - Calendar Day of Month',
    '06' => '06 - Calendar Day of Month',
    '07' => '07 - Calendar Day of Month',
    '08' => '08 - Calendar Day of Month',
    '09' => '09 - Calendar Day of Month',
    '10' => '10 - Calendar Day of Month',
    '11' => '11 - Calendar Day of Month',
    '12' => '12 - Calendar Day of Month',
    '13' => '13 - Calendar Day of Month',
    '14' => '14 - Calendar Day of Month',
    '15' => '15 - Calendar Day of Month',
    '16' => '16 - Calendar Day of Month',
    '17' => '17 - Calendar Day of Month',
    '18' => '18 - Calendar Day of Month',
    '19' => '19 - Calendar Day of Month',
    '20' => '20 - Calendar Day of Month',
    '21' => '21 - Calendar Day of Month',
    '22' => '22 - Calendar Day of Month',
    '23' => '13 - Calendar Day of Month',
    '24' => '24 - Calendar Day of Month',
    '25' => '25 - Calendar Day of Month',
    '26' => '26 - Calendar Day of Month',
    '27' => '27 - Calendar Day of Month',
    '28' => '28 - Calendar Day of Month',
    '29' => '29 - Calendar Day of Month',
    '30' => '30 - Calendar Day of Month',
    '31' => '31 - Calendar Day of Month',
    'IM' => 'IM - Inception Monthly',
    'IQ' => 'IQ - Inception Quarterly',
    'IS' => 'IS - Inception Semi-Annually',
    'IY' => 'IY - Inception Yearly',
    'EM' => 'EM - End of Month',
    'EQ' => 'EQ - End of Quarter',
    'EY' => 'EY - End of Financial Year',
    'SA' => 'SA - End of Half Year'
  };

  /**
   * @description DepositAccount API callout response
   */
  @testVisible
  private class DepositAccountCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<CCRMDepositAccountModel> accounts;
  }

  /**
   * @description constructor
   */
  public CCRMDepositAccountQuery() {
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
    String payload = getPayload();
    if (
      isDepositProductCategory(this.productCategory) &&
      displayDummyRecord(payload)
    ) {
      String accountNumber = extractAccNumberFromPayload(payload);
      queryResult = createDummyFinancialAccounts(
        this.externalId,
        accountNumber
      );
      return queryResult;
    }
    HttpCalloutResponse response = makeCallout();
    parseResponse(response.body);
    queryResult = createFinancialAccounts();
    return queryResult;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  @testVisible
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (DepositAccountCalloutResponse) CalloutModel.deserialize(
      responseBody,
      DepositAccountCalloutResponse.class
    );
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
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMDepositAccountModel> accounts = new List<CCRMDepositAccountModel>();
    if (this.calloutResponse == null) {
      return result;
    }
    for (
      CCRMDepositAccountModel fa : ((DepositAccountCalloutResponse) this.calloutResponse)
        .accounts
    ) {
      String customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      Map<String, Object> row = new Map<String, Object>{
        'CustomerId' => customerId,
        'ExternalId' => getExternalId(fa),
        'DisplayUrl' => getDisplayUrl(fa),
        'Relationship' => getAccountRelationship(fa.accountNumber),
        'AccountName' => fa.accountName,
        'AccountNumber' => formatAccountNumber(fa.accountNumber),
        'AccountStatus' => fa.status,
        'ANZSICCode' => retrieveIndustryCodeAndDescription(fa.anzsicCode),
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
        'Limit' => fa.accountLimit,
        'OverdraftMargin' => fa.tempODMargin,
        'OverdraftInterestRate' => fa.tempODInterestRate,
        'OverdraftLimitInterestRepaymentFrequency' => mapOfCycleCode.get(
          fa.tempODInterestRepaymentFrequency
        ) ?? fa.tempODInterestRepaymentFrequency,
        'OverdraftExpiryDate' => formatDate(fa.expiryDate),
        'NumberOfSignatures' => MAP_NO_OF_SIGNATURES.get(fa.noOfSignatures),
        'StopPayNumber' => fa.restrainsStopPayNumber,
        'ReferenceIndexType' => fa.debitInterestCode,
        'OverdraftReferenceIndexRate' => fa.debitInterestIndexRate,
        'TPMISAO' => String.isBlank(fa.tpmiNumber)
          ? ''
          : fa.tpmiNumber + '-' + fa.tpmiSAO,
        'LinkedLoanOffsets' => formatAccountNumber(fa.productSetOff),
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
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.get(
          fa.sourceSystemStatus
        ) ?? fa.sourceSystemStatus,
        'Date_Closed' => formatDate(fa.closeDate),
        'ExpiryDate' => formatDate(fa.limitExpiryDate)
      };
      populateSeasonalLimits(row, fa.seasonalLimits);
      result.queryResult.add(row);
    }
    return result;
  }

  /**
   * @description This is used to populate the seasonal limits
   * @param row Map<String, Object>
   * @param seasonalLimits List<SeasonalLimits>
   **/
  @testVisible
  private void populateSeasonalLimits(
    Map<String, Object> row,
    List<SeasonalLimits> seasonalLimits
  ) {
    if (seasonalLimits == null || seasonalLimits.isEmpty()) {
      return;
    }
    Map<String, SeasonalLimits> seasonalLimitMap = new Map<String, SeasonalLimits>{
      'FluctuatingSeasonalLimit' => seasonalLimits[0],
      'Fluctuating_Seasonal_Limit_2' => seasonalLimits[1],
      'Fluctuating_Seasonal_Limit_3' => seasonalLimits[2]
    };
    Map<String, SeasonalLimits> expiryLimitMap = new Map<String, SeasonalLimits>{
      'Fluctuating_Seasonal_Start_Expiry_Limit1' => seasonalLimits[0],
      'Fluctuating_Seasonal_Start_Expiry_Limit2' => seasonalLimits[1],
      'Fluctuating_Seasonal_Start_Expiry_Limit3' => seasonalLimits[2]
    };
    for (String slKey : seasonalLimitMap.keySet()) {
      SeasonalLimits sl = seasonalLimitMap.get(slKey);
      if (sl.seasonalLimit == null) {
        continue;
      }
      row.put(slKey, sl.seasonalLimit);
    }
    for (String elKey : expiryLimitMap.keySet()) {
      SeasonalLimits sl = expiryLimitMap.get(elKey);
      if (sl.startDate == null || sl.endDate == null) {
        continue;
      }
      row.put(elKey, formatDate(sl.startDate) + ' - ' + formatDate(sl.endDate));
    }
  }

  /**
   * @description Create Dummy FA record
   * @param externalId
   * @param accountNumber
   * @return dummy FA record
   **/
  @TestVisible
  private CCRMExternalObjectQueryBase.ExternalQueryResult createDummyFinancialAccounts(
    String externalId,
    String accountNumber
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>{
      'ExternalId' => externalId,
      'AccountName' => 'No further information available',
      'AccountNumber' => formatAccountNumber(accountNumber)
    };
    result.queryResult.add(row);
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
   * @description Return AccountNumber from Payload. Payload sample - {"accountNumber": "FM-111269467"}.
   * @param payload
   * @return String accountNumber
   */
  @TestVisible
  public static String extractAccNumberFromPayload(String payload) {
    Map<String, Object> parsedMap = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    String accNumber = (string) parsedMap.get('accountNumber');
    return accNumber.replaceAll('[^0-9]', ''); // replace non-numeric part with empty string
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
}
