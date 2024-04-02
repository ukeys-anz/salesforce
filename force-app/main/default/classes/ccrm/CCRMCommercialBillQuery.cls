/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill external query class
 */
public with sharing class CCRMCommercialBillQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description CommercialBill business model class
   */
  public class CCRMCommercialBillModel extends CCRMFinancialAccountModelBase {
    public String compositeAccountNumber;
    public String sequenceNo;
    public String status;
    public DateTime openedDate;
    public DateTime expires;
    public String purposeCode;
    public Integer loanTermYears;
    public Integer loanTermMonths;
    public Decimal facilityAccountLimit;
    public Decimal capAccountLimit;
  }

  /**
   * @description Commecial Bill API callout response
   */
  public class CommercialBillCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerId;
    public List<CCRMCommercialBillModel> accounts;
  }
  /**
   * @description Class constructor
   */
  public CCRMCommercialBillQuery() {
    this.productCategory = 'commercial-bills';
    this.productTypes = new Set<String>();
    this.sourceSystem = SourceSystemEnum.EBD;
    this.externalField = 'compositeAccountNumber';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (CommercialBillCalloutResponse) CalloutModel.deserialize(
      responseBody,
      CommercialBillCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to MerchantFacility accounts
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    List<CCRMCommercialBillModel> accounts = new List<CCRMCommercialBillModel>();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    if (this.calloutResponse == null) {
      return result;
    }

    accounts = ((CommercialBillCalloutResponse) this.calloutResponse).accounts;
    //Pass pagination token
    result.queryMoreToken = this.calloutResponse.nextPageId;

    for (CCRMCommercialBillModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = String.isNotBlank(fa.compositeAccountNumber)
        ? fa.compositeAccountNumber.substringBefore('-')
        : null;
      row.put('CustomerId', 'CAP-CIS_' + customerId);
      row.put('ExternalId', fa.compositeAccountNumber);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        fa.accountNumber
      );
      row.put('AccountNumber', fa.accountNumber);
      row.put('AccountStatus', fa.status);
      row.put('SequenceNo', fa.sequenceNo);
      row.put('OpeningDate', formatDate(fa.openedDate));
      row.put('Expires', formatDate(fa.expires));
      row.put('PurposeCode', fa.purposeCode);
      row.put('LoanTermYears', fa.loanTermYears);
      row.put('LoanTermMonths', fa.loanTermMonths);
      row.put('FacilityLimit', fa.facilityAccountLimit);
      row.put('CAPAccountLimit', fa.capAccountLimit);

      result.queryResult.add(row);
    }
    return result;
  }
}
