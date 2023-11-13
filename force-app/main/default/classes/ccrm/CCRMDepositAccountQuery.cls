/**
 * @author Ian Huang
 * @since  06/2023
 * @group CCRM (Commercial CRM)
 * @description Deposit Account external query class
 * @runTests CCRMDepositAccountQueryTest
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.NcssMethodCount'
)
public with sharing class CCRMDepositAccountQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Deposit account Model class
   */
  private class CCRMDepositAccountModel extends CCRMFinancialAccountModelBase {
    public String anzsicCode;
    public Boolean accountRestraint;
    public Boolean anzPlusIdentifier;
    public String bsb;
    public Decimal odLimit;
    public Decimal pledgeAmount;
    public Boolean pledge;
    public Decimal accountBalance;
    public Decimal availableBalance;
    public DateTime openDate;
    public String subProductCode;

    public Boolean accountRestrictions;
    public Boolean restrainsHardHold;
    public Boolean restrainsStopPay;
    public String restrainsStopPayNumber;
    public String controllingPostId;
    public String debitInterestCode;
    public Decimal debitInterestIndexRate;
    public Decimal debitInterestMargin;
    public Decimal debitInterestRate;
    public Decimal tempODAccountLimit;
    public Decimal tempODMargin;
    public Decimal tempODInterestRate;
    public Decimal tpmiNumber;
    public Decimal tpmiSAO;
    public String tempODInterestRepaymentFrequency;
    public String bsbCode;
    public Integer noOfSignatures;
    public DateTime tempODExpirytDate;
    public List<SeasonalLimits> seasonalLimits;
  }
  /**
   * @description SeasonalLimits class
   */
  public class SeasonalLimits {
    public Decimal seasonalLimit;
    public DateTime startDate;
    public DateTime endDate;
  }

  /**
   * @description DepositAccount API callout response
   */
  private class DepositAccountCalloutResponse extends FinancialAccountCalloutResponse {
    public String customerid;
    public List<CCRMDepositAccountModel> accounts;
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
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    if (String.isBlank(responseBody)) {
      return;
    }
    this.calloutResponse = (DepositAccountCalloutResponse) JSON.deserialize(
      responseBody,
      DepositAccountCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to DepositAccount records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    List<CCRMDepositAccountModel> accounts = new List<CCRMDepositAccountModel>();

    if (this.calloutResponse != null) {
      accounts = ((DepositAccountCalloutResponse) this.calloutResponse)
        .accounts;
    }

    for (CCRMDepositAccountModel fa : accounts) {
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
      row.put('ANZSICCode ', fa.anzsicCode);
      row.put('accountRestrictions', fa.accountRestrictions);
      row.put('ANZPlusIdentifier', fa.anzPlusIdentifier);
      row.put('BSB', fa.bsb);
      row.put('Balance', fa.accountBalance);
      row.put('BalanceAvailable', fa.availableBalance);
      row.put('CPID', fa.controllingPostId);
      row.put('ProductCode', fa.productCode);
      row.put('SubProductCode', fa.subProductCode);
      row.put('OpenedDate', adjustUTCDateTime(fa.openDate));
      row.put('OverdraftLimit', fa.odLimit);
      row.put('PledgeAmount', fa.pledgeAmount);
      row.put('Pledge', fa.pledge);

      row.put('HardHold', fa.restrainsHardHold);
      row.put('ReferenceIndexRate', fa.debitInterestIndexRate);
      row.put('Margin', fa.debitInterestMargin);
      row.put('InterestRate', fa.debitInterestRate);

      row.put('Limit', fa.tempODAccountLimit);
      row.put('OverdraftMargin', fa.tempODMargin);
      row.put('OverdraftInterestRate', fa.tempODInterestRate);
      row.put(
        'OverdraftLimitInterestRepaymentFrequency',
        fa.tempODInterestRepaymentFrequency
      );
      row.put('ExpiryDate', fa.tempODExpirytDate);
      row.put('BSB', fa.bsbCode);
      row.put('NumberOfSignatures', fa.noOfSignatures);
      row.put('StopPayNumber', fa.restrainsStopPayNumber);
      row.put('ReferenceIndexType', fa.debitInterestCode);
      row.put('OverdraftSAO', fa.tpmiSAO);
      row.put('OverdraftTPMI', fa.tpmiNumber);
      if (fa.seasonalLimits != null && fa.seasonalLimits.size() > 0) {
        if (fa.seasonalLimits[0].endDate != null) {
          row.put(
            'FluctuatingSeasonalExpiryDate',
            fa.seasonalLimits[0].endDate
          );
        }
        if (fa.seasonalLimits[0].seasonalLimit != null) {
          row.put(
            'FluctuatingSeasonalLimit',
            fa.seasonalLimits[0].seasonalLimit
          );
        }
        if (fa.seasonalLimits[0].startDate != null) {
          row.put(
            'FluctuatingSeasonalStartDate',
            fa.seasonalLimits[0].startDate
          );
        }
      }

      result.queryResult.add(row);
    }
    return result;
  }
}
