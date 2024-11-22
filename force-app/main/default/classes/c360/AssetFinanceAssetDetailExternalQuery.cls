/**
 * @author Nabia Nadir
 * @since  08/2024
 * @group CCRM (Commercial CRM)
 * @description Asset Finance Asset Detail external query class
 */
public with sharing class AssetFinanceAssetDetailExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  @testVisible
  private class AssetFinanceAssetDetailModel extends FinancialAccountModelBase {
    private String assetNumber;
    private String year;
    private String make;
    private String model;
    private String serialNumber;
    private Decimal purchasePrice;
    private String compositePhysicalAssetId;
    private Decimal ecvAmount;
    private Date ecvDate;
    private String ecvValuer;
  }

  /**
   * @description Asset Detail callout response
   */
  public class AssetFinanceAssetDetailCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AssetFinanceAssetDetailModel> physicalAssets;
  }

  /**
   * @description constructor
   */
  public AssetFinanceAssetDetailExternalQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'PHYSICAL_ASSETS';
    this.externalField = 'compositePhysicalAssetId';
    this.assetFinanceType = 'AMBIT';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @TestVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (AssetFinanceAssetDetailCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetFinanceAssetDetailCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse calloutResponse
   */
  @TestVisible
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    for (
      AssetFinanceAssetDetailModel asset : ((AssetFinanceAssetDetailCalloutResponse) this.calloutResponse)
        .physicalAssets
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => asset.compositePhysicalAssetId,
        'DisplayUrl' => getDisplayUrl(asset.compositePhysicalAssetId),
        this.parentField => this.parentId,
        'Make' => asset.make,
        'Year' => asset.year,
        'Model' => asset.model,
        'PurchasePrice' => asset.purchasePrice,
        'SerialNo' => asset.serialNumber,
        'ECV' => asset.ecvAmount,
        'ECVDate' => asset.ecvDate,
        'ECVValuer' => asset.ecvValuer,
        'AssetNo' => asset.assetNumber
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
