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
    @testVisible
    private Boolean pledge;
    private Decimal accountBalance;
    @testVisible
    private Decimal availableBalance;
    private DateTime openDate;
    private String subProductCode;
    private Boolean accountRestrictions;
    private Boolean restrainsHardHold;
    private Boolean restrainsStopPay;
    private String restrainsStopPayNumber;
    @testVisible
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
    private String tpmiType;
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
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      DepositAccountModel fa : ((DepositAccountCalloutResponse) calloutResponse)
        .accounts
    ) {
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => getExternalId(fa, this.accountRoleMap),
        'DisplayUrl' => getDisplayUrl(fa.productCode + '-' + fa.accountNumber),
        'Relationship' => getAccountRelationship(fa.accountNumber),
        'AccountName' => fa.accountName,
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          fa.accountNumber
        ),
        'AccountStatus' => fa.status,
        'accountRestrictions' => fa.accountRestrictions,
        'ANZPlusIdentifier' => fa.anzPlusIdentifier,
        'BSB' => fa.bsbCode,
        'Balance' => fa.accountBalance,
        'ProductCode' => fa.productCode,
        'SubProductCode' => fa.subProductCode,
        'OpenedDate' => formatDate(fa.openDate),
        'OverdraftLimit' => fa.odLimit,
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
        'StopPayNumber' => fa.restrainsStopPayNumber,
        'ReferenceIndexType' => fa.debitInterestCode,
        'OverdraftReferenceIndexRate' => fa.debitInterestIndexRate,
        'TPMISAO' => String.isBlank(fa.tpmiNumber)
          ? ''
          : fa.tpmiNumber + '-' + fa.tpmiSAO +' '+fa.tpmiType,
        'LinkedLoanOffsets' => externalQueryHelper.formatAccountNumber(
          fa.productSetOff
        ),
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
        'Date_Closed' => formatDate(fa.closeDate),
        'ExpiryDate' => formatDate(fa.limitExpiryDate)
      };
      row = populateSeasonalLimits(row, fa.seasonalLimits);
      row = populateProductCodeWiseFields(row, fa);
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description This is used to populate the values based on Product Codes - DDA, FM, RSV, SSI
   * @param row Map<String, Object>
   * @param faObj Object
   * @return Map<String, Object>
   **/
  @TestVisible
  private Map<String, Object> populateProductCodeWiseFields(
    Map<String, Object> row,
    Object faObj
  ) {
    DepositAccountModel fa = (DepositAccountModel) faObj;
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();

    Map<String, Map<String, Object>> mapOProductCodeWithDataMappings = new Map<String, Map<String, Object>>{
      'RSV' => new Map<String, Object>{
        'ANZSICCode' => externalQueryHelper.retrieveIndustryCodeAndDescription(
          fa.anzsicCode
        ),
        'NumberOfSignatures' => MAP_NO_OF_SIGNATURES.get(fa.noOfSignatures) ??
          null,
        'PledgeAmount' => fa.pledgeAmount,
        'Pledge' => fa.pledge,
        'HardHold' => fa.restrainsHardHold,
        'BalanceAvailable' => fa.availableBalance,
        'CPID' => fa.controllingPostId,
        'ServiceChargeCode' => '',
        'Limit' => null,
        'StopPayNumber' => null,
        'ReferenceIndexRate' => null,
        'InterestRate' => null,
        'Margin' => null,
        'ServiceChargeWaiveCode' => null,
        'OverdraftLimit' => null,
        'OverdraftReferenceIndexRate' => null,
        'OverdraftInterestRate' => null,
        'OverdraftMargin' => null,
        'FluctuatingSeasonalLimit' => null,
        'Fluctuating_Seasonal_Limit_2' => null,
        'Fluctuating_Seasonal_Limit_3' => null,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.get(
          fa.sourceSystemStatus
        ) ?? fa.sourceSystemStatus
      },
      'DDA' => new Map<String, Object>{
        'ANZSICCode' => externalQueryHelper.retrieveIndustryCodeAndDescription(
          fa.anzsicCode
        ),
        'NumberOfSignatures' => MAP_NO_OF_SIGNATURES.get(fa.noOfSignatures) ??
          null,
        'PledgeAmount' => fa.pledgeAmount,
        'Pledge' => fa.pledge,
        'HardHold' => fa.restrainsHardHold,
        'BalanceAvailable' => fa.availableBalance,
        'CPID' => fa.controllingPostId,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.get(
          fa.sourceSystemStatus
        ) ?? fa.sourceSystemStatus
      },
      'FM' => new Map<String, Object>{
        'CPID' => fa.controllingPostId,
        'Limit' => null,
        'SourceSystemStatus' => fa.sourceSystemStatus
      },
      'SSI' => new Map<String, Object>{
        'Limit' => null,
        'SourceSystemStatus' => fa.sourceSystemStatus
      }
    };

    if(String.isBlank(fa.productcode) || !mapOProductCodeWithDataMappings.containsKey(fa.productcode)){
      return row;
    }
    Map<String, Object> mapOfFieldWithValues = mapOProductCodeWithDataMappings.get(
      fa.productCode
    );
    for (String fieldMapping : mapOfFieldWithValues.keySet()) {
      row.put(fieldMapping, mapOfFieldWithValues.get(fieldMapping));
    }
    return row;
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
    return row;
  }

  /**
   * @description Get Product Category based on ProductCode
   * @param queryMode QueryModeEnum
   * @param formattedAccountNumber AccountNumber
   * @return String
   **/
  @TestVisible
  private String getProductCategoryBasedOnProductCode(
    QueryModeEnum queryMode,
    String formattedAccountNumber
  ) {
    if (
      queryMode == QueryModeEnum.RELATED_LIST ||
      String.isBlank(formattedAccountNumber)
    ) {
      return this.productCategory;
    }
    String accountNumber = formattedAccountNumber.substringAfter('-');
    String productCode = getProductCode(accountNumber);
    Map<String, String> mapOfProductCodeWithProdCategory = new Map<String, String>{
      'FM' => 'savings',
      'SSI' => 'savings',
      'DDA' => 'deposit',
      'RSV' => 'deposit'
    };
    return mapOfProductCodeWithProdCategory.get(productCode) ?? null;
  }

  /**
   * @description Parse query filters and prepare for API callout
   * @param queryContext DataSource QueryContext
   * @return QueryMode Enum
   **/
  protected override ExternalObjectQueryBase.QueryModeEnum prepareCallout(
    DataSource.QueryContext queryContext
  ) {
    QueryModeEnum queryMode = super.prepareCallout(queryContext);

    //set productCategory based on Product Code for FM/SSI in deposit account
    this.productCategory = getProductCategoryBasedOnProductCode(
      queryMode,
      this.externalId
    );
    return queryMode;
  }
}
