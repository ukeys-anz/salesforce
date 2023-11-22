/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Detail ELS external query class
 */
public with sharing class CCRMAssetDetailELSQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Asset Detail Model class
   */
  public class AssetDetailModel extends CCRMFinancialAccountModelBase {
    public String id;
    public String manufacturedYear;
    public String make;
    public String model;
    public String serialNumber;
    public Decimal purchasePrice;
    public String compositeAssetId;
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
  public CCRMAssetDetailELSQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ASSETS';
    this.externalField = 'compositeAssetId';
    this.assetFinanceType = 'ELS';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (AssetDetailCalloutResponse) JSON.deserialize(
      responseBody,
      AssetDetailCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Asset Detail ELS records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      AssetDetailModel asset : ((AssetDetailCalloutResponse) this.calloutResponse)
        .assets
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', asset.compositeAssetId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        asset.compositeAssetId
      );
      List<String> values = asset.compositeAssetId != null
        ? asset.compositeAssetId.split('-')
        : null;
      String parentId = values != null ? values[0] + '-' + values[1] : null;
      row.put(this.parent, parentId);
      row.put('Make', asset.make);
      row.put('Year', asset.manufacturedYear);
      row.put('Model', asset.model);
      row.put('PurchasePrice', asset.purchasePrice);
      row.put('SerialNo', asset.serialNumber);
      row.put('AssetNo', asset.id);
      result.queryResult.add(row);
    }
    return result;
  }
}
