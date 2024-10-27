/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Other Limits And Liabilities external query class
 * @runTests OLLExternalQueryTest
 */
public with sharing class OtherLimitsAndLiabilitiesExternalQuery extends FinancialAccountQueryBase {
  private static final FinancialAccountQueryBaseRepository FAB_REPOSITORY = (FinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    FinancialAccountQueryBaseRepository.class
  );
  /**
   * @description OLL account Model class
   */
  @testVisible
  private class OtherLimitsAndLiabilitiesModel extends FinancialAccountModelBase {
    private String ollType;
    private String branch;
    private DateTime openingDate;
    private String controllingPostId;
    @testVisible
    private String anzsicCode;
    private String customerCreditRating;
    private DateTime inactiveDate;
    private String status;
  }

  private static final Map<String, String> MAP_ACCOUNT_STATUS = new Map<String, String>{
    'ACT' => 'Active',
    'DEL' => 'Deleted',
    'INA' => 'Inactive'
  };

  /**
   * @description OLL API callout response
   */
  @testVisible
  private class OLLCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<OtherLimitsAndLiabilitiesModel> accounts;
  }

  /**
   * @description constructor
   */
  public OtherLimitsAndLiabilitiesExternalQuery() {
    this.productCategory = 'oll';
    this.productTypes = new Set<String>{ 'CAP-CIS:OLL' };
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
    this.calloutResponse = (OLLCalloutResponse) CalloutModel.deserialize(
      responseBody,
      OLLCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to OLL Account records
   *  @param calloutResponse ExternalObjectCalloutResponse
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
    Map<String, String> industryCodeAndNameMap = formIndustryCodeAndNameMap(
      ((OLLCalloutResponse) this.calloutResponse).accounts
    );
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      OtherLimitsAndLiabilitiesModel fa : ((OLLCalloutResponse) this.calloutResponse)
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
        'AccountStatus' => MAP_ACCOUNT_STATUS.containsKey(fa.status)
          ? MAP_ACCOUNT_STATUS.get(fa.status)
          : fa.status,
        'OLLType' => fa.ollType,
        'Branch' => fa.branch,
        'DateOpened' => formatDate(fa.openingDate),
        'CPID' => fa.controllingPostId,
        'Limit' => fa.accountLimit,
        'Account_Name' => fa.accountName,
        'Industry' => industryCodeAndNameMap.get(fa.anzsicCode) ?? fa.anzsicCode,
        'CCR' => fa.customerCreditRating,
        'Date_Closed' => formatDate(fa.inactiveDate),
        'Product_Code' => fa.productCode,
        'Product_Name' => getProductName(fa.accountNumber),
        'Source_System_Status' => getSourceSystemStatus(fa.accountNumber)
      };
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description It is used to form the map of Industry Code and Description
   * @param ollRecords List of OLL records
   * @return Map<String, String> containing the code as key and value as Code + Name
   */
  @testVisible
  private Map<String, String> formIndustryCodeAndNameMap(
    List<OtherLimitsAndLiabilitiesModel> ollRecords
  ) {
    Set<String> industryCodesSet = new Set<String>();
    List<Industry__c> industryRecList = new List<Industry__c>();
    Map<String, String> industryCodeNameMap = new Map<String, String>();

    for (OtherLimitsAndLiabilitiesModel ollRec : ollRecords) {
      if (ollRec.anzsicCode != null) {
        industryCodesSet.add(ollRec.anzsicCode);
      }
    }

    industryRecList = FAB_REPOSITORY.getIndustry(industryCodesSet);

    for (Industry__c indRecord : industryRecList) {
      industryCodeNameMap.put(
        indRecord.Code__c,
        indRecord.Code__c + '-' + indRecord.Name
      );
    }
    return industryCodeNameMap;
  }
}
