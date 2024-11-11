/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Limked Bill external query class
 */
public with sharing class LinkedBillExternalQuery extends FinancialAccountQueryBase {
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
  public LinkedBillExternalQuery() {
    this.productCategory = 'commercial-bills';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'BILLS';
    this.externalField = 'compositeBillId';
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
    this.calloutResponse = (LinkedBillCalloutResponse) CalloutModel.deserialize(
      responseBody,
      LinkedBillCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Linked Bill records
   * @param calloutResponse ExternalObjectCalloutResponse
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();

    if (calloutResponse == null) {
      return result;
    }
    for (
      LinkedBillModel bill : ((LinkedBillCalloutResponse) this.calloutResponse)
        .bills
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => bill.compositeBillId,
        'DisplayUrl' => getDisplayUrl(bill.compositeBillId),
        this.parentField => this.parentId,
        'BillType' => bill.billType,
        'ReferenceNo' => bill.billReferenceNo,
        'Amount' => bill.billAmount,
        'BankBillSwapReferenceRate' => bill.billSwapReferencePercentage,
        'RolloverDate' => formatDate(bill.billRollOverDate),
        'RolloverFrequency' => bill.billRollOverFrequency,
        'Expires' => formatDate(bill.billExpiry),
        'InterestRate' => bill.billInterestRate
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
