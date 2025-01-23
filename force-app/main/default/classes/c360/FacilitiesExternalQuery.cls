/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Facility Query external query class
 */
public with sharing class FacilitiesExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Facility Model class
   */
  public class FacilityModel extends FinancialAccountModelBase {
    public String compositeFacilityId;
    public Integer ollSequence;
    public String ollType;
    public Integer ollAmount;
    public DateTime ollExpiryDate;
    public String tpmiNumber;
    public String tpmiSubNumber;
    public String productName;
    public String sourceSystemStatus;
  }

  private static final Map<String, String> MAP_SOURCE_SYSTEM_STATUS = new Map<String, String>{
    'ACT' => 'ACT - Active',
    'DEL' => 'DEL - Deleted',
    'INA' => 'INA - Inactive'
  };

  private static final Map<String, String> MAP_PRODUCT_NAME = new Map<String, String>{
    'BCCL' => 'Business Credit Card Limits',
    'FEC' => 'Forward Exchange Contracts',
    'BN TRADE' => 'Bills Negotiated Not Under Credit (Trade Only)',
    'C/B/A' => 'Obsolete',
    'CBE' => 'Obsolete',
    'CBAD' => 'Commercial Bill Acceptance Discount',
    'APEP' => 'Australian Protected Equity Portfolio',
    'EXP TRADE' => 'Export Trade Facility',
    'LFCC' => 'Obsolete',
    'IB' => 'Obsolete',
    'BN CLEAN' => 'Bills Negotiated Not Under Credit (Envelope Debits)',
    'MER FAC' => 'Merchant Facilities',
    'GNT BORR' => 'Obsolete',
    'FCL NT' => 'Foreign Currency Loans (Non Trade)',
    'IG ETC' => 'Indemnity Guarantee',
    'DER TRAN' => 'Derivative Transactions',
    'CL CR LO' => 'Clean Credit Local',
    'CL CR O' => 'Obsolete',
    'LT O/BANK' => 'Obsolete',
    'FCL' => 'Trade Finance Loans',
    'ANZ OL' => 'ANZ Online Limits',
    'MML COM' => 'Money Market Lines Committed',
    'IMP TRADE' => 'Import Credit Trade Facility',
    'IMP LC' => 'Import Letter of Credit',
    'S/BY LC O' => 'Standby Letter of Credit',
    'DD' => 'Direct Debit Facility',
    'ML' => 'Margin Lending Facility',
    'INV FIN' => 'Invoice Finance',
    'CON C/BIL' => 'Consumer Commercial Bill',
    'ERMR' => 'Exchange Rate Movement Risk',
    'CACHE LMT' => 'Limit Authorised to CACHE',
    'TCL' => 'Obsolete',
    'SET' => 'Settlement Limit',
    'ASSET FIN' => 'Asset Finance Revolving Limit',
    'MKTS CCO' => 'Markets Covered Call Options'
  };
  /**
   * @description Facility callout response
   */
  public class FacilityCalloutResponse extends FinancialAccountCalloutResponse {
    public List<FacilityModel> facilities;
  }

  /**
   * @description constructor
   */
  public FacilitiesExternalQuery() {
    this.productCategory = 'oll';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'FACILITIES';
    this.externalField = 'compositeFacilityId';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse transformed api response
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (FacilityCalloutResponse) CalloutModel.deserialize(
      responseBody,
      FacilityCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to Facility records
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
      FacilityModel fac : ((FacilityCalloutResponse) this.calloutResponse)
        .facilities
    ) {
      if (fac.ollSequence == 0) {
        continue;
      }
      String tpmiSAO = '';
      if (
        String.isNotBlank(fac.tpmiNumber) ||
        String.isNotBlank(fac.tpmiSubNumber)
      ) {
        tpmiSAO = fac.tpmiNumber + '-' + fac.tpmiSubNumber;
      }

      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => fac.compositeFacilityId,
        'Facility' => fac.accountNumber +
        '-' +
        String.valueOf(fac.ollSequence),
        'DisplayUrl' => getDisplayUrl(
          fac.productCode + '-' + fac.accountNumber
        ),
        this.parentField => this.parentId,
        'Sequence' => fac.ollSequence,
        'Type' => fac.ollType,
        'Amount' => fac.ollAmount,
        'ExpiryDate' => formatDate(fac.ollExpiryDate),
        'Account_Name' => fac.accountName,
        'Account_Number' => externalQueryHelper.formatAccountNumber(
          fac.accountNumber
        ),
        'Source_System_Status' => MAP_SOURCE_SYSTEM_STATUS.get(
          fac.sourceSystemStatus
        ) ?? fac.sourceSystemStatus,
        'Product_Name' => MAP_PRODUCT_NAME.get(fac.productName) ??
          fac.productName,
        'TPMI_SAO' => tpmiSAO
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
