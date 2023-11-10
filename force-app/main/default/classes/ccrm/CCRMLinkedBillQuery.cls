/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Limked Bill external query class
 */
public with sharing class CCRMLinkedBillQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Linked Bill Model class
   */
  public class LinkedBillModel extends CCRMFinancialAccountModelBase {
    public String compositeBillId;
    public String billReferenceNo;
    public String billType;
    public Decimal billAmount;
    public String billSwapReferencePercentage;
    public DateTime billRollOverDate;
    public String billRollOverFrequency;
    public DateTime billExpiry;
    public String compositeAccountNumber;
    public Decimal billInterestRate;
  }

  /**
   * @description Linked Bill callout response
   */
  public class LinkedBillCalloutResponse extends FinancialAccountCalloutResponse {
    public List<LinkedBillModel> bills;
  }

  /**
   * @description constructor
   */
  public CCRMLinkedBillQuery() {
    this.productCategory = 'commercial-bills';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'BILLS';
    this.externalField = 'compositeBillId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (LinkedBillCalloutResponse) JSON.deserialize(
      responseBody,
      LinkedBillCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Linked Bill records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      LinkedBillModel bill : ((LinkedBillCalloutResponse) this.calloutResponse)
        .bills
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', bill.compositeBillId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        bill.compositeBillId
      );
      List<String> values = bill.compositeBillId != null
        ? bill.compositeBillId.split('-')
        : null;
      String parentId = values != null ? values[0] + '-' + values[1] : null;
      row.put(this.parent, parentId);
      row.put('BillType', bill.billType);
      row.put('ReferenceNo', bill.billReferenceNo);
      row.put('Amount', bill.billAmount);
      row.put('BankBillSwapReferenceRate', bill.billSwapReferencePercentage);
      row.put('RolloverDate', adjustUTCDateTime(bill.billRollOverDate));
      row.put('RolloverFrequency', bill.billRollOverFrequency);
      row.put('Expires', adjustUTCDateTime(bill.billExpiry));
      row.put('InterestRate', bill.billInterestRate);
      result.queryResult.add(row);
    }
    return result;
  }
}
