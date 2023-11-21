/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Term Deposit external query class
 */
public with sharing class CCRMTermDepositQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description TermDeposit Model class
   */
  public class CCRMTermDepositModel extends CCRMFinancialAccountModelBase {
    public String subProductCode;
    public Boolean restrainsHardHold;
    public Boolean pledge;
    public Decimal pledgeAmount;
    public Integer restrainsStopPayNumber;
    public DateTime openDate;
    public DateTime closeDate;
    public String bsbCode;
    public String anzsicCode;
    public String controllingPostId;
    public String noOfSignatures;
    public DateTime cdaIssueDate;
    public DateTime maturityDate;
    public Integer termYear;
    public Integer termMonth;
    public List<Decimal> creditInterestRateArray;
    public List<Integer> creditInterestLimitsArray;
  }

  /**
   * @description TermDeposit API callout response
   */
  public class TermAccountCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMTermDepositModel> accounts;
  }

  /**
   * @description Class constructor
   */
  public CCRMTermDepositQuery() {
    this.productCategory = 'deposit';
    this.productTypes = new Set<String>{ 'CAP-CIS:CDA' };
    this.sourceSystem = SourceSystemEnum.CAP;
    this.externalField = 'accountNumber';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (TermAccountCalloutResponse) JSON.deserialize(
      responseBody,
      TermAccountCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to TermDeposit records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    String customerId;
    Map<String, Object> row;
    List<CCRMTermDepositModel> accounts = new List<CCRMTermDepositModel>();

    if (this.calloutResponse != null) {
      accounts = ((TermAccountCalloutResponse) this.calloutResponse).accounts;
    }

    for (CCRMTermDepositModel fa : accounts) {
      row = new Map<String, Object>();
      customerId = getCustomerId(fa.accountNumber);
      if (String.isBlank(customerId)) {
        continue;
      }
      row.put('CustomerId', customerId);
      row.put('ExternalId', getExternalId(fa));
      row.put('DisplayUrl', getDisplayUrl(fa));
      row.put('Relationship', getAccountRelationship(fa.accountNumber));

      row.put('AccountName', fa.accountName);
      row.put('AccountNumber', formatAccountNumber(fa.accountNumber));
      row.put('AccountStatus', fa.status);
      row.put('Balance', fa.accountBalance);
      row.put('ProductCode', fa.productCode);
      row.put('SubProductCode', fa.subProductCode);
      row.put('RestraintsHold', fa.restrainsHardHold);
      row.put('Pledge', fa.pledge);
      row.put('PledgeAmount', fa.pledgeAmount);
      row.put('StopsPay', fa.restrainsStopPayNumber);
      row.put('DateOpened', adjustUTCDateTime(fa.openDate));
      row.put('DateClosed', adjustUTCDateTime(fa.closeDate));
      row.put('BSB', fa.bsbCode);
      row.put('ANZSICCode', fa.anzsicCode);
      row.put('CPID', fa.controllingPostId);
      row.put('NumberOfSignatures', fa.noOfSignatures);
      row.put('IssueDate', adjustUTCDateTime(fa.cdaIssueDate));
      row.put('MaturityDate', adjustUTCDateTime(fa.maturityDate));
      row.put('TermYear', fa.termYear);
      row.put('TermMonth', fa.termMonth);
      List<Decimal> creditInterestRateArray = new List<Decimal>();
      List<Integer> creditInterestLimitsArray = new List<Integer>();
      if (fa.creditInterestRateArray != null) {
        creditInterestRateArray.addAll(fa.creditInterestRateArray);
      }
      if (fa.creditInterestLimitsArray != null) {
        creditInterestLimitsArray.addAll(fa.creditInterestLimitsArray);
      }

      for (Integer i = 0; i < creditInterestLimitsArray.size() - 1; i++) {
        if (
          fa.accountBalance >= creditInterestLimitsArray[i] &&
          (fa.accountBalance <= creditInterestLimitsArray[i + 1] ||
          (creditInterestLimitsArray[i + 1] == 0 &&
          fa.accountBalance != 0))
        ) {
          row.put('InterestRate', creditInterestRateArray[i]);
          break;
        }
      }

      result.queryResult.add(row);
    }
    return result;
  }
}
