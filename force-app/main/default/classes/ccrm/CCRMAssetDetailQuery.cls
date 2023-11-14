/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Detail external query class
 */
public with sharing class CCRMAssetDetailQuery extends CCRMFinancialAccountQueryBase {
  /**
   * @description Asset Detail Model class
   */
  public class AssetDetailModel extends CCRMFinancialAccountModelBase {
    public String assetNumber;
    public String year;
    public String make;
    public String model;
    public String serialNumber;
    public Decimal purchasePrice;
    public String compositePhysicalAssetId;
    public Decimal ecvAmount;
    public String ecvDate;
    public String ecvValuer;
  }

  /**
   * @description Asset Detail callout response
   */
  public class AssetDetailCalloutResponse extends FinancialAccountCalloutResponse {
    public List<AssetDetailModel> assetDetails;
  }

  /**
   * @description constructor
   */
  public CCRMAssetDetailQuery() {
    this.productCategory = 'asset-finance';
    this.sourceSystem = SourceSystemEnum.EBD;
    this.fieldSet = 'PHYSICAL_ASSETS';
    this.externalField = 'compositePhysicalAssetId';
    this.assetFinanceType = 'AMBIT';
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
   * @description Transform API response to Asset Detail records
   * @return External object rows CCRMExternalObjectQueryBase.ExternalQueryResult
   */
  protected override CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts() {
    String customerId;
    Map<String, Object> row;
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();

    for (
      AssetDetailModel asset : ((AssetDetailCalloutResponse) this.calloutResponse)
        .assetDetails
    ) {
      row = new Map<String, Object>();
      row.put('ExternalId', asset.compositePhysicalAssetId);
      row.put(
        'DisplayUrl',
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        asset.compositePhysicalAssetId
      );
      List<String> values = asset.compositePhysicalAssetId != null
        ? asset.compositePhysicalAssetId.split('-')
        : null;
      String parentId = values != null
        ? values[0] + '-' + values[1] + '-' + values[2]
        : null;
      row.put(this.parent, parentId);
      row.put('Make', asset.make);
      row.put('Year', asset.year);
      row.put('Model', asset.model);
      row.put('PurchasePrice', asset.purchasePrice);
      row.put('SerialNo', asset.serialNumber);
      row.put('ECV', asset.ecvAmount);
      row.put(
        'ECVDate',
        String.isNotBlank(asset.ecvDate)
          ? adjustUTCDateTime(Date.valueOf(asset.ecvDate))
          : null
      );
      row.put('ECVValuer', asset.ecvValuer);
      row.put('AssetNo', asset.assetNumber);
      result.queryResult.add(row);
    }
    return result;
  }
}
