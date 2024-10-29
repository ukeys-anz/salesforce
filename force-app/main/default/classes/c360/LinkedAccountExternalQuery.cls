/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description LinkedAccount external query class
 */
public with sharing class LinkedAccountExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description LinkedAccount Model class
   */
  public class LinkedAccountModel extends CCRMFinancialAccountModelBase {
    public String relateCode;
    public String accountNumber;
    public String productCode;
    public String compositeLinkedAccountId;
  }

  /**
   * @description LinkedAccount callout response
   */
  public class LinkedAccountResponse extends FinancialAccountCalloutResponse {
    public List<LinkedAccountModel> relatedAccounts;
  }

  /**
   * @description constructor
   */
  public LinkedAccountExternalQuery() {
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'LINKED_ACCOUNTS';
    this.externalField = 'compositeLinkedAccountId';
    this.productCategory = 'ptf';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed response
   */
  @TestVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (LinkedAccountResponse) CalloutModel.deserialize(
      responseBody,
      LinkedAccountResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to LinkedAccount records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  @TestVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    for (
      LinkedAccountModel acct : ((LinkedAccountResponse) this.calloutResponse)
        .relatedAccounts
    ) {
      String displayUrl = getDisplayUrl(acct.compositeLinkedAccountId);
      Map<String, Object> row = new Map<String, Object>{
        this.parentField => this.parentId,
        'ExternalId' => acct.compositeLinkedAccountId,
        'DisplayUrl' => displayUrl,
        'AccountNumber' => externalQueryHelper.formatAccountNumber(
          acct.accountNumber,
          acct.productCode
        ),
        'Code' => acct.relateCode,
        'ProductCode' => acct.productCode
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
