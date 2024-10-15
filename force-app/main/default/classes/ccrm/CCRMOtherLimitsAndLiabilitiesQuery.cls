/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Other Limits And Liabilities external query class
 */
public with sharing class CCRMOtherLimitsAndLiabilitiesQuery extends CCRMFinancialAccountQueryBase {
  private static final CCRMFinancialAccountQueryBaseRepository FAB_REPOSITORY = (CCRMFinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    CCRMFinancialAccountQueryBaseRepository.class
  );

  /**
   * @description OLL account Model class
   */
  @testVisible
  private class CCRMOtherLimitsAndLiabilitiesModel extends CCRMFinancialAccountModelBase {
    private String ollType;
    private String branch;
    private DateTime openingDate;
    private String controllingPostId;
    @testVisible
    private String anzsicCode;
    private String customerCreditRating;
    private DateTime inactiveDate;
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
  private class CCRMOLLCalloutResponse extends FinancialAccountCalloutResponse {
    private String customerid;
    @testVisible
    private List<CCRMOtherLimitsAndLiabilitiesModel> accounts;
  }
  /**
   * @description constructor
   */
  public CCRMOtherLimitsAndLiabilitiesQuery() {
    this.productCategory = 'oll';
    this.productTypes = new Set<String>{ 'CAP-CIS:OLL' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
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
    this.calloutResponse = (CCRMOLLCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CCRMOLLCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to OLL Account records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  @testVisible
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    List<CCRMOtherLimitsAndLiabilitiesModel> accounts = new List<CCRMOtherLimitsAndLiabilitiesModel>();
    Map<String, String> industryCodeAndNameMap = new Map<String, String>();

    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    if (this.calloutResponse != null) {
      accounts = ((CCRMOLLCalloutResponse) this.calloutResponse).accounts;
    }

    industryCodeAndNameMap = formIndustryCodeAndNameMap(
      ((CCRMOLLCalloutResponse) this.calloutResponse).accounts
    );

    for (
      CCRMOtherLimitsAndLiabilitiesModel fa : ((CCRMOLLCalloutResponse) this.calloutResponse)
        .accounts
    ) {
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      row = new Map<String, Object>{
        'CustomerId' => customerId,
        'ExternalId' => getExternalId(fa),
        'DisplayUrl' => getDisplayUrl(fa),
        'Relationship' => getAccountRelationship(fa.accountNumber),
        'AccountName' => fa.accountName,
        'AccountNumber' => this.sourceSystem == SourceSystemEnum.CAP
          ? getAccountNumberwithFormat(fa.accountNumber)
          : formatAccountNumber(fa.accountNumber),
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
        'Source_System_Status' => getSourceSystemStatus(fa.accountNumber)
      };
      result.queryResult.add(row);
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
    List<CCRMOtherLimitsAndLiabilitiesModel> ollRecords
  ) {
    Set<String> industryCodesSet = new Set<String>();
    List<Industry__c> industryRecList = new List<Industry__c>();
    Map<String, String> industryCodeNameMap = new Map<String, String>();

    for (CCRMOtherLimitsAndLiabilitiesModel ollRec : ollRecords) {
      if(ollRec.anzsicCode != null) {
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
