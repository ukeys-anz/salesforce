/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Asset external query class
 */
public with sharing class CCRMAssetQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Asset Model class
   */
  public class AssetModel extends CCRMFinancialAccountModelBase {
    public String id;
    public String status;
    public Decimal amountFinanced;
    public Decimal purchasePrice;
    public String compositeAssetId;
  }

  /**
   * @description Asset callout response
   */
  public class AssetCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AssetModel> assetDetails;
  }

  /**
   * @description constructor
   */
  public CCRMAssetQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.CAP;
    this.fieldSet = 'ASSETS';
    this.externalField = 'compositeAssetId';
    this.assetFinanceType = 'AMBIT';
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   */
  protected override void parseResponse(String responseBody) {
    this.calloutResponse = (AssetCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AssetCalloutResponse.class
    );
  }

  /**
   * @description Transform API response to Asset records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      AssetModel asset : ((AssetCalloutResponse) this.calloutResponse)
        .assetDetails
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
      row.put('AssetId', asset.id);
      row.put('Status', asset.status);
      row.put('AmountFinanced', asset.amountFinanced);
      row.put('PurchasePrice', asset.purchasePrice);
      result.queryResult.add(row);
    }
    return result;
  }
}
