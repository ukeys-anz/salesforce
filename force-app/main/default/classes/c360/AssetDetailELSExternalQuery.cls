/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Detail ELS external query class
 */
public with sharing class AssetDetailELSExternalQuery extends FinancialAccountQueryBase {
  /**
   * @description Loan account Model class
   */
  public class AssetDetailModel extends FinancialAccountModelBase {
    public String id;
    public String manufacturedYear;
    public String make;
    public String model;
    public String serialNumber;
    public Decimal purchasePrice;
    public String compositeAssetId;
    public string assetFinancedValueInfoType;
  }

  /**
   * @description Asset Detail callout response
   */
  public class AssetDetailCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AssetDetailModel> assets;
  }

  /**
   * @description constructor
   */
  public AssetDetailELSExternalQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ASSETS';
    this.externalField = 'compositeAssetId';
    this.assetFinanceType = 'ELS';
  }
  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (AssetDetailCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetDetailCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to CreditCard records
   * @return External object rows ExternalObjectQueryBase.ExternalQueryResult
   * @param calloutResponse ExternalObjectCalloutResponse calloutResponse
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    for (
      AssetDetailModel asset : ((AssetDetailCalloutResponse) this.calloutResponse)
        .assets
    ) {
      Map<String, Object> row = new Map<String, Object>{
        'ExternalId' => asset.compositeAssetId,
        'DisplayUrl' => getDisplayUrl(asset.compositeAssetId),
        this.parentField => this.parentId,
        'Make' => asset.make,
        'Year' => asset.manufacturedYear,
        'Model' => asset.model,
        'PurchasePrice' => asset.purchasePrice,
        'SerialNo' => asset.serialNumber,
        'ValueType' => asset.assetFinancedValueInfoType,
        'AssetNo' => asset.id
      };
      result.externalRecords.add(row);
    }
    return result;
  }
}
