/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group Platform
 * @description PTF external query class
 * Suppressing ExcessivePublicCount rule to allow for added callouts
 * @runTests PortfolioOfLoanExternalQueryTest
 */
public with sharing class PortfolioOfLoanExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description PTF account Model class
   */
  @testVisible
  private class PortfolioOfLoanAccountModel extends FinancialAccountModelBase {
    private String subProductCode;
    private DateTime openDate;
    private Decimal undrawnBalance;
    private String purposeCode;
    private String controllingPostId;
    private DateTime maturityDate;
    private Integer loanTermMonth;
    private Integer loanTermYears;
    private String tpmiNumber;
    private String subApprovedOrignation;
    private string statementMailingAddress;
    private string branchId;
    private string sourcesystemstatus;
  }
  /**
   * @description PTF API callout response
   */
  @testVisible
  private class PortfolioOfLoanCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<PortfolioOfLoanAccountModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public PortfolioOfLoanExternalQuery() {
    this.productCategory = 'ptf';
    this.productTypes = new Set<String>{ 'CAP-CIS:PTF' };
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
    this.calloutResponse = (PortfolioOfLoanCalloutResponse) CalloutModel.deserialize(
      responseBody,
      PortfolioOfLoanCalloutResponse.class
    );
    return this.calloutResponse;
  }

  private static final Map<String, String> MAP_OF_PURPOSE_CODE = new Map<String, String>{
    '000' => '000 - Revolving Line Of Credit',
    '100' => '100 - Purchase New Cars and Station Wagons',
    '101' => '101 - Purchase Used Cars and Station Wagons',
    '102' => '102 - Purchase Other Motor Vehicles',
    '103' => '103 - Purchase Motorcycles and Scooters',
    '104' => '104 - Purchase Boats, Caravans and Trailers',
    '120' => '120 - Purchase Residential Land Owner-Occupied',
    '130' => '130 - Unsecured Alteration or Addition to Existing Dwelling Owner-Occupied',
    '131' => '131 - Unsecured Purchase or Construct Dwelling Owner-Occupied',
    '140' => '140 - Purchase Household and Personal Goods',
    '141' => '141 - Ongoing Facility for Temporary Financing',
    '145' => '145 - Education',
    '150' => '150 - Debt Consolidation Non ANZ Loans',
    '155' => '155 - Graduates',
    '160' => '160 - Purchase Travel and Holidays',
    '170' => '170 - Refinance Existing ANZ Non-Business Loan',
    '180' => '180 - Dwellings for Rental or Resale',
    '185' => '185 - Other Shares, Bonds and Investments',
    '190' => '190 - Refinance OFI Investment Loan',
    '199' => '199 - Other Personal Use, Pools, Kitchens etc',
    '200' => '200 - Construct Dwellings for Rental or Resale',
    '201' => '201 - Construct Shops',
    '202' => '202 - Construct Non-Building Structures',
    '203' => '203 - Alteration or Addition to Commercial Buildings',
    '204' => '204 - Construct Offices',
    '205' => '205 - Construct Industrial Buildings',
    '206' => '206 - Construct Other Buildings',
    '210' => '210 - Purchase Dwellings for Rental or Resale',
    '211' => '211 - Purchase Shops',
    '212' => '212 - Purchase Rural Property',
    '213' => '213 - Purchase Land for Residential Block Development',
    '214' => '214 - Purchase Offices',
    '215' => '215 - Purchase Industrial Buildings',
    '216' => '216 - Purchase Other Buildings',
    '219' => '219 - Purchase Other Land',
    '220' => '220 - Purchase Motor Vehicles',
    '225' => '225 - Purchase Other Transport Equipment',
    '229' => '229 - Purchase Other Plant and Equipment',
    '230' => '230 - Factoring',
    '240' => '240 - Refinance Non-ANZ Business Loans',
    '241' => '241 - Refinance ANZ Business Loans',
    '250' => '250 - Wholesale Finance',
    '260' => '260 - Establish Business',
    '261' => '261 - Purchase Business',
    '299' => '299 - Other Commercial Use, Maintenance and Repairs',
    '300' => '300 - Construct House Not First Home-Buyer',
    '301' => '301 - Construct House First Home-Buyer',
    '310' => '310 - Construct Other Dwelling Not First Home-Buyer',
    '311' => '311 - Construct Other Dwelling First Home-Buyer',
    '320' => '320 - Purchase New House Not First Home-Buyer',
    '321' => '321 - Purchase New House First Home-Buyer',
    '330' => '330 - Purchase New Other Dwelling Not First Home-Buyer',
    '331' => '331 - Purchase New Other Dwelling First Home-Buyer',
    '340' => '340 - Purchase Existing House Not First Home-Buyer',
    '341' => '341 - Purchase Existing House First Home-Buyer',
    '350' => '350 - Purchase Existing Other Dwelling Not First Home-Buyer',
    '351' => '351 - Purchase Existing Other Dwelling First Home-Buyer',
    '360' => '360 - Alteration or Addition to Existing Dwellings',
    '370' => '370 - Refinance Non-ANZ Home Loans',
    '371' => '371 - Refinance ANZ Home Loans',
    '407' => '407 - Working Capital Other'
  };

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    'OP' => 'Open',
    'CL' => 'Closed',
    'CP' => 'Close Pending',
    'PD' => 'Pending Completion'
  };

  /**
   * @description Transform API response to PortfolioOfLoan Account records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (this.calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      PortfolioOfLoanAccountModel fa : ((PortfolioOfLoanCalloutResponse) this.calloutResponse)
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
        'AccountStatus' => MAP_SOURCE_SYSTEM_STATUS.get(fa.status) ?? fa.status,
        'ProductCode' => fa.productCode,
        'SubProductCode' => fa.subProductCode,
        'LoanTermMonth' => fa.loanTermMonth,
        'LoanTermYears' => fa.loanTermYears,
        'Expires' => formatDate(fa.maturityDate),
        'Limit' => fa.accountLimit,
        'DateOpened' => formatDate(fa.openDate),
        'UndrawnBalance' => fa.undrawnBalance,
        'PurposeCode' => MAP_OF_PURPOSE_CODE.containsKey(fa.purposeCode)
          ? MAP_OF_PURPOSE_CODE.get(fa.purposeCode)
          : fa.purposeCode,
        'CPID' => fa.controllingPostId,
        'TpmiSao' => String.isBlank(fa.tpmiNumber)
          ? ''
          : fa.tpmiNumber + '-' + fa.subApprovedOrignation,
        'StatementMailingAddress' => fa.statementMailingAddress,
        'Product_Name' => getProductName(fa.accountNumber),
        'Branch' => fa.branchId,
        'SourceSystemStatus' => MAP_SOURCE_SYSTEM_STATUS.containsKey(
            fa.sourcesystemstatus
          )
          ? fa.sourcesystemstatus +
            ' - ' +
            MAP_SOURCE_SYSTEM_STATUS.get(fa.sourcesystemstatus)
          : fa.sourcesystemstatus
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
